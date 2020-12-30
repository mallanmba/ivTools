# This script will attempt to find the appropriate
# header and lib locations for JPEG, PNG, TIFF, and
# ZLIB under the OpenSceneGraph 3rdParty directory for
# VisionWorkbench. 
# http://www.openscenegraph.org/projects/osg/wiki/Downloads/Dependencies
# https://osgtoy.svn.sourceforge.net/svnroot/osgtoy/3rdParty/branches/   
#
# It is only intended to be used on Windows, where
# obtaining and building these external libs is 
# a hassle. 
#
#####################################################

if(WIN32) 

message( STATUS "Looking for packages in OpenSceneGraph 3rdParty (${OSG3RDPARTY_ROOT_DIR})" )
if( OSG3RDPARTY_ROOT_DIR )

  ## JPEG
  ############################
  if( NOT JPEG_FOUND ) 
    find_path( JPEG_INCLUDE_DIR      jpeglib.h ${OSG3RDPARTY_ROOT_DIR}/include )
    find_library( JPEG_LIBRARY       libjpeg   ${OSG3RDPARTY_ROOT_DIR}/lib )
    find_library( JPEG_LIBRARY_DEBUG libjpegD  ${OSG3RDPARTY_ROOT_DIR}/lib )
    if( JPEG_INCLUDE_DIR AND JPEG_LIBRARY ) 
      set( JPEG_FOUND TRUE )
      set( JPEG_LIBRARIES optimized ${JPEG_LIBRARY} debug ${JPEG_LIBRARY_DEBUG})
      message( STATUS "  Found JPEG in OpenSceneGraph 3rdParty." )
      mark_as_advanced( 
        JPEG_LIBRARY
        JPEG_LIBRARY_DEBUG
      )
    endif(JPEG_INCLUDE_DIR AND JPEG_LIBRARY ) 
  endif( NOT JPEG_FOUND )
    
  ## ZLIB (for PNG) 
  ############################
  if( NOT ZLIB_FOUND ) 
    find_path( ZLIB_INCLUDE_DIR      zlib.h  ${OSG3RDPARTY_ROOT_DIR}/include )
    find_library( ZLIB_LIBRARY       zlib1   ${OSG3RDPARTY_ROOT_DIR}/lib )
    find_library( ZLIB_LIBRARY_DEBUG zlib1D  ${OSG3RDPARTY_ROOT_DIR}/lib )
    if( ZLIB_INCLUDE_DIR AND ZLIB_LIBRARY ) 
      set( ZLIB_FOUND TRUE )
      set( ZLIB_LIBRARIES optimized ${ZLIB_LIBRARY} debug ${ZLIB_LIBRARY_DEBUG})
      message( STATUS "  Found ZLIB in OpenSceneGraph 3rdParty." )
      mark_as_advanced( 
        ZLIB_LIBRARY
        ZLIB_LIBRARY_DEBUG
      )
    endif(ZLIB_INCLUDE_DIR AND ZLIB_LIBRARY ) 
  endif( NOT ZLIB_FOUND )

  ## PNG
  ############################
  if( NOT PNG_FOUND ) 
    find_path( PNG_INCLUDE_DIR      png.h     ${OSG3RDPARTY_ROOT_DIR}/include )
    find_library( PNG_LIBRARY       libpng13  ${OSG3RDPARTY_ROOT_DIR}/lib )
    find_library( PNG_LIBRARY_DEBUG libpng13D ${OSG3RDPARTY_ROOT_DIR}/lib )
    if( PNG_INCLUDE_DIR AND PNG_LIBRARY ) 
      set( PNG_FOUND TRUE )
      set( PNG_LIBRARIES optimized ${PNG_LIBRARY} debug ${PNG_LIBRARY_DEBUG} ${ZLIB_LIBRARIES} )
      message( STATUS "  Found PNG in OpenSceneGraph 3rdParty." )
      mark_as_advanced( 
        PNG_LIBRARY
        PNG_LIBRARY_DEBUG
      )
    endif(PNG_INCLUDE_DIR AND PNG_LIBRARY ) 
  endif( NOT PNG_FOUND )
    
  ## TIFF
  ############################
  if( NOT TIFF_FOUND ) 
    find_path( TIFF_INCLUDE_DIR      tiff.h  ${OSG3RDPARTY_ROOT_DIR}/include )
    find_library( TIFF_LIBRARY       libtiff ${OSG3RDPARTY_ROOT_DIR}/lib )
    find_library( TIFF_LIBRARY_DEBUG libtiff ${OSG3RDPARTY_ROOT_DIR}/lib )
    if( TIFF_INCLUDE_DIR AND TIFF_LIBRARY ) 
      set( TIFF_FOUND TRUE )
      set( TIFF_LIBRARIES optimized ${TIFF_LIBRARY} debug ${TIFF_LIBRARY_DEBUG})
      message( STATUS "  Found TIFF in OpenSceneGraph 3rdParty." )
      mark_as_advanced( 
        TIFF_LIBRARY
        TIFF_LIBRARY_DEBUG
      )
    endif(TIFF_INCLUDE_DIR AND TIFF_LIBRARY ) 
  endif( NOT TIFF_FOUND )

  # not really necessary, but... 
  if( JPEG_FOUND AND ZLIB_FOUND AND PNG_FOUND AND TIFF_FOUND )
    set( OpenSceneGraph3rdParty_FOUND TRUE )
  endif( JPEG_FOUND AND ZLIB_FOUND AND PNG_FOUND AND TIFF_FOUND )

else( OSG3RDPARTY_ROOT_DIR )

  message( STATUS "  OSG3RDPARTY_ROOT_DIR is not set" )
  
endif( OSG3RDPARTY_ROOT_DIR )

endif(WIN32)
