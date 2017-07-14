function [ hArray] = GenArray(sysPara, hAntennaElement)
% /*!
%  *  @brief     This function create the antenna array system object.
%  *  @details   . 
%  *  @param[out] hArray, 1x1 antenna array system object.
%  *  @param[in] sysPara, 1x1 struct, which contains the following field:
%       see get used field for detail.
%  *  @param[in] hAntennaElement, 1x1 Antenna system object.
%  *  @pre       .
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.05.25.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.05.25. Collus Wang,  first draft }
%  * @remark   { revision history: V1.0, 2017.07.12. Collus Wang,  fix bug: ConformalArray use hAntennaElement}
%  */

%% get used field
ArrayType = sysPara.ArrayType;
NumElements = sysPara.NumElements;
NumChannel = sysPara.NumChannel;
Radius = sysPara.Radius;

%% Flags
GlobalDebugPlot = sysPara.GlobalDebugPlot;
FlagDebugPlot = true && GlobalDebugPlot;
FigureStartNum = 2000;

%% generate array pattern
switch lower(ArrayType)
    case 'uca'        % UCA 
        hArray = phased.UCA('NumElements',NumElements,'Radius',Radius,'Element',hAntennaElement);
        if FlagDebugPlot
            elementSpacing = getElementSpacing(hArray, 'chord');
        end
    case 'conformal'
        AngleOffset = -15-7.5;  % AZ angle between the first element norm and x-axis, in degree.
        ang = (0:NumElements-1)*360/NumElements + AngleOffset;
        ang(ang >= 180.0) = ang(ang >= 180.0) - 360.0;
        elementPosition = [Radius*cosd(ang); Radius*sind(ang); zeros(1,NumElements);];
        elementNormal = [ang;zeros(1,NumElements)];        
        elementPosition = elementPosition(:, 1:NumChannel); % only use NumChannel elements
        elementNormal = elementNormal(:, 1:NumChannel); % only use NumChannel elements
        hArray = phased.ConformalArray('Element',hAntennaElement,...
            'ElementPosition', elementPosition,...
            'ElementNormal', elementNormal);
     otherwise
        error('Unsupported array type.')
end

%% plot array pattern
if FlagDebugPlot
    figure(FigureStartNum+0)
    viewArray(hArray, 'ShowNormals', true,...
        'ShowIndex', 'All');
end







