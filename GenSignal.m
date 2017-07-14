function [ waveformArray, waveformSignal, steeringVector] = GenSignal(sysPara, hArray)
% /*!
%  *  @brief     This function generate the target signal.
%  *  @details   . 
%  *  @param[out] waveformArray, NxM complex doulbe. array response, i.e. signal waveform response at each antenna. N is the number of samples(snaps). M is the number of channel
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
%  * @remark   { revision history: V1.1, 2017.06.22. Collus Wang,  support 16QAM and 64QAM }
%  * @remark   { revision history: V1.2, 2017.07.12. Collus Wang, steering vector calculation can include element response.}
%  */

%% get used field
TargetSigType = sysPara.TargetSigType;      % valid value = {'QPSK', '16QAM', '64QAM'}
NumTarget = sysPara.NumTarget;              % 
TargetAngle = sysPara.TargetAngle;          % incoming wave direction in degree, [azimuth; elevation]. The azimuth angle must be between ¨C180 and 180 degrees, and the elevation angle must be between ¨C90 and 90 degrees.
FreqCenter = sysPara.FreqCenter;
Duration = sysPara.Duration;
SymbolRate = sysPara.SymbolRate;
NumElements = getNumElements(hArray);
LenWaveform = sysPara.LenWaveform;
TargetPower = sysPara.TargetPower;
StvIncludeElementResponse = sysPara.StvIncludeElementResponse;

%% Flags
GlobalDebugPlot = sysPara.GlobalDebugPlot;
FlagDebugPlot = true && GlobalDebugPlot;
figureStartNum = 3000;

%% Gen. signal
waveformSignal = zeros(LenWaveform, NumTarget);
switch lower(TargetSigType)
    case 'qpsk'
        BitPerSym = 2;
        numBit = round(Duration*SymbolRate*BitPerSym*NumTarget);
        txBits = randi([0, 1], numBit,1);
        % bits map to constellations
        symbols = SymbolMap(txBits, 'QPSK');
        waveformSignal = reshape(symbols, [],NumTarget);
    case '16qam'
        BitPerSym = 4;
        numBit = round(Duration*SymbolRate*BitPerSym*NumTarget);
        txBits = randi([0, 1], numBit,1);
        % bits map to constellations
        symbols = SymbolMap(txBits, '16QAM');
        waveformSignal = reshape(symbols, [],NumTarget);
    case '64qam'
        BitPerSym = 6;
        numBit = round(Duration*SymbolRate*BitPerSym*NumTarget);
        txBits = randi([0, 1], numBit,1);
        % bits map to constellations
        symbols = SymbolMap(txBits, '64QAM');
        waveformSignal = reshape(symbols, [],NumTarget);
    otherwise
        error('Unsupported signal type.')
end

amp = db2mag(TargetPower);
waveformSignal = waveformSignal*diag(amp);

if FlagDebugPlot
    figure(figureStartNum+0);clf;
    plot(waveformSignal,'o-');axis equal;
    title('waveformTx');
    fprintf('waveformTx RMS = %2.2f\n', rms(waveformSignal));
end

% waveformArray = collectPlaneWave( hArray, waveformSignal,  TargetAngle, FreqCenter);      % collectPlaneWave donot count for element response. use SteeringVector in future.    
hSteeringVector = phased.SteeringVector('SensorArray', hArray,...
    'PropagationSpeed', physconst('LightSpeed'),...
    'IncludeElementResponse', StvIncludeElementResponse,...
    'NumPhaseShifterBits', 0 ...    'EnablePolarization', false ...
    );
steeringVector = step(hSteeringVector, FreqCenter, TargetAngle);
steeringVector = steeringVector/rms(steeringVector); % in case of IncludeElementResponse=true. Normalize to 1, but keep element response
waveformArray = waveformSignal*steeringVector.';

if FlagDebugPlot
    figure(figureStartNum+100);clf;
    plot(waveformArray(:,1),'o-');axis equal;
    title('waveformSig on the first sensor');
    fprintf('Signal waveform RMS on each anntenna:\n')
    for idxAntenna = 1:NumElements
        fprintf('\tChannel %d = %2.2f = %2.2fdB\n', idxAntenna, rms(waveformArray(:,idxAntenna)), mag2db(rms(waveformArray(:,idxAntenna))) );
    end
end
    
    
    
    
    
    
    
