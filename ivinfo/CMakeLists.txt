set( TARGET ivinfo )

set(HEADERS 
)

set( SOURCES 
  ${TARGET}.cpp
)

link_libraries( Common )

add_executable( ${TARGET} 
  ${SOURCES}
  ${HEADERS}
)

install_targets( /bin ${TARGET} )
