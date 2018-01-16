/*
* MATLAB Compiler: 6.4 (R2017a)
* Date: Tue Jan 16 16:57:37 2018
* Arguments:
* "-B""macro_default""-W""dotnet:CalculateGainPatternComp,MatlabClass,4.0,private""-T""lin
* k:lib""-d""E:\Work\Matlab\SandboxArraySimGit\CodeGen\CalGainPattern\CalculateGainPattern
* Comp\for_testing""-v""class{MatlabClass:E:\Work\Matlab\SandboxArraySimGit\CodeGen\CalGai
* nPattern\CalcuGainPattern.m}"
*/
using System;
using System.Reflection;
using System.IO;
using MathWorks.MATLAB.NET.Arrays;
using MathWorks.MATLAB.NET.Utility;

#if SHARED
[assembly: System.Reflection.AssemblyKeyFile(@"")]
#endif

namespace CalculateGainPatternComp
{

  /// <summary>
  /// The MatlabClass class provides a CLS compliant, MWArray interface to the MATLAB
  /// functions contained in the files:
  /// <newpara></newpara>
  /// E:\Work\Matlab\SandboxArraySimGit\CodeGen\CalGainPattern\CalcuGainPattern.m
  /// </summary>
  /// <remarks>
  /// @Version 4.0
  /// </remarks>
  public class MatlabClass : IDisposable
  {
    #region Constructors

    /// <summary internal= "true">
    /// The static constructor instantiates and initializes the MATLAB Runtime instance.
    /// </summary>
    static MatlabClass()
    {
      if (MWMCR.MCRAppInitialized)
      {
        try
        {
          Assembly assembly= Assembly.GetExecutingAssembly();

          string ctfFilePath= assembly.Location;

          int lastDelimiter= ctfFilePath.LastIndexOf(@"\");

          ctfFilePath= ctfFilePath.Remove(lastDelimiter, (ctfFilePath.Length - lastDelimiter));

          string ctfFileName = "CalculateGainPatternComp.ctf";

          Stream embeddedCtfStream = null;

          String[] resourceStrings = assembly.GetManifestResourceNames();

          foreach (String name in resourceStrings)
          {
            if (name.Contains(ctfFileName))
            {
              embeddedCtfStream = assembly.GetManifestResourceStream(name);
              break;
            }
          }
          mcr= new MWMCR("",
                         ctfFilePath, embeddedCtfStream, true);
        }
        catch(Exception ex)
        {
          ex_ = new Exception("MWArray assembly failed to be initialized", ex);
        }
      }
      else
      {
        ex_ = new ApplicationException("MWArray assembly could not be initialized");
      }
    }


    /// <summary>
    /// Constructs a new instance of the MatlabClass class.
    /// </summary>
    public MatlabClass()
    {
      if(ex_ != null)
      {
        throw ex_;
      }
    }


    #endregion Constructors

    #region Finalize

    /// <summary internal= "true">
    /// Class destructor called by the CLR garbage collector.
    /// </summary>
    ~MatlabClass()
    {
      Dispose(false);
    }


    /// <summary>
    /// Frees the native resources associated with this object
    /// </summary>
    public void Dispose()
    {
      Dispose(true);

      GC.SuppressFinalize(this);
    }


    /// <summary internal= "true">
    /// Internal dispose function
    /// </summary>
    protected virtual void Dispose(bool disposing)
    {
      if (!disposed)
      {
        disposed= true;

        if (disposing)
        {
          // Free managed resources;
        }

        // Free native resources
      }
    }


    #endregion Finalize

    #region Methods

    /// <summary>
    /// Provides a single output, 0-input MWArrayinterface to the CalcuGainPattern MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// /*!
    /// *  @brief     This function calculates the array gain pattern (log scale).
    /// *  @details   
    /// *  @param[out] gainPatterLog. 360x1, array gain pattern (in log scale) for AZ
    /// angle [0:1:359] degree.
    /// *  @param[in] carrierFreq,  1x1, integer, carrier frequency. valid range =
    /// [5625:1:5825], unit is MHz.
    /// *  @param[in] weight,    4x1, complex double, weight. Note: weight should be
    /// conjugated before passing to the function. i.e. this function DOES NOT conjugate
    /// the input weight.
    /// *  @param[in] sector,  1x1, integer, sector number. valid range = [1:1:24].
    /// *  @pre       First initialize the system.
    /// *  @bug       Null
    /// *  @warning   Null
    /// *  @author    Collus Wang, Wayne Zhang
    /// *  @version   1.0
    /// *  @date       2018.01.15.
    /// *  @copyright Collus Wang all rights reserved.
    /// * @remark   { revision history: V1.0, 2018.01.15. Collus Wang, Wayne Zhang, 
    /// first draft }
    /// */
    /// </remarks>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray CalcuGainPattern()
    {
      return mcr.EvaluateFunction("CalcuGainPattern", new MWArray[]{});
    }


    /// <summary>
    /// Provides a single output, 1-input MWArrayinterface to the CalcuGainPattern MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// /*!
    /// *  @brief     This function calculates the array gain pattern (log scale).
    /// *  @details   
    /// *  @param[out] gainPatterLog. 360x1, array gain pattern (in log scale) for AZ
    /// angle [0:1:359] degree.
    /// *  @param[in] carrierFreq,  1x1, integer, carrier frequency. valid range =
    /// [5625:1:5825], unit is MHz.
    /// *  @param[in] weight,    4x1, complex double, weight. Note: weight should be
    /// conjugated before passing to the function. i.e. this function DOES NOT conjugate
    /// the input weight.
    /// *  @param[in] sector,  1x1, integer, sector number. valid range = [1:1:24].
    /// *  @pre       First initialize the system.
    /// *  @bug       Null
    /// *  @warning   Null
    /// *  @author    Collus Wang, Wayne Zhang
    /// *  @version   1.0
    /// *  @date       2018.01.15.
    /// *  @copyright Collus Wang all rights reserved.
    /// * @remark   { revision history: V1.0, 2018.01.15. Collus Wang, Wayne Zhang, 
    /// first draft }
    /// */
    /// </remarks>
    /// <param name="carrierFreq">Input argument #1</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray CalcuGainPattern(MWArray carrierFreq)
    {
      return mcr.EvaluateFunction("CalcuGainPattern", carrierFreq);
    }


    /// <summary>
    /// Provides a single output, 2-input MWArrayinterface to the CalcuGainPattern MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// /*!
    /// *  @brief     This function calculates the array gain pattern (log scale).
    /// *  @details   
    /// *  @param[out] gainPatterLog. 360x1, array gain pattern (in log scale) for AZ
    /// angle [0:1:359] degree.
    /// *  @param[in] carrierFreq,  1x1, integer, carrier frequency. valid range =
    /// [5625:1:5825], unit is MHz.
    /// *  @param[in] weight,    4x1, complex double, weight. Note: weight should be
    /// conjugated before passing to the function. i.e. this function DOES NOT conjugate
    /// the input weight.
    /// *  @param[in] sector,  1x1, integer, sector number. valid range = [1:1:24].
    /// *  @pre       First initialize the system.
    /// *  @bug       Null
    /// *  @warning   Null
    /// *  @author    Collus Wang, Wayne Zhang
    /// *  @version   1.0
    /// *  @date       2018.01.15.
    /// *  @copyright Collus Wang all rights reserved.
    /// * @remark   { revision history: V1.0, 2018.01.15. Collus Wang, Wayne Zhang, 
    /// first draft }
    /// */
    /// </remarks>
    /// <param name="carrierFreq">Input argument #1</param>
    /// <param name="weight">Input argument #2</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray CalcuGainPattern(MWArray carrierFreq, MWArray weight)
    {
      return mcr.EvaluateFunction("CalcuGainPattern", carrierFreq, weight);
    }


    /// <summary>
    /// Provides a single output, 3-input MWArrayinterface to the CalcuGainPattern MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// /*!
    /// *  @brief     This function calculates the array gain pattern (log scale).
    /// *  @details   
    /// *  @param[out] gainPatterLog. 360x1, array gain pattern (in log scale) for AZ
    /// angle [0:1:359] degree.
    /// *  @param[in] carrierFreq,  1x1, integer, carrier frequency. valid range =
    /// [5625:1:5825], unit is MHz.
    /// *  @param[in] weight,    4x1, complex double, weight. Note: weight should be
    /// conjugated before passing to the function. i.e. this function DOES NOT conjugate
    /// the input weight.
    /// *  @param[in] sector,  1x1, integer, sector number. valid range = [1:1:24].
    /// *  @pre       First initialize the system.
    /// *  @bug       Null
    /// *  @warning   Null
    /// *  @author    Collus Wang, Wayne Zhang
    /// *  @version   1.0
    /// *  @date       2018.01.15.
    /// *  @copyright Collus Wang all rights reserved.
    /// * @remark   { revision history: V1.0, 2018.01.15. Collus Wang, Wayne Zhang, 
    /// first draft }
    /// */
    /// </remarks>
    /// <param name="carrierFreq">Input argument #1</param>
    /// <param name="weight">Input argument #2</param>
    /// <param name="sector">Input argument #3</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray CalcuGainPattern(MWArray carrierFreq, MWArray weight, MWArray sector)
    {
      return mcr.EvaluateFunction("CalcuGainPattern", carrierFreq, weight, sector);
    }


    /// <summary>
    /// Provides the standard 0-input MWArray interface to the CalcuGainPattern MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// /*!
    /// *  @brief     This function calculates the array gain pattern (log scale).
    /// *  @details   
    /// *  @param[out] gainPatterLog. 360x1, array gain pattern (in log scale) for AZ
    /// angle [0:1:359] degree.
    /// *  @param[in] carrierFreq,  1x1, integer, carrier frequency. valid range =
    /// [5625:1:5825], unit is MHz.
    /// *  @param[in] weight,    4x1, complex double, weight. Note: weight should be
    /// conjugated before passing to the function. i.e. this function DOES NOT conjugate
    /// the input weight.
    /// *  @param[in] sector,  1x1, integer, sector number. valid range = [1:1:24].
    /// *  @pre       First initialize the system.
    /// *  @bug       Null
    /// *  @warning   Null
    /// *  @author    Collus Wang, Wayne Zhang
    /// *  @version   1.0
    /// *  @date       2018.01.15.
    /// *  @copyright Collus Wang all rights reserved.
    /// * @remark   { revision history: V1.0, 2018.01.15. Collus Wang, Wayne Zhang, 
    /// first draft }
    /// */
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] CalcuGainPattern(int numArgsOut)
    {
      return mcr.EvaluateFunction(numArgsOut, "CalcuGainPattern", new MWArray[]{});
    }


    /// <summary>
    /// Provides the standard 1-input MWArray interface to the CalcuGainPattern MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// /*!
    /// *  @brief     This function calculates the array gain pattern (log scale).
    /// *  @details   
    /// *  @param[out] gainPatterLog. 360x1, array gain pattern (in log scale) for AZ
    /// angle [0:1:359] degree.
    /// *  @param[in] carrierFreq,  1x1, integer, carrier frequency. valid range =
    /// [5625:1:5825], unit is MHz.
    /// *  @param[in] weight,    4x1, complex double, weight. Note: weight should be
    /// conjugated before passing to the function. i.e. this function DOES NOT conjugate
    /// the input weight.
    /// *  @param[in] sector,  1x1, integer, sector number. valid range = [1:1:24].
    /// *  @pre       First initialize the system.
    /// *  @bug       Null
    /// *  @warning   Null
    /// *  @author    Collus Wang, Wayne Zhang
    /// *  @version   1.0
    /// *  @date       2018.01.15.
    /// *  @copyright Collus Wang all rights reserved.
    /// * @remark   { revision history: V1.0, 2018.01.15. Collus Wang, Wayne Zhang, 
    /// first draft }
    /// */
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="carrierFreq">Input argument #1</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] CalcuGainPattern(int numArgsOut, MWArray carrierFreq)
    {
      return mcr.EvaluateFunction(numArgsOut, "CalcuGainPattern", carrierFreq);
    }


    /// <summary>
    /// Provides the standard 2-input MWArray interface to the CalcuGainPattern MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// /*!
    /// *  @brief     This function calculates the array gain pattern (log scale).
    /// *  @details   
    /// *  @param[out] gainPatterLog. 360x1, array gain pattern (in log scale) for AZ
    /// angle [0:1:359] degree.
    /// *  @param[in] carrierFreq,  1x1, integer, carrier frequency. valid range =
    /// [5625:1:5825], unit is MHz.
    /// *  @param[in] weight,    4x1, complex double, weight. Note: weight should be
    /// conjugated before passing to the function. i.e. this function DOES NOT conjugate
    /// the input weight.
    /// *  @param[in] sector,  1x1, integer, sector number. valid range = [1:1:24].
    /// *  @pre       First initialize the system.
    /// *  @bug       Null
    /// *  @warning   Null
    /// *  @author    Collus Wang, Wayne Zhang
    /// *  @version   1.0
    /// *  @date       2018.01.15.
    /// *  @copyright Collus Wang all rights reserved.
    /// * @remark   { revision history: V1.0, 2018.01.15. Collus Wang, Wayne Zhang, 
    /// first draft }
    /// */
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="carrierFreq">Input argument #1</param>
    /// <param name="weight">Input argument #2</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] CalcuGainPattern(int numArgsOut, MWArray carrierFreq, MWArray weight)
    {
      return mcr.EvaluateFunction(numArgsOut, "CalcuGainPattern", carrierFreq, weight);
    }


    /// <summary>
    /// Provides the standard 3-input MWArray interface to the CalcuGainPattern MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// /*!
    /// *  @brief     This function calculates the array gain pattern (log scale).
    /// *  @details   
    /// *  @param[out] gainPatterLog. 360x1, array gain pattern (in log scale) for AZ
    /// angle [0:1:359] degree.
    /// *  @param[in] carrierFreq,  1x1, integer, carrier frequency. valid range =
    /// [5625:1:5825], unit is MHz.
    /// *  @param[in] weight,    4x1, complex double, weight. Note: weight should be
    /// conjugated before passing to the function. i.e. this function DOES NOT conjugate
    /// the input weight.
    /// *  @param[in] sector,  1x1, integer, sector number. valid range = [1:1:24].
    /// *  @pre       First initialize the system.
    /// *  @bug       Null
    /// *  @warning   Null
    /// *  @author    Collus Wang, Wayne Zhang
    /// *  @version   1.0
    /// *  @date       2018.01.15.
    /// *  @copyright Collus Wang all rights reserved.
    /// * @remark   { revision history: V1.0, 2018.01.15. Collus Wang, Wayne Zhang, 
    /// first draft }
    /// */
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="carrierFreq">Input argument #1</param>
    /// <param name="weight">Input argument #2</param>
    /// <param name="sector">Input argument #3</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] CalcuGainPattern(int numArgsOut, MWArray carrierFreq, MWArray 
                                weight, MWArray sector)
    {
      return mcr.EvaluateFunction(numArgsOut, "CalcuGainPattern", carrierFreq, weight, sector);
    }


    /// <summary>
    /// Provides an interface for the CalcuGainPattern function in which the input and
    /// output
    /// arguments are specified as an array of MWArrays.
    /// </summary>
    /// <remarks>
    /// This method will allocate and return by reference the output argument
    /// array.<newpara></newpara>
    /// M-Documentation:
    /// /*!
    /// *  @brief     This function calculates the array gain pattern (log scale).
    /// *  @details   
    /// *  @param[out] gainPatterLog. 360x1, array gain pattern (in log scale) for AZ
    /// angle [0:1:359] degree.
    /// *  @param[in] carrierFreq,  1x1, integer, carrier frequency. valid range =
    /// [5625:1:5825], unit is MHz.
    /// *  @param[in] weight,    4x1, complex double, weight. Note: weight should be
    /// conjugated before passing to the function. i.e. this function DOES NOT conjugate
    /// the input weight.
    /// *  @param[in] sector,  1x1, integer, sector number. valid range = [1:1:24].
    /// *  @pre       First initialize the system.
    /// *  @bug       Null
    /// *  @warning   Null
    /// *  @author    Collus Wang, Wayne Zhang
    /// *  @version   1.0
    /// *  @date       2018.01.15.
    /// *  @copyright Collus Wang all rights reserved.
    /// * @remark   { revision history: V1.0, 2018.01.15. Collus Wang, Wayne Zhang, 
    /// first draft }
    /// */
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return</param>
    /// <param name= "argsOut">Array of MWArray output arguments</param>
    /// <param name= "argsIn">Array of MWArray input arguments</param>
    ///
    public void CalcuGainPattern(int numArgsOut, ref MWArray[] argsOut, MWArray[] argsIn)
    {
      mcr.EvaluateFunction("CalcuGainPattern", numArgsOut, ref argsOut, argsIn);
    }



    /// <summary>
    /// This method will cause a MATLAB figure window to behave as a modal dialog box.
    /// The method will not return until all the figure windows associated with this
    /// component have been closed.
    /// </summary>
    /// <remarks>
    /// An application should only call this method when required to keep the
    /// MATLAB figure window from disappearing.  Other techniques, such as calling
    /// Console.ReadLine() from the application should be considered where
    /// possible.</remarks>
    ///
    public void WaitForFiguresToDie()
    {
      mcr.WaitForFiguresToDie();
    }



    #endregion Methods

    #region Class Members

    private static MWMCR mcr= null;

    private static Exception ex_= null;

    private bool disposed= false;

    #endregion Class Members
  }
}
