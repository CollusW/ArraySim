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

% %% SIMULATION CASE: DOA ERROR - SNR
% % simulation setup: CBF/MUSIC/AntiInterMUSIC, NumTarget = 1, target angle = [-30, 30]random; no interference;  SNR = -10:3:20dB;  NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: DOA ERROR - SNR ===================\n')
% NumLoop = 1e4;
% SNRVector = -10:3:20;
% azimuthVector = -30:30;
% DoaEstiRange = {'CBF', 'MUSIC', 'AntiInterMUSIC'};
% doaErrVector = zeros(NumLoop, length(SNRVector), length(DoaEstiRange));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = false;
% sysPara.SwitchInterence = false;
% sysPara.SwitchAWGN = true;
% sysPara.DOAIncludeElementResponse = false;
% sysPara.GlobalDebugPlot = false;
% sysPara.AzimuthScanAngles = (-35:0.5:35).';
% sysPara.ElevationScanAngles = 0;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = false;
% sysPara.FlagDOAEsti = true;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %#ok<NASGU> %% Gen. array
% for idx = 1:length(DoaEstiRange)
%     fprintf('\n------------------- Begin of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
%     sysPara.DoaEstimator = DoaEstiRange{idx};
%     for idxSNR = 1:length(SNRVector)
%         fprintf('DoaEstiRange = %s, SNR = %d\n', DoaEstiRange{idx}, SNRVector(idxSNR));
%         sysPara.TargetAngle = [azimuthVector(randi(length(azimuthVector)));0];
%         sysPara.SNR = SNRVector(idxSNR);
%         for idxLoop = 1:NumLoop
%             mainArraySimRxBF
%             doaErrVector(idxLoop, idxSNR, idx) = doaErr(1,1);
%             if mod(idxLoop, floor(NumLoop/10)) == 0
%                 fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%             end
%         end
%     end
%     fprintf('\n------------------- End of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
% end
% 
% NumFigure = 100;
% figure(NumFigure + 1);
% hold off;
% plot(SNRVector, rms(doaErrVector(:,:,1)), 'dk-');
% hold on;
% plot(SNRVector, rms(doaErrVector(:,:,2)), 'sb-');
% plot(SNRVector, rms(doaErrVector(:,:,3)), 'or-');
% grid on;
% legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
% title('DOA Std Err - SNR');
% xlabel('SNR/dB');
% ylabel('DOA Err/degree');
% 
% figure(NumFigure + 2);
% hold off;
% plot(SNRVector, mean(doaErrVector(:,:,1)), 'dk-');
% hold on;
% plot(SNRVector, mean(doaErrVector(:,:,2)), 'sb-');
% plot(SNRVector, mean(doaErrVector(:,:,3)), 'or-');
% grid on;
% legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
% title('DOA Err Mean - SNR');
% xlabel('SNR/dB');
% ylabel('DOA Err/degree');
% 
% figure(NumFigure + 3);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,1), distrVector)/size(doaErrVector, 1);
% surf(SNRVector, distrVector, freqDistr);
% grid on;
% title('CBF DOA Err Distribution - SNR');
% xlabel('SNR/dB');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% figure(NumFigure + 4);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,2), distrVector)/size(doaErrVector, 1);
% surf(SNRVector, distrVector, freqDistr);
% grid on;
% title('MUSIC DOA Err Distribution - SNR');
% xlabel('SNR/dB');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% figure(NumFigure + 5);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,3), distrVector)/size(doaErrVector, 1);
% surf(SNRVector, distrVector, freqDistr);
% grid on;
% title('Anti-Inter MUSIC DOA Err Distribution - SNR');
% xlabel('SNR/dB');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% %% SIMULATION CASE: DOA ERROR - SIR
% % simulation setup: CBF/MUSIC/AntiInterMUSIC, NumTarget = 1, target angle = [0]; Interference angle = [11]; SIR = [-10:3:20]dB;  SNR = 20dB;  NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: DOA ERROR - SIR ===================\n')
% NumLoop = 1e4;
% SIRVector = -10:3:20;
% DoaEstiRange = {'CBF', 'MUSIC', 'AntiInterMUSIC'};
% doaErrVector = zeros(NumLoop, length(SIRVector), length(DoaEstiRange));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetAngle = [0;0];
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = false;
% sysPara.SwitchInterence = true;
% sysPara.InterferenceType = 'Sine';
% sysPara.NumInterference = 1;
% sysPara.InterferenceFreq = 10e6;
% sysPara.InterferenceAngle = [11; 0];
% sysPara.SwitchAWGN = true;
% sysPara.SNR = 20;
% sysPara.DOAIncludeElementResponse = false;
% sysPara.GlobalDebugPlot = false;
% sysPara.AzimuthScanAngles = (-35:0.5:35).';
% sysPara.ElevationScanAngles = 0;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = false;
% sysPara.FlagDOAEsti = true;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %#ok<NASGU> %% Gen. array
% for idx = 1:length(DoaEstiRange)
%     fprintf('\n------------------- Begin of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
%     sysPara.DoaEstimator = DoaEstiRange{idx};
%     for idxSIR = 1:length(SIRVector)
%         fprintf('DoaEstiRange = %s, SIR = %d\n', DoaEstiRange{idx}, SIRVector(idxSIR));
%         sysPara.SIR = SIRVector(idxSIR);
%         for idxLoop = 1:NumLoop
%             mainArraySimRxBF
%             doaErrVector(idxLoop, idxSIR, idx) = doaErr(1,1);
%             if mod(idxLoop, floor(NumLoop/10)) == 0
%                 fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%             end
%         end
%     end
%     fprintf('\n------------------- End of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
% end
% 
% NumFigure = 200;
% figure(NumFigure + 1);
% hold off;
% plot(SIRVector, rms(doaErrVector(:,:,1)), 'dk-');
% hold on;
% plot(SIRVector, rms(doaErrVector(:,:,2)), 'sb-');
% plot(SIRVector, rms(doaErrVector(:,:,3)), 'or-');
% grid on;
% legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
% title('DOA Std Err - SIR');
% xlabel('SIR/dB');
% ylabel('DOA Err/degree');
% 
% figure(NumFigure + 2);
% hold off;
% plot(SIRVector, mean(doaErrVector(:,:,1)), 'dk-');
% hold on;
% plot(SIRVector, mean(doaErrVector(:,:,2)), 'sb-');
% plot(SIRVector, mean(doaErrVector(:,:,3)), 'or-');
% grid on;
% legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
% title('DOA Err Mean - SIR');
% xlabel('SIR/dB');
% ylabel('DOA Err/degree');
% 
% figure(NumFigure + 3);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,1), distrVector)/size(doaErrVector, 1);
% surf(SIRVector, distrVector, freqDistr);
% grid on;
% title('CBF DOA Err Distribution - SIR');
% xlabel('SIR/dB');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% figure(NumFigure + 4);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,2), distrVector)/size(doaErrVector, 1);
% surf(SIRVector, distrVector, freqDistr);
% grid on;
% title('MUSIC DOA Err Distribution - SIR');
% xlabel('SIR/dB');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% figure(NumFigure + 5);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,3), distrVector)/size(doaErrVector, 1);
% surf(SIRVector, distrVector, freqDistr);
% grid on;
% title('Anti-Inter MUSIC DOA Err Distribution - SIR');
% xlabel('SIR/dB');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% %% SIMULATION CASE: DOA ERROR - AZIMUTH
% % simulation setup: CBF/MUSIC/AntiInterMUSIC, NumTarget = 1, target angle = [-30, 30]; no interference;  SNR = 0dB;  NumLoop = 1e5;
% fprintf('\n=================== SIMULATION CASE: DOA ERROR - AZIMUTH ===================\n')
% NumLoop = 1e5;
% azimuthVector = -30:3:30;
% DoaEstiRange = {'CBF', 'MUSIC', 'AntiInterMUSIC'};
% doaErrVector = zeros(NumLoop, length(azimuthVector), length(DoaEstiRange));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = false;
% sysPara.SwitchInterence = false;
% sysPara.SwitchAWGN = true;
% sysPara.SNR = 5;
% sysPara.DOAIncludeElementResponse = false;
% sysPara.GlobalDebugPlot = false;
% sysPara.AzimuthScanAngles = (-35:0.5:35).';
% sysPara.ElevationScanAngles = 0;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = false;
% sysPara.FlagDOAEsti = true;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %#ok<NASGU> %% Gen. array
% for idx = 1:length(DoaEstiRange)
%     fprintf('\n------------------- Begin of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
%     sysPara.DoaEstimator = DoaEstiRange{idx};
%     for idxAzimuth = 1:length(azimuthVector)
%         fprintf('DoaEstiRange = %s, Azimuth = %d\n', DoaEstiRange{idx}, azimuthVector(idxAzimuth));
%         sysPara.TargetAngle = [azimuthVector(idxAzimuth); 0];
%         for idxLoop = 1:NumLoop
%             mainArraySimRxBF
%             doaErrVector(idxLoop, idxAzimuth, idx) = doaErr(1,1);
%             if mod(idxLoop, floor(NumLoop/10)) == 0
%                 fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%             end
%         end
%     end
%     fprintf('\n------------------- End of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
% end
% 
% NumFigure = 300;
% figure(NumFigure + 1);
% hold off;
% plot(azimuthVector, rms(doaErrVector(:,:,1)), 'dk-');
% hold on;
% plot(azimuthVector, rms(doaErrVector(:,:,2)), 'sb-');
% plot(azimuthVector, rms(doaErrVector(:,:,3)), 'or-');
% grid on;
% legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
% title('DOA Std Err - Azimuth');
% xlabel('Azimuth/degree');
% ylabel('DOA Err/degree');
% 
% figure(NumFigure + 2);
% hold off;
% plot(azimuthVector, mean(doaErrVector(:,:,1)), 'dk-');
% hold on;
% plot(azimuthVector, mean(doaErrVector(:,:,2)), 'sb-');
% plot(azimuthVector, mean(doaErrVector(:,:,3)), 'or-');
% grid on;
% legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
% title('DOA Err Mean - Azimuth');
% xlabel('Azimuth/degree');
% ylabel('DOA Err/degree');
% 
% figure(NumFigure + 3);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,1), distrVector)/size(doaErrVector, 1);
% surf(azimuthVector, distrVector, freqDistr);
% grid on;
% title('CBF DOA Err Distribution - Azimuth');
% xlabel('Azimuth/degree');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% figure(NumFigure + 4);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,2), distrVector)/size(doaErrVector, 1);
% surf(azimuthVector, distrVector, freqDistr);
% grid on;
% title('MUSIC DOA Err Distribution - Azimuth');
% xlabel('Azimuth/degree');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% figure(NumFigure + 5);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,3), distrVector)/size(doaErrVector, 1);
% surf(azimuthVector, distrVector, freqDistr);
% grid on;
% title('Anti-Inter MUSIC DOA Err Distribution - Azimuth');
% xlabel('Azimuth/degree');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% %% SIMULATION CASE: DIRECTIVITY - AZIMUTH
% % simulation setup: MMSE/LMS, NumTarget = 1, target angle = [-30, 30]; no interference;  SNR = 20dB;  NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: DIRECTIVITY - AZIMUTH ===================\n')
% NumLoop = 1e4;
% azimuthVector = -30:3:30;
% BeamformerTypeRange = {'MMSE', 'LMS'};
% directivityVector = zeros(NumLoop, length(azimuthVector), length(BeamformerTypeRange));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = false;
% sysPara.SwitchInterence = false;
% sysPara.SwitchAWGN = true;
% sysPara.SNR = 20;
% sysPara.GlobalDebugPlot = false;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = true;
% sysPara.FlagDOAEsti = false;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
% for idx = 1:length(BeamformerTypeRange)
%     fprintf('\n------------------- Begin of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
%     sysPara.BeamformerType = BeamformerTypeRange{idx};
%     for idxAzimuth = 1:length(azimuthVector)
%         fprintf('BeamformerTypeRange = %s, Azimuth = %d\n', BeamformerTypeRange{idx}, azimuthVector(idxAzimuth));
%         sysPara.TargetAngle = [azimuthVector(idxAzimuth); 0];
%         for idxLoop = 1:NumLoop
%             mainArraySimRxBF
%             directivityVector(idxLoop, idxAzimuth, idx) = directivity(hArray, sysPara.FreqCenter, sysPara.TargetAngle, 'Weights', weight);
%             if mod(idxLoop, floor(NumLoop/10)) == 0
%                 fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%             end
%         end
%     end
%     fprintf('\n------------------- End of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
% end
% 
% NumFigure = 400;
% figure(NumFigure + 1);
% hold off;
% plot(azimuthVector, mean(directivityVector(:,:,1)), 'dk-');
% hold on;
% plot(azimuthVector, mean(directivityVector(:,:,2)), 'sb-');
% grid on;
% legend('MMSE', 'LMS');
% title('Directivity - Azimuth');
% xlabel('Azimuth/degree');
% ylabel('Directivity/dBi');
% 
% figure(NumFigure + 2);
% hold off;
% plot(azimuthVector, rms(directivityVector(:,:,1) - repmat(mean(directivityVector(:,:,1)), size(directivityVector, 1), 1)), 'dk-');
% hold on;
% plot(azimuthVector, rms(directivityVector(:,:,2) - repmat(mean(directivityVector(:,:,2)), size(directivityVector, 1), 1)), 'sb-');
% grid on;
% legend('MMSE', 'LMS');
% title('Directivity Std Err - Azimuth');
% xlabel('Azimuth/degree');
% ylabel('Directivity Err/dBi');
% 
% figure(NumFigure + 3);
% hold off;
% plot(azimuthVector, max(directivityVector(:,:,1)), 'db-');
% hold on;
% plot(azimuthVector, min(directivityVector(:,:,1)), 'sb-');
% plot(azimuthVector, max(directivityVector(:,:,2)), 'dk-');
% plot(azimuthVector, min(directivityVector(:,:,2)), 'sk-');
% grid on;
% legend('MMSE Upper', 'MMSE Lower', 'LMS Upper', 'LMS Lower');
% title('Directivity Bound - Azimuth');
% xlabel('Azimuth/degree');
% ylabel('Directivity/dBi');
% 
% %% SIMULATION CASE: INTERFERENCE REJECTION - SIR
% % simulation setup: MMSE/LMS, NumTarget = 1, target angle = [0]; Interference angle = [11]; SIR = [-10:20]dB;  SNR = 20dB;  NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: INTERFERENCE REJECTION - AZIMUTH ===================\n')
% NumLoop = 1e4;
% SIR = -10:5:20;
% BeamformerTypeRange = {'MMSE', 'LMS'};
% interRejectVector = zeros(NumLoop, length(SIR), length(BeamformerTypeRange));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetAngle = [0; 0];
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = false;
% sysPara.SwitchInterence = true;
% sysPara.InterferenceType = 'Sine';
% sysPara.NumInterference = 1;
% sysPara.InterferenceFreq = 10e6;
% sysPara.InterferenceAngle = [11; 0];
% sysPara.SwitchAWGN = true;
% sysPara.SNR = 20;
% sysPara.GlobalDebugPlot = false;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = true;
% sysPara.FlagDOAEsti = false;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
% for idx = 1:length(BeamformerTypeRange)
%     fprintf('\n------------------- Begin of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
%     sysPara.BeamformerType = BeamformerTypeRange{idx};
%     for idxSIR = 1:length(SIR)
%         fprintf('BeamformerTypeRange = %s, SIR = %d\n', BeamformerTypeRange{idx}, SIR(idxSIR));
%         sysPara.SIR = SIR(idxSIR);
%         for idxLoop = 1:NumLoop
%             mainArraySimRxBF
%             interRejectVector(idxLoop, idxSIR, idx) = directivity(hArray, sysPara.FreqCenter, sysPara.TargetAngle, 'Weights', weight) - ...
%                 directivity(hArray, sysPara.FreqCenter, sysPara.InterferenceAngle, 'Weights', weight);
%             if mod(idxLoop, floor(NumLoop/10)) == 0
%                 fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%             end
%         end
%     end
%     fprintf('\n------------------- End of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
% end
% 
% NumFigure = 500;
% figure(NumFigure + 1);
% hold off;
% plot(SIR, mean(interRejectVector(:,:,1)), 'dk-');
% hold on;
% plot(SIR, mean(interRejectVector(:,:,2)), 'sb-');
% grid on;
% legend('MMSE', 'LMS');
% title('Interference Rejection - SIR');
% xlabel('SIR/dB');
% ylabel('Inter-Reject/dB');
% 
% figure(NumFigure + 2);
% hold off;
% plot(SIR, rms(interRejectVector(:,:,1) - repmat(mean(interRejectVector(:,:,1)), size(interRejectVector, 1), 1)), 'dk-');
% hold on;
% plot(SIR, rms(interRejectVector(:,:,2) - repmat(mean(interRejectVector(:,:,2)), size(interRejectVector, 1), 1)), 'sb-');
% grid on;
% legend('MMSE', 'LMS');
% title('Interference Rejection Std Err - Azimuth');
% xlabel('SIR/dB');
% ylabel('Inter-Reject Std Err');
% 
% figure(NumFigure + 3);
% hold off;
% plot(SIR, max(interRejectVector(:,:,1)), 'db-');
% hold on;
% plot(SIR, min(interRejectVector(:,:,1)), 'sb-');
% plot(SIR, max(interRejectVector(:,:,2)), 'dk-');
% plot(SIR, min(interRejectVector(:,:,2)), 'sk-');
% grid on;
% legend('MMSE Upper', 'MMSE Lower', 'LMS Upper', 'LMS Lower');
% title('Interference Rejection Bound - Azimuth');
% xlabel('SIR/dB');
% ylabel('Inter-Reject/dB');
% 
% %% SIMULATION CASE: Adaptive Rx Beamform - SNR
% % simulation setup: MMSE/LMS, NumTarget = 1, target angle = [0]; Interference angle = [11]; SIR = -3dB;  SNR = -10:5:20dB;  NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: ADAPTIVE RX BEAMFORM - SNR ===================\n')
% LenRS = 256;
% NumLoop = 1e4;
% SNR = -10:10:20;
% BeamformerTypeRange = {'MMSE', 'LMS'};
% adaptiveErrVector = zeros(LenRS, NumLoop, length(SNR), length(BeamformerTypeRange));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetAngle = [0; 0];
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = false;
% sysPara.SwitchInterence = true;
% sysPara.InterferenceType = 'Sine';
% sysPara.NumInterference = 1;
% sysPara.InterferenceFreq = 10e6;
% sysPara.InterferenceAngle = [11; 0];
% sysPara.SIR = -3;
% sysPara.SwitchAWGN = true;
% sysPara.GlobalDebugPlot = false;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = true;
% sysPara.FlagDOAEsti = false;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %#ok<NASGU> %% Gen. array
% for idx = 1:length(BeamformerTypeRange)
%     fprintf('\n------------------- Begin of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
%     sysPara.BeamformerType = BeamformerTypeRange{idx};
%     for idxSNR = 1:length(SNR)
%         fprintf('BeamformerTypeRange = %s, SNR = %d\n', BeamformerTypeRange{idx}, SNR(idxSNR));
%         sysPara.SNR = SNR(idxSNR);
%         for idxLoop = 1:NumLoop
%             mainArraySimRxBF
%             adaptiveErrVector(:, idxLoop, idxSNR, idx) = errVector;
%             if mod(idxLoop, floor(NumLoop/10)) == 0
%                 fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%             end
%         end
%     end
%     fprintf('\n------------------- End of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
% end
% 
% NumFigure = 600;
% figure(NumFigure + 1);
% idxIter = 1:8:LenRS;
% hold off;
% semilogy(idxIter, rms(adaptiveErrVector(idxIter,:,1,2).').^2, 'sr-');
% hold on;
% semilogy(idxIter, rms(adaptiveErrVector(idxIter,:,2,2).').^2, 'dk-');
% semilogy(idxIter, rms(adaptiveErrVector(idxIter,:,3,2).').^2, '^g-');
% semilogy(idxIter, rms(adaptiveErrVector(idxIter,:,4,2).').^2, '>b-');
% semilogy(idxIter, ones(size(idxIter))*sum(sum((adaptiveErrVector(idxIter,:,1,1).').^2))/(length(idxIter)*NumLoop), 'r-');
% semilogy(idxIter, ones(size(idxIter))*sum(sum((adaptiveErrVector(idxIter,:,2,1).').^2))/(length(idxIter)*NumLoop), 'k-');
% semilogy(idxIter, ones(size(idxIter))*sum(sum((adaptiveErrVector(idxIter,:,3,1).').^2))/(length(idxIter)*NumLoop), 'g-');
% semilogy(idxIter, ones(size(idxIter))*sum(sum((adaptiveErrVector(idxIter,:,4,1).').^2))/(length(idxIter)*NumLoop), 'b-');
% grid on;
% legend('SNR= -10dB', 'SNR=   0dB', 'SNR= 10dB', 'SNR= 20dB');
% title('Adaptive Rx Beamform - SNR (SIR= -3dB)');
% xlabel('Iterations');
% ylabel('MSE');
% 
% %% SIMULATION CASE: Adaptive Rx Beamform - SIR
% % simulation setup: MMSE/LMS, NumTarget = 1, target angle = [0]; Interference angle = [11]; SIR = -3dB;  SNR = -10:5:20dB;  NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: ADAPTIVE RX BEAMFORM - SIR ===================\n')
% LenRS = 256;
% NumLoop = 1e4;
% SIR = [-10,-3,0,3];
% BeamformerTypeRange = {'MMSE', 'LMS'};
% adaptiveErrVector = zeros(LenRS, NumLoop, length(SIR), length(BeamformerTypeRange));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetAngle = [0; 0];
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = false;
% sysPara.SwitchInterence = true;
% sysPara.InterferenceType = 'Sine';
% sysPara.NumInterference = 1;
% sysPara.InterferenceFreq = 10e6;
% sysPara.InterferenceAngle = [11; 0];
% sysPara.SwitchAWGN = true;
% sysPara.SNR = 20;
% sysPara.GlobalDebugPlot = false;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = true;
% sysPara.FlagDOAEsti = false;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %#ok<NASGU> %% Gen. array
% for idx = 1:length(BeamformerTypeRange)
%     fprintf('\n------------------- Begin of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
%     sysPara.BeamformerType = BeamformerTypeRange{idx};
%     for idxSIR = 1:length(SIR)
%         fprintf('BeamformerTypeRange = %s, SIR = %d\n', BeamformerTypeRange{idx}, SIR(idxSIR));
%         sysPara.SIR = SIR(idxSIR);
%         for idxLoop = 1:NumLoop
%             mainArraySimRxBF
%             adaptiveErrVector(:, idxLoop, idxSIR, idx) = errVector;
%             if mod(idxLoop, floor(NumLoop/10)) == 0
%                 fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%             end
%         end
%     end
%     fprintf('\n------------------- End of Beamfomer Type = %s -------------------\n', BeamformerTypeRange{idx});
% end
% 
% NumFigure = 700;
% figure(NumFigure + 1);
% idxIter = 1:8:LenRS;
% hold off;
% semilogy(idxIter, rms(adaptiveErrVector(idxIter,:,1,2).').^2, 'sr-');
% hold on;
% semilogy(idxIter, rms(adaptiveErrVector(idxIter,:,2,2).').^2, 'dk-');
% semilogy(idxIter, rms(adaptiveErrVector(idxIter,:,3,2).').^2, '^g-');
% semilogy(idxIter, rms(adaptiveErrVector(idxIter,:,4,2).').^2, '>b-');
% semilogy(idxIter, ones(size(idxIter))*sum(sum((adaptiveErrVector(idxIter,:,1,1).').^2))/(length(idxIter)*NumLoop), 'r-');
% semilogy(idxIter, ones(size(idxIter))*sum(sum((adaptiveErrVector(idxIter,:,2,1).').^2))/(length(idxIter)*NumLoop), 'k-');
% semilogy(idxIter, ones(size(idxIter))*sum(sum((adaptiveErrVector(idxIter,:,3,1).').^2))/(length(idxIter)*NumLoop), 'g-');
% semilogy(idxIter, ones(size(idxIter))*sum(sum((adaptiveErrVector(idxIter,:,4,1).').^2))/(length(idxIter)*NumLoop), 'b-');
% grid on;
% legend('SIR= -10dB', 'SIR=  -3dB', 'SIR=   0dB', 'SIR=   3dB');
% title('Adaptive Rx Beamform - SIR (SNR= 20dB)');
% xlabel('Iterations');
% ylabel('MSE');
% 
% %% SIMULATION CASE: DOA ERROR - CHANNEL AMPLITUDE ERROR
% % simulation setup: CBF/MUSIC/AntiInterMUSIC, NumTarget = 1, target angle = [-30, 30]random; no interference; channel amplitude mean = 0dB, channel amplitude single range = [0:1:10]dB; SNR = 20dB;  NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: DOA ERROR - CHANNEL AMPLITUDE ERROR ===================\n')
% NumLoop = 1e4;
% channelAmplSBRVector = 0:1:10;
% azimuthVector = -30:30;
% DoaEstiRange = {'CBF', 'MUSIC', 'AntiInterMUSIC'};
% doaErrVector = zeros(NumLoop, length(channelAmplSBRVector), length(DoaEstiRange));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = true;
% sysPara.ChannelPhaseErr = (rand(sysPara.NumChannel, 1)*2 - 1)*0 + 0;
% sysPara.SwitchInterence = false;
% sysPara.SwitchAWGN = true;
% sysPara.SNR = 20;
% sysPara.DOAIncludeElementResponse = false;
% sysPara.GlobalDebugPlot = false;
% sysPara.AzimuthScanAngles = (-35:0.5:35).';
% sysPara.ElevationScanAngles = 0;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = false;
% sysPara.FlagDOAEsti = true;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %#ok<NASGU> %% Gen. array
% for idx = 1:length(DoaEstiRange)
%     fprintf('\n------------------- Begin of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
%     sysPara.DoaEstimator = DoaEstiRange{idx};
%     for idxMaxAmplSBRange = 1:length(channelAmplSBRVector)
%         fprintf('DoaEstiRange = %s, AmplSBRange = %d\n', DoaEstiRange{idx}, channelAmplSBRVector(idxMaxAmplSBRange));
%         sysPara.TargetAngle = [azimuthVector(randi(length(azimuthVector)));0];
%         for idxLoop = 1:NumLoop
%             sysPara.ChannelAmpliErr = (rand(sysPara.NumChannel, 1)*2 - 1)*channelAmplSBRVector(idxMaxAmplSBRange) + 0;
%             mainArraySimRxBF
%             doaErrVector(idxLoop, idxMaxAmplSBRange, idx) = doaErr(1,1);
%             if mod(idxLoop, floor(NumLoop/10)) == 0
%                 fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%             end
%         end
%     end
%     fprintf('\n------------------- End of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
% end
% 
% NumFigure = 800;
% figure(NumFigure + 1);
% hold off;
% plot(channelAmplSBRVector, rms(doaErrVector(:,:,1)), 'dk-');
% hold on;
% plot(channelAmplSBRVector, rms(doaErrVector(:,:,2)), 'sb-');
% plot(channelAmplSBRVector, rms(doaErrVector(:,:,3)), 'or-');
% grid on;
% legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
% title('DOA Std Err - Channel Ampl Err');
% xlabel('Channel Ampl Err/dB');
% ylabel('DOA Err/degree');
% 
% figure(NumFigure + 2);
% hold off;
% plot(channelAmplSBRVector, mean(doaErrVector(:,:,1)), 'dk-');
% hold on;
% plot(channelAmplSBRVector, mean(doaErrVector(:,:,2)), 'sb-');
% plot(channelAmplSBRVector, mean(doaErrVector(:,:,3)), 'or-');
% grid on;
% legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
% title('DOA Err Mean - Channel Ampl Err');
% xlabel('Channel Ampl Err/dB');
% ylabel('DOA Err/degree');
% 
% figure(NumFigure + 3);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,1), distrVector)/size(doaErrVector, 1);
% surf(channelAmplSBRVector, distrVector, freqDistr);
% grid on;
% title('CBF DOA Err Distribution - Channel Ampl Err');
% xlabel('Channel Ampl Err/dB');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% figure(NumFigure + 4);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,2), distrVector)/size(doaErrVector, 1);
% surf(channelAmplSBRVector, distrVector, freqDistr);
% grid on;
% title('MUSIC DOA Err Distribution - Channel Ampl Err');
% xlabel('Channel Ampl Err/dB');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% figure(NumFigure + 5);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,3), distrVector)/size(doaErrVector, 1);
% surf(channelAmplSBRVector, distrVector, freqDistr);
% grid on;
% title('Anti-Inter MUSIC DOA Err Distribution - Channel Ampl Err');
% xlabel('Channel Ampl Err/dB');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% %% SIMULATION CASE: DOA ERROR - CHANNEL PHASE ERROR
% % simulation setup: CBF/MUSIC/AntiInterMUSIC, NumTarget = 1, target angle = [-30, 30]random; no interference; channel phase mean = 0 degree, channel phase single range = [0:0.5:5]degree; SNR = 20dB;  NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: DOA ERROR - CHANNEL PHASE ERROR ===================\n')
% NumLoop = 1e4;
% channelPhaseSBRVector = 0:0.5:10;
% azimuthVector = -30:30;
% DoaEstiRange = {'CBF', 'MUSIC', 'AntiInterMUSIC'};
% doaErrVector = zeros(NumLoop, length(channelPhaseSBRVector), length(DoaEstiRange));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = true;
% sysPara.ChannelAmpliErr = (rand(sysPara.NumChannel, 1)*2 - 1)*0 + 0;
% sysPara.SwitchInterence = false;
% sysPara.SwitchAWGN = true;
% sysPara.SNR = 20;
% sysPara.DOAIncludeElementResponse = false;
% sysPara.GlobalDebugPlot = false;
% sysPara.AzimuthScanAngles = (-35:0.5:35).';
% sysPara.ElevationScanAngles = 0;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = false;
% sysPara.FlagDOAEsti = true;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %#ok<NASGU> %% Gen. array
% for idx = 1:length(DoaEstiRange)
%     fprintf('\n------------------- Begin of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
%     sysPara.DoaEstimator = DoaEstiRange{idx};
%     for idxMaxPhaseSBRange = 1:length(channelPhaseSBRVector)
%         fprintf('DoaEstiRange = %s, PhaseSBRange = %d\n', DoaEstiRange{idx}, channelPhaseSBRVector(idxMaxPhaseSBRange));
%         sysPara.TargetAngle = [azimuthVector(randi(length(azimuthVector)));0];
%         for idxLoop = 1:NumLoop
%             sysPara.ChannelPhaseErr = (rand(sysPara.NumChannel, 1)*2 - 1)*channelPhaseSBRVector(idxMaxPhaseSBRange) + 0;
%             mainArraySimRxBF
%             doaErrVector(idxLoop, idxMaxPhaseSBRange, idx) = doaErr(1,1);
%             if mod(idxLoop, floor(NumLoop/10)) == 0
%                 fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%             end
%         end
%     end
%     fprintf('\n------------------- End of Doa Estimation = %s -------------------\n', DoaEstiRange{idx});
% end
% 
% NumFigure = 900;
% figure(NumFigure + 1);
% hold off;
% plot(channelPhaseSBRVector, rms(doaErrVector(:,:,1)), 'dk-');
% hold on;
% plot(channelPhaseSBRVector, rms(doaErrVector(:,:,2)), 'sb-');
% plot(channelPhaseSBRVector, rms(doaErrVector(:,:,3)), 'or-');
% grid on;
% legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
% title('DOA Std Err - Channel Phase Err');
% xlabel('Channel Phase Err/degree');
% ylabel('DOA Err/degree');
% 
% figure(NumFigure + 2);
% hold off;
% plot(channelPhaseSBRVector, mean(doaErrVector(:,:,1)), 'dk-');
% hold on;
% plot(channelPhaseSBRVector, mean(doaErrVector(:,:,2)), 'sb-');
% plot(channelPhaseSBRVector, mean(doaErrVector(:,:,3)), 'or-');
% grid on;
% legend('CBF', 'MUSIC', 'Anti-Inter MUSIC');
% title('DOA Err Mean - Channel Phase Err');
% xlabel('Channel Phase Err/degree');
% ylabel('DOA Err/degree');
% 
% figure(NumFigure + 3);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,1), distrVector)/size(doaErrVector, 1);
% surf(channelPhaseSBRVector, distrVector, freqDistr);
% grid on;
% title('CBF DOA Err Distribution - Channel Phase Err');
% xlabel('Channel Phase Err/degree');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% figure(NumFigure + 4);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,2), distrVector)/size(doaErrVector, 1);
% surf(channelPhaseSBRVector, distrVector, freqDistr);
% grid on;
% title('MUSIC DOA Err Distribution - Channel Phase Err');
% xlabel('Channel Phase Err/degree');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% figure(NumFigure + 5);
% hold off;
% distrVector = -4:0.5:4;
% freqDistr = hist(doaErrVector(:,:,3), distrVector)/size(doaErrVector, 1);
% surf(channelPhaseSBRVector, distrVector, freqDistr);
% grid on;
% title('Anti-Inter MUSIC DOA Err Distribution - Channel Phase Err');
% xlabel('Channel Phase Err/degree');
% ylabel('DOA Err/degree');
% zlabel('PDF');
% 
% %% SIMULATION CASE: DIRECTIVITY - CHANNEL PHASE ERROR
% % simulation setup: CBF, NumTarget = 1, target angle = [0]; no interference; channel phase mean = 0 degree, channel phase single range = [0:6:60]degree; SNR = 20dB;  NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: DIRECTIVITY - CHANNEL PHASE ERROR ===================\n')
% NumLoop = 1e4;
% channelPhaseSBRVector = 0:6:60;
% directivityVector = zeros(NumLoop, length(channelPhaseSBRVector));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetAngle = [0;0];
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = true;
% sysPara.ChannelAmpliErr = (rand(sysPara.NumChannel, 1)*2 - 1)*0 + 0;
% sysPara.SwitchInterence = false;
% sysPara.SwitchAWGN = true;
% sysPara.SNR = 20;
% sysPara.DOAIncludeElementResponse = false;
% sysPara.GlobalDebugPlot = false;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = false;
% sysPara.FlagDOAEsti = false;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
% hSteeringVector = phased.SteeringVector('SensorArray', hArray,...
%     'PropagationSpeed', physconst('LightSpeed'),...
%     'IncludeElementResponse', sysPara.DOAIncludeElementResponse,...
%     'NumPhaseShifterBits', 0 ...    'EnablePolarization', false ...
%     );
% steeringVector = step(hSteeringVector, sysPara.FreqCenter, sysPara.TargetAngle);
% steeringVector = steeringVector*diag(rms(steeringVector).^-1);
% for idxMaxPhaseSBRange = 1:length(channelPhaseSBRVector)
%     fprintf('PhaseSBRange = %d\n', channelPhaseSBRVector(idxMaxPhaseSBRange));
%     for idxLoop = 1:NumLoop
%         sysPara.ChannelPhaseErr = (rand(sysPara.NumChannel, 1)*2 - 1)*channelPhaseSBRVector(idxMaxPhaseSBRange) + 0;
%         weightTx = diag(exp(1i*sysPara.ChannelPhaseErr/180*pi))*steeringVector;
%         directivityVector(idxLoop, idxMaxPhaseSBRange) = directivity(hArray, sysPara.FreqCenter, sysPara.TargetAngle, 'Weights', weightTx);
%         if mod(idxLoop, floor(NumLoop/10)) == 0
%             fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%         end
%     end
% end
% NumFigure = 1000;
% figure(NumFigure + 1);
% plot(channelPhaseSBRVector, mean(directivityVector(:,:)), 'dk-');
% grid on;
% title('Directivity - Channel Phase Err');
% xlabel('Channel Phase Err/degree');
% ylabel('Directivity/dB');
% 
% figure(NumFigure + 2);
% plot(channelPhaseSBRVector, rms(directivityVector(:,:) - repmat(mean(directivityVector(:,:)), size(directivityVector(:,:), 1), 1)), 'dk-');
% grid on;
% title('Directivity Std Err - Channel Phase Err');
% xlabel('Channel Phase Err/degree');
% ylabel('Directivity Std Err/dB');
% 
% %% SIMULATION CASE: DIRECTIVITY - CHANNEL AMPLITUDE ERROR
% % simulation setup: CBF, NumTarget = 1, target angle = 0]random; no interference; channel amplitude mean = 0dB, channel amplitude single range = [0:1:10]dB; SNR = 20dB;  NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: DIRECTIVITY - CHANNEL AMPLITUDE ERROR ===================\n')
% NumLoop = 1e4;
% channelAmpliSBRVector = 0:1:10;
% directivityVector = zeros(NumLoop, length(channelAmpliSBRVector));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetAngle = [0;0];
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = true;
% sysPara.ChannelPhaseErr = (rand(sysPara.NumChannel, 1)*2 - 1)*0 + 0;
% sysPara.SwitchInterence = false;
% sysPara.SwitchAWGN = true;
% sysPara.SNR = 20;
% sysPara.DOAIncludeElementResponse = false;
% sysPara.GlobalDebugPlot = false;
% sysPara.FlagAnalyzeWaveform = false;
% sysPara.FlagBeamforming = false;
% sysPara.FlagDOAEsti = false;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
% hSteeringVector = phased.SteeringVector('SensorArray', hArray,...
%     'PropagationSpeed', physconst('LightSpeed'),...
%     'IncludeElementResponse', sysPara.DOAIncludeElementResponse,...
%     'NumPhaseShifterBits', 0 ...    'EnablePolarization', false ...
%     );
% steeringVector = step(hSteeringVector, sysPara.FreqCenter, sysPara.TargetAngle);
% steeringVector = steeringVector*diag(rms(steeringVector).^-1);
% for idxMaxAmpliSBRange = 1:length(channelAmpliSBRVector)
%     fprintf('AmpliSBRange = %d\n', channelAmpliSBRVector(idxMaxAmpliSBRange));
%     for idxLoop = 1:NumLoop
%         sysPara.ChannelAmpliErr = (rand(sysPara.NumChannel, 1)*2 - 1)*channelAmpliSBRVector(idxMaxAmpliSBRange) + 0;
%         weightTx = diag(10.^(sysPara.ChannelAmpliErr/20))*steeringVector;
%         directivityVector(idxLoop, idxMaxAmpliSBRange) = directivity(hArray, sysPara.FreqCenter, sysPara.TargetAngle, 'Weights', weightTx);
%         if mod(idxLoop, floor(NumLoop/10)) == 0
%             fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%         end
%     end
% end
% NumFigure = 1100;
% figure(NumFigure + 1);
% plot(channelAmpliSBRVector, mean(directivityVector(:,:)), 'dk-');
% grid on;
% title('Directivity - Channel Ampli Err');
% xlabel('Channel Ampli Err/dB');
% ylabel('Directivity/dB');
% 
% figure(NumFigure + 2);
% plot(channelAmpliSBRVector, rms(directivityVector(:,:) - repmat(mean(directivityVector(:,:)), size(directivityVector(:,:), 1), 1)), 'dk-');
% grid on;
% title('Directivity Std Err - Channel Ampli Err');
% xlabel('Channel Ampli Err/dB');
% ylabel('Directivity Std Err/dB');

% %% SIMULATION CASE: SINR GAIN - CHANNEL AMPLITUDE ERROR
% % simulation setup: MMSE/LMS, NumTarget = 1, target angle = [0]; SNR = 20dB; interference angle = [11]; SIR = -3dB; channel amplitude mean = 0dB, channel amplitude single range = [0:1:10]dB; NumLoop = 1e4;
% fprintf('\n=================== SIMULATION CASE: SINR GAIN - CHANNEL AMPLITUDE ERROR ===================\n')
% NumLoop = 1e4;
% channelAmplSBRVector = 0:2:10;
% BeamformerTypeRange = {'MMSE', 'LMS'};
% SNRGainVector = zeros(NumLoop, length(channelAmplSBRVector), length(BeamformerTypeRange));
% sysPara = GenSysPara();                         %% Gen. System para.
% sysPara.AntennaType = 'Custom';
% sysPara.ArrayType = 'Conformal';
% sysPara.StvIncludeElementResponse = true;
% sysPara.TargetSigType = 'QPSK';
% sysPara.NumTarget = 1;
% sysPara.TargetAngle = [0;0];
% sysPara.TargetPower = 0;
% sysPara.SwitchChannelImplementation = true;
% sysPara.ChannelPhaseErr = (rand(sysPara.NumChannel, 1)*2 - 1)*0 + 0;
% sysPara.SwitchInterence = true;
% sysPara.InterferenceType = 'Sine';
% sysPara.NumInterference = 1;
% sysPara.SIR = -3;
% sysPara.InterferenceFreq = 10e6;
% sysPara.InterferenceAngle = [11; 0];
% sysPara.SwitchAWGN = true;
% sysPara.SNR = 20;
% sysPara.GlobalDebugPlot = false;
% sysPara.FlagAnalyzeWaveform = true;
% sysPara.FlagBeamforming = true;
% sysPara.FlagDOAEsti = false;
% sysPara.FlagPrintResult = false;
% hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
% hArray = GenArray(sysPara, hAntennaElement);    %#ok<NASGU> %% Gen. array
% for idx = 1:length(BeamformerTypeRange)
%     fprintf('\n------------------- Begin of Beamform = %s -------------------\n', BeamformerTypeRange{idx});
%     sysPara.BeamformerType = BeamformerTypeRange{idx};
%     for idxMaxAmplSBRange = 1:length(channelAmplSBRVector)
%         fprintf('Beamform = %s, AmplSBRange = %d\n', BeamformerTypeRange{idx}, channelAmplSBRVector(idxMaxAmplSBRange));
%         for idxLoop = 1:NumLoop
%             sysPara.ChannelAmpliErr = (rand(sysPara.NumChannel, 1)*2 - 1)*channelAmplSBRVector(idxMaxAmplSBRange) + 0;
%             mainArraySimRxBF
%             SNRGainVector(idxLoop, idxMaxAmplSBRange, idx) = snrBf;
%             if mod(idxLoop, floor(NumLoop/10)) == 0
%                 fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
%             end
%         end
%     end
%     fprintf('\n------------------- End of Beamform = %s -------------------\n', BeamformerTypeRange{idx});
% end
% 
% NumFigure = 1200;
% figure(NumFigure + 1);
% hold off;
% plot(channelAmplSBRVector, mean(SNRGainVector(:,:,1)), 'dk-');
% hold on;
% plot(channelAmplSBRVector, mean(SNRGainVector(:,:,2)), 'sb-');
% grid on;
% axis([0,10,10,30]);
% legend('MMSE', 'LMS');
% title('SINR Gain - Channel Ampl Err');
% xlabel('Channel Ampl Err/dB');
% ylabel('SINR Gain/dB');
% 
% figure(NumFigure + 2);
% hold off;
% plot(channelAmplSBRVector, rms(SNRGainVector(:,:,1) - repmat(mean(SNRGainVector(:,:,1)), size(SNRGainVector(:,:,1), 1), 1)), 'dk-');
% hold on;
% plot(channelAmplSBRVector, rms(SNRGainVector(:,:,2) - repmat(mean(SNRGainVector(:,:,2)), size(SNRGainVector(:,:,2), 1), 1)), 'sb-');
% grid on;
% legend('MMSE', 'LMS');
% title('SINR Gain Std Err - Channel Ampl Err');
% xlabel('Channel Ampl Err/dB');
% ylabel('SINR Gain Std Err/dB');
% 
%% SIMULATION CASE: SINR GAIN - CHANNEL PHASE ERROR
% simulation setup: MMSE/LMS, NumTarget = 1, target angle = [0]; SNR = 20dB; interference angle = [11]; SIR = -3dB; channel phase mean = 0 degree, channel phase single range = [0:6:60]degree; NumLoop = 1e4;
fprintf('\n=================== SIMULATION CASE: SINR GAIN - CHANNEL PHASE ERROR ===================\n')
NumLoop = 1e2;
channelPhaseSBRVector = 0:6:60;
BeamformerTypeRange = {'MMSE', 'LMS'};
SNRGainVector = zeros(NumLoop, length(channelPhaseSBRVector), length(BeamformerTypeRange));
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.AntennaType = 'Custom';
sysPara.ArrayType = 'Conformal';
sysPara.StvIncludeElementResponse = true;
sysPara.TargetSigType = 'QPSK';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [0;0];
sysPara.TargetPower = 0;
sysPara.SwitchChannelImplementation = true;
sysPara.ChannelAmpliErr = (rand(sysPara.NumChannel, 1)*2 - 1)*0 + 0;
sysPara.SwitchInterence = true;
sysPara.InterferenceType = 'Sine';
sysPara.NumInterference = 1;
sysPara.SIR = -3;
sysPara.InterferenceFreq = 10e6;
sysPara.InterferenceAngle = [11; 0];
sysPara.SwitchAWGN = true;
sysPara.SNR = 20;
sysPara.GlobalDebugPlot = false;
sysPara.FlagAnalyzeWaveform = true;
sysPara.FlagBeamforming = true;
sysPara.FlagDOAEsti = false;
sysPara.FlagPrintResult = false;
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %#ok<NASGU> %% Gen. array
for idx = 1:length(BeamformerTypeRange)
    fprintf('\n------------------- Begin of Beamform = %s -------------------\n', BeamformerTypeRange{idx});
    sysPara.BeamformerType = BeamformerTypeRange{idx};
    for idxMaxPhaseSBRange = 1:length(channelPhaseSBRVector)
        fprintf('Beamform = %s, PhaseSBRange = %d\n', BeamformerTypeRange{idx}, channelPhaseSBRVector(idxMaxPhaseSBRange));
        for idxLoop = 1:NumLoop
            sysPara.ChannelPhaseErr = (rand(sysPara.NumChannel, 1)*2 - 1)*channelPhaseSBRVector(idxMaxPhaseSBRange) + 0;
            mainArraySimRxBF
            SNRGainVector(idxLoop, idxMaxPhaseSBRange, idx) = snrBf;
            if mod(idxLoop, floor(NumLoop/10)) == 0
                fprintf('%d0%%...\n', fix(idxLoop/(NumLoop/10)));
            end
        end
    end
    fprintf('\n------------------- End of Beamform = %s -------------------\n', BeamformerTypeRange{idx});
end

NumFigure = 1300;
figure(NumFigure + 1);
hold off;
plot(channelPhaseSBRVector, mean(SNRGainVector(:,:,1)), 'dk-');
hold on;
plot(channelPhaseSBRVector, mean(SNRGainVector(:,:,2)), 'sb-');
grid on;
axis([0,60,10,30]);
legend('MMSE', 'LMS');
title('SINR Gain - Channel Phase Err');
xlabel('Channel Phase Err/degree');
ylabel('SINR Gain/dB');

figure(NumFigure + 2);
hold off;
plot(channelPhaseSBRVector, rms(SNRGainVector(:,:,1) - repmat(mean(SNRGainVector(:,:,1)), size(SNRGainVector(:,:,1), 1), 1)), 'dk-');
hold on;
plot(channelPhaseSBRVector, rms(SNRGainVector(:,:,2) - repmat(mean(SNRGainVector(:,:,2)), size(SNRGainVector(:,:,2), 1), 1)), 'sb-');
grid on;
legend('MMSE', 'LMS');
title('SINR Gain Std Err - Channel Phase Err');
xlabel('Channel Phase Err/degree');
ylabel('SINR Gain Std Err/dB');

