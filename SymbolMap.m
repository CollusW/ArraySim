function constellation = SymbolMap(dataBits , modType)
% Description: Map bits to constellation points(symbols).
% Input:
%   dataBits: binary colum or raw vector, data bits to be mapped into constellations.
%   modType:  string, modulation type. valid value = {'OQPSK', 'QPSK', '16QAM', '64QAM'}
% Output:
%   constellation: colum complex vector, constellation points. valid value according to symbol map.
% Revision History:
% 2016.01, V1.0, Collus Wang, first draft

%% check inputs
if ~isvector(dataBits)
    error('Data bits should be column vector.');
elseif isrow(dataBits)
    dataBits = dataBits.';
end

%% load symbol map
GenSymbolMap;

%% modulation 
switch modType
    case 'OQPSK'
        temp = reshape(dataBits, 2, []).';
        idxSym = temp(:,1)*2 + temp(:,2);
        constellation = SymbolMapOQPSK(idxSym+1);
    case 'QPSK'
        temp = reshape(dataBits, 2, []).';
        idxSym = temp(:,1)*2 + temp(:,2);
        constellation = SymbolMapQPSK(idxSym+1);
    case '16QAM'
        temp = reshape(dataBits, 4, []).';
        idxSym = temp(:,1)*8 + temp(:,2)*4 + temp(:,3)*2 + temp(:,4);
        constellation = SymbolMap16QAM(idxSym+1);
    case '64QAM'
        temp = reshape(dataBits, 6, []).';
        idxSym = temp(:,1)*32 + temp(:,2)*16 + temp(:,3)*8 + temp(:,4)*4 + temp(:,5)*2 + temp(:,6) ;
        constellation = SymbolMap64QAM(idxSym+1);
    otherwise
        error('Unknown modulation type.')
end


