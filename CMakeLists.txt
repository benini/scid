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

cmake_minimum_required(VERSION 2.8)
project(scid)
set(CPACK_PACKAGE_VERSION 4.6.5)
set(
  CPACK_PACKAGE_DESCRIPTION_SUMMARY
  "chess database application with play and training functionality"
)
include(CPack)

if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CXX_FLAGS)
  set(CMAKE_BUILD_TYPE "Release")
endif()


# scid
file(GLOB SCID_SRC src/*.cpp)
file(GLOB POLYGLOT_SRC src/polyglot/*.cpp)
add_executable(scid ${SCID_SRC} ${POLYGLOT_SRC})
target_compile_options(scid PRIVATE -std=c++11)
target_compile_options(scid PRIVATE -Wall)

option(SCID_USE_TB "Enable Nalimov tablebases" OFF)
if(SCID_USE_TB)
  target_compile_definitions(scid PRIVATE -DSCID_USE_TB PRIVATE -DT41_INCLUDE)
endif()

option(SPELLCHKVALIDATE "Verify the integrity of spelling files" OFF)
if(SPELLCHKVALIDATE)
  target_compile_definitions(scid PRIVATE -DSPELLCHKVALIDATE)
endif()

find_package(TCL)
include_directories(${TCL_INCLUDE_PATH})
target_link_libraries(scid ${TCL_LIBRARY})

find_package(Threads REQUIRED)
target_link_libraries(scid ${CMAKE_THREAD_LIBS_INIT})

install(TARGETS scid DESTINATION scid)
install(PROGRAMS shell_scid DESTINATION bin RENAME scid)
install(DIRECTORY bitmaps DESTINATION scid)
install(DIRECTORY bitmaps2 DESTINATION scid)
install(DIRECTORY books DESTINATION scid)
install(DIRECTORY html DESTINATION scid)
install(DIRECTORY img DESTINATION scid)
install(DIRECTORY scripts DESTINATION scid)
install(DIRECTORY sounds DESTINATION scid)
install(DIRECTORY tcl DESTINATION scid)


# engine phalanx
file(GLOB PHALANX_SRC engines/phalanx-scid/*.c)
add_executable(phalanx-scid ${PHALANX_SRC})
set_target_properties(phalanx-scid PROPERTIES COMPILE_FLAGS "-w")
install(TARGETS phalanx-scid DESTINATION bin)


# engine scidlet
file(GLOB SCIDLET_SRC engines/scidlet/*.cpp)
set(SCIDLET_EXTRA
  src/engine.cpp
  src/recog.cpp
  src/misc.cpp
  src/position.cpp
)
add_executable(scidlet ${SCIDLET_SRC} ${SCIDLET_EXTRA})
install(TARGETS scidlet DESTINATION bin)
