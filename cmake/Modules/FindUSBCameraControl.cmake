######################################################################
# Find script for USB Camera Control
#
# Output Variables:
# -----------------
# USB_CAMERA_CONTROL_FOUND           : TRUE if search succeded
# USB_CAMERA_CONTROL_INCLUDE_DIR     : include path
# USB_CAMERA_CONTROL_LIBRARY_DIR     : library path
#
######################################################################

# Set parent directory as a search location
string(REGEX REPLACE "/[^/]*$" "" PROJ_SRC_PARENT ${PROJECT_SOURCE_DIR})

include( SetArchitecture )

message(STATUS "Looking for USB Camera Control")

if( NOT USB_CAMERA_CONTROL_ROOT_DIR ) 
  # try and find usb camera control root
  #-------------------------------------------------
  find_library( USB_CAMERA_CONTROL_BASE_LIBRARY sw_usb_camera_control
    ${PROJ_SRC_PARENT}/${ARCHITECTURE}/lib
    ${PROJ_SRC_PARENT}/hw//src/usb_camera_control/lib
    $ENV{USB_CAMERA_CONTROL_ROOT}/lib
    ${LOCAL_RELEASES}/roversw/${ARCHITECTURE}/lib
    DOC "USB camera control base library"
  )
  string(REGEX REPLACE "/[^/]*/[^/]*$" "" USB_CAMERA_CONTROL_ROOT_DIR ${USB_CAMERA_CONTROL_BASE_LIBRARY})
endif( NOT USB_CAMERA_CONTROL_ROOT_DIR ) 


if( USB_CAMERA_CONTROL_ROOT_DIR )
  
  set( USB_CAMERA_CONTROL_INCLUDE_DIR ${USB_CAMERA_CONTROL_ROOT_DIR}/include/sw/usb_camera_control CACHE PATH "USB include directory" )
  set( USB_CAMERA_CONTROL_LIBRARY_DIR ${USB_CAMERA_CONTROL_ROOT_DIR}/lib     CACHE PATH "USB library directory" )
  
  message(STATUS "  Found USB Camera Control in ${USB_CAMERA_CONTROL_ROOT_DIR}")
  set( USB_CAMERA_CONTROL_FOUND TRUE )
  
else( USB_CAMERA_CONTROL_ROOT_DIR )

  message(STATUS "  USB camera control NOT found!!!")
  
endif( USB_CAMERA_CONTROL_ROOT_DIR )

