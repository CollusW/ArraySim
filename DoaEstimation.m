function [doa, spacialSpectrum] = DoaEstimation(sysPara, hArray, waveformRx, waveformPilot)
% /*!
%  *  @brief     This function estimates the DOA of rx waveform according to the doa method.
%  *  @details   . 
%  *  @param[out] doa, 2xK doulbe. DOA of rx waveform. Each column represents one target/interfernence. Direction in degree, [azimuth; elevation]. 
%                   The azimuth angle must be between ¨C180 and 180 degrees, and the elevation angle must be between ¨C90 and 90 degrees. K is the
%                   number of incoming waves.
%  *  @param[out] spacialSpectrum, is a 3D matrix representing the magnitude of the estimated 2-D spatial spectrum for each target. 
%                   first dimension equals to the number of elevation angles specified in ElevationScanAngles 
%                   second dimension equals to the number of azimuth angles specified in AzimuthScanAngles.
%                   third dimension coresponds to the target. (note: some method does not distinguish targets, therefore the third dimension is 1.)
%  *  @param[in] sysPara, 1x1 struct, which contains the following field:
%       see get used field for detail.
%  *  @param[in] hArray, 1x1 antenna array system object.
%  *  @param[in] waveformRx, NxM complex vector. received waveform. N is the number of samples(snaps), M is the number of channel
%  *  @param[in] waveformPilot, NxL complex vector. pilot waveform. N is the number of samples(snaps), L is the number of pilots
%                from targets. This parameter is optional in some beamforming method.
%  *  @pre       .
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.06.27.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.05.25. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2017.07.12. Collus Wang,  change output parameter spacialSpectrum from 2D to 3D. }
%  */

%% Get used field
DoaEstimator = sysPara.DoaEstimator;
FreqCenter = sysPara.FreqCenter;
AzimuthScanAngles = sysPara.AzimuthScanAngles;
ElevationScanAngles = sysPara.ElevationScanAngles;
NumTarget = sysPara.NumTarget;
LenWaveform = sysPara.LenWaveform;

%% Flags
GlobalDebugPlot = sysPara.GlobalDebugPlot;
FlagDebugPlot = true && GlobalDebugPlot;
figureStartNum = 6000;

%% process
switch lower(DoaEstimator)
    case 'toolboxmusicestimator2d'
        spacialSpectrum = zeros(length(ElevationScanAngles), length(AzimuthScanAngles), 1); % this method does not distinguish targets, therefore the third dimension is 1.
        hDoaEstimator = phased.BeamscanEstimator2D('SensorArray',hArray,...
            'OperatingFrequency',FreqCenter,...
            'DOAOutputPort',true,...
            'NumSignals',NumTarget,...
            'AzimuthScanAngles',AzimuthScanAngles.',...
            'ElevationScanAngles',ElevationScanAngles.');
        [spacialSpectrum(:,:,1), doa] = step(hDoaEstimator, waveformRx);
        % sort DOA azimuth angles in ascending order
        [~,idxTmp] = sort(doa(1,:), 'ascend');
        doa = doa(:,idxTmp);
        if FlagDebugPlot
            figure(figureStartNum); clf;            
            plotSpectrum(hDoaEstimator)
            if isvector(spacialSpectrum(:,:,1))    % 1D DOA, plot the estimated DOA on spectrum
                TargetAngle = sysPara.TargetAngle;
                InterferenceAngle = sysPara.InterferenceAngle;
                SwitchInterence = sysPara.SwitchInterence;
                hold on
                for idxTmp = 1:size(doa,2)
                    plot([TargetAngle(1,idxTmp), TargetAngle(1,idxTmp)], [min(mag2db(spacialSpectrum)), mag2db(spacialSpectrum(AzimuthScanAngles==TargetAngle(1,idxTmp)))], 'b-' )
                    if SwitchInterence
                        plot([InterferenceAngle(1,idxTmp), InterferenceAngle(1,idxTmp)], [min(mag2db(spacialSpectrum)), mag2db(spacialSpectrum(AzimuthScanAngles==InterferenceAngle(1,idxTmp)))], 'r--' )
                    end
                    plot([doa(1,idxTmp), doa(1,idxTmp)], [min(mag2db(spacialSpectrum)), mag2db(spacialSpectrum(AzimuthScanAngles==doa(1,idxTmp)))], 'b-o' )
                end
                legend('Spatial Spectrum', 'Target', 'Interference', 'DOA', 'Location', 'best')
            end
        end
    case 'music'
        error('Not implemented yet.')
    otherwise
        error('Unsupported DOA estimator.');
end



