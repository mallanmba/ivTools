#ifndef SB_PROFILER_H
#define SB_PROFILER_H

#include <Inventor/lists/SbList.h>

class SoNode;


class SbProfiler {
public:
  enum PrfMode { RENDER, BELOW_PATH, IN_PATH, OFF_PATH };
  struct PrfRec {
    void *object;
    double time;
    SbBool start : 2;
    PrfMode mode : 4;
    inline PrfRec()  {}
    inline PrfRec(void *aobject, double atime, SbBool astart, PrfMode amode) : 
        object(aobject), time(atime), start(astart), mode(amode)  {}
  };
private:
  static SbList<PrfRec> log;
  static SbBool meassuring;

public:
  static inline SbBool isMeassuring()  { return meassuring; }
  static void setMeassuring(SbBool value);

  static inline void append(void *object, const double &currentTime, SbBool start, PrfMode mode) {
    log.append(PrfRec(object, currentTime, start, mode));
  }
  static inline const PrfRec* get(int i) {
    return &log.operator[](i);
  }
  static inline int getLength() {
    return log.getLength();
  }
  
  static int find(void *object, int start);
  static int find(double time);
  static int find(void *object, double start, double stop);
  static int findStart(int i);
  static int findStop(int i);

  static double getTotalTime(int startIndex, int stopIndex);
  static double getTotalTime(SoNode *node, int startSearch);
  static double getChildrenTime(SoNode *node, int startSearch);
  static void eliminateDoubleRecords();
  static void printResults(SoNode *root, SbBool details);
  static void reset();
};


#endif /* SB_PROFILER_H */
