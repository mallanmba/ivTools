include(GetPackageLibSearchPath)

# This is a reasonably generic macro for packages
# located in standard irg places. If the <package>_ROOT_DIR
# is set before calling this scipt, we search for the base library 
# in that path and that path only (i.e. <package>_ROOT_DIR/lib ).
# If <package>_ROOT_DIR is not set, we will search for it
# in the paths definied by the GetPackageLibSearchPath macro. 
#
# If PACKAGE_ADD_SCOPED_INCLUDE is set to true, the include path will 
# consist of the root include as well as the scoped include - i.e.
# if the required include is foo/foo.h and the package is found
# in /usr, the FOO_INCLUDE_DIR be /usr/include AND /usr/include/foo
# If PACKAGE_ADD_SCOPED_INCLUDE is false (the default), the include 
# path will be only the root include (i.e. /usr/include) and include 
# directives in client code will be expected to scope the file (i.e.
# #include <foo/foo_version.h>
#-----------------------------------------------------------
include( GetLibraryList )

macro( simple_package_find PACKAGE_NAME PACKAGE_DIRS PACKAGE_REQ_LIBRARY )

message(STATUS "Looking for ${PACKAGE_NAME}...")

#
# set up some variables
#--------------------------------------------------
string( TOUPPER "${PACKAGE_NAME}"  PACKAGE_UPPER )

set(PACKAGE_FOUND        "${PACKAGE_UPPER}_FOUND"       )
set(PACKAGE_ROOT_DIR     "${PACKAGE_UPPER}_ROOT_DIR"    )
set(PACKAGE_ENV_VAR      "${PACKAGE_UPPER}_ROOT"        )
set(PACKAGE_BASE_LIBRARY "${PACKAGE_UPPER}_BASE_LIBRARY")
set(PACKAGE_INCLUDE_DIR  "${PACKAGE_UPPER}_INCLUDE_DIR" )
set(PACKAGE_LIBRARY_DIR  "${PACKAGE_UPPER}_LIBRARY_DIR" )
set(PACKAGE_LIBRARIES    "${PACKAGE_UPPER}_LIBRARIES"   )

get_package_lib_search_path( "${PACKAGE_NAME}" "${PACKAGE_DIRS}" "${PACKAGE_ROOT_DIR}" "${PACKAGE_ENV_VAR}" )
#message(STATUS "  (dbg) PACKAGE_BASE_LIBRARY=${PACKAGE_BASE_LIBRARY}")
#message(STATUS "  (dbg) LIB_SEARCH_PATH=${LIB_SEARCH_PATH}")


# Find the base library
#-----------------------------------------
find_library( ${PACKAGE_BASE_LIBRARY} 
  NAMES ${PACKAGE_REQ_LIBRARY}
  HINTS ${LIB_SEARCH_PATH}
  DOC "${PACKAGE_NAME} library"
)


if( ${PACKAGE_BASE_LIBRARY} )

  #message(STATUS "  (dbg) ${PACKAGE_BASE_LIBRARY} = ${${PACKAGE_BASE_LIBRARY}}")
  
  # remove lib name and lib dir to get root
  #-----------------------------------------------
  string(REGEX REPLACE "/[^/]*$" "" ${PACKAGE_LIBRARY_DIR} ${${PACKAGE_BASE_LIBRARY}} )
  
  #message(STATUS "  (dbg) ${PACKAGE_LIBRARY_DIR} = ${${PACKAGE_LIBRARY_DIR}}" )

  string(REGEX REPLACE "/[^/]*/[^/]*$" "" _${PACKAGE_ROOT_DIR} ${${PACKAGE_BASE_LIBRARY}} )
  
  if( _${PACKAGE_ROOT_DIR} ) # only resolve if non-empty
    get_filename_component(${PACKAGE_ROOT_DIR} "${_${PACKAGE_ROOT_DIR}}" REALPATH)
  else ( _${PACKAGE_ROOT_DIR} )
    set( ${PACKAGE_ROOT_DIR} "/" )
  endif( _${PACKAGE_ROOT_DIR} )
  
  #message( STATUS "  (dbg) ${PACKAGE_ROOT_DIR}=${${PACKAGE_ROOT_DIR}}" )
  if( NOT EXISTS "${${PACKAGE_ROOT_DIR}}/include/" )
    # if PACKAGE_LIBRARY_DIR/../include is not a directory, then it's likely 
    # the lib is in a multiarch dir. Pop up one more directory.
    string(REGEX REPLACE "/[^/]*$" "" _TEMP ${${PACKAGE_ROOT_DIR}} )
    set(${PACKAGE_ROOT_DIR} ${_TEMP})
    #message( STATUS "  (dbg) ${PACKAGE_ROOT_DIR}=${${PACKAGE_ROOT_DIR}}" )
  endif( NOT EXISTS "${${PACKAGE_ROOT_DIR}}/include/" )
  
  set( ROOT_INCLUDE_DIR "${${PACKAGE_ROOT_DIR}}/include" )  
  if( PACKAGE_REQ_INCLUDE )
    find_file( TEMP_INCLUDE_FILE 
      NAMES ${PACKAGE_REQ_INCLUDE}
      HINTS ${ROOT_INCLUDE_DIR}
      PATH_SUFFIXES "" ${PACKAGE_INCLUDE_SUFFIX}
      NO_DEFAULT_PATH
    )
    
    if ( TEMP_INCLUDE_FILE ) 
      #if( NOT ${TEMP_INCLUDE_FILE} MATCHES "^${ROOT_INCLUDE_DIR}.*" )
      #  message(STATUS "  (dbg) header path does not match guessed include root")
      #  string( REPLACE "/${PACKAGE_REQ_INCLUDE}" "" TEMP_INCLUDE_DIR ${TEMP_INCLUDE_FILE} )
      #  set( ROOT_INCLUDE_DIR "${TEMP_INCLUDE_DIR}")
      #endif()
          
      set( ${PACKAGE_FOUND} TRUE )
      message(STATUS "  ${PACKAGE_NAME} found in ${${PACKAGE_ROOT_DIR}}")
      string(REGEX REPLACE "/[^/]*$" "" FOUND_INCLUDE_DIR ${TEMP_INCLUDE_FILE} )
            
      #message(STATUS "  (dbg) PACKAGE_ADD_SCOPED_INCLUDE = ${PACKAGE_ADD_SCOPED_INCLUDE}")
      # FIXME: revisit this logic
      foreach(ONE_PACKAGE_REQ_INCLUDE ${PACKAGE_REQ_INCLUDE})
        string(REGEX REPLACE "/[^/]*$" "" REQ_INCLUDE_PATH ${ONE_PACKAGE_REQ_INCLUDE} )
        
        #message(STATUS "  (dbg) ONE_PACKAGE_REQ_INCLUDE = ${ONE_PACKAGE_REQ_INCLUDE}")
        #message(STATUS "  (dbg) REQ_INCLUDE_PATH = ${REQ_INCLUDE_PATH}")

        # if PACKAGE_REQ_INCLUDE included a relative path, strip it off FOUND_INCLUDE_DIR
        if( NOT PACKAGE_ADD_SCOPED_INCLUDE AND NOT ${ONE_PACKAGE_REQ_INCLUDE} STREQUAL REQ_INCLUDE_PATH )
          string(REGEX REPLACE "/${REQ_INCLUDE_PATH}$" "" BARE_INCLUDE_DIR ${FOUND_INCLUDE_DIR} )
          set(FOUND_INCLUDE_DIR ${BARE_INCLUDE_DIR})
          unset(BARE_INCLUDE_DIR)
        endif( NOT PACKAGE_ADD_SCOPED_INCLUDE AND NOT ${ONE_PACKAGE_REQ_INCLUDE} STREQUAL REQ_INCLUDE_PATH )
        #message(STATUS "  (dbg) FOUND_INCLUDE_DIR = ${FOUND_INCLUDE_DIR}")
      endforeach(ONE_PACKAGE_REQ_INCLUDE)
      
      # if PACKAGE_INCLUDE_SUFFIX was provided, strip it off FOUND_INCLUDE_DIR
      if( NOT PACKAGE_ADD_SCOPED_INCLUDE AND PACKAGE_INCLUDE_SUFFIX )
        string(REGEX REPLACE "/${PACKAGE_INCLUDE_SUFFIX}$" "" BARE_INCLUDE_DIR ${FOUND_INCLUDE_DIR} )
        set(FOUND_INCLUDE_DIR ${BARE_INCLUDE_DIR})
      endif( NOT PACKAGE_ADD_SCOPED_INCLUDE AND PACKAGE_INCLUDE_SUFFIX )
      
      if( FOUND_INCLUDE_DIR STREQUAL ROOT_INCLUDE_DIR )
        set( ${PACKAGE_INCLUDE_DIR} "${ROOT_INCLUDE_DIR}" CACHE PATH "${PACKAGE_NAME} include path")
      else (FOUND_INCLUDE_DIR STREQUAL ROOT_INCLUDE_DIR )
        set( ${PACKAGE_INCLUDE_DIR} "${ROOT_INCLUDE_DIR};${FOUND_INCLUDE_DIR}" CACHE PATH "${PACKAGE_NAME} include path")
      endif(FOUND_INCLUDE_DIR STREQUAL ROOT_INCLUDE_DIR )
      
      #message(STATUS "  (dbg) ${PACKAGE_INCLUDE_DIR} = ${${PACKAGE_INCLUDE_DIR}}")
      
    else ( TEMP_INCLUDE_FILE ) 
    
      set( ${PACKAGE_FOUND} FALSE )
      message( STATUS "  Could not find required header file: ${PACKAGE_REQ_INCLUDE}")
      set( ${PACKAGE_INCLUDE_DIR} "NOT_FOUND" CACHE PATH "${PACKAGE_NAME} include path")
      
    endif( TEMP_INCLUDE_FILE ) 
    
    unset( TEMP_INCLUDE_FILE CACHE )
    
  else( PACKAGE_REQ_INCLUDE )
  
    set( ${PACKAGE_FOUND} TRUE )
    message(STATUS "  ${PACKAGE_NAME} found in ${${PACKAGE_ROOT_DIR}}")
    set( ${PACKAGE_INCLUDE_DIR} "${ROOT_INCLUDE_DIR}" CACHE PATH "${PACKAGE_NAME} include path")
    
  endif( PACKAGE_REQ_INCLUDE )
  
else( ${PACKAGE_BASE_LIBRARY} )

  set( ${PACKAGE_FOUND} FALSE )
  message(STATUS ${LIB_SEARCH_ERROR_MESSAGE})
  
endif( ${PACKAGE_BASE_LIBRARY} )

unset( ${PACKAGE_BASE_LIBRARY} CACHE )

#message(STATUS "  (dbg) ${PACKAGE_INCLUDE_DIR} = ${${PACKAGE_INCLUDE_DIR}}")
#message(STATUS "  (dbg) ${PACKAGE_LIBRARY_DIR} = ${${PACKAGE_LIBRARY_DIR}}")

endmacro( simple_package_find )
