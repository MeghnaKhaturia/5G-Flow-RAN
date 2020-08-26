function receive_data_dl()  
%% Global Variables
global param;
global bs;
global wifi;
global ue;

%% LTE Downlink
ind_attach = cell2mat(param.attach(1));
if ~mod(param.t,0.5) && (param.t ~= 0)
    for i = ind_attach
%         if isempty(bs.tcp_data_dl)
%             continue;
%         end
        ind  = find([bs.tcp_data_dl.ack] == 1 & [bs.tcp_data_dl.destination] == i);
        if isempty(ind)
            continue;
        end 
        ue(i).rxbits_dl = ue(i).rxbits_dl + sum([bs.tcp_data_dl(ind).payload_size])*8;
        ue(i).rxpckts_dl = ue(i).rxpckts_dl + length(ind);
        ue(i).tcp_data_dl = [ue(i).tcp_data_dl, bs.tcp_data_dl(ind)];
        ue(i).delay_dl = ue(i).delay_dl + sum(param.t - [bs.tcp_data_dl(ind).gen_time]);
        bs.tcp_data_dl(ind) = [];          
    end
end

%% Wi-Fi Downlink
for i = 1:param.nWiFi
    if param.t > wifi(i).tx_time
        ind_attach = cell2mat(param.attach(i+1));
        for j = ind_attach
            if isempty(wifi(i).tcp_data_dl)
                continue;
            end
            ind  = find([wifi(i).tcp_data_dl.ack] == 1 & [wifi(i).tcp_data_dl.destination] == j);
            if isempty(ind)
                continue;
            end 
            ue(j).rxbits_dl = ue(j).rxbits_dl + sum([wifi(i).tcp_data_dl(ind).payload_size])*8;
            ue(j).rxpckts_dl = ue(j).rxpckts_dl + length(ind);
            ue(j).tcp_data_dl = [ue(j).tcp_data_dl, wifi(i).tcp_data_dl(ind)];
            ue(j).delay_dl = ue(j).delay_dl + sum(param.t - [wifi(i).tcp_data_dl(ind).gen_time]);
            wifi(i).tcp_data_dl(ind) = [];
        end
    end
end

%% Updating TCP parameters

for i = 1:param.nUEs   
    if ~isempty([bs.tcp_data_dl]) && ~mod(param.t,0.5)
        ind = find([bs.tcp_data_dl.destination] == i);
        if sum([bs.tcp_data_dl(ind).lost])
            param.cwnd(i) = 1;
            param.ssthresh(i) = max(1,param.ssthresh(i)/2);
            [bs.tcp_data_dl(ind).lost] = deal(0);
            bs.tcp_data = [bs.tcp_data_dl(ind(2:end)), bs.tcp_data];
            param.sum_ack(i) = 0;
            bs.tcp_data_dl(ind(2:end)) = [];
            continue;
        end
    end
    if ~isempty(ue(i).tcp_data_dl)       
        if sum([ue(i).tcp_data_dl.ack] == 1)        
            ind = find([ue(i).tcp_data_dl.ack] == 1);      
            param.sum_ack(i) = param.sum_ack(i) + length(ind);
            if param.sum_ack(i) >= param.cwnd(i)
                if param.cwnd(i) < param.ssthresh(i)
                    param.sum_ack(i) = param.sum_ack(i) - param.cwnd(i);
                    param.cwnd(i) = param.cwnd(i) + param.cwnd(i);                
                else
                    param.sum_ack(i) = param.sum_ack(i) - param.cwnd(i);
                    param.cwnd(i) = param.cwnd(i) + 1;                
                end
            end        
            ue(i).tcp_data_dl(ind) = [];
        end
    end
end
end
