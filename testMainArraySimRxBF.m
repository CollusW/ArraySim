% /*!
%  *  @brief     This script is used to  Auto test testMainArraySimRxBF.m  .
%  *  @details   any changes with testMainArraySimRxBF.m should pass this autotest script. i.e. run without error/warning occur.
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.06.30
%  *  @copyright Collus Wang all rights reserved.
%  *  @remark   { revision history: V1.0, 2017.06.30. Collus Wang, first draft. }
%  *  @remark   { revision history: V1.1, 2017.07.12. Collus Wang, add tests for cases that include element response. }
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
fprintf('############################### Autotest Begin ###############################\n')

%% TEST CASE: TargetSigType
% test setup: QPSK/16QAM/64QAM, NumTarget = 1, target angle = [-30, 30] random; no interference;  SNR = 20dB; MRC; NumLoop = 3;
% pass criteria: SNR impromvement > theoratical result - 0.1 dB; BER < 1e-4; EVM < 6%;
fprintf('\n=================== TEST CASE: TargetSigType ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 6;    % EVM pass Threshold, in percentage
ThdSnrBf = 20 + 5.9;
NumLoop = 3;
TargetSigTypeRange = {'QPSK', '16QAM', '64QAM'};
for idx = 1:length(TargetSigTypeRange)
    fprintf('\n------------------- Begin of TargetSigType = %s -------------------\n', TargetSigTypeRange{idx});
    sysPara = GenSysPara();                         %% Gen. System para.
    sysPara.TargetSigType = TargetSigTypeRange{idx};
    sysPara.NumTarget = 1;
    sysPara.TargetAngle = [30-rand*60; 0];
    sysPara.TargetPower = [0];
    sysPara.SwitchInterence = false;
    sysPara.NumInterference = 0;
    sysPara.SwitchAWGN = true;
    sysPara.SNR = 20;
    sysPara.GlobalDebugPlot = false;
    sysPara.BeamformerType = 'MRC';
    sysPara.StvIncludeElementResponse = false;
    ShowConfiguration(sysPara);                     %% print simulation configuration.
    hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
    hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
    for idxLoop = 1:NumLoop
        fprintf('TargetSigType = %s, Test Loop = %d\n', sysPara.TargetSigType, idxLoop)
        mainArraySimRxBF
        if sum(snrBf<ThdSnrBf), error('SNR does not meet threshold.'); end
        if sum(berBf>ThdBerBf), error('BER exceeds threshold.'); end
        if sum(evmBf>ThdEvmBf), error('EVM exceeds threshold.'); end
    end
    fprintf('\n------------------- End of TargetSigType = %s -------------------\n', TargetSigTypeRange{idx});
end

%% TEST CASE: BF MRC
% test setup: QPSK, NumTarget = 1, target angle = [-30, 30] random; no interference;  SNR = 20dB; MRC; NumLoop = 3;
% pass criteria: SNR impromvement > theoratical result - 0.3 dB; BER < 1e-4; EVM < 8%;
fprintf('\n=================== TEST CASE: BF MRC ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 8;    % EVM pass Threshold, in percentage
ThdSnrBf = 20 + 5.7;
NumLoop = 3;
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = 'QPSK';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.NumInterference = 0;
sysPara.SwitchAWGN = true;
sysPara.SNR = 20;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'MRC';
sysPara.StvIncludeElementResponse = false;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), error('SNR does not meet threshold.'); end
    if sum(berBf>ThdBerBf), error('BER exceeds threshold.'); end
    if sum(evmBf>ThdEvmBf), error('EVM exceeds threshold.'); end
end

%% TEST CASE: BF MVDR
% test setup: 16QAM, NumTarget = 1, target angle = [-30, 30] random; no interference;  SNR = 20dB; MVDR; NumLoop = 3;
% pass criteria: SNR impromvement > theoratical result - 2 dB; BER < 1e-4; EVM < 8%;
% Note: SNR impromvement does not meet theoratical result - 0.7 dB
warning('This case has issue.')
fprintf('\n=================== TEST CASE: BF MVDR ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 8;    % EVM pass Threshold, in percentage
ThdSnrBf = 20 + 5.3;
NumLoop = 3;
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = '16QAM';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.NumInterference = 0;
sysPara.SwitchAWGN = true;
sysPara.SNR = 20;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'MVDR';
sysPara.StvIncludeElementResponse = false;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), error('SNR does not meet threshold.'); end
    if sum(berBf>ThdBerBf), error('BER exceeds threshold.'); end
    if sum(evmBf>ThdEvmBf), error('EVM exceeds threshold.'); end
end

%% TEST CASE: BF LCMV
% test setup: 64QAM, NumTarget = 1, target angle = [-30, 30] random; no interference;  SNR = 28dB; LCMV; NumLoop = 3;
% pass criteria: SNR impromvement > 0.5 dB; BER < 1e-4; EVM < 5%; ThdCntFailed = 1;
fprintf('\n=================== TEST CASE: BF LCMV ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 5;    % EVM pass Threshold, in percentage
ThdSnrBf = 28 + 0.5;
NumLoop = 3;
ThdCntFailed = 1;   % allow some number of failures
CntFailed = 0;  % count the number of failure
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = '64QAM';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.NumInterference = 0;
sysPara.SwitchAWGN = true;
sysPara.SNR = 28;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'LCMV';
sysPara.LcmvPara.AngleToleranceAZ = 15;
sysPara.StvIncludeElementResponse = false;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), warning('SNR does not meet threshold.'); CntFailed = CntFailed+1; end
    if sum(berBf>ThdBerBf), warning('BER exceeds threshold.'); CntFailed = CntFailed+1; end
    if sum(evmBf>ThdEvmBf), warning('EVM exceeds threshold.'); CntFailed = CntFailed+1; end
    if CntFailed > ThdCntFailed, error('Number of failures exceeds the threshold.'); end
end

%% TEST CASE: BF MMSE
% test setup: 64QAM, NumTarget = 1, target angle = [-30, 30] random; no interference;  SNR = 30dB; MMSE; NumLoop = 3;
% pass criteria: SNR impromvement > theoratical result - 0.3 dB; BER < 1e-4; EVM < 5%;
fprintf('\n=================== TEST CASE: BF MMSE ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 5;    % EVM pass Threshold, in percentage
ThdSnrBf = 30 + 5.7;
NumLoop = 3;
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = '64QAM';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.NumInterference = 0;
sysPara.SwitchAWGN = true;
sysPara.SNR = 30;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'MMSE';
sysPara.StvIncludeElementResponse = false;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), error('SNR does not meet threshold.'); end
    if sum(berBf>ThdBerBf), error('BER exceeds threshold.'); end
    if sum(evmBf>ThdEvmBf), error('EVM exceeds threshold.'); end
end

%% TEST CASE: BF MVDR, Interference
% test setup:  64QAM, NumTarget = 1, target angle = [-30, 30] random; NumInterference = 1; target and int. are at 10 degree separation in AZ;  SNR = 30dB; SIR = -10dB; MVDR; NumLoop = 3;
% pass criteria: SNR > 30 dB; BER < 1e-4; EVM < 5%;
fprintf('\n=================== TEST CASE: BF MVDR, Interference ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 5;    % EVM pass Threshold, in percentage
ThdSnrBf = 30;
NumLoop = 3;
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = '64QAM';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = true;
sysPara.NumInterference = 1;
sysPara.InterferenceFreq = 10e3; 
sysPara.InterferenceAngle = sysPara.TargetAngle + [10; 0];
sysPara.SIR = -10;
sysPara.SwitchAWGN = true;
sysPara.SNR = 30;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'MVDR';
sysPara.StvIncludeElementResponse = false;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), error('SNR does not meet threshold.'); end
    if sum(berBf>ThdBerBf), error('BER exceeds threshold.'); end
    if sum(evmBf>ThdEvmBf), error('EVM exceeds threshold.'); end
end

%% TEST CASE: BF LCMV, Interference
% test setup:   64QAM, NumTarget = 1, target angle = [-30, 30] random; NumInterference = 1; target and int. are at 30 degree separation in AZ;  
%               SNR = 30dB; SIR = -10dB; LCMV; NumLoop = 3;
% pass criteria: SNR > 29 dB; BER < 1e-4; EVM < 5%; ThdCntFailed = 1;
fprintf('\n=================== TEST CASE: BF LCMV, Interference ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 5;    % EVM pass Threshold, in percentage
ThdSnrBf = 29;
NumLoop = 3;
ThdCntFailed = 1;   % allow some number of failures
CntFailed = 0;  % count the number of failure
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = '64QAM';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = true;
sysPara.NumInterference = 1;
sysPara.InterferenceFreq = 10e3; 
sysPara.InterferenceAngle = sysPara.TargetAngle + [30; 0];
sysPara.SIR = -10;
sysPara.SwitchAWGN = true;
sysPara.SNR = 30;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'LCMV';
sysPara.StvIncludeElementResponse = false;
sysPara.LcmvPara.AngleToleranceAZ = 15;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), warning('SNR does not meet threshold.'); CntFailed = CntFailed+1; end
    if sum(berBf>ThdBerBf), warning('BER exceeds threshold.'); CntFailed = CntFailed+1; end
    if sum(evmBf>ThdEvmBf), warning('EVM exceeds threshold.'); CntFailed = CntFailed+1; end
    if CntFailed > ThdCntFailed, error('Number of failures exceeds the threshold.'); end
end

%% TEST CASE: BF MMSE, Interference
% test setup:  64QAM, NumTarget = 1, target angle = [-30, 30] random; NumInterference = 1; target and int. are at 10 degree separation in AZ;  SNR = 30dB; SIR = -10dB; MMSE; NumLoop = 3;
% pass criteria: SNR > 30 dB; BER < 1e-4; EVM < 5%;
fprintf('\n=================== TEST CASE: BF MMSE, Interference ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 5;    % EVM pass Threshold, in percentage
ThdSnrBf = 30;
NumLoop = 3;
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = '64QAM';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = true;
sysPara.NumInterference = 1;
sysPara.InterferenceFreq = 10e3; 
sysPara.InterferenceAngle = sysPara.TargetAngle + [10; 0];
sysPara.SIR = -10;
sysPara.SwitchAWGN = true;
sysPara.SNR = 30;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'MMSE';
sysPara.StvIncludeElementResponse = false;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), error('SNR does not meet threshold.'); end
    if sum(berBf>ThdBerBf), error('BER exceeds threshold.'); end
    if sum(evmBf>ThdEvmBf), error('EVM exceeds threshold.'); end
end

%% below test cases are with StvIncludeElementResponse = true
%% TEST CASE: BF MVDR
% test setup: 16QAM, NumTarget = 1, target angle = [-30, 30] random; no interference;  SNR = 20dB; MVDR; NumLoop = 3;
% pass criteria: SNR impromvement > theoratical result - 4.5 dB; BER < 1e-4; EVM < 8%;
% Note: SNR impromvement does not meet theoratical result - 0.8 dB
fprintf('\n=================== TEST CASE: BF MVDR ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 8;    % EVM pass Threshold, in percentage
ThdSnrBf = 20 + 1.5;
NumLoop = 3;
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = '16QAM';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.NumInterference = 0;
sysPara.SwitchAWGN = true;
sysPara.SNR = 20;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'MVDR';
sysPara.StvIncludeElementResponse = true;
sysPara.MvdrPara.DiagonalLoadingFactor = 0.5;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), error('SNR does not meet threshold.'); end
    if sum(berBf>ThdBerBf), error('BER exceeds threshold.'); end
    if sum(evmBf>ThdEvmBf), error('EVM exceeds threshold.'); end
end

%% TEST CASE: BF LCMV
% test setup: 64QAM, NumTarget = 1, target angle = [-30, 30] random; no interference;  SNR = 28dB; LCMV; NumLoop = 3;
% pass criteria: SNR impromvement > 0.2 dB; BER < 1e-4; EVM < 5%; ThdCntFailed = 1;
fprintf('\n=================== TEST CASE: BF LCMV ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 5;    % EVM pass Threshold, in percentage
ThdSnrBf = 28 + 0.2;
NumLoop = 3;
ThdCntFailed = 1;   % allow some number of failures
CntFailed = 0;  % count the number of failure
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = '64QAM';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.NumInterference = 0;
sysPara.SwitchAWGN = true;
sysPara.SNR = 28;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'LCMV';
sysPara.LcmvPara.AngleToleranceAZ = 15;
sysPara.StvIncludeElementResponse = true;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), warning('SNR does not meet threshold.'); CntFailed = CntFailed+1; end
    if sum(berBf>ThdBerBf), warning('BER exceeds threshold.'); CntFailed = CntFailed+1; end
    if sum(evmBf>ThdEvmBf), warning('EVM exceeds threshold.'); CntFailed = CntFailed+1; end
    if CntFailed > ThdCntFailed, error('Number of failures exceeds the threshold.'); end
end

%% TEST CASE: BF MMSE
% test setup: 64QAM, NumTarget = 1, target angle = [-30, 30] random; no interference;  SNR = 30dB; MMSE; NumLoop = 3;
% pass criteria: SNR impromvement > theoratical result - 0.3 dB; BER < 1e-4; EVM < 5%;
fprintf('\n=================== TEST CASE: BF MMSE ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 5;    % EVM pass Threshold, in percentage
ThdSnrBf = 30 + 5.7;
NumLoop = 3;
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = '64QAM';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = false;
sysPara.NumInterference = 0;
sysPara.SwitchAWGN = true;
sysPara.SNR = 30;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'MMSE';
sysPara.StvIncludeElementResponse = true;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), error('SNR does not meet threshold.'); end
    if sum(berBf>ThdBerBf), error('BER exceeds threshold.'); end
    if sum(evmBf>ThdEvmBf), error('EVM exceeds threshold.'); end
end

%% TEST CASE: BF MMSE, Interference
% test setup:  64QAM, NumTarget = 1, target angle = [-30, 30] random; NumInterference = 1; target and int. are at 10 degree separation in AZ;  SNR = 30dB; SIR = -10dB; MMSE; NumLoop = 3;
% pass criteria: SNR > 30 dB; BER < 1e-4; EVM < 5%;
fprintf('\n=================== TEST CASE: BF MMSE, Interference ===================\n')
ThdBerBf = 1e-4;       % BER pass Threshold.
ThdEvmBf = 5;    % EVM pass Threshold, in percentage
ThdSnrBf = 30;
NumLoop = 3;
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.TargetSigType = '64QAM';
sysPara.NumTarget = 1;
sysPara.TargetAngle = [30-rand*60; 0];
sysPara.TargetPower = [0];
sysPara.SwitchInterence = true;
sysPara.NumInterference = 1;
sysPara.InterferenceFreq = 10e3; 
sysPara.InterferenceAngle = sysPara.TargetAngle + [10; 0];
sysPara.SIR = -10;
sysPara.SwitchAWGN = true;
sysPara.SNR = 30;
sysPara.GlobalDebugPlot = false;
sysPara.BeamformerType = 'MMSE';
sysPara.StvIncludeElementResponse = true;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
for idxLoop = 1:NumLoop
    fprintf('Test Loop = %d\n', idxLoop)
    mainArraySimRxBF
    if sum(snrBf<ThdSnrBf), error('SNR does not meet threshold.'); end
    if sum(berBf>ThdBerBf), error('BER exceeds threshold.'); end
    if sum(evmBf>ThdEvmBf), error('EVM exceeds threshold.'); end
end

%% Conclusion
fprintf('\n=================== ALL AUTO TEST PASSED ===================\n')

clear ScriptCall    % clear ScriptCall so that simSystem can use its own settings.

fprintf('############################### Autotest Finished ###############################\n')
tElapsed = toc(tStart);
fprintf('Total elapsed time = %.2fsec = %dmin %.2fsec\n', tElapsed, floor(tElapsed/60), tElapsed-floor(tElapsed/60)*60);