######################################################################
# Find script for PCAP
#
# Output Variables:
# -----------------
# PCAP_FOUND           : TRUE if search succeded
# PCAP_INCLUDE_DIR     : include path
# PCAP_LIBRARIES       : all libraries in one variable (use this in your CMakeLists)
# PCAP_LIBRARY_DIR     : library path
# PCAP_BASE_LIBRARY    : full path to proj
#
######################################################################
include( SimplePackageFind )

set( PACKAGE_NAME         pcap )
set( PACKAGE_DIRS         libpcap )
set( PACKAGE_REQ_LIBRARY  pcap )
set( PACKAGE_REQ_INCLUDE  pcap.h )

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
    pcap
  )
  get_library_list(${PACKAGE_UPPER} ${${PACKAGE_LIBRARY_DIR}} "d" "${LIBRARY_NAMES}")
endif( ${PACKAGE_FOUND} )



