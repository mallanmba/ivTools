######################################################################
# Find script for PROJ4
#
# Output Variables:
# -----------------
# PROJ4_FOUND           : TRUE if search succeded
# PROJ4_INCLUDE_DIR     : include path
# PROJ4_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# PROJ4_LIBRARY_DIR     : library path
# PROJ4_BASE_LIBRARY    : full path to proj
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         proj4 )
set( PACKAGE_DIRS         proj4 )
set( PACKAGE_REQ_LIBRARY  proj )
set( PACKAGE_REQ_INCLUDE  proj_api.h )

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
    proj
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
  
  set( PROJ4_VERSION_HEADER ${PROJ4_INCLUDE_DIR}/proj_api.h )
  if( EXISTS ${PROJ4_VERSION_HEADER} )
    file(STRINGS ${PROJ4_VERSION_HEADER} PROJ4_TEMP REGEX "^#define PJ_VERSION[ \t]+[0-9]+$")
    string(REGEX REPLACE ".*#define PJ_VERSION[ \t]+([0-9]).*" "\\1"           PROJ4_VERSION_MAJOR ${PROJ4_TEMP})
    string(REGEX REPLACE ".*#define PJ_VERSION[ \t]+[0-9]([0-9]).*" "\\1"      PROJ4_VERSION_MINOR ${PROJ4_TEMP})
    string(REGEX REPLACE ".*#define PJ_VERSION[ \t]+[0-9][0-9]([0-9]).*" "\\1" PROJ4_VERSION_PATCH ${PROJ4_TEMP})
    set(PROJ4_VERSION ${PROJ4_VERSION_MAJOR}.${PROJ4_VERSION_MINOR}.${PROJ4_VERSION_PATCH})
    message(STATUS "  Found Proj4 version ${PROJ4_VERSION} in ${PROJ4_ROOT_DIR}")

  else( EXISTS ${PROJ4_VERSION_HEADER} )
    message(STATUS "  WARNING: Could not find Proj4 version header ${PROJ4_VERSION_HEADER}")
  endif( EXISTS ${PROJ4_VERSION_HEADER} )
  

endif( ${PACKAGE_FOUND} )



