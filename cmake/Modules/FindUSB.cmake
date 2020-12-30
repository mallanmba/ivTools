######################################################################
# Find script for usb
#
# Output Variables:
# -----------------
# USB_FOUND           : TRUE if search succeded
# USB_INCLUDE_DIR     : include path
# USB_LIBRARIES       : libraries in one variable (use this in your CMakeLists)
# USB_LIBRARY_DIR     : library path
# USB_usb_LIBRARY    : full path to usb
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME         usb )
set( PACKAGE_DIRS         usb )
set( PACKAGE_REQ_LIBRARY  usb )
set( PACKAGE_REQ_INCLUDE  usb.h )

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
    usb
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )


