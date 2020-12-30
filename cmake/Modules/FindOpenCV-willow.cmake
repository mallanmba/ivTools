###########################################################
#                  Find OpenCV Library
# See http://sourceforge.net/projects/opencvlibrary/
#----------------------------------------------------------
#
## 1: Setup:
# The following variables are optionally searched for defaults
#  OpenCV_DIR:            Base directory of OpenCv tree to use.
#
## 2: Variable
# The following are set after configuration is done:
#
#  OpenCV_FOUND
#  OpenCV_LIBS
#  OpenCV_INCLUDE_DIR
#  OpenCV_VERSION (OpenCV_VERSION_MAJOR, OpenCV_VERSION_MINOR, OpenCV_VERSION_PATCH)
#
#
# Deprecated variable are used to maintain backward compatibility with
# the script of Jan Woetzel (2006/09): www.mip.informatik.uni-kiel.de/~jw
#  OpenCV_INCLUDE_DIRS
#  OpenCV_LIBRARIES
#  OpenCV_LINK_DIRECTORIES
#
## 3: Version
#
# 2013/12/11 Mark Allan, add search for opencv2 include directory and warn about include path
# 2010/10/19 Mark Allan, remove conditional around 'backwards comatibility' because those variables are conventional
# 2010/09/15 Mark Allan, Improve find behavior for rpm installs of OpenCV
# 2010/04/07 Benoit Rat, Correct a bug when OpenCVConfig.cmake is not found.
# 2010/03/24 Benoit Rat, Add compatibility for when OpenCVConfig.cmake is not found.
# 2010/03/22 Benoit Rat, Creation of the script.
#
#
# tested with:
# - OpenCV 2.1:  MinGW, MSVC2008
# - OpenCV 2.0:  MinGW, MSVC2008, GCC4
#
#
## 4: Licence:
#
# LGPL 2.1 : GNU Lesser General Public License Usage
# Alternatively, this file may be used under the terms of the GNU Lesser

# General Public License version 2.1 as published by the Free Software
# Foundation and appearing in the file LICENSE.LGPL included in the
# packaging of this file.  Please review the following information to
# ensure the GNU Lesser General Public License version 2.1 requirements
# will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
#
#----------------------------------------------------------
cmake_minimum_required(VERSION 2.6.3) # 'unset' command was added in version 2.6.3

find_path(OpenCV_DIR "OpenCVConfig.cmake" DOC "Root directory of OpenCV")

#message(STATUS "  (dbg) OpenCVConfig_FILE = ${OpenCVConfig_FILE}")
# OpenCVConfig may not be in root dir, so look for
# in in a few other places
find_file(OpenCVConfig_FILE "OpenCVConfig.cmake"
          PATHS ${OpenCV_DIR}
                ${OpenCV_DIR}/share/opencv
                /usr/share/opencv
                /usr/local/share/opencv
                /opt/local/share/opencv
                /opt/local/lib/cmake
          DOC "Full path of OpenCVConfig.cmake"
          NO_DEFAULT_PATH)
#message(STATUS "  (dbg) OpenCVConfig_FILE = ${OpenCVConfig_FILE}")

# if OpenCV_DIR is not set but OpenCVConfig.cmake was found, try to
# find cv.h and use it to set OpenCV_DIR
if(NOT OpenCV_DIR AND EXISTS ${OpenCVConfig_FILE})
  # places to look for cv.h
  string( REGEX REPLACE "/[^/]*/[^/]*/[^/]*$" ""       TMP_OPENCV_ROOT_1  ${OpenCVConfig_FILE} )
  string( REGEX REPLACE "/[^/]*/[^/]*/[^/]*/[^/]*$" "" TMP_OPENCV_ROOT_2  ${OpenCVConfig_FILE} )
  string( REGEX REPLACE "/[^/]*$" ""                   TMP_OPENCV_ROOT_3  ${OpenCVConfig_FILE} )
  
  find_file(TMP_OPENCV_CV_H_FILE "cv.h"
            PATHS "${TMP_OPENCV_ROOT_1}" "${TMP_OPENCV_ROOT_2}" "${TMP_OPENCV_ROOT_3}"
            PATH_SUFFIXES "include/opencv" 
            DOC "tmp"
            NO_DEFAULT_PATH )
            
  # mallan: cv.h is a deprecated header. Look for new version...
  if( NOT EXISTS ${TMP_OPENCV_CV_H_FILE} )
    set( HAVE_OLD_OPENCV_HEADERS FALSE )
    find_file(TMP_OPENCV_CV_H_FILE "opencv.hpp"
              PATHS "${TMP_OPENCV_ROOT_1}" "${TMP_OPENCV_ROOT_2}" "${TMP_OPENCV_ROOT_3}"
              PATH_SUFFIXES "include/opencv2" 
              DOC "tmp"
              NO_DEFAULT_PATH )
  else( NOT EXISTS ${TMP_OPENCV_CV_H_FILE} )
    set( HAVE_OLD_OPENCV_HEADERS TRUE )
  endif( NOT EXISTS ${TMP_OPENCV_CV_H_FILE} )
  
  if( EXISTS ${TMP_OPENCV_CV_H_FILE} )
    # remove include/opencv/cv.h and set root dir
    string ( REGEX REPLACE "/[^/]*/[^/]*/[^/]*$" "" TMP_OPENCV_ROOT ${TMP_OPENCV_CV_H_FILE} )
    set( OpenCV_DIR ${TMP_OPENCV_ROOT} CACHE PATH "Root directory of OpenCV" FORCE )
  endif( EXISTS ${TMP_OPENCV_CV_H_FILE} )
  unset( TMP_OPENCV_CV_H_FILE CACHE )
  unset( TMP_OPENCV_ROOT_1 )
  unset( TMP_OPENCV_ROOT_2 )
endif(NOT OpenCV_DIR AND EXISTS ${OpenCVConfig_FILE})

##====================================================
## Find OpenCV libraries
##----------------------------------------------------
if(EXISTS "${OpenCV_DIR}")

        #When its possible to use the Config script use it.
        if(EXISTS "${OpenCVConfig_FILE}")

                ## Include the standard CMake script
                include("${OpenCVConfig_FILE}")
                ## Search for a specific version
                set(CVLIB_SUFFIX "${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}${OpenCV_VERSION_PATCH}")
                
                ## Changes to OpenCVConfig.cmake in 2.3 cause some headaches,
                ## so try to add some backwards compatibility
                #message(STATUS "    debug: OPENCV_LIB_COMPONENTS=${OPENCV_LIB_COMPONENTS}")
                #message(STATUS "    debug: OpenCV_LIB_COMPONENTS=${OpenCV_LIB_COMPONENTS}")
                if(NOT OPENCV_LIB_COMPONENTS)
                  set(OPENCV_LIB_COMPONENTS ${OpenCV_LIB_COMPONENTS})
                endif(NOT OPENCV_LIB_COMPONENTS)
                #message(STATUS "    debug: OPENCV_LIB_COMPONENTS=${OPENCV_LIB_COMPONENTS}")

        #Otherwise it try to guess it.
        else(EXISTS "${OpenCVConfig_FILE}")
                
                ## FIXME this probably no longer works for 2.3+
                find_path(OpenCV_INCLUDE_DIR "cv.h" PATHS "${OpenCV_DIR}" PATH_SUFFIXES "include" "include/opencv" DOC "")
                if(EXISTS  ${OpenCV_INCLUDE_DIR})
                    include_directories(${OpenCV_INCLUDE_DIR})
                endif(EXISTS  ${OpenCV_INCLUDE_DIR})

                ## FIXME this probably no longer works for 2.3+
                ## Find OpenCV version by looking at cvver.h
                file(STRINGS ${OpenCV_INCLUDE_DIR}/cvver.h OpenCV_VERSIONS_TMP REGEX "^#define CV_[A-Z]+_VERSION[ \t]+[0-9]+$")
                string(REGEX REPLACE ".*#define CV_MAJOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_MAJOR ${OpenCV_VERSIONS_TMP})
                string(REGEX REPLACE ".*#define CV_MINOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_MINOR ${OpenCV_VERSIONS_TMP})
                string(REGEX REPLACE ".*#define CV_SUBMINOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_PATCH ${OpenCV_VERSIONS_TMP})
                set(OpenCV_VERSION ${OpenCV_VERSION_MAJOR}.${OpenCV_VERSION_MINOR}.${OpenCV_VERSION_PATCH} CACHE STRING "" FORCE)
                set(CVLIB_SUFFIX "${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}${OpenCV_VERSION_PATCH}")
                
                if( "${OpenCV_VERSION}" VERSION_GREATER "2.2.99" ) 
                    set(OPENCV_LIB_COMPONENTS 
                          opencv_core
                          opencv_imgproc
                          opencv_highgui
                          opencv_ml
                          opencv_features2d
                          opencv_video
                          opencv_objdetect
                          opencv_calib3d
                          opencv_flann
                          opencv_contrib
                          opencv_legacy
                          opencv_gpu )
                else( "${OpenCV_VERSION}" VERSION_GREATER "2.2.9" ) 
                    # old library names
                    set(OPENCV_LIB_COMPONENTS 
                          cxcore 
                          cv 
                          ml 
                          highgui 
                          cvaux )
                endif( "${OpenCV_VERSION}" VERSION_GREATER "2.2.9" ) 
                
        endif(EXISTS "${OpenCVConfig_FILE}")


        ## Initiate the variable before the loop
        set(OpenCV_LIBS "")
        set(OpenCV_FOUND_TMP true)

        ## Loop over each component to determine full path
        foreach(__CVLIB ${OPENCV_LIB_COMPONENTS})

                find_library(OpenCV_${__CVLIB}_LIBRARY_DEBUG
                             NAMES "${__CVLIB}${CVLIB_SUFFIX}d" "lib${__CVLIB}${CVLIB_SUFFIX}d" "${__CVLIB}d"
                             PATHS "${OpenCV_DIR}/lib"
                             NO_DEFAULT_PATH)
                find_library(OpenCV_${__CVLIB}_LIBRARY_RELEASE
                             NAMES "${__CVLIB}${CVLIB_SUFFIX}"  "lib${__CVLIB}${CVLIB_SUFFIX}"  "${__CVLIB}"
                             PATHS "${OpenCV_DIR}/lib"
                             NO_DEFAULT_PATH)

                #Remove the cache value
                set(OpenCV_${__CVLIB}_LIBRARY "" CACHE STRING "" FORCE)

                #both debug/release
                if(OpenCV_${__CVLIB}_LIBRARY_DEBUG AND OpenCV_${__CVLIB}_LIBRARY_RELEASE)
                        set(OpenCV_${__CVLIB}_LIBRARY debug ${OpenCV_${__CVLIB}_LIBRARY_DEBUG} optimized ${OpenCV_${__CVLIB}_LIBRARY_RELEASE}  CACHE STRING "" FORCE)
                #only debug
                elseif(OpenCV_${__CVLIB}_LIBRARY_DEBUG)
                        set(OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_DEBUG}  CACHE STRING "" FORCE)
                #only release
                elseif(OpenCV_${__CVLIB}_LIBRARY_RELEASE)
                        set(OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_RELEASE}  CACHE STRING "" FORCE)
                #no library found
                else()
                        set(OpenCV_FOUND_TMP false)
                endif()

                #Add to the general list
                if(OpenCV_${__CVLIB}_LIBRARY)
                        set(OpenCV_LIBS ${OpenCV_LIBS} ${OpenCV_${__CVLIB}_LIBRARY})
                endif(OpenCV_${__CVLIB}_LIBRARY)

        endforeach(__CVLIB)


        set(OpenCV_FOUND ${OpenCV_FOUND_TMP} CACHE BOOL "" FORCE)


else(EXISTS "${OpenCV_DIR}")
        set(ERR_MSG "Please specify OpenCV directory using OpenCV_DIR env. variable")
endif(EXISTS "${OpenCV_DIR}")
##====================================================


##====================================================
## Print message
##----------------------------------------------------
if(NOT OpenCV_FOUND)
  # make FIND_PACKAGE friendly
  if(NOT OpenCV_FIND_QUIETLY)
        if(OpenCV_FIND_REQUIRED)
          message(FATAL_ERROR "OpenCV required but some headers or libs not found. ${ERR_MSG}")
        else(OpenCV_FIND_REQUIRED)
          message(STATUS "WARNING: OpenCV was not found. ${ERR_MSG}")
        endif(OpenCV_FIND_REQUIRED)
  endif(NOT OpenCV_FIND_QUIETLY)
endif(NOT OpenCV_FOUND)
##====================================================


##====================================================
## Backward compatibility
##----------------------------------------------------
#if(OpenCV_FOUND)
#option(OpenCV_BACKWARD_COMPA "Add some variable to make this script compatible with the other version of FindOpenCV.cmake" false)
#if(OpenCV_BACKWARD_COMPA)

        #find_path(OpenCV_INCLUDE_DIRS "cv.h" PATHS "${OpenCV_DIR}" PATH_SUFFIXES "include" "include/opencv" DOC "Include directory")
        if( HAVE_OLD_OPENCV_HEADERS )
          find_path(OpenCV_INCLUDE_DIR "opencv/cv.h" HINTS "${OpenCV_DIR}" PATH_SUFFIXES "include" "include/opencv" DOC "Include directory")
        else( HAVE_OLD_OPENCV_HEADERS )
          find_path(OpenCV_INCLUDE_DIR "opencv2/opencv.hpp" HINTS "${OpenCV_DIR}" PATH_SUFFIXES "include" DOC "Include directory")
        endif( HAVE_OLD_OPENCV_HEADERS )
        set(OpenCV_LIBRARIES "${OpenCV_LIBS}" CACHE STRING "" FORCE)

#endif(OpenCV_BACKWARD_COMPA)
#endif(OpenCV_FOUND)
##====================================================
if(OpenCV_FOUND)
  if(HAVE_OLD_OPENCV_HEADERS) 
    message(STATUS "  NOTE: The old OpenCV headers exist (i.e. include/opencv/cv.h) but these are deprecated")
    message(STATUS "         and should not be used. Use include/opencv2/opencv.hpp")
  else(HAVE_OLD_OPENCV_HEADERS) 
    message(STATUS "  NOTE: OpenCV was found, but the old-style headers (i.e. include/opencv/cv.h) do not exist")
    message(STATUS "        That is fine, as long as all code has already been updated to use the new headers.")
  endif(HAVE_OLD_OPENCV_HEADERS) 
endif(OpenCV_FOUND)
