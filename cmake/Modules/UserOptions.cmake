## This file should be included after SetArchitecture
## so architecture variables are set in a conistent 
## manner. 
##
## if the UserOptions file doesn't exist, copy 
## a default one to the out-of-source root
## 
##################################################
set( USER_OPTIONS "${PROJECT_NAME}.UserOptions.cmake" )
set( USER_OPTIONS_PATH "${PROJECT_BINARY_DIR}/${USER_OPTIONS}" )
if( NOT EXISTS "${USER_OPTIONS_PATH}" )
  message( STATUS "\n"
                  "##################################################\n"
                  "## \n"
                  "## Copying default \"${USER_OPTIONS}\" \n"
                  "##   file to out-of-source root: \n" 
                  "## ${PROJECT_BINARY_DIR}\n" 
                  "## \n"
                  "##################################################")
                  
  string(TOLOWER ${CMAKE_SYSTEM_NAME} SYSTEM_NAME_LOWER )
  find_file(DEFAULT_USER_OPTIONS_FILE "${USER_OPTIONS}.${SYSTEM_NAME_LOWER}"
    "${PROJECT_SOURCE_DIR}/cmake"
    NO_DEFAULT_PATH
  )
  if( DEFAULT_USER_OPTIONS_FILE ) 
    exec_program("${CMAKE_COMMAND}" ARGS -E copy
      ${DEFAULT_USER_OPTIONS_FILE}
      ${USER_OPTIONS_PATH}
    )
  else( DEFAULT_USER_OPTIONS_FILE )
    file(WRITE ${USER_OPTIONS_PATH} "# ${PROJECT_NAME} CMake User Options \n\n" )
  endif( DEFAULT_USER_OPTIONS_FILE )
  
  mark_as_advanced( DEFAULT_USER_OPTIONS_FILE )
  
  message( STATUS "" )
  message( STATUS "NOTE: A default options file has been copied into the out-of-source root.")
  message( STATUS "      Make changes if necessary, ")
  message( STATUS "        delete CMakeCache.txt,")
  message( STATUS "          and rerun cmake.")
  message( STATUS "" )
endif( NOT EXISTS "${USER_OPTIONS_PATH}" )

include( ${USER_OPTIONS_PATH} )

