project( ivfix )

set( TARGET ivfix )

set(HEADERS 
  IfAssert.h
  IfBuilder.h
  IfCollector.h
  IfCondenser.h
  IfFixer.h
  IfFlattener.h
  IfHasher.h
  IfHolder.h
  IfMerger.h
  IfReplacer.h
  IfReporter.h
  IfShape.h
  IfShapeList.h
  IfSorter.h
  IfStripper.h
  IfTypes.h
  IfWeeder.h
)

set( SOURCES 
  IfBuilder.cpp
  IfCollector.cpp
  IfCondenser.cpp
  IfFixer.cpp
  IfFlattener.cpp
  IfHasher.cpp
  IfHolder.cpp
  IfMerger.cpp
  IfReplacer.cpp
  IfReporter.cpp
  IfShape.cpp
  IfShapeList.cpp
  IfSorter.cpp
  IfStripper.cpp
  IfTypes.cpp
  IfWeeder.cpp
  ivfix.cpp
)

link_libraries( Common )

add_executable( ${TARGET} 
  ${SOURCES}
  ${HEADERS}
)

install_targets( /bin ${TARGET} )
