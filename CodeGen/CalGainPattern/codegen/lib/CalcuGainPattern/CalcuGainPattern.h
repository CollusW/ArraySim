/*
 * File: CalcuGainPattern.h
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 18-Jan-2018 15:38:59
 */

#ifndef CALCUGAINPATTERN_H
#define CALCUGAINPATTERN_H

/* Include Files */
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "rt_nonfinite.h"
#include "rtwtypes.h"
#include "CalcuGainPattern_types.h"

/* Function Declarations */
extern void CalcuGainPattern(double carrierFreq_CalcuGainPattern, const creal_T
  weight_CalcuGainPattern[4], double sector_CalcuGainPattern, double
  gainPatterLog_CalcuGainPattern[360]);
extern void CalcuGainPattern_initialize(void);
extern void CalcuGainPattern_terminate(void);

#endif

/*
 * File trailer for CalcuGainPattern.h
 *
 * [EOF]
 */
