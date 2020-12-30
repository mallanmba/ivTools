######################################################################
# Find script for dc1394
#
# Output Variables:
# -----------------
# DC1394_FOUND           : TRUE if search succeded
# DC1394_INCLUDE_DIR     : include path
# DC1394_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# DC1394_LIBRARY_DIR     : library path
# DC1394_dc1394_LIBRARY  : full path to libdc1394.so
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME           dc1394 )
set( PACKAGE_DIRS           libdc1394-2 )
set( PACKAGE_REQ_LIBRARY    dc1394 )
set( PACKAGE_REQ_INCLUDE    dc1394/capture.h )

simple_package_find("${PACKAGE_NAME}" 
                    "${PACKAGE_DIRS}" 
                    "${PACKAGE_REQ_LIBRARY}"
                    "${PACKAGE_REQ_INCLUDE}"
)

################################################
if( ${PACKAGE_FOUND} )
  set( LIBRARY_NAMES
    dc1394
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )

