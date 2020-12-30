/*
 *
 *  Copyright (C) 2000 Silicon Graphics, Inc.  All Rights Reserved. 
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  Further, this software is distributed without any warranty that it is
 *  free of the rightful claim of any third person regarding infringement
 *  or the like.  Any license provided herein, whether implied or
 *  otherwise, applies only to this software file.  Patent licenses, if
 *  any, provided herein do not apply to combinations of this program with
 *  other software, or any other product whatsoever.
 * 
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *  Contact information: Silicon Graphics, Inc., 1600 Amphitheatre Pkwy,
 *  Mountain View, CA  94043, or:
 * 
 *  http://www.sgi.com 
 * 
 *  For further information regarding this notice, see: 
 * 
 *  http://oss.sgi.com/projects/GenInfo/NoticeExplan/
 *
 */

/*
 *  Port to Windows and to Coin by PCJohn (peciva _at fit.vutbr.cz)
 *
 *  Changes:
 *  - added -m option to use SoTransform while generating output file 
 *    instead of SoMatrixTransform (better file readability of ascii files,
 *    but a little bit worse performance)
 *  - getopt ported on Windows
 *  - handling stdin and stdout on Windows
 *  - correct program name on Windows on all terminal outputs
 *  - disabling of texture loading
 *  
 */

#include <string.h>
#include <stdlib.h>

#include <Inventor/SoDB.h>
#include <Inventor/SoInput.h>
#include <Inventor/SoInteraction.h>
#include <Inventor/actions/SoWriteAction.h>
#include <Inventor/nodes/SoSeparator.h>

#include "IfFixer.h"
#include "IfReporter.h"

#include "../make/Common.h"  // Windows porting


/////////////////////////////////////////////////////////////////////////////
//
// This structure is used to store and pass around command-line options.
//
/////////////////////////////////////////////////////////////////////////////

typedef struct {
    IfFixer::ReportLevel  reportLevel;
    SbBool      writeAscii;
    SbBool      doAnyNormals;
    SbBool      doAnyTexCoords;
    SbBool      writeStrips;
    SbBool      writeVertexProperty;
    SbBool      useSoTransform;
    const char* inFileName;
    const char* outFileName;
    SoInput     inFile;
    SoOutput    outFile;
} OptionInfo;

/////////////////////////////////////////////////////////////////////////////
//
// Forward references.
//
/////////////////////////////////////////////////////////////////////////////

static void printUsage();
static void parseArgs(int argc, char **argv, OptionInfo &options);
static void initOptions(OptionInfo &options);

/////////////////////////////////////////////////////////////////////////////
//
// Mainline.
//
/////////////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{
  // This precomputes correct program name from argv[0],
  // because using argv[0] for program name is not a good solution on Windows.
  updateProgName(argv[0]);

  SoInteraction::init();

  OptionInfo options;

  initOptions(options);

  // Parse arguments
  parseArgs(argc, argv, options);

  // override texture nodes by our own versions that do not bother 
  // about long procedure of texture data loading
  SoTexture2noLoad::override();
  SoTexture3noLoad::override();
  SoVRMLImageTextureNoLoad::override();

  // Input and output files
  OPEN_INPUT_FILE(&options.inFile, options.inFileName, FALSE, printUsage);
  OPEN_OUTPUT_FILE(&options.outFile, options.outFileName, FALSE, printUsage);

  IfFixer fixer;
  fixer.setReportLevel(options.reportLevel, stderr);
  fixer.setStripFlag(options.writeStrips);
  fixer.setNormalFlag(options.doAnyNormals);
  fixer.setTextureCoordFlag(options.doAnyTexCoords);
  fixer.setVertexPropertyFlag(options.writeVertexProperty);
  fixer.setUseSoTransform(options.useSoTransform);

  // Read stuff:
  IfReporter::startReport("Reading file");
  SoSeparator *root = SoDB::readAll(&options.inFile);
  if (root == NULL) {
    FILE_READ_ERROR(options.inFileName, progname);
  }
  IfReporter::finishReport();

  // We don't need to ref the root since we want the IfFixer to get
  // rid of the scene graph when it's done with it
  SoNode *resultRoot = fixer.fix(root);
  if (resultRoot == NULL) {
    fprintf(stderr, "%s: No shapes found in data\n", progname);
    return 1;
  }

  resultRoot->ref();

  // Write out the results
  IfReporter::startReport("Writing result");
  SoWriteAction wa(&options.outFile);
  if (! options.writeAscii)
    wa.getOutput()->setBinary(TRUE);
  wa.apply(resultRoot);
  IfReporter::finishReport();

  // Clean up
  CLOSE_INPUT_FILE(&options.inFile, options.inFileName);
  CLOSE_OUTPUT_FILE(&options.outFile, options.outFileName);
  resultRoot->unref();

  return 0;
}

/////////////////////////////////////////////////////////////////////////////
//
// Prints usage message and exits.
//
/////////////////////////////////////////////////////////////////////////////

static void
printUsage()
{
  fprintf(stderr, "Usage: %s [options] [infile] [outfile]\n", progname);
  fprintf(stderr,
    "\t-a     : Write out an ascii file.  Default is binary\n"
    "\t-d dir : Add 'dir' to the list of directories to search\n"
    "\t-f     : Produce independent faces rather than tri strips\n"
    "\t-h     : Print this message (help)\n"
    "\t-n     : Do not generate any normals\n"
    "\t-p     : Do not produce SoVertexProperty nodes for properties\n"
    "\t-t     : Do not generate any texture coordinates\n"
    "\t-m     : Use SoTransform instead of SoMatrixTransform\n"
    "\t         (better file readability of acsii formats).\n"
    "\t-v     : (Verbose) Display status info during processing\n"
    "\t-V     : (Very verbose) Display more detailed status info\n"
    "If no input or output file name is specified, stdin and stdout are used.\n"
    );

  exit(99);
}

/////////////////////////////////////////////////////////////////////////////
//
// Parses input options, filling in OptionInfo structure.
//
/////////////////////////////////////////////////////////////////////////////

static void
parseArgs(int argc, char **argv, OptionInfo &options)
{
  SbBool uhoh = FALSE;
  int c;
  
  while ((c = getopt(argc, argv, "ad:fhnptmvV")) != -1) {
    switch(c) {
    case 'a':
      options.writeAscii = TRUE;
      break;
    case 'd':
      options.inFile.addDirectoryLast(optarg);
      break;
    case 'f':
      options.writeStrips = FALSE;
      break;
    case 'n':
      options.doAnyNormals = FALSE;
      break;
    case 'p':
      options.writeVertexProperty = FALSE;
      break;
    case 't':
      options.doAnyTexCoords = FALSE;
      break;
    case 'm':
      options.useSoTransform = TRUE;
      break;
    case 'v':
      options.reportLevel = IfFixer::LOW;
      break;
    case 'V':
      options.reportLevel = IfFixer::HIGH;
      break;
    case 'h':  // Help
    default:
      uhoh = TRUE;
      break;
    }
  }

  // Handle optional input and output file name
  options.inFileName = (optind < argc) ? argv[optind++] : NULL;
  options.outFileName = (optind < argc) ? argv[optind++] : NULL;

  // Too many arguments?
  if (optind < argc)
    uhoh = TRUE;

  if (uhoh)
    printUsage();
}

/////////////////////////////////////////////////////////////////////////////
//
// Initializes an OptionInfo structure.
//
/////////////////////////////////////////////////////////////////////////////

static void
initOptions(OptionInfo &options)
{
  options.reportLevel    = IfFixer::NONE;
  options.writeAscii    = FALSE;
  options.doAnyNormals  = TRUE;
  options.doAnyTexCoords  = TRUE;
  options.writeStrips    = TRUE;
  options.writeVertexProperty  = TRUE;
  options.useSoTransform  = FALSE;
}
