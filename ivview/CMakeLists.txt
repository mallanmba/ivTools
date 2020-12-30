set( TARGET ivview )

set(HEADERS 
  ivviewMenus.h
)

set( SOURCES 
  ${TARGET}.cpp
)

add_definitions( -DUSE_SOQT )

link_libraries( 
  Common 
  ${COIN3D_SoQt_LIBRARY}
)

add_executable( ${TARGET} 
  ${SOURCES}
  ${HEADERS}
)

install_targets( /bin ${TARGET} )
