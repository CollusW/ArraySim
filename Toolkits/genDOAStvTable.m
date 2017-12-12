% /*!
%  *  @brief     This script is used to generate the DOA steering vector using the specified parameters.
%  *  @details   
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author   Wayne Zhang
%  *  @version   1.0
%  *  @date      2017.12.01
%  *  @copyright Wayne Zhang all rights reserved.
%  *  @remark   { revision history: V1.0, 2017.12.01. Wayne Zhang, first draft. 
%  */

%% clear
clear all %#ok<CLALL>
close all
clc

CurrentDirectory = cd();
cd('..');

%% prepare
sysPara = GenSysPara();                         %% Gen. System para.
sysPara.AntennaType = 'Custom';
sysPara.ArrayType = 'Conformal';
sysPara.DOAIncludeElementResponse = true;
ShowConfiguration(sysPara);                     %% print simulation configuration.
hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
AzimuthScanAngles = (-60:0.5:60).';
ElevationScanAngles = 0;
FreqCenter = 5625e6:1e6:5825e6;
%% Gen steering vector
hSteeringVector = phased.SteeringVector('SensorArray', hArray,...
    'PropagationSpeed', physconst('LightSpeed'),...
    'IncludeElementResponse', sysPara.DOAIncludeElementResponse,...
    'NumPhaseShifterBits', 0 ...    'EnablePolarization', false ...
    );
elevationScanVector = ones(size(AzimuthScanAngles))*ElevationScanAngles;
angleScanVector = [AzimuthScanAngles, elevationScanVector];
steeringReshapeVector = zeros(length(FreqCenter), sysPara.NumChannel*length(AzimuthScanAngles));
for idxFreq = 1:length(FreqCenter)
    steeringVector = step(hSteeringVector, FreqCenter(idxFreq), angleScanVector.');
    steeringVector = steeringVector*diag(rms(steeringVector).^-1);
    steeringReshapeVector(idxFreq,:) = reshape(steeringVector, 1, []);
end
steeringReshapeVectorI = real(steeringReshapeVector);
steeringReshapeVectorQ = imag(steeringReshapeVector);
