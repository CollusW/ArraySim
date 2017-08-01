% /*!
%  *  @brief     This script is used to simulate multi-antenna performance .
%  *  @details   Null
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author   Wayne Zhang
%  *  @version   1.0
%  *  @date      2017.07.13
%  *  @copyright Wayne Zhang all rights reserved.
%  *  @remark   { revision history: V1.0, 2017.07.13. Wayne Zhang, first draft. }
%  *  @remark   { revision history: V1.0, 2017.07.28. Wayne Zhang, add anti-interference simulation. }
%  */

%% clear
clear all %#ok<CLALL>
close all
clc

%% declare 'ScriptCall'
% declare this var to call mainArraySimRxBF using the parameter specified by this script.
ScriptCall = 1;
% dbstop if warning;

%% Start Timer
tStart = tic;
fprintf('############################### SIMULATION BEGIN ###############################\n')

%% SIMULATION CASE: DOA ERROR - SNR
% simulation setup: CBF/ToolboxMusicEstimator2D/MUSIC, NumTarget = 1, target angle = [-30, 30]random; no interference;  SNR = -10:3:20dB;  NumLoop = 1e4;
fprintf('\n=================== SIMULATION CASE: DOA ERROR - SNR ===================\n')
NumLoop = 1e4;
SNRVector = -10:3:20;
azimuthVector = -30:30;
DoaEstiRange = {'CBF', 'MUSIC', 'AntiInterMUSIC'};
doaErrVector = zeros(NumLoop, length(SNRVector), length(DoaEstiRange));
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.AntennaType = 'Custom';
sysPara.ArrayType = 'Conformal';
sysPara.StvIncludeElementResponse = true;
sysPara.TargetSigType = 'QPSK';
sysPara.NumTarget = 1;
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.SwitchAWGN = true;
sysPara.GlobalDebugPlot = false;
sysPara.AzimuthScanAngles = [-35:0.5:35].';
sysPara.ElevationScanAngles = 0;
sysPara.FlagAnalyzeWaveform = false;
sysPara.FlagBeamforming = false;
sysPara.FlagDOAEsti = true;
sysPara.FlagPrintResult = false;
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idx = 1:length(DoaEstiRange)
    fprintf('\n------------------- Begin of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
    sysPara.DoaEstimator = DoaEstiRange{idx};
    for idxSNR = 1:length(SNRVector)
        fprintf('DoaEstiRange = %s, SNR = %d\n', DoaEstiRange{idx}, SNRVector(idxSNR));
        sysPara.TargetAngle = [azimuthVector(randi(length(azimuthVector)));0];
        sysPara.SNR = SNRVector(idxSNR);
        for idxLoop = 1:NumLoop
            mainArraySimRxBF
            doaErrVector(idxLoop, idxSNR, idx) = doaErr(1,1);
            if mod(idxLoop, floor(NumLoop/10)) == 0
                fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
            end
        end
    end
    fprintf('\n------------------- End of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
end

figure(11);
hold off;
plot(SNRVector, rms(doaErrVector(:,:,1)), 'dk-');
hold on;
plot(SNRVector, rms(doaErrVector(:,:,2)), 'sb-');
plot(SNRVector, rms(doaErrVector(:,:,3)), 'or-');
grid on;
legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
title('DOA Std Err - SNR');
xlabel('SNR/dB');
ylabel('DOA Err/degree');

figure(12);
hold off;
plot(SNRVector, mean(doaErrVector(:,:,1)), 'dk-');
hold on;
plot(SNRVector, mean(doaErrVector(:,:,2)), 'sb-');
plot(SNRVector, mean(doaErrVector(:,:,3)), 'or-');
grid on;
legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
title('DOA Err Mean - SNR');
xlabel('SNR/dB');
ylabel('DOA Err/degree');

figure(13);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,1), distrVector)/size(doaErrVector, 1);
surf(SNRVector, distrVector, freqDistr);
grid on;
title('CBF DOA Err Distribution - SNR');
xlabel('SNR/dB');
ylabel('DOA Err/degree');
zlabel('PDF');

figure(14);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,2), distrVector)/size(doaErrVector, 1);
surf(SNRVector, distrVector, freqDistr);
grid on;
title('MUSIC DOA Err Distribution - SNR');
xlabel('SNR/dB');
ylabel('DOA Err/degree');
zlabel('PDF');

figure(15);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,3), distrVector)/size(doaErrVector, 1);
surf(SNRVector, distrVector, freqDistr);
grid on;
title('Anti-Inter MUSIC DOA Err Distribution - SNR');
xlabel('SNR/dB');
ylabel('DOA Err/degree');
zlabel('PDF');

%% SIMULATION CASE: DOA ERROR - AZIMUTH
% simulation setup: CBF/ToolboxMusicEstimator2D/MUSIC, NumTarget = 1, target angle = [-30, 30]; no interference;  SNR = 0dB;  NumLoop = 1e5;
fprintf('\n=================== SIMULATION CASE: DOA ERROR - AZIMUTH ===================\n')
NumLoop = 1e5;
azimuthVector = -30:3:30;
DoaEstiRange = {'CBF', 'MUSIC', 'AntiInterMUSIC'};
doaErrVector = zeros(NumLoop, length(azimuthVector), length(DoaEstiRange));
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.AntennaType = 'Custom';
sysPara.ArrayType = 'Conformal';
sysPara.StvIncludeElementResponse = true;
sysPara.TargetSigType = 'QPSK';
sysPara.NumTarget = 1;
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.SwitchAWGN = true;
sysPara.SNR = 5;
sysPara.GlobalDebugPlot = false;
sysPara.AzimuthScanAngles = [-35:0.5:35].';
sysPara.ElevationScanAngles = 0;
sysPara.FlagAnalyzeWaveform = false;
sysPara.FlagBeamforming = false;
sysPara.FlagDOAEsti = true;
sysPara.FlagPrintResult = false;
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idx = 1:length(DoaEstiRange)
    fprintf('\n------------------- Begin of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
    sysPara.DoaEstimator = DoaEstiRange{idx};
    for idxAzimuth = 1:length(azimuthVector)
        fprintf('DoaEstiRange = %s, Azimuth = %d\n', DoaEstiRange{idx}, azimuthVector(idxAzimuth));
        sysPara.TargetAngle = [azimuthVector(idxAzimuth); 0];
        for idxLoop = 1:NumLoop
            mainArraySimRxBF
            doaErrVector(idxLoop, idxAzimuth, idx) = doaErr(1,1);
            if mod(idxLoop, floor(NumLoop/10)) == 0
                fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
            end
        end
    end
    fprintf('\n------------------- End of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
end

figure(21);
hold off;
plot(azimuthVector, rms(doaErrVector(:,:,1)), 'dk-');
hold on;
plot(azimuthVector, rms(doaErrVector(:,:,2)), 'sb-');
plot(azimuthVector, rms(doaErrVector(:,:,3)), 'or-');
grid on;
legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
title('DOA Std Err - Azimuth');
xlabel('Azimuth/degree');
ylabel('DOA Err/degree');

figure(22);
hold off;
plot(azimuthVector, mean(doaErrVector(:,:,1)), 'dk-');
hold on;
plot(azimuthVector, mean(doaErrVector(:,:,2)), 'sb-');
plot(azimuthVector, mean(doaErrVector(:,:,3)), 'or-');
grid on;
legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
title('DOA Err Mean - Azimuth');
xlabel('Azimuth/degree');
ylabel('DOA Err/degree');

figure(23);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,1), distrVector)/size(doaErrVector, 1);
surf(azimuthVector, distrVector, freqDistr);
grid on;
title('CBF DOA Err Distribution - Azimuth');
xlabel('Azimuth/degree');
ylabel('DOA Err/degree');
zlabel('PDF');

figure(24);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,2), distrVector)/size(doaErrVector, 1);
surf(azimuthVector, distrVector, freqDistr);
grid on;
title('MUSIC DOA Err Distribution - Azimuth');
xlabel('Azimuth/degree');
ylabel('DOA Err/degree');
zlabel('PDF');

figure(25);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,3), distrVector)/size(doaErrVector, 1);
surf(azimuthVector, distrVector, freqDistr);
grid on;
title('Anti-Inter MUSIC DOA Err Distribution - Azimuth');
xlabel('Azimuth/degree');
ylabel('DOA Err/degree');
zlabel('PDF');

%% SIMULATION CASE: DIRECTIVITY - AZIMUTH
% simulation setup: MMSE/LMS, NumTarget = 1, target angle = [-30, 30]; no interference;  SNR = 20dB;  NumLoop = 1e4;
fprintf('\n=================== SIMULATION CASE: DIRECTIVITY - AZIMUTH ===================\n')
NumLoop = 1e4;
azimuthVector = -30:3:30;
BeamformerTypeRange = {'MMSE', 'LMS'};
directivityVector = zeros(NumLoop, length(azimuthVector), length(BeamformerTypeRange));
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.AntennaType = 'Custom';
sysPara.ArrayType = 'Conformal';
sysPara.StvIncludeElementResponse = true;
sysPara.TargetSigType = 'QPSK';
sysPara.NumTarget = 1;
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.SwitchAWGN = true;
sysPara.SNR = 20;
sysPara.GlobalDebugPlot = false;
sysPara.FlagAnalyzeWaveform = false;
sysPara.FlagBeamforming = true;
sysPara.FlagDOAEsti = false;
sysPara.FlagPrintResult = false;
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idx = 1:length(BeamformerTypeRange)
    fprintf('\n------------------- Begin of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
    sysPara.BeamformerType = BeamformerTypeRange{idx};
    for idxAzimuth = 1:length(azimuthVector)
        fprintf('BeamformerTypeRange = %s, Azimuth = %d\n', BeamformerTypeRange{idx}, azimuthVector(idxAzimuth));
        sysPara.TargetAngle = [azimuthVector(idxAzimuth); 0];
        for idxLoop = 1:NumLoop
            mainArraySimRxBF
            directivityVector(idxLoop, idxAzimuth, idx) = directivity(hArray, sysPara.FreqCenter, sysPara.TargetAngle, 'Weights', weight);
            if mod(idxLoop, floor(NumLoop/10)) == 0
                fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
            end
        end
    end
    fprintf('\n------------------- End of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
end

figure(31);
hold off;
plot(azimuthVector, mean(directivityVector(:,:,1)), 'dk-');
hold on;
plot(azimuthVector, mean(directivityVector(:,:,2)), 'sb-');
grid on;
legend('MMSE', 'LMS');
title('Directivity - Azimuth');
xlabel('Azimuth/degree');
ylabel('Directivity/dBi');

figure(32);
hold off;
plot(azimuthVector, rms(directivityVector(:,:,1) - repmat(mean(directivityVector(:,:,1)), size(directivityVector, 1), 1)), 'dk-');
hold on;
plot(azimuthVector, rms(directivityVector(:,:,2) - repmat(mean(directivityVector(:,:,2)), size(directivityVector, 1), 1)), 'sb-');
grid on;
legend('MMSE', 'LMS');
title('Directivity Std Err - Azimuth');
xlabel('Azimuth/degree');
ylabel('Directivity Err/dBi');

figure(33);
hold off;
plot(azimuthVector, max(directivityVector(:,:,1)), 'db-');
hold on;
plot(azimuthVector, min(directivityVector(:,:,1)), 'sb-');
plot(azimuthVector, max(directivityVector(:,:,2)), 'dk-');
plot(azimuthVector, min(directivityVector(:,:,2)), 'sk-');
grid on;
legend('MMSE Upper', 'MMSE Lower', 'LMS Upper', 'LMS Lower');
title('Directivity Bound - Azimuth');
xlabel('Azimuth/degree');
ylabel('Directivity/dBi');

%% SIMULATION CASE: INTERFERENCE REJECTION - SIR
% simulation setup: MMSE/LMS, NumTarget = 1, target angle = [0]; Interference angle = [16]; SIR = [-10:20]dB;  SNR = 20dB;  NumLoop = 1e4;
fprintf('\n=================== SIMULATION CASE: INTERFERENCE REJECTION - AZIMUTH ===================\n')
NumLoop = 1e4;
SIR = -10:5:20;
BeamformerTypeRange = {'MMSE', 'LMS'};
interRejectVector = zeros(NumLoop, length(SIR), length(BeamformerTypeRange));
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.AntennaType = 'Custom';
sysPara.ArrayType = 'Conformal';
sysPara.StvIncludeElementResponse = true;
sysPara.TargetSigType = 'QPSK';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [0; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = true;
sysPara.InterferenceType = 'Sine';
sysPara.NumInterference = 1;
sysPara.InterferenceFreq = 10e6;
sysPara.InterferenceAngle = [8; 0];
sysPara.SwitchAWGN = true;
sysPara.SNR = 20;
sysPara.GlobalDebugPlot = false;
sysPara.FlagAnalyzeWaveform = false;
sysPara.FlagBeamforming = true;
sysPara.FlagDOAEsti = false;
sysPara.FlagPrintResult = false;
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idx = 1:length(BeamformerTypeRange)
    fprintf('\n------------------- Begin of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
    sysPara.BeamformerType = BeamformerTypeRange{idx};
    for idxSIR = 1:length(SIR)
        fprintf('BeamformerTypeRange = %s, SIR = %d\n', BeamformerTypeRange{idx}, SIR(idxSIR));
        sysPara.SIR = SIR(idxSIR);
        for idxLoop = 1:NumLoop
            mainArraySimRxBF
            interRejectVector(idxLoop, idxSIR, idx) = directivity(hArray, sysPara.FreqCenter, sysPara.TargetAngle, 'Weights', weight) - ...
                directivity(hArray, sysPara.FreqCenter, sysPara.InterferenceAngle, 'Weights', weight);
            if mod(idxLoop, floor(NumLoop/10)) == 0
                fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
            end
        end
    end
    fprintf('\n------------------- End of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
end

figure(41);
hold off;
plot(SIR, mean(interRejectVector(:,:,1)), 'dk-');
hold on;
plot(SIR, mean(interRejectVector(:,:,2)), 'sb-');
grid on;
legend('MMSE', 'LMS');
title('Interference Rejection - SIR');
xlabel('SIR/dB');
ylabel('Inter-Reject/dB');

figure(42);
hold off;
plot(SIR, rms(interRejectVector(:,:,1) - repmat(mean(interRejectVector(:,:,1)), size(interRejectVector, 1), 1)), 'dk-');
hold on;
plot(SIR, rms(interRejectVector(:,:,2) - repmat(mean(interRejectVector(:,:,2)), size(interRejectVector, 1), 1)), 'sb-');
grid on;
legend('MMSE', 'LMS');
title('Interference Rejection Std Err - Azimuth');
xlabel('SIR/dB');
ylabel('Inter-Reject Std Err');

figure(43);
hold off;
plot(SIR, max(interRejectVector(:,:,1)), 'db-');
hold on;
plot(SIR, min(interRejectVector(:,:,1)), 'sb-');
plot(SIR, max(interRejectVector(:,:,2)), 'dk-');
plot(SIR, min(interRejectVector(:,:,2)), 'sk-');
grid on;
legend('MMSE Upper', 'MMSE Lower', 'LMS Upper', 'LMS Lower');
title('Interference Rejection Bound - Azimuth');
xlabel('SIR/dB');
ylabel('Inter-Reject/dB');
