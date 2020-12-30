# Coin3D SoQt based versions of SGI Inventor tools

This a set of OpenInventor tools ported to work with Coin3D/SoQt. This source
has been sitting around so long that I forget the origins, but I believe I
did some additional porting after PCJohn and set it up to use CMake. 

It looks like there is an `ivtools` repo in the official Coin3D github pages:
https://github.com/coin3d/ivtools
but it doesn't include `ivview`. I haven't used these tools in about a decade, 
but I quickly updated it for Qt5 and put it up on github in case it might
be useful to someone... 

To build:
```
mkdir build; cd build
cmake ..
make install
```

By default, it will install into `~/.local`. To insall elsewhere (e.g. 
into `/usr/local`), pass `CMAKE_INSTALL_PREFIX`, i.e.
```
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
```

-mallanmba

-----------------------------------------------------------

This directory contains the source code for the Open Inventor tools:

ivcat   - Converts between binary and ASCII Inventor formats.
ivinfo  - Prints out information on an Inventor file.
ivnorm  - Generates normals for SoIndexedFaceSet objects.
ivfix   - Restructures an Inventor scene for improved rendereing performance.
ivview  - A simple viewer for quickly viewing Inventor files.
ivAddVP - Converts files to use the vertex property fields.
ivperf  - Analyzes rendering performance
longToInt32 - Converts files to use type int32_t in place of long.
ivvrml  - Converts between Inventor and vrml file formats 
          (the utility is not in original SGI package)
ivToInclude - Converts files into the c-style includable file.
ivgraph - Prints scene graph structure.

Each subdirectory contains the source code and include files needed to
make the program.

Note that you need superuser permissions to build or modify the installed
source code for the Inventor tools.  Alternatively, you can copy the programs 
that interest you into your local directory.


Coin port has been made by PCJohn (peciva _at fit.vutbr.cz).
Porting layer has been placed in make/Common.h and make/Common.cpp
and files has been modified apropriatelly to use this layer.
More information concerning porting issues are in the sources.
