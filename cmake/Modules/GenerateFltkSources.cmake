
## FLTK_WRAP_UI_PROTECTED_VARS
#
# Use this macro as a substitute for fltk_wrap_ui to generate files with protected variables instead of private, so that inherited
# classes can use the variables directly.  Note that unlike fltk_wrap_ui, this macro is executed during config, not build.
#

macro( fltk_wrap_ui_protected_vars LIB_NAME )

  foreach( FLD_FILE ${ARGN} )
    string( REGEX REPLACE ".[^.]*$" "" BASE ${FLD_FILE})
    set( FLTK_UI_DIR ${CMAKE_BINARY_DIR}/${DIR_NAME} )

    # Cannot use fltk_wrap_ui here, since we need fluid to run now.
    execute_process(
      WORKING_DIRECTORY ${FLTK_UI_DIR}
      COMMAND ${FLTK_FLUID_EXECUTABLE} -c ${PROJECT_SOURCE_DIR}/${DIR_NAME}/${FLD_FILE}
      )

    execute_process(
      WORKING_DIRECTORY ${FLTK_UI_DIR}
      INPUT_FILE ${BASE}.hpp
      OUTPUT_FILE ${BASE}.h
      COMMAND sed s/private:/protected:/g 
      )

    set( ${LIB_NAME}_FLTK_UI_SRCS ${FLTK_UI_DIR}/${BASE}.cpp)
    set( ${LIB_NAME}_FLTK_UI_HDRS ${FLTK_UI_DIR}/${BASE}.h)
#
# NOTE: The following lines remove the semicolons from the source code!  Until a CMAKE
# work-around is available, we'll have to resort to the less portable sed command above.
#
# file( READ "${CMAKE_BINARY_DIR}/${DIR_NAME}/${BASE}.hpp" FILE_CONTENTS )
# string( REGEX REPLACE "private:" "protected:" NEW_FILE_CONTENTS ${FILE_CONTENTS})
# file( WRITE "${CMAKE_BINARY_DIR}/${DIR_NAME}/${BASE}.h" ${NEW_FILE_CONTENTS} )

  endforeach( FLD_FILE ${ARGN} )

endmacro( fltk_wrap_ui_protected_vars LIB_NAME )
