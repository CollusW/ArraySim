function [snr, ber, evm] = AnalyzeWaveform(sysPara, waveformRx, waveformRef, figureStartNum)
% /*!
%  *  @brief     This function analyze the waveform. calcualte SNR, BER, and, EVM of the received waveform.
%  *  @details   use waveformRef as reference signal without noise or channel, the waveform should be single sampling rate.
%  *  @param[out] snr, 1x1 doulbe. signal noise ratio in dB.
%  *  @param[out] ber, 1x1 doulbe. signal error bit ratio (range:0~1).
%  *  @param[out] evm, 1x1 doulbe. signal error vector magnitude in percentage (range:0~100).
%  *  @param[in] sysPara, 1x1 struct, which contains the following field:
%       see get used field for detail.
%  *  @param[in] waveformRx, Nx1 complex vector. received waveform. N is the number of samples(snaps).
%  *  @param[in] waveformRef, Nx1 complex vector. reference waveform. N is the number of samples(snaps).
%  *  @param[in] figureStartNum, 1x1 interger scaler. start index of drawing figure.
%  *  @pre       .
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.05.25.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.05.25. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2017.06.22. Collus Wang,  support 16QAM and 64QAM }
%  * @remark   { revision history: V1.2, 2017.11.03. Wayne Zhang,  support custom pilot case. Not accurate BER and EVM results. Need to fix code. Just able to able proceed the test case }
%  */

%% get used field
TargetSigType = sysPara.TargetSigType;

%% Flags
GlobalDebugPlot = sysPara.GlobalDebugPlot;
FlagDebugPlot = true && GlobalDebugPlot;

%% check input
if size(waveformRx)~=size(waveformRef)
    error('waveformRx and waveformRef size does not match.')
end

snr = zeros(size(waveformRx,2),1);
ber = zeros(size(waveformRx,2),1);
evm = zeros(size(waveformRx,2),1);
for idxTarget = 1: size(waveformRx,2)
    %% pre-process
    % normalize signal
    if FlagDebugPlot
        figure(figureStartNum+0+idxTarget*100);clf; subplot(211);plot(waveformRx, '.-b'); hold on; plot(waveformRef, 'o-r'); axis equal; title('AnalzeWaveform'); ylabel('original');
    end
    waveformRx(:,idxTarget) = waveformRx(:,idxTarget)/rms(waveformRx(:,idxTarget));
    waveformRef(:,idxTarget) = waveformRef(:,idxTarget)/rms(waveformRef(:,idxTarget));
    if FlagDebugPlot
        figure(figureStartNum+0+idxTarget*100); subplot(212);plot(waveformRx, '.-b'); hold on; plot(waveformRef, 'o-r'); axis equal; ylabel('normalized');
    end
    %% process
    % SNR cal.
    snr(idxTarget) = mag2db(rms(waveformRef(:,idxTarget))/rms(waveformRx(:,idxTarget)-waveformRef(:,idxTarget)));
    % BER cal.
    switch lower(TargetSigType)
        case 'qpsk'
            waveformNorm = waveformRef(:,idxTarget);
            GenSymbolMap;
            idxSymDemod = zeros(length(waveformNorm),1);
            for idx = 1:length(waveformNorm)
                dis = CalDistance(waveformNorm(idx), SymbolMapQPSK);
                [~, idxMin] = min(dis);
                idxSymDemod(idx) = idxMin-1;
            end
            bits = zeros(length(waveformNorm),2);
            bits(:,1) = floor(idxSymDemod/2);
            bits(:,2) = mod(idxSymDemod,2);
            decodeBits = reshape(bits.', [], 1);
            txBits = decodeBits;
            
            waveformNorm = waveformRx(:,idxTarget);
            GenSymbolMap;
            idxSymDemod = zeros(length(waveformNorm),1);
            for idx = 1:length(waveformNorm)
                dis = CalDistance(waveformNorm(idx), SymbolMapQPSK);
                [~, idxMin] = min(dis);
                idxSymDemod(idx) = idxMin-1;
            end
            bits = zeros(length(waveformNorm),2);
            bits(:,1) = floor(idxSymDemod/2);
            bits(:,2) = mod(idxSymDemod,2);
            decodeBits = reshape(bits.', [], 1);
            rxBits = decodeBits;
        case '16qam'
            waveformNorm = waveformRef(:,idxTarget);
            GenSymbolMap;
            idxSymDemod = zeros(length(waveformNorm),1);
            for idx = 1:length(waveformNorm)
                dis = CalDistance(waveformNorm(idx), SymbolMap16QAM);
                [~, idxMin] = min(dis);
                idxSymDemod(idx) = idxMin-1;
            end
            bits = zeros(length(waveformNorm),4);
            temp = idxSymDemod;
            bits(:,1) = floor(temp/8);
            temp = mod(temp, 8);
            bits(:,2) = floor(temp/4);
            temp = mod(temp, 4);
            bits(:,3) = floor(temp/2);
            temp = mod(temp, 2);
            bits(:,4) = temp;
            decodeBits = reshape(bits.', [], 1);
            txBits = decodeBits;
            
            waveformNorm = waveformRx(:,idxTarget);
            GenSymbolMap;
            idxSymDemod = zeros(length(waveformNorm),1);
            for idx = 1:length(waveformNorm)
                dis = CalDistance(waveformNorm(idx), SymbolMap16QAM);
                [~, idxMin] = min(dis);
                idxSymDemod(idx) = idxMin-1;
            end
            bits = zeros(length(waveformNorm),4);
            temp = idxSymDemod;
            bits(:,1) = floor(temp/8);
            temp = mod(temp, 8);
            bits(:,2) = floor(temp/4);
            temp = mod(temp, 4);
            bits(:,3) = floor(temp/2);
            temp = mod(temp, 2);
            bits(:,4) = temp;
            decodeBits = reshape(bits.', [], 1);
            rxBits = decodeBits;
        case '64qam'
            waveformNorm = waveformRef(:,idxTarget);
            GenSymbolMap;
            idxSymDemod = zeros(length(waveformNorm),1);
            for idx = 1:length(waveformNorm)
                dis = CalDistance(waveformNorm(idx), SymbolMap64QAM);
                [~, idxMin] = min(dis);
                idxSymDemod(idx) = idxMin-1;
            end
            bits = zeros(length(waveformNorm),6);
            temp = idxSymDemod;
            bits(:,1) = floor(temp/32);
            temp = mod(temp, 32);
            bits(:,2) = floor(temp/16);
            temp = mod(temp, 16);
            bits(:,3) = floor(temp/8);
            temp = mod(temp, 8);
            bits(:,4) = floor(temp/4);
            temp = mod(temp, 4);
            bits(:,5) = floor(temp/2);
            temp = mod(temp, 2);
            bits(:,6) = temp;
            decodeBits = reshape(bits.', [], 1);
            txBits = decodeBits;
            
            waveformNorm = waveformRx(:,idxTarget);
            GenSymbolMap;
            idxSymDemod = zeros(length(waveformNorm),1);
            for idx = 1:length(waveformNorm)
                dis = CalDistance(waveformNorm(idx), SymbolMap64QAM);
                [~, idxMin] = min(dis);
                idxSymDemod(idx) = idxMin-1;
            end
            bits = zeros(length(waveformNorm),6);
            temp = idxSymDemod;
            bits(:,1) = floor(temp/32);
            temp = mod(temp, 32);
            bits(:,2) = floor(temp/16);
            temp = mod(temp, 16);
            bits(:,3) = floor(temp/8);
            temp = mod(temp, 8);
            bits(:,4) = floor(temp/4);
            temp = mod(temp, 4);
            bits(:,5) = floor(temp/2);
            temp = mod(temp, 2);
            bits(:,6) = temp;
            decodeBits = reshape(bits.', [], 1);
            rxBits = decodeBits;
        case 'custompilot'	% need fix
            warning('Over sampled custom pilot decode according to QPSK temporarily. BER is not accurate because of constellation point near origin');
            waveformNorm = waveformRef(:,idxTarget);
            GenSymbolMap;
            idxSymDemod = zeros(length(waveformNorm),1);
            for idx = 1:length(waveformNorm)
                dis = CalDistance(waveformNorm(idx), SymbolMapQPSK);
                [~, idxMin] = min(dis);
                idxSymDemod(idx) = idxMin-1;
            end
            bits = zeros(length(waveformNorm),2);
            bits(:,1) = floor(idxSymDemod/2);
            bits(:,2) = mod(idxSymDemod,2);
            decodeBits = reshape(bits.', [], 1);
            txBits = decodeBits;
            
            waveformNorm = waveformRx(:,idxTarget);
            GenSymbolMap;
            idxSymDemod = zeros(length(waveformNorm),1);
            for idx = 1:length(waveformNorm)
                dis = CalDistance(waveformNorm(idx), SymbolMapQPSK);
                [~, idxMin] = min(dis);
                idxSymDemod(idx) = idxMin-1;
            end
            bits = zeros(length(waveformNorm),2);
            bits(:,1) = floor(idxSymDemod/2);
            bits(:,2) = mod(idxSymDemod,2);
            decodeBits = reshape(bits.', [], 1);
            rxBits = decodeBits;
        otherwise
            error('Unsupported signal type.')
    end
    ber(idxTarget) = sum(abs(rxBits-txBits))/length(rxBits);
    
    % EVM cal.
    % Create an EVM object, output maximum and 90-percentile EVM
    % measurements, and symbol count
    hEVM = comm.EVM('MaximumEVMOutputPort',true,...
        'XPercentileEVMOutputPort', true, 'XPercentileValue', 90,...
        'SymbolCountOutputPort', true);
    [RMSEVM,MaxEVM,PercentileEVM,NumSym] = step(hEVM,waveformRef(:,idxTarget),waveformRx(:,idxTarget));   % Calculate measurements
    evm(idxTarget) = RMSEVM;
    
    if FlagDebugPlot
        str = sprintf('SNR = %.2f dB; EVM = %.2f%%; BER = %.2f', snr, evm, ber);
        figure(figureStartNum+0+idxTarget*100); subplot(212); title(str)
    end
end

end

function dis = CalDistance(rxPoint, RefPoints)
dis = abs(rxPoint*ones(length(RefPoints),1)-RefPoints);
end