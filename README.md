# ReadMe #

This project simulates the multi-antenna system on Matlab.

Main feature includes:

1. RX beamforming. 
2. DOA estimation.

## System requirement ##
tested on Matlab version 2016a or later (2017a may have warnings but work.) with PhasedArray toolbox and Communication toolbox.

## File/Folder descriptions ##

1. mainArraySimRxBF.m is the main entry file.
2. Result folder include multi-antenna performance simulation result and the generated C-file for fixed weights.
3. Toolkits folder stores some useful tools that relies on the main algorithms.
4. CodeGen folder stores some specific functions that are further generated into C-code for hardware implementation. Each sub-folder contain one function and its corresponding testing and configuration files.


## Simulation result ##

### AnitInterference ###
This folder stores the performance of anti-interference using Rx weights. Figures are further described in the word doc. 

### Channel Error ###
1. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different amplitude error (0:1:10dB), random azimuth within a certain range (-30:3:30 degree) and fixed SNR (20dB).
2. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different phase error (0:0.5:5 degree), random azimuth within a certain range (-30:3:30 degree) and fixed SNR (20dB).

### Directivity ###
MMSE, LMS algorithm adaptive beamforming directivity at target azimuth traversing within a certain range (-30:3:30 degree).

### DOAEstimation ###
1. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different SNR (-10:5:20dB) and random azimuth within a certain range (-30:3:30 degree).
2. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different SIR (-10:3:20dB), fixed signal azimuth (0 degree), fixed interference azimuth (11 degree) and fixed SNR (5dB).
3. CBF, MUSIC, Anti-MUSIC algorithm performance (unbiasedness, robustness) under different azimuth (-30:3:30 degree) and fixed SNR (5dB).

### LMSIteration ###
Figures in this folder show the weight convergency of LMS. 


### TypicalRxPatten ###
Figures in this folder show the typical rx weight pattern with/without consideration of element antenna response.


### WeightGenerationForC ###
The generated C-files for fixed weights are stored here.
