# see:
# http://www.cmake.org/Wiki/CMake_RPATH_handling
#
# Note that this should be called *after* CMAKE_INSTALL_PREFIX
# has been set!
#
# http://www.cmake.org/Wiki/CMake_RPATH_handling

macro( setup_rpath  )

if( NOT CMAKE_INSTALL_PREFIX )
  message( SEND_ERROR "setup_rpath: CMAKE_INSTALL_PREFIX is not valid. Please call this macro after CMAKE_INSTALL_PREFIX is set." )
endif( NOT CMAKE_INSTALL_PREFIX )

set( CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib" CACHE STRING "the RPATH to be used when installing" FORCE)

if(APPLE)
  set( CMAKE_INSTALL_NAME_DIR ${CMAKE_INSTALL_PREFIX}/lib CACHE STRING "" FORCE)
endif(APPLE)

set( CMAKE_SKIP_RPATH                   FALSE CACHE BOOL "if FALSE, use RPATH" )
set( CMAKE_SKIP_BUILD_RPATH             FALSE CACHE BOOL "if FALSE, build with RPATH so shared libs can be resolved in build tree" )
set( CMAKE_BUILD_WITH_INSTALL_RPATH     FALSE CACHE BOOL "when building, don't use CMAKE_INSTALL_RPATH (only use it when installing)" )
set( CMAKE_INSTALL_RPATH_USE_LINK_PATH  TRUE  CACHE BOOL "add the automatically determined parts of the RPATH which point to directories outside the build tree to CMAKE_INSTALL_RPATH" )

mark_as_advanced( 
  CMAKE_SKIP_RPATH 
  CMAKE_SKIP_BUILD_RPATH 
  CMAKE_BUILD_WITH_INSTALL_RPATH 
  CMAKE_INSTALL_RPATH_USE_LINK_PATH 
)

endmacro( setup_rpath  )

