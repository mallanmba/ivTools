######################################################################
# Find script for ACE
#
# NOTE: ACE has a whole bunch of libraries. Right now, this script
# looks for and verifies *only* the base lib.
#
# NOTE: Defines "USE_ACE" for the compiler. Not sure if
#       this is an appropriate place for this or not. 
#
# Output Variables:
# -----------------
# ACE_FOUND           : TRUE if search succeded
# ACE_INCLUDE_DIR     : include path
# ACE_LIBRARY_DIR     : library path
# ACE_LIBRARIES       : all ACE libraries
# ACE_VERSION         : software version in the form "X.Y.Z"
# ACE_VERSION_MAJOR   : X
# ACE_VERSION_MINOR   : Y
# ACE_VERSION_PATCH   : Z
#
######################################################################
message(STATUS "Looking for ACE")

include( GetPackageLibSearchPath )
include( GetLibraryList )

# do this manually, rather than using SimplePackageFind because 
# ACE's include directory path is 'non-standard' i.e., not
# ${PACKAGE_ROOT_DIR}/include

get_package_lib_search_path( ACE ACE_wrappers ACE_ROOT_DIR ACE_ROOT )

# look for ACE library
#-----------------------------------------
set( TEMP_PATH "NOTFOUND" CACHE PATH "temp_path" FORCE )
mark_as_advanced( TEMP_PATH )
find_library( TEMP_PATH ACE
  ${LIB_SEARCH_PATH}
  NO_DEFAULT_PATH
)

# Set the root to 2 directories above library.
#-----------------------------------------
string(REGEX REPLACE "/[^/]*/[^/]*$" "" ACE_ROOT_DIR ${TEMP_PATH})

if( ACE_ROOT_DIR )
  
  set( ACE_LIBRARY_DIR  ${ACE_ROOT_DIR}/lib )
  
  # FIXME - do a proper header search
  if( EXISTS ${ACE_ROOT_DIR}/ace/ACE.h )
    set( ACE_INCLUDE_DIR  ${ACE_ROOT_DIR}  CACHE PATH "ACE include path" )
  else( EXISTS ${ACE_ROOT_DIR}/ace/ACE.h )
    set( ACE_INCLUDE_DIR  ${ACE_ROOT_DIR}/include  CACHE PATH "ACE include path" )
  else( EXISTS ${ACE_ROOT_DIR}/include/ace/ACE.h )
    set( ACE_INCLUDE_DIR  ${ACE_ROOT_DIR}/include  CACHE PATH "ACE include path" )
  endif( EXISTS ${ACE_ROOT_DIR}/ace/ACE.h )
  
  get_library_list(ACE ${ACE_LIBRARY_DIR} "d" "ACE")
  
  if( ACE_MISSING_LIBRARIES )
    message( STATUS "  !! Not all ACE libraries were found! Missing libraries:\n${ACE_MISSING_LIBRARIES}\n")
    set( ACE_FOUND FALSE )
  else( ACE_MISSING_LIBRARIES )
    set( ACE_FOUND TRUE )
  endif( ACE_MISSING_LIBRARIES )
    
  # Find ACE version by looking at Version.h
  set( ACE_VERSION_HEADER ${ACE_INCLUDE_DIR}/ace/Version.h )
  if( EXISTS ${ACE_VERSION_HEADER} )
    file(STRINGS ${ACE_VERSION_HEADER} ACE_TEMP REGEX "^#define ACE_[A-Z]+_VERSION[ \t]+[0-9]+$")
    string(REGEX REPLACE ".*#define ACE_MAJOR_VERSION[ \t]+([0-9]+).*" "\\1" ACE_VERSION_MAJOR ${ACE_TEMP})
    string(REGEX REPLACE ".*#define ACE_MINOR_VERSION[ \t]+([0-9]+).*" "\\1" ACE_VERSION_MINOR ${ACE_TEMP})
    string(REGEX REPLACE ".*#define ACE_BETA_VERSION[ \t]+([0-9]+).*" "\\1"  ACE_VERSION_PATCH ${ACE_TEMP})
  else( EXISTS ${ACE_VERSION_HEADER} )
    message(STATUS "  WARNING: Could not find ACE version header ${ACE_VERSION_HEADER}")
    set( ACE_VERSION_MAJOR X )
    set( ACE_VERSION_MINOR Y )
    set( ACE_VERSION_PATCH Z )
  endif( EXISTS ${ACE_VERSION_HEADER} )

  set(ACE_VERSION ${ACE_VERSION_MAJOR}.${ACE_VERSION_MINOR}.${ACE_VERSION_PATCH})
  message(STATUS "  Found ACE version ${ACE_VERSION} in ${ACE_ROOT_DIR}")
  
  # Add the USE_ACE definition which some 
  # code needs (CLARAty only?)
  #--------------------------------------------------
  add_definitions( -DUSE_ACE )

else (ACE_ROOT_DIR)

  message(STATUS ${LIB_SEARCH_ERROR_MESSAGE})
  
endif (ACE_ROOT_DIR)

