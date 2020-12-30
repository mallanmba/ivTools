# FindLAPACK delegates to either 
#   FindLAPACK-win32.cmake on Windows or
#   FindLAPACK-eigen.cmake elsewhere

if( WIN32 )
  find_package( LAPACK-win32 )
else( WIN32 )
  find_package( LAPACK-eigen )
endif( WIN32 )
