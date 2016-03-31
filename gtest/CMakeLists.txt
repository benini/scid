cmake_minimum_required(VERSION 2.6)

find_package(GTest REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -O3")
include_directories(${GTEST_INCLUDE_DIRS} ../src)
file(GLOB TESTS *.cpp)
set(SCID_OBJ
	../src/misc.o
	../src/index.o ../src/namebase.o ../src/sortcache.o
)

add_executable(runAll ${TESTS} ${SCID_OBJ})
target_link_libraries(runAll ${GTEST_LIBRARIES} ${GTEST_MAIN_LIBRARIES} pthread)

