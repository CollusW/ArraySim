% /*!
%  *  @brief     This script is used to generate the weights using the specified parameters.
%  *  @details   
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.09.21
%  *  @copyright Collus Wang all rights reserved.
%  *  @remark   { revision history: V1.0, 2017.09.21. Collus Wang, first draft. inherited from Tag_MainArraySimToolBox_HNRWeight.m in ArraySim project. }
%  *  @remark   { revision history: V1.1, 2017.09.22. Collus Wang, add header file generation. }
%  *  @remark   { revision history: V1.2, 2017.11.30. Collus Wang, 1.conjugate the weight. 2.add CSMA wide beam weight generation. }
%  */

%% clear
clear all %#ok<CLALL>
close all
clc
CurrentDirectory = cd();
cd('..');

%% Start Timer
tStart = tic;
fprintf('############################### Begin ###############################\n')

%% Flags
FlagFixedNarrowBeam = true; % true = creat narrow beam using MRC method.
FlagFixedWideBeam = true;       % true = creat wide beam using LCMV method.
FlagFixedWideBeamCSMA = true;   % true = creat wide beam using LCMV method for CSMA directional coverage. 4 wide beams at each frequency.
FlagFixedIntCanceller = true;  % true = creat fixed interference/signal search beam using LCMV method.
FlagExportToC = true;      % true = export to C file for const generation.

%% Parameter configuration.
% Common para.
ExportSourceFileName = 'FixedWeightsTable.c';             % string. specify the output source file name.
ExportHeaderFileName = 'FixedWeightsTable.h';       % string. specify the output header file name.
ExportFilePath = '.\Result\WeightGenerationForC';   % string. specify the output file path.
RecFreqCenter = (5625:1:5825)*1e6;                  % range of frequency
ELofAZCut = -3.5;                                   % Elevation angle (degree) of AZ cut view

% Fixed Narrow beam para.
TargetAngleRange = [-30:0.75:30; ELofAZCut*ones(size(-30:0.75:30))];   % incoming wave direction in degree, [azimuth; elevation]. The azimuth angle must be between ¨C180 and 180 degrees, and the elevation angle must be between ¨C90 and 90 degrees.
% Fixed Wide beam para.
TargetAngleWideBeam = [0; ELofAZCut];   % center angle of the wide beam in degree [AZ; EL].
AngleToleranceAZ = 15;                  % DesiredTargetAngle in degree [AZ; EL].  15 => 54 beam width.
% Fixed interference cancellation beam para.
AngleSigInt = 5;                        % angle between signal and interference in interference search case, unit in degree

%% Fixed Narrow Beam
if FlagFixedNarrowBeam
    % Parameter init.
    sysPara = GenSysPara();                         %% Gen. System para.
    sysPara.NumTarget = size(TargetAngleRange,2);
    sysPara.TargetAngle = TargetAngleRange;
    sysPara.TargetPower = zeros(size(TargetAngleRange,2),1);                % double vector. target relative power above 1W in dB.
    sysPara.GlobalDebugPlot = false;
    sysPara.BeamformerType = 'MRC';
    sysPara.StvIncludeElementResponse = false;
    sysPara.WeightsNormalization = 'bypass';
    sysPara.NumWeightsQuantizationBits = 0; % no quantization within function.
    sysPara.GlobalDebugPlot = ~true;
    % some generated para.
    NumQuantizedBit = 15;   % number of quantized bit for the weight
    FullScale = 2^NumQuantizedBit-1; % FullScale of the quantized weights
    NumChannel = sysPara.NumChannel;
    recWeightI = zeros(NumChannel , size(TargetAngleRange,2), length(RecFreqCenter));     % pre-allocation of memory
    recWeightQ = zeros(NumChannel, size(TargetAngleRange,2), length(RecFreqCenter));     % pre-allocation of memory
    
    % begin process
    ShowConfiguration(sysPara);                     %% print simulation configuration.
    hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
    hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
    [waveformArray, waveformSignal, steeringVector] = GenSignal(sysPara, hArray);       %% Gen. signal
    waveformArrayChannel = ChannelImplementation(sysPara, waveformArray);
    waveformInt = GenInterference(sysPara, hArray); %% Gen. interference
    waveformIntChannel = ChannelImplementation(sysPara, waveformInt);
    waveformNoise = GenNoise(sysPara, hArray);      %% Gen. noise
    waveformRx = waveformArrayChannel + waveformIntChannel + waveformNoise;           %% Rx waveform
    
    for idxFreq = 1:length(RecFreqCenter)
        sysPara.FreqCenter = RecFreqCenter(idxFreq);    % double scaler. Center frequency, Unit in Hz.  e.g. 5725e6, 34e9
        fprintf('Processing center frequency:\t %.2f MHz\n', sysPara.FreqCenter/1e6);
        
        [weight, errVector] = GenWeight(sysPara, hArray, waveformRx, waveformSignal);             %% Gen. Beamforming weight
        weight = conj(weight);
        weight = weight./repmat( weight(1,:), sysPara.NumChannel, 1);   % normalize channel #1 to zero phase
        weight = weight./repmat( max(abs(weight)), sysPara.NumChannel, 1);  % normalize max abs to 1.
        
        weightQuant = fix(weight*FullScale);    % Quantization to integer
        weightI = real(weightQuant);
        weightQ = imag(weightQuant);
        
        if  sum( sum( abs(weightI + 1j*weightQ)>(2^NumQuantizedBit-1) ) )
            error('Quantized weights exceed full scasle.')
        end
        
        recWeightI(:,:, idxFreq) = weightI;     % just record the weights
        recWeightQ(:,:, idxFreq) = weightQ;
    end
end

%% Fixed Wide Beam
if FlagFixedWideBeam
    % Parameter init.
    sysPara = GenSysPara();                         %% Gen. System para.
    sysPara.NumTarget = size(TargetAngleWideBeam,2);
    sysPara.TargetAngle = TargetAngleWideBeam;
    sysPara.TargetPower = zeros(size(TargetAngleWideBeam,2),1);                % double vector. target relative power above 1W in dB.
    sysPara.GlobalDebugPlot = false;
    sysPara.BeamformerType = 'LCMV';
    sysPara.LcmvPara.AngleToleranceAZ = AngleToleranceAZ; % double scaler. The angle (in degree) tolerance for LCVM constraints. The desired azimuth angle is set to [TargetAngle, TargetAngle-AngleToleranceAZ, TargetAngle+AngleToleranceAZ] with response of [1;1;1]
    % noise parameter
    sysPara.SwitchAWGN = true;          % boolen scaler. switch flag of AWGN.  true = add noise; false = not add noise.
    sysPara.SNR = 10;                   % double scaler. SNR, in dB, in-channel SNR. Valid only when SwitchAWGN = true.
    sysPara.SwitchInterence = false;    % boolen scaler. true = enable interference; false = disable interference.
    
    sysPara.StvIncludeElementResponse = false;
    sysPara.WeightsNormalization = 'bypass';
    sysPara.NumWeightsQuantizationBits = 0;
    sysPara.GlobalDebugPlot = ~true;
    % some generated para.
    NumQuantizedBit = 15;   % number of quantized bit for the weight
    FullScale = 2^NumQuantizedBit-1; % FullScale of the quantized weights
    NumChannel = sysPara.NumChannel;
    recWideWeightI = zeros(NumChannel, 1, length(RecFreqCenter));  % pre-allocation of memory
    recWideWeightQ = zeros(NumChannel, 1, length(RecFreqCenter));  % pre-allocation of memory
    
    ShowConfiguration(sysPara);                     %% print simulation configuration.
    hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
    hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
    [waveformArray, waveformSignal, steeringVector] = GenSignal(sysPara, hArray);       %% Gen. signal
    waveformArrayChannel = ChannelImplementation(sysPara, waveformArray);
    waveformInt = GenInterference(sysPara, hArray); %% Gen. interference
    waveformIntChannel = ChannelImplementation(sysPara, waveformInt);
    waveformNoise = GenNoise(sysPara, hArray);      %% Gen. noise
    waveformRx = waveformArrayChannel + waveformIntChannel + waveformNoise;           %% Rx waveform
    
    for idxFreq = 1:length(RecFreqCenter)
        sysPara.FreqCenter = RecFreqCenter(idxFreq);    % double scaler. Center frequency, Unit in Hz.  e.g. 5725e6, 34e9
        fprintf('Processing center frequency:\t %.2f MHz\n', sysPara.FreqCenter/1e6);
        
        [weight, errVector] = GenWeight(sysPara, hArray, waveformRx, waveformSignal);             %% Gen. Beamforming weight
        weight = conj(weight);
        weight = weight./repmat( weight(1,:), sysPara.NumChannel, 1);   % normalize channel #1 to zero phase
        weight = weight./repmat( max(abs(weight)), sysPara.NumChannel, 1);  % normalize max abs to 1.
        
        weightQuant = fix(weight*FullScale);    % Quantization to integer
        weightI = real(weightQuant);
        weightQ = imag(weightQuant);
        
        if  sum( sum( abs(weightI + 1j*weightQ)>(2^NumQuantizedBit-1) ) )
            error('Quantized weights exceed full scasle.')
        end
        
        recWideWeightI(:,:, idxFreq) = weightI;     % just record the weights
        recWideWeightQ(:,:, idxFreq) = weightQ;
    end
end

%% Fixed Wide Beam for CSMA directional coverage
if FlagFixedWideBeamCSMA
    % Parameter init.
    sysPara = GenSysPara();                         %% Gen. System para.
    sysPara.NumTarget = size(TargetAngleWideBeam,2);
    sysPara.TargetPower = zeros(size(TargetAngleWideBeam,2),1);                % double vector. target relative power above 1W in dB.
    sysPara.GlobalDebugPlot = false;
    sysPara.BeamformerType = 'LCMV-custom';

    % noise parameter
    sysPara.SwitchAWGN = true;          % boolen scaler. switch flag of AWGN.  true = add noise; false = not add noise.
    sysPara.SNR = 0;                   % double scaler. SNR, in dB, in-channel SNR. Valid only when SwitchAWGN = true.
    sysPara.SwitchInterence = false;    % boolen scaler. true = enable interference; false = disable interference.
    
    sysPara.StvIncludeElementResponse = ~false;
    sysPara.WeightsNormalization = 'bypass';
    sysPara.NumWeightsQuantizationBits = 0;
    sysPara.GlobalDebugPlot = ~true;
    % some generated para.
    NumQuantizedBit = 15;   % number of quantized bit for the weight
    FullScale = 2^NumQuantizedBit-1; % FullScale of the quantized weights
    NumChannel = sysPara.NumChannel;
    recWideCSMAWeightI = zeros(NumChannel, 4, length(RecFreqCenter));  % pre-allocation of memory
    recWideCSMAWeightQ = zeros(NumChannel, 4, length(RecFreqCenter));  % pre-allocation of memory
    
    ShowConfiguration(sysPara);                     %% print simulation configuration.
    hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
    hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
    [waveformArray, waveformSignal, steeringVector] = GenSignal(sysPara, hArray);       %% Gen. signal
    waveformArrayChannel = ChannelImplementation(sysPara, waveformArray);
    waveformInt = GenInterference(sysPara, hArray); %% Gen. interference
    waveformIntChannel = ChannelImplementation(sysPara, waveformInt);
    waveformNoise = GenNoise(sysPara, hArray);      %% Gen. noise
    waveformRx = waveformArrayChannel + waveformIntChannel + waveformNoise;           %% Rx waveform
    
    for idxFreq = 1:length(RecFreqCenter)
        sysPara.FreqCenter = RecFreqCenter(idxFreq);    % double scaler. Center frequency, Unit in Hz.  e.g. 5725e6, 34e9
        fprintf('Processing center frequency:\t %.2f MHz\n', sysPara.FreqCenter/1e6);
        
        % beam #1    -60~-30 degree
        sysPara.LcmvPara.ConstraintAngle = [-50; -3.5];  % -60~-30
        sysPara.LcmvPara.DesiredResponse = db2mag([0;]);
        sysPara.TargetAngle = sysPara.LcmvPara.ConstraintAngle(:,1);
        [weight, errVector] = GenWeight(sysPara, hArray, waveformRx, waveformSignal);             %% Gen. Beamforming weight
		weight = conj(weight);
        weight = weight./repmat( weight(1,:), sysPara.NumChannel, 1);   % normalize channel #1 to zero phase
        weight = weight./repmat( max(abs(weight)), sysPara.NumChannel, 1);  % normalize max abs to 1.
        weightQuant = fix(weight*FullScale);    % Quantization to integer
        weightI = real(weightQuant);
        weightQ = imag(weightQuant);
        if  sum( sum( abs(weightI + 1j*weightQ)>(2^NumQuantizedBit-1) ) )
            error('Quantized weights exceed full scasle.')
        end
        recWideCSMAWeightI(:,1, idxFreq) = weightI;     % just record the weights
        recWideCSMAWeightQ(:,1, idxFreq) = weightQ;
        
        % beam #2    -30~0 degree
        sysPara.LcmvPara.ConstraintAngle = [-20, -8; -3.5,   -3.5]; %% -30~-0
        sysPara.LcmvPara.DesiredResponse = db2mag([0;0]);
        sysPara.TargetAngle = sysPara.LcmvPara.ConstraintAngle(:,1);
        [weight, errVector] = GenWeight(sysPara, hArray, waveformRx, waveformSignal);             %% Gen. Beamforming weight
		weight = conj(weight);        
        weight = weight./repmat( weight(1,:), sysPara.NumChannel, 1);   % normalize channel #1 to zero phase
        weight = weight./repmat( max(abs(weight)), sysPara.NumChannel, 1);  % normalize max abs to 1.
        weightQuant = fix(weight*FullScale);    % Quantization to integer
        weightI = real(weightQuant);
        weightQ = imag(weightQuant);
        if  sum( sum( abs(weightI + 1j*weightQ)>(2^NumQuantizedBit-1) ) )
            error('Quantized weights exceed full scasle.')
        end
        recWideCSMAWeightI(:,2, idxFreq) = weightI;     % just record the weights
        recWideCSMAWeightQ(:,2, idxFreq) = weightQ;

        % beam #3    0~+30 degree
        sysPara.LcmvPara.ConstraintAngle = [22,5, ; -3.5, -3.5]; %% 0~30
        sysPara.LcmvPara.DesiredResponse = db2mag([0;0;]);
        sysPara.TargetAngle = sysPara.LcmvPara.ConstraintAngle(:,1);
        [weight, errVector] = GenWeight(sysPara, hArray, waveformRx, waveformSignal);             %% Gen. Beamforming weight
		weight = conj(weight);        
        weight = weight./repmat( weight(1,:), sysPara.NumChannel, 1);   % normalize channel #1 to zero phase
        weight = weight./repmat( max(abs(weight)), sysPara.NumChannel, 1);  % normalize max abs to 1.
        weightQuant = fix(weight*FullScale);    % Quantization to integer
        weightI = real(weightQuant);
        weightQ = imag(weightQuant);
        if  sum( sum( abs(weightI + 1j*weightQ)>(2^NumQuantizedBit-1) ) )
            error('Quantized weights exceed full scasle.')
        end
        recWideCSMAWeightI(:,3, idxFreq) = weightI;     % just record the weights
        recWideCSMAWeightQ(:,3, idxFreq) = weightQ;
        
        % beam #4    +30~+60 degree
        sysPara.LcmvPara.ConstraintAngle = [50; -3.5];  % +30~+60
        sysPara.LcmvPara.DesiredResponse = db2mag([0;]);
        sysPara.TargetAngle = sysPara.LcmvPara.ConstraintAngle(:,1);
        [weight, errVector] = GenWeight(sysPara, hArray, waveformRx, waveformSignal);             %% Gen. Beamforming weight
		weight = conj(weight);        
        weight = weight./repmat( weight(1,:), sysPara.NumChannel, 1);   % normalize channel #1 to zero phase
        weight = weight./repmat( max(abs(weight)), sysPara.NumChannel, 1);  % normalize max abs to 1.
        weightQuant = fix(weight*FullScale);    % Quantization to integer
        weightI = real(weightQuant);
        weightQ = imag(weightQuant);
        if  sum( sum( abs(weightI + 1j*weightQ)>(2^NumQuantizedBit-1) ) )
            error('Quantized weights exceed full scasle.')
        end
        recWideCSMAWeightI(:,4, idxFreq) = weightI;     % just record the weights
        recWideCSMAWeightQ(:,4, idxFreq) = weightQ;
    end    
end

%% Fixed interference search beam
if FlagFixedIntCanceller
    % Parameter init.
    sysPara = GenSysPara();                         %% Gen. System para.

    sysPara.GlobalDebugPlot = false;
    sysPara.BeamformerType = 'LCMV';
    sysPara.LcmvPara.AngleToleranceAZ = 0; % double scaler. The angle (in degree) tolerance for LCVM constraints. The desired azimuth angle is set to [TargetAngle, TargetAngle-AngleToleranceAZ, TargetAngle+AngleToleranceAZ] with response of [1;1;1]
    sysPara.LcmvPara.FlagSuppressInterference = true;

    % noise parameter
    sysPara.SwitchAWGN = true;          % boolen scaler. switch flag of AWGN.  true = add noise; false = not add noise.
    sysPara.SNR = 10;                   % double scaler. SNR, in dB, in-channel SNR. Valid only when SwitchAWGN = true.
    sysPara.SwitchInterence = false;    % boolen scaler. true = enable interference; false = disable interference.
    
    sysPara.StvIncludeElementResponse = false;
    sysPara.WeightsNormalization = 'minquantizationerror';
    sysPara.NumWeightsQuantizationBits = 0;
    sysPara.GlobalDebugPlot = ~true;
    % some generated para.
    NumQuantizedBit = 15;   % number of quantized bit for the weight
    FullScale = 2^NumQuantizedBit-1; % FullScale of the quantized weights
    NumChannel = sysPara.NumChannel;
    
    recWeightLeftIntSearchI = zeros(NumChannel , size(TargetAngleRange,2), length(RecFreqCenter));     % pre-allocation of memory
    recWeightLeftIntSearchQ = zeros(NumChannel, size(TargetAngleRange,2), length(RecFreqCenter));     % pre-allocation of memory
    recWeightRightIntSearchI = zeros(NumChannel , size(TargetAngleRange,2), length(RecFreqCenter));     % pre-allocation of memory
    recWeightRightIntSearchQ = zeros(NumChannel, size(TargetAngleRange,2), length(RecFreqCenter));     % pre-allocation of memory
    
    ShowConfiguration(sysPara);                     %% print simulation configuration.
    hAntennaElement = GenAntennaElement(sysPara);   %% Gen. antenna element
    hArray = GenArray(sysPara, hAntennaElement);    %% Gen. array
    [waveformArray, waveformSignal, steeringVector] = GenSignal(sysPara, hArray);       %% Gen. signal
    waveformArrayChannel = ChannelImplementation(sysPara, waveformArray);
    waveformInt = GenInterference(sysPara, hArray); %% Gen. interference
    waveformIntChannel = ChannelImplementation(sysPara, waveformInt);
    waveformNoise = GenNoise(sysPara, hArray);      %% Gen. noise
    waveformRx = waveformArrayChannel + waveformIntChannel + waveformNoise;           %% Rx waveform
    
    for idxFreq = 1:length(RecFreqCenter)
        sysPara.FreqCenter = RecFreqCenter(idxFreq);    % double scaler. Center frequency, Unit in Hz.  e.g. 5725e6, 34e9
        fprintf('Processing center frequency:\t %.2f MHz\n', sysPara.FreqCenter/1e6);
        
        for idxTargetAngle = 1:size(TargetAngleRange,2)
            TargetAngle = TargetAngleRange(:,idxTargetAngle);
            sysPara.NumTarget = size(TargetAngle,2);
            sysPara.TargetAngle = TargetAngle - [AngleSigInt;0];
            sysPara.TargetPower = zeros(size(TargetAngle,2),1);                % double vector. target relative power above 1W in dB.
            sysPara.InterferenceAngle = TargetAngle;
            
            [weight, errVector] = GenWeight(sysPara, hArray, waveformRx, waveformSignal);             %% Gen. Beamforming weight
            weight = conj(weight);
            weight = weight./repmat( weight(1,:), sysPara.NumChannel, 1);   % normalize channel #1 to zero phase
            weight = weight./repmat( max(abs(weight)), sysPara.NumChannel, 1);  % normalize max abs to 1.
            
            weightQuant = fix(weight*FullScale);    % Quantization to integer
            weightI = real(weightQuant);
            weightQ = imag(weightQuant);
            
            if  sum( sum( abs(weightI + 1j*weightQ)>(2^NumQuantizedBit-1) ) )
                error('Quantized weights exceed full scasle.')
            end
            
            recWeightLeftIntSearchI(:,idxTargetAngle, idxFreq) = weightI;     % just record the weights
            recWeightLeftIntSearchQ(:,idxTargetAngle, idxFreq) = weightQ;
            
            
            sysPara.TargetAngle = TargetAngle + [AngleSigInt;0];
            [weight, errVector] = GenWeight(sysPara, hArray, waveformRx, waveformSignal);             %% Gen. Beamforming weight
            weight = conj(weight);
            weight = weight./repmat( weight(1,:), sysPara.NumChannel, 1);   % normalize channel #1 to zero phase
            weight = weight./repmat( max(abs(weight)), sysPara.NumChannel, 1);  % normalize max abs to 1.
            
            weightQuant = fix(weight*FullScale);    % Quantization to integer
            weightI = real(weightQuant);
            weightQ = imag(weightQuant);
            
            if  sum( sum( abs(weightI + 1j*weightQ)>(2^NumQuantizedBit-1) ) )
                error('Quantized weights exceed full scasle.')
            end
            
            recWeightRightIntSearchI(:,idxTargetAngle, idxFreq) = weightI;     % just record the weights
            recWeightRightIntSearchQ(:,idxTargetAngle, idxFreq) = weightQ;
        end
    end
end

%% Export to C variable definition
if FlagExportToC
    fprintf('Begin code generation...\n');
    if ~exist(ExportFilePath, 'dir')
        mkdir(ExportFilePath)
    end
    cd(ExportFilePath)
    
    % Generation of header file
    fprintf('Header file...');
    fileID = fopen(ExportHeaderFileName,'w');
    fprintf(fileID,[...
        '/*This file is automatically generated by genWeightTable.m by Collus Wang.*/\n',...
        '/*Do NOT edit it manually.*/\n\n',...
        '/*Notice that the weights here have already had conjugated. i.e. waveformBf = waveformRx(Nx4)*weight(4x1); */\n\n',...
        '#ifndef FIXEDWEIGHTSTABLE_H_\n',...
        '#define FIXEDWEIGHTSTABLE_H_\n\n'...
        ]);
    
    if FlagFixedNarrowBeam
        % narrow beam
        fprintf(fileID, '\n/* Fixed Narrow Beam:*/\n');
        fprintf(fileID, '/*Number of Freq = %d, Number of TargetAngle =%d*/\n', length(RecFreqCenter), size(TargetAngleRange, 2));
        fprintf(fileID, '/*FreqCenter(MHz)= %.1f:%.1f:%.1f*/\n', RecFreqCenter(1)/1e6, RecFreqCenter(2)/1e6-RecFreqCenter(1)/1e6,RecFreqCenter(end)/1e6);
        fprintf(fileID, '/*TargetAngle(degree)= %.2f:%.2f:%.2f*/\n', TargetAngleRange(1,1), TargetAngleRange(1,2)-TargetAngleRange(1,1),TargetAngleRange(1,end));
        fprintf(fileID, '/* Real part of the weights*/\n');
        fprintf(fileID, 'extern const int16_t Tx_WBF_Table_Real[%d][%d][%d];\n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
        fprintf(fileID, '/* Imag part of the weights*/\n');
        fprintf(fileID, 'extern const int16_t Tx_WBF_Table_Imag[%d][%d][%d];\n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
    end
    
    if FlagFixedWideBeam
        % wide beam
        fprintf(fileID, '\n/* Fixed Wide Beam:*/\n');        
        fprintf(fileID, '/*Number of Freq = %d, Number of TargetAngle = %d*/\n', length(RecFreqCenter), size(TargetAngleWideBeam, 2));
        fprintf(fileID, '/*FreqCenter(MHz)= %.1f:%.1f:%.1f*/\n', RecFreqCenter(1)/1e6, RecFreqCenter(2)/1e6-RecFreqCenter(1)/1e6,RecFreqCenter(end)/1e6);
        fprintf(fileID, '/*TargetAngle(degree)= %.2f:%.2f:%.2f*/\n', TargetAngleWideBeam(1,1), 0,TargetAngleWideBeam(1,end));        
        fprintf(fileID, '/* Real part of the weights*/\n');
        fprintf(fileID, 'extern const int16_t Tx_WBF_Wide_Table_Real[%d][%d][%d];\n', length(RecFreqCenter), size(TargetAngleWideBeam, 2), NumChannel);
        fprintf(fileID, '/* Imag part of the weights*/\n');
        fprintf(fileID, 'extern const int16_t Tx_WBF_Wide_Table_Imag[%d][%d][%d];\n', length(RecFreqCenter), size(TargetAngleWideBeam, 2), NumChannel);
    end

    if FlagFixedWideBeamCSMA
        % wide beam for CSMA directional reception
        fprintf(fileID, '\n/* Fixed CSMA Wide Beam:*/\n');        
        fprintf(fileID, '/*Number of Freq = %d, Number of TargetAngle = %d*/\n', length(RecFreqCenter), size(recWideCSMAWeightI, 2) );
        fprintf(fileID, '/*FreqCenter(MHz)= %.1f:%.1f:%.1f*/\n', RecFreqCenter(1)/1e6, RecFreqCenter(2)/1e6-RecFreqCenter(1)/1e6,RecFreqCenter(end)/1e6);
        fprintf(fileID, '/*TargetAngle(degree)= [-60~-30, -30~0, 0~+30, +30~+60]*/\n');        
        fprintf(fileID, '/* Real part of the weights*/\n');
        fprintf(fileID, 'extern const int16_t Tx_WBF_CSMA_Wide_Table_Real[%d][%d][%d];\n', length(RecFreqCenter), size(recWideCSMAWeightI, 2), NumChannel);
        fprintf(fileID, '/* Imag part of the weights*/\n');
        fprintf(fileID, 'extern const int16_t Tx_WBF_CSMA_Wide_Table_Imag[%d][%d][%d];\n', length(RecFreqCenter), size(recWideCSMAWeightQ, 2), NumChannel);
    end
    
    if FlagFixedIntCanceller
        % interference search beam (left)
        fprintf(fileID, '\n/* Fixed Interference Search Beam (left):*/\n');
        fprintf(fileID, '/*Number of Freq = %d, Number of TargetAngle =%d*/\n', length(RecFreqCenter), size(TargetAngleRange, 2));
        fprintf(fileID, '/*FreqCenter(MHz)= %.1f:%.1f:%.1f*/\n', RecFreqCenter(1)/1e6, RecFreqCenter(2)/1e6-RecFreqCenter(1)/1e6,RecFreqCenter(end)/1e6);
        fprintf(fileID, '/*TargetAngle(degree)= %.2f:%.2f:%.2f*/\n', TargetAngleRange(1,1), TargetAngleRange(1,2)-TargetAngleRange(1,1),TargetAngleRange(1,end));
        fprintf(fileID, '/* Real part of the weights*/\n');
        fprintf(fileID, 'extern const int16_t IntSearch_Left_WBF_Table_Real[%d][%d][%d];\n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
        fprintf(fileID, '/* Imag part of the weights*/\n');
        fprintf(fileID, 'extern const int16_t IntSearch_Left_WBF_Table_Imag[%d][%d][%d];\n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
        % interference search beam (right)
        fprintf(fileID, '\n/* Fixed Interference Search Beam (right):*/\n');
        fprintf(fileID, '/*Number of Freq = %d, Number of TargetAngle =%d*/\n', length(RecFreqCenter), size(TargetAngleRange, 2));
        fprintf(fileID, '/*FreqCenter(MHz)= %.1f:%.1f:%.1f*/\n', RecFreqCenter(1)/1e6, RecFreqCenter(2)/1e6-RecFreqCenter(1)/1e6,RecFreqCenter(end)/1e6);
        fprintf(fileID, '/*TargetAngle(degree)= %.2f:%.2f:%.2f*/\n', TargetAngleRange(1,1), TargetAngleRange(1,2)-TargetAngleRange(1,1),TargetAngleRange(1,end));
        fprintf(fileID, '/* Real part of the weights*/\n');
        fprintf(fileID, 'extern const int16_t IntSearch_Right_WBF_Table_Real[%d][%d][%d];\n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
        fprintf(fileID, '/* Imag part of the weights*/\n');
        fprintf(fileID, 'extern const int16_t IntSearch_Right_WBF_Table_Imag[%d][%d][%d];\n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
    end        
        
    fprintf(fileID, '\n\n#endif /* FIXEDWEIGHTSTABLE_H_ */\n');
    fprintf('Done!\n')   
    fclose(fileID);

    % Generation of source file
    fileID = fopen(ExportSourceFileName,'w');
    fprintf('Source file...');
    
    fprintf(fileID, '/*This table is automatically generated by genWeightTable.m by Collus Wang.*/\n/*Do NOT edit it manually.*/\n\n');
    fprintf(fileID, '/*Notice that the weights here have already had conjugated. i.e. waveformBf = waveformRx(Nx4)*weight(4x1); */\n\n');
    fprintf(fileID, '#include "stdint.h"\n');
    fprintf(fileID, '#include "%s"\n', ExportHeaderFileName);

    % narrow beam
    if FlagFixedNarrowBeam
        fprintf(fileID, '\n/* Fixed Narrow Beam:*/\n');
        fprintf(fileID, '/*Number of Freq = %d, Number of TargetAngle =%d*/\n', length(RecFreqCenter), size(TargetAngleRange, 2));
        fprintf(fileID, '/*FreqCenter(MHz)= %.1f:%.1f:%.1f*/\n', RecFreqCenter(1)/1e6, RecFreqCenter(2)/1e6-RecFreqCenter(1)/1e6,RecFreqCenter(end)/1e6);
        fprintf(fileID, '/*TargetAngle(degree)= %.2f:%.2f:%.2f*/\n', TargetAngleRange(1,1), TargetAngleRange(1,2)-TargetAngleRange(1,1),TargetAngleRange(1,end));
        % write I-weight
        fprintf(fileID, '\n/* Real part of the weights*/');
        fprintf(fileID, '\nconst int16_t Tx_WBF_Table_Real[%d][%d][%d]= \n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
        fprintf(fileID, '{\n');
        for idxFreq = 1:length(RecFreqCenter)
            fprintf(fileID, '\t{ /* Freq (MHz) = %.1f*/\n\t\t', RecFreqCenter(idxFreq)/1e6 );
            
            for idxAngle = 1:size(TargetAngleRange, 2)
                if idxAngle ~=size(TargetAngleRange, 2)
                    fprintf(fileID, '{%d,%d,%d,%d},', recWeightI(:,idxAngle,idxFreq));
                else
                    fprintf(fileID, '{%d,%d,%d,%d}', recWeightI(:,idxAngle,idxFreq));
                end
            end
            if idxFreq ~= length(RecFreqCenter)
                fprintf(fileID, '\n\t},\n');
            else
                fprintf(fileID, '\n\t}\n');
            end
        end
        fprintf(fileID, '};\n');
        
        % write Q-weight
        fprintf(fileID, '\n/* Imag part of the weights*/');
        fprintf(fileID, '\nconst int16_t Tx_WBF_Table_Imag[%d][%d][%d]= \n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
        fprintf(fileID, '{\n');
        for idxFreq = 1:length(RecFreqCenter)
            fprintf(fileID, '\t{ /* Freq (MHz) = %.1f*/\n\t\t', RecFreqCenter(idxFreq)/1e6 );
            
            for idxAngle = 1:size(TargetAngleRange, 2)
                if idxAngle ~=size(TargetAngleRange, 2)
                    fprintf(fileID, '{%d,%d,%d,%d},', recWeightQ(:,idxAngle,idxFreq));
                else
                    fprintf(fileID, '{%d,%d,%d,%d}', recWeightQ(:,idxAngle,idxFreq));
                end
            end
            if idxFreq ~= length(RecFreqCenter)
                fprintf(fileID, '\n\t},\n');
            else
                fprintf(fileID, '\n\t}\n');
            end
        end
        fprintf(fileID, '};\n');
    end

    % Wide Beam
    if FlagFixedWideBeam
        fprintf(fileID, '\n\n\n');
        % write I-weight
        fprintf(fileID, '\n/* Fixed Wide Beam:*/\n');
    
        fprintf(fileID, '/*Number of Freq = %d, Number of TargetAngle =%d*/\n', length(RecFreqCenter), size(TargetAngleWideBeam, 2));
        fprintf(fileID, '/*FreqCenter(MHz)= %.1f:%.1f:%.1f*/\n', RecFreqCenter(1)/1e6, RecFreqCenter(2)/1e6-RecFreqCenter(1)/1e6,RecFreqCenter(end)/1e6);
        fprintf(fileID, '/*TargetAngle(degree)= %.2f:%.2f:%.2f*/\n', TargetAngleWideBeam(1,1), 0,TargetAngleWideBeam(1,end));
    
        fprintf(fileID, '\n/* Real part of the weights*/');
        fprintf(fileID, '\nconst int16_t Tx_WBF_Wide_Table_Real[%d][%d][%d]= \n', length(RecFreqCenter), size(TargetAngleWideBeam, 2), NumChannel);
        fprintf(fileID, '{\n');
        for idxFreq = 1:length(RecFreqCenter)
            fprintf(fileID, '\t{ /* Freq (MHz) = %.1f*/\n\t\t', RecFreqCenter(idxFreq)/1e6 );
            for idxAngle = 1:size(TargetAngleWideBeam, 2)
                if idxAngle ~=size(TargetAngleWideBeam, 2)
                    fprintf(fileID, '{%d,%d,%d,%d},', recWideWeightI(:,idxAngle,idxFreq));
                else
                    fprintf(fileID, '{%d,%d,%d,%d}', recWideWeightI(:,idxAngle,idxFreq));
                end
            end
            if idxFreq ~= length(RecFreqCenter)
                fprintf(fileID, '\n\t},\n');
            else
                fprintf(fileID, '\n\t}\n');
            end
        end
        fprintf(fileID, '};\n');
    
        % write Q-weight
        fprintf(fileID, '\n/* Imag part of the weights*/');
        fprintf(fileID, '\nconst int16_t Tx_WBF_Wide_Table_Imag[%d][%d][%d]= \n', length(RecFreqCenter), size(TargetAngleWideBeam, 2), NumChannel);
        fprintf(fileID, '{\n');
        for idxFreq = 1:length(RecFreqCenter)
            fprintf(fileID, '\t{ /* Freq (MHz) = %.1f*/\n\t\t', RecFreqCenter(idxFreq)/1e6 );
            
            for idxAngle = 1:size(TargetAngleWideBeam, 2)
                if idxAngle ~=size(TargetAngleWideBeam, 2)
                    fprintf(fileID, '{%d,%d,%d,%d},', recWideWeightQ(:,idxAngle,idxFreq));
                else
                    fprintf(fileID, '{%d,%d,%d,%d}', recWideWeightQ(:,idxAngle,idxFreq));
                end
            end
            if idxFreq ~= length(RecFreqCenter)
                fprintf(fileID, '\n\t},\n');
            else
                fprintf(fileID, '\n\t}\n');
            end
        end
        fprintf(fileID, '};\n');
    end

    % Wide Beam for CSMA directional reception
    if FlagFixedWideBeamCSMA
        fprintf(fileID, '\n\n\n');
        % write I-weight
        fprintf(fileID, '\n/* Fixed CSMA Wide Beam:*/\n');
    
        fprintf(fileID, '/*Number of Freq = %d, Number of TargetAngle = %d*/\n', length(RecFreqCenter), size(recWideCSMAWeightI, 2) );
        fprintf(fileID, '/*FreqCenter(MHz)= %.1f:%.1f:%.1f*/\n', RecFreqCenter(1)/1e6, RecFreqCenter(2)/1e6-RecFreqCenter(1)/1e6,RecFreqCenter(end)/1e6);
        fprintf(fileID, '/*TargetAngle(degree)= [-60~-30, -30~0, 0~+30, +30~+60]*/\n');       
    
        fprintf(fileID, '\n/* Real part of the weights*/');
        fprintf(fileID, '\nconst int16_t Tx_WBF_Wide_Table_Real[%d][%d][%d]= \n', length(RecFreqCenter), size(recWideCSMAWeightI, 2), NumChannel);
        fprintf(fileID, '{\n');
        for idxFreq = 1:length(RecFreqCenter)
            fprintf(fileID, '\t{ /* Freq (MHz) = %.1f*/\n\t\t', RecFreqCenter(idxFreq)/1e6 );
            for idxAngle = 1:size(recWideCSMAWeightI, 2)
                if idxAngle ~=size(recWideCSMAWeightI, 2)
                    fprintf(fileID, '{%d,%d,%d,%d},', recWideCSMAWeightI(:,idxAngle,idxFreq));
                else
                    fprintf(fileID, '{%d,%d,%d,%d}', recWideCSMAWeightI(:,idxAngle,idxFreq));
                end
            end
            if idxFreq ~= length(RecFreqCenter)
                fprintf(fileID, '\n\t},\n');
            else
                fprintf(fileID, '\n\t}\n');
            end
        end
        fprintf(fileID, '};\n');
    
        % write Q-weight
        fprintf(fileID, '\n/* Imag part of the weights*/');
        fprintf(fileID, '\nconst int16_t Tx_WBF_Wide_Table_Imag[%d][%d][%d]= \n', length(RecFreqCenter), size(recWideCSMAWeightQ, 2), NumChannel);
        fprintf(fileID, '{\n');
        for idxFreq = 1:length(RecFreqCenter)
            fprintf(fileID, '\t{ /* Freq (MHz) = %.1f*/\n\t\t', RecFreqCenter(idxFreq)/1e6 );
            
            for idxAngle = 1:size(recWideCSMAWeightQ, 2)
                if idxAngle ~=size(recWideCSMAWeightQ, 2)
                    fprintf(fileID, '{%d,%d,%d,%d},', recWideCSMAWeightQ(:,idxAngle,idxFreq));
                else
                    fprintf(fileID, '{%d,%d,%d,%d}', recWideCSMAWeightQ(:,idxAngle,idxFreq));
                end
            end
            if idxFreq ~= length(RecFreqCenter)
                fprintf(fileID, '\n\t},\n');
            else
                fprintf(fileID, '\n\t}\n');
            end
        end
        fprintf(fileID, '};\n');
    end
    
    % Interference Search Beam:
    if FlagFixedIntCanceller
        % interference search beam (left)
        fprintf(fileID, '\n/* Fixed Interference Search Beam (left):*/\n');
        fprintf(fileID, '/*Number of Freq = %d, Number of TargetAngle =%d*/\n', length(RecFreqCenter), size(TargetAngleRange, 2));
        fprintf(fileID, '/*FreqCenter(MHz)= %.1f:%.1f:%.1f*/\n', RecFreqCenter(1)/1e6, RecFreqCenter(2)/1e6-RecFreqCenter(1)/1e6,RecFreqCenter(end)/1e6);
        fprintf(fileID, '/*TargetAngle(degree)= %.2f:%.2f:%.2f*/\n', TargetAngleRange(1,1), TargetAngleRange(1,2)-TargetAngleRange(1,1),TargetAngleRange(1,end));
        % write I-weight
        fprintf(fileID, '\n/* Real part of the weights*/');
        fprintf(fileID, '\nconst int16_t IntSearch_Left_WBF_Table_Real[%d][%d][%d]= \n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
        fprintf(fileID, '{\n');
        for idxFreq = 1:length(RecFreqCenter)
            fprintf(fileID, '\t{ /* Freq (MHz) = %.1f*/\n\t\t', RecFreqCenter(idxFreq)/1e6 );
            
            for idxAngle = 1:size(TargetAngleRange, 2)
                if idxAngle ~=size(TargetAngleRange, 2)
                    fprintf(fileID, '{%d,%d,%d,%d},', recWeightLeftIntSearchI(:,idxAngle,idxFreq));
                else
                    fprintf(fileID, '{%d,%d,%d,%d}', recWeightLeftIntSearchI(:,idxAngle,idxFreq));
                end
            end
            if idxFreq ~= length(RecFreqCenter)
                fprintf(fileID, '\n\t},\n');
            else
                fprintf(fileID, '\n\t}\n');
            end
        end
        fprintf(fileID, '};\n');
        
        % write Q-weight
        fprintf(fileID, '\n/* Imag part of the weights*/');
        fprintf(fileID, '\nconst int16_t IntSearch_Left_WBF_Table_Imag[%d][%d][%d]= \n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
        fprintf(fileID, '{\n');
        for idxFreq = 1:length(RecFreqCenter)
            fprintf(fileID, '\t{ /* Freq (MHz) = %.1f*/\n\t\t', RecFreqCenter(idxFreq)/1e6 );
            
            for idxAngle = 1:size(TargetAngleRange, 2)
                if idxAngle ~=size(TargetAngleRange, 2)
                    fprintf(fileID, '{%d,%d,%d,%d},', recWeightLeftIntSearchQ(:,idxAngle,idxFreq));
                else
                    fprintf(fileID, '{%d,%d,%d,%d}', recWeightLeftIntSearchQ(:,idxAngle,idxFreq));
                end
            end
            if idxFreq ~= length(RecFreqCenter)
                fprintf(fileID, '\n\t},\n');
            else
                fprintf(fileID, '\n\t}\n');
            end
        end
        fprintf(fileID, '};\n');
        
        % interference search beam (right)
        fprintf(fileID, '\n/* Fixed Interference Search Beam (right):*/\n');
        fprintf(fileID, '/*Number of Freq = %d, Number of TargetAngle =%d*/\n', length(RecFreqCenter), size(TargetAngleRange, 2));
        fprintf(fileID, '/*FreqCenter(MHz)= %.1f:%.1f:%.1f*/\n', RecFreqCenter(1)/1e6, RecFreqCenter(2)/1e6-RecFreqCenter(1)/1e6,RecFreqCenter(end)/1e6);
        fprintf(fileID, '/*TargetAngle(degree)= %.2f:%.2f:%.2f*/\n', TargetAngleRange(1,1), TargetAngleRange(1,2)-TargetAngleRange(1,1),TargetAngleRange(1,end));
        % write I-weight
        fprintf(fileID, '\n/* Real part of the weights*/');
        fprintf(fileID, '\nconst int16_t IntSearch_Right_WBF_Table_Real[%d][%d][%d]= \n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
        fprintf(fileID, '{\n');
        for idxFreq = 1:length(RecFreqCenter)
            fprintf(fileID, '\t{ /* Freq (MHz) = %.1f*/\n\t\t', RecFreqCenter(idxFreq)/1e6 );
            
            for idxAngle = 1:size(TargetAngleRange, 2)
                if idxAngle ~=size(TargetAngleRange, 2)
                    fprintf(fileID, '{%d,%d,%d,%d},', recWeightRightIntSearchI(:,idxAngle,idxFreq));
                else
                    fprintf(fileID, '{%d,%d,%d,%d}', recWeightRightIntSearchI(:,idxAngle,idxFreq));
                end
            end
            if idxFreq ~= length(RecFreqCenter)
                fprintf(fileID, '\n\t},\n');
            else
                fprintf(fileID, '\n\t}\n');
            end
        end
        fprintf(fileID, '};\n');
        
        % write Q-weight
        fprintf(fileID, '\n/* Imag part of the weights*/');
        fprintf(fileID, '\nconst int16_t IntSearch_Right_WBF_Table_Imag[%d][%d][%d]= \n', length(RecFreqCenter), size(TargetAngleRange, 2), NumChannel);
        fprintf(fileID, '{\n');
        for idxFreq = 1:length(RecFreqCenter)
            fprintf(fileID, '\t{ /* Freq (MHz) = %.1f*/\n\t\t', RecFreqCenter(idxFreq)/1e6 );
            
            for idxAngle = 1:size(TargetAngleRange, 2)
                if idxAngle ~=size(TargetAngleRange, 2)
                    fprintf(fileID, '{%d,%d,%d,%d},', recWeightRightIntSearchQ(:,idxAngle,idxFreq));
                else
                    fprintf(fileID, '{%d,%d,%d,%d}', recWeightRightIntSearchQ(:,idxAngle,idxFreq));
                end
            end
            if idxFreq ~= length(RecFreqCenter)
                fprintf(fileID, '\n\t},\n');
            else
                fprintf(fileID, '\n\t}\n');
            end
        end
        fprintf(fileID, '};\n');
    end
    
    fclose(fileID);
    cd('..');cd('..');
    fprintf('Done!\n')
end

fprintf('############################### Finished ###############################\n')
%% Stop Timer
tElapsed = toc(tStart);
fprintf('Total elapsed time = %.2fsec = %dmin %.2fsec\n', tElapsed, floor(tElapsed/60), tElapsed-floor(tElapsed/60)*60);
