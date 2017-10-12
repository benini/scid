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

cmake_minimum_required(VERSION 3.1)
project(scid_gtest)

find_package(Threads REQUIRED)
set(CMAKE_CXX_STANDARD 14 CACHE STRING "")

set(CMAKE_CXX_EXTENSIONS OFF)
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CXX_FLAGS)
  set(CMAKE_BUILD_TYPE "Debug")
  set(CMAKE_CXX_FLAGS "-O3 -Wall")
endif()
if(MSVC)
  add_definitions(/D_CRT_SECURE_NO_WARNINGS /D_SCL_SECURE_NO_WARNINGS)
endif()

# googletest
if(NOT IS_DIRECTORY "${CMAKE_BINARY_DIR}/googletest")
  find_package(Git)
  execute_process(COMMAND ${GIT_EXECUTABLE} clone https://github.com/google/googletest.git)
endif()
set(gtest_force_shared_crt ON CACHE BOOL "Always use msvcrt.dll")
add_subdirectory(${CMAKE_BINARY_DIR}/googletest ${CMAKE_BINARY_DIR}/googletest/Build)
include_directories("${gtest_SOURCE_DIR}/include" "${gmock_SOURCE_DIR}/include")

# scid_tests
include_directories(../src)
file(GLOB GTEST_SRC *.cpp)
set(GTEST_EXTRA
  ../src/index.cpp
  ../src/namebase.cpp
  ../src/scidbase.cpp
  ../src/sortcache.cpp
  ../src/pgnparse.cpp ../src/misc.cpp
  ../src/game.cpp ../src/position.cpp ../src/bytebuf.cpp ../src/textbuf.cpp ../src/stored.cpp
)
add_executable(scid_tests ${GTEST_SRC} ${GTEST_EXTRA})
add_executable(coverage EXCLUDE_FROM_ALL ${GTEST_SRC} ${GTEST_EXTRA})
set_property(TARGET scid_tests coverage APPEND PROPERTY COMPILE_DEFINITIONS
    SCID_TESTDIR=\"${CMAKE_CURRENT_LIST_DIR}/\")
target_link_libraries(coverage gtest_main ${CMAKE_THREAD_LIBS_INIT})
target_link_libraries(scid_tests gtest_main ${CMAKE_THREAD_LIBS_INIT})

# coverage
target_compile_options(coverage PRIVATE -coverage)
set_property(TARGET coverage APPEND PROPERTY LINK_FLAGS -coverage)
add_custom_command(TARGET coverage POST_BUILD
	COMMAND ./coverage
	COMMAND lcov ARGS -c -b "${CMAKE_CURRENT_LIST_DIR}/../src" -d CMakeFiles -no-external -o test_coverage.info
	COMMAND genhtml ARGS test_coverage.info -o gcov)
