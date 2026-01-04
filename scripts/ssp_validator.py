#!/usr/bin/env python3
"""
spelling_validator.py - Validate spelling files and export to Parquet

Copyright (C) 2026 Fulvio Benini

This file is part of Scid (Shane's Chess Information Database).

Scid is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation.

Scid is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Scid. If not, see <http://www.gnu.org/licenses/>.
"""

import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

try:
    import pyarrow as pa
    import pyarrow.parquet as pq

    HAS_PYARROW = True
except ImportError:
    HAS_PYARROW = False


@dataclass
class Player:
    """Player data from spelling file."""

    name: str
    aliases: list[str] = field(default_factory=list)
    title: str = ""
    countries: list[str] = field(default_factory=list)
    peak_elo: int = 0
    birthdate: str = ""
    deathdate: str = ""
    bio: list[str] = field(default_factory=list)
    elo_history: dict[int, list[int]] = field(default_factory=dict)


@dataclass
class NameEntry:
    """Generic name entry (event, site, round)."""

    name: str
    aliases: list[str] = field(default_factory=list)
    comment: str = ""


@dataclass
class GeneralCorrection:
    """Prefix/Infix/Suffix correction rule."""

    correction_type: str  # prefix, infix, suffix
    name_type: str  # PLAYER, EVENT, SITE, ROUND
    wrong: str
    correct: str


class SpellingValidator:
    """
    Validates and parses spelling files.

    A spelling file contains correct names for players, events, sites and rounds.
    It can also provide additional information for players like ELO, birthdate, etc.

    File format:
        @SECTION "exclude_chars"
        Correct Name                    #comment with metadata
        =Alias Name
        %Prefix "wrong" "correct"
        %Infix "wrong" "correct"
        %Suffix "wrong" "correct"
        %Bio Biography text
        %Elo YEAR:r1,r2,r3,... YEAR:r1,r2,...
    """

    # Expected ELO entries per year based on FIDE publication schedule
    ELO_PERIODS: dict[range, int] = {
        range(1970, 1990): 1,  # Annual
        range(1990, 2001): 2,  # Biannual
        range(2001, 2009): 4,  # Quarterly
        range(2009, 2010): 5,  # Transition (2 trimonthly + 3 bimonthly)
        range(2010, 2012): 6,  # Bimonthly
        range(2012, 2013): 9,  # Transition (3 bimonthly + 6 monthly)
        range(2013, 2100): 12,  # Monthly
    }

    VALID_SECTIONS = {"PLAYER", "EVENT", "SITE", "ROUND"}

    TITLE_PATTERN = re.compile(
        r"^(gm|im|fm|wgm|wim|wfm|w|cgm|cim|hgm)(\+w)?$", re.IGNORECASE
    )

    COUNTRY_PATTERN = re.compile(r"^[A-Z]{3}$")

    ELO_BRACKET_PATTERN = re.compile(r"\[(\d+)\]")

    def __init__(self):
        self.players: list[Player] = []
        self.events: list[NameEntry] = []
        self.sites: list[NameEntry] = []
        self.rounds: list[NameEntry] = []
        self.corrections: list[GeneralCorrection] = []
        self.errors: list[str] = []
        self.warnings: list[str] = []

        self._current_section: Optional[str] = None
        self._current_entry: Optional[Player | NameEntry] = None
        self._exclude_chars: str = ""
        self._line_num: int = 0

    def _expected_elo_count(self, year: int) -> int:
        """Get expected number of ELO ratings for a given year."""
        for year_range, count in self.ELO_PERIODS.items():
            if year in year_range:
                return count
        return 0

    def _parse_comment(self, comment: str) -> dict:
        """
        Parse player comment string.

        Format: #<title> <countries...> [<peak_elo>] <birthdate>--<deathdate>
        Example: #gm+w HUN GER [2735] 1976.07.23--
        """
        result = {
            "title": "",
            "countries": [],
            "peak_elo": 0,
            "birthdate": "",
            "deathdate": "",
        }

        if not comment:
            return result

        parts = comment.split()
        if not parts:
            return result

        # Title (first token)
        if self.TITLE_PATTERN.match(parts[0]):
            result["title"] = parts[0].upper()
            parts = parts[1:]

        # Countries (3-letter codes before '[')
        while parts and self.COUNTRY_PATTERN.match(parts[0]):
            result["countries"].append(parts[0])
            parts = parts[1:]

        # Peak ELO [number]
        if parts and parts[0].startswith("["):
            elo_match = self.ELO_BRACKET_PATTERN.match(parts[0])
            if elo_match:
                result["peak_elo"] = int(elo_match.group(1))
                parts = parts[1:]

        # Dates: birthdate--deathdate
        if parts:
            date_str = parts[0]
            if "--" in date_str:
                birth, death = date_str.split("--", 1)
                result["birthdate"] = birth
                result["deathdate"] = death
            else:
                result["birthdate"] = date_str

        return result

    def _parse_elo(self, elo_str: str) -> dict[int, list[int]]:
        """
        Parse ELO data string.

        Format: YEAR:r1,r2,?,r3 YEAR:r1,r2,...
        '?' represents unknown/missing rating (stored as 0)
        """
        result: dict[int, list[int]] = {}

        for year_data in elo_str.split():
            if ":" not in year_data:
                continue

            year_str, ratings_str = year_data.split(":", 1)

            try:
                year = int(year_str)
            except ValueError:
                self.errors.append(f"Line {self._line_num}: Invalid year '{year_str}'")
                continue

            if year < 1900 or year > 2100:
                self.warnings.append(f"Line {self._line_num}: Suspicious year {year}")

            ratings: list[int] = []
            for r in ratings_str.split(","):
                r = r.strip()
                if r == "?":
                    ratings.append(0)
                elif r.isdigit():
                    rating = int(r)
                    if rating > 0 and (rating < 1000 or rating > 3500):
                        self.warnings.append(
                            f"Line {self._line_num}: Suspicious rating {rating}"
                        )
                    ratings.append(rating)
                elif r:  # Non-empty invalid string
                    self.errors.append(f"Line {self._line_num}: Invalid rating '{r}'")

            # Validate count
            expected = self._expected_elo_count(year)
            if expected > 0 and len(ratings) != expected:
                self.warnings.append(
                    f"Line {self._line_num}: Year {year} has {len(ratings)} "
                    f"ratings, expected {expected}"
                )

            if year in result:
                self.warnings.append(
                    f"Line {self._line_num}: Duplicate ELO data for year {year}"
                )

            result[year] = ratings

        return result

    def _parse_correction(self, line: str) -> Optional[tuple[str, str]]:
        """
        Parse correction directive.

        Format: %Prefix "wrong" "correct"
        """
        matches = re.findall(r'"([^"]*)"', line)

        if len(matches) != 2:
            self.errors.append(
                f"Line {self._line_num}: Invalid correction syntax, "
                f"expected two quoted strings"
            )
            return None

        if not matches[0]:
            self.errors.append(
                f"Line {self._line_num}: Empty 'wrong' pattern in correction"
            )
            return None

        return matches[0], matches[1]

    def _finalize_entry(self):
        """Add current entry to appropriate list."""
        if self._current_entry is None:
            return

        if self._current_section == "PLAYER":
            if isinstance(self._current_entry, Player):
                self.players.append(self._current_entry)
        elif self._current_section == "EVENT":
            if isinstance(self._current_entry, NameEntry):
                self.events.append(self._current_entry)
        elif self._current_section == "SITE":
            if isinstance(self._current_entry, NameEntry):
                self.sites.append(self._current_entry)
        elif self._current_section == "ROUND":
            if isinstance(self._current_entry, NameEntry):
                self.rounds.append(self._current_entry)

        self._current_entry = None

    def _parse_section_header(self, line: str):
        """Parse section header: @SECTION "exclude_chars" """
        self._finalize_entry()

        # Parse: @PLAYER ", .-"
        content = line[1:]  # Skip '@'
        parts = content.split('"')
        section = parts[0].strip().upper()

        if section not in self.VALID_SECTIONS:
            self.errors.append(f"Line {self._line_num}: Unknown section '{section}'")
            self._current_section = None
            return

        self._current_section = section
        self._exclude_chars = parts[1] if len(parts) >= 2 else ""

    def _parse_alias(self, line: str):
        """Parse alias: =alternative_name"""
        alias = line[1:].strip()

        if not alias:
            self.warnings.append(f"Line {self._line_num}: Empty alias")
            return

        if self._current_entry is None:
            self.errors.append(f"Line {self._line_num}: Alias without preceding name")
            return

        self._current_entry.aliases.append(alias)

    def _parse_directive(self, line: str):
        """Parse % directives."""
        if line.startswith("%Prefix "):
            parsed = self._parse_correction(line)
            if parsed and self._current_section:
                self.corrections.append(
                    GeneralCorrection(
                        "prefix", self._current_section, parsed[0], parsed[1]
                    )
                )

        elif line.startswith("%Infix "):
            parsed = self._parse_correction(line)
            if parsed and self._current_section:
                self.corrections.append(
                    GeneralCorrection(
                        "infix", self._current_section, parsed[0], parsed[1]
                    )
                )

        elif line.startswith("%Suffix "):
            parsed = self._parse_correction(line)
            if parsed and self._current_section:
                self.corrections.append(
                    GeneralCorrection(
                        "suffix", self._current_section, parsed[0], parsed[1]
                    )
                )

        elif line.startswith("%Bio "):
            if not isinstance(self._current_entry, Player):
                self.errors.append(
                    f"Line {self._line_num}: %Bio outside PLAYER section"
                )
                return
            bio_text = line[5:].strip()
            if bio_text:
                self._current_entry.bio.append(bio_text)

        elif line.startswith("%Elo "):
            if not isinstance(self._current_entry, Player):
                self.errors.append(
                    f"Line {self._line_num}: %Elo outside PLAYER section"
                )
                return
            elo_data = self._parse_elo(line[5:])
            self._current_entry.elo_history.update(elo_data)

        else:
            directive = line.split()[0] if line.split() else line
            self.warnings.append(
                f"Line {self._line_num}: Unknown directive '{directive}'"
            )

    def _parse_new_name(self, line: str, comment: str):
        """Parse new canonical name entry."""
        if self._current_section is None:
            self.errors.append(f"Line {self._line_num}: Name outside section")
            return

        self._finalize_entry()

        if self._current_section == "PLAYER":
            self._current_entry = Player(name=line)
            parsed = self._parse_comment(comment)
            self._current_entry.title = parsed["title"]
            self._current_entry.countries = parsed["countries"]
            self._current_entry.peak_elo = parsed["peak_elo"]
            self._current_entry.birthdate = parsed["birthdate"]
            self._current_entry.deathdate = parsed["deathdate"]
        else:
            self._current_entry = NameEntry(name=line, comment=comment)

    def parse_line(self, line: str):
        """Parse a single line from spelling file."""
        self._line_num += 1

        # Split comment (# starts comment)
        comment = ""
        if "#" in line:
            idx = line.index("#")
            comment = line[idx + 1 :].strip()
            line = line[:idx]

        line = line.strip()

        # Empty line
        if not line:
            return

        # Section header
        if line.startswith("@"):
            self._parse_section_header(line)
            return

        # Alias
        if line.startswith("="):
            self._parse_alias(line)
            return

        # Directives
        if line.startswith("%"):
            self._parse_directive(line)
            return

        # Old bio format (deprecated, ignored)
        if line.startswith(">"):
            self.warnings.append(
                f"Line {self._line_num}: Old bio format '>' is deprecated"
            )
            return

        # New name entry
        self._parse_new_name(line, comment)

    def parse_file(self, filepath: Path):
        """Parse entire spelling file."""
        encodings = ["utf-8", "latin-1", "cp1252"]

        for encoding in encodings:
            try:
                with open(filepath, "r", encoding=encoding) as f:
                    for line in f:
                        self.parse_line(line.rstrip("\n\r"))
                break
            except UnicodeDecodeError:
                if encoding == encodings[-1]:
                    raise
                continue

        self._finalize_entry()

        # Post-parse validation
        self._validate_elo_sorting()
        self._check_duplicates()

    def _validate_elo_sorting(self):
        """Ensure ELO years are properly sorted for each player."""
        for i, player in enumerate(self.players):
            years = list(player.elo_history.keys())
            if years != sorted(years):
                self.warnings.append(f"Player '{player.name}': ELO years not sorted")

    def _check_duplicates(self):
        """Check for duplicate canonical names."""
        for name, entries in [
            ("players", self.players),
            ("events", self.events),
            ("sites", self.sites),
            ("rounds", self.rounds),
        ]:
            names = [e.name for e in entries]
            seen = set()
            for n in names:
                if n in seen:
                    self.warnings.append(f"Duplicate {name[:-1]} name: '{n}'")
                seen.add(n)

    def to_parquet(self, output_dir: Path):
        """Export all data to Parquet files."""
        if not HAS_PYARROW:
            raise ImportError(
                "pyarrow is required for Parquet export. "
                "Install with: pip install pyarrow"
            )

        output_dir.mkdir(parents=True, exist_ok=True)

        # Players table
        if self.players:
            players_data = {
                "name": [p.name for p in self.players],
                "aliases": [p.aliases for p in self.players],
                "title": [p.title for p in self.players],
                "countries": [p.countries for p in self.players],
                "peak_elo": pa.array(
                    [p.peak_elo for p in self.players], type=pa.int32()
                ),
                "birthdate": [p.birthdate for p in self.players],
                "deathdate": [p.deathdate for p in self.players],
                "bio": [p.bio for p in self.players],
            }
            table = pa.table(players_data)
            pq.write_table(table, output_dir / "players.parquet", compression="zstd")
            print(f"  Written: players.parquet ({len(self.players)} records)")

        # ELO history (separate table for efficiency)
        elo_records = []
        for i, p in enumerate(self.players):
            for year in sorted(p.elo_history.keys()):
                ratings = p.elo_history[year]
                for period, rating in enumerate(ratings):
                    elo_records.append(
                        {
                            "player_idx": i,
                            "player_name": p.name,
                            "year": year,
                            "period": period,
                            "rating": rating,
                        }
                    )

        if elo_records:
            elo_data = {
                "player_idx": pa.array(
                    [r["player_idx"] for r in elo_records], type=pa.int32()
                ),
                "player_name": [r["player_name"] for r in elo_records],
                "year": pa.array([r["year"] for r in elo_records], type=pa.int16()),
                "period": pa.array([r["period"] for r in elo_records], type=pa.int8()),
                "rating": pa.array([r["rating"] for r in elo_records], type=pa.int16()),
            }
            table = pa.table(elo_data)
            pq.write_table(
                table, output_dir / "elo_history.parquet", compression="zstd"
            )
            print(f"  Written: elo_history.parquet ({len(elo_records)} records)")

        # Events, Sites, Rounds
        for name, entries in [
            ("events", self.events),
            ("sites", self.sites),
            ("rounds", self.rounds),
        ]:
            if entries:
                data = {
                    "name": [e.name for e in entries],
                    "aliases": [e.aliases for e in entries],
                    "comment": [e.comment for e in entries],
                }
                table = pa.table(data)
                pq.write_table(
                    table, output_dir / f"{name}.parquet", compression="zstd"
                )
                print(f"  Written: {name}.parquet ({len(entries)} records)")

        # Corrections
        if self.corrections:
            data = {
                "type": [c.correction_type for c in self.corrections],
                "name_type": [c.name_type for c in self.corrections],
                "wrong": [c.wrong for c in self.corrections],
                "correct": [c.correct for c in self.corrections],
            }
            table = pa.table(data)
            pq.write_table(
                table, output_dir / "corrections.parquet", compression="zstd"
            )
            print(
                f"  Written: corrections.parquet " f"({len(self.corrections)} records)"
            )

    def to_json(self, output_file: Path):
        """Export all data to JSON file."""
        import json

        data = {
            "players": [
                {
                    "name": p.name,
                    "aliases": p.aliases,
                    "title": p.title,
                    "countries": p.countries,
                    "peak_elo": p.peak_elo,
                    "birthdate": p.birthdate,
                    "deathdate": p.deathdate,
                    "bio": p.bio,
                    "elo_history": {str(k): v for k, v in p.elo_history.items()},
                }
                for p in self.players
            ],
            "events": [
                {"name": e.name, "aliases": e.aliases, "comment": e.comment}
                for e in self.events
            ],
            "sites": [
                {"name": s.name, "aliases": s.aliases, "comment": s.comment}
                for s in self.sites
            ],
            "rounds": [
                {"name": r.name, "aliases": r.aliases, "comment": r.comment}
                for r in self.rounds
            ],
            "corrections": [
                {
                    "type": c.correction_type,
                    "name_type": c.name_type,
                    "wrong": c.wrong,
                    "correct": c.correct,
                }
                for c in self.corrections
            ],
        }

        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

        print(f"  Written: {output_file}")

    def write_report(self, output_file: Path):
        """Write validation report to file."""
        with open(output_file, "w", encoding="utf-8") as f:
            f.write("=" * 60 + "\n")
            f.write("SPELLING FILE VALIDATION REPORT\n")
            f.write("=" * 60 + "\n\n")

            f.write("SUMMARY\n")
            f.write("-" * 40 + "\n")
            f.write(f"Players:     {len(self.players):>8}\n")
            f.write(f"Events:      {len(self.events):>8}\n")
            f.write(f"Sites:       {len(self.sites):>8}\n")
            f.write(f"Rounds:      {len(self.rounds):>8}\n")
            f.write(f"Corrections: {len(self.corrections):>8}\n")
            f.write(f"Errors:      {len(self.errors):>8}\n")
            f.write(f"Warnings:    {len(self.warnings):>8}\n")
            f.write("\n")

            if self.errors:
                f.write("ERRORS\n")
                f.write("-" * 40 + "\n")
                for error in self.errors:
                    f.write(f"  {error}\n")
                f.write("\n")

            if self.warnings:
                f.write("WARNINGS\n")
                f.write("-" * 40 + "\n")
                for warning in self.warnings:
                    f.write(f"  {warning}\n")
                f.write("\n")

        print(f"  Written: {output_file}")

    def print_report(self):
        """Print validation report to console."""
        print("\n" + "=" * 50)
        print("VALIDATION REPORT")
        print("=" * 50)
        print(f"Players:     {len(self.players):>8}")
        print(f"Events:      {len(self.events):>8}")
        print(f"Sites:       {len(self.sites):>8}")
        print(f"Rounds:      {len(self.rounds):>8}")
        print(f"Corrections: {len(self.corrections):>8}")

        if self.errors:
            print(f"\n❌ ERRORS ({len(self.errors)}):")
            for error in self.errors[:20]:
                print(f"   {error}")
            if len(self.errors) > 20:
                print(f"   ... and {len(self.errors) - 20} more")

        if self.warnings:
            print(f"\n⚠️  WARNINGS ({len(self.warnings)}):")
            for warning in self.warnings[:20]:
                print(f"   {warning}")
            if len(self.warnings) > 20:
                print(f"   ... and {len(self.warnings) - 20} more")

        if not self.errors and not self.warnings:
            print("\n✅ No issues found!")

        print()


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="Validate spelling file and optionally export to Parquet/JSON",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s spelling.ssp
  %(prog)s spelling.ssp -o ./output --parquet
  %(prog)s spelling.ssp -o data.json --json
  %(prog)s spelling.ssp --report validation.txt
        """,
    )

    parser.add_argument("input", type=Path, help="Input spelling file (.ssp)")

    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="Output path (directory for Parquet, file for JSON)",
    )

    parser.add_argument(
        "--parquet", action="store_true", help="Export to Parquet format"
    )

    parser.add_argument("--json", action="store_true", help="Export to JSON format")

    parser.add_argument("--report", type=Path, help="Write validation report to file")

    parser.add_argument(
        "-q", "--quiet", action="store_true", help="Suppress console output"
    )

    args = parser.parse_args()

    if not args.input.exists():
        print(f"Error: Input file not found: {args.input}", file=sys.stderr)
        return 1

    # Parse file
    if not args.quiet:
        print(f"Parsing: {args.input}")

    validator = SpellingValidator()

    try:
        validator.parse_file(args.input)
    except Exception as e:
        print(f"Error parsing file: {e}", file=sys.stderr)
        return 1

    # Print report
    if not args.quiet:
        validator.print_report()

    # Write report file
    if args.report:
        validator.write_report(args.report)

    # Export to Parquet
    if args.parquet:
        if not HAS_PYARROW:
            print(
                "Error: pyarrow required for Parquet export. "
                "Install with: pip install pyarrow",
                file=sys.stderr,
            )
            return 1

        output_dir = args.output or (args.input.parent / "parquet_output")
        if not args.quiet:
            print(f"\nExporting to Parquet: {output_dir}")
        validator.to_parquet(output_dir)

    # Export to JSON
    if args.json:
        output_file = args.output or args.input.with_suffix(".json")
        if not args.quiet:
            print(f"\nExporting to JSON: {output_file}")
        validator.to_json(output_file)

    # Return error code based on validation errors
    return 1 if validator.errors else 0


if __name__ == "__main__":
    sys.exit(main())
