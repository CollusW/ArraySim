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
%  * @remark   { revision history: V1.2, 2017.07.19. Wayne Zang,  differentiate common MUSIC and anti-interference MUSIC algorithm. }
%  * @remark   { revision history: V1.3, 2017.10.18. Wayne Zang,  MUSIC method peak search optimization and support DoaEstiMaxNumSig feature. }
%  */

%% Get used field
DoaEstimator = sysPara.DoaEstimator;
FreqCenter = sysPara.FreqCenter;
AzimuthScanAngles = sysPara.AzimuthScanAngles;
ElevationScanAngles = sysPara.ElevationScanAngles;
NumTarget = sysPara.NumTarget;
LenWaveform = sysPara.LenWaveform;
DOAIncludeElementResponse = sysPara.DOAIncludeElementResponse;
DoaEstiMaxNumSig = sysPara.DoaEstiMaxNumSig;

%% Flags
GlobalDebugPlot = sysPara.GlobalDebugPlot;
FlagDebugPlot = true && GlobalDebugPlot;
figureStartNum = 6000;

%% process
switch lower(DoaEstimator)
    case 'toolboxmusicestimator2d'
        spacialSpectrum = zeros(length(ElevationScanAngles), length(AzimuthScanAngles), 1); % this method does not distinguish targets, therefore the third dimension is 1.
        LenRS = 512;  % RS length
        if LenWaveform < LenRS, error('Waveform length < RS length!'); end  % check length
        idxRS = (1:LenRS) + 0; % RS indices
        hDoaEstimator = phased.BeamscanEstimator2D('SensorArray',hArray,...
            'OperatingFrequency',FreqCenter,...
            'DOAOutputPort',true,...
            'NumSignals',NumTarget,...
            'AzimuthScanAngles',AzimuthScanAngles.',...
            'ElevationScanAngles',ElevationScanAngles.');
        [spacialSpectrum(:,:,1), doa] = step(hDoaEstimator, waveformRx(idxRS,:));
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
    case 'cbf'
        spacialSpectrum = zeros(length(ElevationScanAngles), length(AzimuthScanAngles), NumTarget);
        LenRS = 512;  % RS length
        if LenWaveform < LenRS, error('Waveform length < RS length!'); end  % check length
        idxRS = (1:LenRS) + 0; % RS indices
        Pxs = waveformRx(idxRS,:).'*conj(waveformPilot(idxRS,:))/LenRS;   % cross-correlation vector
        hSteeringVector = phased.SteeringVector('SensorArray', hArray,...
            'PropagationSpeed', physconst('LightSpeed'),...
            'IncludeElementResponse', DOAIncludeElementResponse,...
            'NumPhaseShifterBits', 0 ...    'EnablePolarization', false ...
            );
        elevationScanVector = ones(size(AzimuthScanAngles))*ElevationScanAngles;
        angleScanVector = [AzimuthScanAngles, elevationScanVector];
        steeringVector = step(hSteeringVector, FreqCenter, angleScanVector.');
        steeringVector = steeringVector*diag(rms(steeringVector).^-1);
        angleMatchVector = abs(steeringVector'*Pxs);
        [~, idxPeak] = max(angleMatchVector);
        doa = angleScanVector(idxPeak, :).';
        spacialSpectrum(1,:,:) = angleMatchVector;
        if FlagDebugPlot
            TargetAngle = sysPara.TargetAngle;
            for idxTarget = 1:NumTarget
                figure(figureStartNum + idxTarget);
                hold off;
                plot(AzimuthScanAngles, mag2db(spacialSpectrum(1,:,idxTarget)), 'b-');
                hold on;
                plot([TargetAngle(1,idxTarget), TargetAngle(1,idxTarget)],...
                    [min(mag2db(spacialSpectrum(1,:,idxTarget))),...
                    mag2db(spacialSpectrum(1,(TargetAngle(1,idxTarget) - AzimuthScanAngles(1))/(AzimuthScanAngles(2) - AzimuthScanAngles(1)) + 1,idxTarget))], 'b-');
                plot([doa(1,idxTarget), doa(1,idxTarget)],...
                    [min(mag2db(spacialSpectrum(1,:,idxTarget))),...
                    mag2db(spacialSpectrum(1,(doa(1,idxTarget) - AzimuthScanAngles(1))/(AzimuthScanAngles(2) - AzimuthScanAngles(1)) + 1,idxTarget))], 'bo-');
                grid on;
                axis([min(AzimuthScanAngles), max(AzimuthScanAngles), min(mag2db(spacialSpectrum(1,:,idxTarget))), max(mag2db(spacialSpectrum(1,:,idxTarget)))]);
                title(['Target ', num2str(idxTarget), ': Common Beamform Spatial Spectrum at Elevation 0 Degree']);
                xlabel('Azimuth Angle(degree)');
                ylabel('Power(dB)');
                legend('Spatial Spectrum', 'Target', 'DOA');
            end
        end
    case 'music'
        spacialSpectrum = zeros(length(ElevationScanAngles), length(AzimuthScanAngles), NumTarget);
        LenRS = 512;  % RS length
        if LenWaveform < LenRS, error('Waveform length < RS length!'); end  % check length
        idxRS = (1:LenRS) + 0; % RS indices
        hSteeringVector = phased.SteeringVector('SensorArray', hArray,...
            'PropagationSpeed', physconst('LightSpeed'),...
            'IncludeElementResponse', DOAIncludeElementResponse,...
            'NumPhaseShifterBits', 0 ...    'EnablePolarization', false ...
            );
        elevationScanVector = ones(size(AzimuthScanAngles))*ElevationScanAngles;
        angleScanVector = [AzimuthScanAngles, elevationScanVector];
        steeringVector = step(hSteeringVector, FreqCenter, angleScanVector.');
        steeringVector = steeringVector*diag(rms(steeringVector).^-1);
        Rxx = waveformRx(idxRS,:).'*conj(waveformRx(idxRS,:))/LenRS;
        % eigen value decomposition
        [eigV, eigD] = eig(Rxx, 'vector');
        [~, idx] = sort(eigD, 'ascend');
        eigD = eigD(idx);
        eigV = eigV(:,idx);
        % find out the Number of signal.
        SigThd = 0.8*sum(eigD);        % assume the signals power should exceed certurn percentage of the total power.
        NumCh = length(eigD);
        pwrSum = 0;
        NumSig = NumCh-1;	% at least one column for noise space
        for idx = 1:NumCh-1 
            pwrSum = pwrSum + eigD(NumCh-idx+1);
            if pwrSum>SigThd
                NumSig = idx;
                break;
            end
        end
        % noise space construction
        Vnoise = eigV(:, 1:NumCh-NumSig );
        Rnn = Vnoise*Vnoise'; 
        Pmusic = 1./abs(sum((steeringVector'*Rnn.*steeringVector.').').');      
        
        if DoaEstiMaxNumSig ==1
            [~,idxDoa] = max(Pmusic);
        else
            processSpectrum = Pmusic.'/max(Pmusic);
            processSpectrum = pow2db(processSpectrum);
            processSpectrumExpand = [processSpectrum(2), processSpectrum, processSpectrum(end-1)]; % expand the spectrum so that findpeaks can return peaks at the boundary.
            % peak para.
            minPeakHeight = -15;
            minPeakProminence = .5;
            minPeakDistance = 1/(AzimuthScanAngles(2)-AzimuthScanAngles(1)); % degrees / reselution
            % find peaks
            [~, idxDoa] = findpeaks(processSpectrumExpand, 'NPeaks', min([DoaEstiMaxNumSig,NumSig]), 'MinPeakProminence', minPeakProminence, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDistance);
            idxDoa = idxDoa - 1;    % index of processSpectrum and processSpectrumExpand differs 1 point
            % if max is not in the peak list, add max
            [~,idxMax] = max(processSpectrum);
            if ~sum(idxDoa == idxMax)
                idxDoa = [idxMax, idxDoa];
            end
        end
        doaSelect = angleScanVector(idxDoa, :).';
        % make sure number of DOAs is the same as NumberTarget so that it can be compared in main.
        if NumTarget > size(doaSelect, 2)
            doa = [doaSelect,repmat([NaN;NaN], 1, NumTarget - size(doaSelect, 2))];
        else
            doa = doaSelect(:,1:NumTarget);
        end
        spacialSpectrum(:,:,1) = Pmusic;
        
        if FlagDebugPlot
            TargetAngle = sysPara.TargetAngle;
            figure(figureStartNum);
            hold off;
            plot(AzimuthScanAngles, mag2db(spacialSpectrum(1,:,1)), 'b-');
            hold on;
            for idxSig = 1:size(doaSelect, 2)
                plot([doaSelect(1,idxSig), doaSelect(1,idxSig)],...
                    [min(mag2db(spacialSpectrum(1,:,1))),...
                    mag2db(spacialSpectrum(1,(doaSelect(1,idxSig) - AzimuthScanAngles(1))/(AzimuthScanAngles(2) - AzimuthScanAngles(1)) + 1,1))], 'bo-');
            end
            for idxTarget = 1:NumTarget
                plot([TargetAngle(1,idxTarget), TargetAngle(1,idxTarget)],...
                    [min(mag2db(spacialSpectrum(1,:,1))),...
                    mag2db(spacialSpectrum(1,(TargetAngle(1,idxTarget) - AzimuthScanAngles(1))/(AzimuthScanAngles(2) - AzimuthScanAngles(1)) + 1,1))], 'b-');
                grid on;
                axis([min(AzimuthScanAngles), max(AzimuthScanAngles), min(mag2db(spacialSpectrum(1,:,1))), max(mag2db(spacialSpectrum(1,:,1)))]);
                title(['Target ', num2str(idxTarget), ': MUSIC Spatial Spectrum at Elevation 0 Degree']);
                xlabel('Azimuth Angle(degree)');
                ylabel('Power(dB)');
                legend('Spatial Spectrum', 'Target', 'DOA');
            end
        end
    case 'antiintermusic'
        spacialSpectrum = zeros(length(ElevationScanAngles), length(AzimuthScanAngles), NumTarget);
        LenRS = 512;  % RS length
        if LenWaveform < LenRS, error('Waveform length < RS length!'); end  % check length
        idxRS = (1:LenRS) + 0; % RS indices
        hSteeringVector = phased.SteeringVector('SensorArray', hArray,...
            'PropagationSpeed', physconst('LightSpeed'),...
            'IncludeElementResponse', DOAIncludeElementResponse,...
            'NumPhaseShifterBits', 0 ...    'EnablePolarization', false ...
            );
        elevationScanVector = ones(size(AzimuthScanAngles))*ElevationScanAngles;
        angleScanVector = [AzimuthScanAngles, elevationScanVector];
        steeringVector = step(hSteeringVector, FreqCenter, angleScanVector.');
        steeringVector = steeringVector*diag(rms(steeringVector).^-1);
        Pxs = waveformRx(idxRS,:).'*conj(waveformPilot(idxRS,:))/LenRS;   % cross-correlation vector
        doa = zeros(2, size(Pxs, 2));
        for idxTarget = 1:size(Pxs, 2)
            Rxx = Pxs(:, idxTarget)*Pxs(:, idxTarget)';
            [eigV, eigD] = eig(Rxx);
            eigD = diag(eigD);
            [~, idxMaxEig] = max(eigD);
            unitI = eye(size(Rxx, 1));
            unitI(idxMaxEig, idxMaxEig) = 0;
            noiseSpace = eigV*unitI*eigV';
            Pmusic = 1./abs(sum((steeringVector'*noiseSpace.*steeringVector.').').');
            [~, idxPeak] = max(Pmusic);
            doa(:, idxTarget) = angleScanVector(idxPeak, :).';
            spacialSpectrum(1,:,idxTarget) = Pmusic;
        end
        if FlagDebugPlot
            TargetAngle = sysPara.TargetAngle;
            for idxTarget = 1:NumTarget
                figure(figureStartNum + idxTarget);
                hold off;
                plot(AzimuthScanAngles, mag2db(spacialSpectrum(1,:,idxTarget)), 'b-');
                hold on;
                plot([TargetAngle(1,idxTarget), TargetAngle(1,idxTarget)],...
                    [min(mag2db(spacialSpectrum(1,:,idxTarget))),...
                    mag2db(spacialSpectrum(1,(TargetAngle(1,idxTarget) - AzimuthScanAngles(1))/(AzimuthScanAngles(2) - AzimuthScanAngles(1)) + 1,idxTarget))], 'b-');
                plot([doa(1,idxTarget), doa(1,idxTarget)],...
                    [min(mag2db(spacialSpectrum(1,:,idxTarget))),...
                    mag2db(spacialSpectrum(1,(doa(1,idxTarget) - AzimuthScanAngles(1))/(AzimuthScanAngles(2) - AzimuthScanAngles(1)) + 1,idxTarget))], 'bo-');
                grid on;
                axis([min(AzimuthScanAngles), max(AzimuthScanAngles), min(mag2db(spacialSpectrum(1,:,idxTarget))), max(mag2db(spacialSpectrum(1,:,idxTarget)))]);
                title(['Target ', num2str(idxTarget), ': Anti-Inter MUSIC Spatial Spectrum at Elevation 0 Degree']);
                xlabel('Azimuth Angle(degree)');
                ylabel('Power(dB)');
                legend('Spatial Spectrum', 'Target', 'DOA');
            end
        end
    otherwise
        error('Unsupported DOA estimator.');
end



