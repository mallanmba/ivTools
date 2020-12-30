set( TARGET ivFixCreatorVrml2 )

set(HEADERS 
  ${TARGET}.h
)

set( SOURCES 
  ${TARGET}.cpp
)

add_executable( ${TARGET} 
  ${SOURCES}
  ${HEADERS}
)

install_targets( /bin ${TARGET} )
