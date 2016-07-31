cmake_minimum_required(VERSION 2.6)

find_package(GTest REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -O3")
include_directories(${GTEST_INCLUDE_DIRS} ../src)
file(GLOB TESTS *.cpp)
set(SCID_OBJ
	../src/misc.o
	../src/index.o ../src/namebase.o ../src/sortcache.o
	../src/gfile.o ../src/bytebuf.o ../src/mfile.o
	../src/game.o ../src/position.o ../src/textbuf.o ../src/dstring.o ../src/matsig.o ../src/date.o
	../src/stored.o
	../src/pgnparse.o
	../src/scidbase.o
)

add_executable(runAll ${TESTS} ${SCID_OBJ})
target_link_libraries(runAll ${GTEST_LIBRARIES} ${GTEST_MAIN_LIBRARIES} pthread)

find_package(ZLIB)
if (ZLIB_FOUND)
	target_link_libraries( runAll ${ZLIB_LIBRARIES} )
endif(ZLIB_FOUND)
