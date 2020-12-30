######################################################################
# Master find script for OpenCV. 
# 
# Delegates to one of two other FindOpenCV scripts based
# on whether OpenCVConfig.cmake is found.
#
# ** NOTE **  the FindOpenCV script from Willow Garage uses
# Boost capitalization convention  (MyProject_VARIABLE) 
# instead of CMake caps convention (MYPROJECT_VARIABLE)
# for cmake variables. *We adopt their convention for compatibility*
#
# Output Variables:
# -----------------
#  OpenCV_FOUND         : TRUE if search succeded
#  OpenCV_INCLUDE_DIR   : include path
#  OpenCV_LIBRARIES     : libraries in one variable (use this in your CMakeLists)
#  OpenCV_VERSION       : software version in the form "X.Y.Z"
#  OpenCV_VERSION_MAJOR : X
#  OpenCV_VERSION_MINOR : Y
#  OpenCV_VERSION_PATCH : Z
#
######################################################################
include( SetIrgPaths )

message(STATUS "Looking for OpenCV...")

find_file(OpenCVConfig_FILE "OpenCVConfig.cmake" 
  HINTS ${OPENCV_ROOT_DIR}
        $ENV{OPENCV_ROOT}
        ${IRG_PACKAGES_DIR}/opencv
  PATH_SUFFIXES
        share/OpenCV
        share/opencv
        share
  DOC "Location of OpenCVConfig.cmake"
)

if( EXISTS ${OpenCVConfig_FILE} )

  message( STATUS "  Found ${OpenCVConfig_FILE}" )
  #message( STATUS "  Using FindOpenCV-willow.cmake" )
  #find_package( OpenCV-willow )
  message( STATUS "  Using FindOpenCV-useConfig.cmake" )
  find_package( OpenCV-useConfig )
  
else( EXISTS ${OpenCVConfig_FILE} )
  
  message( STATUS "  Could not find OpenCVConfig.cmake" )  
  message( STATUS "  Using FindOpenCV-irg.cmake" )  
  find_package( OpenCV-irg )

endif( EXISTS ${OpenCVConfig_FILE})

if( OpenCV_FOUND )
  message( STATUS "  Found OpenCV version ${OpenCV_VERSION} in ${OpenCV_DIR}" )
  if(CMAKE_COMPILER_IS_GNUCXX)
      message(STATUS "gcc version is ${GCC_MINORVERSION}")
    if (GCC_MINORVERSION VERSION_LESS "4.3" )
      message(STATUS "*** OpenCV adding -Wno-non-virtual-dtor to CMAKE_CXX_FLAGS")
      set( CMAKE_CXX_FLAGS "-Wno-non-virtual-dtor" )
    endif (GCC_MINORVERSION VERSION_LESS "4.3")
  endif(CMAKE_COMPILER_IS_GNUCXX)
  #message( STATUS "        OpenCV_LIBRARIES=${OpenCV_LIBRARIES}")
  #message( STATUS "        OpenCV_INCLUDE_DIR=${OpenCV_INCLUDE_DIR}")
endif( OpenCV_FOUND )
