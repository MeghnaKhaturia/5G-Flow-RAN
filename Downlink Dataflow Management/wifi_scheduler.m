function time_to_send  = wifi_scheduler(ID) 
%% Global Variables
global param;
global wifi;
global ue;
p = rand(1) < 1e-4; % packet loss
time_to_send = 0;
%%
     if isempty(cell2mat(param.attach(ID+1)))         
         return;
     end
    % Finding UEs attached to Wi-Fi     
    ind_nodes = [0 cell2mat(param.attach(ID+1))];
    
    % Finding UEs that are contending
    contending_UE = [];
    if ~isempty(wifi(ID).tcp_data_dl)
        contending_UE = [contending_UE,0];
    end
    for i = ind_nodes(2:end)
        if ~isempty(ue(i).tcp_data_ul)
            contending_UE = [contending_UE,i];
        end
    end
    
    if isempty(contending_UE)
        return;
    end

    % Find the UE/Wi-Fi has access to wireless channel
    Node0 = contending_UE(randi(length(contending_UE)));  
    
     
    % If Node0 = 0, then Wi-Fi has access to the channel
    if Node0 == 0 
        UE0 = [wifi(ID).tcp_data_dl(1).destination];
        rss = snr_wifi(wifi(ID),ue(UE0),1);
        rate = snr_2_rate_wifi(wifi(ID),rss);
        if rate == 0
            time_to_send = 0.05;
            return;
        end
        ind = find([wifi(ID).tcp_data_dl.destination] == UE0);
        data_to_send = 8*min(1500, sum([wifi(ID).tcp_data_dl(ind).size]));
        time_to_send = data_to_send/(rate*1e3) + (randi(10)*0.02 + 0.034); % in ms
        wifi(ID).tx_time = param.t + time_to_send;
       
        for j = ind           
            if data_to_send > 0 && [wifi(ID).tcp_data_dl(j).ack] == 0
                pckt_size = wifi(ID).tcp_data_dl(j).size;
                if data_to_send >= pckt_size*8      
                    wifi(ID).txbits_dl = wifi(ID).txbits_dl + pckt_size*8;
                    wifi(ID).tcp_data_dl(j).ack = 1-p;
                    wifi(ID).tcp_data_dl(j).lost = p;
                    data_to_send = data_to_send - pckt_size*8;
                else                   
                    wifi(ID).txbits_dl = wifi(ID).txbits_dl + data_to_send;
                    wifi(ID).tcp_data_dl(j).size = ...
                        wifi(ID).tcp_data_dl(j).size - (1-p)*floor(data_to_send/8);
                    data_to_send = 0;
                end
                ue(UE0).packet_loss = ue(UE0).packet_loss + p;
            end  
        end           
    else         
        rss = snr_wifi(wifi(ID),ue(Node0),0);
        rate = snr_2_rate_wifi(wifi(ID),rss);
        if rate == 0
            time_to_send = 0.05;
            return;
        end
        data_to_send = 8*min(1500, sum([ue(Node0).tcp_data_ul.size]));
        time_to_send = data_to_send/(rate*1e3) + (randi(10)*0.02 + 0.06); % in ms
        wifi(ID).tx_time = param.t + time_to_send;

        for j = find([ue(Node0).tcp_data_ul.ack]==0)
            if data_to_send > 0 
                pckt_size = ue(Node0).tcp_data_ul(j).size;
                if data_to_send >= pckt_size*8      
                    ue(Node0).txbits_ul = ue(Node0).txbits_ul + pckt_size*8;
                    ue(Node0).tcp_data_ul(j).ack = 1-p; 
                    ue(Node0).tcp_data_ul(j).lost = p; 
                    data_to_send = data_to_send - pckt_size*8;
                else                   
                    ue(Node0).txbits_ul = ue(Node0).txbits_ul + data_to_send;
                    ue(Node0).tcp_data_ul(j).size = ...
                        ue(Node0).tcp_data_ul(j).size - (1-p)*floor(data_to_send/8);
                    data_to_send = 0;
                end
                ue(Node0).packet_loss = ue(Node0).packet_loss + p;
            end  
        end           
    end

end
   
    