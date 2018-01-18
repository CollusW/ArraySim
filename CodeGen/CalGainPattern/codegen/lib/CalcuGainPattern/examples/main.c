/*
 * File: main.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 18-Jan-2018 15:38:59
 */

/*************************************************************************/
/* This automatically generated example C main file shows how to call    */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/
/* Include Files */
#include "rt_nonfinite.h"
#include "CalcuGainPattern.h"
#include "main.h"

/* Function Declarations */
static void argInit_4x1_creal_T_CalcuGainPa(creal_T result_CalcuGainPattern[4]);
static creal_T argInit_creal_T_CalcuGainPatter(void);
static double argInit_real_T_CalcuGainPattern(void);
static void main_CalcuGainPattern(void);

/* Function Definitions */

/*
 * Arguments    : creal_T result_CalcuGainPattern[4]
 * Return Type  : void
 */
static void argInit_4x1_creal_T_CalcuGainPa(creal_T result_CalcuGainPattern[4])
{
  int idx0_CalcuGainPattern;

  /* Loop over the array to initialize each element. */
  for (idx0_CalcuGainPattern = 0; idx0_CalcuGainPattern < 4;
       idx0_CalcuGainPattern++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result_CalcuGainPattern[idx0_CalcuGainPattern] =
      argInit_creal_T_CalcuGainPatter();
  }
}

/*
 * Arguments    : void
 * Return Type  : creal_T
 */
static creal_T argInit_creal_T_CalcuGainPatter(void)
{
  creal_T result_CalcuGainPattern;

  /* Set the value of the complex variable.
     Change this value to the value that the application requires. */
  result_CalcuGainPattern.re = argInit_real_T_CalcuGainPattern();
  result_CalcuGainPattern.im = argInit_real_T_CalcuGainPattern();
  return result_CalcuGainPattern;
}

/*
 * Arguments    : void
 * Return Type  : double
 */
static double argInit_real_T_CalcuGainPattern(void)
{
  return 0.0;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
static void main_CalcuGainPattern(void)
{
  creal_T dcv0_CalcuGainPattern[4];
  double gainPatterLog_CalcuGainPattern[360];

  /* Initialize function 'CalcuGainPattern' input arguments. */
  /* Initialize function input argument 'weight'. */
  /* Call the entry-point 'CalcuGainPattern'. */
  argInit_4x1_creal_T_CalcuGainPa(dcv0_CalcuGainPattern);
  CalcuGainPattern(argInit_real_T_CalcuGainPattern(), dcv0_CalcuGainPattern,
                   argInit_real_T_CalcuGainPattern(),
                   gainPatterLog_CalcuGainPattern);
}

/*
 * Arguments    : int argc_CalcuGainPattern
 *                const char * const argv_CalcuGainPattern[]
 * Return Type  : int
 */
int main(int argc_CalcuGainPattern, const char * const argv_CalcuGainPattern[])
{
  (void)argc_CalcuGainPattern;
  (void)argv_CalcuGainPattern;

  /* Initialize the application.
     You do not need to do this more than one time. */
  CalcuGainPattern_initialize();

  /* Invoke the entry-point functions.
     You can call entry-point functions multiple times. */
  main_CalcuGainPattern();

  /* Terminate the application.
     You do not need to do this more than one time. */
  CalcuGainPattern_terminate();
  return 0;
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
