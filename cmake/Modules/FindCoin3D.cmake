######################################################################
# Find script for Coin3D
#
# Output Variables:
# -----------------
# COIN3D_FOUND           : TRUE if search succeded
# COIN3D_INCLUDE_DIR     : include path
# COIN3D_LIBRARIES       : libraries in one variable (use this in your CMakeLists)
# COIN3D_LIBRARY_DIR     : library path
# COIN3D_Coin_LIBRARY  
# COIN3D_simage_LIBRARY 
# COIN3D_dime_LIBRARY  
#
# COIN3D_SoQt_LIBRARY    : will NOT be in COIN3D_LIBRARIES, even if found
# COIN3D_SoXt_LIBRARY    : will NOT be in COIN3D_LIBRARIES, even if found   
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME           Coin3D )
set( PACKAGE_DIRS           coin3d )
set( PACKAGE_REQ_LIBRARY    Coin )
set( PACKAGE_REQ_INCLUDE    Inventor/So.h )

if(WIN32)
  set( PACKAGE_REQ_LIBRARY coin3 )
endif(WIN32)

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
  
  if(WIN32)
    # XXX ugly hack because Coin3D lib names are different on Win32
    get_pkg_library (COIN3D ${COIN3D_LIBRARY_DIR} "d" Coin TRUE coin3 ) 
    get_pkg_library (COIN3D ${COIN3D_LIBRARY_DIR} "d" SoQt TRUE soqt1 ) 
    add_definitions( -DCOIN_DLL -DSOQT_DLL )
  else(WIN32)
    get_pkg_library (COIN3D ${COIN3D_LIBRARY_DIR} "d" SoQt FALSE ) 
    get_pkg_library (COIN3D ${COIN3D_LIBRARY_DIR} "d" SoXt FALSE ) 
  endif(WIN32)

  set( LIBRARY_NAMES
    Coin
    simage
    dime
  )
  get_library_list(COIN3D ${COIN3D_LIBRARY_DIR} "d" "${LIBRARY_NAMES}")
    
endif( ${PACKAGE_FOUND} ) 

