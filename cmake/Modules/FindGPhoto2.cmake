######################################################################
# Find script for gphoto2
#
# Output Variables:
# -----------------
# GPHOTO2_FOUND           : TRUE if search succeded
# GPHOTO2_INCLUDE_DIR     : include path
# GPHOTO2_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# GPHOTO2_LIBRARY_DIR     : library path
#
######################################################################

include( SimplePackageFind )

set( PACKAGE_NAME           gphoto2 )
set( PACKAGE_DIRS           libgphoto2 )
set( PACKAGE_REQ_LIBRARY    gphoto2 )
set( PACKAGE_REQ_INCLUDE    gphoto2/gphoto2.h )

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

  set( LIBRARY_NAMES
    gphoto2
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
  
  find_program( GPHOTO2CONFIG 
                NAMES gphoto2-config 
                PATHS ${GPHOTO2_ROOT_DIR}/bin 
                NO_DEFAULT_PATH )  
  if(GPHOTO2CONFIG)
    execute_process( COMMAND ${GPHOTO2CONFIG} --version OUTPUT_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE GPHOTO2_VERSION_STRING )
    string( REGEX REPLACE "^.*libgphoto2 ([0-9]+).*$" "\\1"                   GPHOTO2_VERSION_MAJOR "${GPHOTO2_VERSION_STRING}" )
    string( REGEX REPLACE "^.*libgphoto2 [0-9]+\\.([0-9]+).*$" "\\1"          GPHOTO2_VERSION_MINOR "${GPHOTO2_VERSION_STRING}" )
    string( REGEX REPLACE "^.*libgphoto2 [0-9]+\\.[0-9]+\\.([0-9]+).*$" "\\1" GPHOTO2_VERSION_PATCH "${GPHOTO2_VERSION_STRING}" )
    set(GPHOTO2_VERSION "${GPHOTO2_VERSION_MAJOR}.${GPHOTO2_VERSION_MINOR}.${GPHOTO2_VERSION_PATCH}")
    message(STATUS "  Found gphoto2 version ${GPHOTO2_VERSION} in ${GPHOTO2_ROOT_DIR}")
  endif(GPHOTO2CONFIG)

endif( ${PACKAGE_FOUND} )

