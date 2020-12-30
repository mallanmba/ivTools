include(CheckTypeSize)

## check sizes of standard types for use below
check_type_size( "long"     SIZEOF_LONG     )
check_type_size( "__int64"  SIZEOF____INT64 )
check_type_size( "size_t"   SIZEOF_SIZE_T   )

## ssize_t is a non-standard but useful type. If
## if does not exist, we guess the preferred
## data type for it (long on 32 bit, __int64 on 64 bit)
## Output Variables :
## ------------------
##   HAVE_SSIZE_T   : 1 if true, 0 if false
##   SSIZE_T_TYPE   : only defined if HAVE_SSIZE_T is 0 ("long" or "__int64")
##
#################################################
check_type_size( "ssize_t"  SIZEOF_SSIZE_T )

if( HAVE_SIZEOF_SSIZE_T )
  set( HAVE_SSIZE_T 1 ) # exists, our job here is done
else( HAVE_SIZEOF_SSIZE_T )
  set( HAVE_SSIZE_T 0 ) # doesn't exist

  if( SIZEOF_SIZE_T EQUAL SIZEOF_LONG )
    set( SSIZE_T_TYPE "long" )
  endif( SIZEOF_SIZE_T EQUAL SIZEOF_LONG )

  if( NOT SSIZE_T_TYPE AND SIZEOF_SIZE_T EQUAL SIZEOF___INT64 )
    set( SSIZE_T_TYPE "__int64" )
  endif( NOT SSIZE_T_TYPE AND SIZEOF_SIZE_T EQUAL SIZEOF___INT64 )

  if( NOT SSIZE_T_TYPE )
    message( SEND_ERROR "Unable to guess suitable type for ssize_t (size_t is ${SIZEOF_SIZE_T} bytes)" )
  endif( NOT SSIZE_T_TYPE )
endif( HAVE_SIZEOF_SSIZE_T )











