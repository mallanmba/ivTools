set( DLL_SCRIPT_OUTFILE    ${PROJECT_BINARY_DIR}/gather_dlls.cmake )
set( DLLS_FOUND_OUTFILE    ${PROJECT_BINARY_DIR}/gather_dlls.found )
set( DLLS_NOTFOUND_OUTFILE ${PROJECT_BINARY_DIR}/gather_dlls.notfound )
set( DLLS_ALL_IN_OUTFILE   ${PROJECT_BINARY_DIR}/gather_dlls.all_in )
# make sure we start with empty files
file( WRITE  ${DLL_SCRIPT_OUTFILE}    "" )
file( WRITE  ${DLLS_FOUND_OUTFILE}    "" )
file( WRITE  ${DLLS_NOTFOUND_OUTFILE} "" )
file( WRITE  ${DLLS_ALL_IN_OUTFILE}   "" )

##
## Macro to find win32 DLLs for libraries that we link 
## against. Not particularly sophisticated, it just 
## looks for DLLs with the same name as the .lib in the 
## same directory as the .lib, or in a 'bin' dir. 
##
## USEAGE:
##   gather_dlls( ${Boost_LIBRARIES} ${ACE_LIBARARIES} )
##   gather_dlls_install()
##
## Creates a "gather_dlls" make target
##
######################################################
macro( gather_dlls ) 

  if(WIN32)
    message( STATUS "Finding external dlls..." )
    
    ## find the dlls
    ##------------------------------------------------------
    set( DLLS_FOUND "" )
    set( DLLS_NOTFOUND "" )
    set( NEXTFLAG "" )
    set( GATHER_RELEASE_ONLY FALSE )
    
    foreach( LIBARG ${ARGN} )

      if( LIBARG ) 
	#message( STATUS ${LIBARG} )
        if( "${LIBARG}" MATCHES "RELEASE_ONLY" )
          set( GATHER_RELEASE_ONLY TRUE )
        endif( "${LIBARG}" MATCHES "RELEASE_ONLY" )
        
        if( "${LIBARG}" MATCHES "debug|optimized" )
        
          set( NEXTFLAG ${LIBARG} )
          
        else( "${LIBARG}" MATCHES "debug|optimized" )
        
          set( IS_VALID TRUE )
          if( GATHER_RELEASE_ONLY )
            if( "${NEXTFLAG}" MATCHES "debug" )
              set( IS_VALID FALSE )
            endif( "${NEXTFLAG}" MATCHES "debug" )
          endif( GATHER_RELEASE_ONLY )

          if( IS_VALID )
            # look for it next to the .lib
            string(REGEX REPLACE "lib$" "dll" DLL_NAME ${LIBARG})
            if( NOT EXISTS ${DLL_NAME} )
              # replace lib with bin 
              string(REGEX REPLACE "/lib/" "/bin/" DLL_NAME ${DLL_NAME})
            endif( NOT EXISTS ${DLL_NAME} )

            if( EXISTS ${DLL_NAME} ) 
              set( DLLS_FOUND ${DLLS_FOUND} ${DLL_NAME} )
            else( EXISTS ${DLL_NAME} ) 
              set( DLLS_NOTFOUND ${DLLS_NOTFOUND} ${LIBARG} )
            endif( EXISTS ${DLL_NAME} ) 
          endif( IS_VALID )
          
          set(NEXTFLAG "")
          
        endif( "${LIBARG}" MATCHES "debug|optimized" )

      endif( LIBARG )

    endforeach( LIBARG )

    ## write out the found and notfound files
    ##------------------------------------------------------
    foreach( DLL_NAME ${DLLS_NOTFOUND} )
      file( APPEND ${DLLS_NOTFOUND_OUTFILE} "\"${DLL_NAME}\"\n")
    endforeach( DLL_NAME )
    
    foreach( DLL_NAME ${DLLS_FOUND} )
      file( APPEND ${DLLS_FOUND_OUTFILE} "${DLL_NAME}\n" )
    endforeach( DLL_NAME )
    
    
    ## write out the target script
    ##------------------------------------------------------
    set(DLL_DESTINATION_DIR "${CMAKE_INSTALL_PREFIX}/dlls")
    file( APPEND ${DLL_SCRIPT_OUTFILE} "message( STATUS \"Gathered dlls will be copied to: ${DLL_DESTINATION_DIR}\" )\n" )
    file( APPEND ${DLL_SCRIPT_OUTFILE} "exec_program(${CMAKE_COMMAND} ARGS -E make_directory ${DLL_DESTINATION_DIR} )\n" )
    file( APPEND ${DLL_SCRIPT_OUTFILE} "file( STRINGS \n" )
    file( APPEND ${DLL_SCRIPT_OUTFILE} "      \"${DLLS_FOUND_OUTFILE}\" \n")
    file( APPEND ${DLL_SCRIPT_OUTFILE} "      DLLS_FOUND \n")
    file( APPEND ${DLL_SCRIPT_OUTFILE} ") \n" )
    file( APPEND ${DLL_SCRIPT_OUTFILE} "\n")
    file( APPEND ${DLL_SCRIPT_OUTFILE} "foreach( DLL_NAME \${DLLS_FOUND} )          \n" )
    file( APPEND ${DLL_SCRIPT_OUTFILE} "  message( STATUS \"  dll \${DLL_NAME}\" )  \n" )
    file( APPEND ${DLL_SCRIPT_OUTFILE} "  exec_program(${CMAKE_COMMAND} ARGS        \n" )
    file( APPEND ${DLL_SCRIPT_OUTFILE} "               -E copy_if_different         \n" )
    file( APPEND ${DLL_SCRIPT_OUTFILE} "               \"\${DLL_NAME}\"             \n" )
    file( APPEND ${DLL_SCRIPT_OUTFILE} "               ${DLL_DESTINATION_DIR})      \n" )
    file( APPEND ${DLL_SCRIPT_OUTFILE} "endforeach( DLL_NAME )                      \n" )
    
    ## add the custom target
    ## note that this does *not* perform the same action as
    ## 'install' - this copies the list of gathered dlls 
    ## into a given directory, irrespective of whether the 
    ## win32_install_dlls switch is on or not. Useful for
    ## debugging what dlls have been gathered. 
    ##------------------------------------------------------
    add_custom_target( GATHER_DLLS
      "${CMAKE_COMMAND}" -P "${DLL_SCRIPT_OUTFILE}" 
    )

  endif(WIN32)
  
endmacro( gather_dlls )

##
## For packages that have inconsistently named dlls
## (i.e. the dll name does not match the lib name)
## add via gather_named_dll. This will search in the 
## PKG_LIB_DIR for the dll, as well as the package 
## bin dir
## NOTE: this MUST be called AFTER gather_dlls in
##       order for appropriate variables to exist 
######################################################
macro( gather_named_dll DLL_FILENAME PKG_LIB_DIR )

  # loop in case lib dir variable has more than one value
  foreach( LIB_DIR ${PKG_LIB_DIR} )
    set( DLL_NAME "${LIB_DIR}/${DLL_FILENAME}" )
    if( EXISTS ${DLL_NAME} )
       file( APPEND ${DLLS_FOUND_OUTFILE} "${DLL_NAME}\n")
    else( EXISTS ${DLL_NAME} )
       string(REGEX REPLACE "/lib/" "/bin/" DLL_NAME ${DLL_NAME})
       if( EXISTS ${DLL_NAME} )
         file( APPEND ${DLLS_FOUND_OUTFILE} "${DLL_NAME}\n")
       else( EXISTS ${DLL_NAME} )
         file( APPEND ${DLLS_NOTFOUND_OUTFILE} "\"${DLL_FILENAME} in ${PGK_LIB_DIR}\"\n")
       endif( EXISTS ${DLL_NAME} )
    endif( EXISTS ${DLL_NAME} )
  endforeach( LIB_DIR )

endmacro( gather_named_dll )

## 
## Gathers all files with a .dll extension from the 
## specified directory (and a directory with 'lib'
## replaced with 'bin')
## NOTE: this MUST be called AFTER gather_dlls in
##       order for appropriate variables to exist 
######################################################
macro( gather_all_dlls_in )
  set( LIB_DIR ${ARGN} )
  if( WIN32 AND LIB_DIR ) 
    set( PKG_LIB_DIR ${LIB_DIR} )
    string(REGEX REPLACE "/lib$" "/bin" PKG_BIN_DIR ${PKG_LIB_DIR})
    
    file( APPEND ${DLLS_ALL_IN_OUTFILE} "${PKG_LIB_DIR}\n")
    file( APPEND ${DLLS_ALL_IN_OUTFILE} "${PKG_BIN_DIR}\n")
    
    file( GLOB DLL_LIB_GLOB ${PKG_LIB_DIR}/*.dll )
    file( GLOB DLL_BIN_GLOB ${PKG_BIN_DIR}/*.dll )  
    foreach( DLL_NAME ${DLL_LIB_GLOB} ${DLL_BIN_GLOB} )
      file( APPEND ${DLLS_FOUND_OUTFILE} "${DLL_NAME}\n")
    endforeach( DLL_NAME )
  endif( WIN32 AND LIB_DIR )
endmacro( gather_all_dlls_in )

##
## Call this after all other gather calls. Creates
## a build switch to enable dll installation (off 
## by default)
######################################################
macro( gather_dlls_install )
  if( WIN32 )
    add_build_var( win32_install_dlls FALSE )
    if( ${PROJECT_UPPER}_BUILD_win32_install_dlls )
      file( STRINGS
            "${DLLS_FOUND_OUTFILE}"
            DLLS_FOUND
      )
      foreach( DLL_NAME ${DLLS_FOUND}  )
        message( STATUS "  will install ${DLL_NAME} " )
        install( FILES ${DLL_NAME} DESTINATION bin )
      endforeach( DLL_NAME )
    endif( ${PROJECT_UPPER}_BUILD_win32_install_dlls )
  endif( WIN32 )
endmacro( gather_dlls_install )


