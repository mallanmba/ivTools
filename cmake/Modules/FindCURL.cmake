######################################################################
# Find script for libcURL
#
# Output Variables:
# -----------------
# CURL_FOUND           : TRUE if search succeded
# CURL_INCLUDE_DIR     : include path
# CURL_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# CURL_LIBRARY_DIR     : library path
# CURL_curl_LIBRARY    : full path to library
#
######################################################################

include( SimplePackageFind )
include( CheckSymbolExists ) 

set( PACKAGE_NAME           curl )
set( PACKAGE_DIRS           curl )
set( PACKAGE_REQ_LIBRARY    curl )
set( PACKAGE_REQ_INCLUDE    curl/curl.h )

simple_package_find("${PACKAGE_NAME}" 
                   "${PACKAGE_DIRS}" 
                   "${PACKAGE_REQ_LIBRARY}"
                   "${PACKAGE_REQ_INCLUDE}"
)

if( ${PACKAGE_FOUND} )

  add_definitions( -DCURL_FOUND )
  set( LIBRARY_NAMES 
    curl
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}}  "d" "${LIBRARY_NAMES}")

  check_symbol_exists( CURLSSH_AUTH_PUBLICKEY "${CURL_INCLUDE_DIR}/curl/curl.h" CURL_HAS_SSH )

endif( ${PACKAGE_FOUND} )
