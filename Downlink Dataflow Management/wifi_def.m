function wifi = wifi_def(wifi,pos)
    
    for i = 1:size(wifi,2)
        wifi(i).ID = i; 
        wifi(i).pos = pos(i,:)';
    end
    
    % Assigning wifi attributes
    [wifi.txpow] = deal(20); % in dBm (maximum allowed power)
    [wifi.height] = deal(10); % 10 m
    [wifi.txAntGain] = deal(4); % in dBi
    [wifi.rxAntGain] = deal(4); % in dBi
    [wifi.Bandwidth] = deal(20); % in MHz
    [wifi.freq] = deal(2.4); % in GHz
    [wifi.shadowing] = deal(1);
    [wifi.GI] = deal(1); % 1 for 800ns and 2 for 400 ns guard interval
    [wifi.spatialstream] = deal(1); % Spatial Stream [1,2,3]
   
    % Analysis parameters
    [wifi.txpckts_dl] = deal(0);
    [wifi.txbits_dl] = deal(0);
    [wifi.rxbits_ul] = deal(0);
    [wifi.rxpckts_ul] = deal(0);       
    
end