
//
//  Print out scene graph.
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


#include <Inventor/SoInput.h>
#include <Inventor/SoInteraction.h>
#include <Inventor/nodes/SoGroup.h>
#include <Inventor/actions/SoGetPrimitiveCountAction.h>

#include "../make/Common.h"

#define LAST_CHILD 0x01

static char *inFileName = NULL;
static SoGroup *nodeList = NULL;
static SbBool verbose = FALSE;


static void printUsage()
{
  fprintf(stderr, "Usage: %s [-h] [infile]\n",
          progname);
  fprintf(stderr, "-v, --verbose   : Verbose error messages\n");
  fprintf(stderr, "-h, --help      : This message (help)\n");
  fprintf(stderr, "If input file name is not specified, stdin is used.\n");
  fprintf(stderr, "Output is directed to stdout.\n");

  if (nodeList)  nodeList->unref();
  exit(99);
}

static void parseArgs(int argc, char **argv)
{
  int i;
  for (i=1; i<argc; i++) {
    if (argv[i] && argv[i][0] == '-') {
      if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "--verbose"  ) == 0)  verbose = TRUE; else
      if (strcmp(argv[i], "-h") == 0)
        printUsage();
    } else
      if (!inFileName)  inFileName = argv[i];
      else  printUsage();
  }
}


int main(int argc, char **argv)
{
  updateProgName(argv[0]);

  SoInteraction::init();

  parseArgs(argc, argv);

  // override texture nodes by our own versions that do not bother 
  // about long procedure of texture data loading
  SoTexture2noLoad::override();
  SoTexture3noLoad::override();
  SoVRMLImageTextureNoLoad::override();

  // read stuff:
  SoInput in;
  SoNode *root;

  OPEN_INPUT_FILE(&in, inFileName, verbose, printUsage);

  // Print input file header
  fprintf(stdout, "\n");
  fprintf(stdout, "File header:  %s\n\n", in.getHeader().getString());

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

  // Print overall info
  SoGetPrimitiveCountAction pca;
  pca.apply(nodeList);
  fprintf(stdout, "Triangle count: %6i\n", pca.getTriangleCount());
  fprintf(stdout, "Line count:     %6i\n", pca.getLineCount());
  fprintf(stdout, "Point count:    %6i\n", pca.getPointCount());
  fprintf(stdout, "Text count:     %6i\n", pca.getTextCount());
  fprintf(stdout, "Image count:    %6i\n", pca.getImageCount());
  fprintf(stdout, "\n");
  
  // Output graph
  if (nodeList->getNumChildren() == 0)
    fprintf(stdout, " < empty scene >\n\n");

  int i,c = nodeList->getNumChildren();
  for (i=0; i<c; i++)
    SoGraphPrint::print(nodeList->getChild(i), TRUE);

  nodeList->unref();
  return 0;
}
