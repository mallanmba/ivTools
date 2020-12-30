include(CheckIncludeFiles)

#################################################
#
# check for some common system header files
# this should be called before setup_configure_file 
# 
#################################################

macro( check_common_includes  )

check_include_files( stdint.h    ${PROJECT_UPPER}_HAVE_STDINT_H    )
check_include_files( unistd.h    ${PROJECT_UPPER}_HAVE_UNISTD_H    )

endmacro( check_common_includes  )









