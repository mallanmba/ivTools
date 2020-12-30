set( TARGET ivnorm )

set(HEADERS 
  Edges.h
  Faces.h
  FindNormals.h
)

set( SOURCES 
  ${TARGET}.cpp
  Edges.cpp
  Faces.cpp
  FindNormals.cpp
)

link_libraries( Common )

add_executable( ${TARGET} 
  ${SOURCES}
  ${HEADERS}
)

install_targets( /bin ${TARGET} )
