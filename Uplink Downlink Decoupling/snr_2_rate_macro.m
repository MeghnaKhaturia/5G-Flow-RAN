function [rate,TBS] = snr_2_rate_macro(SNR,nPRB,flag)
    v = 1; % Number of layers ( for SISO, v = 1)
    N_RB_SC = 12;    
    % Number of Scheduled OFDM symbols in a slot (max 14 or 12) depending
    % on SLIV
    N_SH_SYM = 14; 
    % Number of REs for DMRS per PRB in the scheduled duration including
    % the overhead of the DMRS CDm groups indicated by DCI format 1_0/1_1
    N_PRB_DMRS = 12;
    % Overhead configured by higher layer paramter Xoh_PDSCH. If Xoh_PDSCH
    % is not configured (0,6,12 or 18), then it is set to 0.
    N_PRB_OH = 0;
    s_e = log2(1+10^(SNR/10));
    
    %% Calculating N_info
    N_RE0 = N_RB_SC*N_SH_SYM - N_PRB_DMRS - N_PRB_OH;
    N_RE_quant = [9,15,30,57,90,126,150,200;6,12,18,42,72,108,144,156];
    ind = find(N_RE_quant(1,:)>N_RE0,1)-1;
    N_RE = N_RE_quant(2,ind)*nPRB;
    
    % MCS Index Table
    S_eff = [0.2344, 0.3066, 0.3770, 0.4902, 0.6016, 0.7402, 0.8770, 1.0273,...
        1.1758, 1.3262, 1.3281, 1.4766, 1.6953, 1.9141, 2.1602, 2.4063, 2.5703,...
        2.5664, 2.7305, 3.0293, 3.3223, 3.6094, 3.9023, 4.2129, 4.5234, 4.8164,...
        5.1152, 5.3320, 5.5547];
    %I_MCS = [0,	1,	2,	3,	4,	5,	6,	7,	8,	9,	10,	11,	12,	13,	14,	15,...
     %   16,	17,	18,	19,	20,	21,	22,	23,	24,	25,	26,	27,	28];
    Qm = [2, 2,	2,	2,	2,	2,	2,	2,	2,	2,	4,	4,	4,	4,	4,	4,	4,...
        6,	6,	6,	6,	6,	6,	6,	6,	6,	6,	6,	6];
    R = [120, 157, 193, 251, 308, 379, 449,	526, 602, 679, 340, 378, 434, 490,...
        553, 616, 658, 438, 466, 517, 567, 616,	666, 719, 772, 822,	873, 910, 948]/1024;
    ind = max(1,(find(S_eff > s_e,1) - 1));  
    if isempty(ind)
        ind=29;
    end
    N_info = N_RE*R(ind)*Qm(ind)*v;
    
    %% Calculating TBS from N_info
    TBS_ind = [24, 32, 40, 48,	56,	64,	72,	80,	88,	96,	104, 112, 120, 128, ...
        136, 144, 152, 160, 168, 176, 184, 192, 208, 224, 240, 256,	272, 288,...
        304, 320, 336, 352,	368, 384, 408, 432,	456, 480, 504, 528,	552, 576,...
        608, 640, 672, 704,	736, 768, 808, 848,	888, 928, 984, 1032, 1064, 1128,...
        1160, 1192,	1224, 1256, 1288, 1320, 1352, 1416, 1480, 1544, 1608, 1672,...
        1736, 1800, 1864, 1928, 2024, 2088, 2152, 2216, 2280, 2408, 2472, 2536,...
        2600, 2664, 2728, 2792, 2856, 2976, 3104, 3240, 3368, 3496, 3624, 3752, 3824];

    if N_info <= 3824
        n = max(3,floor(log2(N_info))-6);
        N_info_bar = max(24,2^n*floor(N_info/2^n));        
        temp = find(TBS_ind > N_info_bar,1);
        TBS = TBS_ind(temp);
    else
        n = floor(log2(N_info-24))-5;
        N_info_bar = (2^n)*round((N_info-24)/(2^n)) ;
        if R(ind) < 1/4
            C = ceil((N_info_bar + 24)/3816);
            TBS = 8*C*ceil((N_info_bar + 24)/(8*C)) - 24;
        else
            if N_info_bar >= 8424 
                C = ceil((N_info_bar + 24)/8424);
                TBS = 8*C*ceil((N_info_bar + 24)/(8*C)) - 24;
            else
                TBS = 8*ceil((N_info_bar + 24)/8) - 24;
            end
        end
    end
    rate = TBS*2*10^(-3);
end