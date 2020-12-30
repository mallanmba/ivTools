## TAO IDL
# Define a macro to generate IDL output
# After this macro is called, 
#
# !!IMPORTANT!! To set the exports, the following 
# variables must be set before calling this macro:
# EXPORT_NAME (e.g. mylib_Export ) and 
# EXPORT_FILE (e,g. mylib_Export.h )
#
# Upon completion of this macro, the following variables will exist
#
# TAO_IDL_GENERATED - all files generated (add this to your target)
#   
# TAO_IDL_GENERATED_HEADERS - generated header files (used for include
#                             file install)
#
# To add additional includes to the tao_idl command line, add them
# to TAO_IDL_INCLUDES before calling the macro:
# set( TAO_IDL_INCLUDES -I/my/foo/include ${TAO_IDL_INCLUDES )
#
#############################################################
macro( tao_wrap_idl )

  # in-source files need to see out-of-source files
  include_directories( ${CMAKE_CURRENT_BINARY_DIR} )
  
  # on unix, set the LD_LIBRARY_PATH explicitly for tao_idl
  # and the PATH so tao_idl can use gperf
  #-----------------------------------------------------
  set( TAO_LIB_VAR "" )
  set( TAO_BIN_VAR "" )
  if( UNIX )
    set( LD_PATH_VAR LD_LIBRARY_PATH )
    if( APPLE ) # "think different", indeed
      set( LD_PATH_VAR DYLD_LIBRARY_PATH )
    endif( APPLE )
    set( ORIGINAL_PATH    $ENV{PATH} )
    set( ORIGINAL_LD_PATH $ENV{${LD_PATH_VAR}} )
    set( TAO_LIB_VAR "${LD_PATH_VAR}=${ORIGINAL_LD_PATH}:${ACE_ROOT_DIR}/lib" )
    set( TAO_BIN_VAR "PATH=${ORIGINAL_PATH}:${ACE_ROOT_DIR}/bin" )
  endif( UNIX )
  
  # the generated files need to reference the *_Export files, 
  # so copy them to the out-of-source tree to avoid nasty 
  # include path referencing mess
  #-----------------------------------------------------
  if( EXPORT_FILE )
    message(STATUS "Copying ${EXPORT_FILE} file to out-of-source tree... (GenerateTaoIdl)" )
    exec_program("${CMAKE_COMMAND}" ARGS
      -E copy_if_different
      "${CMAKE_CURRENT_SOURCE_DIR}/${EXPORT_FILE}"
      "${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_FILE}"
    )
  endif( EXPORT_FILE )
      
  set( IDL_CHDR "C.h" )
  set( IDL_CINL "C.inl" )
  set( IDL_CSRC "C.cpp" )
  set( IDL_SHDR "S.h" )
  set( IDL_SINL "S.inl" )
  set( IDL_SSRC "S.cpp" )

  set( TAO_IDL_VER_FLAGS "" )
  # newer versions of TAO (ACE version 5.8.1+) default to generating errors 
  # for anonymous types. -aw overrides this and makes it a warning
  # Nice of them to add new compiler flags as a "patch" update...
  if( ACE_VERSION VERSION_GREATER "5.8.0" )
    set( TAO_IDL_VER_FLAGS "-aw" )
  endif( ACE_VERSION VERSION_GREATER "5.8.0" )
  
  # -si flag disappeared somewhere before 2.1.2. Use default .inl extensions
  set( TAO_IDL_FLAGS ${TAO_IDL_VER_FLAGS} -in -GC ) # -ci ${IDL_CINL} -si ${IDL_SINL} )
  
  #message( STATUS "TAO_IDL_FLAGS = ${TAO_IDL_FLAGS}" )
  
  # TODO we should to some system introspection to narrow this list down
  set( TAO_IDL_INCLUDES 
    -I${TAO_ROOT_INCLUDE}
    -I${TAO_ROOT_INCLUDE}/tao
    -I${TAO_ROOT_INCLUDE}/orbsvcs
    -I${TAO_ROOT_INCLUDE}/orbsvcs/orbsvcs
    -I/usr/share/idl
    -I/usr/share/idl/orbsvcs
    ${TAO_IDL_INCLUDES} 
	)

  set( SRCDIR ${CMAKE_CURRENT_SOURCE_DIR} )
  set( OOSDIR ${CMAKE_CURRENT_BINARY_DIR} )

  # add a custom command set for idl files
  #-----------------------------------------------------
  foreach( IDL_FILENAME ${ARGN} )

    # get the basename (i.e. "NAME Without Extension")
    get_filename_component( IDL_BASE ${IDL_FILENAME} NAME_WE )

    set( IDL_OUTPUT_HEADERS
      ${OOSDIR}/${IDL_BASE}${IDL_CHDR}
      ${OOSDIR}/${IDL_BASE}${IDL_CINL}
      ${OOSDIR}/${IDL_BASE}${IDL_SHDR}
    )
    # newer versions of TAO don't generate servant inline files
    # not sure what version this happened at, the version 
    # below is a guess
    if( ACE_VERSION VERSION_LESS "6.0.2" )
      set( IDL_OUTPUT_HEADERS ${IDL_OUTPUT_HEADERS} 
        ${OOSDIR}/${IDL_BASE}${IDL_SINL} 
      )
    endif( ACE_VERSION VERSION_LESS "6.0.2" )
  
    set( IDL_OUTPUT_SOURCES
      ${OOSDIR}/${IDL_BASE}${IDL_CSRC}
      ${OOSDIR}/${IDL_BASE}${IDL_SSRC}
    )

    set( IDL_OUTPUT_FILES 
      ${IDL_OUTPUT_HEADERS}
      ${IDL_OUTPUT_SOURCES}
    )

    if( EXPORT_NAME )
      if( NOT EXTRA_TAO_IDL_ARGS MATCHES ".*export_macro=\"${EXPORT_NAME}\"" )
        set( EXTRA_TAO_IDL_ARGS ${EXTRA_TAO_IDL_ARGS} -Wb,export_macro="${EXPORT_NAME}" )
      endif(  NOT EXTRA_TAO_IDL_ARGS MATCHES ".*export_macro=\"${EXPORT_NAME}\"" )
    endif( EXPORT_NAME )

    if( EXPORT_FILE )
      if( NOT EXTRA_TAO_IDL_ARGS MATCHES ".*export_include=\"${EXPORT_FILE}\"" )
        set( EXTRA_TAO_IDL_ARGS ${EXTRA_TAO_IDL_ARGS} -Wb,export_include="${EXPORT_FILE}" )
      endif( NOT EXTRA_TAO_IDL_ARGS MATCHES ".*export_include=\"${EXPORT_FILE}\"" )
    endif( EXPORT_FILE )

    # output files depend on at least the corresponding idl
    set( DEPEND_FILE_LIST ${SRCDIR}/${IDL_BASE}.idl )
    
    # load the contents of the idl file
    file( READ ${IDL_FILENAME} IDL_FILE_CONTENTS )

    # look for other dependencies
    foreach( IDL_DEP_FULL_FILENAME ${ARGN} )
      get_filename_component( IDL_DEP_BASE     ${IDL_DEP_FULL_FILENAME} NAME_WE )

      if( IDL_FILE_CONTENTS MATCHES ${IDL_DEP_BASE}\\.idl AND 
          NOT IDL_DEP_FULL_FILENAME STREQUAL IDL_FILENAME)

        # Target will need to depend on the output file, not the idl,
        # so that included included dependencies work correctly.
        set( DEPEND_FILE_LIST ${DEPEND_FILE_LIST} ${OOSDIR}/${IDL_DEP_BASE}${IDL_CHDR} )

      endif( IDL_FILE_CONTENTS MATCHES ${IDL_DEP_BASE}\\.idl AND 
             NOT IDL_DEP_FULL_FILENAME STREQUAL IDL_FILENAME)
    endforeach( IDL_DEP_FULL_FILENAME ${ARGN} )

    if( DEBUG_IDL_DEPENDENCIES)
      message("${IDL_OUTPUT_FILES} depends on ${DEPEND_FILE_LIST}\n")
    endif (DEBUG_IDL_DEPENDENCIES)

    #message(STATUS "--------------------------------------")
    #message(STATUS "  IDL_OUTPUT_FILES=${IDL_OUTPUT_FILES}")
    #message(STATUS "  DEPEND_FILE_LIST=${DEPEND_FILE_LIST}")
    #message(STATUS "       TAO_BIN_VAR=${TAO_BIN_VAR}")
    #message(STATUS "       TAO_LIB_VAR=${TAO_LIB_VAR}")
    #message(STATUS "   TAO_IDL_COMMAND=${TAO_IDL_COMMAND}")
    #message(STATUS "     TAO_IDL_FLAGS=${TAO_IDL_FLAGS}")
    #message(STATUS "EXTRA_TAO_IDL_ARGS=${EXTRA_TAO_IDL_ARGS}")
    
    # setup the command
    #-----------------------------------------------------
    add_custom_command(
      OUTPUT   ${IDL_OUTPUT_FILES}
      DEPENDS  ${DEPEND_FILE_LIST}
      COMMAND  ${TAO_BIN_VAR} ${TAO_LIB_VAR} ${TAO_IDL_COMMAND}
      ARGS ${TAO_IDL_FLAGS}
           ${EXTRA_TAO_IDL_ARGS}
          -I${SRCDIR} ${TAO_IDL_INCLUDES} 
          -o ${OOSDIR} ${SRCDIR}/${IDL_BASE}.idl
    )
    
    set( TAO_IDL_GENERATED_HEADERS 
      ${IDL_OUTPUT_HEADERS}
      ${TAO_IDL_GENERATED_HEADERS}
    )
    
    set( TAO_IDL_GENERATED 
      ${IDL_OUTPUT_FILES}
      ${TAO_IDL_GENERATED}
    )
  endforeach( IDL_FILENAME )

endmacro( tao_wrap_idl )


