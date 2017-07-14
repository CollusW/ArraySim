function [ waveformBf] = RxBeamforming(sysPara, waveformRx, weight)
% /*!
%  *  @brief     This function combines the received waveform according to the given weight.
%  *  @details   . 
%  *  @param[out] waveformBf, Nx1 complex vector. combined received waveform. N is the number of samples(snaps).     
%  *  @param[in] sysPara, 1x1 struct, which contains the following field:
%       see get used field for detail.
%  *  @param[in] waveformRx, NxM complex vector. received waveform. N is the number of samples(snaps), M is the number of channel
%  *  @param[in] weight, Mx1 complex doulbe. array channel weight. M is the number of channel
%  *  @pre       .
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.05.25.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.05.25. Collus Wang,  first draft }
%  */

%% get used field

% check input
if size(weight, 1)~=size(waveformRx, 2)
    weight = weight.';
    if size(weight, 1)~=size(waveformRx, 2)
        error('weight size does not match waveform size.')
    end
end

waveformBf = waveformRx*conj(weight);