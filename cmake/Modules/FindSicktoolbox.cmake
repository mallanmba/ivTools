######################################################################
# Find script for Sicktoolbox libraries
#
# Output Variables:
# -----------------
# SICKTOOLBOX_FOUND               : TRUE if search succeded
# SICKTOOLBOX_INCLUDE_DIR         : include path
# SICKTOOLBOX_LIBRARIES           : libraries in one variable (use this in your CMakeLists)
# SICKTOOLBOX_LIBRARY_DIR         : library path
# SICKTOOLBOX_sicklms-1.0_LIBRARY : full path to sicklms-1.0
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         sicktoolbox )
set( PACKAGE_DIRS         sicktoolbox )
set( PACKAGE_REQ_LIBRARY  sicklms-1.0 )
set( PACKAGE_REQ_INCLUDE  sicklms-1.0/SickLMS.hh )

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
    sicklms-1.0
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )

