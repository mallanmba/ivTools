IVDEPTH = ..
include $(IVDEPTH)/make/ivcommondefs

PROGRAM = ivview

CXXFILES = ivview.cpp ../make/Common.cpp

CXXFLAGS += `soqt-config --cppflags`
#LLDOPTS += -L../../samples/widgets

# Coin port
#LLDLIBS = -lInventorWidget -lInventorXt -lInventor
#LLDLIBS = $(INVENTOR_LIB) $(INVENTOR_XT_LIB)
LLDLIBS = $(INVENTOR_LIB) `soqt-config --ldflags` `soqt-config --libs`

all: all_ivbin

install: install_ivbin
	mkdir -p $(IVHELPDIR)/$(PROGRAM)
	$(INSTALL) -m 644 $(PROGRAM).about $(IVHELPDIR)/$(PROGRAM)

include $(IVCOMMONRULES)
