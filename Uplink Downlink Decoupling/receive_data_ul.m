function receive_data_ul()  
%% Global Variables
global param;
global bs;
global wifi;
global ue;


%% UE Uplink
if ~mod(param.t,0.5)
    for i = 1:param.nUEs
        if isempty(ue(i).tcp_data_ul)
            continue;
        end
        if sum([ue(i).tcp_data_ul.ack] == 1)
            %Finding the destination for this received packet and adding it
            %to the appropriate queue   
            ind = find([ue(i).tcp_data_ul.ack] == 1);
            [ue(i).tcp_data_ul(ind).ack] = deal(0);    
            ID = ue(i).tcp_data_ul(ind(1)).destination; 
            if ID == 0
                bs.rxpckts_ul = bs.rxpckts_ul + length(ind);
                bs.rxbits_ul = bs.rxbits_ul + sum([ue(i).tcp_data_ul(ind).payload_size])*8;  
                bs.delay_ul = bs.delay_ul + sum(param.t - [ue(i).tcp_data_ul(ind).gen_time]);
            else   
                wifi(ID).rxbits_ul = wifi(ID).rxbits_ul + sum([ue(i).tcp_data_ul(ind).payload_size])*8;
                wifi(ID).rxpckts_ul = wifi(ID).rxpckts_ul + length(ind); 
                wifi(ID).delay_ul = wifi(ID).delay_ul + sum(param.t - [ue(i).tcp_data_ul(ind).gen_time]);
            end        
            ue(i).tcp_data_ul(ind) = [];  
        end
    end
end