######################################################################
# Find script for EXIV2
#
# Output Variables:
# -----------------
# EXIV2_FOUND           : TRUE if search succeded
# EXIV2_INCLUDE_DIR     : include path
# EXIV2_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# EXIV2_LIBRARY_DIR     : library path
# EXIV2_exiv2_LIBRARY   : full path to library
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME           exiv2 )
set( PACKAGE_DIRS           exiv2 )
set( PACKAGE_REQ_LIBRARY    exiv2 )
set( PACKAGE_REQ_INCLUDE    exiv2/version.hpp )

simple_package_find("${PACKAGE_NAME}" 
                    "${PACKAGE_DIRS}" 
                    "${PACKAGE_REQ_LIBRARY}"
                    "${PACKAGE_REQ_INCLUDE}"
)

################################################
if( ${PACKAGE_FOUND} )
  set( LIBRARY_NAMES
    exiv2
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )

