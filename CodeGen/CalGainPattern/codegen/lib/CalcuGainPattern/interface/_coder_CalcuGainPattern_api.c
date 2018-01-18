/*
 * File: _coder_CalcuGainPattern_api.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 18-Jan-2018 15:38:59
 */

/* Include Files */
#include "tmwtypes.h"
#include "_coder_CalcuGainPattern_api.h"
#include "_coder_CalcuGainPattern_mex.h"

/* Variable Definitions */
emlrtCTX emlrtRootTLSGlobal = NULL;
emlrtContext emlrtContextGlobal = { true,/* bFirstTime */
  false,                               /* bInitialized */
  131451U,                             /* fVersionInfo */
  NULL,                                /* fErrorFunction */
  "CalcuGainPattern",                  /* fFunctionName */
  NULL,                                /* fRTCallStack */
  false,                               /* bDebugMode */
  { 2045744189U, 2170104910U, 2743257031U, 4284093946U },/* fSigWrd */
  NULL                                 /* fSigMem */
};

/* Function Declarations */
static real_T b_emlrt_marshallIn_CalcuGainPat(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *u_CalcuGainPattern, const
  emlrtMsgIdentifier *parentId_CalcuGainPattern);
static void c_emlrt_marshallIn_CalcuGainPat(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *weight_CalcuGainPattern, const char_T
  *identifier_CalcuGainPattern, creal_T y_CalcuGainPattern[4]);
static void d_emlrt_marshallIn_CalcuGainPat(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *u_CalcuGainPattern, const
  emlrtMsgIdentifier *parentId_CalcuGainPattern, creal_T y_CalcuGainPattern[4]);
static real_T e_emlrt_marshallIn_CalcuGainPat(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *src_CalcuGainPattern, const
  emlrtMsgIdentifier *msgId_CalcuGainPattern);
static real_T emlrt_marshallIn_CalcuGainPatte(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *carrierFreq_CalcuGainPattern, const
  char_T *identifier_CalcuGainPattern);
static const mxArray *emlrt_marshallOut_CalcuGainPatt(const real_T
  u_CalcuGainPattern[360]);
static void f_emlrt_marshallIn_CalcuGainPat(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *src_CalcuGainPattern, const
  emlrtMsgIdentifier *msgId_CalcuGainPattern, creal_T ret_CalcuGainPattern[4]);

/* Function Definitions */

/*
 * Arguments    : const emlrtStack *sp_CalcuGainPattern
 *                const mxArray *u_CalcuGainPattern
 *                const emlrtMsgIdentifier *parentId_CalcuGainPattern
 * Return Type  : real_T
 */
static real_T b_emlrt_marshallIn_CalcuGainPat(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *u_CalcuGainPattern, const
  emlrtMsgIdentifier *parentId_CalcuGainPattern)
{
  real_T y_CalcuGainPattern;
  y_CalcuGainPattern = e_emlrt_marshallIn_CalcuGainPat(sp_CalcuGainPattern,
    emlrtAlias(u_CalcuGainPattern), parentId_CalcuGainPattern);
  emlrtDestroyArray(&u_CalcuGainPattern);
  return y_CalcuGainPattern;
}

/*
 * Arguments    : const emlrtStack *sp_CalcuGainPattern
 *                const mxArray *weight_CalcuGainPattern
 *                const char_T *identifier_CalcuGainPattern
 *                creal_T y_CalcuGainPattern[4]
 * Return Type  : void
 */
static void c_emlrt_marshallIn_CalcuGainPat(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *weight_CalcuGainPattern, const char_T
  *identifier_CalcuGainPattern, creal_T y_CalcuGainPattern[4])
{
  emlrtMsgIdentifier thisId_CalcuGainPattern;
  thisId_CalcuGainPattern.fIdentifier = (const char *)
    identifier_CalcuGainPattern;
  thisId_CalcuGainPattern.fParent = NULL;
  thisId_CalcuGainPattern.bParentIsCell = false;
  d_emlrt_marshallIn_CalcuGainPat(sp_CalcuGainPattern, emlrtAlias
    (weight_CalcuGainPattern), &thisId_CalcuGainPattern, y_CalcuGainPattern);
  emlrtDestroyArray(&weight_CalcuGainPattern);
}

/*
 * Arguments    : const emlrtStack *sp_CalcuGainPattern
 *                const mxArray *u_CalcuGainPattern
 *                const emlrtMsgIdentifier *parentId_CalcuGainPattern
 *                creal_T y_CalcuGainPattern[4]
 * Return Type  : void
 */
static void d_emlrt_marshallIn_CalcuGainPat(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *u_CalcuGainPattern, const
  emlrtMsgIdentifier *parentId_CalcuGainPattern, creal_T y_CalcuGainPattern[4])
{
  f_emlrt_marshallIn_CalcuGainPat(sp_CalcuGainPattern, emlrtAlias
    (u_CalcuGainPattern), parentId_CalcuGainPattern, y_CalcuGainPattern);
  emlrtDestroyArray(&u_CalcuGainPattern);
}

/*
 * Arguments    : const emlrtStack *sp_CalcuGainPattern
 *                const mxArray *src_CalcuGainPattern
 *                const emlrtMsgIdentifier *msgId_CalcuGainPattern
 * Return Type  : real_T
 */
static real_T e_emlrt_marshallIn_CalcuGainPat(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *src_CalcuGainPattern, const
  emlrtMsgIdentifier *msgId_CalcuGainPattern)
{
  real_T ret_CalcuGainPattern;
  static const int32_T dims_CalcuGainPattern = 0;
  emlrtCheckBuiltInR2012b(sp_CalcuGainPattern, msgId_CalcuGainPattern,
    src_CalcuGainPattern, "double", false, 0U, &dims_CalcuGainPattern);
  ret_CalcuGainPattern = *(real_T *)emlrtMxGetData(src_CalcuGainPattern);
  emlrtDestroyArray(&src_CalcuGainPattern);
  return ret_CalcuGainPattern;
}

/*
 * Arguments    : const emlrtStack *sp_CalcuGainPattern
 *                const mxArray *carrierFreq_CalcuGainPattern
 *                const char_T *identifier_CalcuGainPattern
 * Return Type  : real_T
 */
static real_T emlrt_marshallIn_CalcuGainPatte(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *carrierFreq_CalcuGainPattern, const
  char_T *identifier_CalcuGainPattern)
{
  real_T y_CalcuGainPattern;
  emlrtMsgIdentifier thisId_CalcuGainPattern;
  thisId_CalcuGainPattern.fIdentifier = (const char *)
    identifier_CalcuGainPattern;
  thisId_CalcuGainPattern.fParent = NULL;
  thisId_CalcuGainPattern.bParentIsCell = false;
  y_CalcuGainPattern = b_emlrt_marshallIn_CalcuGainPat(sp_CalcuGainPattern,
    emlrtAlias(carrierFreq_CalcuGainPattern), &thisId_CalcuGainPattern);
  emlrtDestroyArray(&carrierFreq_CalcuGainPattern);
  return y_CalcuGainPattern;
}

/*
 * Arguments    : const real_T u_CalcuGainPattern[360]
 * Return Type  : const mxArray *
 */
static const mxArray *emlrt_marshallOut_CalcuGainPatt(const real_T
  u_CalcuGainPattern[360])
{
  const mxArray *y_CalcuGainPattern;
  const mxArray *m0_CalcuGainPattern;
  static const int32_T iv0_CalcuGainPattern[2] = { 0, 0 };

  static const int32_T iv1_CalcuGainPattern[2] = { 1, 360 };

  y_CalcuGainPattern = NULL;
  m0_CalcuGainPattern = emlrtCreateNumericArray(2, iv0_CalcuGainPattern,
    mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m0_CalcuGainPattern, (void *)&u_CalcuGainPattern[0]);
  emlrtSetDimensions((mxArray *)m0_CalcuGainPattern, iv1_CalcuGainPattern, 2);
  emlrtAssign(&y_CalcuGainPattern, m0_CalcuGainPattern);
  return y_CalcuGainPattern;
}

/*
 * Arguments    : const emlrtStack *sp_CalcuGainPattern
 *                const mxArray *src_CalcuGainPattern
 *                const emlrtMsgIdentifier *msgId_CalcuGainPattern
 *                creal_T ret_CalcuGainPattern[4]
 * Return Type  : void
 */
static void f_emlrt_marshallIn_CalcuGainPat(const emlrtStack
  *sp_CalcuGainPattern, const mxArray *src_CalcuGainPattern, const
  emlrtMsgIdentifier *msgId_CalcuGainPattern, creal_T ret_CalcuGainPattern[4])
{
  static const int32_T dims_CalcuGainPattern[1] = { 4 };

  emlrtCheckBuiltInR2012b(sp_CalcuGainPattern, msgId_CalcuGainPattern,
    src_CalcuGainPattern, "double", true, 1U, dims_CalcuGainPattern);
  emlrtImportArrayR2015b(sp_CalcuGainPattern, src_CalcuGainPattern,
    ret_CalcuGainPattern, 8, true);
  emlrtDestroyArray(&src_CalcuGainPattern);
}

/*
 * Arguments    : const mxArray * const prhs_CalcuGainPattern[3]
 *                const mxArray *plhs_CalcuGainPattern[1]
 * Return Type  : void
 */
void CalcuGainPattern_api(const mxArray * const prhs_CalcuGainPattern[3], const
  mxArray *plhs_CalcuGainPattern[1])
{
  real_T (*gainPatterLog_CalcuGainPattern)[360];
  real_T carrierFreq_CalcuGainPattern;
  creal_T weight_CalcuGainPattern[4];
  real_T sector_CalcuGainPattern;
  emlrtStack st_CalcuGainPattern = { NULL,/* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st_CalcuGainPattern.tls = emlrtRootTLSGlobal;
  gainPatterLog_CalcuGainPattern = (real_T (*)[360])mxMalloc(sizeof(real_T [360]));

  /* Marshall function inputs */
  carrierFreq_CalcuGainPattern = emlrt_marshallIn_CalcuGainPatte
    (&st_CalcuGainPattern, emlrtAliasP(prhs_CalcuGainPattern[0]), "carrierFreq");
  c_emlrt_marshallIn_CalcuGainPat(&st_CalcuGainPattern, emlrtAliasP
    (prhs_CalcuGainPattern[1]), "weight", weight_CalcuGainPattern);
  sector_CalcuGainPattern = emlrt_marshallIn_CalcuGainPatte(&st_CalcuGainPattern,
    emlrtAliasP(prhs_CalcuGainPattern[2]), "sector");

  /* Invoke the target function */
  CalcuGainPattern(carrierFreq_CalcuGainPattern, weight_CalcuGainPattern,
                   sector_CalcuGainPattern, *gainPatterLog_CalcuGainPattern);

  /* Marshall function outputs */
  plhs_CalcuGainPattern[0] = emlrt_marshallOut_CalcuGainPatt
    (*gainPatterLog_CalcuGainPattern);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void CalcuGainPattern_atexit(void)
{
  emlrtStack st_CalcuGainPattern = { NULL,/* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st_CalcuGainPattern.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st_CalcuGainPattern);
  emlrtLeaveRtStackR2012b(&st_CalcuGainPattern);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  CalcuGainPattern_xil_terminate();
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void CalcuGainPattern_initialize(void)
{
  emlrtStack st_CalcuGainPattern = { NULL,/* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st_CalcuGainPattern.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st_CalcuGainPattern, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st_CalcuGainPattern);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void CalcuGainPattern_terminate(void)
{
  emlrtStack st_CalcuGainPattern = { NULL,/* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st_CalcuGainPattern.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st_CalcuGainPattern);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/*
 * File trailer for _coder_CalcuGainPattern_api.c
 *
 * [EOF]
 */
