# Output Variables:
# -----------------
# FLANN_FOUND           : TRUE if search succeded
# FLANN_INCLUDE_DIR     : include path
# FLANN_LIBRARIES       : libraries in one variable (use this in your CMakeLists)
# FLANN_LIBRARY_DIR     : library path
#
######################################################################
message(STATUS "Looking for flann...")

find_path(FLANN_ROOT_DIR include/flann/flann.hpp 
          PATH_SUFFIXES
          HINTS
          ${FLANN_ROOT_DIR}
          $ENV{FLANN_ROOT}
          ${IRG_PACKAGES_DIR}/flann)
          
if(FLANN_ROOT_DIR)
    mark_as_advanced(FLANN_ROOT_DIR)
    
    # look for version
    file(READ "${FLANN_ROOT_DIR}/include/flann/config.h" FLANN_CONFIG)
    string(REGEX REPLACE ".*FLANN_VERSION_ \"([0-9.]+)\".*" "\\1" FLANN_VERSION ${FLANN_CONFIG})

    set(FLANN_INCLUDE_DIR ${FLANN_ROOT_DIR}/include)
    set(FLANN_LIBRARY_DIR ${FLANN_ROOT_DIR}/lib)

    set(LIBRARY_NAMES 
        flann
        flann_cpp )
    get_library_list(FLANN ${FLANN_LIBRARY_DIR} "d" "${LIBRARY_NAMES}")
    
    set(FLANN_FOUND TRUE)
    message(STATUS "  Found flann version ${FLANN_VERSION} in ${FLANN_ROOT_DIR}")
    
else(FLANN_ROOT_DIR)

    message(STATUS"  flann NOT found!!! Try passing -DFLANN_ROOT_DIR=<path> to cmake command, or setting the FLANN_ROOT environment variable")   
    
endif(FLANN_ROOT_DIR)

