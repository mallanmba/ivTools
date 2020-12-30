# Quick hack find script for win32 pthreads
#
#
######################################################################
if( WIN32 )
message( STATUS "Looking for win32 pthreads")

include(GetLibraryList)

set( PTHREADS_FOUND FALSE )

if( NOT PTHREADS_ROOT_DIR )
  if( DEFINED ENV{PTHREADS_ROOT} )
    set( PTHREADS_ROOT_DIR $ENV{PTHREADS_ROOT} )
    message( STATUS "  PTHREADS_ROOT environment variable is set to $ENV{PTHREADS_ROOT}")
  else( DEFINED ENV{PTHREADS_ROOT} )
    message( STATUS "  ! Neither the PTHREADS_ROOT environment variable nor the " )
    message( STATUS "  ! PTHREADS_ROOT_DIR CMake variable is set. " )
    message( STATUS "  ! Will not be able to find the win32 pthreads libraries." )
  endif( DEFINED ENV{PTHREADS_ROOT} )
endif( NOT PTHREADS_ROOT_DIR )

#---------------------------------------------------------------
set( PTHREADS_INCLUDE_DIR ${PTHREADS_ROOT_DIR}/include )
set( PTHREADS_LIBRARY_DIR ${PTHREADS_ROOT_DIR}/lib )

# FIXME need to support aliases for different exception/cleanup build options
set( LIBRARY_NAMES
  pthreadVC2
  )
get_library_list(PTHREADS ${PTHREADS_LIBRARY_DIR} "d" "${LIBRARY_NAMES}")

unset( CMAKE_HAVE_PTHREAD_H CACHE )
find_file( CMAKE_HAVE_PTHREAD_H "pthread.h" PATHS ${PTHREADS_INCLUDE_DIR} NO_DEFAULT_PATH )

if( CMAKE_HAVE_PTHREAD_H )
  message(STATUS "  Found win32 pthreads in ${PTHREADS_ROOT_DIR}")
else( CMAKE_HAVE_PTHREAD_H )
  message(STATUS "  win32 pthreads root NOT found!!!")
endif( CMAKE_HAVE_PTHREAD_H )

endif( WIN32 )