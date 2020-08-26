function send_data_ul()
global ue;
global param;
global bs;

    
    % Checking Application buffer for data        
    for i = 1:param.nUEs
        n = poissrnd(param.lambda_ul(i)*param.slot_sim);
        ue(i).txpckts_ul = ue(i).txpckts_ul + n;
        if param.policy == 1
            tmp = ue(i).attach_ul;
        else
            tmp = ue(i).attach;
        end
        for j = 1:n
            tcp_pckt = packet;
            tcp_pckt.org_size = param.data_pckt_size;
            tcp_pckt.size =param.data_pckt_size;
            tcp_pckt.payload_size = param.data_pckt;
            tcp_pckt.source = i;
            tcp_pckt.destination = tmp;
            tcp_pckt.gen_time = param.t;
            ue(i).tcp_data_ul = [ue(i).tcp_data_ul,tcp_pckt];
        end    
    end
    
    % Radio Resource Allocation for users associated with eNB
    if param.uldl == 0 
        lte_scheduler_ul();     
    end

end