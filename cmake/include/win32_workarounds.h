#ifndef WIN32_WORKAROUNDS_INCLUDED
#define WIN32_WORKAROUNDS_INCLUDED

// XXX FIXME XXX
// as a temporary measure, default to using
// int on 32 bit windows until ACE is fixed or a clean
// workaround can be implemented
#define WIN32_WORKAROUNDS_USE_INT_SSIZE_T

/*
 * Compatibility header to simplify win32 porting
 */
#ifdef _WIN32

  // disable 'min' and 'max' macros
  #ifndef NOMINMAX
  #  define NOMINMAX
  #endif
  // don't include gobs of win32 headers
  #ifndef WIN32_LEAN_AND_MEAN
  #  define WIN32_LEAN_AND_MEAN
  #endif
  // prefer winsock2
  #ifndef _WINSOCKAPI_
  #  define _WINSOCKAPI_
  #endif
  // include useful things like M_PI
  #ifndef _USE_MATH_DEFINES
  #  define _USE_MATH_DEFINES
  #endif

  #include <windows.h>
  #include <math.h>
  #include <stdlib.h>

  namespace win32_workarounds {
    //-- rounding
    inline double nearbyint(double val) { return (val > 0 ? floor(val+0.5)   : ceil(val-0.5));   }
    inline float  nearbyintf(float val) { return (val > 0 ? floorf(val+0.5f) : ceilf(val-0.5f)); }
    inline double round(double val)     { return nearbyint(val); }
    inline float  roundf(float val)     { return nearbyintf(val); }
    inline long   lround(double val)    { return (long)nearbyint(val); }

    //-- random
    inline void   srandom(unsigned int seed) { srand(seed); }
    inline int    random()  { return rand(); }
    inline double drand48() { return rand()/(double)RAND_MAX; } //<< TODO: better simulation of drand48

    //-- math
    // "long double" maps to "double" in msvc:
    // http://msdn.microsoft.com/en-us/library/9cx8xs15.aspx
    inline long double hypotl(double a, double b) { return _hypot(a,b); }
    #if (_MSC_VER < 1600) // no longer needed in vc100
    inline float       hypotf(float a, float b)   { return _hypotf(a,b); }
    #endif
    inline double      log2(double x)             { return log(x)/log(2.0); }

    //-- isnan
    #if __STDC_VERSION__ < 199901L // isnan added in C99
    inline int isnan(double val) { return (int)(val != val); }
    inline int isnan(float val)  { return (int)(val != val); }
    #endif

    //-- wrap iso in posix
    inline int strcasecmp(const char* str1, const char* str2) {
      return _stricmp(str1, str2);
    }
    inline int strncasecmp(const char* str1, const char* str2, size_t len) {
      return _strnicmp(str1, str2, len);
    }

  } // namespace win32_workarounds

  // workaround namespace is used by default;
  // to disable, define USE_WIN32_WORKAROUNDS_NAMESPACE 0
  #ifndef USE_WIN32_WORKAROUNDS_NAMESPACE
  #  define USE_WIN32_WORKAROUNDS_NAMESPACE 1
  #endif
  #if defined(USE_WIN32_WORKAROUNDS_NAMESPACE) && (USE_WIN32_WORKAROUNDS_NAMESPACE==1)
    using namespace win32_workarounds;
  #endif

  /*
   * use macros for calls with varargs
   */
  #ifndef snprintf
  #  define snprintf     _snprintf
  #endif
  #if (_MSC_VER < 1500) // no longer needed in vc90
  #ifndef vsnprintf
  #  define vsnprintf    _vsnprintf
  #endif
  #endif // _MSC_VER

  //-- types http://msdn.microsoft.com/en-us/library/aa383751%28VS.85%29.aspx
  // allow use of int for ssize_t if requested, but only on 32 bit
  #if defined(WIN32_WORKAROUNDS_USE_INT_SSIZE_T) && !defined(_WIN64)
    typedef int ssize_t;
  #else
    typedef SSIZE_T ssize_t;
  #endif // WIN32_WORKAROUNDS_USE_INT_SSIZE_T

#endif// _WIN32

#endif// WIN32_WORKAROUNDS_INCLUDED
