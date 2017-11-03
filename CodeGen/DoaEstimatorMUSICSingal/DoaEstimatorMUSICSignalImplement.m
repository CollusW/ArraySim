function [spatialSpectrum, doas]  = DoaEstimatorMUSICSignalImplement(recStvPartition, rxSigNoise, PilotSequence, AzimuthScanAngles, MaxNumSig, FilterFlag) %#codegen
% DOA estimation using MUSIC method. but filter only the signal.
% input: 
%    % recStvPartition, MxK complex, matrix of steering vectors, each column is one steering vector for a specific Azimuth angle. M is the number of channel. K is the number of azimuth scan angle.
%    % rxSigNoise: NxM complex, N is the number of snapshots, M is the number of channel. each colum is one snapshot
%    % PilotSequence: Nx1 complex, N is the length of pilot.
%    % AzimuthScanAngles: 1xK double, azimuth scan angle in degree, should be in assending order.
%    % MaxNumSig: 1x1 double, the number of maximum signals in DOA search.
%    % FilterFlag: 1x1 double, the switch of PN filter function.
% output:  
%    % spatialSpectrum, 1xK double, it is a matrix representing the magnitude of the estimated spatial spectrum. 
%    % doas, 1xP double, the signal's direction of arrival (DOA) .
% 2017-10-18 V1.0 Collus Wang and Wayne Zhang. inherited from old repo.
% 2017-10-20 V1.1 Collus Wang. eigD convert to double.
% 2017-11-03 V1.2 Wayne Zhang. add input parameter FilterFlag.

if FilterFlag == 1
    Pxs = rxSigNoise.'*conj(PilotSequence);% PN code filtering in time.
    Rxx = Pxs*Pxs';
else
    Rxx = rxSigNoise.'*conj(rxSigNoise);
end

[eigV, eigD] = eig(Rxx, 'vector');
eigD = abs(eigD);
[~,idx] = sort(eigD, 'ascend');
eigD = eigD(idx);
eigV = eigV(:,idx);

% find out the Number of signal.
SigThd = 0.8*sum(eigD);        % assume the signals power should exceed certurn percentage of the total power.
NumCh = length(eigD);
pwrSum = 0;
NumSig = NumCh-1; % at least one column for noise space
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

spatialSpectrum = abs(1./sum((recStvPartition'*Rnn).'.*recStvPartition));

if MaxNumSig ==1
    [~,idxDoa] = max(spatialSpectrum);
else
    processSpectrum = spatialSpectrum/max(spatialSpectrum);
    processSpectrum = pow2db(processSpectrum);
    processSpectrumExpand = [processSpectrum(2), processSpectrum, processSpectrum(end-1) ]; % expand the spectrum so that findpeaks can return peaks at the boundary.
    % peak para.
    minPeakHeight = -15;
    minPeakProminence = .5;
    minPeakDistance = 1/(AzimuthScanAngles(2)-AzimuthScanAngles(1)); % degrees / reselution
    % find peaks
    [~, idxDoa] = findpeaks(processSpectrumExpand, 'NPeaks', min([MaxNumSig,NumSig]), 'MinPeakProminence', minPeakProminence, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDistance);
    idxDoa = idxDoa - 1;    % index of processSpectrum and processSpectrumExpand differs 1 point
    % if max is not in the peak list, add max
    [~,idxMax] = max(processSpectrum);
    if ~sum(idxDoa == idxMax)
        idxDoa = [idxMax, idxDoa];
    end
end
doas = AzimuthScanAngles(idxDoa);
