## find_package_if
##
## Only execute find_package if the conditional
## is true. Usage:
##  find_package_if( OpenGL BUILD_WITH_OPENGL AND NOT BAD_DAY )
##
##################################################
macro( find_package_if PACKAGE )
  if( ${ARGN} )
    find_package( ${PACKAGE} )
  endif( ${ARGN} )
endmacro( find_package_if )

## assert 
## 
## message, followed by a conditional expression
## if the conditional expression fails, cmake 
## will abort. 
##   assert( "minimum requirements" OPENGL_FOUND AND NOT APPLE )
##
#################################################
macro( assert MESSAGE )

  if( ${ARGN} )
    # do nothing
  else( ${ARGN} )
  
    set( MSG "\nASSERT ${MESSAGE} failed!\n" )
    set( MSG "${MSG}    assertion: ${ARGN}\n" )
    foreach( ARG ${ARGN} )
      set( MSG "${MSG}        ${ARG}[${${ARG}}]\n" )
    endforeach( ARG )
    message( FATAL_ERROR "${MSG}" )
    
  endif( ${ARGN} )

endmacro( assert )

## minimum_requirements
##
## Checks the passed variables, if any of them
## are false, abort cmake and print error 
## message. Useage: 
##   minimum_requirements( TAO_FOUND OPENGL_FOUND KNALGO_knFoo_LIBRARY )
## 
#################################################
macro( minimum_requirements )

  set( MSG "\nERROR! CMake cannot continue because the following minimum requirements were not met: \n" )
  set( MINIMUM_REQUIREMENTS_OK TRUE )
  foreach( ARG ${ARGN} )
  
    if( NOT ${ARG} )
      set( MSG "${MSG}    ${ARG} is not true, value is \"${${ARG}}\" \n" )
      set( MINIMUM_REQUIREMENTS_OK FALSE )
    endif( NOT ${ARG} )
  
  endforeach( ARG ${ARGN} )

  if( NOT MINIMUM_REQUIREMENTS_OK ) 
    message( FATAL_ERROR "${MSG}" )
  endif( NOT MINIMUM_REQUIREMENTS_OK )
  
endmacro( minimum_requirements )

##
## add_target_definitions
##
## macro to simplify adding definitions to a 
## target. The passed arguments should NOT be
## prefixed with a -D
##
## The legacy "add_definitions" function required a 
## -D, but to support that syntax, we'd have to use
## the COMPILE_FLAGS property instead of the 
## COMPILE_DEFINITIONS property. 
##
#################################################
macro( add_target_definitions TARGET_NAME )
  set_property( TARGET ${TARGET_NAME} APPEND PROPERTY COMPILE_DEFINITIONS ${ARGN} )
endmacro( add_target_definitions )

##
## add_directory_definitions
##
## macro to simplify adding definitions to a source
## directory. The passed arguments should NOT be
## prefixed with a -D
##
## This does essentially the same thing as "add_definitions"
## function, except "-D" should not be prefixed to the define
##
#################################################
macro( add_srcdir_definitions )
  #get_property( EXISTING DIRECTORY PROPERTY COMPILE_DEFINITIONS )
  #message(STATUS "BEFORE: ${EXISTING}")
  set_property( DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS ${ARGN} )
endmacro( add_srcdir_definitions )

##
## set_unless_env
##
## macro to set a variable to a given value 
## unless an environment variable has been 
## set to override the default
##
#################################################
macro( set_unless_env SET_VARIABLE ENV_VARIABLE DEFAULT_VALUE )
  
  if( DEFINED ENV{${ENV_VARIABLE}} )
    set( ${SET_VARIABLE} $ENV{${ENV_VARIABLE}} )
  else( DEFINED ENV{${ENV_VARIABLE}} )
    set( ${SET_VARIABLE} ${DEFAULT_VALUE} )
  endif( DEFINED ENV{${ENV_VARIABLE}} )
  #message(STATUS "(dbg) set_unless_env ${SET_VARIABLE} set to ${${SET_VARIABLE}}")
  
endmacro( set_unless_env  )

## set the DOXYGEN_WORKING_DIR variable
## end create it
#################################################
macro( doxygen_set_working_dir )

  set( DOXYGEN_WORKING_DIR ${CMAKE_INSTALL_PREFIX}/doc/${CMAKE_PROJECT_NAME} )
  file( MAKE_DIRECTORY ${DOXYGEN_WORKING_DIR} )
  
endmacro( doxygen_set_working_dir )

## Create a list of tagfiles for external 
## modules. The modules are expected to have 
## installed their documentation and tagfile
## into ${INSTALL_PREFIX}/doc/${MODULE_NAME}
##  
## To get the DOXYGEN_TAGFILES string formatted
## properly, we first create a list of expanded
## tagfile strings, then create the actual
## string with backslashes and indentation
#################################################
macro( doxygen_create_tagfile_list )
  
  set( TMP_TAGFILES "" )
  foreach( ARG ${ARGN} )
    set( TMP_TAGFILES ${TMP_TAGFILES} "${CMAKE_INSTALL_PREFIX}/doc/${ARG}/${ARG}.tag=${CMAKE_INSTALL_PREFIX}/doc/${ARG}/html" )
  endforeach( ARG )
  
  set( DOXYGEN_TAGFILES "" )
  foreach( TAGFILE_ ${TMP_TAGFILES} )
    set( DOXYGEN_TAGFILES "${DOXYGEN_TAGFILES} \\
                         ${TAGFILE_}" )
  endforeach( TAGFILE_ )

endmacro( doxygen_create_tagfile_list )

## Create a list directories to exclude
## from processing
#################################################
macro( doxygen_create_exclude_list )
  
  set( TMP_EXCLUDES "" )
  foreach( ARG ${ARGN} )
    set( TMP_EXCLUDES ${TMP_EXCLUDES} ${ARG} )
  endforeach( ARG )
  
  set( DOXYGEN_EXCLUDE "" )
  foreach( EXCLUDE_ ${TMP_EXCLUDES} )
    set( DOXYGEN_EXCLUDE "${DOXYGEN_EXCLUDE} \\
                         ${EXCLUDE_}" )
  endforeach( EXCLUDE_ )

endmacro( doxygen_create_exclude_list )

## create the make doc target
## expects a Doxyfile.in in the current directory
## and creates documentation in DOXYGEN_WORKING_DIR
#################################################
macro( doxygen_create_doc_target )

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in ${DOXYGEN_WORKING_DIR}/Doxyfile @ONLY)
  
  add_custom_target(doc
    ${DOXYGEN_EXECUTABLE} ${DOXYGEN_WORKING_DIR}/Doxyfile
    WORKING_DIRECTORY     ${DOXYGEN_WORKING_DIR}
    COMMENT "Generating API documentation with Doxygen" VERBATIM
  )
  
endmacro( doxygen_create_doc_target )









