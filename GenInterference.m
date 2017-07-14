function [ waveformInt] = GenInterference(sysPara, hArray)
% /*!
%  *  @brief     This function generate the interference.
%  *  @details   . 
%  *  @param[out] waveformInt, NxM complex doulbe. array response to the interference, i.e. interference waveform response at each antenna. N is the number of samples(snaps). M is the number of channel
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
%  * @remark   { revision history: V1.1, 2017.07.12. Collus Wang, steering vector calculation can include element response.}
%  */

%% get used field
SwitchInterence = sysPara.SwitchInterence; 
InterferenceType = sysPara.InterferenceType;
NumInterference = sysPara.NumInterference;
InterferenceAngle = sysPara.InterferenceAngle;
SIR = sysPara.SIR;                    % SIR in dB.
InterferenceFreq = sysPara.InterferenceFreq;    % double scaler. interfence frequency at baseband, in Hz.
Duration = sysPara.Duration;
SampleRate = sysPara.SampleRate;
FreqCenter = sysPara.FreqCenter;
StvIncludeElementResponse = sysPara.StvIncludeElementResponse;

%% Flags
GlobalDebugPlot = sysPara.GlobalDebugPlot;
FlagDebugPlot = true && GlobalDebugPlot;
figureStartNum = 4000;

%% preprocess
if ~isvector(SIR)
    error('SIR should be column vector.');
elseif isrow(SIR)
    SIR = SIR.';
end

%% process
if ~SwitchInterence
    intLen = round(Duration*SampleRate);
    waveformInt = zeros(intLen, NumElements);
    return;
end
    
switch lower(InterferenceType)
    case 'sine'
        len = round(Duration*SampleRate);
        pwrInt = db2pow(-SIR);   % interference power. assume signal power = 1;
        waveformOriginal = exp(1j*2*pi*InterferenceFreq*(0:len-1)/SampleRate).'*diag(sqrt(pwrInt));
    otherwise
        error('Unsupported interfence type.')
end

if FlagDebugPlot
    figure(figureStartNum+0);clf;
    subplot(211)
    plot(waveformOriginal,'.-');axis equal;
    title('waveform Interference');
    subplot(212)
    plot(real(waveformOriginal),'.-');
    fprintf('Interference waveform RMS = %2.2f\n', rms(waveformOriginal));
end


% waveformInt = collectPlaneWave( hArray, waveformOriginal,  InterferenceAngle, FreqCenter);      % collectPlaneWave donot count for element response. use SteeringVector in future.    
hSteeringVector = phased.SteeringVector('SensorArray', hArray,...
    'PropagationSpeed', physconst('LightSpeed'),...
    'IncludeElementResponse', StvIncludeElementResponse,...
    'NumPhaseShifterBits', 0 ...   %'EnablePolarization', false ...
    );
steeringVector = step(hSteeringVector, FreqCenter, InterferenceAngle);
steeringVector = steeringVector*diag(rms(steeringVector).^-1); % in case of IncludeElementResponse=true. Normalize to 1, but keep element response
waveformInt = waveformOriginal*steeringVector.';
