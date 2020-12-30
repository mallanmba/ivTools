######################################################################
# Find script for tinyxml
#
# Output Variables:
# -----------------
# TINYXML_FOUND           : TRUE if search succeded
# TINYXML_INCLUDE_DIR     : include path
# TINYXML_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# TINYXML_LIBRARY_DIR     : library path
# TINYXML_tinyxml_LIBRARY : full path to tinyxml
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         tinyxml )
set( PACKAGE_DIRS         tinyxml )
set( PACKAGE_REQ_LIBRARY  tinyxml )
set( PACKAGE_REQ_INCLUDE  tinyxml.h )

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
    tinyxml
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )

