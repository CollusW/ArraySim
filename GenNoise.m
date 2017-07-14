function [ waveformNoise] = GenNoise(sysPara, hArray)
% /*!
%  *  @brief     This function create Antenna system object.
%  *  @details   . 
%  *  @param[out] waveformNoise, NxM complex doulbe. rx noise at each antenna. N is the number of samples(snaps). M is the number of channel
%  *  @param[out] waveformSignal, Nx1 complex doulbe. signal waveform. N is the number of samples(snaps).
%  *  @param[out] steeringVector, Mx1 complex doulbe. steeringVector of the array according to the input signal.M is the number of channel
%  *  @param[in] sysPara, 1x1 struct, which contains the following field:
%       see get used field for detail.
%  *  @param[in] hArray, 1x1 antenna array system object.
%  *  @pre       .
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.05.25.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.05.25. Collus Wang,  first draft }
%  */

%% get used field
SwitchAWGN = sysPara.SwitchAWGN; 
Duration = sysPara.Duration;
SampleRate = sysPara.SampleRate;
NumElements = getNumElements(hArray);
SNR = sysPara.SNR;

%% Flags
GlobalDebugPlot = sysPara.GlobalDebugPlot;
FlagDebugPlot = true && GlobalDebugPlot;

%% process
noiseLen = round(Duration*SampleRate);
if ~SwitchAWGN
    waveformNoise = zeros(noiseLen, NumElements);
    return;
end

pwrNoise = db2pow(-SNR);   % noise power. assume signal power = 1;
waveformNoise = (randn(noiseLen, NumElements)+1j*randn(noiseLen, NumElements))*sqrt(pwrNoise/2);    % Gaussian noise, white






