
//
//  Convertor between Inventor/VRML file formats.
//  The following formats are supported:
//  - ASCII Inventor
//  - Binary Inventor
//  - VRML1
//  - VRML2 (VRML97)
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


#include <Inventor/SoInteraction.h>
#include <Inventor/SoInput.h>
#include <Inventor/SoOutput.h>
#include <Inventor/nodes/SoGroup.h>
#include <Inventor/VRMLnodes/SoVRMLGroup.h>
#include <Inventor/actions/SoWriteAction.h>
#include <Inventor/actions/SoToVRMLAction.h>
#include <Inventor/actions/SoToVRML2Action.h>

#include "../make/Common.h"


enum FileFormat { FF_UNASSIGNED, FF_IV_ASCII, FF_IV_BINARY, FF_VRML1, FF_VRML2 };
static FileFormat srcFormat = FF_UNASSIGNED;
static FileFormat dstFormat = FF_UNASSIGNED;
static char *inFileName = NULL;
static char *outFileName = NULL;
static SoGroup *nodeList = NULL;
static SbBool verbose = FALSE;


static void print_usage()
{
  fprintf(stderr, "Usage: %s [options] [infile] [[-o] outfile]\n",
          progname);
  fprintf(stderr, "-i, --iv-ascii  : Output Inventor ascii format\n");
  fprintf(stderr, "-b, --iv-binary : Output Inventor binary format\n");
  fprintf(stderr, "-1, --vrml-1    : Output VRML 1.0 format\n");
  fprintf(stderr, "-2, --vrml-2    : Output VRML2/VRML97 format\n");
  fprintf(stderr, "-o [filename]   : Write output to [filename]\n");
  fprintf(stderr, "-v, --verbose   : Print messages during the process\n");
  fprintf(stderr, "-h, --help      : This message (help)\n");
  fprintf(stderr, "If input or output file name is not specified,\n");
  fprintf(stderr, "stdin and stdout are used.\n");

  if (nodeList)  nodeList->unref();
  exit(99);
}

static void parse_args(int argc, char **argv)
{
  SbBool err = FALSE;        // Flag: error in options?
  
  int i;
  for (i=1; i<argc; i++) {
    if (argv[i] && argv[i][0] == '-') {
      if (strcmp(argv[i], "-i") == 0 || strcmp(argv[i], "--iv-ascii" ) == 0)  dstFormat = FF_IV_ASCII; else
      if (strcmp(argv[i], "-b") == 0 || strcmp(argv[i], "--iv-binary") == 0)  dstFormat = FF_IV_BINARY; else
      if (strcmp(argv[i], "-1") == 0 || strcmp(argv[i], "--vrml-1"   ) == 0)  dstFormat = FF_VRML1; else
      if (strcmp(argv[i], "-2") == 0 || strcmp(argv[i], "--vrml-2"   ) == 0)  dstFormat = FF_VRML2; else
      if (strcmp(argv[i], "-o") == 0)  { if (++i < argc) outFileName = argv[i]; else err = TRUE; } else
      if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "--verbose"  ) == 0)  verbose = TRUE; else
      if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help"     ) == 0)  err = TRUE;
      else  err = TRUE;
    } else
      if (!inFileName)  inFileName = argv[i];
      else  outFileName = argv[i];
  }

  if (err) {
    print_usage();
  }
}


static void toVRML2(SoGroup *&root)
{
  SoToVRML2Action toVrml2action;
  toVrml2action.apply(root);
  SoGroup *newRoot = toVrml2action.getVRML2SceneGraph();

  // Test for NULL. Coin returns NULL only if it is compiled without VRML97/VRML 2.0 support.
  if (newRoot == NULL) {
    fprintf(stderr, "Error while converting the file.\n"
            "If you use Coin library, it is probably caused by "
            "compiling the library without VRML97/VRML 2.0 support.\n");
    nodeList->unref();
    exit(1);
  }

  newRoot->ref();
  root->unref();
  root = newRoot;
}


static void toVRML1(SoGroup *&root)
{
  SoToVRMLAction toVrml1action;
  toVrml1action.apply(root);
  SoGroup *newRoot = (SoGroup*)toVrml1action.getVRMLSceneGraph();
  assert(newRoot && "Something is really strange with your Inventor library.");
  newRoot->ref();
  root->unref();
  root = newRoot;
}


int main(int argc, char **argv)
{
  updateProgName(argv[0]);

  SoInteraction::init();

  parse_args(argc, argv);

  if (dstFormat == FF_UNASSIGNED)
    print_usage();

  // override texture nodes by our own versions that do not bother 
  // about long procedure of texture data loading
  SoTexture2noLoad::override();
  SoTexture3noLoad::override();
  SoVRMLImageTextureNoLoad::override();

  // read stuff:
  SoInput in;
  SoNode *root;

  OPEN_INPUT_FILE(&in, inFileName, verbose, print_usage);

  // Get source file format
  if (in.getIVVersion() != 0.f) {
    const char *srcHeader = in.getHeader().getString();
    if (strstr(srcHeader, "Inventor") != NULL) {
      if (in.isBinary())  srcFormat = FF_IV_BINARY; 
      else srcFormat = FF_IV_ASCII;
    }
    if (strstr(srcHeader, "VRML") != NULL) {
      if (strstr(srcHeader, "V1.0") != NULL) srcFormat = FF_VRML1; else
      if (strstr(srcHeader, "V2.0") != NULL) srcFormat = FF_VRML2;
    }
  }
  if (srcFormat == FF_UNASSIGNED) {
    fprintf(stderr, "Unrecognized file header.\n");
    exit(-1);
  }

  // Print input file header
  if (verbose) {
    fprintf(stderr, "Source file header:  %s\n", in.getHeader().getString());
    fprintf(stderr, "Source file format:  ");
    switch (srcFormat) {
      case FF_IV_ASCII:  fprintf(stderr, "Inventor ascii format\n"); break;
      case FF_IV_BINARY: fprintf(stderr, "Inventor binary format\n"); break;
      case FF_VRML1:     fprintf(stderr, "VRML 1.0 format\n"); break;
      case FF_VRML2:     fprintf(stderr, "VRML 2.0 format\n"); break;
      case FF_UNASSIGNED:fprintf(stderr, "FF_UNASSIGNED %s:%d\n", __FILE__, __LINE__); break;
    }
    fprintf(stderr, "Reading...\n");
  }

  // Read the file
  nodeList = new SoGroup;
  nodeList->ref();
  do {
    int read_ok = SoDB::read(&in, root);

    if (!read_ok)
      FILE_READ_ERROR(inFileName);
    else if (root != NULL) {
      nodeList->addChild(root);
    }
  } while (root != NULL);

  CLOSE_INPUT_FILE(&in, inFileName);

  if (verbose) {
    fprintf(stderr, "Converting data to ");
    switch (dstFormat) {
    case FF_IV_ASCII:
    case FF_IV_BINARY: fprintf(stderr, "Inventor format...\n"); break;
    case FF_VRML1:     fprintf(stderr, "VRML 1.0 format...\n"); break;
    case FF_VRML2:     fprintf(stderr, "VRML 2.0 format...\n"); break;
    case FF_UNASSIGNED:fprintf(stderr, "FF_UNASSIGNED %s:%d\n", __FILE__, __LINE__); break;
    }
  }


  // Conversion
  switch (dstFormat) {

  case FF_IV_ASCII:
  case FF_IV_BINARY: switch (srcFormat) {
                     case FF_IV_ASCII:  break;
                     case FF_IV_BINARY: break;
                     case FF_VRML1:     toVRML2(nodeList); // toVRML2 is done because of SoToVRMLAction (used in toVRML1()) in Coin, that does not convert Inventor specific nodes
                     case FF_VRML2:     toVRML1(nodeList);
                                        break;
                     case FF_UNASSIGNED:fprintf(stderr, "FF_UNASSIGNED %s:%d\n", __FILE__, __LINE__); break;
                     }
                     break;

  case FF_VRML1:     switch (srcFormat) {
                     case FF_IV_ASCII:
                     case FF_IV_BINARY:
                     case FF_VRML1:     break;
                     case FF_VRML2:     toVRML1(nodeList);
                                        break;
                     case FF_UNASSIGNED:fprintf(stderr, "FF_UNASSIGNED %s:%d\n", __FILE__, __LINE__); break;
                     }
                     break;

  case FF_VRML2:     switch (srcFormat) {
                     case FF_IV_ASCII:  
                     case FF_IV_BINARY:
                     case FF_VRML1:     toVRML2(nodeList);
                                        break;
                     case FF_VRML2:     break;
                     case FF_UNASSIGNED:fprintf(stderr, "FF_UNASSIGNED %s:%d\n", __FILE__, __LINE__); break;
                     }
                     break;
  case FF_UNASSIGNED:fprintf(stderr, "FF_UNASSIGNED %s:%d\n", __FILE__, __LINE__); break;
  }


  const char *headerString;
  switch (dstFormat) {
  case FF_IV_ASCII:  headerString = "#Inventor V2.1 ascii   "; break;
  case FF_IV_BINARY: headerString = "#Inventor V2.1 binary  "; break;
  case FF_VRML1:     headerString = "#VRML V1.0 ascii   "; break;
  case FF_VRML2:     headerString = "#VRML V2.0 utf8"; break;
  case FF_UNASSIGNED:fprintf(stderr, "FF_UNASSIGNED %s:%d\n", __FILE__, __LINE__); break;
  }

  if (verbose) {
    fprintf(stderr, "Output file header:  %s\n", headerString);
    fprintf(stderr, "Output file format:  ");
    switch (dstFormat) {
    case FF_IV_ASCII:  fprintf(stderr, "Inventor ascii\n"); break;
    case FF_IV_BINARY: fprintf(stderr, "Inventor binary\n"); break;
    case FF_VRML1:     fprintf(stderr, "VRML 1.0\n"); break;
    case FF_VRML2:     fprintf(stderr, "VRML 2.0\n"); break;
    case FF_UNASSIGNED:fprintf(stderr, "FF_UNASSIGNED %s:%d\n", __FILE__, __LINE__); break;
    }
  }

  SoOutput out;
  OPEN_OUTPUT_FILE(&out, outFileName, verbose, print_usage);

  out.setBinary(dstFormat==FF_IV_BINARY);
  out.setHeaderString(headerString);
  
  if (verbose)
    fprintf(stderr, "Writing...\n");

  SoWriteAction wa(&out);
  int i;
  for (i=0; i<nodeList->getNumChildren(); i++)
    wa.apply(nodeList->getChild(i));

  CLOSE_OUTPUT_FILE(&out, outFileName);

  if (verbose)
    fprintf(stderr, "Done.\n");
  
  nodeList->unref();
  return 0;
}
