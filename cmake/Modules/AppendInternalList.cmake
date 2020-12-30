# A macro for passing lists between different directories
# through an internal cache variable.
macro( append_internal_list LIST_NAME VALUE )

   # If the list in not in the cache, create it.
   if(${LIST_NAME})
      set( ${LIST_NAME} "${${LIST_NAME}};${VALUE}" CACHE INTERNAL "Internal variable" )
   else( ${LIST_NAME} )
      set( ${LIST_NAME} "${VALUE}" CACHE INTERNAL "Internal variable" )
   endif( ${LIST_NAME} )
endmacro( append_internal_list )

# A macro for passing lists between different directories
# through an internal cache variable.
# This function empties the variable (usually because of older runs)
macro( initialize_internal_list  LIST_NAME)
   set(${LIST_NAME} "" CACHE INTERNAL "Internal variable")
endmacro( initialize_internal_list)

