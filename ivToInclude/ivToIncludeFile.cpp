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
// Convert from ASCII/binary Inventor file to a C-standard header file.
// Typical use is
//
// ivToInclude foo <model.iv >foo.h
//
// such command will produce foo.h file containing:
//
// const unsigned char foo[] = {
// 0x23u,0x49u,0x6eu,0x76u,0x65u,0x6eu,0x74u,....
// };
//
// Such file can be included into the your project and the model 
// will be built in your application, e.g. no external file.
//
//
// Format for these files is as follows:
//
// const unsigned char variableName[] = { 0xXXu,0xXXu,0xXXu };
//
// compared to original SGI format:
//
// const char variableName[] = { 0xXX,0xXX,0xXX };
//
// where the stuff between the quotes is a hex version of the binary file.
//

/*
 *  Port to Windows and to Coin by PCJohn (peciva _at fit.vutbr.cz)
 *
 *  Changes:
 *  - fixed issues related to output file that
 *    produced warnings when compiled by MSVC6
 *  - not using SoXt
 *  - handling stdin and stdout on Windows
 *  - correct program name on Windows on all terminal outputs
 *  - disabling of texture loading
 *  - added ascii format output
 *  
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <Inventor/SoInteraction.h>
#include <Inventor/nodes/SoSeparator.h>
#include <Inventor/SoInput.h>
#include <Inventor/SoOutput.h>
#include <Inventor/actions/SoWriteAction.h>
#include "../make/Common.h"  // Windows porting

static SbBool asciiOutput = FALSE;

static void
print_usage()
{
    (void)fprintf(stderr, "Usage: %s [options] variableName < inputFile.iv\n",
                  progname);
    (void)fprintf(stderr, "\t-a : Output ascii\n");
    (void)fprintf(stderr, "\t-h : This message (help)\n");
    (void)fprintf(stderr, "\tvariableName : The name of the variable to create.\n");
    exit(99);
}

static void
parse_args(int argc, char **argv, char **variableName)
{
    SbBool nameAssigned = FALSE;
    int i;
    for (i=1; i<argc; i++) {
        if (argv[i] && argv[i][0] == '-') {
            if (strcmp(argv[i], "-h") == 0)  print_usage(); else
            if (strcmp(argv[i], "-a") == 0)  asciiOutput = TRUE;
        } else {
            if (nameAssigned)  print_usage();
            else {
                (*variableName) = strdup(argv[i]);
                nameAssigned = TRUE;
            }
        }
    }
    if (!nameAssigned)  print_usage();
    
    return; 
}

static void writeAscii(const char *variableName, const char *outputBuffer, unsigned int size)
{
    // print declaration
    fprintf( stdout, "const char %s[] =\n", variableName );
    
    unsigned int i = 0;
    while (i<size) {
        
        // make \" character
        fprintf( stdout, "\"");

        // print line content
        char c = outputBuffer[i++];
        while (c != '\n') {
            
            // handle special characters
            if (c == '\"')  fprintf( stdout, "\\\""); else
            if (c == '\\')  fprintf( stdout, "\\\\"); 
            
            // regular output
            else fprintf( stdout, "%c", c);
            
            if (i == size) break;
            c = outputBuffer[i++];
        }

        // finish line
        if (i != size)
            fprintf( stdout, "\\n\"\n");
        else
            fprintf( stdout, "\\n\";");
    }
}

static void convertDirectly(SoInput *in, const char *variableName)
{
    SbString s;
    char c;
    //char prev = 0;

    while (in->read(c, FALSE)) {
        
        // handle DOS line endings
        // (convert them to Unix one)
        if (c == (char)0x0d) {
            if (in->read(c, FALSE)) {
                if (c == 0x0a)
                    s += c;
                else {
                    s += (char)0x0d;
                    s += c;
                }
            } else
                s += (char)0x0d;
        }
        else
            s += c;
    }

    writeAscii(variableName, s.getString(), s.getLength()); 
}

int main(int argc, char **argv)
{
    // This precomputes correct program name from argv[0],
    // because using argv[0] for program name is not a good solution on Windows.
    updateProgName(argv[0]);

    SoInteraction::init();

    // Parse arguments
    char *variableName = NULL;

    parse_args(argc, argv, &variableName );

    // override texture nodes by our own versions that do not bother 
    // about long procedure of texture data loading
    SoTexture2noLoad::override();
    SoTexture3noLoad::override();
    SoVRMLImageTextureNoLoad::override();

    // read stuff:
    SoInput in;
    SoSeparator *root;
    void *buf;
    size_t size;

    // open and read from stdin
    OPEN_INPUT_FILE(&in, NULL, FALSE, &print_usage);
    if (!in.isBinary() && asciiOutput) {
        // handle special case when just there is ascii2ascii conversion
        // to keep original formating
        convertDirectly(&in, variableName);
        CLOSE_INPUT_FILE(&in, NULL);
        return 0;
    } else
        root = SoDB::readAll( &in );
    CLOSE_INPUT_FILE(&in, NULL);
    if (!root)
        // this will print error message and exit
        FILE_READ_ERROR(NULL);

    root->ref();

    // write stuff into a buffer
    SoOutput out;
    out.setBinary(!asciiOutput);
    out.setBuffer( malloc(1000), 1000, realloc );
    SoWriteAction writer(&out);
    writer.apply(root);

    if (root)
        root->unref();

    // Create the output file
    out.getBuffer(buf, size);
    char *outputBuffer = (char *) buf;
    fprintf(stderr,"bufferSize = %zd\n", size);
    
    if (!asciiOutput) {
#if 0   // This looks like not work correctly for me on Windows. Why SGI is using %p? PCJohn-2005-10-23
        // Moreover, 0xNN produces warnings on MSVC6 when NN >0x80. PCJohn-2005-10-23
        // Update: the warnings are produced probably only without MSVC6 service packs. PCJohn-2006-05-04
        // Finally, lines longer than 2048 make problems to MSVC6. PCJohn-2005-10-23

        fprintf( stdout, "const char %s[] = {\n", variableName );
        // All but last number get commas afterwards
        for ( size_t j = 0; j < size-1; j++ )
            fprintf( stdout, "0x%p,", outputBuffer[j] );
        // Last number gets no comma afterwards
        fprintf( stdout, "0x%p", outputBuffer[size-1] );
        fprintf( stdout, "\n};\n");
#else
        // Writing only 100 records per line,
        // each record has format of "0xNNu," - "u" tells compiler that the value
        // is unsigned (avoids warnings for MSVC6), and whole array is of 
        // const unsigned char type (originally just const char). PCJohn-2005-10-23

        fprintf( stdout, "const unsigned char %s[] = {\n", variableName );
        size_t j = 0;
        while (TRUE) {
            size_t n = (size-j < 100) ? size-j : 100; // limit number of values per line to 100
            while (n-->0) {
                if (j+1 == size) {
                    fprintf( stdout, "0x%.2xu", (unsigned char)outputBuffer[j++] );
                    fprintf( stdout, "\n};\n");
                    goto writeFinished;
                } else
                    fprintf( stdout, "0x%.2xu,", (unsigned char)outputBuffer[j++] );
            }
            fprintf( stdout, "\n");
        }
writeFinished: ;
#endif
    } else {

        // ASCII output
        writeAscii(variableName, outputBuffer, size);
    }

    return 0;
}
