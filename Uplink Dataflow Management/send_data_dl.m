function send_data_dl()
%% Global Variables
global param;
global bs;
global wifi;
global ue;

%% Initialize tcp_data_dl and tcp_data
if param.t == 0
    tcp_pckt = packet;
    tcp_pckt.org_size = param.data_pckt_size;
    tcp_pckt.size =param.data_pckt_size;
    tcp_pckt.payload_size = param.data_pckt;
    tcp_pckt.source = 0;
    tcp_pckt.type = ue(1).service_type; 
    tcp_pckt.destination = 1;
    tcp_pckt.gen_time = param.t;
    bs.tcp_data_dl = [bs.tcp_data_dl,tcp_pckt];

    tcp_pckt = packet;
    tcp_pckt.org_size = param.data_pckt_size;
    tcp_pckt.size =param.data_pckt_size;
    tcp_pckt.payload_size = param.data_pckt;
    tcp_pckt.source = 0;
    tcp_pckt.type = ue(2).service_type; 
    tcp_pckt.destination = 2;
    tcp_pckt.gen_time = param.t;
    bs.tcp_data = [bs.tcp_data,tcp_pckt];
end
%% Downlink Data generation and buffer updation for LTE
ind = [];
ind2 = []; 
for i = cell2mat(param.attach(1)) 
    n = poissrnd(param.lambda_dl(i)*param.slot_sim); % packet generation
    bs.txpckts_dl = bs.txpckts_dl + n;
    ue(i).txpckts_dl = ue(i).txpckts_dl + n;    
    for j = 1:n
        tcp_pckt = packet;
        tcp_pckt.org_size = param.data_pckt_size;
        tcp_pckt.size =param.data_pckt_size;
        tcp_pckt.payload_size = param.data_pckt;
        tcp_pckt.source = 0;
        %tcp_pckt.type = ue(i).service_type; 
        tcp_pckt.destination = i;
        tcp_pckt.gen_time = param.t;
        bs.tcp_data = [bs.tcp_data,tcp_pckt];
    end      
    % Check if the transmit queue at BS is empty or not and then calculate
    % the number of packets already in queue for UE i
    ind = find(ismember([bs.tcp_data_dl.destination], i));
    len = param.cwnd(i) - length(ind);
    % Check if the Application queue has any packet for UE i     
    ind2 = find(ismember([bs.tcp_data.destination], i));
    if ~isempty(ind2)
        len = min(len,length(ind2));
        bs.tcp_data_dl = [bs.tcp_data_dl, bs.tcp_data(ind2(1:len))];
        bs.tcp_data(ind2(1:len)) = [];                   
    end    
end


%% Data generation and buffer updation for Wi-Fi 
% (Initially the buffer at Middle mile AP will be updated)
for k = 1:param.nWiFi
    for i = cell2mat(param.attach(k+1))
        n = poissrnd(param.lambda_dl(i)*param.slot_sim); % packet generation
        wifi(k).txpckts_dl = wifi(k).txpckts_dl + n;
        ue(i).txpckts_dl = ue(i).txpckts_dl + n;
        for j = 1:n
            tcp_pckt = packet;
            tcp_pckt.org_size = param.data_pckt_size;
            tcp_pckt.size = param.data_pckt_size;
            tcp_pckt.payload_size = param.data_pckt;
            tcp_pckt.type = ue(i).service_type; 
            tcp_pckt.source = 0;
            tcp_pckt.destination = i;
            tcp_pckt.gen_time = param.t;
            wifi(k).tcp_data = [wifi(k).tcp_data,tcp_pckt]; % buffer of kth middle mile client will be updated
        end     
        % Check if the transmit queue at BS is empty or not and then calculate
        % the number of packets already in queue for UE i
        if ~isempty([wifi(k).tcp_data_dl])
            ind = find([wifi(k).tcp_data_dl.destination] == i);
        end
        len = param.cwnd(i) - length(ind);
        % Check if the Application queue has any packet for UE i
        if ~isempty([wifi(k).tcp_data])       
            ind2 = find([wifi(k).tcp_data.destination] == i);
            if ~isempty(ind2)
                len = min(len,length(ind2));
                wifi(k).tcp_data_dl = [wifi(k).tcp_data_dl, wifi(k).tcp_data(ind2(1:len))];
                wifi(k).tcp_data(ind2(1:len)) = [];            
            end    
        end
    end
end
%% Scheduling     
    % Radio Resource Allocation for users associated with eNB
    if param.uldl == 1
        gnb_scheduler_dl();
    end
          
    % Wi-Fi schedule    
    for i = 1:param.nWiFi
        if param.t >= wifi(i).tx_time
            wifi_scheduler(i);             
        end
    end         
    
end