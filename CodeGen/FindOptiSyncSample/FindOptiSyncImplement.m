function [pilotSequence, numSyncChannel, circShiftSelect] = FindOptiSyncImplement(rxSigNoise, pilotSequenceUpSample, UpSampleTimes, LenSearch)
% Find Optimum Synchronization Sample Point.
% input: 
%    % rxSigNoise: NxM complex, N is the number of snapshots, M is the number of channel. each colum is one snapshot
%    % pilotSequenceUpSample: (UpSampleTimesxN)x1 complex, N is the length of pilot.
%    % UpSampleTimes: 1x1 integer, upsample factor.
%    % LenSearch: 1x1 odd integer, search range of finding optimum synchronization sample point under upsampled symbols.
% output:  
%    % pilotSequence, Nx1 complex, N is the length of pilot, pilot sequence downsampled according to optimum synchronization sample.
%    % numSyncChannel: 1x1 integer, number of synchronized channel after adjust optimum synchronization sample.
%    % circShiftSelect: 1x1 integer, pilot circle shift index.
%    
% 2018-01-25 V1.0 Wayne Zhang. draft.
% 2018-05-25 V1.1 Collus Wang. remove unnecessary multiplication operations for speed. 30ms->10ms.
% 2018-06-01 V1.2 Collus Wang. reduce corr length to further optimize speed. 4~5ms.

LenCorr = 64*2;
circShiftPattern = (1:LenSearch) - (LenSearch + 1)/2;

[LenPilot, NumChannel] = size(rxSigNoise);
syncIndexMat = zeros(NumChannel, LenSearch);
rxSigNoiseUpSample = upsample(rxSigNoise, UpSampleTimes);


pilotSequenceUpSampleMat = complex(zeros(LenPilot*UpSampleTimes, LenSearch));
for idxShift = 1:LenSearch
    pilotSequenceUpSampleMat(:,idxShift) = circshift(pilotSequenceUpSample, circShiftPattern(idxShift));
end

xcorrMat = rxSigNoiseUpSample(1:UpSampleTimes:LenCorr*UpSampleTimes,:)'*pilotSequenceUpSampleMat(1:UpSampleTimes:LenCorr*UpSampleTimes,:);
[~, idxSyncIndexVec] = max(abs(xcorrMat.'));

for idxChannel = 1:NumChannel
    syncIndexMat(idxChannel,idxSyncIndexVec(idxChannel)) = 1;
end

[numSyncChannel, idxShift] = max(sum(syncIndexMat));
circShiftSelect = circShiftPattern(idxShift);
pilotSequenceUpSampleShift = circshift(pilotSequenceUpSample, circShiftSelect);
pilotSequence = downsample(pilotSequenceUpSampleShift, UpSampleTimes);
end

