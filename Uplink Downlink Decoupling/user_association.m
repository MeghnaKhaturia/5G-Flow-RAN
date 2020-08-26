function user_association()
global ue;
global param;
global wifi;
global bs;

    % RAT Admission
    %% Downlink User Association
    [ue.attach] = deal(0); % All UEs are attached to gNB
    [ue.attach_ul] = deal(0);
    for i = 1:param.nWiFi
        ind = dist([wifi(i).pos]',[ue.pos])<param.wifirange;
        [ue(ind).attach] = deal(i);
        [ue(ind).attach_ul] = deal(i);
    end 
%    only_gnb_range_users = find([ue.attach]==0);
%     capacity_gnb = 30-length(only_gnb_range_users);
%     if param.policy == 1
%         for i = 1:param.nUEs
%             ue(i).snr_dl = snr_macro(bs,ue(i),1);
%             if ue(i).snr_dl > 30 && capacity_gnb >=0
%                 ue(i).attach = 0;
%                 ue(i).attach_ul = 0;
%                 capacity_gnb = capacity_gnb - 1;
%             end
%         end
%     end
    
    param.attach = cell(1,param.nWiFi);
    for i = 0:param.nWiFi
        param.attach(i+1) = {find([ue.attach] == i)};
    end
    
    %% Uplink user association
    only_gnb_range_users = find([ue.attach]==0);
    capacity_gnb = 38 - length(only_gnb_range_users); % Uplink capacity for gnb (55 Mbps)
    [~,ind_wifi] = sort(histc([ue.attach],[1:param.nWiFi]),'descend');

    for i = ind_wifi
        tmp = cell2mat(param.attach(i+1));
        if length(tmp)<=3
            continue;
        end
        [~,ind] = sort(dist([bs.pos],[ue(tmp).pos]));
        len = min(length(tmp)-3,capacity_gnb);
        [ue(tmp(ind(1:len))).attach_ul] = deal(0);
        capacity_gnb = capacity_gnb - len;
        if capacity_gnb<=0
            break;
        end
    end
    [~,ind] = sort(dist([bs.pos],[ue.pos]));
    ind(ismember(ind,find([ue.attach_ul]==0))) = [];
    [ue(ind(1:capacity_gnb)).attach_ul] = deal(0);  
    
     param.attach_ul = cell(1,param.nWiFi);
    for i = 0:param.nWiFi
        param.attach_ul(i+1) = {find([ue.attach_ul] == i)};
    end
    %%
    % RAT Scheduling
%     if param.policy == 1
%         capacity_5G = 44-sum([ue.attach]==0); % in terms of number of users with 4Mbps load
%         capacity_wifi(1:param.nWiFi) = 10; % in terms of number of users with 4Mbps load
%         load_5G = 1; % 1 denotes low load
%         load_wifi = ones(1,param.nWiFi); % 1 denotes low load
%         chan_5G = 1;
%         for j = 1:param.nSP
%             for i = find([ue.service_type] == j)
%                 ue(i).snr_dl = snr_macro(bs,ue(i),1);
%                 if ue(i).snr_dl < 6
%                     chan_5G = 2;
%                 end
%                 if ue(i).attach > 0
%                     tmp = load_5G*10 - load_wifi(ue(i).attach)*10 ...
%                         + ue(i).service_type*10;
%                     if tmp <= 30
%                         ue(i).attach = 0;
%                         capacity_5G = capacity_5G - 1;
%                         load_5G(capacity_5G <= 20) = 2;
%                         load_5G(capacity_5G <= 0) = 5; 
%                     else
%                         capacity_wifi(ue(i).attach) = capacity_wifi(ue(i).attach) - 1;
%                         load_wifi(capacity_wifi<=3) = 2;
%                     end
%                 end        
%                 chan_5G = 1;
%             end
%         end 
%     else
%         for i = 1:param.nUEs
%             if ue(i).attach>0 && (ue(i).service_type == 1 || ue(i).service_type == 2) 
%                 ue(i).attach = 0;
%             end
%         end
%     end
%     
%     param.attach = cell(1,N_wifi);
%     for i = 0:N_wifi
%         param.attach(i+1) = {find([ue.attach] == i)};
%     end
          
end