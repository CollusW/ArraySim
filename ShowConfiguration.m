function [ ] = ShowConfiguration( sysPara)
% /*!
%  *  @brief     This function is used to print the simulation configuration settings.
%  *  @details   
%  *  @param[out] 
%  *  @param[in] sysPara, 1x1 struct. system configuration paramenter struct.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date       2017.06.06.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.06.06. Collus Wang,  first draft }
%  */

fprintf('\n------------Configuration Info.----------------\n')
fprintf('General parameter:\n');
fprintf('\tSample rate: %fMSPS\n',sysPara.SampleRate/1e6);
fprintf('\tSimulation duration: %.3fus\n', sysPara.Duration*1e6);

fprintf('Antenna parameter:\n');
fprintf('\tAntenna type: %s\n',sysPara.AntennaType);
fprintf('\tAntenna patten file name: %s\n',sysPara.AntennaPatternFileName);
fprintf('\tCenter frequency: %.3fMHz\n',sysPara.FreqCenter/1e6);
fprintf('\tFrequency span: %.3fMHz\n',sysPara.FreqSpan/1e6);

fprintf('Array parameter:\n');
fprintf('\tArray type: %s\n',sysPara.ArrayType);
fprintf('\tNumber of antenna elements: %d\n',sysPara.NumElements);
fprintf('\tNumber of used channels: %d\n',sysPara.NumChannel);
fprintf('\tRadius of UCA array: %.3fm\n',sysPara.Radius);
fprintf('\tSteering vector calculation include element response: %d\n', sysPara.StvIncludeElementResponse);

fprintf('Target parameter:\n');
fprintf('\tTarget singal type: %s\n',sysPara.TargetSigType);
fprintf('\tNumber of target: %d\n',sysPara.NumTarget);
fprintf('\tDirection of target ([azimuth, elevation] in degree):\n');
for idxTarget = 1:sysPara.NumTarget
    fprintf('\t\tTarget #%2d:\t[%+7.2f, %+7.2f]\n',idxTarget,sysPara.TargetAngle(1,idxTarget),sysPara.TargetAngle(2,idxTarget));
end
fprintf('\tNormalized power in dB (relative to 1):\n');
for idxTarget = 1:sysPara.NumTarget
    fprintf('\t\tTarget #%2d:\t%+7.2f dB\n',idxTarget, sysPara.TargetPower(idxTarget));
end
fprintf('\tSymbol rate: %.6fMSPS\n',sysPara.SymbolRate/1e6);

fprintf('Channel implementation parameter:\n');
if sysPara.SwitchChannelImplementation
    fprintf('\tSwitch of channel implementation: Enable\n');
else
    fprintf('\tSwitch of channel implementation: Disable\n');
end
fprintf('\tChannel amplitude error:\n');
for idxChannel = 1:sysPara.NumChannel
    fprintf('\t\tChannel #%2d:%+7.2f dB\n',idxChannel, sysPara.ChannelAmpliErr(idxChannel));
end
fprintf('\tChannel phase error:\n');
for idxChannel = 1:sysPara.NumChannel
    fprintf('\t\tChannel #%2d:%+7.2f degree\n',idxChannel, sysPara.ChannelPhaseErr(idxChannel));
end

fprintf('Interfence parameter:\n');
if sysPara.SwitchInterence
    fprintf('\tSwitch of interfence: Enable\n');
else
    fprintf('\tSwitch of interfence: Disable\n');
end
fprintf('\tInterferece type: %s\n',sysPara.InterferenceType);
fprintf('\tNumber of interference: %d\n',sysPara.NumInterference);
fprintf('\tInterferece frequency:\n');
for idxInterference = 1:sysPara.NumInterference
    fprintf('\t\tInterferece #%2d: %.3fKHz\n',idxInterference, sysPara.InterferenceFreq(idxInterference)/1e3);
end
fprintf('\tSIR in dB: (assume signal power = 1)\n');
for idxInterference = 1:sysPara.NumInterference
    fprintf('\t\tInterferece #%2d: SIR = %.3f dB\n', idxInterference, sysPara.SIR(idxInterference));
end

fprintf('\tDirection of interference ([azimuth, elevation] in degree):\n');
for idxInter = 1:sysPara.NumInterference
    fprintf('\t\tInterference #%2d:\t[%+7.2f, %+7.2f]\n',idxInter,sysPara.InterferenceAngle(1,idxInter),sysPara.InterferenceAngle(2,idxInter));
end

fprintf('Noise parameter:\n');
if sysPara.SwitchAWGN
    fprintf('\tSwitch of AWGN: Enable\n');
else
    fprintf('\tSwitch of AWGN: Disable\n');
end
fprintf('\tSNR: %.2f dB\n',sysPara.SNR);

fprintf('Beamformer:\n');
fprintf('\tBeamformer type: %s\n',sysPara.BeamformerType);
fprintf('\tWeights normalization: %s\n',sysPara.WeightsNormalization);
fprintf('\tNumber of bits for weights quantization (0=No quantization): %d\n',sysPara.NumWeightsQuantizationBits);

fprintf('Direction of Arrival Estimation:\n');
fprintf('\tDOA calculation include element response: %d\n', sysPara.DOAIncludeElementResponse);
fprintf('\tDOA Estimator: %s\n',sysPara.DoaEstimator);
fprintf('\tAzimuth scan angles in degree:');
fprintf('\t[%.2f : %.2f : %.2f]\n', sysPara.AzimuthScanAngles(1), sysPara.AzimuthScanAngles(2)-sysPara.AzimuthScanAngles(1), sysPara.AzimuthScanAngles(end)); 
fprintf('\tElevation scan angles in degree:')
if length(sysPara.ElevationScanAngles)>1
    fprintf('\t[%.2f : %.2f : %.2f]\n', sysPara.ElevationScanAngles(1), sysPara.ElevationScanAngles(2)-sysPara.ElevationScanAngles(1), sysPara.ElevationScanAngles(end));
else
    fprintf('\t[%.2f]\n', sysPara.ElevationScanAngles)
end

fprintf('Flags:\n');
if sysPara.GlobalDebugPlot
    fprintf('\tSwitch of global debug plot: Enable\n');
else
    fprintf('\tSwitch of global debug plot: Disable\n');
end

fprintf('Generated parameters:\n');
fprintf('\tFrequency range of Antenna Elements: %.3f - %.3fMHz\n',sysPara.FrequencyRange(1)/1e6,sysPara.FrequencyRange(2)/1e6);
fprintf('\tNumber of samples for the simulation: %d\n',sysPara.LenWaveform);

fprintf('------------End of Configuration Info.----------------\n');
end
