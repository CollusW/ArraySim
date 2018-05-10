function [pilotSequence, numSyncChannel, circShiftSelect] = FindOptiSyncFixedPointImplement(rxSigNoise, pilotSequenceUpSample)
% Find Optimum Synchronization Sample Point.
% input: 
%    % rxSigNoise: NxM complex, N is the number of snapshots, M is the number of channel. each colum is one snapshot
%    % pilotSequenceUpSample: (UpSampleTimesxN)x1 complex, N is the length of pilot.
%    % UpSampleTimes: 1x1 integer, upsample factor.Fixed 3 for fixed point.
%    % LenSearch: 1x1 odd integer, search range of finding optimum synchronization sample point under upsampled symbols.Fixed 7 for fixed point.
% output:  
%    % pilotSequence, Nx1 complex, N is the length of pilot, pilot sequence downsampled according to optimum synchronization sample.
%    % numSyncChannel: 1x1 integer, number of synchronized channel after adjust optimum synchronization sample.
%    % circShiftSelect: 1x1 integer, pilot circle shift index.
%    
% 2018-01-25 V1.0 Wayne Zhang. draft.

circShiftPattern = -3:3;

[LenPilot, NumChannel] = size(rxSigNoise);
syncIndexMat = zeros(NumChannel, 7);
pilotSequenceUpSampleShift = zeros(LenPilot*3, 1);
rxSigNoiseUpSample = upsample(rxSigNoise, 3);

pilotSequenceUpSampleMat = complex(zeros(LenPilot*3, 7));
for idxShift = 1:7
    circShiftCurr = circShiftPattern(idxShift);
    if circShiftCurr == 0
        pilotSequenceUpSampleMat(:,idxShift) = pilotSequenceUpSample;
    elseif circShiftCurr > 0
        pilotSequenceUpSampleMat(:,idxShift) = [pilotSequenceUpSample(end - circShiftCurr + 1:end);pilotSequenceUpSample(1:end - circShiftCurr)];
    elseif circShiftCurr < 0
        pilotSequenceUpSampleMat(:,idxShift) = [pilotSequenceUpSample(-circShiftCurr + 1:end);pilotSequenceUpSample(1:-circShiftCurr)];
    end
end

xcorrMat = rxSigNoiseUpSample'*pilotSequenceUpSampleMat;
[~, idxSyncIndexVec] = max(abs(xcorrMat.'));

for idxChannel = 1:NumChannel
    syncIndexMat(idxChannel,idxSyncIndexVec(idxChannel)) = 1;
end

[numSyncChannel, idxShift] = max(sum(syncIndexMat));
circShiftSelect = circShiftPattern(idxShift);
if circShiftSelect == 0
    pilotSequenceUpSampleShift = pilotSequenceUpSample;
elseif circShiftSelect > 0
    pilotSequenceUpSampleShift = [pilotSequenceUpSample(end - circShiftSelect + 1:end);pilotSequenceUpSample(1:end - circShiftSelect)];
elseif circShiftSelect < 0
    pilotSequenceUpSampleShift = [pilotSequenceUpSample(-circShiftSelect + 1:end);pilotSequenceUpSample(1:-circShiftSelect)];
end
% for fixed point
pilotSequence = complex(zeros(LenPilot, 1));
for idxDownSample = 1:LenPilot
    pilotSequence(idxDownSample) = pilotSequenceUpSampleShift(idxDownSample*3 - 2);
end


end

