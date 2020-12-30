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
 * Copyright (C) 1990,91,92,93,94   Silicon Graphics, Inc.
 *
 _____________________________________________________________
 _________  S I L I C O N   G R A P H I C S   I N C .  _______
 |
 |   $Revision: 1.3 $
 |
 |   Description:
 |        Benchmarks rendering by spinning scene graph.
 |      See printUsage() for usage.
 |        Based on older ivRender by Gavin Bell and Paul Strauss
 |
 |   Author(s)                : Ajay Sreekanth
 |
 _________  S I L I C O N   G R A P H I C S   I N C .  _______
 _____________________________________________________________
 */


/*
 *  Port to Windows and to Coin by PCJohn (peciva _at fit.vutbr.cz)
 *
 *  Changes:
 *  - window creation is now handled by openWindow
 *  - openWindow and killWindow rewrited to be handled on both Unix-style systems and Windows also
 *  - getopt ported on Windows
 *  - handling stdin and stdout on Windows
 *  - correct program name on Windows on all terminal outputs
 *  - added scene graph profiling capabilities
 *  - timing results written also for the tests that were not ruuning
 *    (just to keep user to know that such test is also available)
 *  - meassurements improved (no-fill test does not worked correctly on todays hardware,
 *    detailed OpenGL pipeline analyze, and so on)
 *
 */
#ifdef USE_SOQT
# include <Inventor/Qt/SoQt.h>
# include <Inventor/Qt/viewers/SoQtExaminerViewer.h>
# include <QWidget>
# ifdef _WIN32
#  include <windows.h>
# else
#  include <GL/glx.h>
# endif // _WIN32
#else
# ifdef _WIN32
#  include <Inventor/Win/SoWin.h>
#  include <Inventor/Win/viewers/SoWinExaminerViewer.h>
#  include <windows.h>
# else
#  include <Inventor/Xt/SoXt.h>
#  include <Inventor/Xt/viewers/SoXtExaminerViewer.h>
#  include <GL/glx.h>
# endif
#endif 

#include <GL/gl.h>
#include <stdio.h>
#include <stdlib.h>

#include <Inventor/Sb.h>
#include <Inventor/SbTime.h>
#include <Inventor/SbViewportRegion.h>
#include <Inventor/SoDB.h>
#include <Inventor/SoInteraction.h>
#include <Inventor/actions/SoActions.h>
#include <Inventor/actions/SoCallbackAction.h>
#include <Inventor/actions/SoGLRenderAction.h>
#include <Inventor/actions/SoGetBoundingBoxAction.h>
#include <Inventor/actions/SoSearchAction.h>
#include <Inventor/actions/SoSubAction.h>
#include <Inventor/fields/SoSFTime.h>
#include <Inventor/misc/SoChildList.h>
#include <Inventor/nodekits/SoBaseKit.h>
#include <Inventor/nodes/SoBaseColor.h>
#include <Inventor/nodes/SoCallback.h>
#include <Inventor/nodes/SoDirectionalLight.h>
#include <Inventor/nodes/SoDrawStyle.h>
#include <Inventor/nodes/SoFile.h>
#include <Inventor/nodes/SoLightModel.h>
#include <Inventor/nodes/SoMaterial.h>
#include <Inventor/nodes/SoNode.h>
#include <Inventor/nodes/SoPackedColor.h>
#include <Inventor/nodes/SoPerspectiveCamera.h>
#include <Inventor/nodes/SoSeparator.h>
#include <Inventor/nodes/SoShape.h>
#include <Inventor/nodes/SoShapeHints.h>
#include <Inventor/nodes/SoTexture2.h>
#include <Inventor/nodes/SoTexture3.h>
#include <Inventor/nodes/SoTransform.h>

#include "../make/Common.h"
#include "OverrideNodes.h"


// default window size
#define WINDOW_X        400        
#define WINDOW_Y        400        

// number of frame to draw before autocaching kicks in
// typically needs only 2 but we use 4 just in case
#define NUM_FRAMES_AUTO_CACHING        4

// default number of frames 
#define NUM_FRAMES        60

// the name used in the scene graph to indicate that the application
// will modify something below this separator
// the children of these nodes are touched to destroy the caches there
#define NO_CACHE_NAME        "NoCache"

// the name of the transformation node added to spin the scene
#define SCENE_XFORM_NAME           "SCENE_XFORM_#####"
// the name of the camera node in "superScene"
#define SCENE_CAMERA_NAME          "SCENE_CAMERA_#####"


#ifdef USE_SOQT
  typedef SoQtViewer         SoIvViewer;
  typedef SoQtExaminerViewer SoIvExaminerViewer;
  #define SO_WIDGET  QWidget*
  #define SO_TOOLKIT SoQt
#else
  #ifdef _WIN32
    typedef SoWinViewer         SoIvViewer;
    typedef SoWinExaminerViewer SoIvExaminerViewer;
    #define SO_WIDGET  HWND
    #define SO_TOOLKIT SoWin
  #else
    typedef SoXtViewer         SoIvViewer;
    typedef SoXtExaminerViewer SoIvExaminerViewer;
    #define SO_WIDGET  Widget
    #define SO_TOOLKIT SoXt
  #endif
#endif 

struct Options {
    // fields initialized by the user
    SbBool        showBars;
    int           numFrames;
    const char    *inputFileName;
    unsigned int  windowX, windowY;
    SbBool        useProfiler;
    SbBool        fullProfilerResults;
    // fields set based on structure of scene graph
    SbBool        hasLights;
    SbBool        hasTextures;
    // fields used internally
    SbBool        noClear;
    SbBool        zbufferSwapping;
    SbBool        zbufferNever;
    SbBool        noMaterials;
    SbBool        noTextures;
    SbBool        oneTexture;
    SbBool        noXforms;
    SbBool        outsideViewVolume;
    SbBool        outsideVvByOpenGL;
    SbBool        invisible;
    SbBool        noLights;
    SbBool        freeze;
    SbBool        newRootWanted;
    SoSeparator   *newRoot;
};


#ifdef _WIN32
    HDC      hDC=NULL;    // Private GDI Device Context
    HGLRC    hRC=NULL;    // Permanent Rendering Context
    HWND    hWnd=NULL;    // Holds Our Window Handle
    HINSTANCE  hInstance;    // Holds The Instance Of The Application
#else
    Display      *display;
    Window       window;
#endif
    SbBool fullscreen;

    
//////////////////////////////////////////////////////////////
//
// Description:
//    Prints usage message.
//

static void
printUsage()
//
//////////////////////////////////////////////////////////////
{
    fprintf(stderr,
            "Usage: %s [-bpthH] [-f N] [-w X,Y] [infile]\n",
            progname);
    fprintf(stderr,
            "\t-b      display results as bar chart\n"
            "\t-f N    render N frames for each test (default %i)\n"
            "\t-w X,Y  make window size X by Y pixels (default %ix%i)\n"
            "\t-p      activate profiler; print out scene graph timing\n"
            "\t-t      profiler timing output; print all time values\n"
            "\t        gathered through the profiler rendering meassurement\n"
            "\t-h      this message (help)\n"
            "\t-H      large help\n"
            "If no input file name is given, stdin is used.\n"
            "For more details on meassurements use -H.\n"
            "\n",
            NUM_FRAMES, WINDOW_X, WINDOW_Y);//, NUM_FRAMES_AUTO_CACHING);
}

//////////////////////////////////////////////////////////////
//
// Description:
//    Prints large usage info.
//

static void
printLargeUsage()
//
//////////////////////////////////////////////////////////////
{
    fprintf(stderr,
            "Usage: %s [-bpthH] [-f N] [-w X,Y] [infile]\n",
            progname);
    fprintf(stderr,
            "\n"
            "Parameters:\n"
            "\n"
            "-b      Display results as bar chart.\n"
            "\n"
            "-f N    Render N frames for each test (default %i).\n"
            "        Higher number makes the meassurement more precise.\n"
            "\n"
            "-w X,Y  Make window size X by Y pixels (default %ix%i)\n"
            "        It makes possible to investigate the cost of rendering\n"
            "        on different screen resolutions.\n"
            "\n"
            "-p      activate profiler; print out scene graph timing\n"
            "        Profiling data are gathered during \"as-is\" rendering\n"
            "        meassurement. Please note: median is used instead of\n"
            "        averaging values because there are spikes of render\n"
            "        caching, etc. As a side effect, the children time in\n"
            "        grouping nodes and their sum calculated \"by hand\" may not\n"
            "        match since median often selects values from different\n"
            "        render runs for different children and their parent node.\n"
            "\n"
            "-t      profiler timing output; print all time values gathered\n"
            "        through the profiler rendering meassurement. The number\n"
            "        of printed values is given by -f parameter plus %i that\n"
            "        are rendered before each test (eliminates performance\n"
            "        hits of render caching)\n"
            "\n"
            "Time meassurements:\n"
            "\n"
            "As-Is rendering:\n"
            "     The scene is rendered normally. If profiling data are gathered\n"
            "     (-p or -t option), they are gathered during as-is rendering only.\n"
            "No Clear:\n"
            "     The scene is rendered without clearing color and z-buffers.\n"
            "     A special z-buffer trick is used to avoid z-buffer data from\n"
            "     previous frame to cull geometry of the current frame.\n"
            "     It uses glDepthRange(0.,0.5) and glDepthRange(1.,0.5) and\n"
            "     switch between them before each new frame. This trick is used\n"
            "     in all following meassurements to avoid effect of glClear.\n"
            "No Materials:\n"
            "     SoMaterial, SoPackedColor, SoBaseColor, and classes derived\n"
            "     from them are removed from the scene before the meassurement.\n"
            "No Transforms:\n" // noXforms
            "     All nodes derived from SoTransformation are removed.\n"
            "No Textures:\n"
            "     Used only if the model contains textures.\n"
            "     During the test, all nodes derived from SoTexture2 and\n"
            "     SoTexture3 are removed.\n"
            "One Texture:\n"
            "     Used only if the model contains textures.\n"
            "     All nodes derived from SoTexture2 and SoTexture3 are removed\n"
            "     and simple texture is appended for the whole scene.\n"
            "No Lights:\n"
            "     Used only if the model contains lights.\n"
            "     SoLightModel::BASE_COLOR is set for the whole scene.\n"
            "Outside View Volume:\n"
            "     The model is positioned outside the view volume of the camera.\n"
            "     As a result, OpenGL does not render anything since it is just\n"
            "     transforming geometry to see it is really out of view volume.\n"
            "     The resulting value is known as \"pipe\" or \"vertex\" throughput.\n"
            "     Please note that Open Inventor is using geometry culling in\n"
            "     separators and in shapes that influences the result much.\n"
            "     To see OpenGL throughput only, look at \"Time taken by OpenGL\n"
            "     vertex transformations\".\n"
            "Z-Buffer Culled:\n"
            "     glClearDepth is set to 0. and nothing passes z-test.\n"
            "\n"
            "Time taken by OpenGL (sum):\n"
            "     Time taken by OpenGL rendering pipeline. The scene is rendered\n"
            "     with SoDrawStyle::INVISIBLE style. The difference to \"No Clear\"\n"
            "     rendering time is printed out.\n"
            "Time taken by OpenGL vertex transformations:\n"
            "     Time taken by the first part of OpenGL pipeline - vertex\n" 
            "     transformation. It is computed as difference between \"Outside\n"
            "     View Volume\" rendering and SoDrawStyle::INVISIBLE rendering.\n"
            "     To avoid effect of render culling that is performed in\n"
            "     separators (SoSeparator::renderCulling) and on the shapes\n"
            "     glTranslate is called to put geometry outside the view volume\n"
            "     while Open Inventor is fooled since its elements are still\n"
            "     thinking the geometry is inside the view volume. Therefore,\n"
            "     the geometry is not culled.\n"
            "Time taken by OpenGL pixel rasterizer:\n"
            "     Time taken by the second part of OpenGL pipeline - pixel\n"
            "     rasterization. The difference between \"No Clear\" and \"Outside\n"
            "     View Volume\" rendering is printed out. The effect of culling\n"
            "     is eliminated as in previous point.\n"
            "Time taken by scene graph traversal:\n"
            "     The value is meassured while rendering scene with\n"
            "     SoDrawStyle::INVISIBLE style.\n"
            "Scene animation cost:\n"
            "     By default, tests are rendered with three animation sources:\n"
            "     - realtime field updates - this keeps engines in the model\n"
            "                                running\n"
            "     - separators named "NO_CACHE_NAME" - these are considered\n"
            "       to contain non-static geometry and they are \"touched\"\n"
            "       each frame to simulate scene graph modification\n"
            "     - built-in scene spinning\n"
            "     First two animation sources are skipped during animation\n"
            "     cost test.\n"
            "Window clear time:\n"
            "     The cost of clearing the window by glClear.\n"
            "\n"
            "Please, report bugs to peciva _at fit.vutbr.cz.\n"
            "\n",
            NUM_FRAMES, WINDOW_X, WINDOW_Y, NUM_FRAMES_AUTO_CACHING);
}

////////////////////////////////////////////////////////////////////////
//
// Description:
//    Callback used to count triangles.
//

static void
countTriangleCB(void *userData, SoCallbackAction *,
                const SoPrimitiveVertex *,
                const SoPrimitiveVertex *,
                const SoPrimitiveVertex *)
//
////////////////////////////////////////////////////////////////////////
{
    int32_t *curCount = (int32_t *) userData;

    (*curCount)++;
}

////////////////////////////////////////////////////////////////////////
//
// Description:
//    Callback used to count Line Segments.
//

static void
countLinesCB(void *userData, SoCallbackAction *,
                const SoPrimitiveVertex *,
                const SoPrimitiveVertex *)
//
////////////////////////////////////////////////////////////////////////
{
    int32_t *curCount = (int32_t *) userData;

    (*curCount)++;
}


////////////////////////////////////////////////////////////////////////
//
// Description:
//    Callback used to count points.
//

static void
countPointsCB(void *userData, SoCallbackAction *,
                const SoPrimitiveVertex *)
//
////////////////////////////////////////////////////////////////////////
{
    int32_t *curCount = (int32_t *) userData;

    (*curCount)++;
}

////////////////////////////////////////////////////////////////////////
//
// Description:
//    Callback used to count nodes.
//

static SoCallbackAction::Response
countNodesCB(void *userData, SoCallbackAction *,
                const SoNode *)
//
////////////////////////////////////////////////////////////////////////
{
    int32_t *curCount = (int32_t *) userData;

    (*curCount)++;

    return SoCallbackAction::CONTINUE;
}


////////////////////////////////////////////////////////////////////////
//
// Description:
//    Counts triangles/lines/points in given graph using primitive generation,
//    returning total.
//

void
countPrimitives(SoNode *root, int32_t &numTris, int32_t &numLines, int32_t &numPoints,
                int32_t &numNodes)
//
////////////////////////////////////////////////////////////////////////
{
    numTris = 0;
    numLines = 0;
    numPoints = 0;
    numNodes = 0;
    SoCallbackAction        ca;

    ca.addPointCallback(SoShape::getClassTypeId(),
                           countPointsCB,
                           (void *) &numPoints);
    ca.addLineSegmentCallback(SoShape::getClassTypeId(),
                           countLinesCB,
                           (void *) &numLines);
    ca.addTriangleCallback(SoShape::getClassTypeId(),
                           countTriangleCB,
                           (void *) &numTris);
    ca.addPreCallback( SoNode::getClassTypeId(),
                        countNodesCB, (void *)&numNodes
                    );
    ca.apply(root);
}


//////////////////////////////////////////////////////////////
//
// Description:
//    Windows only.
//    Returns registry string from the given key and valueName.
//

#ifdef _WIN32

static TCHAR* getRegistryString(const char *key, const char *valueName)
{
    // open the registry key
    HKEY hKey;
    LONG ret = RegOpenKeyEx(HKEY_LOCAL_MACHINE,
                            key,
                            0,
                            KEY_READ,
                            &hKey);

    // key could not be opened
    if(ret != ERROR_SUCCESS)
        return NULL;

    // get registry value length
    DWORD type;
    DWORD size = 0;
    ret = RegQueryValueEx(hKey, valueName, NULL, &type, NULL, &size);

    // key could not be read
    if(ret != ERROR_SUCCESS) {
        RegCloseKey(hKey);
        return NULL;
    }
    assert(size>0);

    // get registry value
    char *string = new TCHAR[size];
    ret = RegQueryValueEx(hKey, valueName, NULL, &type, (LPBYTE)string, &size);

    // key could not be read
    if(ret != ERROR_SUCCESS) {
        delete string;
        RegCloseKey(hKey);
        return NULL;
    }

    // return value
    RegCloseKey(hKey);
    return string;
}

#endif

//////////////////////////////////////////////////////////////
//
// Description:
//    Prints hardware information.
//

static void
printHWInfo()
//
//////////////////////////////////////////////////////////////
{
#ifdef __sgi // hinv is probably present on SGI systems only. (???) PCJohn 2005-04-12
    system("hinv -c processor"); printf("\n");
    // Prints info like:
    // CPU: MIPS R4600 Processor Chip Revision: 2.0
    // FPU: MIPS R4600 Floating Point Coprocessor Revision: 2.0
    // 1 133MHZ IP22 Processor
    system("hinv -t memory"); printf("\n");
    // Prints info like:
    // Main memory size: 96 Mbytes
    // Secondary unified instruction/data cache size: 512 Kbytes on Processor 0
    // Instruction cache size: 16 Kbytes
    // Data cache size 16 Kbytes
    system("hinv -c graphics"); printf("\n");
    // Prints info like:
    // Graphics board: Indy 8-bit
#elif !defined(_WIN32)
    // Linux, Unixes,...
    printf("Processor(s):\n");
    system("grep -i \"model name\" /proc/cpuinfo | sed s/[^:]*:[\\ ]*/\"    \"/g");
    printf("Memory:\n");
    system("grep -i \"MemTotal\"   /proc/meminfo | sed s/MemTotal[\\ ]*:[\\ ]*/\"    \"/g");
    printf("Graphics card:\n");
    system("glxinfo | grep -i '\\(OpenGL.*vendor\\|OpenGL.*renderer\\|OpenGL.*version\\)' | sed s/^/\"    \"/g");
    printf("\n");
#else
    // Windows
    // Let's use info stored in registry

    // processor
    printf("Processor(s):\n");

    int numCPUs = 0;
    char cpuKeyName[] = "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\??";
    char *numP = strstr(cpuKeyName, "?"); 
    do {
        if (numCPUs < 10) {
            numP[0] = '0' + numCPUs;
            numP[1] = 0;
        } else {
            numP[0] = '0' + numCPUs/10;
            numP[1] = '0' + numCPUs%10;
        }

        // FIXME: it is known, that Win9x uses different value string:
        // instead of "ProcessorNameString" it uses "Identifier".
        // This should be implemented and tested when Win9x machine will be available.
        // PCJohn 2005-11-13
        char *cpuString = getRegistryString(cpuKeyName,
                                            "ProcessorNameString");
        if (cpuString) {
            
            // skip spaces
            char *p = cpuString;
            while (*p == ' ')  p++;
            
            printf("    %s\n", p);
            delete[] cpuString;
        
        } else {
            if (numCPUs == 0)
                printf("    %s\n", "<detection failed>");
            break;
        }

        numCPUs++;
    } while (numCPUs < 100);

    // memory
    MEMORYSTATUS ms;
    ms.dwLength = sizeof(ms);
    GlobalMemoryStatus(&ms);

    printf("Memory:\n");
    printf("    %iKB\n", ms.dwTotalPhys/1024);

    // graphics card
    char *videoCardName = NULL;
    char *registryPath = getRegistryString("HARDWARE\\DEVICEMAP\\VIDEO",
                                           "\\Device\\Video0");
    if (registryPath) {
        // registryPath is now something like
        // \Registry\Machine\System\CurrentControlSet\Control\Video\{6F576E66-7EBD-4106-9232-B72F44F8876E}\0000
        char *tmp;
        char *realPath = registryPath;
        
        // skip '\'
        if (*registryPath != 0) {
            tmp = registryPath+1;
            // skip Registry word
            tmp = strstr(tmp, "\\");
            if (tmp != NULL && *tmp != 0) {
                // skip '\'
                tmp++;
                // skip Machine word
                tmp = strstr(tmp, "\\");
                if (tmp != NULL && *tmp != 0)
                    realPath = tmp+1;
            }
        }
        videoCardName = getRegistryString(realPath,
                                          "Device Description");
        delete registryPath;
    }

    printf("Video card:\n");
    printf("    %s\n", videoCardName ? videoCardName : "<detection failed>");
    printf("    OpenGL vendor: %s\n"
           "    OpenGL renderer: %s\n"
           "    OpenGL version: %s\n",
           glGetString(GL_VENDOR), glGetString(GL_RENDERER), glGetString(GL_VERSION));

    delete videoCardName;
#endif
}

//////////////////////////////////////////////////////////////
//
// Description:
//    Parses command line arguments, setting options.
//

static SbBool
parseArgs(int argc, char *argv[], Options &options)
//
//////////////////////////////////////////////////////////////
{
    SbBool ok = TRUE;
    int    c, curArg;

    // Initialize options
    options.showBars       = FALSE;
    options.numFrames      = NUM_FRAMES;
    options.inputFileName  = NULL;
    options.windowX        = WINDOW_X;
    options.windowY        = WINDOW_Y;
    options.useProfiler    = FALSE;
    options.fullProfilerResults = FALSE;
    options.hasLights      = FALSE;
    options.hasTextures    = FALSE;
    options.noClear        = FALSE;
    options.zbufferSwapping = FALSE;
    options.zbufferNever   = FALSE;
    options.noMaterials    = FALSE;
    options.noTextures     = FALSE;
    options.oneTexture     = FALSE;
    options.noXforms       = FALSE;
    options.outsideViewVolume = FALSE;
    options.outsideVvByOpenGL = FALSE;
    options.invisible      = FALSE;
    options.freeze         = FALSE;
    options.noLights       = FALSE;
    options.newRootWanted  = FALSE;

    while ((c = getopt(argc, argv, "bf:w:pthH")) != -1) {
        switch (c) {
          case 'b':
            options.showBars = TRUE;
            break;
          case 'f':
            options.numFrames = atoi(optarg);
            break;
          case 'w':
            sscanf(optarg, " %d , %d", &options.windowX, &options.windowY);
            break;
          case 'p':
            options.useProfiler = TRUE;
            break;
          case 't':
            options.useProfiler = TRUE;
            options.fullProfilerResults = TRUE;
            break;
          case 'h':
            printUsage();
            exit(99);
          case 'H':
            printLargeUsage();
            exit(99);
          default:
            ok = FALSE;
            break;
        }
    }

    curArg = optind;

    // Check for input filename at end
    if (curArg < argc)
        options.inputFileName = argv[curArg++];

    // Extra arguments? Error!
    if (curArg < argc)
        ok = FALSE;

    return ok;
}


//////////////////////////////////////////////////////////////
//
// Description:
//    Callback used by openWindow() and by main()
//

#ifndef _WIN32
static Bool
waitForNotify(Display *, XEvent *e, char *arg)
//
//////////////////////////////////////////////////////////////
{
    return ((e->type == MapNotify) || (e->type == UnmapNotify)) &&
        (e->xmap.window == (Window) arg);
}
#endif


//////////////////////////////////////////////////////////////
//
// Description:
//    Kills the GL/X window.
//

#ifdef _WIN32

static void
killWindow()
{
  if (!hWnd) return;

  if (fullscreen)                    // Are We In Fullscreen Mode?
  {
    ChangeDisplaySettings(NULL,0);          // If So Switch Back To The Desktop
    ShowCursor(TRUE);                // Show Mouse Pointer
  }

  if (hRC)                      // Do We Have A Rendering Context?
  {
    if (!wglMakeCurrent(NULL,NULL))          // Are We Able To Release The DC And RC Contexts?
    {
      MessageBox(NULL,"Release Of DC And RC Failed.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
    }

    if (!wglDeleteContext(hRC))            // Are We Able To Delete The RC?
    {
      MessageBox(NULL,"Release Rendering Context Failed.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
    }
    hRC=NULL;                    // Set RC To NULL
  }

  if (hDC && !ReleaseDC(hWnd,hDC))          // Are We Able To Release The DC
  {
    MessageBox(NULL,"Release Device Context Failed.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
    hDC=NULL;                    // Set DC To NULL
  }

  if (hWnd && !DestroyWindow(hWnd))          // Are We Able To Destroy The Window?
  {
    MessageBox(NULL,"Could Not Release hWnd.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
    hWnd=NULL;                    // Set hWnd To NULL
  }

  if (!UnregisterClass("OpenInventor",hInstance))      // Are We Able To Unregister Class
  {
    MessageBox(NULL,"Could Not Unregister Class.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
    hInstance=NULL;                  // Set hInstance To NULL
  }
}

#else

static void
killWindow()
{
    XEvent         event;
    XUnmapWindow(display, window);
    XIfEvent(display, &event, waitForNotify, (char *) window);
}

#endif


//////////////////////////////////////////////////////////////
//
// Description:
//    Creates and initializes GL/X window.
//

#ifdef _WIN32

LRESULT CALLBACK WndProc(HWND hWnd, UINT msgId, WPARAM wParam, LPARAM lParam)
{
    switch (msgId) {
    case WM_CLOSE: exit(-1);
    }
    return DefWindowProc(hWnd, msgId, wParam, lParam);
}

static void
openWindow(char *title, unsigned int width, unsigned int height, 
           int bits, bool fullscreenRequest)
//
//////////////////////////////////////////////////////////////
{
  GLuint    PixelFormat;      // Holds The Results After Searching For A Match
  WNDCLASS  wc;            // Windows Class Structure
  DWORD     dwExStyle;        // Window Extended Style
  DWORD     dwStyle;        // Window Style
  RECT      WindowRect;        // Grabs Rectangle Upper Left / Lower Right Values
  WindowRect.left   =(long)0;      // Set Left Value To 0
  WindowRect.right  =(long)width;    // Set Right Value To Requested Width
  WindowRect.top    =(long)0;        // Set Top Value To 0
  WindowRect.bottom =(long)height;    // Set Bottom Value To Requested Height

  fullscreen=fullscreenRequest;      // Set The Global Fullscreen Flag

  hInstance         = GetModuleHandle(NULL);        // Grab An Instance For Our Window
  wc.style          = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;  // Redraw On Size, And Own DC For Window.
  wc.lpfnWndProc    = (WNDPROC) WndProc;                   // WndProc Handles Messages
  wc.cbClsExtra     = 0;                  // No Extra Window Data
  wc.cbWndExtra     = 0;                  // No Extra Window Data
  wc.hInstance      = hInstance;              // Set The Instance
  wc.hIcon          = LoadIcon(NULL, IDI_WINLOGO);      // Load The Default Icon
  wc.hCursor        = LoadCursor(NULL, IDC_ARROW);      // Load The Arrow Pointer
  wc.hbrBackground  = NULL;                  // No Background Required For GL
  wc.lpszMenuName   = NULL;                  // We Don't Want A Menu
  wc.lpszClassName  = "OpenInventor";        // Set The Class Name

  if (!RegisterClass(&wc))                  // Attempt To Register The Window Class
  {
    MessageBox(NULL,"Failed To Register The Window Class.","ERROR",MB_OK|MB_ICONEXCLAMATION);
    exit(-1);                      // Exit app
  }
  
  if (fullscreen)                        // Attempt Fullscreen Mode?
  {
    DEVMODE dmScreenSettings;                // Device Mode
    memset(&dmScreenSettings,0,sizeof(dmScreenSettings));  // Makes Sure Memory's Cleared
    dmScreenSettings.dmSize=sizeof(dmScreenSettings);    // Size Of The Devmode Structure
    dmScreenSettings.dmPelsWidth  = width;        // Selected Screen Width
    dmScreenSettings.dmPelsHeight  = height;        // Selected Screen Height
    dmScreenSettings.dmBitsPerPel  = bits;          // Selected Bits Per Pixel
    dmScreenSettings.dmFields=DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;

    // Try To Set Selected Mode And Get Results.  NOTE: CDS_FULLSCREEN Gets Rid Of Start Bar.
    if (ChangeDisplaySettings(&dmScreenSettings,CDS_FULLSCREEN)!=DISP_CHANGE_SUCCESSFUL)
    {
      // If The Mode Fails, Offer Two Options.  Quit Or Use Windowed Mode.
      if (MessageBox(NULL,"The Requested Fullscreen Mode Is Not Supported By\nYour Video Card. Use Windowed Mode Instead?","NeHe GL",MB_YESNO|MB_ICONEXCLAMATION)==IDYES)
      {
        fullscreen=FALSE;    // Windowed Mode Selected.  Fullscreen = FALSE
      }
      else
      {
        // Pop Up A Message Box Letting User Know The Program Is Closing.
        MessageBox(NULL,"Program Will Now Close.","ERROR",MB_OK|MB_ICONSTOP);
        exit(-1);                  // Exit app
      }
    }
  }

  if (fullscreen)                        // Are We Still In Fullscreen Mode?
  {
    dwExStyle=WS_EX_APPWINDOW;                // Window Extended Style
    dwStyle=WS_POPUP;                    // Windows Style
    ShowCursor(FALSE);                    // Hide Mouse Pointer
  }
  else
  {
    dwExStyle=WS_EX_APPWINDOW | WS_EX_WINDOWEDGE;      // Window Extended Style
    dwStyle=WS_OVERLAPPEDWINDOW;              // Windows Style
  }

  AdjustWindowRectEx(&WindowRect, dwStyle, FALSE, dwExStyle);    // Adjust Window To True Requested Size

  // Create The Window
  if (!(hWnd=CreateWindowEx(  dwExStyle,              // Extended Style For The Window
                "OpenInventor",              // Class Name
                title,                // Window Title
                dwStyle |              // Defined Window Style
                WS_CLIPSIBLINGS |          // Required Window Style
                WS_CLIPCHILDREN,          // Required Window Style
                0, 0,                // Window Position
                WindowRect.right-WindowRect.left,  // Calculate Window Width
                WindowRect.bottom-WindowRect.top,  // Calculate Window Height
                NULL,                // No Parent Window
                NULL,                // No Menu
                hInstance,              // Instance
                NULL)))                // Dont Pass Anything To WM_CREATE
  {
    killWindow();                // Reset The Display
    MessageBox(NULL,"Window Creation Error.","ERROR",MB_OK|MB_ICONEXCLAMATION);
    exit(-1);                // Exit app
  }

  static  PIXELFORMATDESCRIPTOR pfd=        // pfd Tells Windows How We Want Things To Be
  {
    sizeof(PIXELFORMATDESCRIPTOR),        // Size Of This Pixel Format Descriptor
    1,                      // Version Number
    PFD_DRAW_TO_WINDOW |            // Format Must Support Window
    PFD_SUPPORT_OPENGL,            // Format Must Support OpenGL
    PFD_TYPE_RGBA,                // Request An RGBA Format
    bits,                    // Select Our Color Depth
    0, 0, 0, 0, 0, 0,              // Color Bits Ignored
    0,                      // No Alpha Buffer
    0,                      // Shift Bit Ignored
    0,                      // No Accumulation Buffer
    0, 0, 0, 0,                  // Accumulation Bits Ignored
    16,                      // 16Bit Z-Buffer (Depth Buffer)  
    0,                      // No Stencil Buffer
    0,                      // No Auxiliary Buffer
    PFD_MAIN_PLANE,                // Main Drawing Layer
    0,                      // Reserved
    0, 0, 0                    // Layer Masks Ignored
  };
  
  if (!(hDC=GetDC(hWnd)) ||                         // Did We Get A Device Context?
      !(PixelFormat=ChoosePixelFormat(hDC,&pfd)) || // Did Windows Find A Matching Pixel Format?
      !SetPixelFormat(hDC,PixelFormat,&pfd) ||      // Are We Able To Set The Pixel Format?
      !(hRC=wglCreateContext(hDC)) ||               // Are We Able To Get A Rendering Context?
      !wglMakeCurrent(hDC,hRC))                     // Try To Activate The Rendering Context
  {
    killWindow();                // Reset The Display
    MessageBox(NULL, "Can not initialize OpenInventor window.","ERROR",MB_OK|MB_ICONEXCLAMATION);
    exit(-1);                // Exit app
  }

  glEnable(GL_DEPTH_TEST);
  glClearColor(0.5, 0.5, 0.5, 1);
}

static void
showWindow()
{
  ShowWindow(hWnd,SW_SHOW);            // Show The Window
  SetForegroundWindow(hWnd);            // Slightly Higher Priority
  SetFocus(hWnd);                  // Sets Keyboard Focus To The Window

  // clear the graphics window and depth planes
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glFinish();
}

#else

static void
openWindow(Display *&display, Window &window, unsigned int windowX,
           unsigned int windowY, char *title)
//
//////////////////////////////////////////////////////////////
{
    XVisualInfo           *vi;
    Colormap              cmap;
    XSetWindowAttributes  swa;
    GLXContext            cx;
    XEvent                event;
    static int  attributeList[] = {
        GLX_RGBA,
        GLX_RED_SIZE, 1,
        GLX_GREEN_SIZE, 1,
        GLX_BLUE_SIZE, 1,
        GLX_DEPTH_SIZE, 1,
        None,                // May be replaced w/GLX_DOUBLEBUFFER
        None,
    };

    display = XOpenDisplay(0);
    vi   = glXChooseVisual(display,
                           DefaultScreen(display),
                           attributeList);
    cx   = glXCreateContext(display, vi, 0, GL_TRUE);
    cmap = XCreateColormap(display,
                           RootWindow(display, vi->screen),
                           vi->visual, AllocNone);
    swa.colormap        = cmap;
    swa.border_pixel        = 0;
    swa.event_mask        = StructureNotifyMask;
    window = XCreateWindow(display,
           RootWindow(display, vi->screen),
           10, 10, windowX, windowY,
           0, vi->depth, InputOutput, vi->visual,
           (CWBorderPixel | CWColormap | CWEventMask), &swa);

    // Make the window appear in the lower left corner
    XSizeHints *xsh = XAllocSizeHints();
    xsh->flags = USPosition;
    XSetWMNormalHints(display, window, xsh);
    XSetStandardProperties(display, window, title, title, None, 0, 0, 0);
    XFree(xsh);

    XMapWindow(display, window);
    XIfEvent(display, &event, waitForNotify, (char *) window);
    glXMakeCurrent(display, window, cx);

    glEnable(GL_DEPTH_TEST);
    glClearColor(0.5, 0.5, 0.5, 1);
    
    // clear the graphics window and depth planes
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

static void
showWindow()
{
}
#endif


//////////////////////////////////////////////////////////////
//
// Description:
//    Creates and returns scene graph containing given
//    scene. Adds a perspective camera, a directional
//    light, and a transform.
//    Returns NULL on error.
//

static SoSeparator *
setUpGraph(const SbViewportRegion &vpReg,
           SoInput *sceneInput,
           Options &options)
//
//////////////////////////////////////////////////////////////
{

    // Create a root separator to hold everything. Turn
    // caching off, since the transformation will blow
    // it anyway.
    SoSeparator *root = (SoSeparator*)SoSeparator::getClassTypeId().createInstance();
    root->ref();
    root->renderCaching = SoSeparator::OFF;

    // Add a camera to view the scene
    SoPerspectiveCamera *camera = (SoPerspectiveCamera*)SoPerspectiveCamera::getClassTypeId().createInstance();
    camera->setName(SCENE_CAMERA_NAME);
    root->addChild(camera);

    // Add a transform node to spin the scene
    SoTransform *sceneTransform = (SoTransform*)SoTransform::getClassTypeId().createInstance();
    sceneTransform->setName(SCENE_XFORM_NAME);
    root->addChild(sceneTransform);

    // Read and add input scene graph
    SoSeparator *inputRoot = SoDB::readAll(sceneInput);
    if (inputRoot == NULL)
        FILE_READ_ERROR(options.inputFileName);
    root->addChild(inputRoot);

    SoPath         *path;
    SoGroup        *parent, *group;
    SoSearchAction        act;

    // expand out all File nodes and replace them with groups
    //    containing the children
    SoFile         *fileNode;
    act.setType(SoFile::getClassTypeId());
    act.setInterest(SoSearchAction::FIRST);
    act.apply(inputRoot);
    while ((path = act.getPath()) != NULL) {
        fileNode = (SoFile *) path->getTail();
        path->pop();
        parent = (SoGroup *) path->getTail();
        group = fileNode->copyChildren();
        if (group) {
            parent->replaceChild(fileNode, group);
            // apply action again and continue
            act.apply(inputRoot);
        }
    }

    // expand out all node kits and replace them with groups
    //    containing the children
    SoBaseKit        *kitNode;
    SoChildList        *childList;
    act.setType(SoBaseKit::getClassTypeId());
    act.setInterest(SoSearchAction::FIRST);
    act.apply(inputRoot);
    while ((path = act.getPath()) != NULL) {
        kitNode = (SoBaseKit *) path->getTail();
        path->pop();
        parent = (SoGroup *) path->getTail();
        group = (SoGroup*)SoGroup::getClassTypeId().createInstance();
        childList = kitNode->getChildren();
        for (int i=0; i<childList->getLength(); i++) 
            group->addChild((*childList)[i]);
        parent->replaceChild(kitNode, group);
        act.apply(inputRoot);
    }

    // check to see if there are any lights
    // if no lights, add a directional light to the scene
    act.setType(SoLight::getClassTypeId());
    act.setInterest(SoSearchAction::FIRST);
    act.apply(inputRoot);
    if (act.getPath() == NULL) { // no lights
        SoDirectionalLight *light = (SoDirectionalLight*)SoDirectionalLight::getClassTypeId().createInstance();
        root->insertChild(light, 1);
    }
    else 
        options.hasLights = TRUE;

    // check to see if there are any 2D texures in the scene
    int numTextures2, numTexture2references, numTexture2nodes;
    act.setType(SoTexture2::getClassTypeId());
    act.setInterest(SoSearchAction::ALL);
    act.apply(inputRoot);
    SoPathList &pl = act.getPaths();
    numTexture2references = pl.getLength();
    int i,j;
    SbPList plist;
    for (i=0; i<numTexture2references; i++) {
        SoNode *n = pl[i]->getTail();
        if (plist.find(n) == -1)
            plist.append(n);
    }
    numTexture2nodes = plist.getLength();
    numTextures2 = numTexture2nodes;
    for (i=0; i<numTextures2; i++) {
        const char *name1 = ((SoTexture2*)plist[i])->filename.getValue().getString();
        if (name1 == NULL || strlen(name1) == 0)
            continue;
        for (j=i+1; j<numTextures2; j++) {
            const char *name2 = ((SoTexture2*)plist[i])->filename.getValue().getString();
            if (name2 == NULL) continue;
            if (strcmp(name1, name2) == 0) {
                plist.removeFast(j);
                j--;
                numTextures2--;
            }
        }
    }

    // check to see if there are any 3D texures in the scene
    int numTextures3, numTexture3references;
    act.setType(SoTexture3::getClassTypeId());
    act.apply(inputRoot);
    pl = act.getPaths();
    numTexture3references = pl.getLength();
    plist.truncate(0);
    for (i=0; i<numTexture3references; i++) {
        SoNode *n = pl[i]->getTail();
        if (plist.find(n) == -1)
            plist.append(n);
    }
    numTextures3 = plist.getLength(); // not looking here for the same names, since users usually
                                      // takes care about huge SoTexture3 memory requirements
                                      // and does not put them into the file multiple times

    options.hasTextures = numTextures2+numTextures3 > 0;

    camera->viewAll(root, vpReg);

    // print out information about the scene graph

    int32_t numTris, numLines, numPoints, numNodes;
    countPrimitives( inputRoot, numTris, numLines, numPoints, numNodes );
    printf("Number of nodes in scene graph:     %d\n", numNodes );
    printf("Number of triangles in scene graph: %d\n", numTris );
    printf("Number of lines in scene graph:     %d\n", numLines );
    printf("Number of points in scene graph:    %d\n", numPoints );
    printf("Number of textures in scene graph:  %d\n\n", numTextures2+numTextures3 );

    // Make the center of rotation the center of
    // the scene
    SoGetBoundingBoxAction        bba(vpReg);
    bba.apply(root);
    sceneTransform->center = bba.getBoundingBox().getCenter();

    return root;
}


//////////////////////////////////////////////////////////////
//
// Description:
//    Replaces all group nodes in the graph with new ones
//    to reset autocaching threshold in separators.  Recursive.
//

SoNode *
replaceSeparators(SoNode *root)
//
//////////////////////////////////////////////////////////////
{
    //
    // if it's a group, make a new group and copy its
    //  children over
    //
    if (root->isOfType(SoGroup::getClassTypeId())) {
        SoGroup *group = (SoGroup *) root;
        SoGroup *newGroup = (SoGroup *) group->getTypeId().createInstance();
        newGroup->SoNode::copyContents(group, FALSE);

        int        i;
        for (i=0; i<group->getNumChildren(); i++) {
            SoNode *child = replaceSeparators(group->getChild(i));
            newGroup->addChild(child);
        }
        return newGroup;
    }
    //
    // if not a group, return the node
    //
    else 
        return root;
}

//////////////////////////////////////////////////////////////
//
// Description:
//    Removes nodes of the given type from the given graph.
//

void
removeNodes(SoGroup *root, SoType type)
//
//////////////////////////////////////////////////////////////
{
    SoSearchAction act;
    act.setInterest(SoSearchAction::ALL);
    act.setType(type);
    act.apply(root);
    SoPathList &paths = act.getPaths();
    for (int i = 0; i < paths.getLength(); i++) {
        SoNode *kid = paths[i]->getTail();
        paths[i]->pop();
        SoGroup *parent = (SoGroup *)paths[i]->getTail();
        parent->removeChild(kid);
    }
}

//////////////////////////////////////////////////////////////
//
// Description:
//    Rotates the scene directly by OpenGL to hide
//    the effect to Open Inventor.
//

static void
rotateByGL(void *userdata, SoAction *action)
//
//////////////////////////////////////////////////////////////
{
  if (action->isOfType(SoGLRenderAction::getClassTypeId())) {
    float shift = *((float*)&userdata);
    glTranslatef(0.f, 0.f, shift);
  }
}

//////////////////////////////////////////////////////////////
//
// Description:
//    Returns the time taken PER FRAME to render the scene 
//    graph anchored at root
//    Different types of rendering performance are measured
//    depending on options
//    

static float
timeRendering(Options &options,
              const SbViewportRegion &vpr,
              SoSeparator *&root)
//
//////////////////////////////////////////////////////////////
{
    SbTime              timeDiff, startTime;
    int                 frameIndex;
    SoTransform         *sceneTransform;
    SoGLRenderAction    ra(vpr);
    SoNodeList          noCacheList;
    SoSeparator         *newRoot;

    //
    // reset autocaching threshold before each experiment
    //   done by replacing every separator in the scene graph
    //   with a new one
    //
    newRoot = (SoSeparator *) replaceSeparators(root);
    newRoot->ref();
    newRoot->renderCaching = SoSeparator::OFF;

    // get a list of separators marked as being touched by the application
    newRoot->getByName(NO_CACHE_NAME, noCacheList);

    // find the transform node that spins the scene
    SoNodeList        xformList;
    newRoot->getByName(SCENE_XFORM_NAME, xformList);
    sceneTransform = (SoTransform *) xformList[0];

    // find the scene camera
    SoNodeList cameraList;
    newRoot->getByName(SCENE_CAMERA_NAME, cameraList);
    SoCamera *camera = (SoCamera*)cameraList[0];
    SbString savedCameraData;


    if (options.noMaterials) {  // nuke material node
        removeNodes(newRoot, SoMaterial::getClassTypeId());
        removeNodes(newRoot, SoPackedColor::getClassTypeId());
        removeNodes(newRoot, SoBaseColor::getClassTypeId());
    }

    if (options.noXforms) {  // nuke transforms
        removeNodes(newRoot, SoTransformation::getClassTypeId());

        // reinsert transform node that spins scene
        newRoot->insertChild(sceneTransform, root->findChild(sceneTransform));

        // save camera data
        camera->get(savedCameraData);
        camera->viewAll(newRoot, vpr);
    }

    if (options.noTextures || options.oneTexture) {  // override texture node

        removeNodes(newRoot, SoTexture2::getClassTypeId());
        removeNodes(newRoot, SoTexture3::getClassTypeId());

        if (options.oneTexture) {
            // texture node with simple texture
            static unsigned char img[] = {
                255, 255, 0, 0,
                255, 255, 0, 0,
                0, 0, 255, 255,
                0, 0, 255, 255
                };
            SoTexture2 *overrideTex = (SoTexture2*)SoTexture2::getClassTypeId().createInstance();
            overrideTex->image.setValue(SbVec2s(4, 4), 1, img);
            newRoot->insertChild(overrideTex, 1);
        }
    }

#if 0 // Old SGI code: draw getometry as points and get "pipe" or "vertex" performance.
      //
      // That probably worked on their machines, but todays accelerators often do not
      // accelerate point rendering, so it is often slower than normal rendering.
      // Therefore, it can not be used. PCJohn 2006-02-18
    if (options.noFill) {  // draw as points
        SoDrawStyle *overrideFill = (SoDrawStyle*)SoDrawStyle::getClassTypeId().createInstance();
        overrideFill->style.setValue(SoDrawStyle::POINTS);
        overrideFill->lineWidth.setIgnored(TRUE);
        overrideFill->linePattern.setIgnored(TRUE);
        overrideFill->setOverride(TRUE);
        newRoot->insertChild(overrideFill, 0);

        // cull backfaces so that extra points don't get drawn
        SoShapeHints *cullBackfaces = (SoShapeHints*)SoShapeHints::getClassTypeId().createInstance();
        cullBackfaces->shapeType = SoShapeHints::SOLID;
        cullBackfaces->vertexOrdering = SoShapeHints::COUNTERCLOCKWISE;
        cullBackfaces->setOverride(TRUE);
        newRoot->insertChild(cullBackfaces, 0);
    }
#else // Rotate the camera to make the model to be completely outsize view volume.
      // In such way, the "pipe" or "vertex" performance can be meassured.
      // PCJohn 2006-02-18
    if (options.outsideViewVolume) {
        // save camera data and change the orientation
        if (savedCameraData.getLength() == 0)
            camera->get(savedCameraData);
        camera->orientation = camera->orientation.getValue() * SbRotation(SbVec3f(0.f,1.f,0.f), float(M_PI));
    }

    if (options.outsideVvByOpenGL) {
        SoCallback *callback = new SoCallback;
        assert(!options.outsideViewVolume && "outsideVvByOpenGL is not supported while outsideViewVolume is set.");
        float shift = 2.f * (camera->position.getValue()[2] - sceneTransform->center.getValue()[2]);
        callback->setCallback(rotateByGL, *((void**)&shift));
        newRoot->insertChild(callback, newRoot->findChild(camera)+1);
    }
#endif

    SoDrawStyle *overrideInvisible;
    if (options.invisible) {  // draw invisible
        overrideInvisible = (SoDrawStyle*)SoDrawStyle::getClassTypeId().createInstance();
        overrideInvisible->style.setValue(SoDrawStyle::INVISIBLE);
        overrideInvisible->pointSize.setIgnored(TRUE);
        overrideInvisible->lineWidth.setIgnored(TRUE);
        overrideInvisible->linePattern.setIgnored(TRUE);
        overrideInvisible->setOverride(TRUE);
        newRoot->insertChild(overrideInvisible, 0);
    }

    if (options.noLights) {  // set lighting model to base color
        SoLightModel *baseColor = (SoLightModel*)SoLightModel::getClassTypeId().createInstance();
        baseColor->model = SoLightModel::BASE_COLOR;
        newRoot->insertChild(baseColor, 0);
    }

    // z-buffer setup
    assert(!options.zbufferSwapping || !options.zbufferNever &&
           "zbufferSwapping and zbufferNever can not be switched on together.");
    if (options.zbufferSwapping) {
        glDepthRange(0., 0.5);
        glClearDepth(0.5);
    } else {
        // default z-buffer settings
        glDepthRange(0., 1.);
        glClearDepth(options.zbufferNever ? 0. : 1.);
    }

    // clear the window
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    for (frameIndex = 0; ; frameIndex++) {

        // wait till autocaching has kicked in then start timing
        if (frameIndex == NUM_FRAMES_AUTO_CACHING) {
            glFinish(); // flush the pipeline before the meassurement starts
            startTime = SbTime::getTimeOfDay();
        }

        // stop timing and exit loop when requisite number of
        //    frames have been drawn
        if (frameIndex == options.numFrames + NUM_FRAMES_AUTO_CACHING) {
            glFinish();
            timeDiff = SbTime::getTimeOfDay() - startTime;
            break;
        }

        // if not frozen, update realTime and destroy labelled caches
        if (! options.freeze) { 

            // update realTime 
            SoSFTime *realTime = (SoSFTime *) SoDB::getGlobalField("realTime");
            realTime->setValue(SbTime::getTimeOfDay());

            // touch the separators marked NoCache 
            for (int i=0; i<noCacheList.getLength(); i++)
                ((SoSeparator *) noCacheList[i])->getChild(0)->touch();
        }

        // Rotate the scene
        if (!options.zbufferSwapping)
            sceneTransform->rotation.setValue(SbVec3f(1, 1, 1), 
                                              frameIndex * 2 * float(M_PI) / options.numFrames);
        else
            // rotate only each second frame
            if ((frameIndex & 0x01) == 0)
                sceneTransform->rotation.setValue(SbVec3f(1, 1, 1), 
                                                  frameIndex * 2 * float(M_PI) / options.numFrames);

        if (! options.noClear)
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        ra.apply(newRoot);

        if (options.zbufferSwapping)
            if ((frameIndex & 0x01) == 0) {
                glDepthRange(1., 0.5);
                glClearDepth(0.5);
            } else {
                glDepthRange(0., 0.5);
                glClearDepth(0.5);
            }

        // once per 100ms process all windows messages
#ifdef _WIN32
        double ct = SbTime::getTimeOfDay().getValue();
        static double lastMsgTime = ct;
        if (ct - lastMsgTime > 0.1) {
            lastMsgTime = ct;
            MSG msg;
            while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) {
                TranslateMessage(&msg);
                DispatchMessage(&msg);
            }
        }
#endif
    }

    // restore original camera setup
    if (savedCameraData.getLength() != 0) {
        camera->setToDefaults();
        SbBool ok = camera->set(savedCameraData.getString());
        assert(ok);
    }

    // Get rid of newRoot
    if (options.newRootWanted)
        options.newRoot = newRoot;
    else
        newRoot->unref();

    return float(timeDiff.getValue() / options.numFrames);
}



#include "BarChart.h"

//#ifdef _WIN32
//static void interactionStartCallback(void * data, SoWinViewer * viewer)
//#else
//static void interactionStartCallback(void * data, SoXtViewer * viewer)
//#endif
static void interactionStartCallback(void * data, SoIvViewer * viewer)
{
  viewer->setAntialiasing(TRUE, 1);
}

//#ifdef _WIN32
//static void interactionFinishCallback(void * data, SoWinViewer * viewer)
//#else
//static void interactionFinishCallback(void * data, SoXtViewer * viewer)
//#endif
static void interactionFinishCallback(void * data, SoIvViewer * viewer)
{
  if (viewer->getAccumulationBuffer()) // FIXME: is there a way of handling accumulation 
                                       // buffer absence? PCJohn 2006-05-05
    viewer->setAntialiasing(TRUE, 9);
}

//////////////////////////////////////////////////////////////
//
// Description:
//    Uses Chris Marrin's BarChart node to display timing info
//

static void
drawBar(float asisTime, float noClearTime, float noMatTime,
        float noXformTime, float noTexTime, float oneTexTime,
        float noLitTime, float outsideVvTime, float invisTime, float freezeTime)
//
//////////////////////////////////////////////////////////////
{
    float barValues[9];
    static const char *barXLabels[] = { "Total", "Clear", "Trav", 
                                  "Mat", "Xform", "Tex",
                                  "TMgmt", "Lit", "OpenGL" };
    static const char *barYLabels[] = { "milliseconds/frame" };
    int i;

//#ifdef _WIN32
//    HWND barWindow = SoWin::init("Timing display");
//#else
//    Widget barWindow = SoXt::init("Timing display");
//#endif

    SO_WIDGET barWindow = SO_TOOLKIT::init("Timing display");
    
    BarChart::initClass();

    SoSeparator *root = new SoSeparator;
    SoTransform *xform = new SoTransform;
    BarChart *bar = new BarChart;

    root->ref();
    root->addChild(xform);
    root->addChild(bar);

    xform->scaleFactor.setValue(2.0, 1.0, 0.5);
    xform->rotation.setValue(SbVec3f(0,1,0), -float(M_PI)/36); // rotate by 5 degrees

    barValues[0] = asisTime;                    // Total
    barValues[1] = asisTime - noClearTime;      // Clear
    barValues[2] = invisTime;                   // Trav
    barValues[3] = noClearTime - noMatTime;     // Mat
    barValues[4] = noClearTime - noXformTime;   // Xform
    barValues[5] = oneTexTime - noTexTime;      // Tex
    barValues[6] = noClearTime - oneTexTime;    // TMgmt
    barValues[7] = noClearTime - noLitTime;     // Lit
#if 0 // FIXME: Meassure Pipe and Fill time. PCJohn 2006-05-05
    barValues[8] = outsideVvTime - invisTime;   // Pipe
    barValues[9] = noClearTime - outsideVvTime; // Fill
#else
    barValues[8] = noClearTime - invisTime;     // OpenGL
#endif

    for (i=1; i<9; i++) {
        bar->valueColors.set1Value(i, 1, 1, 0, 0);
        bar->xLabelColors.set1Value(i, 1, 1, 0, 0);
        if (barValues[i] < 0) barValues[i] = 0;
        barValues[i] *= 1e3; // make the result in ms
    }
    barValues[0] *= 1e3; // make the result in ms
    bar->values.setValues(0, 9, barValues);
    bar->xLabels.setValues(0, 9, barXLabels);
    bar->yLabels.setValues(0, 1, barYLabels);
    bar->xDimension = 9;
    bar->yDimension = 1;
    bar->minValue = 0.0;
    bar->maxValue = barValues[0];
    bar->xLabelScale.setValue(0.6f, 1, 1);
    bar->yLabelScale.setValue(2, 1, 1);
    bar->zLabelIncrement = barValues[0] / 4;
        
//#ifdef _WIN32
//    SoWinExaminerViewer *viewer = new SoWinExaminerViewer(barWindow);
//#else
//    SoXtExaminerViewer *viewer = new SoXtExaminerViewer(barWindow);
//#endif
    SoIvExaminerViewer *viewer = new SoIvExaminerViewer(barWindow);
    interactionFinishCallback(NULL, viewer);
    viewer->addStartCallback(interactionStartCallback);
    viewer->addFinishCallback(interactionFinishCallback);
    viewer->setTitle("Timing Display");
    viewer->setSceneGraph(root);
    viewer->show();
    
//#ifdef _WIN32
//    SoWin::show(barWindow);
//    SoWin::mainLoop(); 
//#else
//    SoXt::show(barWindow);
//    SoXt::mainLoop(); 
//#endif
    SO_TOOLKIT::show(barWindow);
    SO_TOOLKIT::mainLoop();
}



//////////////////////////////////////////////////////////////
//
// Description:
//    Mainline
//

int main(int argc, char **argv)
//
//////////////////////////////////////////////////////////////
{
    // This precomputes correct program name from argv[0],
    // because using argv[0] for program name is not a good solution on Windows.
    updateProgName(argv[0]);


    Options      options;
    SoSeparator  *root;
    float        asisTime, noClearTime, noMatTime,  noXformTime,
                 noTexTime, oneTexTime, noLitTime, outsideVvTime, outsideVvNoCullTime,
                 zCulledTime, invisTime, freezeTime;

    // Init Inventor
    SoInteraction::init();

    // Parse arguments
    if (! parseArgs(argc, argv, options)) {
        printUsage();
        return 1;
    }

    // Create and initialize window
    // note: Window have to be created before the parseArgs
    //       because hardware info needs valid OpenGL window.
#ifdef _WIN32
    openWindow(argv[0], options.windowX, options.windowY, 0, FALSE);
#else
    openWindow(display, window, options.windowX, options.windowY, argv[0]);
#endif

    // override classes implementation if profiling will be applied
    if (options.useProfiler)
        overrideClasses();

    printHWInfo();
    printf("\n");
    printf("Reading graph from %s\n", (options.inputFileName) ? options.inputFileName : "stdin");
    printf("Number of frames: %d\n", options.numFrames);
    printf("Window size: %d x %d pixels\n", options.windowX, options.windowY);
    printf("\n");

    // Open scene graphs
    SoInput      sceneInput;
    OPEN_INPUT_FILE(&sceneInput, options.inputFileName, FALSE, &printUsage);

    SbViewportRegion vpr(options.windowX, options.windowY);
    root = setUpGraph(vpr, &sceneInput, options);

    CLOSE_INPUT_FILE(&sceneInput, options.inputFileName);

    // make window visible
    showWindow();

    // Timing tests
   
    printf("\t\t\t time/frame\tframes/second\n");
    #define VALUE_STRING "\t%7.2f ms\t%9.2f\n"
    #define NO_STRING "\t    no %s in model\n"

    // as is rendering
    if (options.useProfiler) {
        SbProfiler::setMeassuring(TRUE);
        options.newRootWanted = TRUE;
    }
    asisTime = timeRendering(options, vpr, root);
    if (options.useProfiler) {
        SbProfiler::setMeassuring(FALSE);
        options.newRootWanted = FALSE;
    }
    printf("As-Is rendering:"VALUE_STRING, asisTime*1e3, 1.0/asisTime);

    // global setting for the rest of the tests
    options.zbufferSwapping = TRUE;
    options.noClear = TRUE;

    // time for rendering without clear
    noClearTime = timeRendering(options, vpr, root);
    printf("No Clear:\t"VALUE_STRING, noClearTime*1e3, 1.0/noClearTime);

    // time for rendering without materials
    options.noMaterials = TRUE;
    noMatTime = timeRendering(options, vpr, root);
    options.noMaterials = FALSE;
    printf("No Materials:\t"VALUE_STRING, noMatTime*1e3, 1.0/noMatTime);

    // time for rendering without xforms
    options.noXforms = TRUE;
    noXformTime = timeRendering(options, vpr, root);
    options.noXforms = FALSE;
    printf("No Transforms:\t"VALUE_STRING, noXformTime*1e3, 1.0/noXformTime);

    if (options.hasTextures) { // do tests only if scene has textures

        // time for rendering without any textures
        options.noTextures = TRUE;
        noTexTime = timeRendering(options, vpr, root);
        options.noTextures = FALSE;
        printf("No Textures:\t"VALUE_STRING, noTexTime*1e3, 1.0/noTexTime);

        // time for rendering without only one texture
        options.oneTexture = TRUE;
        oneTexTime = timeRendering(options, vpr, root);
        options.oneTexture = FALSE;
        printf("One Texture:\t"VALUE_STRING, oneTexTime*1e3, 1.0/oneTexTime);
    }
    else {
        printf("No Textures:\t"NO_STRING, "textures");
        printf("One Texture:\t"NO_STRING, "textures");
        noTexTime = oneTexTime = noClearTime;
    }

    if (options.hasLights) { // do test only if scene has lights
        // time for rendering with lights turned off
        options.noLights = TRUE;
        noLitTime = timeRendering(options, vpr, root);
        options.noLights = FALSE;
        printf("No Lights:\t"VALUE_STRING, noLitTime*1e3, 1.0/noLitTime);
    }
    else {
        printf("No Lights:\t"NO_STRING, "lights");
        noLitTime = noClearTime;
    }

    // time for rendering of geometry outside the view volume
    options.outsideViewVolume = TRUE;
    outsideVvTime = timeRendering(options, vpr, root);
    options.outsideViewVolume = FALSE;    
    printf("Outside View Volume:"VALUE_STRING, outsideVvTime*1e3, 1.0/outsideVvTime);

    // time for rendering of geometry that does not pass z-test
    options.zbufferNever = TRUE;
    options.zbufferSwapping = FALSE;
    zCulledTime = timeRendering(options, vpr, root);
    options.zbufferSwapping = TRUE;
    options.zbufferNever = FALSE;    
    printf("Z-Buffer Culled:"VALUE_STRING, zCulledTime*1e3, 1.0/zCulledTime);

    printf("\n");

    // time for scene traversing
    options.invisible = TRUE;
    invisTime = timeRendering(options, vpr, root);
    options.invisible = FALSE;
    printf("Time taken by OpenGL (sum):          %7.2f ms/frame\n", (noClearTime-invisTime)*1e3);

    // time for rendering of geometry outside the view volume without visibility culling
    options.outsideVvByOpenGL = TRUE;
    outsideVvNoCullTime = timeRendering(options, vpr, root);
    options.outsideVvByOpenGL = FALSE;    
#if 0 // This does not work yet. Some hidden Coin and OpenGL behaviours 
      // make the things much more complex. PCJohn-2006-05-04
    printf("Time taken by OpenGL vertex transformations: %7.2f ms/frame\n", (outsideVvNoCullTime-invisTime)*1e3);
    printf("Time taken by OpenGL pixel rasterizer:       %7.2f ms/frame\n", (noClearTime-outsideVvNoCullTime)*1e3);
#endif

    printf("Time taken by scene graph traversal: %7.2f ms/frame\n", invisTime*1e3);

    // time for rendering with scene graph frozen
    options.freeze = TRUE;
    freezeTime = timeRendering(options, vpr, root);
    options.freeze = FALSE;
    printf("Scene animation cost:                %7.2f ms/frame\n", (noClearTime-freezeTime)*1e3);
    printf("Window clear time:                   %7.2f ms/frame\n", (asisTime-noClearTime)*1e3);

    printf("\n");

    // print profiler output
    if (options.useProfiler) {
        SbProfiler::eliminateDoubleRecords();
        SbProfiler::printResults(options.newRoot, options.fullProfilerResults);
        SbProfiler::reset();
        options.newRoot->unref();

        printf("\n");
    }

    // kill window
    killWindow();

    // draw timing bars
    if (options.showBars) 
        drawBar(asisTime, noClearTime, noMatTime,
                noXformTime, noTexTime, oneTexTime,
                noLitTime, outsideVvNoCullTime, invisTime, freezeTime);

    return 0;
}
