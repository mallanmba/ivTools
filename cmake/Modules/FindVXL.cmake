######################################################################
# Find script for VXL
#
# NOTE: Doesn't attempt to find/verify all the VXL libs, 
#       just the ones we need right now
#
# Output Variables:
# -----------------
# VXL_FOUND              : TRUE if search succeded
# VXL_INCLUDE_DIR        : all of the vxl include paths
# VXL_CORE_INCLUDE_DIR   :
# VXL_VCL_INCLUDE_DIR    :
# VXL_NETLIB_INCLUDE_DIR :
# VXL_LIBRARY_DIR        : library path
# VXL_vcl_LIBRARY        : full path to vcl
# VXL_vnl_LIBRARY        : full path to vnl
# VXL_vnl_algo_LIBRARY   : full path to vnl_algo
# VXL_v3p_netlib_LIBRARY : full path to v3p_netlib
# VXL_netlib_LIBRARY     : full path to netlib
# VXL_LIBRARIES          : all of the above libs
#
######################################################################
include( GetPackageLibSearchPath )

get_package_lib_search_path( VXL vxl VXL_ROOT_DIR VXL_ROOT )

message(STATUS "Looking for VXL")

# Find the vxl library
#-----------------------------------------
find_library( VXL_vnl_LIBRARY vnl
  ${LIB_SEARCH_PATH}
  "VXL vnl library"
)

# Set the root to 2 directories above library.
#-----------------------------------------
string(REGEX REPLACE "/[^/]*/[^/]*$" "" VXL_ROOT_DIR ${VXL_vnl_LIBRARY})

if( VXL_ROOT_DIR )
  
  set( VXL_LIBRARY_DIR  ${VXL_ROOT_DIR}/lib )

  # VXL seems to have a wacky convention for include path CMake variable naming
  # we do our best to maintain some kind of consistency w/ other find scripts
  set( VXL_INCLUDE_DIR_ROOT    ${VXL_ROOT_DIR}/include CACHE STRING "VXL root include path" )
  set( VXLCORE_INCLUDE_DIR     ${VXL_INCLUDE_DIR_ROOT}/vxl/core       )
  set( VXLVCL_INCLUDE_DIR      ${VXL_INCLUDE_DIR_ROOT}/vxl/vcl        )
  set( VXLNETLIB_INCLUDE_DIR   ${VXL_INCLUDE_DIR_ROOT}/vxl/v3p/netlib )
  
  find_library( VXL_vcl_LIBRARY        vcl        ${VXL_LIBRARY_DIR} )
  find_library( VXL_vnl_algo_LIBRARY   vnl_algo   ${VXL_LIBRARY_DIR} )
  find_library( VXL_v3p_netlib_LIBRARY v3p_netlib ${VXL_LIBRARY_DIR} )
  find_library( VXL_netlib_LIBRARY     netlib     ${VXL_LIBRARY_DIR} )
  mark_as_advanced( 
    VXL_vcl_LIBRARY
    VXL_vnl_LIBRARY
    VXL_vnl_algo_LIBRARY
    VXL_v3p_netlib_LIBRARY
    VXL_netlib_LIBRARY
  )
  
  set( VXL_LIBRARIES 
    ${VXL_vcl_LIBRARY}
    ${VXL_vnl_LIBRARY}
    ${VXL_vnl_algo_LIBRARY}
    ${VXL_v3p_netlib_LIBRARY}
    ${VXL_netlib_LIBRARY}
  )
  set( VXL_INCLUDE_DIR
    ${VXL_INCLUDE_DIR_ROOT}
    ${VXLCORE_INCLUDE_DIR}
    ${VXLVCL_INCLUDE_DIR}
    ${VXLNETLIB_INCLUDE_DIR}
  )
  
  message(STATUS "  VXL found in ${VXL_ROOT_DIR}")
  set( VXL_FOUND TRUE )
  
else (VXL_ROOT_DIR)

  message(STATUS ${LIB_SEARCH_ERROR_MESSAGE})
 
endif (VXL_ROOT_DIR)

