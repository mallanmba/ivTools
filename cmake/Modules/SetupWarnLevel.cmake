## 
## We only want to run this once, so the user can 
## change options if they want to, so we create
## a SETUP_WARN_LEVEL_HAS_RUN flag to ensure this. 
## 
## If a project wishes to set their own warn flags, set
## one of the following variables before calling this macro:
## WARN_FLAGS         : completely override the default flags
## WARN_FLAG_ADDITIONS: add to the defaults
##
######################################################
if( NOT SETUP_WARN_LEVEL_HAS_RUN )

  ## GCC
  #######################################
  if( CMAKE_COMPILER_IS_GNUCXX )
    # allow the user to override default warn flags
    if( NOT WARN_FLAGS )
      set( WARN_FLAGS "-Wall -Woverloaded-virtual ${WARN_FLAG_ADDITIONS}"  )
    endif( NOT WARN_FLAGS )
    message( STATUS "Set warning flags to \"${WARN_FLAGS}\"" )
      
    set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${WARN_FLAGS}"
            CACHE STRING "Flags used by the C++ compiler during all build types." 
            FORCE )
  endif( CMAKE_COMPILER_IS_GNUCXX ) 
  
  ## Visual Studio
  #######################################
  if( MSVC )
    # allow the user to override default warn flags
    if( NOT WARN_FLAGS )
      set( WARN_FLAGS ${WARN_FLAG_ADDITIONS} )
      set( WARN_FLAGS "${WARN_FLAGS} /wd4099" ) # disable 'type name first seen using 'class' now seen using 'struct''
      set( WARN_FLAGS "${WARN_FLAGS} /wd4244" ) # disable 'initializing from double to float' 
      set( WARN_FLAGS "${WARN_FLAGS} /wd4305" ) # disable 'const double to float' truncation
      set( WARN_FLAGS "${WARN_FLAGS} /wd4309" ) # disable 'const int to char' truncation 
      set( WARN_FLAGS "${WARN_FLAGS} /wd4522" ) # disable 'multiple assignment operators specified'
      set( WARN_FLAGS "${WARN_FLAGS} /wd4800" ) # disable 'forcing value to bool' 
      set( WARN_FLAGS "${WARN_FLAGS} /wd4996" ) # disable 'std::_Copy_backward_opt' was declared deprecated (used by boost)
      set( WARN_FLAGS "${WARN_FLAGS} /wd4805" ) # disable 'unsafe mix of type 'BOOL' and type 'bool' in operation' (from ACE)
      ## msvc doesn't do exception specification...
      set( WARN_FLAGS "${WARN_FLAGS} /wd4290" ) # disable 'C++ exception specification ignored except to indicate a function is not __declspec(nothrow)'

      ## Potentially sketchy disables... these pop up throughout boost. 
      ## Maybe the config is messed up, or maybe it is expected. 
      ## http://www.unknownroad.com/rtfm/VisualStudio/warningC4251.html
      set( WARN_FLAGS "${WARN_FLAGS} /wd4275" ) # disable 'non dll-interface class 'foo' used as base for dll-interface class 'bar''
      set( WARN_FLAGS "${WARN_FLAGS} /wd4251" ) # disable 'class 'foo' needs to have dll-interface to be used by clients of class 'bar''

      ## XXX this one should not be part of the default disables. However,
      ## XXX it is convinient to have it here right now... remove later
      ## XXX when there is better support for user-disables via cmakeoptions
      set( WARN_FLAGS "${WARN_FLAGS} /wd4355" ) # disable 'this' : used in base member initializer list
      
      ## also add /MP to hint parallel builds
      set( WARN_FLAGS "/MP ${WARN_FLAGS}" ) # http://msdn.microsoft.com/en-us/library/bb385193.aspx

    endif( NOT WARN_FLAGS )

    ## Enable /bigobj by default - afaik the only downside to
    ## using it is incompatibility with pre-VC2005 compilers
    ## http://msdn.microsoft.com/en-us/library/ms173499.aspx
    set( WARN_FLAGS "/bigobj ${WARN_FLAGS}" )

    message( STATUS "Set warning flags to \"${WARN_FLAGS}\"" )

    set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${WARN_FLAGS}"
            CACHE STRING "Flags used by the C++ compiler during all build types." 
            FORCE )

    ## XXX FIXME XXX NEED TO MAKE THIS USER CONFIGURABLE
    set( LINKER_ADDITIONS "/NODEFAULTLIB:LIBCMT" )
    set( CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS}    /NODEFAULTLIB:LIBCMT" CACHE STRING "" FORCE )
    set( CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /NODEFAULTLIB:LIBCMT" CACHE STRING "" FORCE )
    set( CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /NODEFAULTLIB:LIBCMT" CACHE STRING "" FORCE )

    ### The MSVC compiler mangles C++ names differently in Release and Debug mode, 
    ### so libraries cannot be mixed-and-matched. To keep things simple, only 
    ### enable Release builds by default. RelWithDebInfo builds optimized code
    ### but also includes debug symbols.
    #set( CMAKE_CONFIGURATION_TYPES RelWithDebInfo Release
    #        CACHE STRING 
    #        "Only allow Release and RelWithDebInfo info to avoid C++ name mangling problems w/ Debug libs"
    #        FORCE )
    
    ## Set DEBUG build postfix character
    ## little 'd' is used by ACE/TAO and RTI/DDS, 
    ## so we adopt their convention
    set(CMAKE_DEBUG_POSTFIX "d" CACHE STRING "Append this string to debug lib names")
    
  endif( MSVC )
  
  ## all done
  #######################################
  set( SETUP_WARN_LEVEL_HAS_RUN ON CACHE INTERNAL "one-time setup of compiler warning flags" FORCE)
  
endif( NOT SETUP_WARN_LEVEL_HAS_RUN )

if( MSVC )
  message(STATUS "Compiler is Microsoft Visual Studio:")
  message(STATUS "  _MSVC_VER is ${MSVC_VERSION} (${ARCH_COMPILER})")
  
  # globally diable the idiotic min and max macros that cause havoc everywhere
  message(STATUS "  Adding NOMINMAX to compiler defines")
  add_definitions( -DNOMINMAX )
  
  message(STATUS "  Adding WIN32_LEAN_AND_MEAN to compiler defines")
  add_definitions( -DWIN32_LEAN_AND_MEAN )
endif( MSVC )
