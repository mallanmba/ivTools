######################################################################
# Find script for OpenEXR
# 
# Output Variables:
# -----------------
# OPENEXR_FOUND           : TRUE if search succeded
# OPENEXR_INCLUDE_DIR     : include path
# OPENEXR_LIBRARIES       : libraries in one variable (use this in your CMakeLists)
# OPENEXR_LIBRARY_DIR     : library path
#
######################################################################
include( SimplePackageFind )

set( PACKAGE_NAME         OpenEXR )
set( PACKAGE_DIRS         OpenEXR )
set( PACKAGE_REQ_LIBRARY  IlmImf )
set( PACKAGE_REQ_INCLUDE  OpenEXR/OpenEXRConfig.h )
set( PACKAGE_ADD_SCOPED_INCLUDE TRUE )

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
    Half
    Iex
    IlmImf
    IlmThread
    Imath
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} ) 

