cmake_minimum_required(VERSION 3.9)

project(laplace_MPI)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Release)


## adding the following lines while cleaning the code
if (CMAKE_C_COMPILER_ID STREQUAL "GNU" )
    set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Wall -Wextra -Wno-unused-result -Wno-unused-parameter -ftree-vectorize -fopt-info-vec-optimized -ffast-math -mavx2 ")
    #set(CMAKE_EXE_LINKER_FLAGS "-lm" )
elseif ( CMAKE_C_COMPILER_ID STREQUAL "Intel" )
    set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Wall -qopt-report=3 -qopt-report-phase=vec -xCORE-AVX2")
elseif ( CMAKE_C_COMPILER_ID STREQUAL "PGI" )
    set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Minform=inform -Minfo=all -Mvect=simd -DPGI")
endif ( )
## end of adding the following lines while cleaning the code

find_package(MPI REQUIRED)
include_directories(${MPI_INCLUDE_PATH})

include_directories("src/include")
add_subdirectory(src)


add_executable(laplace_MPI ${laplace_MPI_Src})
target_link_libraries(laplace_MPI ${MPI_LIBRARIES} ${CMAKE_EXE_LINKER_FLAGS})


############### Debug messages ####################
MESSAGE( STATUS "CMAKE_BINARY_DIR: "            ${CMAKE_BINARY_DIR} )
MESSAGE( STATUS "CMAKE_C_COMPILER_ID: "         ${CMAKE_C_COMPILER_ID} )
MESSAGE( STATUS "CMAKE_C_FLAGS: "               ${CMAKE_C_FLAGS} )
MESSAGE( STATUS "CMAKE_CURRENT_SOURCE_DIR: "    ${CMAKE_CURRENT_SOURCE_DIR} )
########### end of Debug messages #################


