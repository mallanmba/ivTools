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

//
//______________________________________________________________________
//_____________  S I L I C O N   G R A P H I C S   I N C .  ____________
//
//   $Source: /oss/CVS/cvs/inventor/apps/tools/ivnorm/ivnorm.c++,v $
//   $Revision: 1.3 $
//   $Date: 2001/09/25 00:45:30 $
//
//   ivnorm
//
//      This is the mainline for the IRIS Inventor `ivnorm' program.
//   This program reads an Inventor data file, finds all of the
//   indexed face set nodes, generates normals for each, and writes the
//   result in tact (it does not remove any properties or hierarchy)
//   to a new file.
//
//   Author(s)          : Gavin Bell
//
//   Notes:
//
//_____________  S I L I C O N   G R A P H I C S   I N C .  ____________
//______________________________________________________________________


/*
 *  Port to Windows and to Coin by PCJohn (peciva _at fit.vutbr.cz)
 *
 *  Changes:
 *  - getopt ported on Windows
 *  - handling stdin and stdout on Windows
 *  - correct program name on Windows on all terminal outputs
 *  - disabling of texture loading
 *  
 */


#include <stdio.h>
#include <math.h>
#include <assert.h>
#include <stdlib.h>

#include <Inventor/SoInteraction.h>
#include <Inventor/SoDB.h>
#include <Inventor/SoInput.h>
#include <Inventor/SoOutput.h> // appended because of Coin (original Inventor does this in SoWriteAction.h)
#include <Inventor/nodes/SoNode.h> // appended because of Coin (original Inventor does not need this)
#include <Inventor/actions/SoWriteAction.h>

#include "FindNormals.h"

#include "../make/Common.h"


Face::Orientation orientation = Face::UNKNOWN;
float       creaseAngle = (float)M_PI/6.f;                // 30 degrees
int         findVNorms  = 0;
int         verbose = 0;


static void
printUsage()
{
    (void)fprintf(stderr, "Usage: %s [options] [infile] [outfile]\n", progname);
    (void)fprintf(stderr, "\t-c        Assume counter-clockwise faces\n");
    (void)fprintf(stderr, "\t-C        Assume clockwise faces\n");
    (void)fprintf(stderr, "\t-v        Find vertex normals\n");
    (void)fprintf(stderr, "\t-a angle  Use angle (in degrees) as crease angle\n");
    (void)fprintf(stderr, "\t-V        verbose trace\n");
    (void)fprintf(stderr, "\t-h        This message (help)\n");
    (void)fprintf(stderr, "If input or output file name is not specified,\n");
    (void)fprintf(stderr, "stdin and stdout are used.\n");
    exit(99);
}


//-----------------------------------------------------------------------------
//
// My standard command-line parser for tools that can take two
// filenames or act as a filter.
//
// The function was modified by PCJohn to return file names in third and fourth
// parameter instead of FILE** (portability reasons).
//
//-----------------------------------------------------------------------------
static void
ParseCommandLine(int argc, char **argv, const char **inFileName, const char **outFileName)
{
    int err;        /* Flag: error in options? */
    int c;
    *inFileName = NULL;
    *outFileName = NULL;
    err = 0;

    while ((c = getopt(argc, argv, "cCva:bVh")) != -1)
    {
        switch(c)
        {
          case 'c':
            orientation = Face::CCW;
            break;
          case 'C':
            orientation = Face::CW;
            break;
          case 'v':
            findVNorms = TRUE;
            break;
          case 'a':
            findVNorms = TRUE;
            // convert from given arg (in degrees) to radians
            creaseAngle = (float)atof(optarg) * (float)M_PI / 180.f;
            break;
          case 'V':
            verbose = TRUE;
            break;
          case 'h':        /* Help */
          default:
            err = 1;
            break;
        }
    }

    /* Handle optional filenames */
    for (; optind < argc; optind++)
    {
        if (*inFileName == NULL)
            *inFileName = argv[optind];
        else if (*outFileName == NULL)
            *outFileName = argv[optind];
        else err = 1;        /* Too many arguments */
    }

    if (err)
        printUsage();
}


int
main(int argc, char **argv)
{
    const char *inFileName;
    const char *outFileName;

    SoInteraction::init();

    // This precomputes correct program name from argv[0],
    // because using argv[0] for program name is not a good solution on Windows.
    updateProgName(argv[0]);

    ParseCommandLine(argc, argv, &inFileName, &outFileName);

    // override texture nodes by our own versions that do not bother 
    // about long procedure of texture data loading
    SoTexture2noLoad::override();
    SoTexture3noLoad::override();
    SoVRMLImageTextureNoLoad::override();

    SoNode *node = NULL;
    SbBool ok;

    SoInput in;
    OPEN_INPUT_FILE(&in, inFileName, verbose, printUsage);

    SoOutput out;
    OPEN_OUTPUT_FILE(&out, outFileName, verbose, printUsage);
    SoWriteAction wa(&out);

    FindNormals normalFinder;
    normalFinder.AssumeOrientation(orientation);
    normalFinder.setCreaseAngle(creaseAngle);
    normalFinder.setVerbose(verbose);

    const char *inputName = inFileName ? inFileName : "stdin";
    const char *outputName = outFileName ? outFileName : "stdout";

    for (;;) {
        if (verbose) fprintf(stderr, "%s: reading graph from '%s'.\n", progname, inputName);
        ok = SoDB::read(&in, node);
        if (!ok)  FILE_READ_ERROR(inputName, progname);
        if (verbose) fprintf(stderr, "%s: finished reading graph: %s\n", progname, inputName);
        if (!node)  break;

        node->ref();
        // Generate normals
        normalFinder.apply(node, findVNorms);

        // Write out the (modified) scene graph
        if (verbose) fprintf(stderr, "%s: writing graph to '%s'.\n", argv[0], outputName);
        out.setBinary(in.isBinary());
        wa.apply(node);
        if (verbose) fprintf(stderr, "%s: finished writing graph: %s\n", argv[0], outputName);
    }

    CLOSE_INPUT_FILE(&in, inFileName);
    CLOSE_OUTPUT_FILE(&out, outFileName);

    return 0;
}
