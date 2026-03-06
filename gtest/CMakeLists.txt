# Copyright (C) 2016-2026  Fulvio Benini
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

cmake_minimum_required(VERSION 3.15)
set(CMAKE_CXX_STANDARD 20 CACHE STRING "")

enable_testing()
include(CTest)

# googletest
include(FetchContent)
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG        v1.17.0
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# scid_sources
set(SCID_BASE
  ${CMAKE_CURRENT_SOURCE_DIR}/../src/codec_scid4.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/../src/scidbase.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/../src/sortcache.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/../src/stored.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/../src/game.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/../src/position.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/../src/textbuf.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/../src/misc.cpp
)
add_library(scid_base ${SCID_BASE})
target_include_directories(scid_base PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../src)
find_package(Threads REQUIRED)
target_link_libraries(scid_base PUBLIC Threads::Threads)

# scid_tests
file(GLOB GTEST_SRC *.cpp)
add_executable(scid_tests ${GTEST_SRC})
target_compile_definitions(scid_tests PRIVATE -DSCID_TESTDIR=\"${CMAKE_CURRENT_LIST_DIR}/\")
target_link_libraries(scid_tests PRIVATE scid_base gtest_main)
set_target_properties(scid_tests PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

# Google Test Discovery
include(GoogleTest)
gtest_discover_tests(scid_tests)
