######################################################################
# Find script for gsl
#
# NOTE: gsl has a whole bunch of libraries. Right now, this script
# looks for *only* the base lib and gslcblas and puts those into 
# GSL_LIBRARIES.
#
# Output Variables:
# -----------------
# GSL_FOUND           : TRUE if search succeded
# GSL_INCLUDE_DIR     : include path
# GSL_LIBRARIES       : libraries in one variable (use this in your CMakeLists)
# GSL_LIBRARY_DIR     : library path
# GSL_gsl_LIBRARY     : full path to gsl
# GSL_gslcblas_LIBRARY:full path to gslcblas
#
######################################################################


include( SimplePackageFind )

set( PACKAGE_NAME           gsl )
set( PACKAGE_DIRS           gsl )
set( PACKAGE_REQ_LIBRARY    gsl )
set( PACKAGE_REQ_INCLUDE    gsl/gsl_version.h )

simple_package_find("${PACKAGE_NAME}" 
                    "${PACKAGE_DIRS}" 
                    "${PACKAGE_REQ_LIBRARY}"
                    "${PACKAGE_REQ_INCLUDE}"
)

##
## find paths to package libraries
##
################################################
if( ${PACKAGE_FOUND} )
  set( LIBRARY_NAMES
    gsl
    gslcblas
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )
