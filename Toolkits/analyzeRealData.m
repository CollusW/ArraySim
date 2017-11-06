% /*!
%  *  @brief     This script is used to analyze the DOA and weight which are captured from device (real data).
%  *  @details   
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.10.27
%  *  @copyright Collus Wang all rights reserved.
%  *  @remark   { revision history: V1.0, 2017.10.27. Collus Wang, first draft.}
%  */

%% Clear
clear all %#ok<CLALL>
close all
clc

%% Make sure the working folder is current m-file folder.
filePath= mfilename('fullpath');
idx=strfind(filePath,'\');
CurrentDirectory=filePath(1:idx(end));
cd(CurrentDirectory)

%% System para.
% recorded data file path and name
PathName = 'RawData\20171026_RealDataAnalysis\Degree0\Degree0SMA_80dBm\';
FileNameDoa = 'doaEstiTest.dat';    % file name of the DOA value. Each line contain one DOA estimation result.
FileNameMaxSS = 'spacialEstiTest.dat';  % file name of the max spacial spectrum value. Each line contain one max spectrum value.
FileNameWeight = 'weightCalcuTest.dat'; % file name of the weight. Format: {I1,Q1,I2,Q2,I3,Q3,I4,Q4}, {I1,Q1,I2,Q2,I3,Q3,I4,Q4}, ...
NumDoa = 10000;  % Number of DOA samples to read from DSP .dat file.
NumWeight = 100; % Number of weights (4x1 complex) to read from DSP .dat file.
figureStartNum = 100;

%% DOA
fileID = fopen([PathName,FileNameDoa]);
dataDoa = textscan(fileID, '%d',NumDoa, 'Delimiter','\n' , 'HeaderLines', 1);
fclose(fileID);
dataDoa = double(dataDoa{1})/100;

figureObj = figure(figureStartNum+0);
PlotHistWithMeanStd(dataDoa, figureObj);
title('DOA Result')
xlabel('DOA estimation (degree)')

%% Max Spacial spectrum value
fileID = fopen([PathName,FileNameMaxSS]);
dataMaxSS = textscan(fileID, '%d',NumDoa, 'Delimiter','\n' , 'HeaderLines', 1);
fclose(fileID);
dataMaxSS = double(dataMaxSS{1});

figureObj = figure(figureStartNum+10);
PlotHistWithMeanStd(dataMaxSS, figureObj);
title('Spacial Spectrum Result')
xlabel('Max Spacial Spectrum (linear)')

%% Weight analysis
fileID = fopen([PathName,FileNameWeight]);
dataWeight = textscan(fileID, '%d',NumWeight*8, 'Delimiter','\n' , 'HeaderLines', 1);
fclose(fileID);
dataWeight = double(dataWeight{1});
dataWeight = dataWeight(1:2:end)+1j*dataWeight(2:2:end);
dataWeight = reshape(dataWeight, 4, []);    % Each column is one set of weight

cd('..')
sysPara = GenSysPara();                         %% Gen. System para.
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
FreqCenter=sysPara.FreqCenter
ELofAZCut = 0;
AZofELCut = 0;
SwitchPattern = 'directivity';
AZ = -180:0.1:180;
PATRec = zeros(length(AZ), NumWeight);
for idxWeight = 1:NumWeight
    idxWeight
    weight = dataWeight(:,idxWeight);
    switch SwitchPattern
        case 'powerdb'
            [PAT,AZ_ANG,EL_ANG] = pattern(hArray, FreqCenter, AZ, ELofAZCut,...
                'CoordinateSystem', 'polar',...
                'Type', 'powerdb', ...
                'Plotstyle', 'overlay', ...
                'Normalize', false, ...
                'Weight', weight);
        case 'directivity'
            [PAT,AZ_ANG,EL_ANG] = pattern(hArray, FreqCenter, AZ, ELofAZCut,...
                'CoordinateSystem', 'polar',...
                'Type', 'directivity', ...
                'Plotstyle', 'overlay', ...
                'Weight', weight);
    end
    PATRec(:,idxWeight) = PAT;    
end
figure(figureStartNum+21); clf;
plot(AZ_ANG,PATRec.', 'LineWidth', 1);
hold on
plot(AZ_ANG,mean(PATRec.'), 'g:','LineWidth', 1.5);
plot(AZ_ANG,-3*ones(size(AZ_ANG)), 'r--', 'LineWidth', 1.5);
xlim([min(AZ_ANG), max(AZ_ANG)])
title('Array Azimuth Cut')
xlabel('Azimuth (degree)')
ylabel('Normalized Power (dB)')
legend('Norm. Power', '-3dB', 'Location', 'Best')
grid on

%% finished
cd(CurrentDirectory)

return


%% 
function [] = PlotHistWithMeanStd(data, figureObj)
% data: double vector
% figureObj: figure object
meanData = mean(data);
stdData = std(data);
fprintf('Mean = %.2f\nStd = %.2f\n', meanData, stdData);

figure(figureObj)
histogram(data, 'Normalization', 'probability')
hold on
plot([meanData, meanData],[0,1], '-r' )
plot([meanData+3*stdData, meanData+3*stdData],[0,1], '--r' )
plot([meanData-3*stdData, meanData-3*stdData],[0,1], '--r' )
legend('Mean', 'Mean \pm 3\sigma')
ylabel('Probability')
end