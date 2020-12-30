######################################################################
# Find script for Avt
#
# Output Variables:
# -----------------
# AVT_FOUND            : TRUE if search succeded
# AVT_INCLUDE_DIR      : include path
# AVT_LIBRARIES        : all libraries in one variable (use this in your CMakeLists)
# AVT_LIBRARY_DIR      : library path
# AVT_Imagelib_LIBRARY : full path to libImagelib.a
# AVT_PvAPI_LIBRARY    : full path to libPvAPI.a
#
######################################################################
include( SimplePackageFind )
include( GetLibraryList )

set( PACKAGE_NAME         avt )
set( PACKAGE_DIRS         avt )
set( PACKAGE_REQ_LIBRARY  PvAPI )
set( PACKAGE_REQ_INCLUDE  PvApi.h )

simple_package_find("${PACKAGE_NAME}" 
                    "${PACKAGE_DIRS}" 
                    "${PACKAGE_REQ_LIBRARY}"
                    "${PACKAGE_REQ_INCLUDE}"
)

if( ${PACKAGE_FOUND} )
  set( LIBRARY_NAMES
    PvAPI
    Imagelib
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )

