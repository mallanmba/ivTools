if( NOT ARCHITECTURE )
  
  include(CMakeDetermineSystem)

  # set the defaults
  #---------------------------------------------------------
  set( ARCH_CPU ${CMAKE_SYSTEM_PROCESSOR} )
  string(TOLOWER ${CMAKE_SYSTEM_NAME} ARCH_OS )
  set( ARCH_COMPILER "unknown" )
  
  # this assumes 'uname' is available if 'gcc' is...
  #---------------------------------------------------------
  if( CMAKE_COMPILER_IS_GNUCXX )
  
    # we want to use "uname -m" instead of 
    # CMAKE_SYSTEM_PROCESSOR (equivalent to "uname -p") 
    # because AMD chips return "athlon" instead of "i686"
    #---------------------------------------------------------
    find_program( UNAME_COMMAND uname )
    if( UNAME_COMMAND )
      exec_program( ${UNAME_COMMAND} ARGS -m OUTPUT_VARIABLE ARCH_MACHINE )
      if(ARCH_MACHINE) 
        set(ARCH_CPU ${ARCH_MACHINE})
      endif(ARCH_MACHINE)
    endif( UNAME_COMMAND )
    
    # get the major.minor version of gcc
    #---------------------------------------------------------
    exec_program( gcc ARGS -dumpversion OUTPUT_VARIABLE GCC_TINYVERSION )
    
    string(REGEX MATCH "^[0-9]+[.][0-9]+" GCC_MINORVERSION ${GCC_TINYVERSION})
    set( ARCH_COMPILER "gcc${GCC_MINORVERSION}" )
    
  endif( CMAKE_COMPILER_IS_GNUCXX )
  
  # punt on the name of the windows compiler
  #---------------------------------------------------------
  if( MSVC )
    # set architecture based on link flags
    string(REGEX REPLACE ".*machine:([A-Za-z0-9]+).*" "\\1" MSVC_MACHINE ${CMAKE_EXE_LINKER_FLAGS})
    if( MSVC_MACHINE MATCHES "X86" )
      set( ARCH_CPU "x86" )
    else( MSVC_MACHINE MATCHES "X86" )
      set( ARCH_CPU "x86_64" )
    endif( MSVC_MACHINE MATCHES "X86" )

    # visual studio, unknown version
    # the MSVC_VERSION number is odd (e.g. 1500 for msvc90)
    # so we override this below if we have better
    # information
    set( ARCH_COMPILER "vc${MSVC_VERSION}" )
    
    if( MSVC60 )
      set( ARCH_COMPILER "vc60" )
    endif( MSVC60 )
  
    if( MSVC70 )
      set( ARCH_COMPILER "vc70" )
    endif( MSVC70 )
  
    if( MSVC71 )
      set( ARCH_COMPILER "vc71" )
    endif( MSVC71 )
  
    if( MSVC80 )
      set( ARCH_COMPILER "vc80" )
    endif( MSVC80 )
  
    if( MSVC90 )
      set( ARCH_COMPILER "vc90" )
    endif( MSVC90 )
   
    if( MSVC_VERSION MATCHES "1600" )
      set( MSVC100 TRUE ) # ARGH! CMake decided for the variable to be MSVC10 
                          # instead of being consistent with their previous defines. 
      set( ARCH_COMPILER "vc100" )
      
      # There seems to be a bug with detecting the VC++ 10 compiler version
      # when using CMake at the command line. Force the variables to their
      # proper state to work around the problem...
      message( STATUS "Forcing CMake variable MSVC10 to true and MSVC90 to false..." )
      set( MSVC90 FALSE )
      set( MSVC10 TRUE )
      
    endif( MSVC_VERSION MATCHES "1600" )
  
  endif( MSVC )
  
  # set the architecture name
  #---------------------------------------------------------
  set(ARCHITECTURE ${ARCH_CPU}_${ARCH_OS}_${ARCH_COMPILER})

#message( STATUS "CPU is \"${ARCH_CPU}\"")
#message( STATUS "System is \"${ARCH_OS}\"")
#message( STATUS "Compiler is \"${ARCH_COMPILER}\"")
message( STATUS "Architecture set to \"${ARCHITECTURE}\"")

endif( NOT ARCHITECTURE )


