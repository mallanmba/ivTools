include( CheckCommonIncludes )

## install the win32_workarounds.h file next
## to config.h. The source file will be searched for
## in CMAKE_MODULE_PATH/../include/win32_workarounds.h
## DEST_DIR is appended to 'src' for build tree and
## 'include' for install
#########################################
macro( setup_win32_workarounds DEST_DIR )

  # look for win32_workarounds.h
  set( WIN32_WORKAROUNDS_FILE "win32_workarounds.h" )
  set( WIN32_WORKAROUNDS_SOURCE "" )
  foreach( LOCAL_MODULE_PATH ${CMAKE_MODULE_PATH} )

    if( NOT WIN32_WORKAROUNDS_SOURCE )

      string(REGEX REPLACE "/[^/]*$" "" LOCAL_INCLUDE_PATH ${LOCAL_MODULE_PATH})
      set(LOCAL_INCLUDE_PATH ${LOCAL_INCLUDE_PATH}/include)
      set(WIN32_WORKAROUNDS_SOURCE ${LOCAL_INCLUDE_PATH}/${WIN32_WORKAROUNDS_FILE})

      if( EXISTS ${WIN32_WORKAROUNDS_SOURCE} )

        configure_file(
          "${WIN32_WORKAROUNDS_SOURCE}"
          "${PROJECT_BINARY_DIR}/src/${DEST_DIR}/${WIN32_WORKAROUNDS_FILE}"
        )
        install(FILES "${PROJECT_BINARY_DIR}/src/${DEST_DIR}/${WIN32_WORKAROUNDS_FILE}"
          DESTINATION include/${DEST_DIR}
        )
        message( STATUS "Using win32 workarounds..." )
        message( STATUS "  install ${WIN32_WORKAROUNDS_SOURCE} to ${PROJECT_BINARY_DIR}/src/${DEST_DIR}/${WIN32_WORKAROUNDS_FILE}" )
      endif( EXISTS ${WIN32_WORKAROUNDS_SOURCE} )

    endif( NOT WIN32_WORKAROUNDS_SOURCE )
  endforeach( LOCAL_MODULE_PATH)

endmacro( setup_win32_workarounds )

## install a "fake" stdint.h that just includes
## boost/cstdint.hpp for platforms that do not 
## comply with C99
#########################################
macro( setup_stdint_workaround DEST_DIR )
  # look for STDINT_WORKAROUND.h
  set( STDINT_WORKAROUND_FILE "stdint.h" )
  set( STDINT_WORKAROUND_SOURCE "" )
  foreach( LOCAL_MODULE_PATH ${CMAKE_MODULE_PATH} )
  
    if( NOT STDINT_WORKAROUND_SOURCE )

      string(REGEX REPLACE "/[^/]*$" "" LOCAL_INCLUDE_PATH ${LOCAL_MODULE_PATH})
      set(LOCAL_INCLUDE_PATH ${LOCAL_INCLUDE_PATH}/include)
      set(STDINT_WORKAROUND_SOURCE ${LOCAL_INCLUDE_PATH}/${STDINT_WORKAROUND_FILE})

      if( EXISTS ${STDINT_WORKAROUND_SOURCE} )
	# force boost inclusion if we don't have stdint
	if(NOT Boost_FOUND) 
	  find_package( Boost )
	endif(NOT Boost_FOUND)
	include_directories(
	  ${Boost_INCLUDE_DIR}
	)

        configure_file(
          "${STDINT_WORKAROUND_SOURCE}"
          "${PROJECT_BINARY_DIR}/src/${DEST_DIR}/${STDINT_WORKAROUND_FILE}"
        )
        install(FILES "${PROJECT_BINARY_DIR}/src/${DEST_DIR}/${STDINT_WORKAROUND_FILE}"
          DESTINATION include/${DEST_DIR}
        )
        message( STATUS "Using stdint.h workaround..." )
        message( STATUS "  install ${STDINT_WORKAROUND_SOURCE} to ${PROJECT_BINARY_DIR}/src/${DEST_DIR}/${STDINT_WORKAROUND_FILE}" )
      endif( EXISTS ${STDINT_WORKAROUND_SOURCE} )

    endif( NOT STDINT_WORKAROUND_SOURCE )
  endforeach( LOCAL_MODULE_PATH)
endmacro( setup_stdint_workaround )

## TODO: change filename to Project/config.h
##       rather than Project/Config.h
#########################################
macro( setup_configure_file )
  # check common system include files
  check_common_includes()

  set( DEST_DIR ${ARGN} ) # optional param

  set( CONFIGURE_NAME ${PROJECT_NAME}Config )
  set( CONFIGURE_FILENAME ${CONFIGURE_NAME}.h )

  # clean up configure file from previous build
  file( REMOVE ${CMAKE_INSTALL_PREFIX}/include/${DEST_DIR}/${CONFIGURE_FILENAME} )

  # put the configure file in the out of source tree
  set( CONFIG_IN_FILEPATH ${PROJECT_SOURCE_DIR}/cmake/config.h.in )
  if(NOT EXISTS ${CONFIG_IN_FILEPATH} ) # default config.h.in
    set( CONFIG_IN_FILEPATH ${PROJECT_SOURCE_DIR}/../cmake/config.h.in )
  endif( NOT EXISTS ${CONFIG_IN_FILEPATH} )

  configure_file(
    ${CONFIG_IN_FILEPATH}
    ${PROJECT_BINARY_DIR}/src/${DEST_DIR}/${CONFIGURE_FILENAME}
  )
  add_definitions(-DHAVE_${CONFIGURE_NAME}_H)
  install(FILES ${PROJECT_BINARY_DIR}/src/${DEST_DIR}/${CONFIGURE_FILENAME}
          DESTINATION include/${DEST_DIR} )

  if(WIN32)
    setup_win32_workarounds( "${DEST_DIR}" )
  endif(WIN32)
  
  if( NOT ${PROJECT_UPPER}_HAVE_STDINT_H )
    setup_stdint_workaround( "${DEST_DIR}" )
  endif( NOT ${PROJECT_UPPER}_HAVE_STDINT_H )
  
endmacro( setup_configure_file )

