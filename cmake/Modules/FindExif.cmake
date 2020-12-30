######################################################################
# Find script for Exif
# 
# Output Variables:
# -----------------
#  EXIF_FOUND         : TRUE if search succeded
#  EXIF_INCLUDE_DIR   : include path
#  EXIF_LIBRARIES     : all libraries in one variable  (use this in your CMakeLists)
#  EXIF_LIBRARY_DIR   : library path
#  EXIF_exif_LIBRARY  : full path to library
#
######################################################################
include( SimplePackageFind )

set( PACKAGE_NAME           exif )
set( PACKAGE_DIRS           libexif;libexif-0.6.19 )
set( PACKAGE_REQ_LIBRARY    exif )
set( PACKAGE_REQ_INCLUDE    libexif/exif-format.h )

simple_package_find("${PACKAGE_NAME}" 
                   "${PACKAGE_DIRS}" 
                   "${PACKAGE_REQ_LIBRARY}"
                   "${PACKAGE_REQ_INCLUDE}"
)

if( ${PACKAGE_FOUND} )
  set( LIBRARY_NAMES
    exif
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )

