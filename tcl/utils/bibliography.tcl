###
### bibliography.tcl: part of Scid.
### Copyright (C) 2010 Alexander Wagner
###
### $Id: bibliography.tcl,v 1.3 2010/04/26 17:52:33 arwagner Exp $
###
### Last change: <Mon, 2010/04/26 19:51:13 arwagner ingata>
###
### Handle Bib pgn headers to show bibliographic references for a
### given game. The bibliographic database should be available in
### BibTeX format. The ref header should be of the form:
###
### [Bib "<bibtexkey>, <additional info> ; <bibtexkey>, <additional info>]
###
### E.g.
###     [Bib "Botvinnik:1960, No. 27 p.57"]
###
### Refering to the BibTeX record:
###
###     @BOOK{Botvinnik:1960,
###       title = {{O}ne hundred selected games},
###       publisher = {Dover Pub.},
###       year = {1960},
###       author = {Botvinnik, M. M.},
###       pages = {272},
###       address = {New York},
###       keywords = {Game Collection},
###       refid = {1106902}
###     }

###
#======================================================================

set m .menu.tools

# $m add command -label "Database information..." -command {::metadata::show}

#======================================================================
#
#======================================================================
namespace eval Bibliography {

	set literature ""

image create photo tb_bibliography -data {
	R0lGODlhEAAPAMZrAAAAAA4ODg0RFRYdJB0gIyUlJSInLiIsNC4vNC41OzM7Qi89STw8PDpETkFG
	TEJHS0JHTEVITD1KV0VJTj5MVzFOazJOa0ZLUDJPbElMTjNQbjRRbUtOUTVSbk5OTkVQXDpXdTxY
	dE5WXT1ZdD9adVZXWUJceFhbX0Rgfk5fcUlgeEVhfU1gcVteYUpielhgaUhkgltiaU5lfFNnfGJl
	aU1ph2JmaU9riWVpbmFqc1lsgFNtimdqbVJujFNvjV1vg2NvfF1xe15xhGBze1h0knBxc1p2k114
	lGx5cmB7mHF+d2V/m2aAnG5/kGuFoXSFloKIdHqKm36Pn4+UmYKYsY2gtqChgZ6lr5qqvJ6ruZut
	v6Sxv66wsqqyuqu6ya+7ybu9wMvMze7WgN3h5Obm6OTn6efo6evt7u7v8O/w8PDx8v//////////
	/////////////////////////////////////////////////////////////////////////yH+
	EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEKAH8ALAAAAAAQAA8AAAekgH+Cg4SFhQYAiYqKhgFYRzsr
	IyEkJikAhABeSzdinlAWKhSFBVpGVkMaFWIdKSKYggBbTD0oSp5ILhIZRYMMVUQ1QWIVFRszCSWw
	AF9OPjAgGMUyCzywfx5USTcoxMUsCg/LV1JRT01CPz86HyfXAC8IExwcEQ4QFzg07zk2XGZk0qA5
	E2bKtT8EEjUAkmVMGTVgWhwctOhAjC4TDf0RkGhAoUAAOw==
}

if {$png_image_support} {
	image create photo tb_bibliography -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAPCAYAAADtc08vAAACYElEQVR42q2TS0hUcRSHv7l3nHFG
		HXykk4KTmIObbGVpJG1aFSFFVEK7WojkplZBaEGbFolCEUhZSIkRlWXpYiaJsqRMsxoKo8YHSfkY
		argzdx733rn/FjoSItSiA2dzOOc7L37wn81eXrm1ExB/c0dOfjMgWdYAGlwuV+/Fa/cZfjtJTI2h
		RCMkEnGEAFmyIEsy2XKS/u52ANm6BtDbddeP7+UHlIjKjRNxQAayudwf5cFIDHd+DuHQdwHsBMw/
		AQe9Xi/hSAw1nuDA9gSnunQCwQimmWLoQiGPRjUyRJJcpw1gBLCkV5AB49bDpzyfCBL6GUZRFKo8
		SVoaHAC03lSYWsgkMh80s6U4lV7vvY72tsPpCY7X1dWx8CuOEo2h6zrFeSlaGhzsPr203EGW2FTk
		ZG5pjuJyDx3tbYcAW3oC0ed/zZPRSeYXQ6iqihJJH08AUOrOY3ZynNqqCjqvXALYBQxLwP76+noC
		wXnUWBzDMDAMg8dns1aLAYSuYjWTfAlOmSuhYQALIK739ImZxbDF0A00XUfTNMJKFGEuA4xUitDc
		VwqyZG73dJNhz2zVk4nzAFYAn99n+TTxJuUuKZFtGTIAmqZjmMtntlqtlHk8pAwd4GO6eBXgcDqp
		rtkm79u7hx21NQhT4HBmIgSkTJOZ6WlevBrjZHMjFkk6J0xzdTW5tGyz85l/IGdifMz9LaSqgc+z
		Ns1ix70hFyEEDrudqelZBgcHCLx/B0IcWU8DBUATcBUYAn4AonxLtXb0WJNxp9+nA8Lpyj/zL4La
		uPKixpy8wq60eIpKK/zrJf8GjDkZQZW6Gi0AAAAASUVORK5CYII=
	}
}

	#----------------------------------------------------------------------
	# Take a ref structure and turn it into a simplified version of
	# ISBD reference output
	#----------------------------------------------------------------------
	proc Ref2ISBD { Ref Biblio} {

		set w .showRef

		set key [lindex $Ref 0]
		set type ""
		set address   ""; set author    ""; set editor    ""; set number    "";
		set isbn      ""; set issn      ""; set issue     ""; set pages     "";
		set publisher ""; set title     ""; set volume    ""; set year      "";
		set edition   ""; set keywords  "";

		foreach tag { type address author editor number isbn issn issue pages publisher title volume year edition keywords } {
			set $tag [lindex [lindex $Ref [lsearch -exact -index 0 $Ref $tag]] 1]
		}
		regsub -all -nocase { and }    $author "; " author
		set isbd ""

		$w.f.tree insert {} end -id $key -text "$type: $author ($key)" -open true
		$w.f.tree insert $key end -id "l2$key" -text "$author" -tags {author}
		$w.f.tree insert $key end -id "l3$key" -text "$title"  -tags {title}
		$w.f.tree insert $key end -id "l4$key" -text "$Biblio" -tags {reference}
		if {$editor != ""} {
			$w.f.tree insert $key end -id "l5$key" -text "Ed. $editor"
		}
		if {$edition != ""} {
			$w.f.tree insert $key end -id "l6$key" -text  "$edition"
		}
		$w.f.tree insert $key end -id "l7$key" -text  "$address : $publisher, $year. - "
		if {$pages != ""} {
			$w.f.tree insert $key end -id "l8$key" -text  "$pages"
		}
		if {$isbn != ""} {
			$w.f.tree insert $key end -id "l9$key" -text  "$isbn"
		} elseif {$issn != ""} {
			$w.f.tree insert $key end -id "l9$key" -text  "$issn"
		}
		if {$keywords != ""} {
			$w.f.tree insert $key end -id "l0$key" -text  "$keywords"
		}

		### set isbd "\[$type\]\n"
		### set isbd "$author\n$title / $author.\n"
		### if {$editor != ""} {
		### 	set isbd "$isbd Ed. $editor\n"
		### }
		### set isbd "$isbd $edition\n"
		### set isbd "$isbd $address : $publisher, $year. - "
		### set isbd "$isbd $pages\n$isbn\n\n$keywords"

		# Simplified ISBD for book
		if {$type == "BOOK"} {
			set isbd "$author:\n$title / $author. Ed. $editor.\n- $edition -\n$address : $publisher, $year. - $pages\n$isbn\n\n$keywords\n"
		} elseif {$type == "PERIODICAL"} {
			# Simplified ISBD for journal
			set isbd "\[Journal\]\n$title / publ. $editor\n$address : $publisher, $year. - $pages\n$issn\n\n$keywords\n"
		} else {
			# use book format by default, should be improved
			set isbd "\[$type\]\n$author:\n$title / $author. Ed. $editor.\n - $edition - $address : $publisher, $year. - $pages\n$isbn ($issn)\n\n$keywords\n"
		}
		### set isbd "$isbd\n------------------------------------------------------------\n";

		return $isbd
	}

	#----------------------------------------------------------------------
	# Simple BibTeX reader. Does not handle all the funny things of
	# BibTeX like crossref etc. assumes all tags in a single line
	#----------------------------------------------------------------------
	proc ReadBibTeX { bibfile } {
		set fd [open $bibfile]

		set Bibentries {}

		set type ""
		set key  ""
		set address   ""; set author    ""; set editor    ""; set number    "";
		set isbn      ""; set issn      ""; set issue     ""; set pages     "";
		set publisher ""; set title     ""; set volume    ""; set year      "";
		set edition   ""; set keywords  "";

		while { [gets $fd line] >= 0} {
			if {[regexp -- "@" $line]} {
				# begin of dataset
				lappend Bibentries [list \
					"$key" \
					[list "type" $type] \
					[list "title" $title] \
					[list "editor" $editor] \
					[list "author" $author] \
					[list "publisher" $publisher] \
					[list "pages" $pages] \
					[list "address" $address] \
					[list "isbn" $isbn] \
					[list "issn" $issn] \
					[list "volume" $volume] \
					[list "issue" $issue] \
					[list "number" $number] \
					[list "edition" $edition] \
					[list "keywords" $keywords] \
					[list "year"  $year] ]

				regsub {\{.*} $line "" type
				regsub {\@} $type "" type
				## set type [string lower type]
				regsub {.*\{} $line "" key
				regsub {,}    $key  "" key

				set key [string trim $key]
				set type [string trim $type]

				set address   ""; set author    ""; set editor    ""; set number    "";
				set isbn      ""; set issn      ""; set issue     ""; set pages     "";
				set publisher ""; set title     ""; set volume    ""; set year      ""
				set edition   ""; set keywords  "";
			} else {
				regsub -all { "} $line {} line
				regsub -all {" } $line {} line
				regsub -all {,$} $line {} line
				regsub -all {[\{\}]} $line {} line

			}
			if {[regexp -- {[ \t]title[ \t=]} $line]} {
				regsub -all {title .*= } $line {} title
				set title [string trim $title]
			}
			if {[regexp -- {[ \t]author[ \t=]} $line]} { 
				regsub -all {author .*= } $line {} author
				set author [string trim $author]
			}
			if {[regexp -- {[ \t]editor[ \t=]} $line]} { 
				regsub -all {editor .*= } $line {} editor
				set editor [string trim $editor]
			}
			if {[regexp -- {[ \t]year[ \t=]} $line]} {
				regsub -all {year .*= } $line {} year
				set year [string trim $year]
			}
			if {[regexp -- {[ \t]publisher[ \t=]} $line]} {
				regsub -all {publisher .*= } $line {} publisher
				set publisher [string trim $publisher]
			}
			if {[regexp -- {[ \t]address[ \t=]} $line]} {
				regsub -all {address .*= } $line {} address
				set address [string trim $address]
			}
			if {[regexp -- {[ \t]isbn[ \t=]} $line]} {
				regsub -all {isbn.*= } $line {} isbn
				set isbn [string trim $isbn]
			}
			if {[regexp -- {[ \t]issn[ \t=]} $line]} {
				regsub -all {issn.*= } $line {} issn
				set issn [string trim $issn]
			}
			if {[regexp -- {[ \t]issue[ \t=]} $line]} {
				regsub -all {issue.*= } $line {} issue
				set issue [string trim $issue]
			}
			if {[regexp -- {[ \t]volume[ \t=]} $line]} {
				regsub -all {volume.*= } $line {} volume
				set volume [string trim $volume]
			}
			if {[regexp -- {[ \t]number[ \t=]} $line]} {
				regsub -all {number.*= } $line {} number
				set number [string trim $number]
			}
			if {[regexp -- {[ \t]edition[ \t=]} $line]} {
				regsub -all {edition.*= } $line {} edition
				set edition [string trim $edition]
			}
			if {[regexp -- {[ \t]keywords[ \t=]} $line]} {
				regsub -all {keywords.*= } $line {} keywords
				set keywords [string trim $keywords]
			}
		}
		close $fd
		return $Bibentries
	}

	#----------------------------------------------------------------------
	# Extract the Ref header from the current game. Uses bibfile as
	# input for bibliographic information, returns a block of ISBD
	# formatted entries
	#----------------------------------------------------------------------
	proc ExtractRef { bibfile } {

		set w .showRef

		set Extra  [sc_game tags get Extra]
		set extraTagsList [split $Extra "\n"]

		set literature ""

		foreach i $extraTagsList {
			if { [string equal -nocase [lindex $i 0] "Bib" ] } {
				set ref [string range $i 5 end-1]

				regsub -all { ; } $ref {|} ref

				# Tcl uses a list of split chars as second argument :(
				set ref [split $ref "|"]
				
				set BibEntries [::Bibliography::ReadBibTeX $bibfile]

				foreach r $ref {
					regsub -all {, .*} $r {} BibKey
					regsub -all {.*, } $r {} Biblio
					set BibKey [string trim $BibKey]
					set Biblio [string trim $Biblio]
					set idx [lsearch -exact -index 0 $BibEntries $BibKey]
					set BibDta [lindex $BibEntries $idx]

					set isbd [::Bibliography::Ref2ISBD $BibDta $Biblio]
					set literature "$literature\n$isbd\n$Biblio\n\n"
				}
			}
		}
		set lit [string trim $literature]
		return $lit
	}

	#----------------------------------------------------------------------
	# Open a window with an expanded tree widget containing all
	# referenced entities from the BibTeX file.
	#----------------------------------------------------------------------
	proc ShowRef {} {

		set w .showRef

		if { [winfo exists $w] } {
			# recreate the widget with new data
			destroy $w
		}

		toplevel $w
		::setTitle $w "References"
		setWinLocation $w
		setWinSize $w

		ttk::frame $w.f
		pack $w.f -fill both -expand 1

		ttk::treeview  $w.f.tree -xscrollcommand "$w.f.xbar set" -yscrollcommand "$w.f.ybar set" -show tree -selectmode none
		ttk::scrollbar $w.f.xbar -command "$w.f.tree xview" -orient horizontal
		ttk::scrollbar $w.f.ybar -command "$w.f.tree yview" -orient vertical
		$w.f.tree column #0 -minwidth 1200

		$w.f.tree tag configure author -foreground blue
		$w.f.tree tag configure title -foreground blue
		$w.f.tree tag configure reference -foreground red

		pack $w.f.xbar -side bottom -fill x
		pack $w.f.ybar -side right  -fill y
		pack $w.f.tree -side left   -expand 1 -fill both

		set bibfile "[sc_base filename].bib"
		set ::Bibliography::literature [::Bibliography::ExtractRef $bibfile]

		bind $w <Escape> { destroy  .showRef}
		bind $w <Configure>  {
			recordWinSize .showRef
		}
		# Copy references to clipboard
		bind $w <Control-Insert> { clipboard clear; clipboard append $::Bibliography::literature }
		bind $w <Control-c>      { clipboard clear; clipboard append $::Bibliography::literature }
		
	}

}

###
### End of file: bibliography.tcl
###
