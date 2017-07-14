function [ hAntennaElement] = GenAntennaElement(sysPara)
% /*!
%  *  @brief     This function create antenna element system object.
%  *  @details   . 
%  *  @param[out] hAntennaElement,  1x1 Antenna system object.
%  *  @param[in] sysPara, 1x1 struct, which contains the following field:
%       see get used field for detail.
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
AntennaType = sysPara.AntennaType;
AntennaPatternFileName = sysPara.AntennaPatternFileName;
FrequencyRange = sysPara.FrequencyRange;
FreqCenter = sysPara.FreqCenter;

%% Flags
GlobalDebugPlot = sysPara.GlobalDebugPlot;
FlagDebugPlot = true && GlobalDebugPlot;
figureStartNum = 1000;

%% preprocess
if ~isvector(FrequencyRange)
    error('FrequencyRange should be column vector.');
elseif isrow(FrequencyRange)
    FrequencyRange = FrequencyRange.';
end

%% load antenna pattern
switch lower(AntennaType)
    case 'custom'
        tableAntenna = csvread(AntennaPatternFileName, 1, 0);  % import from HFSS csv file
        phi = tableAntenna(:,1);
        theta = tableAntenna(:,2);
        pattern_phitheta = tableAntenna(:,3);
        phi = unique(phi, 'stable');
        theta = unique(theta, 'stable');
        pattern_phitheta = reshape(pattern_phitheta, length(phi),  length(theta)).';
        [pattern_azel,az,el] = phitheta2azelpat(pattern_phitheta,phi,theta);    % convert phitheta to az el coordinates
        hAntennaElement = phased.CustomAntennaElement('FrequencyVector',FrequencyRange.',...
            'AzimuthAngles',az,...
            'ElevationAngles',el,...
            'RadiationPattern',pattern_azel);
    otherwise
        error('Unsupported antenna type.')
end
        
%% plot antenna element
if FlagDebugPlot
    ELofAZCut = -3;    % Elevation angle (degree) of AZ cut view
    AZofELCut = 0;      % Azimuth angle (degree) of EL cut view
    
    % 3D plot
    figure(figureStartNum+0);
    pattern(hAntennaElement, FreqCenter,...
        'CoordinateSystem', 'Polar',...
        'Type', 'directivity');
    colormap('jet')
    
    % Antenna element: AZ cut
    AZ = -180:0.1:180;
    figure(figureStartNum+100)
    pattern(hAntennaElement, FreqCenter, AZ, ELofAZCut,...
        'CoordinateSystem', 'Polar',...
        'Type', 'powerdb');     % polar plot
    [PAT,AZ_ANG,EL_ANG] = pattern(hAntennaElement, FreqCenter, AZ, ELofAZCut,...
        'CoordinateSystem', 'polar',...
        'Type', 'powerdb', ...
        'Plotstyle', 'overlay');    % get data and then customized plot
    figure(figureStartNum+200)
    plot(AZ_ANG, PAT.', 'LineWidth', 1.5);
    hold on
    plot(AZ_ANG,-3*ones(size(AZ_ANG)), 'r--', 'LineWidth', 1.5);    % -3dB line
    xlim([min(AZ_ANG), max(AZ_ANG)])
    ylim([-70, 5])
    title('Antenna Element Azimuth Cut')
    xlabel('Azimuth (degree)')
    ylabel('Normalized Power (dB)')
    legend('Norm. Power', '-3dB', 'Location', 'Best')
    grid on
    
    % element: EL cut
    figure(figureStartNum+300)
    clf
    EL = -90:0.1:90;
    pattern(hAntennaElement, FreqCenter, AZofELCut, EL,...
        'CoordinateSystem', 'polar',...
        'Type', 'powerdb', ...
        'Plotstyle', 'overlay');     % polar plot
    [PAT,AZ_ANG,EL_ANG] = pattern(hAntennaElement, FreqCenter, AZofELCut, EL,...
        'CoordinateSystem', 'polar',...
        'Type', 'powerdb', ...
        'Plotstyle', 'overlay');    % get data and then customized plot
    figure(figureStartNum+210)
    plot(EL_ANG,PAT.', 'LineWidth', 1.5);
    hold on
    plot(EL_ANG,-3*ones(size(EL_ANG)), 'r--', 'LineWidth', 1.5);    % -3dB line
    xlim([min(EL_ANG), max(EL_ANG)])
    ylim([-70, 5])
    title('Antenna Element Elevation Cut')
    xlabel('Elevation (degree)')
    ylabel('Normalized Power (dB)')
    legend('Norm. Power', '-3dB', 'Location', 'Best')
    grid on
end