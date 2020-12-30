#include <Inventor/SbName.h>
#include <Inventor/nodes/SoNode.h>
#include <Inventor/nodes/SoGroup.h>
#include <Inventor/misc/SoChildList.h>
#include "SbProfiler.h"
#include "OverrideNodes.h"
#include "../make/Common.h" // for SoGraphPrint

#define LAST_CHILD 0x01


SbList<SbProfiler::PrfRec> SbProfiler::log(1000);
SbBool SbProfiler::meassuring = FALSE;



void SbProfiler::setMeassuring(SbBool value)
{
  meassuring = value;
}


//! Find first occurence of object's record after (and including) the start index.
int SbProfiler::find(void *object, int start)
{
  // handle -1 and negative values
  if (start < 0)
    return -1;

  // search for first occurence
  int i = start;
  int c = log.getLength();
  for (; i<c; i++)
    if (log[i].object == object)
      return i;

  // not found
  return -1;
}


//! Finds the first record with higher (or equal) time than time parameter.
int SbProfiler::find(double time)
{
  int i,c = log.getLength();
  for (i=0; i<c; i++)
    if (log[i].time >= time)
      return i;
  return -1;
}


/*! The function finds record belonging to object specified by object parameter
 *  with time equal or higher than start parameter and lower or equal to stop parameter.
 *  If such record is not found, -1 is returned.
 */
int SbProfiler::find(void *object, double start, double stop)
{
  int i = find(start);
  int c = log.getLength();
  for (; i<c; i++) {
    const PrfRec *rec = get(i);
    if (rec->time > stop)
      return -1;
    if (rec->object == object)
      return i;
  }
  return -1;
}


int SbProfiler::findStop(int i)
{
  int c=log.getLength();
  if (i<0 || i>=c)
    return -1;
  const PrfRec *recStart = get(i);
  assert(recStart->start == TRUE && "Index given to SbProfiler::findStop does not point to start record.");
  for (i++; i<c; i++) {
    const PrfRec *rec = get(i);
    if (rec->object != recStart->object)
      continue;

    if (rec->start) {
      i = findStop(i);
      if (i == -1)
        return -1;
    } else
      return i;
  }
  return -1;
}


int SbProfiler::findStart(int i)
{
  assert(0 && "Not implemented yet.");
  return -1;
}


double SbProfiler::getTotalTime(int startIndex, int stopIndex)
{
  if (startIndex == -1 || stopIndex == -1)
    return -1.;
  assert(log[startIndex].object == log[stopIndex].object && "Wrong indexes (objects are not the same).");
  assert(log[startIndex].start == TRUE && log[stopIndex ].start == FALSE && "Wrong indexes (start/stop mismatch).");

  return log[stopIndex].time - log[startIndex].time;
}


double SbProfiler::getTotalTime(SoNode *node, int startSearch)
{
  int i = find(node, startSearch);

  if (i == -1) // node not found
    return -1.;

  if (!log[i].start) // found finish record instead of starting one
    return -1.;
  
  return getTotalTime(i, findStop(i));
}


double SbProfiler::getChildrenTime(SoNode *node, int startSearch)
{
  SoChildList *children = node->getChildren();
  if (children == NULL)
    return 0.;

  int i,c=children->getLength();
  double sum = 0.;
  for (i=0; i<c; i++) {
    SoNode *child = children->operator[](i);

    int j = find(node, startSearch);
    if (j == -1) // node not found
      continue;
    if (!log[j].start) // found finish record instead of starting one
      continue;
    
    // move startSearch index forward
    startSearch = j;

    double tt = getTotalTime(child, startSearch);
    if (tt != -1.)
      sum += tt;
  }
  return sum;
}


void SbProfiler::eliminateDoubleRecords()
{
  int i,j,c = log.getLength()-1;
  for (i=0,j=0; j<c; i++,j++) {
    if (log[j].object == log[j+1].object &&
        log[j].start  == log[j+1].start) {
      if (log[j].start) {
        log[i] = log[j];
        j++;
      } else {
        j++;
        log[i] = log[j];
      }
    } else
      log[i] = log[j];
  }
  if (j==c) {
    log[i] = log[j];
    i++;
  }
  log.truncate(i);
}


static void printNode(SoNode *node, void *data)
{
  SbBool isGroup = node->getTypeId().isDerivedFrom(SoGroup::getClassTypeId());
  SbBool printDetails = data ? true : false;
  const SoTypeList *overridenClassList = getOverridenClasses();

  // make space after the node
  printf("   ");

  if (printDetails) {

    // print all meassured times
    //int c = SbProfiler::getLength();
    int i = SbProfiler::find(node, 0);

    if (i == -1)

      // handle non-registered and non-rendered nodes
      if (overridenClassList->find(node->getTypeId()) == -1)
        printf("<non-registered type>");
      else
        printf("<never rendered>");

    else {

      // print output of the node
      int j = SbProfiler::findStop(i);
      printf("%.2fus", SbProfiler::getTotalTime(i,j) * 1e6);
      if (isGroup)
        printf(" (children: %.2fus)", SbProfiler::getChildrenTime(node, i) * 1e6);
      i = SbProfiler::find(node, j+1);
      while (i != -1) {
        int j = SbProfiler::findStop(i);
        printf(", %.2fus", SbProfiler::getTotalTime(i,j) * 1e6);
        if (isGroup)
          printf(" (children: %.2fus)", SbProfiler::getChildrenTime(node, i) * 1e6);
        i = SbProfiler::find(node, j+1);
      }
    }

  } else {

    // print median
    SbList<double> totalTimes;
    SbList<double> childrenTimes;
    int c = SbProfiler::getLength();
    int i = SbProfiler::find(node, 0);
    while (i != -1) {
      int j = SbProfiler::findStop(i);
      double totalTime = SbProfiler::getTotalTime(i,j);
      double childrenTime = SbProfiler::getChildrenTime(node,i);

      // insert into the ordered list
      totalTimes.push(totalTime); // this ensures that following "for" does not require condition
      const double *a = totalTimes.getArrayPtr();
      for (int k=0;; k++)
        if (a[k] >= totalTime) {
          totalTimes.pop();
          totalTimes.insert(totalTime, k);
          childrenTimes.insert(childrenTime, k);
          break;
        }
    
      i = SbProfiler::find(node, j+1);
    }
    c = totalTimes.getLength();
    if (c != 0)
      if (isGroup)
        printf("%.2fus (children: %.2fus)", totalTimes[c/2] * 1e6, childrenTimes[c/2] * 1e6);
      else
        printf("%.2fus", totalTimes[c/2] * 1e6);
    else {
      if (overridenClassList->find(node->getTypeId()) == -1)
        printf("<non-registered type>");
      else
        printf("<never rendered>");
    }
  }
}


void SbProfiler::printResults(SoNode *root, SbBool details)
{
#if 0 // useful debugging code,
      // prints all records for one node
  int i,c = log.getLength();
  for (i=0; i<c; i++)
    if (log[i].object == node)
      printf("(%i,%c), ", i, log[i].start ? 'T' : 'F');
  printf("\n");
#endif

  printf("Scene graph timing:\n\n");

  if (root == NULL) {
    fprintf(stdout, " < empty scene >\n\n");
    return;
  }

  SoGraphPrint::print(root, FALSE, printNode, (void*)details);

  if (!details)
    printf("\n"
           "The scene includes \"hidden scene\" if it exists.\n" 
           "Median value is used for results. Use -h for more info.\n");
}


void SbProfiler::reset()
{
  log.truncate(0);
}
