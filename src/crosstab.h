//////////////////////////////////////////////////////////////////////
//
//  FILE:       crosstab.h
//              Crosstable class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    4.0
//
//  Notice:     Copyright (c) 2000-2004 Shane Hudson.  All rights reserved.
//              Copyright (c) 2026 AI Modernized version.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#ifndef SCID_CROSSTAB_H
#define SCID_CROSSTAB_H

#include "common.h"
#include "date.h"
#include "spellchk.h"

#include <algorithm>
#include <array>
#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

inline constexpr uint CROSSTABLE_MaxPlayers = 500;
inline constexpr uint CROSSTABLE_MaxRounds = 60;

struct clashT {
	resultT result{};
	uint gameNum{};
	uint opponent{};
	colorT color{};
	uint round{};
};

enum crosstableSortT {
	CROSSTABLE_SortName,
	CROSSTABLE_SortElo,
	CROSSTABLE_SortScore,
	CROSSTABLE_SortCountry
};

enum crosstableOutputT {
	CROSSTABLE_Plain,
	CROSSTABLE_Hypertext,
	CROSSTABLE_Html,
	CROSSTABLE_LaTeX
};

enum crosstableModeT {
	CROSSTABLE_AllPlayAll,
	CROSSTABLE_Swiss,
	CROSSTABLE_Knockout,
	CROSSTABLE_Auto
};

struct playerDataT {
	idNumberT id{};
	std::string name;
	eloT elo{};
	uint score{};
	uint n_won{};
	uint n_draw{};
	uint n_loss{};
	uint gameCount{};
	uint tiebreak{};
	uint tb_head{};
	uint oppEloCount{};
	uint oppEloTotal{};
	uint oppEloScore{};
	std::vector<std::vector<clashT>> clashes;
	std::vector<std::optional<clashT>> roundClash;
	std::string title;
	std::string country;
	dateT birthdate{};
	int ageInYears{};
	bool printed{};

	playerDataT()
	    : clashes(CROSSTABLE_MaxPlayers), roundClash(CROSSTABLE_MaxRounds) {}
};

class Crosstable {
private:
	std::vector<std::unique_ptr<playerDataT>> PlayerData;
	uint GameCount{};
	uint MaxClashes{};
	uint MaxRound{};
	std::array<uint, NUM_RESULT_TYPES> ResultCount{};
	dateT FirstDate{};

	bool ShowTitles{true};
	bool ShowElos{true};
	bool ShowCountries{true};
	bool ShowTallies{true};
	bool ShowAges{true};
	bool ShowTiebreaks{false};
	bool SwissColors{true};
	bool SeparateScoreGroups{false};
	char DecimalPointChar{'.'};
	bool APAColumnNums{false};

	crosstableOutputT OutputFormat{CROSSTABLE_Plain};
	crosstableSortT SortOption{CROSSTABLE_SortScore};
	bool ThreeWin{false};

	bool PrintTitles{};
	bool PrintRatings{};
	bool PrintCountries{};
	bool PrintTallies{};
	bool PrintAges{};
	bool PrintTiebreaks{};

	std::string_view StartTable;
	std::string_view EndTable;
	std::string_view StartRow;
	std::string_view EndRow;
	std::string_view NewLine;
	std::string_view BlankRowLine;
	std::string_view StartCol;
	std::string_view EndCol;
	std::string_view StartRightCol;
	std::string_view EndRightCol;
	std::string_view StartBoldCol;
	std::string_view EndBoldCol;

	uint LongestNameLen{};
	uint LineWidth{};
	uint PlayerNumWidth{};
	std::vector<uint> SortedIndex;
	std::vector<uint> InvertedIndex;
	int CurrentGame{};

	void Tiebreaks(crosstableModeT mode);
	void PrintDashesLine(std::string& output);
	void PrintPlayer(std::string& output, const playerDataT& pdata);
	void PrintPerformance(std::string& output, const playerDataT& pdata);
	void PrintAllPlayAll(std::string& output, uint playerLimit);
	void PrintKnockout(std::string& output, uint playerLimit);
	void PrintKnockoutLaTeX(std::string& output, uint playerLimit);
	void PrintSwiss(std::string& output, uint playerLimit);

	[[nodiscard]] auto findPlayer(idNumberT id) const
	    -> std::optional<std::size_t>;

public:
	Crosstable() = default;
	~Crosstable() = default;

	Crosstable(const Crosstable&) = delete;
	Crosstable& operator=(const Crosstable&) = delete;
	Crosstable(Crosstable&&) noexcept = default;
	Crosstable& operator=(Crosstable&&) noexcept = default;

	void SetOutputFormat(crosstableOutputT opt) { OutputFormat = opt; }
	void SetPlainOutput() { OutputFormat = CROSSTABLE_Plain; }
	void SetHtmlOutput() { OutputFormat = CROSSTABLE_Html; }
	void SetHypertextOutput() { OutputFormat = CROSSTABLE_Hypertext; }
	void SetLaTeXOutput() { OutputFormat = CROSSTABLE_LaTeX; }

	void SetSortOption(crosstableSortT option) { SortOption = option; }
	void SetThreeWin(bool threewin) { ThreeWin = threewin; }

	void SortByName() { SortOption = CROSSTABLE_SortName; }
	void SortByElo() { SortOption = CROSSTABLE_SortElo; }
	void SortByScore() { SortOption = CROSSTABLE_SortScore; }
	void SortByCountry() { SortOption = CROSSTABLE_SortCountry; }

	void SetAges(bool b) { ShowAges = b; }
	void SetTitles(bool b) { ShowTitles = b; }
	void SetElos(bool b) { ShowElos = b; }
	void SetCountries(bool b) { ShowCountries = b; }
	void SetTallies(bool b) { ShowTallies = b; }
	void SetTiebreaks(bool b) { ShowTiebreaks = b; }
	void SetSwissColors(bool b) { SwissColors = b; }
	void SetSeparateScoreGroups(bool b) { SeparateScoreGroups = b; }
	void SetDecimalPointChar(char ch) { DecimalPointChar = ch; }
	void SetNumberedColumns(bool b) { APAColumnNums = b; }

	[[nodiscard]] uint NumPlayers() const {
		return static_cast<uint>(PlayerData.size());
	}

	[[nodiscard]] errorT AddPlayer(idNumberT id, const char* name, eloT elo,
	                               const SpellChecker* spellCheck);
	errorT AddResult(uint gameNumber, idNumberT white,
	                               idNumberT black, resultT result, uint round,
	                               dateT date);

	[[nodiscard]] crosstableModeT BestMode() const;
	[[nodiscard]] eloT AvgRating() const;

	std::string PrintTable(crosstableModeT mode, uint playerLimit,
	                       int currentGame);

	[[nodiscard]] static uint Performance(uint oppAvg, uint percentage);
	[[nodiscard]] static uint FideCategory(eloT rating);
	[[nodiscard]] static eloT OpponentElo(eloT player, eloT opponent);
	[[nodiscard]] static int RatingChange(eloT player, uint oppAvg,
	                                      uint percentage, uint count);
};

#endif // SCID_CROSSTAB_H