set( TARGET ivperf )

set(HEADERS 
  BarChart.h
  OverrideNodes.h
  SbProfiler.h
)

set( SOURCES 
  ${TARGET}.cpp
  BarChart.cpp
  OverrideNodes.cpp
  SbProfiler.cpp
)

link_libraries( Common )

add_definitions( -DUSE_SOQT )

link_libraries( 
  ${COIN3D_SoQt_LIBRARY}
  ${OPENGL_gl_LIBRARY}
)

add_executable( ${TARGET} 
  ${SOURCES}
  ${HEADERS}
)

add_executable( overrideClassGenerator
  OverrideClassGenerator.cpp
)

install_targets( /bin ${TARGET} overrideClassGenerator )
