######################################################################
# Find script for CSPICE
#
# Output Variables:
# -----------------
# CSPICE_FOUND            : TRUE if search succeded
# CSPICE_INCLUDE_DIR      : include path
# CSPICE_LIBRARIES        : all libraries in one variable (use this in your CMakeLists)
# CSPICE_LIBRARY_DIR      : library path
# CSPICE_cspice_LIBRARY   : full path to cspice
# CSPICE_csupport_LIBRARY : full path to csupport
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         cspice )
set( PACKAGE_DIRS         cspice )
set( PACKAGE_REQ_LIBRARY  cspice )
set( PACKAGE_REQ_INCLUDE  SpiceUsr.h )

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

  add_definitions( -DCURL_FOUND )
  set( LIBRARY_NAMES 
    cspice
    csupport
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}}  "d" "${LIBRARY_NAMES}")

endif( ${PACKAGE_FOUND} )
