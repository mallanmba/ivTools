######################################################################
# Find script for RASM
#
# Output Variables:
# -----------------
# RASM_FOUND           : TRUE if search succeded
# RASM_INCLUDE_DIR     : include path
# RASM_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# RASM_LIBRARY_DIR     : library path
# RASM_common_LIBRARY  : full path to rasm common library
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         rasm )
set( PACKAGE_DIRS         rasm )
set( PACKAGE_REQ_LIBRARY  common )
set( PACKAGE_REQ_INCLUDE  rasm_common_types.h )

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
    common
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )

