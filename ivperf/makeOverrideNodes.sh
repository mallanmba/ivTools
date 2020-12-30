#! /bin/sh

echo Making the project...
make -f GNUmakefile.OverrideClassGenerator

echo Generating OverrideNodes.cpp ...
./overrideClassGenerator > OverrideNodes.cpp

echo Done.
