% /*!
%  *  @brief     This script is used to generate the beam pattern for omnidirectional transmission.
%  *  @details
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.10.13
%  *  @copyright Collus Wang all rights reserved.
%  *  @remark   { revision history: V1.0, 2017.10.13. Collus Wang, first draft.}
%  */

%% clear
clear all %#ok<CLALL>
close all
clc
CurrentDirectory = cd();
cd('..');

%% prepare
sysPara = GenSysPara();                         %% Gen. System para.
% specify the parameters
sysPara.ArrayType = 'Conformal';      % string. Array type. valid value = {'Conformal', 'UCA'};
sysPara.NumElements = 24;       % interger scaler. number of antenna elements
sysPara.NumChannel = 24;         % interger scaler. number of used channels
sysPara.Radius = 0.162;         % double scaler. radius of UCA array, in meter. e.g. 3rd Gen = 0.162;
sysPara.StvIncludeElementResponse = true; % boolen scaler. Include individual element response in the calculation of steering vector when generating the received waveforms from channels.

ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array

figureStartNum = 1000;
FreqCenter = sysPara.FreqCenter;

%% Process
% Pattern 1
weight = zeros(24,1);
weight([1,7,14,20])=1; % HW implementation 4 tx
weight(20) = exp(1j*-40/180*pi);    % Tune the phase to improve the radiation pattern
ELofAZCut = 0;
AZofELCut = 0;
[PatAZ1,~] = ViewArrayPattern(hArray, FreqCenter , ELofAZCut, AZofELCut, weight, figureStartNum);

% Pattern 2
weight = zeros(24,1);
weight([4,11,17,22])=exp(1j*rand(4,1)*2*pi*0); % HW implementation 4 tx
ELofAZCut = 0;
AZofELCut = 0;
[PatAZ2,~] = ViewArrayPattern(hArray, FreqCenter , ELofAZCut, AZofELCut, weight, figureStartNum);

% combined pattern
patternCombine = max([PatAZ1.PAT,PatAZ2.PAT], [], 2);

% plot
figure(figureStartNum+100)
plot(PatAZ1.AZ_ANG,PatAZ1.PAT, '--','LineWidth', 1.0);
hold on
plot(PatAZ2.AZ_ANG,PatAZ2.PAT, '--','LineWidth', 1.0);
plot(PatAZ1.AZ_ANG, patternCombine, '-b','LineWidth', 1.5);
disp(max(patternCombine) - min(patternCombine))
xlim([min(PatAZ1.AZ_ANG), max(PatAZ1.AZ_ANG)])
ylim([-15, 20])
title('Array Azimuth Cut')
xlabel('Azimuth (degree)')
ylabel('Normalized Power (dB)')
legend('Pattern 1', 'Pattern 2','Combined Pattern', 'Location', 'Best')
grid on

figure(figureStartNum+200)
patternCombine = max([PatAZ1.PAT,PatAZ2.PAT], [], 2);
patternCombine = patternCombine-max(patternCombine);
plot(PatAZ1.AZ_ANG, patternCombine, '-b','LineWidth', 1.5);
disp(min(patternCombine))
xlim([min(PatAZ1.AZ_ANG), max(PatAZ1.AZ_ANG)])
ylim([-15, 5])
title('Array Azimuth Cut')
xlabel('Azimuth (degree)')
ylabel('Normalized Power (dB)')
legend('Combined Pattern', 'Location', 'Best')
grid on

%% finished
cd(CurrentDirectory);
