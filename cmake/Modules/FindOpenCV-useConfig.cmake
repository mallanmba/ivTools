# this is a chopped-down version of the FindOpenCV.cmake script from 
# WillowGarage. Modifying that script became too convoluted, so 
# we keep things simple and throw out the old stuff

if(EXISTS "${OpenCVConfig_FILE}")
  include("${OpenCVConfig_FILE}")
  
  if(WIN32) 
    # sigh. OpenCV_INSTALL_PATH is invalid on windows,
    # so derive OpenCV_DIR from OpenCV_LIB_DIR
    # XXX This will fail if OpenCV_LIB_DIR has more than one entry
    string( REGEX REPLACE "/[^/]*$" "" OpenCV_DIR ${OpenCV_LIB_DIR} )
  else(WIN32) 
    set( OpenCV_DIR ${OpenCV_INSTALL_PATH} )
  endif(WIN32)

  ## Awesome. OpenCVConfig.cmake has changed yet again and
  ## no longer has the OpenCV_LIB_DIR variable (at least on 
  ## Ubuntu 14.04) So lets try and guess what it is, shall we?
  if( NOT OpenCV_LIB_DIR )
    if(CMAKE_VERSION VERSION_GREATER 2.8.4)
      include(GNUInstallDirs)
    else(CMAKE_VERSION VERSION_GREATER 2.8.4)
      # if we're using an ancient cmake, just fake it
      set(CMAKE_INSTALL_LIBDIR lib)
    endif(CMAKE_VERSION VERSION_GREATER 2.8.4)
    find_library( OPENCV_CORE_LIB opencv_core
                  HINTS ${OpenCV_INSTALL_PATH}/lib
                        ${OpenCV_INSTALL_PATH}/lib/x86_64-linux-gnu
                        ${OpenCV_INSTALL_PATH}/${CMAKE_INSTALL_LIBDIR}
                  NO_DEFAULT_PATH )
    string(REGEX REPLACE "/[^/]*$" "" OpenCV_LIB_DIR ${OPENCV_CORE_LIB})
    unset(OPENCV_CORE_LIB CACHE)
  endif( NOT OpenCV_LIB_DIR )
  
  ## print out the important variables to help debug if things go wrong
  message( STATUS "    OpenCV_INSTALL_PATH=${OpenCV_INSTALL_PATH}")
  message( STATUS "    OpenCV_LIB_DIR=${OpenCV_LIB_DIR}")

  ## Search for a specific version
  set(CVLIB_SUFFIX "${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}${OpenCV_VERSION_PATCH}")

  if(NOT OPENCV_LIB_COMPONENTS)
    set(OPENCV_LIB_COMPONENTS ${OpenCV_LIB_COMPONENTS})
  endif(NOT OPENCV_LIB_COMPONENTS)

else(EXISTS "${OpenCVConfig_FILE}")

  message( SEND_ERROR "  OpenCVConfig_FILE is '${OpenCVConfig_FILE}'. This script should only be called if OpenCVConfig_FILE exists." )
  
endif(EXISTS "${OpenCVConfig_FILE}")

set(OpenCV_LIBS "")
set(OpenCV_FOUND_TMP true)
## Loop over each component to determine full path
foreach(__CVLIB ${OPENCV_LIB_COMPONENTS})

  find_library(OpenCV_${__CVLIB}_LIBRARY_DEBUG
               NAMES "${__CVLIB}${CVLIB_SUFFIX}d" "lib${__CVLIB}${CVLIB_SUFFIX}d" "${__CVLIB}d"
               PATHS ${OpenCV_LIB_DIR}
               NO_DEFAULT_PATH)
  find_library(OpenCV_${__CVLIB}_LIBRARY_RELEASE
               NAMES "${__CVLIB}${CVLIB_SUFFIX}"  "lib${__CVLIB}${CVLIB_SUFFIX}"  "${__CVLIB}"
               PATHS ${OpenCV_LIB_DIR}
               NO_DEFAULT_PATH)

  # clear the cache value
  set(OpenCV_${__CVLIB}_LIBRARY "" CACHE STRING "" FORCE)

  if(OpenCV_${__CVLIB}_LIBRARY_DEBUG AND OpenCV_${__CVLIB}_LIBRARY_RELEASE)
    set(OpenCV_${__CVLIB}_LIBRARY debug ${OpenCV_${__CVLIB}_LIBRARY_DEBUG} optimized ${OpenCV_${__CVLIB}_LIBRARY_RELEASE}  CACHE STRING "" FORCE)
  elseif(OpenCV_${__CVLIB}_LIBRARY_DEBUG)
    set(OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_DEBUG}  CACHE STRING "" FORCE)
  elseif(OpenCV_${__CVLIB}_LIBRARY_RELEASE)
    set(OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_RELEASE}  CACHE STRING "" FORCE)
  else()
    message(STATUS "  OpenCV_${__CVLIB}_LIBRARY not found." )
    message(STATUS "    OpenCV_LIB_DIR=${OpenCV_LIB_DIR} " )
    message(STATUS "           __CVLIB=${__CVLIB} " )
    set(OpenCV_FOUND_TMP false)
  endif()

  #Add to the general list
  if(OpenCV_${__CVLIB}_LIBRARY)
    set(OpenCV_LIBS ${OpenCV_LIBS} ${OpenCV_${__CVLIB}_LIBRARY})
  endif(OpenCV_${__CVLIB}_LIBRARY)

endforeach(__CVLIB)

set( OpenCV_FOUND ${OpenCV_FOUND_TMP} CACHE BOOL "" FORCE )
set( OpenCV_LIBRARIES "${OpenCV_LIBS}" )

##====================================================
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
