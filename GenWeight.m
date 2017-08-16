function [ weight, errVector] = GenWeight(sysPara, hArray, waveformRx, waveformPilot)
% /*!
%  *  @brief     This function generate the rx weight according to the beamforming method.
%  *  @details   . 
%  *  @param[out] weight, MxK complex doulbe. array channel weight. M is the number of channel, K is the
%                   number of targets.
%  *  @param[out] errVector, Lx1 complex doulbe. error vector between local RS and combined RS. M is the length of RS
%       for LMS algorithm, each error vector element is corresponding to current iterated weight.
%       for other algorithm, each error vector element is corresponding to final weight.
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
%  *  @date      2017.05.25.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.05.25. Collus Wang, first draft }
%  * @remark   { revision history: V1.1, 2017.07.12. Wayne Zhang, add lms method }
%  * @remark   { revision history: V1.1, 2017.07.12. Collus Wang, 1.steering vector calculation can include element response. StvIncludeElementResponse; 2. add DiagonalLoadingFactor for mvdr}
%  * @remark   { revision history: V1.2, 2017.07.14. Wayne Zhang, lms method add break }
%  * @remark   { revision history: V1.2, 2017.07.28. Wayne Zhang, modify lms variable step lenght strategy }
%  */

%% Get used field
BeamformerType = sysPara.BeamformerType;
TargetAngle = sysPara.TargetAngle;
FreqCenter = sysPara.FreqCenter;
LenWaveform = sysPara.LenWaveform;
NumWeightsQuantizationBits = sysPara.NumWeightsQuantizationBits;
WeightsNormalization = sysPara.WeightsNormalization;
NumTarget = sysPara.NumTarget;
NumChannel = sysPara.NumChannel;
StvIncludeElementResponse = sysPara.StvIncludeElementResponse;

%% Flags
GlobalDebugPlot = sysPara.GlobalDebugPlot;
FlagDebugPlot = true && GlobalDebugPlot;
figureStartNum = 5000;

%% process
LenRS = 256;  % RS length
idxRS = (1:LenRS) + 0; % RS indices
switch lower(BeamformerType)
    case 'mvdr'
        DiagonalLoadingFactor = sysPara.MvdrPara.DiagonalLoadingFactor;
        hBeamformer = phased.MVDRBeamformer('SensorArray',hArray,...
            'Direction',TargetAngle,...
            'OperatingFrequency',FreqCenter,...
            'DiagonalLoadingFactor', DiagonalLoadingFactor,...
            'WeightsOutputPort',true);
        [~, weight] = step(hBeamformer,waveformRx);
        errVector = abs(waveformPilot(idxRS,:).' - weight'*waveformRx(idxRS,:).').';
    case 'mrc'
        hBeamformer = phased.PhaseShiftBeamformer('SensorArray',hArray,...
            'Direction',TargetAngle,...
            'OperatingFrequency',FreqCenter,...
            'WeightsOutputPort', true);
        [~, weight] = step(hBeamformer,waveformRx);
        errVector = abs(waveformPilot(idxRS,:).' - weight'*waveformRx(idxRS,:).').';
    case 'lcmv'
        % get used field.
        AngleToleranceAZ = sysPara.LcmvPara.AngleToleranceAZ;
        hBeamformer = phased.LCMVBeamformer('WeightsOutputPort',true);
        hSteeringVector = phased.SteeringVector('SensorArray',hArray, ...
            'IncludeElementResponse', StvIncludeElementResponse);
        FlagSuppressInterference = false;
        weight = zeros(NumChannel, NumTarget);
        for idxTarget = 1:NumTarget
            if AngleToleranceAZ == 0
                ConstraintAngle = TargetAngle(:,idxTarget);
                DesiredResponse = 1;
            else
                ConstraintAngle = [TargetAngle(:,idxTarget), TargetAngle(:,idxTarget)+[AngleToleranceAZ;0], TargetAngle(:,idxTarget)-[AngleToleranceAZ;0]];
                DesiredResponse = db2mag([0;0;0]); % desired response corresponds to AZ [Target-Tolerance; Target; Target+Tolerance] in magnitude.
%                 ConstraintAngle = [TargetAngle(:,idxTarget)+[AngleToleranceAZ/2;0], TargetAngle(:,idxTarget)-[AngleToleranceAZ/2;0]];
%                 DesiredResponse = db2mag([0;0]); % desired response corresponds to AZ [Target-Tolerance; Target; Target+Tolerance] in magnitude.
            end            
            if FlagSuppressInterference
                InterferenceAngle = sysPara.InterferenceAngle;
                ConstraintAngle = [ConstraintAngle, InterferenceAngle];
                DesiredResponse = [DesiredResponse; zeros(size(InterferenceAngle,2), 1)];
            end
            if isLocked(hBeamformer)
                release(hBeamformer); 
            end
            hBeamformer.Constraint = step(hSteeringVector, FreqCenter, ConstraintAngle);
            hBeamformer.DesiredResponse = DesiredResponse;
            [~, weight(:,idxTarget)] = step(hBeamformer,waveformRx);
        end
        errVector = abs(waveformPilot(idxRS,:).' - weight'*waveformRx(idxRS,:).').';
    case 'mmse'
        if LenWaveform < LenRS, error('Waveform length < RS length!'); end  % check length
        Rxx = waveformRx(idxRS,:).'*conj(waveformRx(idxRS,:))/LenRS;    % auto-correlation matix
        Pxs = waveformRx(idxRS,:).'*conj(waveformPilot(idxRS,:))/LenRS;   % cross-correlation vector
        if FlagDebugPlot
            fprintf('Condition number of Rxx = %f\n', cond(Rxx));
            fprintf('Eigen value decomposition of Rxx:\n');
            [V,D] = eig(Rxx)   %#ok<ASGLU,NOPRT>
        end
        weight = Rxx\Pxs;
        errVector = abs(waveformPilot(idxRS,:).' - weight'*waveformRx(idxRS,:).').';
    case 'lms'
        LenJudgConv = 10;   % minimun number of iterations
        FlagConvSwitch = 0; % true = turn on convergency break for faster calculation. false = turn off convergency break
        ThresholdConv = 0.03;  % threshold of convergence.
        ThresholdConv = ThresholdConv*ones(NumTarget, 1);
        flagConv = zeros(NumTarget, 1);
        if LenWaveform < LenRS, error('Waveform length < RS length!'); end  % check length
        Pxs = waveformRx(idxRS,:).'*conj(waveformPilot(idxRS,:))/LenRS;   % cross-correlation vector
        Rxx = waveformRx(idxRS,:).'*conj(waveformRx(idxRS,:))/LenRS;    % auto-correlation matix
        betaStepLen = 1/trace(Rxx);
        AlphaStepLen = 50;
        ConvSecendValStepLen = betaStepLen*1e-2*ones(NumTarget, 1);
        GammaStepLen = 1/10;
        NumFirstVarStepLen = 100;
        weight = Pxs;   % init. with Pxs.
        errVector = zeros(LenRS, NumTarget);
        for idxIter = 1:LenRS
            errIter = waveformPilot(idxIter,:).' - weight'*waveformRx(idxIter,:).';
            errVector(idxIter, :) = abs(errIter).';
            if idxIter > LenJudgConv
                sigmaErrIter = rms(errVector(idxIter - LenJudgConv + 1:idxIter, :)).';
                flagConv = sigmaErrIter.*~flagConv < ThresholdConv;
                flagConv = flagConv*FlagConvSwitch;
            end
            if idxIter <= NumFirstVarStepLen
                stepLen = betaStepLen*(1 - exp(-AlphaStepLen*abs(errIter).^2)).*~flagConv;      %stepLen = betaStep*(1./(1 + exp(-alphaStep*abs(errRS).^2)) - 0.5);
                if idxIter == NumFirstVarStepLen
                    OrigSecondValStepLen = stepLen;
                end
            else
                stepLen = ((OrigSecondValStepLen - ConvSecendValStepLen)*exp(-GammaStepLen*(idxIter - NumFirstVarStepLen)) + ConvSecendValStepLen).*~flagConv;
            end
            weight = weight + waveformRx(idxIter,:).'*errIter'*diag(stepLen);
            if sum(flagConv) == NumTarget
                break;
            end
        end
        if FlagDebugPlot
            fprintf('LMS iteration times = %d\n', idxIter);
            figure(figureStartNum)
            plot(errVector, '.-');
            grid on
            xlabel('Iteration')
            ylabel('Error')
            title('LMS error convergency')
        end
end
% by here weight should be a column vetor or matrix whose columns are one set of weight.

% to do: weight normalization.
%  string. valid value = {'Distortionless', 'Preserve power'}. Approach for normalizing beamformer weights. 
%  If you set this property value to 'Distortionless', the gain in the beamforming direction is 0 dB.
%  If you set this property value to 'Preserve power', the norm of the weights is unity.
switch lower(WeightsNormalization)
    case 'distortionless'
        normWeight = zeros(size(weight, 2), 1); % cal the norm of each weight
        for idxTmp = 1:size(weight, 2)
            normWeight(idxTmp) = norm(weight(:,idxTmp), 1); % 1-norm
        end
        weight = weight*diag(1./normWeight);
    case 'preserve power'
        normWeight = zeros(size(weight, 2), 1); % cal the norm of each weight
        for idxTmp = 1:size(weight, 2)
            normWeight(idxTmp) = norm(weight(:,idxTmp), 2); % 2-norm
        end
        weight = weight*diag(1./normWeight);
    case 'minquantizationerror'
        weight = weight/max(abs(weight));
    case 'bypass'
        weight = weight;
    otherwise
        error('Unsupported weight normalization.')
end

% Make sure maximum weight coefficient module value not exceeding 1.
if max(max(abs(weight))) > 1
    warning('Weight coefficient module value exceeded 1.');
    pause(2)
end

% Weight quantization
if NumWeightsQuantizationBits>0
    fullScaleQuantization = 2^(NumWeightsQuantizationBits - 1) - 1;
    weight = round(weight*fullScaleQuantization)/fullScaleQuantization;
end

% Plot beam pattern
if FlagDebugPlot
    ELofAZCut = 0;
    AZofELCut = 0;
    for idx = 1:size(TargetAngle,2)
        ViewArrayPattern(hArray, FreqCenter , ELofAZCut, AZofELCut, weight(:,idx), figureStartNum+idx*100+100);
    end
end

