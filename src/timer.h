/*
* Copyright (C) 2014  Fulvio Benini

* This file is part of Scid (Shane's Chess Information Database).
*
* Scid is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation.
*
* Scid is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Scid.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef SCID_TIMER_H
#define SCID_TIMER_H

#include <chrono>
class Timer {
   decltype(std::chrono::system_clock::now()) start_;
public:
   Timer() { Reset(); }
   void Reset() { start_ = std::chrono::system_clock::now(); }
   long long MilliSecs (void) const {
		auto t = std::chrono::system_clock::now();
		return std::chrono::duration_cast<std::chrono::milliseconds>(t - start_).count();
   }
   long long CentiSecs () const { return MilliSecs() / 10; }
};

template <class S>
auto operator<<(S& os, const Timer& timer) -> decltype(os) {
   return os << timer.MilliSecs() << " milliseconds\n";
}

/* Usage:
Timer t;
//do some stuff
std::cout << "Elapsed: " << t;
*/


#endif //SCID_TIMER_H
