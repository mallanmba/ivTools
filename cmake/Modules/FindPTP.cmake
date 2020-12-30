message(STATUS "Looking for PTP")

find_library( PTP_LIBRARY ptp2
  /usr/local/irg/packages/i686_linux_gcc4.1/libptp2/lib
)

string(REGEX REPLACE "/[^/]*/[^/]*$" "" PTP_ROOT ${PTP_LIBRARY})

if ( PTP_ROOT )

  set( PTP_INCLUDE_DIR ${PTP_ROOT}/include/libptp2 CACHE PATH "ptp include path")
  
  message(STATUS "  ptp found in ${PTP_ROOT}")

  set( PTP_FOUND TRUE )

else( PTP_ROOT )

  message(STATUS "  ptp NOT found!!!")
  
endif( PTP_ROOT )
