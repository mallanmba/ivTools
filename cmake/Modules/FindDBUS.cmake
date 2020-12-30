######################################################################
# Find script for DBUS
#
# Output Variables:
# -----------------
# DBUS_FOUND           : TRUE if search succeded
# DBUS_INCLUDE_DIR     : include path
# DBUS_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# DBUS_LIBRARY_DIR     : library path
# DBUS_BASE_LIBRARY    : full path to library
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         dbus )
set( PACKAGE_DIRS         dbus )
set( PACKAGE_REQ_LIBRARY  dbus-1 )
set( PACKAGE_REQ_INCLUDE  "" )

simple_package_find("${PACKAGE_NAME}" 
                   "${PACKAGE_DIRS}" 
                   "${PACKAGE_REQ_LIBRARY}"
                   "${PACKAGE_REQ_INCLUDE}"
)

################################################
if( ${PACKAGE_FOUND} )
  set( LIBRARY_NAMES
    dbus-1
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )

