## 04/30/2013 mallan: the old FindBoost.cmake script doesn't work on 
##            on modern systems, and current FindBoost.cmake script
##            from Kitware doesn't work on old systems. So, maintain
##            two find scripts and choose between them depending on 
##            cmake version. 
##
## Delegating Find script to support old and new systems. Note
## that this script does NOT pass on all the arguments faithfully 
## to the subordinate scripts, only version, components and required. 
## This is a hacky and horrible, I know. But we have to support
## ancient systems (RHEL6) and the IRG /usr/local/irg/packages convention. 
######################################################################
include(SetIrgPaths)

## have a look in irg packages dir if BOOST_ROOT and BOOST_ROOT
## environment variable is not already set 
if( NOT BOOST_ROOT ) 
  set( BOOST_ROOT_ENV $ENV{BOOST_ROOT} )
  if( BOOST_ROOT_ENV )
    set( BOOST_ROOT ${BOOST_ROOT_ENV} )
  else( BOOST_ROOT_ENV )
    include( SetIrgPaths )
    set( BOOST_ROOT ${IRG_PACKAGES_DIR}/boost )
    message( STATUS  "Setting BOOST_ROOT to ${BOOST_ROOT}" )
  endif( BOOST_ROOT_ENV )
endif( NOT BOOST_ROOT )

## create variable to hold find_package options
set( BOOST_FIND_OPTIONS "" )
if( Boost_FIND_VERSION )
  set( BOOST_FIND_OPTIONS "${Boost_FIND_VERSION}" )
endif()

if( Boost_FIND_COMPONENTS )
  set( BOOST_FIND_OPTIONS "${BOOST_FIND_OPTIONS};COMPONENTS;${Boost_FIND_COMPONENTS}" )
endif()

if( Boost_FIND_REQUIRED )
  set( BOOST_FIND_OPTIONS "${BOOST_FIND_OPTIONS};REQUIRED" )
endif()

## use a fairly arbitrary version of cmake to choose 
## which find script to use. RHEL6 needs the legacy 
## find script, Ubuntu 14.04 needs the current one. 
if(CMAKE_VERSION VERSION_GREATER 2.8.8)

  set(Boost_NO_BOOST_CMAKE TRUE)
  message(STATUS "Find Boost-current")
  find_package( Boost-current ${BOOST_FIND_OPTIONS} )
  
else(CMAKE_VERSION VERSION_GREATER 2.8.8)
  
  message(STATUS "Find Boost-legacy")
  find_package( Boost-legacy ${BOOST_FIND_OPTIONS} )

endif(CMAKE_VERSION VERSION_GREATER 2.8.8)

