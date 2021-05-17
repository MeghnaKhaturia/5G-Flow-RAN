function gnb_scheduler_ul() 
global param;
global bs;
global ue
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
    if param.policy == 1
        ind_attach = find([ue.attach_ul] == 0);
    else
        ind_attach = find([ue.attach] == 0);
    end
    
    if ~mod(param.t-0.5,(bs.CQImeasure_period))
        for i = ind_attach
            ue(i).snr_ul = snr_gnb(bs,ue(i),flag);
        end
    end
    
    %% Resource Allocation (Round robin scheduler)
    i = find(ind_attach == bs.lastserveduser_ul);
    u_served = 0;
    while prb_avail > 0        
        u_i = ind_attach(i);
        u_served = u_served + 1;
        u_i_satisfied = 0;
        if ~isempty([ue(u_i).tcp_data_ul])
            bits_to_send = sum([ue(u_i).tcp_data_ul.size]*8);
            while u_i_satisfied == 0 && prb_avail > 0
                alloc_PRB(u_i) = alloc_PRB(u_i) + 1;
                prb_avail = bs.nPRBs - sum(alloc_PRB);   
                [~,TBS] = snr_2_rate_gnb(ue(u_i).snr_ul,alloc_PRB(u_i));
                alloc_TBS(u_i) = TBS;
                if alloc_TBS(u_i) > bits_to_send                    
                    u_i_satisfied = 1; 
                    i = mod(i,length(ind_attach))+1;
                end             
            end
        else
             i = mod(i,length(ind_attach))+1;
        end
        if u_served >= length(ind_attach)
            break;
        end
    end   
   
    bs.lastserveduser_ul = ind_attach(i);
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
    