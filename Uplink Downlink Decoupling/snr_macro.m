% Urban Macrocell Pathloss model as suggested in 3GPP TR 38.901
% All distances and heights are in meters
function SNR_dB = snr_macro(bs,ue,flag) 
    global param;
    % Parameters
    if flag == 1
        Ptx = bs.txpow; % Transmit Power (in dBm)
        Gt = bs.txAntGain; % Transmit Antenna Gain of BS
        Gr = ue.rxAntGain; % Receive Antenna Gain of UE
        NF = 7+6; %Noise Figure and cable loss (in dB)
    else
        Ptx = ue.txpow;
        Gt = ue.txAntGain; % Transmit Antenna Gain of BS
        Gr = bs.rxAntGain; % Receive Antenna Gain of UE
        NF = 5+6; %Noise Figure and cable loss (in dB)
    end
    hBS = bs.height; % Height of Base Station (10m<=hBS<=150m)
    hUT = ue.height; % Height of User Equipment (1m<=hUT<=10m)    
    fc = bs.freq; % Frequency of Operation (in GHz)    
    S = bs.shadowing; % 0 for no shadowing, 1 for shadowing    
    %W = 20; % Average Street Width (5m<=W<=50m)
    %h = 5; % Average Building Height (5m<=h<=50m)
    c = 3e8; 
    sigma_SF_nlos = 6; % Shadow Fading Parameter (in dB)
    sigma_SF_los = 4;    
    N = -114 + 10*log10(bs.Bandwidth); %Noise level in dBm
    T_c = 32; % Coherence time in ms (Tc = 9*c/(16*pi*v*fc))
    T_c_los = 20; %(50)
    %FM = 10; % Fade Margin
    
    % Distances   
    d2d = pdist2(bs.pos,ue.pos');
    d3d = sqrt(d2d^2 + (hBS-hUT)^2);  
    dBP = ceil((4*(hUT-1)*(hBS-1)*fc*1e9)/c) ;
    
    % LOS probablity
    if d2d < 18
        Pr_LOS = 1;
    else
        Pr_LOS = 18/d2d + (exp(-d2d/63))*(1-18/d2d);
    end
    persistent p;
    if (~mod(param.t,T_c_los) || isempty(p)) 
        p = rand(1)<Pr_LOS; % 1 if link is LOS
    end
    
    % LOS Pathloss
    if d2d<dBP 
        PL_LOS = 28 + 22*log10(d3d)+ 20*log10(fc);
    else 
        PL_LOS = 28 + 40*log10(d3d) + 20*log10(fc)...
            - 9*log10(dBP^2 + (hBS - hUT)^2);
    end   
    
    % NLOS Pathloss
    if ~p
        PL_NLOS = 13.54 + 39.08*log10(d3d)+20*log10(fc)-0.6*(hUT -1.5);
        PL =  max(PL_LOS,PL_NLOS);
    else
        PL = PL_LOS;
    end 
    
    % Shadow Fading for uplink
    persistent SF_ul;
    if (~mod(param.t,T_c) || isempty(SF_ul)) && flag == 0
        SF_ul = S*randn*(p*sigma_SF_los+(1-p)*sigma_SF_nlos);
    end
    
    % Shadow Fading for downlink
    persistent SF_dl;
    if (~mod(param.t,T_c) || isempty(SF_dl)) && flag == 1        
        SF_dl = S*randn*(p*sigma_SF_los+(1-p)*sigma_SF_nlos);
    end
    
    if flag == 1
        PL = PL + SF_dl;
    else
        PL = PL + SF_ul;
    end
    
    % SINR Calculation
    SNR_dB = Ptx + Gr + Gt - PL - NF - N;
end