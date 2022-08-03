/*
 * Copyright (C) 2022  Fulvio Benini.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/** @file
 * Encode a game according to the PGN standard.
 */

#pragma once

#include <algorithm>
#include <string>
#include <string_view>

namespace pgn {

// We want to split the PGN text in lines to make it more readable, but we do
// not want to insert extra newline chars inside comments or tag values.
// This implies that even very long comment would stay on a single line if the
// user didn't insert newline chars himself.
// However it is possible to set @e hard_len (i.e to 1024) to allow converting
// spaces to newline chars in lines longer than @e hard_len.
template <int desired_len = 80, char breakpoint_char = '\0', int hard_len = 0,
          typename Iter>
Iter break_lines(Iter begin, Iter end) {
	auto line_first_char = begin;
	auto last_breakpoint = begin;
	auto it = begin;
	while (true) {
		it = find_if(it, end, [&](char ch) {
			return ch == '\n' || ch == breakpoint_char;
		});

		// Change the last breakpoint to newline char if the line would exceed
		// the desired length and there weren't newline chars (for example in
		// comments) beetween this and the last breakpoint.
		if (std::distance(line_first_char, it) > desired_len &&
		    last_breakpoint > line_first_char) {
			*last_breakpoint = '\n';
			line_first_char = last_breakpoint + 1;
		}

		// If a secondary line length was requested, try to convert spaces to
		// newline chars (this is not desiderable, but old software may use
		// limited fixed size buffer when reading PGNs).
		if (hard_len != 0 && std::distance(line_first_char, it) > hard_len) {
			line_first_char = break_lines<hard_len, ' '>(line_first_char, it);
		}

		if (it == end)
			break;

		if (*it == '\n') {
			line_first_char = ++it;
		} else /*  *it == breakpoint_char  */ {
			last_breakpoint = it;
			*it++ = ' ';
		}
	}
	return line_first_char;
}

// Escape quote and backslash chars according to the PGN standard:
// "A quote inside a string is represented by the backslash immediately followed
// by a quote. A backslash inside a string is represented by two adjacent
// backslashes."
// @param str: the string containing the chars to be escaped.
// @param pos: start of the substring of @e str to be processed.
template <typename TCont>
void escape_string(TCont& str, typename TCont::size_type pos) {
	auto it = str.begin() + pos;
	while (true) {
		it = std::find_if(it, str.end(),
		                  [](char ch) { return ch == '\\' || ch == '\"'; });
		if (it != str.end())
			it = str.insert(it, '\\') + 2;
		else
			break;
	}
}

// Encode a tag pair according to the PGN standard.
// "A tag pair is composed of four consecutive tokens: a left bracket token, a
// symbol token, a string token, and a right bracket token. The symbol token is
// the tag name and the string token is the tag value associated with the tag
// name. There are no white space characters between the left bracket and the
// tag name, there are no white space characters between the tag value and the
// right bracket, and there is a single space character between the tag name and
// the tag value."
// @param unknown_to_question_mark: if true, and a Seven Tag Roster is unknown,
// its tag value is changed to a single question mark.
template <bool unknown_to_question_mark = false, typename TCont>
void encode_tag_pair(std::string_view tag, std::string_view value,
                     TCont& dest) {
	dest.push_back('[');
	dest.insert(dest.end(), tag.begin(), tag.end());
	dest.push_back('\0');

	dest.push_back('"');
	if (unknown_to_question_mark && value.empty() &&
	    (tag == "Event" || tag == "Site" || tag == "Round" || tag == "White" ||
	     tag == "Black")) {
		dest.push_back('?');
	} else {
		auto value_begin = dest.size();
		dest.insert(dest.end(), value.begin(), value.end());
		escape_string(dest, value_begin);
	}
	dest.push_back('"');

	dest.push_back(']');
	// "Each tag pair should appear left justified on a line by itself"
	dest.push_back('\n');
}

// Encode a comment as "rest of the line": this comment type starts with a
// semicolon character and continues to the end of the line.
// If @e comment include any newline or line break char the comment cannot be
// encoded in this way: it return false and does not modify @e dest.
template <int hard_len = 0, typename TCont>
[[nodiscard]] bool encode_comment_rest_of_line(std::string_view comment,
                                               TCont& dest) {
	if ((hard_len != 0 && comment.size() >= hard_len) ||
	    std::any_of(comment.begin(), comment.end(),
	                [](char ch) { return ch == '\n' || ch == '\0'; }))
		return false;

	if (!dest.empty() && dest.back() != '\0' && dest.back() != '\n') {
		dest.push_back('\0');
	}
	dest.push_back(';');
	dest.insert(dest.end(), comment.begin(), comment.end());
	dest.push_back('\n');
	return true;
}

// Encode a comment in one of the two kinds specified by PGN standard.
// The kind that "starts with a left brace character and continues to the next
// right brace character" is preferred and used if the comment do not contains
// curly braces itself. If the comments contains both curly braces and newline
// or line break chars the curly braces inside the comment are replaced with
// UTF-8 fullwidth curly braces.
template <int hard_len = 0, typename TCont>
static void encode_comment(std::string_view comment, TCont& dest) {
	auto is_curly = [](char ch) { return ch == '{' || ch == '}'; };
	auto it_curly = std::find_if(comment.begin(), comment.end(), is_curly);
	if (it_curly != comment.end() &&
	    encode_comment_rest_of_line<hard_len>(comment, dest))
		return;

	dest.push_back('{');
	dest.insert(dest.end(), comment.begin(), comment.end());
	if (it_curly != comment.end()) {
		// Replace curly braces with UTF-8 fullwidth curly braces U+FF5B
		// (ef bd 9b) or U+FF5D (ef bd 9d).
		auto it = dest.end() - std::distance(it_curly, comment.end());
		do {
			auto replace_char = (*it == '{') ? u8"\uFF5B" : u8"\uFF5D";
			static_assert(std::u8string_view(u8"\uFF5D").size() == 3);
			it = dest.insert(it, 2, '\0');
			it = std::copy_n(replace_char, 3, it);

			it = std::find_if(it, dest.end(), is_curly);
		} while (it != dest.end());
	}
	dest.push_back('}');
	dest.push_back('\0');
}

// Encode the movetext section according to the PGN standard.
// @param m: iterator to the list of moves.
// @param initial_ply: the ply of the initial position.
//                     Should be even if it is white turn to move.
// @param dest: the container where movetext section will be appended.
template <int hard_len = 0, typename Iter, typename TCont>
void encode_movetext(Iter m, long long initial_ply, TCont& dest) {
	std::vector<long long> ply = {initial_ply};
	auto move_end = dest.size();
	dest.push_back('\n');

	// Check if there is a pre-game comment
	if (!m->comment.empty())
		encode_comment<hard_len>(m->comment, dest);

	while ((m = m->nextMoveInPGN())) {
		if (m->startMarker()) {
			ply.push_back(ply.back() - 1);
			dest.push_back('(');
			if (!m->comment.empty())
				encode_comment<hard_len>(m->comment, dest);

		} else if (m->endMarker()) {
			if (m->nextMoveInPGN()) {
				ply.pop_back();
				if (dest.back() == '\0') {
					dest.back() = ')';
				} else {
					dest.push_back(')');
				}
				dest.push_back('\0');
			}

		} else {
			auto white_to_move = (ply.back() % 2) == 0;
			if (white_to_move || move_end != dest.size()) {
				auto move_number = std::to_string(ply.back() / 2 + 1);
				move_number.append(white_to_move ? 1 : 3, '.');
				dest.insert(dest.end(), move_number.begin(), move_number.end());
			}
			std::string_view san = m->san;
			dest.insert(dest.end(), san.begin(), san.end());
			dest.push_back('\0');
			move_end = dest.size();
			ply.back()++;

			for (int i = 0, n = m->nagCount; i < n; ++i) {
				dest.push_back('$');
				auto nag_str = std::to_string(m->nags[i]);
				dest.insert(dest.end(), nag_str.begin(), nag_str.end());
				dest.push_back('\0');
			}
			if (!m->comment.empty())
				encode_comment<hard_len>(m->comment, dest);
		}
	}

	if (dest.back() == '\0')
		dest.back() = '\n';
}

// Encode a game according to the PGN standard.
// @param game: the game to be encoded.
// @param dest: the container where the PGN Game will be appended.
template <int hard_len = 0, typename TGame, typename TCont>
void encode_game(TGame const& game, TCont& dest) {
	game.viewTagPairs(
	    [&](auto tag, auto value) { encode_tag_pair(tag, value, dest); });

	encode_movetext<hard_len>(game.movetree(), game.initialPlyCounter(), dest);

	auto result = game.GetResultStr();
	dest.insert(dest.end(), result.begin(), result.end());
	dest.push_back('\n');
}

// Encode a game according to the PGN standard, adding newline chars to make it
// more readable.
// @param game: the game to be encoded.
// @param dest: the container where the PGN Game will be appended.
template <int desired_len = 80, typename TGame, typename TCont>
void encode(TGame const& game, TCont& dest) {
	auto begin = dest.size();
	encode_game(game, dest);
	break_lines<desired_len>(dest.begin() + begin, dest.end());
}

} // namespace pgn
