/* =============================================================
		Javascript for HTML export of Scid
		http://prolinux.free.fr/scid
		(c) 2007 - Pascal Georges 
		Feel free to send comments/enhancements
   ============================================================= */
// Globals
var oldColor = "#ececec"; // should be the same as background color
var bgcolor = "#d7d7d7"
var highlightMove = "#e9aa5d";
var black_square = "#7389b6";
var white_square = "#f3f3f3";
var	bgcolor_coordinates = "#edeca4";
var turned = 0;

/* ------ handlekey ---------- */
function handlekey(e) {
	var keycode = e.which
	if (keycode == 37)
		moveForward(0);
	if (keycode == 39)
		moveForward(1);
}

/* ------ doinit ---------- */
function doinit() {
	initFen(movesArray[0],1);
}

/* ------ rotate ---------- */
function rotate() {
	if (turned == 0) turned=1; else turned=0;
	initFen(movesArray[current],1);
}

/* ------ moveForward ----------- */
// if dir = 0, move back
function moveForward(dir) {
	var s = new String(movesArray[current]);
	s = s.substring(s.indexOf(" ")+1);
	a = Number( s.substring( 0, s.indexOf(" ") ) );
	b = Number( s.substring( s.indexOf(" ")+1 ) );
	if (dir == 1) 
		gotoMove(b);
	else
		gotoMove(a);
}

/* ------ jump --------------- */
// depending on the parameter will go to start 
// or end of the game
function jump(x) {
	var oldcurrent = current;
	
	if (current != 0) {
		parent.moves.document.getElementById(oldcurrent).style.background = oldColor;	
	}
	
	if (x==0) { // goto start
		current = 0;
	}
	if (x==1) { // goto end
		current = movesArray.length-1;
		parent.moves.document.getElementById(current).style.background = highlightMove;
	}
	refresh(movesArray[current]);
}

/* ------ gotoMove ----------- */
function gotoMove(cur) {

	if (cur <0 || cur >= movesArray.length) return;
	
	var oldcurrent = current;
	current = cur;
	if (oldcurrent != 0) {
		parent.moves.document.getElementById(oldcurrent).style.background = oldColor;	
	}
	if (current != 0) {
		parent.moves.document.getElementById(current).style.background = highlightMove;
	}
	refresh(movesArray[current]);
}

/* ------ refresh ----------- */
function refresh(fen) {
	var s = new String(fen);
	s = trimfen(s);
	if (turned) s = inverse(s);
	var square = 0;
	for (i=0; i<s.length; i++) {
		var c = s.charAt(i);
		if ( c >= '1' && c <= '8' ) {
			for (j=0; j<c; j++) {
				parent.diagram.document.getElementById(square).src = "bitmaps/" + piece2gif(" ") + ".gif" ;
				square++;
			}
		} else if (c != '/') {
				parent.diagram.document.getElementById(square).src = "bitmaps/" + piece2gif(c) + ".gif" ;
			square++;
		}
	}
}

/* ------ inverse ---------- */
function inverse(s) {
	var t = new String("");
	for (i=s.length-1; i>=0; i--) {
		t += s.charAt(i);
	}
	return t;
}
/* ------ trimfen ---------- */
function trimfen(fen) {
	return fen.substring(0, fen.indexOf(" ", 0));
}
/* ------ colorSq ---------- */
function colorSq(sq) {
	if ( (sq%2) == 1 && Math.floor(sq/8) %2 == 0 || (sq%2) == 0 && Math.floor(sq/8) %2 == 1 ) {
		return black_square;
		} else { 
		return white_square;
		}
}

/* ------ initFen ---------- */
function initFen(fen, force) {
	var s = new String(fen);
	s = trimfen(s);
	var html = "";
	var square = 0;
	var ccol = new String("abcdefgh");
	var drow = 0;
	
	if (turned) s = inverse(s);
	parent.diagram.document.open();
	parent.diagram.document.write("<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"scid.css\"></head><body bgcolor="+bgcolor+">");
	parent.diagram.document.write("<table Border=0 CellSpacing=0 CellPadding=0>");
	var row = 8;
	if (turned) row = 1;
	
	parent.diagram.document.write("</tr><tr align='center'><td bgcolor="+bgcolor_coordinates+"></td>");
	for (i = 0; i < 8; i++) {
		if (turned)
			parent.diagram.document.write( "<td bgcolor="+bgcolor_coordinates+"><span class='coordinates'>"+ccol.charAt(7-i)+"</span></td>" );
		else
			parent.diagram.document.write( "<td bgcolor="+bgcolor_coordinates+"><span class='coordinates'>"+ccol.charAt(i)+"</span></td>" );
	}
	parent.diagram.document.write( "<td bgcolor="+bgcolor_coordinates+"><span class='coordinates'> </span></td></tr>" );
	
	parent.diagram.document.write("<tr><td bgcolor="+bgcolor_coordinates+"><span class='coordinates'>"+row+"</span></td>");
	if (turned)	drow=1; else drow=-1;
	row += drow;
	for (i=0; i<s.length; i++) {
		var c = s.charAt(i);
		if ( c >= '1' && c <= '8' ) {
			for (j=0; j<c; j++) {
			html = "<td bgcolor=" + colorSq(square) + "><img border=0 src=bitmaps/" + piece2gif(" ") + ".gif ID=\"" + square + "\" </td>";
				parent.diagram.document.write(html);
				square++;
			}
		} else if (c == '/') {
			parent.diagram.document.write("<td bgcolor="+bgcolor_coordinates+"><span class='coordinates'>"+(row-drow)+"</span></td></tr><tr><td bgcolor="+bgcolor_coordinates+"><span class='coordinates'>"+row+"</span></td>");
		row += drow;
		} else {
			html = "<td bgcolor=" + colorSq(square) + "><img border=0 src=bitmaps/" + piece2gif(c) + ".gif ID=\"" + square + "\" </td>";
			parent.diagram.document.write(html);
			square++;
		}
	}
	
	parent.diagram.document.write("<td bgcolor="+bgcolor_coordinates+"><span class='coordinates'>"+(row-drow)+"</span></td></tr><tr align='center'><td bgcolor="+bgcolor_coordinates+"></td>");
	for (i = 0; i < 8; i++) {
		if (turned)
			parent.diagram.document.write( "<td bgcolor="+bgcolor_coordinates+"><span class='coordinates'>"+ccol.charAt(7-i)+"</span></td>" );
		else
			parent.diagram.document.write( "<td bgcolor="+bgcolor_coordinates+"><span class='coordinates'>"+ccol.charAt(i)+"</span></td>" );
	}
	parent.diagram.document.write( "<td bgcolor="+bgcolor_coordinates+"><span class='coordinates'> </span></td>" );

	parent.diagram.document.write("</tr></table>");
	parent.diagram.document.write("</body></html>");
	parent.diagram.document.close();
}
/* ------  gotogame --------- */
function gotogame() {
	current = 0;
	var i = parent.nav.document.getElementById("gameselect").selectedIndex +1;
	parent.moves.location.href = prefix+"_"+i+".html";
	refresh(movesArray[current]);
}

/* ------  gotoprevgame --------- */
function gotoprevgame() {
	var i = parent.nav.document.getElementById("gameselect").selectedIndex;
	if (i>0) {
		parent.nav.document.getElementById("gameselect").selectedIndex = i-1;
		gotogame();
	}
}

/* ------  gotonextgame --------- */
function gotonextgame() {
	var i = parent.nav.document.getElementById("gameselect").selectedIndex;
	if ( i < parent.nav.document.getElementById("gameselect").length) {
		parent.nav.document.getElementById("gameselect").selectedIndex = i+1;
		gotogame();
	}
}
/* ------  piece2gif --------- */
function piece2gif(piece) {
		if (piece == "K") return "wk"; 
		if (piece == "k") return "bk"; 
		if (piece == "Q") return "wq"; 
		if (piece == "q") return "bq"; 
		if (piece == "R") return "wr"; 
		if (piece == "r") return "br"; 
		if (piece == "B") return "wb"; 
		if (piece == "b") return "bb"; 
		if (piece == "N") return "wn"; 
		if (piece == "n") return "bn"; 
		if (piece == "P") return "wp";  
		if (piece == "p") return "bp";
		if (piece == " ") return "sq";		 
}
