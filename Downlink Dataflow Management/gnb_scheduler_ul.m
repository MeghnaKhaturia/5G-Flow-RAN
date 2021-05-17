function ue = gnb_scheduler_ul(bs,ue) 
global param;
    % If UEs have no data to send, then terminate the function
    if isempty([ue.tcp_data_ul])
        return;
    end   
    
    %% Initialization
    flag = 0; % for uplink
    N_users = size(ue,2);
    N_PRBs = 100; % for 20MHz
    prb_avail = N_PRBs;
    alloc_TBS = zeros(1,N_users);
    alloc_PRB = zeros(1,N_users);
    satisfied = zeros(1,N_users);
    p = zeros(1,N_users);    
    ind_attach = find([ue.attach] == 0);
    
    for i = ind_attach
        if isempty(ue(i).snr_ul)
            ue(i).snr_ul = snr_gnb(bs,ue(i),flag);
        elseif ~mod(param.t,bs.CQImeasure_period)
            ue(i).snr_ul = snr_gnb(bs,ue(i),flag);
        end
    end
    %% Resource Allocation (Round robin scheduler)   
    while prb_avail > 0
        prb_avail = N_PRBs - sum(alloc_PRB);
        for i = ind_attach 
            if ~isempty(ue(i).tcp_data_ul) && satisfied(i) == 0
                alloc_PRB(i) = alloc_PRB(i) + 1;
                bits_to_send = sum([ue(i).tcp_data_ul.size]*8);                             
                [~,TBS] = snr_2_rate_gnb(ue(i).snr_ul,alloc_PRB(i),flag);
                alloc_TBS(i) = TBS;
                if alloc_TBS(i) > bits_to_send                    
                    satisfied(i) = 1; 
                end
                prb_avail = prb_avail - 1;
                if prb_avail <=0
                   break;
                end
            elseif isempty(ue(i).tcp_data_ul)
                satisfied(i) = 1;
            end  
        end     
        if all(satisfied(ind_attach)) 
            break;
        end
    end
    
    %% Packet Fragmentation & transmission
    % Packet drop probability (only when CQI information is not available)
    if mod(param.t,bs.CQImeasure_period)
        for i = ind_attach
            current_snr = snr_gnb(bs,ue(i),flag);
            p(i) = (ue(i).snr_ul > (current_snr + 10));
        end
    end
    
    % Fragmentation 
    for i = ind_attach  
        if ~isempty(ue(i).tcp_data_ul)
        for j = 1:sum([ue(i).tcp_data_ul.ack]==0)
            if alloc_TBS(i) > 0 
                pckt_size = ue(i).tcp_data_ul(j).size;
                if alloc_TBS(i) > pckt_size*8                    
                    ue(i).txbits_ul = ue(i).txbits_ul + pckt_size*8;
                    ue(i).tcp_data_ul(j).ack = 1 - p(i);   
                    ue(i).tcp_data_ul(j).lost = p(i);   
                    alloc_TBS(i) = alloc_TBS(i) - pckt_size*8;
                else                   
                    ue(i).txbits_ul = ue(i).txbits_ul + alloc_TBS(i);
                    ue(i).tcp_data_ul(j).size = ue(i).tcp_data_ul(j).size - (1-p(i))*floor(alloc_TBS(i)/8);
                    alloc_TBS(i) = 0;
                end
            end  
        end
        end
    end
    
end
    