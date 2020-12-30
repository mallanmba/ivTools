IVDEPTH = ..
include $(IVDEPTH)/make/ivcommondefs

PROGRAM = ivnorm

CXXFILES = \
	ivnorm.cpp ../make/Common.cpp \
	FindNormals.cpp \
	Faces.cpp Edges.cpp

LLDLIBS = $(INVENTOR_LIB)

all: all_ivbin

install: install_ivbin

include $(IVCOMMONRULES)
