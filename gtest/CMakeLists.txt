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

find_package(Threads REQUIRED)

find_package(Git)
execute_process(COMMAND ${GIT_EXECUTABLE} clone https://github.com/google/googletest.git)

set(gtest_force_shared_crt ON CACHE BOOL "Always use msvcrt.dll")
add_subdirectory(${CMAKE_BINARY_DIR}/googletest ${CMAKE_BINARY_DIR}/googletest/Build)
include_directories("${gtest_SOURCE_DIR}/include" "${gmock_SOURCE_DIR}/include")


include_directories(../src)
file(GLOB GTEST_SRC *.cpp)
set(GTEST_EXTRA
  ../src/index.cpp
  ../src/namebase.cpp
  ../src/gfile.cpp
  ../src/scidbase.cpp
  ../src/sortcache.cpp
  ../src/pgnparse.cpp ../src/misc.cpp ../src/mfile.cpp
  ../src/game.cpp ../src/position.cpp ../src/bytebuf.cpp ../src/textbuf.cpp ../src/stored.cpp
)

add_executable(unit-testing ${GTEST_SRC} ${GTEST_EXTRA})
set_target_properties(unit-testing PROPERTIES OUTPUT_NAME "runAll")
set_target_properties(unit-testing PROPERTIES COMPILE_FLAGS "-Wall -std=c++14")
target_link_libraries(unit-testing gtest_main ${CMAKE_THREAD_LIBS_INIT})

add_executable(coverage EXCLUDE_FROM_ALL ${GTEST_SRC} ${GTEST_EXTRA})
set_target_properties(coverage PROPERTIES OUTPUT_NAME "runAll")
set_target_properties(coverage PROPERTIES COMPILE_FLAGS "-Wall -std=c++14 -coverage")
set_target_properties(coverage PROPERTIES LINK_FLAGS "-coverage")
target_link_libraries(coverage gtest_main ${CMAKE_THREAD_LIBS_INIT})
add_custom_command(TARGET coverage POST_BUILD
	COMMAND ./runAll
	COMMAND lcov ARGS -c -d . -o test_coverage.info
	COMMAND genhtml ARGS test_coverage.info -o gcov)

