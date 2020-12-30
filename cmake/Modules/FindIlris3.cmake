######################################################################
# Find script for Ilris3
#
# Output Variables:
# -----------------
# ILRIS3_FOUND                 : TRUE if search succeded
# ILRIS3_INCLUDE_DIR           : include path
# ILRIS3_LIBRARIES             : libraries in one variable (use this in your CMakeLists)
# ILRIS3_LIBRARY_DIR           : library path
# ILRIS3_LIDARAPI_LIBRARY      : full path to lidarapi
# ILRIS3_AUXPLATFORM_LIBRARY   : full path to auxplatform
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         Ilris3 )
set( PACKAGE_DIRS         ilris3dAPI )
set( PACKAGE_REQ_LIBRARY  lidarapi )
set( PACKAGE_REQ_INCLUDE  Ilris3dAPI.h )

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
    lidarapi
    auxplatform
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )
