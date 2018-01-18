/*
 * File: _coder_CalcuGainPattern_mex.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 18-Jan-2018 15:38:59
 */

/* Include Files */
#include "_coder_CalcuGainPattern_api.h"
#include "_coder_CalcuGainPattern_mex.h"

/* Function Declarations */
static void CalcuGainPattern_mexFunction_Ca(int32_T nlhs_CalcuGainPattern, const
  mxArray * const plhs_CalcuGainPattern[1], int32_T nrhs_CalcuGainPattern, const
  mxArray * const prhs_CalcuGainPattern[3]);

/* Function Definitions */

/*
 * Arguments    : int32_T nlhs_CalcuGainPattern
 *                const mxArray * const plhs_CalcuGainPattern[1]
 *                int32_T nrhs_CalcuGainPattern
 *                const mxArray * const prhs_CalcuGainPattern[3]
 * Return Type  : void
 */
static void CalcuGainPattern_mexFunction_Ca(int32_T nlhs_CalcuGainPattern, const
  mxArray * const plhs_CalcuGainPattern[1], int32_T nrhs_CalcuGainPattern, const
  mxArray * const prhs_CalcuGainPattern[3])
{
  const mxArray *inputs_CalcuGainPattern[3];
  const mxArray *outputs_CalcuGainPattern[1];
  int32_T b_nlhs_CalcuGainPattern;
  emlrtStack st_CalcuGainPattern = { NULL,/* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st_CalcuGainPattern.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs_CalcuGainPattern != 3) {
    emlrtErrMsgIdAndTxt(&st_CalcuGainPattern,
                        "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 3, 4, 16,
                        "CalcuGainPattern");
  }

  if (nlhs_CalcuGainPattern > 1) {
    emlrtErrMsgIdAndTxt(&st_CalcuGainPattern,
                        "EMLRT:runTime:TooManyOutputArguments", 3, 4, 16,
                        "CalcuGainPattern");
  }

  /* Temporary copy for mex inputs. */
  if (0 <= nrhs_CalcuGainPattern - 1) {
    memcpy((void *)&inputs_CalcuGainPattern[0], (void *)&prhs_CalcuGainPattern[0],
           (uint32_T)(nrhs_CalcuGainPattern * (int32_T)sizeof(const mxArray *)));
  }

  /* Call the function. */
  CalcuGainPattern_api(inputs_CalcuGainPattern, outputs_CalcuGainPattern);

  /* Copy over outputs to the caller. */
  if (nlhs_CalcuGainPattern < 1) {
    b_nlhs_CalcuGainPattern = 1;
  } else {
    b_nlhs_CalcuGainPattern = nlhs_CalcuGainPattern;
  }

  emlrtReturnArrays(b_nlhs_CalcuGainPattern, plhs_CalcuGainPattern,
                    outputs_CalcuGainPattern);

  /* Module termination. */
  CalcuGainPattern_terminate();
}

/*
 * Arguments    : int32_T nlhs_CalcuGainPattern
 *                const mxArray * const plhs_CalcuGainPattern[]
 *                int32_T nrhs_CalcuGainPattern
 *                const mxArray * const prhs_CalcuGainPattern[]
 * Return Type  : void
 */
void mexFunction(int32_T nlhs_CalcuGainPattern, const mxArray * const
                 plhs_CalcuGainPattern[], int32_T nrhs_CalcuGainPattern, const
                 mxArray * const prhs_CalcuGainPattern[])
{
  mexAtExit(CalcuGainPattern_atexit);

  /* Initialize the memory manager. */
  /* Module initialization. */
  CalcuGainPattern_initialize();

  /* Dispatch the entry-point. */
  CalcuGainPattern_mexFunction_Ca(nlhs_CalcuGainPattern, plhs_CalcuGainPattern,
    nrhs_CalcuGainPattern, prhs_CalcuGainPattern);
}

/*
 * Arguments    : void
 * Return Type  : emlrtCTX
 */
emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/*
 * File trailer for _coder_CalcuGainPattern_mex.c
 *
 * [EOF]
 */
