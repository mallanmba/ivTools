IVDEPTH = ..
include $(IVDEPTH)/make/ivcommondefs

PROGRAM = ivfix

CXXFILES = \
	ivfix.cpp 	\
	../make/Common.cpp  \
	IfBuilder.cpp	\
	IfCollector.cpp	\
	IfCondenser.cpp	\
	IfFixer.cpp	\
	IfFlattener.cpp	\
	IfHasher.cpp	\
	IfHolder.cpp	\
	IfMerger.cpp	\
	IfReplacer.cpp	\
	IfReporter.cpp	\
	IfShape.cpp	\
	IfShapeList.cpp	\
	IfSorter.cpp	\
	IfStripper.cpp	\
	IfTypes.cpp	\
	IfWeeder.cpp

LLDLIBS = $(INVENTOR_LIB)

all: all_ivbin

install: install_ivbin

include $(IVCOMMONRULES)
