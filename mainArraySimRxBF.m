% /*!
%  *  @brief    mainArraySimRxBF.m. This script is used to simulate the RX beamforming.
%  *  @details  .
%  *  @pre      .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.05.25
%  *  @copyright Collus Wang all rights reserved.
%  *  @remark   { revision history: V1.0 2017.05.25. Collus Wang, first draft }
%  *  @remark   { revision history: V1.1 2017.06.30. Collus Wang, add ScriptCall feature }
%  */

%% check if this script is called by other script, if not, then clear and defined parameters
if ~exist('ScriptCall', 'var')
    %% clear
    clear all
    close all
    clc
    tic
    
    %% prepare
    sysPara = GenSysPara();                         %% Gen. System para.
    ShowConfiguration(sysPara);                     %% print simulation configuration.
    hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
    hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
end
[waveformArray, waveformSignal, steeringVector] = GenSignal(sysPara, hArray);       %% Gen. signal
waveformInt = GenInterference(sysPara, hArray); %% Gen. interference
waveformNoise = GenNoise(sysPara, hArray);      %% Gen. noise
%% Rx
waveformRx = waveformArray + waveformInt + waveformNoise;           %% Rx waveform
if sysPara.FlagAnalyzeWaveform
    [snrSingle, berSingle, evmSingle] = AnalyzeWaveform(sysPara, waveformRx(:,1)*conj(steeringVector(1)), waveformArray(:,1)*conj(steeringVector(1)), 10000);  %% analze single antenna result. cal SNR BER EVM etc.
end
%% Beamforming
if sysPara.FlagBeamforming
    weight = GenWeight(sysPara, hArray, waveformRx, waveformSignal);             %% Gen. Beamforming weight
    waveformBeamform = RxBeamforming(sysPara, waveformRx, weight);               %% Beamforming
end
%% analyze Beamforming
if sysPara.FlagAnalyzeWaveform
    [snrBf, berBf, evmBf] = AnalyzeWaveform(sysPara, waveformBeamform, waveformSignal, 20000);                 %% analze beamforming result. cal SNR BER EVM etc.
    gainSnr = snrBf - snrSingle;
    gainBer = berSingle - berBf;
    gainEvm = evmSingle - evmBf;
end
%% DOA estimation
if sysPara.FlagDOAEsti
    [doa, spatialSpectrum] = DoaEstimation(sysPara, hArray, waveformRx, waveformSignal);
    doaErr = sysPara.TargetAngle - doa;
end
%% print result
if sysPara.FlagPrintResult
    fprintf('\n------------Report Results----------------\n')
    fprintf('\n----Beamforming----\n')
    if sysPara.FlagBeamforming
        fprintf('Sigle antenna:\n')
        fprintf('\tSNR = %.2f (dB)\n', snrSingle);
        fprintf('\tBER = %.1e = %.2f%%\n', berSingle, berSingle*100);
        fprintf('\tEVM = %.2f%% \n\n', evmSingle);
        fprintf('Multi-antenna:\n')
        for idxTarget = 1:sysPara.NumTarget
            fprintf('Target #%d:\n', idxTarget);
            fprintf('Multi-antenna:\n')
            fprintf('\tSNR = %.2f (dB)\n', snrBf(idxTarget));
            fprintf('\tBER = %.1e = %.2f%%\n', berBf(idxTarget), berBf(idxTarget)*100);
            fprintf('\tEVM = %.2f%% \n', evmBf(idxTarget));
            fprintf('Multi-antenna Gain:\n')
            fprintf('\tSNR Gain = %.2f (dB)\n', gainSnr(idxTarget));
            fprintf('\tBER Gain = %.1e = %.2f%%\n', gainBer(idxTarget), gainBer(idxTarget)*100);
            fprintf('\tEVM Gain = %.2f%% \n', gainEvm(idxTarget));
        end
    end
    
    if sysPara.FlagDOAEsti
        fprintf('\n----DOA Estimation----\n')
        for idxDoa = 1:size(doa, 2)
            fprintf('\tDOA #%2d: [AZ, EL] = [%+7.2f, %+7.2f] (degree)\n', idxDoa, doa(1,idxDoa), doa(2,idxDoa));
            fprintf('\t            Error = [%+7.2f, %+7.2f] (degree)\n',  doaErr(1,idxDoa), doaErr(2,idxDoa));
        end
    end
    fprintf('\n------------End of Report-----------------\n')
    if ~exist('ScriptCall', 'var'), toc, end % print elapsed time
end