% GenSymbolMap.m

% Constellation mapping according to 3GPP TS 36.211

SymbolMapQPSK = [
    1+1j*1;
    1+1j*-1;
    -1+1j*1;
    -1+1j*-1;
    ]/sqrt(2);

SymbolMapOQPSK = [
    1+1j*1;
    1+1j*-1;
    -1+1j*1;
    -1+1j*-1;
    ];

SymbolMap16QAM = [
    1+1j*1;
    1+1j*3;
    3+1j*1;
    3+1j*3;
    1+1j*-1;
    1+1j*-3;
    3+1j*-1;
    3+1j*-3;
    -1+1j*1;
    -1+1j*3;
    -3+1j*1;
    -3+1j*3;
    -1+1j*-1;
    -1+1j*-3;
    -3+1j*-1;
    -3+1j*-3;
    ]/sqrt(10);


SymbolMap64QAM = [
    3+1j*3 ;
    3+1j*1 ;
    1+1j*3 ;
    1+1j*1 ;
    3+1j*5 ;
    3+1j*7 ;
    1+1j*5 ;
    1+1j*7 ;
    5+1j*3 ;
    5+1j*1 ;
    7+1j*3 ;
    7+1j*1 ;
    5+1j*5 ;
    5+1j*7 ;
    7+1j*5 ;
    7+1j*7 ;
    3+1j*-3;
    3+1j*-1;
    1+1j*-3;
    1+1j*-1;
    3+1j*-5;
    3+1j*-7;
    1+1j*-5;
    1+1j*-7;
    5+1j*-3;
    5+1j*-1;
    7+1j*-3;
    7+1j*-1;
    5+1j*-5;
    5+1j*-7;
    7+1j*-5;
    7+1j*-7;
    -3+1j*3;
    -3+1j*1;
    -1+1j*3;
    -1+1j*1;
    -3+1j*5;
    -3+1j*7;
    -1+1j*5;
    -1+1j*7;
    -5+1j*3;
    -5+1j*1;
    -7+1j*3;
    -7+1j*1;
    -5+1j*5;
    -5+1j*7;
    -7+1j*5;
    -7+1j*7;
    -3+1j*-3;
    -3+1j*-1;
    -1+1j*-3;
    -1+1j*-1;
    -3+1j*-5;
    -3+1j*-7;
    -1+1j*-5;
    -1+1j*-7;
    -5+1j*-3;
    -5+1j*-1;
    -7+1j*-3;
    -7+1j*-1;
    -5+1j*-5;
    -5+1j*-7;
    -7+1j*-5;
    -7+1j*-7;
    ]/sqrt(42);


% figure(1)
% clf
% plot(SymbolMapOQPSK, '.', 'markerSize', 25)
% hold on
% for idx = 1:length(SymbolMapOQPSK)
%     str = sprintf('%s', dec2bin(idx - 1, 2));
%     text(real(SymbolMapOQPSK(idx))+0.05, imag(SymbolMapOQPSK(idx)), str);
% end
% title('OQPSK modulation mapping')
% xlim([-1.5, 1.5])
% ylim([-1.5, 1.5])
% grid on
% rmsOQPSK = rms(SymbolMapOQPSK)
% 
% figure(2)
% clf
% plot(SymbolMap16QAM, '.', 'markerSize', 25)
% hold on
% for idx = 1:length(SymbolMap16QAM)
%     str = sprintf('%s', dec2bin(idx - 1, 4));
%     text(real(SymbolMap16QAM(idx))+0.05, imag(SymbolMap16QAM(idx)), str);
% end
% title('16QAM modulation mapping')
% xlim([-1.5, 1.5])
% ylim([-1.5, 1.5])
% grid on
% rms16QAM = rms(SymbolMap16QAM)
% 
% figure(3)
% clf
% plot(SymbolMap64QAM, '.', 'markerSize', 25)
% hold on
% for idx = 1:length(SymbolMap64QAM)
%     str = sprintf('%d', idx - 1);
%     text(real(SymbolMap64QAM(idx)), imag(SymbolMap64QAM(idx))-0.1, str);
% end
% title('64QAM modulation mapping')
% xlim([-1.5, 1.5])
% ylim([-1.5, 1.5])
% grid on
% rms64QAM = rms(SymbolMap64QAM)

% figure(4)
% clf
% plot(SymbolMapQPSK, '.', 'markerSize', 25)
% hold on
% for idx = 1:length(SymbolMapQPSK)
%     str = sprintf('%s', dec2bin(idx - 1, 2));
%     text(real(SymbolMapQPSK(idx))+0.05, imag(SymbolMapQPSK(idx)), str);
% end
% title('QPSK modulation mapping')
% xlim([-1.5, 1.5])
% ylim([-1.5, 1.5])
% grid on
% rmsOQPSK = rms(SymbolMapQPSK)
