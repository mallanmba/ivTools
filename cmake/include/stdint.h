#ifndef stdint_workaround_h
#define stdint_workaround_h

// ensure the config file is included so
// the _HAVE variables are defined
#include "@PROJECT_NAME@Config.h"

#ifdef _MSC_VER
#pragma message ("including boost/cstdint.hpp because this platform does not appear to provide stdint.h")
#else
#warning "including boost/cstdint.hpp because this platform does not appear to provide stdint.h"
#endif // _MSC_VER

// use boost stdint
#include <boost/cstdint.hpp>
using namespace boost;

#endif // stdint_workaround_h
