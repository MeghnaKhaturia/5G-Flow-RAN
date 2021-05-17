function send_data_ul()
global ue;
global param;
global bs;

    l = param.nCalls;
    % Checking Application buffer for data
    if ~mod(param.t,20)        
        for i = param.ind_voice
            ue(i).txpckts_ul = ue(i).txpckts_ul + 1;
            ind = find(param.ind_voice==i);
            if ind > param.nCalls
                l = -param.nCalls;
            end            
            tcp_pckt = packet;
            tcp_pckt.type = 1; % 1 represents voice data type
            tcp_pckt.org_size = param.voice_pckt_size;
            tcp_pckt.size = param.voice_pckt_size;
            tcp_pckt.payload_size = param.voice_data;
            tcp_pckt.source = i;
            tcp_pckt.destination = param.ind_voice(ind + l);
            tcp_pckt.gen_time = param.t;
            ue(i).tcp_data_ul = [ue(i).tcp_data_ul,tcp_pckt];
        end
    end    
    
    % Radio Resource Allocation for users associated with eNB
    ue = lte_scheduler_ul(bs,ue);     

end