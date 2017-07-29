# ReadMe #

This project simulates the multi-antenna system on Matlab.

Main feature includes:
1. RX beamforming.
2. DOA estimation.

## System requirement ##
tested on Matlab version 2016a or later (2017a may have warnings but work.) with PhasedArray toolbox and Communiation toolbox.

## File descriptions ##

1. mainArraySimRxBF.m is the main entry file.
2. Result folder include multi-antenna performance simulation result.

## Simulation result ##

### DOA estimation ###
1. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different SNR (-10~20dB) and random azimuth within a certain range (-30~30 degree).
2. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different azimuth (-30~30 degree) and fixed SNR (5dB).

### Directivity ###
MMSE, LMS algorithm adaptive beamform directivity at target azimuth traversing within a certain range (-30~30 degree).

### Anti-Interference ###
MMSE, LMS algorithm adaptive anti-interference (6dB similarity between signal and interference) performance under different SIR (-10~20dB).