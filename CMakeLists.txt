cmake_minimum_required(VERSION 3.10)
project( ivTools )

## set up some defaults
set( CMAKE_MODULE_PATH  ${PROJECT_SOURCE_DIR}/cmake/Modules ${CMAKE_MODULE_PATH})

include( SetArchitecture )
include( SetupBuildSwitch )
include( SetupWarnLevel )
include( SetupRPATH )

find_package( Qt5 COMPONENTS Core Widgets OpenGL Xml REQUIRED )
find_package( Coin3D )
find_package( OpenGL )
find_package( X11 )

## set default install to .local
##------------------------------------------------
set( ${PROJECT_UPPER}_INSTALL_PREFIX "$ENV{HOME}/.local" CACHE PATH "${PROJECT_NAME} apps install path")
set( CMAKE_INSTALL_PREFIX ${${PROJECT_UPPER}_INSTALL_PREFIX} CACHE INTERNAL "" )

#
# Set up RPATH 
##--------------------------------------------
setup_rpath()

include_directories(
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Widgets_INCLUDE_DIRS}
  ${Qt5OpenGL_INCLUDE_DIRS}
  ${Qt5Xml_INCLUDE_DIRS}
  ${X11_INCLUDE_DIR}
)
link_libraries(
  ${Qt5Core_LIBRARIES}
  ${Qt5Widgets_LIBRARIES}
  ${Qt5OpenGL_LIBRARIES}
  ${Qt5Xml_LIBRARIES}
  ${X11_LIBRARIES}
)

include_directories( 
  ${COIN3D_INCLUDE_DIR}
)

link_libraries(
  ${COIN3D_LIBRARIES}
)

add_build_switch( make        COIN3D_FOUND )
add_build_switch( ivAddVP     COIN3D_FOUND )
add_build_switch( ivcat       COIN3D_FOUND )
add_build_switch( ivfix       COIN3D_FOUND )
add_build_switch( ivgraph     COIN3D_FOUND )
add_build_switch( ivinfo      COIN3D_FOUND )
add_build_switch( ivnorm      COIN3D_FOUND )
add_build_switch( ivToInclude COIN3D_FOUND )
add_build_switch( ivvrml      COIN3D_FOUND )
add_build_switch( ivview      COIN3D_FOUND AND COIN3D_SoQt_LIBRARY )
add_build_switch( ivperf      COIN3D_FOUND AND COIN3D_SoQt_LIBRARY AND NOT APPLE)

add_build_switch( ivFixCreatorVrml2 Qt5_FOUND )

#-----------------------------------
print_build_switches()

message(STATUS "*** install dir = ${CMAKE_INSTALL_PREFIX}")
