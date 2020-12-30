//
//  Some code useful for porting Linux applications into the Windows
//  and some fine-tune hacks for better Open Inventor Tools functionality.
//
//
//  Content:
//
//  - getopt() - the function is missed on Windows platform
//  - SoStdFile class - handling of stdin and stdout on Windows,
//  - updateProgName() - proper detecting of program name on Windows
//  - override classes for disabling texture image loading (some speed up)
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
#include <Inventor/SoInput.h>
#include <Inventor/SoOutput.h>
#include <Inventor/SoOutput.h>
#include <Inventor/nodes/SoGroup.h>
#include <Inventor/actions/SoGetPrimitiveCountAction.h>
#include "Common.h"

#ifdef _WIN32
#include <string.h>
#include <assert.h>
#include <io.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <Inventor/SbDict.h>
#endif



#ifdef _WIN32

// AT&T public domain source for getopt(3). Hacked by PCJohn.

#define ERR(s, c)	{ if(opterr)  fprintf(stderr, "%s%s%c\n", argv[0], s, c); }

int	opterr = 1;
int	optind = 1;
int	optopt;
char	*optarg;

int getopt(int argc, char **argv, char *opts)
{
	static int sp = 1;
	register int c;
	register char *cp;

	if(sp == 1)
		if(optind >= argc ||
		   argv[optind][0] != '-' || argv[optind][1] == '\0')
			return(EOF);
		else if(strcmp(argv[optind], "--") == NULL) {
			optind++;
			return(EOF);
		}
	optopt = c = argv[optind][sp];
	if(c == ':' || (cp=strchr(opts, c)) == NULL) {
		ERR(": illegal option -- ", c);
		if(argv[optind][++sp] == '\0') {
			optind++;
			sp = 1;
		}
		return('?');
	}
	if(*++cp == ':') {
		if(argv[optind][sp+1] != '\0')
			optarg = &argv[optind++][sp+1];
		else if(++optind >= argc) {
			ERR(": option requires an argument -- ", c);
			sp = 1;
			return('?');
		} else
			optarg = argv[optind++];
		sp = 1;
	} else {
		if(argv[optind][++sp] == '\0') {
			sp = 1;
			optind++;
		}
		optarg = NULL;
	}
	return(c);
}
#endif



//#if !defined(_WIN32)  // This code is disabled 
#if 0 // because Coin has problems with non-seekable
      // streams like one produced by:
      // cat <model.iv | ivview
      // although
      // ivview <model.iv works.
      //
      // The bug was fixed in CVS at 2005-03-18, so the following code may
      // be enabled after the next release of Coin (version greater than 2.3).
      // PCJohn 2005-03-20

SbBool SoStdFile::assign(FILE *f, SoInput *in)
{
  in->setFilePointer(f);
  return TRUE;
}

void SoStdFile::release(FILE *f, SoInput *in)
{
}

void SoStdFile::assign(FILE *f, SoOutput *out)
{
  out->setFilePointer(f);
}

SbBool SoStdFile::release(FILE *f, SoOutput *out)
{
  return TRUE;
}

#else

static SbDict inDict(13);
static SbDict outDict(13);

struct FileStruct {
  char *inbuf;
  size_t endpos;
  int numUsages;
  FileStruct() : numUsages(0) {}
  ~FileStruct() { assert(numUsages==0 && "FileStruct is still in use."); }
};


SbBool SoStdFile::assign(FILE *f, SoInput *in)
{
  FileStruct *fs;
  
  if (!inDict.find((SbDict::Key)f, *(void**)&fs)) {
    fs = new FileStruct;
    size_t streamSize = 10240;
    size_t bufSize = streamSize;
    fs->inbuf = (char*)malloc(bufSize);
    fs->endpos = 0;

#ifdef _WIN32 // to avoid LF => CRLF conversion that breaks binary files
    if (_setmode(fileno(f), _O_BINARY) == -1)
      fprintf(stderr, "setmode() failed. Binary files may be not parsed correctly.");
#endif

    do {
      size_t s = fread(fs->inbuf+fs->endpos, 1, streamSize-fs->endpos, f);
      fs->endpos += s;
      if (feof(f))  break;
      if (fs->endpos != streamSize) {
        free(fs->inbuf);
        delete fs;
        return FALSE;
      }
      streamSize += 10240;
      if (bufSize < streamSize) {
        bufSize *= 2;
        char *tmp = (char*)realloc(fs->inbuf, bufSize);
        if (!tmp) {
          free(fs->inbuf);
          delete fs;
          return FALSE;
        }
        fs->inbuf = tmp;
      }
    } while(1);

    inDict.enter((SbDict::Key)f, (void*)fs);
  }

  fs->numUsages++;
  in->setBuffer(fs->inbuf, fs->endpos);
  return TRUE;
} 


void SoStdFile::release(FILE *f, SoInput *in)
{
  FileStruct *fs;

  if (!inDict.find((SbDict::Key)f, *(void**)&fs))
    assert(0 && "Trying to release file that is not assigned.");
  
  if (--fs->numUsages == 0) {
    free(fs->inbuf);
    inDict.remove((SbDict::Key)f);
    delete fs;
  }
}


void SoStdFile::assign(FILE *f, SoOutput *out)
{
  SoOutput *tmp;
  
  if (outDict.find((SbDict::Key)f, *(void**)&tmp))
    assert(0 && "FILE can be assigned to one SoOutput only.");

  outDict.enter((SbDict::Key)f, (void*)out);
  
  out->setBuffer(malloc(4000), 4000, realloc); 
}


SbBool SoStdFile::release(FILE *f, SoOutput *out)
{
  SoOutput *tmp;

  if (!outDict.find((SbDict::Key)f, *(void**)&tmp))
    assert(0 && "Trying to release file that is not assigned.");

  assert(tmp == out && "SoStdFile::release() called with different SoOutput then SoStdFile::assign().");
  outDict.remove((SbDict::Key)f);

#ifdef _WIN32 // to avoid LF => CRLF conversion that breaks binary files
  if (out->isBinary())
    if (_setmode(fileno(f), _O_BINARY) == -1)
      fprintf(stderr, "setmode() failed. Binary files may be not written correctly.");
#endif

  void *buf;
  size_t size;
  SbBool b = out->getBuffer(buf, size);
  assert(b);

  char *p = (char*)buf;
  while (size>0) {
    size_t amount = (size>10240) ? 10240 : size;
    size_t s = fwrite(p, 1, amount, f);
    if (s != amount) {
      free(buf);
#if _WIN32 // It looks like Windows are not sending broken pipe signal, 
           // so this code avoids writing "Write error" message on broken pipes.
      struct _stat info;
      if (_fstat(fileno(f), &info) != 0) { fprintf(stderr, "error in _fstat"); }
      else if (info.st_mode & _S_IFIFO)  return TRUE; // if broken pipe is detected, dont report error
#endif  
      return FALSE;
    }
    p+=s;
    size-=s;
  }
  free(buf);

  return TRUE;
}

#endif



//
//  Convenience function wrapping all file open stuff.
//
SbBool OPEN_INPUT_FILE(SoInput *in, const char *inFileName, SbBool verbose, void (*print_usage)())
{
  if (inFileName == NULL || strcmp(inFileName, "-") == 0) {
    if (verbose)
      fprintf(stderr, "Setting input to stdin...\n");
    
    if (isatty(fileno(stdin))) {
      fprintf(stderr, "Trying to read from standard input, ");
      fprintf(stderr, "but standard input is a tty!\n");
      fprintf(stderr, "\n");
      if (print_usage == NULL)  return FALSE;
      print_usage();
      exit(99);
    }

    //  This is used instead of 
    //
    //  in.setFilePointer(stdin)
    //  
    //  SoStdFile class is used as workaround on Windows DLL design,
    //  that does not enables passing of FILE* structures to and from DLL.
    //  SoInput is class inside the Coin DLL, and passing stdin there
    //  results in the application crash.
    if (!SoStdFile::assign(stdin, in)) {
      fprintf(stderr, "Error while reading from stdin.\n");
      if (print_usage == NULL)  return FALSE;
      exit(-1);
    }
    inFileName = NULL;
  }
  else {
    if (verbose)
      fprintf(stderr, "Setting input to file %s...\n", inFileName);

    if (in->openFile(inFileName) == FALSE) {
      fprintf(stderr, "Could not open file %s\n", inFileName);
      if (print_usage)  exit(-1);
      else  return FALSE;
    }
  }

  // Check file header
  if (in->getIVVersion() == 0.f) {

    // tolerate "empty" stdin
    if (inFileName == NULL && in->getNumBytesRead()==0 && in->eof()) {
      if (verbose)
        fprintf(stderr, "Empty stdin. Terminating.\n");
      exit(-1);
    }

    FILE_READ_ERROR(inFileName);
  }



  // If the filename includes a directory path, add the directory name 
  // to the list of directories where to look for input files 
  if (inFileName != NULL) {
    const char *slashPtr;
    char *searchPath = NULL;
#ifndef _WIN32
    if ((slashPtr = strrchr(inFileName, '/')) != NULL) {
#else
    if ((slashPtr = strrchr(inFileName, '\\')) != NULL) {
#endif
      searchPath = strdup(inFileName);
      searchPath[slashPtr - inFileName] = '\0';
      in->addDirectoryFirst(searchPath);
      free(searchPath);
    }
  }

  return TRUE;
}

  
void CLOSE_INPUT_FILE(SoInput *in, const char *inFileName)
{
  if (inFileName != NULL)  in->closeFile();
  else  SoStdFile::release(stdin, in);
}


void OPEN_OUTPUT_FILE(SoOutput *out, const char *outFileName, SbBool verbose, void (*print_usage)())
{
  if (outFileName == NULL) {
    if (verbose)
      fprintf(stderr, "Setting output to stdout...\n");

    //  This is used instead of 
    //
    //  out.setFilePointer(stdout)
    //  
    //  SoStdFile class is used as workaround on Windows DLL design,
    //  that does not enables passing of FILE* structures to and from DLL.
    //  SoOutput is class inside the Coin DLL, and passing stdout there
    //  results in the application crash.
    SoStdFile::assign(stdout, out);
  } else {
    if (out->openFile(outFileName) == FALSE) {
      fprintf(stderr, "Couldn't open %s for writing\n", outFileName);
      print_usage();
      exit(99);
    }
  }
}


void CLOSE_OUTPUT_FILE(SoOutput *out, const char *outFileName)
{
  if (outFileName) out->closeFile();
  else {
    if (!SoStdFile::release(stdout, out))
      fprintf(stderr, "Write error.\n");
  }
}


void FILE_READ_ERROR(const char *fileName)
{
  FILE_READ_ERROR(fileName, NULL, TRUE);
}


void FILE_READ_ERROR(const char *fileName, const char *progName, SbBool terminate)
{
  const char *printedName;
  
  if (fileName == NULL) printedName = "stdin";
  else if (strcmp(fileName, "-") == 0) printedName = "stdin";
  else printedName = fileName;

  if (progName)  fprintf(stderr, "%s: ", progName);
  fprintf(stderr, "Error while reading from %s.\n", printedName);
  
  if (terminate)  exit(-1);
}


//
//  Contains program file name
//

const char *progname = NULL;
static char progname_buf[32];

void updateProgName(const char *argv0)
{
#ifndef _WIN32
  progname = argv0;
#else
  // extract file name from the path+filename string
  progname = strrchr(argv0, '\\');
  if (progname == NULL)
    progname = argv0;
  else
    progname++;

  // extract suffix .exe from the filename
  if (strlen(progname)+1 < sizeof(progname_buf)) {
    strcpy(progname_buf, progname);
    char *p = strrchr(progname_buf, '.');
    if (p)  (*p) = '\0';
    progname = progname_buf;
  }
#endif
}


//
//  Texture Overriding Classes
//

#define OVERRIDE_SRC(_class_,_parent_) \
\
int _class_::overrideCounter = 0; \
SoType::instantiationMethod _class_::oldMethod; \
\
void _class_::override() \
{ \
  if (overrideCounter == 0) { \
    SoType t = _parent_::getClassTypeId(); \
    oldMethod = t.getInstantiationMethod(); \
    SoType::overrideType(t, _class_::createInstance); \
  } \
  overrideCounter++; \
} \
\
SbBool _class_::cancelOverride() \
{ \
  assert(overrideCounter > 0 && #_class_ "::cancelOverride called more times\n" \
         "than " #_class_ "::override"); \
  assert(_parent_::getClassTypeId().getInstantiationMethod() == _class_::createInstance && \
         "Somebody changed " #_parent_ " instantiation method\n" \
         "(probably through SoType::overrideType) and did not restored it."); \
\
  overrideCounter--; \
  if (overrideCounter == 0) \
    SoType::overrideType(_parent_::getClassTypeId(), oldMethod); \
\
  return overrideCounter==0; \
} \
\
void* _class_::createInstance() \
{ \
  return new _class_; \
}


OVERRIDE_SRC(SoTexture2noLoad, SoTexture2);
OVERRIDE_SRC(SoTexture3noLoad, SoTexture3);
OVERRIDE_SRC(SoVRMLImageTextureNoLoad, SoVRMLImageTexture);


#define READINSTANCE_OVERRIDE(_class_,_parent_,_field_) \
SbBool _class_::readInstance(SoInput *in, unsigned short flags) \
{ \
  SbBool oldNotify = _field_.enableNotify(FALSE); \
  SbBool ok = SoNode::readInstance(in, flags); \
  _field_.enableNotify(oldNotify); \
  return ok; \
}

READINSTANCE_OVERRIDE(SoTexture2noLoad, SoTexture2, filename);
READINSTANCE_OVERRIDE(SoTexture3noLoad, SoTexture3, filenames);
READINSTANCE_OVERRIDE(SoVRMLImageTextureNoLoad, SoVRMLImageTexture, url);


//
//  Scene graph printing capabilities
//

void SoGraphPrint::print(SoNode *node, SbBool shouldPrintPrimitiveCounts,
                         printGraphCB *cb, void *data)
{
  SbList<int> indentation;
  printNode(node, &indentation, shouldPrintPrimitiveCounts, cb, data, FALSE);
  assert(indentation.getLength() == 0);
}


void SoGraphPrint::printPrimitiveCounts(SoNode *node)
{
  SoGetPrimitiveCountAction pca;
  pca.apply(node);
  int tc = pca.getTriangleCount();
  int lc = pca.getLineCount();
  int pc = pca.getPointCount();
  int textC = pca.getTextCount();
  int imgC = pca.getImageCount();
  if (tc!=0 || lc!=0 || pc!=0 || textC!=0 || imgC!=0) {
    fprintf(stdout, "  (");
    SbBool firstWrite = TRUE;
    if (tc > 0)  { fprintf(stdout, "triangles: %i", tc); firstWrite = FALSE; }
    if (lc > 0)  { if (!firstWrite) fprintf(stdout, ", "); fprintf(stdout, "lines: %i", lc); firstWrite = FALSE; }
    if (pc > 0)  { if (!firstWrite) fprintf(stdout, ", "); fprintf(stdout, "points: %i", pc); firstWrite = FALSE; }
    if (textC > 0)  { if (!firstWrite) fprintf(stdout, ", "); fprintf(stdout, "texts: %i", textC); firstWrite = FALSE; }
    if (imgC  > 0)  { if (!firstWrite) fprintf(stdout, ", "); fprintf(stdout, "images: %i", imgC); firstWrite = FALSE; }
    fprintf(stdout, ")");
  }
}


void SoGraphPrint::printNode(SoNode *node, SbList<int> *indentation, SbBool shouldPrintPrimitiveCounts, 
                             printGraphCB *cb, void *data, SbBool lastChild)
{
  // print indentations
  int i,numIndent = indentation->getLength();
  for (i=0; i<numIndent; i++) {
    int j,numSpaces = indentation->operator[](i);
    for (j=0; j<numSpaces; j++)
      fprintf(stdout, " ");
    if (i != numIndent-1)
      fprintf(stdout, "|");
    else
      fprintf(stdout, "*- ");
  }

  // get node type info
  SoType type = node->getTypeId();
  SbName name = type.getName();

  // print node type
  fprintf(stdout, "%s", name.getString());

  // print primitive counts
  if (shouldPrintPrimitiveCounts)
    printPrimitiveCounts(node);

  // make callback for user defined outputs
  if (cb != NULL)
    cb(node, data);

  fprintf(stdout, "\n");

  if (type.isDerivedFrom(SoGroup::getClassTypeId())) {
    SoGroup *group = (SoGroup*)node;

    // append new indentation
    indentation->push(numIndent<=0 ? 2 : 3);

    // correct indentation for the last child
    if (lastChild) {
      assert(indentation->getLength() >= 2 && "printNode called with lastChild set to TRUE for top-level indentation.");
      int sum = indentation->pop();
      sum += indentation->pop();
      indentation->push(sum+1);
    }
    
    // traverse children
    int i,c = group->getNumChildren();
    for (i=0; i<c-1; i++)
      printNode(group->getChild(i), indentation, shouldPrintPrimitiveCounts, cb, data, FALSE);
    if (c>0)
      printNode(group->getChild(i), indentation, shouldPrintPrimitiveCounts, cb, data, TRUE);

    // remove "our" indentation if it is not the last child (last children are handled on other place)
    if (!lastChild)
      indentation->pop();
  }
}


void SoGraphPrint::makePrintPrimitiveCounts(SoNode *node, void *data)
{
  if (!node->getTypeId().isDerivedFrom(SoGroup::getClassTypeId()))
    printPrimitiveCounts(node);
}
