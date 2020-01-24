# Copyright (c) 2013 Nathan Osman
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Determines whether or not the compiler supports C++11

# Adapted from:
# https://github.com/nathan-osman/CXX11-CMake-Macros
#
# Pass:
#   msvc 14+
#   g++ 4.9.0+
#   clang 3.4+
#
# Earlier versions of these compilers might support C++11 but the purposes
# of osgEarth we are using these minimum requirements.

macro(check_for_cxx11_compiler _VAR)
    
    set(${_VAR})

    # Default: use C++11 if the compiler supports it, unless it is
    # GCC < 5 in which default to OFF.
    if (CMAKE_COMPILER_IS_GNUCXX AND ${CMAKE_CXX_COMPILER_VERSION} VERSION_LESS 5.0)
        option(BUILD_USE_CXX11 OFF)
        set(NO_CXX11_REASON "using GCC ${CMAKE_CXX_COMPILER_VERSION} so you must set BUILD_USE_CXX11=ON to force C++11")
    else()
        option(BUILD_USE_CXX11 ON)
    endif()

    if (BUILD_USE_CXX11)
        
        if(MSVC) 
    
            message(STATUS "MSVC checking for C++11; compiler version=${CMAKE_CXX_COMPILER_VERSION}/${MSVC_VERSION}")
        
            # Windows / MSVC++
            if (${MSVC_VERSION} GREATER_EQUAL 1900) # VS2015 (14.0)
                set(${_VAR} 1)
            else()
                set(NO_CXX11_REASON "using MSVC ${MSVC_VERSION} but 1900+ is required")
            endif()

        elseif(CMAKE_COMPILER_IS_GNUCXX)

            # GCC/Linux
            
            # test for C++ > C++98
            include(CheckCXXCompilerFlag)
            check_cxx_compiler_flag("-std=c++11" COMPILER_SUPPORTS_CXX11)
            
            if(COMPILER_SUPPORTS_CXX11)

                set(${_VAR} 1)
                set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
                
                # GCC 5+ lets you disable the C++11 ABI for compatibility with older compiler versions
                option(BUILD_ENABLE_GCC_CXX11_ABI "Use the new C++11 ABI, which is not backwards compatible." ON)
                if(NOT BUILD_ENABLE_GCC_CXX11_ABI)
                    add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)
                endif()
                
            else()
            
                check_cxx_compiler_flag("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
                if(COMPILER_SUPPORTS_CXX0X)
                    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
                endif()
                set(NO_CXX11_REASON "compiler does not support it")
                
            endif()
        
        elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")

            # Clang / Apple
            if (NOT ${CMAKE_CXX_COMPILER_VERSION} VERSION_LESS 3.4)
                set(${_VAR} 1)
            else()
                set(NO_CXX11_REASON "using clang ${CMAKE_CXX_COMPILER_VERSION} but 3.4+ is required")
            endif()
            
        endif()
        
    else()
        
        if (NOT ${NO_CXX_REASON})
            set(NO_CXX11_REASON "the BUILD_USE_CXX11 option was set to OFF")
        endif()
        
    endif()
    
    if (${_VAR})
        message(STATUS "Building with C++11 support")
        set(CMAKE_CXX_STANDARD 11)
    else()
        message(STATUS "Building without C++11 support because ${NO_CXX11_REASON}")
    endif()
    
endmacro()
