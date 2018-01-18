/*
 * File: _coder_CalcuGainPattern_api.h
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 18-Jan-2018 15:38:59
 */

#ifndef _CODER_CALCUGAINPATTERN_API_H
#define _CODER_CALCUGAINPATTERN_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_CalcuGainPattern_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void CalcuGainPattern(real_T carrierFreq_CalcuGainPattern, creal_T
  weight_CalcuGainPattern[4], real_T sector_CalcuGainPattern, real_T
  gainPatterLog_CalcuGainPattern[360]);
extern void CalcuGainPattern_api(const mxArray * const prhs_CalcuGainPattern[3],
  const mxArray *plhs_CalcuGainPattern[1]);
extern void CalcuGainPattern_atexit(void);
extern void CalcuGainPattern_initialize(void);
extern void CalcuGainPattern_terminate(void);
extern void CalcuGainPattern_xil_terminate(void);

#endif

/*
 * File trailer for _coder_CalcuGainPattern_api.h
 *
 * [EOF]
 */
