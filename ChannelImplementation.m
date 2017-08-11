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
NumChannel = sysPara.NumChannel;                                       % interger scaler. number of used channels
SwitchChannelImplementation = sysPara.SwitchChannelImplementation;     % boolen scaler. true = enable channel implementation; false = disable channel implementation.
MeanAmpl = sysPara.MeanAmpl;                                           % double scaler. mean value of channel amplitude. unit in dB.
MaxAmplSBRange = sysPara.MaxAmplSBRange;                               % double scaler. single band range of channel amplitude. unit in dB.
MeanPhaseErr = sysPara.MeanPhaseErr;                                   % double scaler. mean value of channel phase error. unit in degree.
MaxPhaseErrSBRange = sysPara.MaxPhaseErrSBRange;                       % double scaler. single band range of channel phase error. unit in degree.
%% process
if ~SwitchChannelImplementation
    waveformArrayChannel = waveformArray;
    return;
end
%% process
waveformArrayChannel = waveformArray*diag(10.^(((rand(NumChannel, 1)*2 - 1)*MaxAmplSBRange + MeanAmpl)/20))...
    *diag(exp(1i*(rand(NumChannel, 1)*2 - 1)*(MaxPhaseErrSBRange/180*pi) + (MeanPhaseErr/180*pi)));
end