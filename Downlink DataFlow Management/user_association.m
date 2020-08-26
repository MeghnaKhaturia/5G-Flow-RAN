function user_association()
global ue;
global param;
global wifi;
global bs;

    % RAT Admission
    N_wifi = size(wifi,2);
    [ue.attach] = deal(0); % All UEs are attached to gNB
    for i = 1:N_wifi
        ind = dist([wifi(i).pos]',[ue.pos])<param.wifirange;
        [ue(ind).attach] = deal(i);
    end    
    
    % RAT Scheduling
    if param.policy == 1
        capacity_5G = 45-sum([ue.attach]==0); % in terms of number of users with 4Mbps load
        capacity_wifi(1:param.nWiFi) = 10; % in terms of number of users with 4Mbps load
        load_5G = 1; % 1 denotes low load
        load_wifi = ones(1,param.nWiFi); % 1 denotes low load
        chan_5G = 1;
        for j = 1:param.nSP
            for i = find([ue.service_type] == j)
                ue(i).snr_dl = snr_macro(bs,ue(i),1);
                if ue(i).snr_dl < 6
                    chan_5G = 2;
                end
                if ue(i).attach > 0               
                    tmp = load_5G*10 - load_wifi(ue(i).attach)*10 ...
                        + ue(i).service_type*5 + 30*(chan_5G-1);
                    if tmp <= 30
                        ue(i).attach = 0;
                        capacity_5G = capacity_5G - 1;
                        load_5G(capacity_5G <= 20) = 2;
                        load_5G(capacity_5G <= 0) = 1000; 
                    else
                        capacity_wifi(ue(i).attach) = capacity_wifi(ue(i).attach) - 1;
                        load_wifi(capacity_wifi<=3) = 2;
                    end
                end        
                chan_5G = 1;
            end
        end 
    else
        for i = 1:param.nUEs
            if ue(i).attach>0 && (ue(i).service_type == 1 || ue(i).service_type == 2) 
                ue(i).attach = 0;
            end
        end
    end
    
    param.attach = cell(1,N_wifi);
    for i = 0:N_wifi
        param.attach(i+1) = {find([ue.attach] == i)};
    end
end