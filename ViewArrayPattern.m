function [ PATAZ, PATEL ] = ViewArrayPattern( hArray, FreqCenter , ELofAZCut, AZofELCut, weight, figureStartNum )
% view Array Pattern
% input: hArray, handle of Antenna Array
% FreqCenter: 1x1 doulbe, center frequency
% ELofAZCut: 1x1 double, elevation angle of the azimuth cut view
% AZofELCut: 1x1 double, azimuth angle of the elevation cut view
% weight: Nx1 colum vector, complex, weight of the array, N should be equal
%           to the number of antenna elements in the array
% output: PATAZ, 1x1 struct of AZ pattern, which includes the following fields:
%			 PAT, the array pattern in PAT. 
%			 AZ_ANG, contains the coordinate values corresponding to the rows of PAT. 
%			 EL_ANG, contains the coordinate values corresponding to the columns of PAT.
% 		  PATEL, 1x1 struct of EL pattern, which includes the following fields:
%			 PAT, the array pattern in PAT. 
%			 AZ_ANG, contains the coordinate values corresponding to the rows of PAT. 
%			 EL_ANG, contains the coordinate values corresponding to the columns of PAT.
% 2016-04-16 V0.1 Collus Wang
% 2017-07-05 V1.0 Collus Wang, add pattern normalize = false.
% 2017-07-08 V1.1 Collus Wang, add pattern type switch.
% 2017-10-14 V1.2 Collus Wang, export pattern.

% Flags and Switches
SwitchPattern = 'powerdb';    % control the AZ and EL cut pattern type {'directivity' | 'powerdb'}

% view array geometry
figure(figureStartNum)
viewArray(hArray, 'ShowNormals', true, 'ShowIndex', 'All' );

% 3D plot of array pattern
figure(figureStartNum+10)
pattern(hArray, FreqCenter,...
    'CoordinateSystem','polar',...
    'Type', 'directivity', ...
    'Weight', weight);
colormap('jet')

% Array AZ cut
AZ = -180:0.1:180;
figure(figureStartNum+20)
switch SwitchPattern
    case 'powerdb'
        pattern(hArray, FreqCenter, AZ, ELofAZCut,...
            'CoordinateSystem', 'Polar',...
            'Type', 'powerdb',...
            'Weight', weight);
        [PAT,AZ_ANG,EL_ANG] = pattern(hArray, FreqCenter, AZ, ELofAZCut,...
            'CoordinateSystem', 'polar',...
            'Type', 'powerdb', ...
            'Plotstyle', 'overlay', ...
            'Normalize', false, ...
            'Weight', weight);
    case 'directivity'
        pattern(hArray, FreqCenter, AZ, ELofAZCut,...
            'CoordinateSystem', 'Polar',...
            'Type', 'directivity',...
            'Weight', weight);
        [PAT,AZ_ANG,EL_ANG] = pattern(hArray, FreqCenter, AZ, ELofAZCut,...
            'CoordinateSystem', 'polar',...
            'Type', 'directivity', ...
            'Plotstyle', 'overlay', ...
            'Weight', weight);
end
figure(figureStartNum+21)
plot(AZ_ANG,PAT.', 'LineWidth', 1.5);
hold on
plot(AZ_ANG,-3*ones(size(AZ_ANG)), 'r--', 'LineWidth', 1.5);
xlim([min(AZ_ANG), max(AZ_ANG)])
ylim([-30, 5])
title('Array Azimuth Cut')
xlabel('Azimuth (degree)')
ylabel('Normalized Power (dB)')
legend('Norm. Power', '-3dB', 'Location', 'Best')
grid on
PATAZ.PAT = PAT;
PATAZ.AZ_ANG = AZ_ANG;
PATAZ.EL_ANG = EL_ANG;

% Array EL cut
figure(figureStartNum+30)
clf
EL = -90:0.1:90;
switch SwitchPattern
    case 'powerdb'
        pattern(hArray, FreqCenter, AZofELCut, EL,...
            'CoordinateSystem', 'polar',...
            'Type', 'powerdb', ...
            'Plotstyle', 'overlay', ...
            'Weight', weight);
        [PAT,AZ_ANG,EL_ANG] = pattern(hArray, FreqCenter, AZofELCut, EL,...
            'CoordinateSystem', 'polar',...
            'Type', 'powerdb', ...
            'Plotstyle', 'overlay', ...
            'Normalize', false, ...
            'Weight', weight);
    case 'directivity'
        pattern(hArray, FreqCenter, AZofELCut, EL,...
            'CoordinateSystem', 'polar',...
            'Type', 'directivity', ...
            'Plotstyle', 'overlay', ...
            'Weight', weight);
        [PAT,AZ_ANG,EL_ANG] = pattern(hArray, FreqCenter, AZofELCut, EL,...
            'CoordinateSystem', 'polar',...
            'Type', 'directivity', ...
            'Plotstyle', 'overlay', ...
            'Weight', weight);
end
figure(figureStartNum+31)
plot(EL_ANG,PAT.', 'LineWidth', 1.5);
hold on
plot(EL_ANG,-3*ones(size(EL_ANG)), 'r--', 'LineWidth', 1.5);
xlim([min(EL_ANG), max(EL_ANG)])
ylim([-30, 5])
title('Array Elevation Cut')
xlabel('Elevation (degree)')
ylabel('Normalized Power (dB)')
legend('Norm. Power', '-3dB', 'Location', 'Best')
grid on
PATEL.PAT = PAT;
PATEL.AZ_ANG = AZ_ANG;
PATEL.EL_ANG = EL_ANG;


end
