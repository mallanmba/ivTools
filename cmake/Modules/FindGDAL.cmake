######################################################################
# Find script for GDAL
#
# Output Variables:
# -----------------
# GDAL_FOUND           : TRUE if search succeded
# GDAL_INCLUDE_DIR     : include path
# GDAL_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# GDAL_LIBRARY_DIR     : library path
# GDAL_gdal_LIBRARY    : full path to gdal
# GDAL_HAS_TIFF        : true if GDAL can read TIFF files
# GDAL_HAS_BIGTIFF     : true if 64 bit offsets are supported for TIFF files
# GDAL_USES_LIBTIFF    : true if GDAL was compiled external libTIFF library 
######################################################################

include( SimplePackageFind )

set( VCN vc8 )
if( MSVC90 )
  set( VCN vc9 )
endif( MSVC90 )

set( PACKAGE_NAME           "gdal" )
set( PACKAGE_DIRS           "gdal" )
set( PACKAGE_REQ_LIBRARY    "gdal;gdal_i-${VCN};gdal1.7.0" )
set( PACKAGE_REQ_INCLUDE    "gdal.h" )
set( PACKAGE_INCLUDE_SUFFIX "gdal" )

set( PACKAGE_ADD_SCOPED_INCLUDE TRUE )

simple_package_find("${PACKAGE_NAME}" 
                    "${PACKAGE_DIRS}" 
                    "${PACKAGE_REQ_LIBRARY}"
                    "${PACKAGE_REQ_INCLUDE}"
)
unset( PACKAGE_ADD_SCOPED_INCLUDE )

##
## find paths to package libraries
##
################################################
if( ${PACKAGE_FOUND} ) 

  set( LIBRARY_NAMES
    gdal
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
    
  # AAArghhh! Ubuntu has libgdal.so as libgdal1.7.0.so. WTF?
  # thankfully there's only one gdal library
  if(NOT GDAL_gdal_LIBRARY)
    find_library( GDAL_gdal_LIBRARY 
                  NAMES ${PACKAGE_REQ_LIBRARY} 
                  HINTS ${LIB_SEARCH_PATH})
    if(GDAL_gdal_LIBRARY)
      message(STATUS "  IGNORE the warning above. This platform renamed libgdal.so to ${GDAL_gdal_LIBRARY}")
    endif(GDAL_gdal_LIBRARY)
  endif(NOT GDAL_gdal_LIBRARY)

  if(WIN32) # win libs are inconveniently named
    find_library(GDAL_gdal_LIBRARY_DEBUG gdal_id-${VCN} ${GDAL_LIBRARY_DIR})
    set(GDAL_LIBRARIES optimized ${GDAL_gdal_LIBRARY} debug ${GDAL_gdal_LIBRARY_DEBUG})
  else(WIN32)
    set( GDAL_LIBRARIES ${GDAL_gdal_LIBRARY})
  endif(WIN32)
  
   ## Check for TIFF in GDAL
  include( CheckLibraryExists )
  check_library_exists( ${GDAL_gdal_LIBRARY} TIFFScanlineSize   "" GDAL_HAS_TIFFScanlineSize )
  check_library_exists( ${GDAL_gdal_LIBRARY} TIFFScanlineSize64 "" GDAL_HAS_TIFFScanlineSize64 )
  if( GDAL_HAS_TIFFScanlineSize )
    set( GDAL_HAS_TIFF TRUE )
    set( GDAL_HAS_BIGTIFF ${GDAL_HAS_TIFFScanlineSize64} ) 
    set( GDAL_USES_LIBTIFF TRUE )
  else( GDAL_HAS_TIFFScanlineSize )
    # XXX Can tiff be disabled completely in gdal
    # XXX or will gdal always support tiff, and it's a case of
    # XXX libtiff or internal implementation?
    set( GDAL_HAS_TIFF TRUE )
    set( GDAL_HAS_BIGTIFF TRUE ) # XXX internal tiff always supports 64 bit offsets?
    set( GDAL_USES_LIBTIFF FALSE )
  endif( GDAL_HAS_TIFFScanlineSize )
  #message( STATUS " GDAL_HAS_TIFF = ${GDAL_HAS_TIFF}" )
  #message( STATUS " GDAL_HAS_BIGTIFF = ${GDAL_HAS_BIGTIFF}" )
  #message( STATUS " GDAL_USES_LIBTIFF = ${GDAL_USES_LIBTIFF}" )
 
endif( ${PACKAGE_FOUND} )
