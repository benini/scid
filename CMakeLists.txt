# Copyright (C) 2016-2017  Fulvio Benini
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
project(scid)
set(CPACK_PACKAGE_VERSION 5.0.0)
set(
  CPACK_PACKAGE_DESCRIPTION_SUMMARY
  "chess database application with play and training functionality"
)
set(CPACK_DEBIAN_PACKAGE_DEPENDS "tk8.6 (>= 8.6.0)")
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
include(CPack)

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CXX_FLAGS)
  set(CMAKE_BUILD_TYPE "Release")
endif()

if(MSVC)
  add_definitions(/D_CRT_SECURE_NO_WARNINGS /D_SCL_SECURE_NO_WARNINGS)
  # To run/debug using Visual Studio set "scid" as startup project and add:
  # Command Arguments: ../tcl/start.tcl
  # Environment:       PATH=C:\tcl\bin
endif()

find_package(Threads)
find_package(TCL)

# polyglot
file(GLOB POLYGLOT_SRC src/polyglot/*.cpp)
add_library(polyglot ${POLYGLOT_SRC})

# scid
file(GLOB SCID_SRC src/*.h src/*.cpp)
if(MSVC)
  add_executable(scid WIN32 ${SCID_SRC} resources/win/scid.rc resources/win/scid.manifest)
  target_link_options(scid PRIVATE /ENTRY:mainCRTStartup)
else()
  add_executable(scid ${SCID_SRC})
endif()
set_property(TARGET scid PROPERTY INTERPROCEDURAL_OPTIMIZATION_RELEASE True)
target_include_directories(scid PRIVATE ${TCL_INCLUDE_PATH})
target_link_libraries(scid PRIVATE polyglot ${CMAKE_THREAD_LIBS_INIT} ${TCL_LIBRARY})

option(SPELLCHKVALIDATE "Verify the integrity of spelling files" OFF)
if(SPELLCHKVALIDATE)
  target_compile_definitions(scid PRIVATE -DSPELLCHKVALIDATE)
endif()

install(TARGETS scid DESTINATION scid)
file(GLOB ECO_FILES *.eco)
install(FILES ${ECO_FILES} DESTINATION scid)
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


option(GTEST "Build unit tests" OFF)
if(GTEST)
  add_subdirectory(gtest)
endif()
