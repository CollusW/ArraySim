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
NumLoop = 1e1;
SNRVector = -10:3:20;
azimuthVector = -30:30;
DoaEstiRange = {'CBF', 'MUSIC', 'AntiInterMUSIC'};
doaErrVector = zeros(NumLoop, length(SNRVector), length(DoaEstiRange));
sysPara = GenSysPara();                         %% Gen. System para.
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

figure(1);
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

figure(2);
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

figure(3);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,1), distrVector)/size(doaErrVector, 1);
surf(SNRVector, distrVector, freqDistr);
grid on;
title('CBF DOA Err Distribution - SNR');
xlabel('SNR/dB');
ylabel('DOA Err/degree');
zlabel('PDF');

figure(4);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,2), distrVector)/size(doaErrVector, 1);
surf(SNRVector, distrVector, freqDistr);
grid on;
title('MUSIC DOA Err Distribution - SNR');
xlabel('SNR/dB');
ylabel('DOA Err/degree');
zlabel('PDF');

figure(5);
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
% simulation setup: CBF/ToolboxMusicEstimator2D/MUSIC, NumTarget = 1, target angle = [-30, 30]; no interference;  SNR = 0dB;  NumLoop = 1e4;
fprintf('\n=================== SIMULATION CASE: DOA ERROR - AZIMUTH ===================\n')
NumLoop = 1e1;
azimuthVector = -30:30;
DoaEstiRange = {'CBF', 'MUSIC', 'AntiInterMUSIC'};
doaErrVector = zeros(NumLoop, length(azimuthVector), length(DoaEstiRange));
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = 'QPSK';
sysPara.NumTarget = 1;
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.SwitchAWGN = true;
sysPara.SNR = 0;
sysPara.GlobalDebugPlot = false;
sysPara.AzimuthScanAngles = [-35:0.5:35].';
sysPara.ElevationScanAngles = 0;
sysPara.FlagAnalyzeWaveform = false;
sysPara.FlagBeamforming = false;
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

figure(11);
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

figure(12);
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

figure(13);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,1), distrVector)/size(doaErrVector, 1);
surf(azimuthVector, distrVector, freqDistr);
grid on;
title('CBF DOA Err Distribution - Azimuth');
xlabel('Azimuth/degree');
ylabel('DOA Err/degree');
zlabel('PDF');

figure(14);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,2), distrVector)/size(doaErrVector, 1);
surf(azimuthVector, distrVector, freqDistr);
grid on;
title('MUSIC DOA Err Distribution - Azimuth');
xlabel('Azimuth/degree');
ylabel('DOA Err/degree');
zlabel('PDF');

figure(15);
hold off;
distrVector = -4:0.5:4;
freqDistr = hist(doaErrVector(:,:,3), distrVector)/size(doaErrVector, 1);
surf(azimuthVector, distrVector, freqDistr);
grid on;
title('Anti-Inter MUSIC DOA Err Distribution - Azimuth');
xlabel('Azimuth/degree');
ylabel('DOA Err/degree');
zlabel('PDF');

