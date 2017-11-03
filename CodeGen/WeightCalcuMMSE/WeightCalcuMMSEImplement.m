function [weight]  = WeightCalcuMMSEImplement(rxSigNoise, PilotSequence, SNRThreshold) %#codegen
% Weight calculation using MMSE critetion.
% input: 
%    % rxSigNoise: NxM complex, N is the number of snapshots, M is the number of channel. each colum is one snapshot
%    % PilotSequence: Nx1 complex, N is the length of pilot.
%    % SNRThreshold: 1x1 double, in dB, SNR threshold for diagnal loading to lower high SNR.
% output:  
%    % weight, Mx1 complex, Adaptive receive weight .
% 2017-10-18 V1.0 Collus Wang and Wayne Zhang. inherited from old repo.

% Cross correlation vector
Pxs = rxSigNoise.'*conj(PilotSequence);
% Auto correlation matrix
Rxx = rxSigNoise.'*conj(rxSigNoise);
% Diagnal load noise power to lower high SNR to specific threshold.
Rxx = Rxx + sum(diag(Rxx))/length(Pxs)/SNRThreshold*eye(size(Rxx));
% MMSE criterion
weight = Rxx\Pxs;
% Amplitude normalization
weight = weight/max(abs(weight));

