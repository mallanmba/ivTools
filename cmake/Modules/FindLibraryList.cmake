# Find a list of debug and release libraries for a 
# given package. Example:
# Upon successful completion, 
# find_library_list( FOO ${FOO_LIBRARY_DIR} "d" "foo bar" )
# would set:
# 
# (unix)
# FOO_RELEASE_LIBRARIES = libfoo.so libbar.so
# FOO_LIBRARIES = ${FOO_RELEASE_LIBRARIES}
#
# (windows)
# FOO_RELEASE_LIBRARIES = optimized foo.lib optimized bar.lib
# FOO_DEBUG_LIBRARIES = debug food.lib debug bard.lib
# FOO_LIBRARIES = ${FOO_RELEASE_LIBRARIES} ${FOO_DEBUG_LIBRARIES}
#
###########################################################

macro( find_library_list PKG_PREFIX LIBRARY_DIR DEBUG_POSTFIX LIBRARY_NAMES )

  foreach( LIBRARY_NAME ${LIBRARY_NAMES} )
  
      ##-- release libraries
      ##--------------------
      set( TEMP_VAR_NAME ${PKG_PREFIX}_${LIBRARY_NAME}_LIBRARY )
      find_library( ${TEMP_VAR_NAME} ${LIBRARY_NAME} ${LIBRARY_DIR} NO_DEFAULT_PATH )
      
      if( NOT WIN32 )
      
        if(${TEMP_VAR_NAME})
          set( ${PKG_PREFIX}_RELEASE_LIBRARIES ${${PKG_PREFIX}_RELEASE_LIBRARIES} ${${TEMP_VAR_NAME}} )
          mark_as_advanced( ${TEMP_VAR_NAME} )
        else(${TEMP_VAR_NAME})
          set( ${PKG_PREFIX}_MISSING_LIBRARIES ${${PKG_PREFIX}_MISSING_LIBRARIES} ${TEMP_VAR_NAME} )
        endif(${TEMP_VAR_NAME})
        
      else( NOT WIN32 )
      
        set( ${PKG_PREFIX}_RELEASE_LIBRARIES ${${PKG_PREFIX}_RELEASE_LIBRARIES} optimized ${${TEMP_VAR_NAME}} )
        mark_as_advanced( ${TEMP_VAR_NAME} )
        
        ##-- debug libraries
        ##-------------------
        set( TEMP_VAR_NAME ${PKG_PREFIX}_${LIBRARY_NAME}${DEBUG_POSTFIX}_LIBRARY )
        find_library( ${TEMP_VAR_NAME} ${LIBRARY_NAME}${DEBUG_POSTFIX} ${LIBRARY_DIR} NO_DEFAULT_PATH )
             
        if(${TEMP_VAR_NAME})
          set( ${PKG_PREFIX}_DEBUG_LIBRARIES ${${PKG_PREFIX}_DEBUG_LIBRARIES} debug ${${TEMP_VAR_NAME}} )
          mark_as_advanced( ${TEMP_VAR_NAME} )
        else(${TEMP_VAR_NAME})
          set( ${PKG_PREFIX}_MISSING_LIBRARIES ${${PKG_PREFIX}_MISSING_LIBRARIES} ${TEMP_VAR_NAME} )
        endif(${TEMP_VAR_NAME})
         
      endif( NOT WIN32 ) 
      
  endforeach( LIBRARY_NAME ${LIBRARY_NAMES} ) 

set( ${PKG_PREFIX}_LIBRARIES ${${PKG_PREFIX}_RELEASE_LIBRARIES} ${${PKG_PREFIX}_DEBUG_LIBRARIES} )

endmacro( find_library_list )