######################################################################
# Find script for jsoncpp
#
# Output Variables:
# -----------------
# JSONCPP_FOUND           : TRUE if search succeded
# JSONCPP_INCLUDE_DIR     : include path
# JSONCPP_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# JSONCPP_LIBRARY_DIR     : library path
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME           JsonCpp )
set( PACKAGE_DIRS           jsoncpp )
set( PACKAGE_REQ_LIBRARY    jsoncpp)
set( PACKAGE_REQ_INCLUDE    jsoncpp/json/json.h )

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

  # jsoncpp used the unfortunate prefix of 'include/json' which conflicted 
  # with json-c. Ubuntu has prefixed this with 'jsoncpp' to disambiguate. 
  # For backwards compatibility, we add ${INCLUDE_PATH}/jsoncpp to the includes
  if( NOT JSONCPP_INCLUDE_MODIFIED )
    message(STATUS "  adding ${JSONCPP_INCLUDE_DIR}/jsoncpp to JSONCPP_INCLUDE_DIR")
    set( JSONCPP_INCLUDE_DIR "${JSONCPP_INCLUDE_DIR};${JSONCPP_INCLUDE_DIR}/jsoncpp" CACHE PATH "${PACKAGE_NAME} include path" FORCE)
  endif( NOT JSONCPP_INCLUDE_MODIFIED )
  set( JSONCPP_INCLUDE_MODIFIED TRUE CACHE BOOL "") 
  
  set( LIBRARY_NAMES
    jsoncpp
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")

endif( ${PACKAGE_FOUND} )


#  # json-c uses the same library name as jsoncpp and the same
#  # include dir. Do a simple check for a unique jsoncpp header
#  find_file( JSONCPP_UNIQUE_HEADER jsoncpp/json/value.h
#             HINTS ${${PACKAGE_INCLUDE_DIR}}
#             PATH_SUFFIXES json
#             NO_DEFAULT_PATH )
#  
#  message( STATUS "JSONCPP_INCLUDE_DIR = ${JSONCPP_INCLUDE_DIR}")
#  if( JSONCPP_UNIQUE_HEADER ) 
#  
#    add_definitions( -DJSONCPP_FOUND )
#    set( LIBRARY_NAMES 
#      ${PACKAGE_REQ_LIBRARY}
#    )
#    get_library_list(JSONCPP ${JSONCPP_LIBRARY_DIR} "d" "${LIBRARY_NAMES}")
#        
#  else( JSONCPP_UNIQUE_HEADER ) 
#  
#    message( STATUS "  ** No, jsoncpp was NOT found (json-c was found, but that's not what we want)" )
#    message( STATUS "  ** JSONCPP_FOUND is FALSE" )
#    set( ${PACKAGE_FOUND} FALSE )
#    unset( ${PACKAGE_LIBRARY_DIR} )
#    unset( ${PACKAGE_INCLUDE_DIR} CACHE )
#    unset( ${PACKAGE_BASE_LIBRARY} CACHE )
#    
#  endif( JSONCPP_UNIQUE_HEADER ) 
#  
#  unset( JSONCPP_UNIQUE_HEADER CACHE )


