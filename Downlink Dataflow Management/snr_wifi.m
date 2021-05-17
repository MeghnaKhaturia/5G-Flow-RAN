%Pathloss model for IEEE 802.11 is taken from the document 
%"IEEE 802.11ax Channel Model Document (IEEE 802.11-14/0882r4)". 
% The path loss models for IEEE 802.11ax outdoor scenarios are 
% based on UMi path loss model discussed in the document ITU-R M.2135-1.
function RSS = snr_wifi(wifi,ue,flag)

    % Parameters
    if flag == 1 % Downlink
        Ptx = wifi.txpow; % Transmit Power (in dBm)
        Gt = wifi.txAntGain; % Transmit Antenna Gain of BS
        Gr = ue.rxAntGain; % Receive Antenna Gain of UE
    else % Uplink
        Ptx = ue.txpow_wifi; % Transmit Power (in dBm)
        Gt = ue.txAntGain; % Transmit Antenna Gain of BS
        Gr = wifi.rxAntGain; % Receive Antenna Gain of UE
    end
    hwifi = wifi.height; % Height of Base Station (10m<=hBS<=150m)
    hUT = ue.height; % Height of User Equipment (1m<=hUT<=10m)
    fc = wifi.freq; % Frequency of Operation (in GHz)    
    S = wifi.shadowing; % 0 for no shadowing, 1 for shadowing
    sigma_SF_LOS = 3; % Shadow Fading Parameter (in dB)
    sigma_SF_NLOS = 4;
    NF = 7+2; %Noise Figure and cable loss (in dB)
    %N = -100; %Noise in dBm at 20Mhz
    FM = 10;
    
    r = 1;
    d = pdist2(wifi.pos',ue.pos');
    
    if r == 1
        d_BP= 4*(hwifi-1)*(hUT-1)*fc*1e9/(3*1e8);
        if d < d_BP
            PL_LOS = 22*log10(d) + 28 + 20*log10(fc); %if 10m<d<d_BP
        else
            PL_LOS = 40*log10(d) + 7.8 - 18*log10(hwifi-1) - ...
                18*log10(hUT-1) + 20*log10(fc);  % if  d_BP<d<5000m
        end
        
        % Shadow Fading        
        PL = PL_LOS + S*randn*sigma_SF_LOS;
    else    
        PL_NLOS =  36.7*log10(d) + 22.7 + 26*log10(fc);
        PL = PL_NLOS + S*randn*sigma_SF_NLOS;
    end    

    % SINR Calculation
    RSS = Ptx + Gr + Gt - PL - NF - FM; % Received Signal Strength
    
end