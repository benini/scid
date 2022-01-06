lassign $argv codec basename srccodec srcbasename
if {$codec eq "" || $basename eq ""} {
    puts "Usage: scid bench_codec.tcl <SCID4|PGN> basename"
    exit 1
}

if {$srcbasename ne ""} {
    set elapsed [clock milliseconds]
    set srcId [sc_base open $srccodec $srcbasename]
    set elapsed [expr { [clock milliseconds] - $elapsed }]
    puts "Load ($elapsed ms) [sc_base numGames $srcId] games: $srcbasename ($srccodec)"

    set elapsed [clock milliseconds]
    set baseId [sc_base create $codec $basename]
    sc_base copygames $srcId dbfilter $baseId
    set elapsed [expr { [clock milliseconds] - $elapsed }]
    puts "Imported ($elapsed ms) [sc_base numGames $baseId] games: $basename ($codec)"

    sc_base close $srcId
    sc_base close $baseId
}

# Open the database:
set elapsed [clock milliseconds]
set baseId [sc_base open $codec $basename]
set elapsed [expr { [clock milliseconds] - $elapsed }]
puts "Open ($elapsed ms) [sc_base numGames $baseId] games: $basename ($codec)"

# Search position
lappend pos "r1bqkbnr/pp1ppppp/2n5/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq"
lappend pos "r4rk1/p2n1ppp/1p3n2/2p5/2PP4/4BN2/P4PPP/R3R1K1 w"
lappend pos "5k2/2R2p1p/3p2p1/p7/8/r5P1/4KP1P/8 w"
lappend pos "r2qkb1r/pp2pppp/2bp1n2/6B1/3QP3/2N2N2/PPP2PPP/R3K2R b KQkq"
lappend pos "k6r/1pQ2pp1/pBq1p2p/8/3R1P1P/bPK5/2P5/8 w"
lappend pos "r1bqkbnr/pp1ppppp/2n5/2p5/3PP3/5N2/PPP2PPP/RNBQKB1R b KQkq"
lappend pos "r2nr1k1/pp2B2p/q3bQp1/4p1N1/4P3/7P/2P3P1/1R3RK1 w"
lappend pos "rnbqk1nr/ppp1ppbp/3p2p1/8/3PPP2/2N5/PPP3PP/R1BQKBNR b KQkq"
lmap el $pos {
  sc_game startBoard $el
  set elapsed [clock milliseconds]
  sc_filter search $baseId "dbfilter" board nocache
  set elapsed [expr { [clock milliseconds] - $elapsed }]
  lassign [sc_filter sizes $baseId dbfilter] n_found
  puts "Search pos ($elapsed ms): $n_found games - $el"
}

# Collect extra tags
set elapsed [clock milliseconds]
set tags [sc_base taglist $baseId]
set elapsed [expr { [clock milliseconds] - $elapsed }]
puts "Collect tags ($elapsed ms): $basename ($codec)"
puts $tags

# Search pgn
set search_comments White
set elapsed [clock milliseconds]
sc_filter search $baseId "dbfilter" header -pgn $search_comments
set elapsed [expr { [clock milliseconds] - $elapsed }]
lassign [sc_filter sizes $baseId dbfilter] n_found
puts "Search pgn ($elapsed ms): $n_found games - $search_comments"

sc_base close $baseId
