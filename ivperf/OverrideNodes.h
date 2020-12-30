#include <Inventor/SbTime.h>
#include "SbProfiler.h"

class SoTypeList;


#define OVERRIDE_FUNC(_name_, _mode_) \
virtual void _name_(SoGLRenderAction *action) \
{ \
  if (SbProfiler::isMeassuring()) { \
    double t1 = SbTime::getTimeOfDay().getValue(); \
    SbProfiler::append(this, t1, TRUE,  _mode_); \
  } \
  inherited::_name_(action); \
  if (SbProfiler::isMeassuring()) { \
    double t2 = SbTime::getTimeOfDay().getValue(); \
    SbProfiler::append(this, t2, FALSE, _mode_); \
  } \
}


#define OVERRIDE(_class_) \
class _class_##Override : public _class_ { \
  typedef _class_ inherited; \
public: \
  static void* createInstance() { \
    return new _class_##Override; \
  } \
\
  OVERRIDE_FUNC(GLRender, SbProfiler::RENDER); \
  OVERRIDE_FUNC(GLRenderBelowPath, SbProfiler::BELOW_PATH); \
  OVERRIDE_FUNC(GLRenderInPath,    SbProfiler::IN_PATH); \
  OVERRIDE_FUNC(GLRenderOffPath,   SbProfiler::OFF_PATH); \
}  

void overrideClasses();
const SoTypeList* getOverridenClasses();
