# Copyright (C) 2016 Fulvio Benini
# This file is part of Scid (Shane's Chess Information Database).
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# Scid is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Scid. If not, see <http://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 2.6)
project(scid_gtest)

file(GLOB GTEST_SRC *.cpp)
set(GTEST_EXTRA
  ../src/misc.cpp
  ../src/index.cpp ../src/namebase.cpp ../src/sortcache.cpp
  ../src/gfile.cpp ../src/bytebuf.cpp ../src/mfile.cpp
  ../src/game.cpp ../src/position.cpp ../src/textbuf.cpp ../src/dstring.cpp ../src/matsig.cpp ../src/date.cpp
  ../src/stored.cpp
  ../src/pgnparse.cpp
  ../src/scidbase.cpp
)
include_directories(../src)
add_executable(runAll ${GTEST_SRC} ${GTEST_EXTRA})
set_target_properties(runAll PROPERTIES COMPILE_FLAGS "-Wall -std=c++14 -O3")
set_target_properties(runAll PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}")

find_package(GTest REQUIRED)
include_directories(${GTEST_INCLUDE_DIRS})
target_link_libraries(runAll ${GTEST_LIBRARIES} ${GTEST_MAIN_LIBRARIES})

find_package(Threads REQUIRED)
target_link_libraries(runAll ${CMAKE_THREAD_LIBS_INIT})
