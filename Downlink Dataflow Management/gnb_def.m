function bs = bs_def(bs,param)
    bs.ID = 0;
    bs.pos = [250,250];
    
    % These parameter values are taken from 3GPP TR 36.931
    bs.txpow = 30; % dBm  
    bs.txAntGain =6; %dBi
    bs.rxAntGain =6; %dBi (erricson)
    bs.Bandwidth = 60; %MHz
    bs.height = 25; % in meters (ericsson)
    bs.freq = 1.9; % in GHz (FDD, n1 frequency band)
    %bs.freq_dl = 2.1; % in GHZ
    bs.shadowing = 1; % 1 for shadowing, 0 for no shadowing
    bs.numerology = 1; % Subcarrier spacing = 30 Khz
    bs.CQImeasure_period = 10; % in ms
    bs.nPRBs = 162; % Number of Physical resource blocks
    bs.slot_time = 0.5; % in ms
    
    % Analysis parameters
    bs.txpckts_dl = 0;
    bs.rxpckts_ul = 0;
    bs.txbits_dl = 0;
    bs.rxbits_ul = 0;
end