## USAGE: add_build_switch( subdir DEPENDENCY_FOUND AND OTHER_DEPENDENCY_FOUND )
##
## add_build_switch is essentially a smarter version of add_subdirectory
##
## A cache value is created for the subdirectory so the user can toggle
## whether the subdir is built or not. The default state of the switch
## is how the PKG_FOUND statement is evaluated. For example:
## add_build_switch( guiSubdir QT_FOUND AND OPENGL_FOUND AND MIRO_FOUND )
## if Miro, OpenGL and Qt were all found, guiSubdir would be built by default.
## If one or more of those packages were not found, the default state would 
## be "OFF"
##
## If BUILD_SWITCH_SUBDIR_PREFIX is defined before calling add_build_switch
## or add_build_var, that value will be inserted before the subdir name, i.e.
## FOO_BUILD_prefix_subdir instead of FOO_BUILD_subdir
##
##==========================================================
include(AppendInternalList)

## constants
set( BUILD_DEFAULT_TRUE  TRUE  )
set( BUILD_DEFAULT_FALSE FALSE )


set( BUILD_SWITCH_LOG_FILENAME ${PROJECT_NAME}.BuildSwitches.txt )
set( BUILD_SWITCH_LOG_FILEPATH ${PROJECT_BINARY_DIR}/${BUILD_SWITCH_LOG_FILENAME} )

## initialize
string( TOUPPER ${PROJECT_NAME} PROJECT_UPPER )
set( BUILD_PREFIX ${PROJECT_UPPER} )
initialize_internal_list(ALL_BUILD_SWITCHES)
file( WRITE  ${BUILD_SWITCH_LOG_FILEPATH} "# ${PROJECT_NAME} build switch log\n" )
file( APPEND ${BUILD_SWITCH_LOG_FILEPATH} "#----------------------------------\n" )


## @internal
##==========================================================
macro( is_true_or_false TESTSTATE TESTVAR ) # surely there must be an internal way to do this?
  set(${TESTSTATE} FALSE)
  if( ${${TESTVAR}} )
    set(${TESTSTATE} TRUE)
  endif( ${${TESTVAR}} )
endmacro( is_true_or_false )

## @internal
##==========================================================
macro( log_build_switch BUILD_SWITCH_NAME ARGUMENTS ) 
  # append the state of the build switch as well as the expression which led 
  # to that state in the log
  
  # Found a CMake bug: this code should be ok, but fails:
  #set(FOO MATCHES)
  #if("${FOO}" MATCHES "MATCHES" OR "${FOO}" MATCHES "OR")
  #  message(STATUS "OK")
  #endif("${FOO}" MATCHES "MATCHES" OR "${FOO}" MATCHES "OR")
  
  file( APPEND ${BUILD_SWITCH_LOG_FILEPATH} "BuildSwitch:${BUILD_SWITCH_NAME} = ${${BUILD_SWITCH_NAME}}" )
  file( APPEND ${BUILD_SWITCH_LOG_FILEPATH} "\n" )
  
  foreach( THISARG ${ARGUMENTS} ) 
    set(IS_KEYWORD FALSE)
    
    if( "${THISARG}" MATCHES "AND" OR "${THISARG}" MATCHES "NOT" OR "${THISARG}" MATCHES "OR" OR "${THISARG}" MATCHES "MATCHES" )
      set(IS_KEYWORD TRUE)
    endif( "${THISARG}" MATCHES "AND" OR "${THISARG}" MATCHES "NOT" OR "${THISARG}" MATCHES "OR" OR "${THISARG}" MATCHES "MATCHES" )
     
    if(IS_KEYWORD)
      file( APPEND ${BUILD_SWITCH_LOG_FILEPATH} "           :${THISARG}\n" )
    else(IS_KEYWORD)
      is_true_or_false(STATE THISARG)
      file( APPEND ${BUILD_SWITCH_LOG_FILEPATH} "           : ${THISARG}=${STATE}\n" )
    endif(IS_KEYWORD)
    
  endforeach( THISARG ${ARGN} ) 
  file( APPEND ${BUILD_SWITCH_LOG_FILEPATH} "\n" )
endmacro( log_build_switch BPREFIX ) 

## Create a cache switch to turn on/off building a particular
## subdirectory. A variable <PROJECT>_BUILD_<subdirectory> is 
## created to reflect state of build switch
##==========================================================
macro( add_build_switch SUBDIR )
  if( NOT DEFINED BUILD_PREFIX )
    message(SEND_ERROR "BUILD_PREFIX not defined in SetupBuildSwitch.cmake")
  endif( NOT DEFINED BUILD_PREFIX )


  # evaluate PKG_FOUND 
  if( ${ARGN} )
    set( BUILD_${SUBDIR}_DEFAULT ON )
  else( ${ARGN} )
    set( BUILD_${SUBDIR}_DEFAULT OFF )
  endif( ${ARGN} )
  
  set( BUILD_SWITCH_NAME ${BUILD_PREFIX}_BUILD_${SUBDIR} )
  if(BUILD_SWITCH_SUBDIR_PREFIX)
    set( BUILD_SWITCH_NAME ${BUILD_PREFIX}_BUILD_${BUILD_SWITCH_SUBDIR_PREFIX}_${SUBDIR} )
  endif(BUILD_SWITCH_SUBDIR_PREFIX)
  
  append_internal_list( ALL_BUILD_SWITCHES ${BUILD_SWITCH_NAME})

  set( ${BUILD_SWITCH_NAME} ${BUILD_${SUBDIR}_DEFAULT} CACHE BOOL "Build the ${PROJECT_NAME} ${SUBDIR} subdirectory" )
  log_build_switch( ${BUILD_SWITCH_NAME} "${ARGN}" )
  
  if( ${BUILD_SWITCH_NAME} )
    add_subdirectory( ${SUBDIR} )
  endif( ${BUILD_SWITCH_NAME} )
    
endmacro( add_build_switch )

##
## This does not add a cache switch - it just evaluates
## the conditional and calls add_subdirectory if true. 
## Useful for chaining off another cache switch
## A <PROJECT>_BUILD_<subdirectory> is created 
##==========================================================
macro( add_build_slave SUBDIR )
  if( NOT DEFINED BUILD_PREFIX )
    message(SEND_ERROR "BUILD_PREFIX not defined in SetupBuildSwitch.cmake")
  endif( NOT DEFINED BUILD_PREFIX )

  # create build var for consistency w/ add_build_switch
  set( BUILD_SWITCH_NAME ${BUILD_PREFIX}_BUILD_${SUBDIR} )

  if( ${ARGN} )
    set( ${BUILD_SWITCH_NAME} TRUE )
    add_subdirectory( ${SUBDIR} )
  else( ${ARGN} )
    set( ${BUILD_SWITCH_NAME} FALSE )
  endif( ${ARGN} )
  
endmacro( add_build_slave )

##
## Create a build switch variable, but do not call 
## add_subdirectory()
##==========================================================
macro( add_build_var NAME )
  if( NOT DEFINED BUILD_PREFIX )
    message(SEND_ERROR "BUILD_PREFIX not defined in SetupBuildSwitch.cmake")
  endif( NOT DEFINED BUILD_PREFIX )

  # evaluate PKG_FOUND 
  if( ${ARGN} )
    set( BUILD_${NAME}_DEFAULT ON )
  else( ${ARGN} )
    set( BUILD_${NAME}_DEFAULT OFF )
  endif( ${ARGN} )
  
  set( BUILD_SWITCH_NAME ${BUILD_PREFIX}_BUILD_${NAME} )
  if(BUILD_SWITCH_SUBDIR_PREFIX)
    set( BUILD_SWITCH_NAME ${BUILD_PREFIX}_BUILD_${BUILD_SWITCH_SUBDIR_PREFIX}_${SUBDIR} )
  endif(BUILD_SWITCH_SUBDIR_PREFIX)
  
  append_internal_list( ALL_BUILD_SWITCHES ${BUILD_SWITCH_NAME})

  set( ${BUILD_SWITCH_NAME} ${BUILD_${NAME}_DEFAULT} CACHE BOOL "Enable ${PROJECT_NAME} ${NAME} projects" )
  log_build_switch( ${BUILD_SWITCH_NAME} "${ARGN}" )
  
endmacro( add_build_var )

## This macro should probably be re-thought, syntax is a bit odd.
## The idea is the user creates a build var PROJ_BUILD_WITH_FOO, e.g.
##  add_build_var( WITH_FOO  BUILD_DEFAULT_TRUE )
## then uses this to guard a Find script. e.g.
##  find_package_if( Foo PROJ_BUILD_WITH_FOO )
## After the find, build_with_var macro will update
## the value of the BUILD_WITH variable, and a
## PROJ_HAS_FOO variable is created. This variable should end
## up in a config.h file 
#################################################
macro( build_with_var WITH_VAR_NAME )
  #message( STATUS "${PROJECT_UPPER}_BUILD_${WITH_VAR_NAME} = ${${PROJECT_UPPER}_BUILD_${WITH_VAR_NAME}}")
  string( REPLACE "WITH_" "" VAR_NAME ${WITH_VAR_NAME} )
  
  if( ${PROJECT_UPPER}_BUILD_${WITH_VAR_NAME} )
    set( BUILD_STATE OFF )
    
    if( ${ARGN} )
      set( BUILD_STATE ON )
    endif( ${ARGN} )
    
    if( NOT BUILD_STATE ) 
      set( ${PROJECT_UPPER}_BUILD_${WITH_VAR_NAME} ${BUILD_STATE} CACHE BOOL "" FORCE )
    endif( NOT BUILD_STATE )
  endif( ${PROJECT_UPPER}_BUILD_${WITH_VAR_NAME} )

  set( ${PROJECT_UPPER}_HAS_${VAR_NAME} ${${PROJECT_UPPER}_BUILD_${WITH_VAR_NAME}} )
  #message( STATUS "  ${PROJECT_UPPER}_HAS_${VAR_NAME} = ${${PROJECT_UPPER}_BUILD_${WITH_VAR_NAME}}" )

endmacro( build_with_var )


##
## Print the state of each build switch on the console 
## as well as a BuildSwitch.txt file
##==========================================================
macro( print_build_switches )
  message( STATUS "----------------------------------------------" )

  set( FILENAME ${BUILD_SWITCH_LOG_FILENAME} )
  set( FILEPATH ${BUILD_SWITCH_LOG_FILEPATH} )
  
  foreach( BUILD_SWITCH ${ALL_BUILD_SWITCHES} ) 
    message( STATUS " * ${BUILD_SWITCH} = ${${BUILD_SWITCH}}")
    #file(APPEND ${BUILD_SWITCH_LOG_FILEPATH} "BuildSwitch:${BUILD_SWITCH}=${${BUILD_SWITCH}}\n")
  endforeach( BUILD_SWITCH ${ALL_BUILD_SWITCHES} )
  message( STATUS "----------------------------------------------" )
  
  install_files( /lib/cmake FILES ${FILEPATH} )
  
  # nothing to do with switches, but this is a convinient place for it...
  message(STATUS "Install dir for ${PROJECT_NAME} is ${CMAKE_INSTALL_PREFIX}")
  message(STATUS "Build type is ${CMAKE_BUILD_TYPE}")
  
endmacro( print_build_switches )
