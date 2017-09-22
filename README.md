# ReadMe #

This project simulates the multi-antenna system on Matlab.

Main feature includes:
1. RX beamforming.
2. DOA estimation.

## System requirement ##
tested on Matlab version 2016a or later (2017a may have warnings but work.) with PhasedArray toolbox and Communiation toolbox.

## File descriptions ##

1. mainArraySimRxBF.m is the main entry file.
2. Result folder include multi-antenna performance simulation result and the generated C-file for fixed weights.
3. Toolkits folder stores some useful tools that relies on the main algorithms.

## Simulation result ##

### DOA estimation ###
1. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different SNR (-10:5:20dB) and random azimuth within a certain range (-30:3:30 degree).
2. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different SIR (-10:3:20dB), fixed signal azimuth (0 degree), fixed interference azimuth (11 degree) and fixed SNR (5dB).
3. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different azimuth (-30:3:30 degree) and fixed SNR (5dB).

### Adaptive Beamforming ###
MMSE, LMS algorithm adaptive beamforming MSE under different SNR (-10:3:20dB), fixed RS length (256), fixed signal azimuth (0 degree), fixed interference azimuth (11 degree) and fixed SIR (-3dB).
MMSE, LMS algorithm adaptive beamforming MSE under different SIR (-10:3:20dB), fixed RS length (256), fixed signal azimuth (0 degree), fixed interference azimuth (11 degree) and fixed SNR (20dB).

### Directivity ###
MMSE, LMS algorithm adaptive beamforming directivity at target azimuth traversing within a certain range (-30:3:30 degree).

### Anti-Interference ###
MMSE, LMS algorithm adaptive anti-interference (6dB similarity between signal and interference) performance under different SIR (-10:5:20dB).

### Channel Error ###
1. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different amplitude error (0:1:10dB), random azimuth within a certain range (-30:3:30 degree) and fixed SNR (20dB).
2. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different phase error (0:0.5:5 degree), random azimuth within a certain range (-30:3:30 degree) and fixed SNR (20dB).

### WeightGenerationForC ###
The generated C-files for fixed weights are stored here.
