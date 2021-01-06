cmake_minimum_required(VERSION 3.10)
project( iv_tools )

# disable some warnings - this is ancient code
set( CMAKE_CXX_STANDARD 98 )
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wno-int-to-pointer-cast 
                      -Wno-write-strings
                      -Wno-literal-suffix)
endif()

set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake/Modules)

find_package( ament_cmake REQUIRED )
find_package( Qt5 COMPONENTS Core Widgets OpenGL Xml REQUIRED )
find_package( Coin3D REQUIRED )
find_package( OpenGL COMPONENTS OpenGL GLX REQUIRED )
find_package( X11 )

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
  ${OPENGL_LIBRARIES}
)

include_directories( 
  ${COIN3D_INCLUDE_DIR}
)

link_libraries(
  ${COIN3D_LIBRARIES}
)

add_subdirectory( make       )
add_subdirectory( ivAddVP    )
add_subdirectory( ivcat      )
add_subdirectory( ivfix      )
add_subdirectory( ivgraph    )
add_subdirectory( ivinfo     )
add_subdirectory( ivnorm     )
add_subdirectory( ivToInclude)
add_subdirectory( ivvrml     )
add_subdirectory( ivview     )
add_subdirectory( ivperf     )
add_subdirectory( ivFixCreatorVrml2 )

ament_package()
