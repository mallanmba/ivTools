#ifndef COMMON_H_
#define COMMON_H_
//
//  Some code useful for porting Linux applications into the Windows
//  and some fine-tune hacks for better Open Inventor Tools functionality.
//
//
//  Autor: PCJohn (peciva _at fit.vutbr.cz)
//
//  License: public domain
//
//
//  THIS SOFTWARE IS NOT COPYRIGHTED
//
//  This source code is offered for use in the public domain.
//  You may use, modify or distribute it freely.
//
//  This source code is distributed in the hope that it will be useful but
//  WITHOUT ANY WARRANTY.  ALL WARRANTIES, EXPRESS OR IMPLIED ARE HEREBY
//  DISCLAIMED.  This includes but is not limited to warranties of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
//  If you find the source code useful, authors will kindly welcome
//  if you give them credit and keep their names with their source code,
//  but you are not forced to do so.
//

#include <stdio.h>
#include <string.h>
#include <Inventor/SbBasic.h>

class SoInput;
class SoOutput;


//
// linking with main instead of WinMain on Windows
//
#ifdef _WIN32
# pragma comment(linker, "/entry:\"mainCRTStartup\"")
# pragma comment(linker, "/subsystem:\"CONSOLE\"") // show and use console
#endif


//
//  getopt() function
//
//  getopt function resides in unistd.h on Unices,
//  but there is not getopt function on Windows on MSVC6.
//  So, there is an implementation for Windows.

#ifndef _WIN32
# include <unistd.h>
#else
  int getopt(int argc, char **argv, char *opts);
  extern char *optarg;
  extern int optind, opterr, optopt;
#endif


//
//  isatty() function
//
//  isatty resides in unistd.h on Unices
//  and in io.h on Windows on MSVC6.

#ifndef _WIN32
# include <unistd.h>
#else
# include <io.h>
#endif

  
//
//  This class is used instead of, for example,
//
//  in.setFilePointer(stdin)
//
//  and
//
//  out.setFilePointer(stdout)
//  
//  SoStdFile class is used as workaround on Windows DLL design,
//  that does not enables passing of FILE* structures to and from DLL.
//  SoInput and SoOutput are classes inside the Coin DLL, and passing 
//  stdin and stdout there results in the application crash.
//

class SoStdFile {
public:
  static SbBool assign(FILE *f, SoInput *in);
  static void release(FILE *f, SoInput *in);
  static void assign(FILE *f, SoOutput *out);
  static SbBool release(FILE *f, SoOutput *out);
  static void closeAll();
};


//
//  Convenience functions wrapping all input file open and close stuff.
//
SbBool OPEN_INPUT_FILE(SoInput *in, const char *inFileName, SbBool verbose, void (*print_usage)());
void CLOSE_INPUT_FILE(SoInput *in, const char *inFileName);


//
//  Convenience functions wrapping all output file open and close stuff.
//
void OPEN_OUTPUT_FILE(SoOutput *out, const char *outFileName, SbBool verbose, void (*print_usage)());
void CLOSE_OUTPUT_FILE(SoOutput *out, const char *outFileName);


//
//  Convenience function that writes error message about failing of file reading,
//  correct file name, and then terminates the application.
//
void FILE_READ_ERROR(const char *fileName);
void FILE_READ_ERROR(const char *fileName, const char *progName, SbBool terminate = TRUE);


//
//  Program name is used in many program outputs.
//  On Unixes argv[0] can be used, but Windows need another solution.
//
extern const char *progname;
void updateProgName(const char *argv0);


//
//  These classes can be used for disabling texture loading.
//  Many utilities does not display anything and they are doing just geometry processing.
//  Therefore, loading of textures is just a lost of time.
//  Moreover, the user is often bothered by messages about textures that can not be loaded
//  while he is probably really not interested in them.
//
//  Classes that are loading textures: SoTexture2, SoTexture3 (since Coin 2.0), 
//  SoVRMLImageTexture (since Coin 2.0), SoVRMLMovieTexture (not yet implemented in Coin)
//
//  Principle: SoType::overrideType() can be used for changing 
//  of the class instantiation method. So let's change it and create our own
//  API compatible class that will just not load texture from file.
//

// This macro gives the common API for all overriding classes.
#define OVERRIDER_HEADER() \
public: \
  static void override(); \
  static SbBool cancelOverride(); \
private: \
  static int overrideCounter; \
  static SoType::instantiationMethod oldMethod; \
  static void* createInstance()


#include <Inventor/nodes/SoTexture2.h>
#include <Inventor/nodes/SoTexture3.h>
#include <Inventor/VRMLnodes/SoVRMLImageTexture.h>


class SoTexture2noLoad : public SoTexture2 {
  OVERRIDER_HEADER();
protected:
  virtual SbBool readInstance(SoInput *in, unsigned short flags);
};


class SoTexture3noLoad : public SoTexture3 {
  OVERRIDER_HEADER();
protected:
  virtual SbBool readInstance(SoInput *in, unsigned short flags);
};


class SoVRMLImageTextureNoLoad : public SoVRMLImageTexture {
  OVERRIDER_HEADER();
protected:
  virtual SbBool readInstance(SoInput *in, unsigned short flags);
};


//
// Scene graph printing capability.
//
class SoGraphPrint {
public:
  typedef void printGraphCB(SoNode *node, void *data);
  
  static void print(SoNode *node, SbBool shouldPrintPrimitiveCounts,
                    printGraphCB *cb = NULL, void *data = NULL);

  static void printPrimitiveCounts(SoNode *node);

private:
  static void printNode(SoNode *node, SbList<int> *indentation, SbBool shouldPrintPrimitiveCounts,printGraphCB *cb, void *data, SbBool lastChild);
  static void makePrintPrimitiveCounts(SoNode *node, void *data = NULL);
};


#endif /* COMMON_H_ */
