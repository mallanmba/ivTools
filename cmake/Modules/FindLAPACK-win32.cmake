######################################################################
# Find script for CLAPACK on Windows
# http://www.netlib.org/clapack/
######################################################################
message( STATUS "Looking for LAPACK")

include(GetLibraryList)

set( LAPACK_FOUND FALSE )

if( NOT LAPACK_ROOT_DIR )
  if( DEFINED ENV{LAPACK_ROOT} )
    set( LAPACK_ROOT_DIR $ENV{LAPACK_ROOT} )
    message( STATUS "  LAPACK_ROOT environment variable is set to $ENV{LAPACK_ROOT}")
  else( DEFINED ENV{LAPACK_ROOT} )
    message( STATUS "  ! Neither the LAPACK_ROOT environment variable nor the " )
    message( STATUS "  ! LAPACK_ROOT_DIR CMake variable is set. " )
    message( STATUS "  ! Will not be able to find CLAPACK libraries." )
  endif( DEFINED ENV{LAPACK_ROOT} )
endif( NOT LAPACK_ROOT_DIR )

#---------------------------------------------------------------
# search for cmake-built libraries
#---------------------------------------------------------------
set( LAPACK_INCLUDE_DIR ${LAPACK_ROOT_DIR}/include )
set( LAPACK_LIBRARY_DIR ${LAPACK_ROOT_DIR}/lib )
set( LIBRARY_NAMES 
  blas
  lapack
  libf2c
  )
get_library_list(LAPACK ${LAPACK_LIBRARY_DIR} "d" "${LIBRARY_NAMES}")
  
if( LAPACK_blas_LIBRARY AND LAPACK_lapack_LIBRARY )
  set( LAPACK_FOUND TRUE )
endif( LAPACK_blas_LIBRARY AND LAPACK_lapack_LIBRARY )

if( LAPACK_FOUND )
  message(STATUS "  Found LAPACK in ${LAPACK_ROOT_DIR}")
else( LAPACK_FOUND )
  message(STATUS "  LAPACK root NOT found!!!")
endif( LAPACK_FOUND )

