include( SimplePackageFind )

set( PACKAGE_NAME           exempi )
set( PACKAGE_DIRS           exempi )
set( PACKAGE_REQ_LIBRARY    exempi )
set( PACKAGE_REQ_INCLUDE    exempi-2.0/exempi/xmp.h )
#set( PACKAGE_INCLUDE_SUFFIX exempi-2.0/exempi )

simple_package_find("${PACKAGE_NAME}" 
                    "${PACKAGE_DIRS}" 
                    "${PACKAGE_REQ_LIBRARY}"
                    "${PACKAGE_REQ_INCLUDE}"
)

if( ${PACKAGE_FOUND} )
  set( LIBRARY_NAMES
    exempi
  )
  get_library_list(EXEMPI ${EXEMPI_LIBRARY_DIR} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} ) 

