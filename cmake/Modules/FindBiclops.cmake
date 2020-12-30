######################################################################
# Find script for biclops libraries
#
# Output Variables:
# -----------------
# BICLOPS_FOUND             : TRUE if search succeded
# BICLOPS_INCLUDE_DIR       : include path
# BICLOPS_LIBRARIES         : libraries in one variable (use this in your CMakeLists)
# BICLOPS_LIBRARY_DIR       : library path
# BICLOPS_Biclops_LIBRARY   : full path to library
# BICLOPS_PMD_LIBRARY       : full path to library
# BICLOPS_Utils_LIBRARY     : full path to library
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         Biclops )
set( PACKAGE_DIRS         biclops )
set( PACKAGE_REQ_LIBRARY  Biclops )
set( PACKAGE_REQ_INCLUDE  Biclops.h )

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
    Biclops
    PMD
    Utils
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )

