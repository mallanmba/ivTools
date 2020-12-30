######################################################################
# Find script for raw1394
#
# Output Variables:
# -----------------
# RAW1394_FOUND           : TRUE if search succeded
# RAW1394_INCLUDE_DIR     : include path
# RAW1394_LIBRARIES       : libraries in one variable (use this in your CMakeLists)
# RAW1394_LIBRARY_DIR     : library path
# RAW1394_raw1394_LIBRARY : full path to raw1394
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         raw1394 )
set( PACKAGE_DIRS         libraw1394 )
set( PACKAGE_REQ_LIBRARY  raw1394 )
set( PACKAGE_REQ_INCLUDE  libraw1394/raw1394.h )

simple_package_find("${PACKAGE_NAME}" 
                    "${PACKAGE_DIRS}" 
                    "${PACKAGE_REQ_LIBRARY}"
                    "${PACKAGE_REQ_INCLUDE}"
)

##
## find paths to package libraries
##
################################################
if( ${PACKAGE_FOUND} )
  set( LIBRARY_NAMES
    raw1394
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )






