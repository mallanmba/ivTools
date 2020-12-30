include( SimplePackageFind )

set( PACKAGE_NAME         zeromq )
set( PACKAGE_DIRS         zeromq )
set( PACKAGE_REQ_LIBRARY  zmq )
set( PACKAGE_REQ_INCLUDE  zmq.h )

simple_package_find("${PACKAGE_NAME}" 
                    "${PACKAGE_DIRS}" 
                    "${PACKAGE_REQ_LIBRARY}"
                    "${PACKAGE_REQ_INCLUDE}"
)

if( ${PACKAGE_FOUND} )
  set( LIBRARY_NAMES
    zmq
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )
