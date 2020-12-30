# look for ctest executable
# enable testing if found
#--------------------------------------------------
macro( setup_ctest )

  find_program( CTEST_EXECUTABLE ctest )

  if( CTEST_EXECUTABLE )
    set(CTEST_ENABLED TRUE)
    enable_testing()
  endif( CTEST_EXECUTABLE )
  
  set( TESTS_PATH    ${CMAKE_INSTALL_PREFIX}/tests )
  set( CTEST_BIN_DIR ${CMAKE_INSTALL_PREFIX}/tests )

endmacro( setup_ctest )
