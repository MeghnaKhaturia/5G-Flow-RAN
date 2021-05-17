function gnb_scheduler()  

%% Global Variables
global param;
global bs;
global ue;
%%
    % Finding UEs which are attached to eNB
    ind_attach = find([ue.attach] == 0);
    
    % If eNB has no data to be sent for UEs, then terminate the function
    if isempty([bs.tcp_data_dl])
        return;
    end
    
    
    %% Initialization
    N_users = param.nUEs;
    prb_avail = bs.nPRBs;
    alloc_TBS = zeros(1,N_users);
    alloc_PRB = zeros(1,N_users);
    satisfied = zeros(1,N_users);
    p = zeros(1,N_users);    
    flag = 1;
    % Update SNR based on CQImeasure_period value    
    if ~mod(param.t,bs.CQImeasure_period)
        for i = ind_attach
            ue(i).snr_dl = snr_gnb(bs,ue(i),flag);
        end
    end
     %% Resource Allocation (Priority Scheduler)          
    for i = 1:4
        ind_service = ind_attach(([ue(ind_attach).service_type] == i));
        j = 1; 
        if ~isempty(ind_service)
            while prb_avail > 0 && j<= length(ind_service)
                u_j_satisfied = 0;
                u_j = ind_service(j);    
               if sum([bs.tcp_data_dl.destination] == u_j)            
                    ind = [bs.tcp_data_dl.destination] == u_j;
                    bits_to_send = sum([bs.tcp_data_dl(ind).size]*8);
                    while u_j_satisfied == 0 && prb_avail > 0
                        alloc_PRB(u_j) = alloc_PRB(u_j) + 1;
                        prb_avail = bs.nPRBs - sum(alloc_PRB);   
                        [~,TBS] = snr_2_rate_gnb(ue(u_j).snr_dl,alloc_PRB(u_j));
                        alloc_TBS(u_j) = TBS;
                        if alloc_TBS(u_j) > bits_to_send                    
                            u_j_satisfied = 1;                         
                            j = j+1;
                        end             
                    end
               else
                    j = j+1;
               end   
            end
        end
    end
    %% Resource Allocation (Round robin scheduler)
%     i = find(ind_attach == bs.lastserveduser_dl);
%     u_served = 0;
%     while prb_avail > 0
%         u_i = ind_attach(i);
%         u_served = u_served + 1;
%         u_i_satisfied = 0;
%         if sum([bs.tcp_data_dl.destination] == u_i)            
%             ind = [bs.tcp_data_dl.destination] == u_i;
%             bits_to_send = sum([bs.tcp_data_dl(ind).size]*8);
%             while u_i_satisfied == 0 && prb_avail > 0
%                 alloc_PRB(u_i) = alloc_PRB(u_i) + 1;
%                 prb_avail = bs.nPRBs - sum(alloc_PRB);   
%                 [~,TBS] = snr_2_rate_gnb(ue(u_i).snr_dl,alloc_PRB(u_i));
%                 alloc_TBS(u_i) = TBS;
%                 if alloc_TBS(u_i) > bits_to_send                    
%                     u_i_satisfied = 1; 
%                     i = mod(i,length(ind_attach))+1;
%                 end             
%             end
%         else
%              i = mod(i,length(ind_attach))+1;
%         end
%         if u_served >= length(ind_attach)
%             break;
%         end
%     end
%     bs.lastserveduser_dl = ind_attach(i);
    
    %% Packet Fragmentation & transmission    
    % Fragmentation    
    for i = ind_attach        
        p(i) = 0;
        if mod(param.t,bs.CQImeasure_period)
            current_snr = snr_gnb(bs,ue(i),flag);
            p(i) = (ue(i).snr_dl > (current_snr + 10)); % Packet Drop  
        end
       
        for j = find([bs.tcp_data_dl.destination] == i)
            if alloc_TBS(i) > 0 && [bs.tcp_data_dl(j).ack] == 0
                pckt_size = bs.tcp_data_dl(j).size;
                if alloc_TBS(i) >= pckt_size*8                    
                    bs.txbits_dl = bs.txbits_dl + pckt_size*8;
                    bs.tcp_data_dl(j).ack = (1-p(i)) ;
                    bs.tcp_data_dl(j).lost = p(i) ;
                    alloc_TBS(i) = alloc_TBS(i) - pckt_size*8;
                else                   
                    bs.txbits_dl = bs.txbits_dl + alloc_TBS(i);
                    bs.tcp_data_dl(j).size = bs.tcp_data_dl(j).size - (1-p(i))*floor(alloc_TBS(i)/8);
                    alloc_TBS(i) = 0;
                end
                if p(i) == 1
                    ue(i).packet_loss = ue(i).packet_loss + p(i)*ue(i).count;
                    ue(i).count = 0;
                    ue(i).snr_dl = snr_gnb(bs,ue(i),flag);
                end
            end 
       end
        
    end
end
    