#include "ivFixCreatorVrml2.h"

#include <stdio.h>
#include <stdlib.h>

#include <QString>
#include <QFileInfo>
#include <QFile>
#include <QByteArray>


int main(int argc, const char** argv)
{
  if (argc < 2 || argv[1][0] == '-') {
    printHelp(argc, argv);
    exit(-1);
  }

  QFileInfo fi(argv[1]);
  if (!fi.isReadable()) {
    printHelp(argc, argv);
    exit(-2);
  }

  QString outfileName = fi.canonicalFilePath();
  if (outfileName.endsWith(".wrl")) {
    outfileName.truncate(outfileName.size()-4);
    outfileName += "-cdef.wrl";
  }
  else {
    outfileName += "-cdef.wrl";
  }

  int numDefTags = 0;
  QFile infile(fi.canonicalFilePath());
  QFile outfile(outfileName);

  infile.open(QIODevice::ReadOnly);
  outfile.open(QIODevice::WriteOnly);

  if (outfile.isWritable()) {
    QByteArray buffer;
    while ( (buffer = infile.readLine()).count() > 0 ) {
      QString str(buffer);
      int idx;
      if ( (idx = str.indexOf("{  # ")) > 0 ) {
        QString defName = str.mid(idx+5).simplified();
        if ( (idx = defName.indexOf(' ') > 0) ) {
          defName.truncate(idx);
        }
        if (defName.length() > 0) {
          numDefTags++;
          int firstNonWhite = 0;
          for (int i = 0; i < str.length(); i++) {
            if ( !(str[i] == ' ' || str[i] == '\t') ) {
              firstNonWhite = i;
              break;
            }
          }
          if (str.indexOf("DEF ") == firstNonWhite) {
            fprintf(stdout, "oops, DEF for %s already exists.\n", qPrintable(defName));
          }
          else {
            str.insert(firstNonWhite, "DEF "+defName+" ");
            buffer = str.toLatin1();
          }
        }
      }
      outfile.write(buffer);
    }
    infile.close();
    outfile.close();

    fprintf(stdout, "Added %d DEF tags, output file is:\n    %s\n", numDefTags, qPrintable(outfileName));
  }
  else {
    fprintf(stderr, "ERROR: output file is not writable: \n    %s\n", qPrintable(outfileName));
  }

  return 0;
}


void printHelp(int argc, const char** argv)
{
  QFileInfo fi(argv[0]);
  QString execName = fi.baseName();
  fprintf(stderr, "+------------------------------------------------\n");
  fprintf(stderr, "|\n");
  fprintf(stderr, "| %s reads VRML2 files exported from \n", qPrintable(execName));
  fprintf(stderr, "| Multigen Creator and adds DEF tags to node names.\n");
  fprintf(stderr, "| DEF tag names are extracted from comments.\n");
  fprintf(stderr, "| \n");
  fprintf(stderr, "|   usage: \n");
  fprintf(stderr, "|   %s <filename>\n", qPrintable(execName));
  fprintf(stderr, "| \n");
  fprintf(stderr, "+------------------------------------------------\n");
}
