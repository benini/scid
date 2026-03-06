#!/bin/sh
# Lichess Broadcast Downloader
# POSIX-compliant - works on Linux, macOS, MinGW/MSYS/Cygwin

set -e

#--- Configuration ---
NB=100
OUTPUT_DIR="pgn_files"
COMBINED_FILE="lichess_broadcasts.pgn"
START_DATE=""
TMPDIR="${TMPDIR:-${TMP:-/tmp}}"
USE_API="no"

#--- Utility Functions ---

die() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

warn() {
    printf 'Warning: %s\n' "$1" >&2
}

show_help() {
    cat << 'EOF'
Usage: lichess-broadcasts.sh [OPTIONS]

Download Lichess broadcast PGNs.
Defaults to streaming bulk data from database.lichess.org/broadcast/.

Options:
  --use-api            Switch to API mode (download latest live/individual tournaments)
  -n, --number NUM     Number of broadcasts/files to fetch (default: 100)
  -d, --dir DIR        Output directory (API mode only) (default: pgn_files)
  -o, --output FILE    Combined PGN filename (default: lichess_broadcasts.pgn)
  -s, --start DATE     Only include broadcasts after YYYY-MM-DD (API mode only)
  -h, --help           Show this help

Examples:
  # Bulk download (fast, archived games)
  ./lichess-broadcasts.sh -n 10 -o bulk_games.pgn

  # API download (slower, includes live/recent metadata)
  ./lichess-broadcasts.sh --use-api -n 50 -s 2024-01-01
EOF
}

#--- Core Functions ---

# HTTP GET to file
http_get() {
    _url="$1"
    _out="$2"
    if [ "$HTTP_CMD" = "curl" ]; then
        curl -sSfL --retry 5 --connect-timeout 100 "$_url" -o "$_out" 2>/dev/null
    else
        wget -q -t 5 -T 100 "$_url" -O "$_out" 2>/dev/null
    fi
}

# HTTP GET stream to stdout
http_stream() {
    _url="$1"
    if [ "$HTTP_CMD" = "curl" ]; then
        curl -sSfL --retry 2 --connect-timeout 10 "$_url" 2>/dev/null
    else
        wget -q -t 2 -T 10 "$_url" -O - 2>/dev/null
    fi
}

date_to_epoch_ms() {
    _date="$1"
    if _epoch=$(date -d "$_date" +%s 2>/dev/null); then
        printf '%s000\n' "$_epoch"
        return 0
    fi
    if _epoch=$(date -j -f "%Y-%m-%d" "$_date" +%s 2>/dev/null); then
        printf '%s000\n' "$_epoch"
        return 0
    fi
    return 1
}

parse_broadcasts() {
    if [ "$HAS_JQ" = "yes" ]; then
        jq -r '"\(.tour.id)|\(.tour.name)"' 2>/dev/null
    else
        awk '
        {
            id = ""; name = ""
            if (match($0, /"tour":[^}]*"id":"[^"]+"/)) {
                s = substr($0, RSTART, RLENGTH); gsub(/.*"id":"/, "", s); gsub(/".*/, "", s); id = s
            }
            if (match($0, /"tour":[^}]*"name":"[^"]+"/)) {
                s = substr($0, RSTART, RLENGTH); gsub(/.*"name":"/, "", s); gsub(/".*/, "", s); name = s
            }
            if (id != "" && name != "") print id "|" name
        }'
    fi
}

filter_by_date() {
    if [ -z "$START_DATE" ]; then cat; return 0; fi
    if [ "$HAS_JQ" != "yes" ]; then
        warn "Date filtering requires jq - downloading all broadcasts"
        cat; return 0;
    fi
    _start_ms=$(date_to_epoch_ms "$START_DATE") || die "Cannot parse date: $START_DATE"
    jq -c --argjson s "$_start_ms" 'select(.tour.dates[0] >= $s)' 2>/dev/null
}

sanitize() {
    printf '%s' "$1" | tr -cd 'A-Za-z0-9 ._-' | tr ' ' '_' | cut -c1-100
}

#--- Modes ---

run_bulk_mode() {
    printf 'Mode: Bulk Download (database.lichess.org)\n'
    printf 'Output: %s\n' "$COMBINED_FILE"

    # Dependencies
    if ! command -v zstd >/dev/null 2>&1; then
        die "Bulk mode requires 'zstd' installed. Use --use-api or install zstd."
    fi

    : > "$COMBINED_FILE" || die "Cannot write to: $COMBINED_FILE"

    printf 'Fetching file list...\n'
    http_get "https://database.lichess.org/broadcast/list.txt" "$tmp_list" || die "Failed to fetch list.txt"

    # Sanitize list: remove \r (Windows line endings), empty lines
    tr -d '\r' < "$tmp_list" | grep -v '^\s*$' > "$tmp_parsed_full"

    total_avail=$(wc -l < "$tmp_parsed_full" | tr -d '[:space:]')
    if [ "$total_avail" -eq 0 ]; then
        die "Broadcast list is empty or could not be parsed."
    fi

    # Take last NB files (assuming list is chronological)
    if [ "$NB" -lt "$total_avail" ]; then
        tail -n "$NB" "$tmp_parsed_full" > "$tmp_parsed"
    else
        cat "$tmp_parsed_full" > "$tmp_parsed"
    fi

    total=$(wc -l < "$tmp_parsed" | tr -d '[:space:]')
    printf 'Processing %s broadcast archives...\n\n' "$total"

    count=0
    success=0

    while read -r url; do
        count=$((count + 1))
        # Extra safety check for URL validity
        case "$url" in
            http*) ;;
            *) continue ;;
        esac

        filename=$(basename "$url")
        printf '[%d/%d] Downloading: %s ... ' "$count" "$total" "$filename"

        # Stream -> Decompress -> Append
        # Note: zstd fails on empty input (e.g. if curl fails/404), ensuring we detect failures
        if http_stream "$url" | zstd -dc >> "$COMBINED_FILE" 2>/dev/null; then
            printf 'OK\n'
            success=$((success + 1))
        else
            printf 'FAILED\n'
        fi

    done < "$tmp_parsed"

    return 0
}

run_api_mode() {
    printf 'Mode: API Download (lichess.org/api)\n'
    mkdir -p "$OUTPUT_DIR" || die "Cannot create directory: $OUTPUT_DIR"
    : > "$COMBINED_FILE" || die "Cannot write to: $COMBINED_FILE"

    printf 'Fetching broadcast list (limit=%s)...\n' "$NB"
    http_get "https://lichess.org/api/broadcast?nb=${NB}" "$tmp_list" || die "Failed to download broadcast list"
    [ -s "$tmp_list" ] || die "Empty response from API"

    filter_by_date < "$tmp_list" | parse_broadcasts > "$tmp_parsed"

    total=$(wc -l < "$tmp_parsed" | tr -d '[:space:]')
    printf 'Found %s broadcasts to download\n\n' "$total"
    [ "$total" -gt 0 ] || { echo "No broadcasts match criteria"; exit 0; }

    count=0
    success=0
    failed=0

    while IFS='|' read -r id name || [ -n "$id" ]; do
        count=$((count + 1))
        [ -n "$id" ] || continue

        safe_name=$(sanitize "$name")
        filename="${id}_${safe_name}.pgn"
        filepath="$OUTPUT_DIR/$filename"

        printf '[%d/%d] %s ... ' "$count" "$total" "$name"

        if http_get "https://lichess.org/api/broadcast/${id}.pgn" "$filepath"; then
            if [ -s "$filepath" ]; then
                printf 'OK\n'
                {
                    printf '\n{ Broadcast: %s }\n' "$name"
                    cat "$filepath"
                    printf '\n'
                } >> "$COMBINED_FILE"
                success=$((success + 1))
            else
                printf 'EMPTY\n'
                rm -f "$filepath"
                failed=$((failed + 1))
            fi
        else
            printf 'FAILED\n'
            rm -f "$filepath"
            failed=$((failed + 1))
        fi
        sleep 1
    done < "$tmp_parsed"
}

#--- Initialization ---

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --use-api) USE_API="yes"; shift ;;
        -n|--number) NB="$2"; shift 2 ;;
        -d|--dir) OUTPUT_DIR="$2"; shift 2 ;;
        -o|--output) COMBINED_FILE="$2"; shift 2 ;;
        -s|--start) START_DATE="$2"; shift 2 ;;
        -h|--help) show_help; exit 0 ;;
        -*) die "Unknown option: $1" ;;
        *) shift ;;
    esac
done

# Detect HTTP client
HTTP_CMD=""
if command -v curl >/dev/null 2>&1; then HTTP_CMD="curl"
elif command -v wget >/dev/null 2>&1; then HTTP_CMD="wget"
else die "Neither curl nor wget found. Please install one."; fi

# Check for jq
HAS_JQ="no"
if command -v jq >/dev/null 2>&1; then HAS_JQ="yes"; fi

# Create temp files
tmp_list="$TMPDIR/lichess_list_$$.tmp"
tmp_parsed_full="$TMPDIR/lichess_parsed_full_$$.tmp"
tmp_parsed="$TMPDIR/lichess_parsed_$$.tmp"

cleanup() { rm -f "$tmp_list" "$tmp_parsed_full" "$tmp_parsed" 2>/dev/null || true; }
trap cleanup EXIT INT TERM HUP

#--- Main ---

if [ "$USE_API" = "yes" ]; then
    run_api_mode
else
    run_bulk_mode
fi

# Summary
if [ -f "$COMBINED_FILE" ]; then
    size_bytes=$(wc -c < "$COMBINED_FILE" | tr -d '[:space:]')
    if [ "$size_bytes" -ge 1048576 ]; then size="$((size_bytes / 1048576))MB"
    elif [ "$size_bytes" -ge 1024 ]; then size="$((size_bytes / 1024))KB"
    else size="${size_bytes}B"; fi
else
    size="0B"
fi

printf '\n===== Download Complete =====\n'
printf 'Combined PGN:    %s (%s)\n' "$COMBINED_FILE" "$size"
if [ "$USE_API" = "yes" ]; then
    printf 'Individual PGNs: %s/\n' "$OUTPUT_DIR"
fi