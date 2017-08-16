function [waveformArrayChannel] = ChannelImplementation(sysPara, waveformArray)
% /*!
%  *  @brief     This function implement channel amplitude error and phase error.
%  *  @details   . 
%  *  @param[out] waveformArrayChannel, NxM complex doulbe. multi-channel waveform include amplitude error and phase error, N is the number of samples(snaps). M is the number of channel
%  *  @param[in] sysPara, 1x1 struct, which contains the following field:
%       see get used field for detail.
%  *  @param[in] waveformArray, NxM complex doulbe. array response, i.e. signal waveform response at each antenna. N is the number of samples(snaps). M is the number of channel
%  *  @pre       .
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Wayne Zhang
%  *  @version   1.0
%  *  @date      2017.08.03.
%  *  @copyright Wayne Zhang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.03. Wayne Zhang,  first draft }
%  */
%% get used field
SwitchChannelImplementation = sysPara.SwitchChannelImplementation;     % boolen scaler. true = enable channel implementation; false = disable channel implementation.
ChannelAmpliErr = sysPara.ChannelAmpliErr;       % double Mx1 vector. channel amplitude vector. unit in dB. M is number of channel.
ChannelPhaseErr = sysPara.ChannelPhaseErr;      % double Mx1 vector. channel phase vector. unit in degree . M is number of channel.
%% process
if ~SwitchChannelImplementation
    waveformArrayChannel = waveformArray;
    return;
end
%% process
waveformArrayChannel = waveformArray*diag(10.^(ChannelAmpliErr/20))...
    *diag(exp(1i*ChannelPhaseErr/180*pi));
end