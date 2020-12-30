######################################################################
# Find script for SGE
#
# Output Variables:
# -----------------
# SGE_FOUND           : TRUE if search succeded
# SGE_INCLUDE_DIR     : include path
# SGE_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# SGE_LIBRARY_DIR     : library path
# SGE_SGE_LIBRARY     : full path to SGE
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         sge )
set( PACKAGE_DIRS         sge )
set( PACKAGE_REQ_LIBRARY  SGE )
set( PACKAGE_REQ_INCLUDE  sge.h )

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
    SGE
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )

