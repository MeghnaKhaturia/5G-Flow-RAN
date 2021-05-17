function main()
%% Global Variables
global param;
global bs;
global wifi;
global ue;

%%
seed = 2;
nuser = 80;
nwifi = 10;
P = 1;
N = [0,20,40,60,80];

%% Parameters
rng(seed);
param.policy = P; % '1' for 5G Flow network policy and '2' for core network policy for user association

% Defining System Parameters
param.ISD = 500; % Urban Macro ISD (in meters)
param.wifirange = 40; % Coverage Range of Wi-Fi (in meters)
param.nUEs = nuser; % Number of users
param.nWiFi = nwifi; % Number of Wi-Fi APs in Urban Macro cell (Maximum 10 allowed if range is 50m)
param.t = 0; % simulation time (not duration)
param.nSP = 4; % Number of service profiles

% Defining users and their parameters
temp(param.nUEs) = user;
ue = temp;
[ue, xy] = user_def(ue);

% Defining macrocell and its parameters
bs = macrocell;
bs = gnb_def(bs,param);

% Defining Wi-Fi APs and their parameters
clear temp;
temp(param.nWiFi) = wifi_aps;
wifi = temp;
wifi = wifi_def(wifi,xy);

%% Application Parameters
% Service type for each user
ind = randperm(param.nUEs);

%N = param.nUEs/4;
for i = 1:param.nSP
    [ue(ind(N(i)+1:N(i+1))).service_type] = deal(i); % Denotes mission critical streaming
end

% Data Generation rate for user
param.lambda = 500*ones(1,param.nUEs); % packets/sec (rate is same for all UEs)

% Data Size: 1000 bytes
% Header: TCP + IP + LTE, with a preamble of sizes, 20+20+20
param.data_pckt_size = 1060; %bytes
param.data_pckt = 1000;

% TCP parameters
param.cwnd = ones(1,param.nUEs);
param.ssthresh = 32*ones(1,param.nUEs);
param.sum_ack = zeros(1,param.nUEs);



%% User Association    
user_association(); % 0 for bs, 1 for Wi-fi 1
                                   % 2 for Wi-Fi 2 and so on.
%xx = find([ue.attach]==0);
%% Starting Simulation
sim_time = 1000; % in ms
k = sim_time/100; % for progress evaluation
k0 = k; % for progress evaluation
param.slot_sim = 0.001/4;%in seconds
for t = 0:0.25:sim_time 
    %[ue.count] = deal(1);
    param.t = t;
    
    % Monitoring Progress
    if param.t == k 
        clc;
        fprintf("Number of Users: %d\n",param.nUEs);
        fprintf("Number of Wi-Fi APs: %d\n",param.nWiFi);
        fprintf("Seed: %d\n",seed);
        fprintf("\n \n Progress: %3d %%",k/k0);
        k = k + k0;
    end   
%      if param.t == k 
%          fprintf("-");
%          k = k + k0;
%      end    
    
    receive_data_dl(); % Receive Data 
    send_data_dl();

end



%% Plot
figure(1);
pos = [ue.pos]';
plot(pos(:,1), pos(:,2), '+b');
hold on;
L = 500;
l = param.wifirange;
plot((L)/2,(L)/2, 'ok','MarkerSize',5);
plot(xy(:,1), xy(:,2), '^r','MarkerFaceColor','red');
labels = cellstr(num2str((1:param.nWiFi)'));
%labels_usr = cellstr(num2str([1:param.nUEs]'));
text(xy(:,1), xy(:,2), labels, 'VerticalAlignment','bottom','HorizontalAlignment','right');
%text(pos(:,1), pos(:,2), labels_usr, 'VerticalAlignment','bottom','HorizontalAlignment','right');
th = 0:pi/50:2*pi;
for i=1:param.nWiFi
    xunit = (l)*cos(th) + xy(i,1);
    yunit = (l)*sin(th) + xy(i,2);
    plot(xunit, yunit, '-k');
end
xunit = (L/2)*cos(th) + (L/2);
yunit = (L/2)*sin(th) + (L/2);
plot(xunit, yunit, '-k');
axis square;
axis([0 L 0 L]);
hold off;
drawnow;
% saveas(gcf,['results/ex_' num2str(seed) '_' num2str(param.nUEs) '_' num2str(param.nWiFi) '.jpg']);

%% Results

clc
if param.policy == 1
    fprintf('5G-Flow Network - %d users, %d Wi-Fi APs,  %d\n \n', param.nUEs, param.nWiFi, seed);
else
    fprintf('5G Network - %d users, %d Wi-Fi APs, %d \n \n', param.nUEs, param.nWiFi, seed);
end
fprintf('User service profile (1,2,3,4) - %d, %d, %d, %d \n \n', N(2), N(3)-N(2), N(4)-N(3), N(5)-N(4));
for i = 1:param.nUEs
    fprintf('User %d \n',i);
    fprintf('Transmitted Packets: %d \n', [ue(i).txpckts_dl]);
    fprintf('Received Packets: %d \n', [ue(i).rxpckts_dl]);
    fprintf('Datarate: %.3f Mbps \n', [ue(i).rxbits_dl]/(sim_time*0.001*1e6));
    fprintf('Avg. Packet Delay: %.3f ms\n \n \n', [ue(i).delay_dl]/[ue(i).rxpckts_dl]);
end

txbits = sum([bs.txbits_dl,wifi.txbits_dl])/1e6;
gnb_txthrpt = sum([bs.txbits_dl])/1e6;
wifi_txthrpt = sum([wifi.txbits_dl])/1e6;
ue_rxthrpt = sum([ue.rxbits_dl])/1e6;
delay = mean([ue.delay_dl]./([ue.rxpckts_dl]+0.00001));
ue_bs_attach = sum([ue.attach]==0);
fprintf('************************DOWNLINK******************** \n');
fprintf('Total Transmitted Throughput: %.2f Mbps\n', txbits);
fprintf('gNB Transmitted Throughput: %.2f Mbps\n', gnb_txthrpt);
fprintf('Wi-Fi Transmitted Throughput: %.2f Mbps\n', wifi_txthrpt);
fprintf('Total Received Throughput: %.2f Mbps\n \n', ue_rxthrpt);
fprintf('Avg. Packet Delay: %.2f ms\n \n',delay);

% Service Priority 
for i = 1:param.nSP
    rxthrpt_pr(i) = sum([ue(ind(N(i)+1:N(i+1))).rxbits_dl])/1e6;
    delay_pr(i) = mean([ue(ind(N(i)+1:N(i+1))).delay_dl]./([ue(ind(N(i)+1:N(i+1))).rxpckts_dl]+0.00001));
    fprintf('Priority %d \n', i);
    fprintf('Throughput: %.2f Mbps\n', rxthrpt_pr(i));
    fprintf('Delay: %.2f ms\n \n', delay_pr(i));
end

%% To store the results in file
% if param.policy == 2
%     str = sprintf('results/5g_%dU_%dW_%d_%d_%d_%d.csv',param.nUEs,...
%         param.nWiFi,N(2)-N(1), N(3)-N(2),N(4)-N(3),N(5)-N(4));
% else
%     str = sprintf('results/5gflow_%dU_%dW_%d_%d_%d_%d.csv',param.nUEs,...
%         param.nWiFi,N(2)-N(1),N(3)- N(2),N(4)-N(3),N(5)-N(4));
% end
% fileID = fopen(str,'a');
% fprintf(fileID,"\n %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d",...
%     seed, txbits, gnb_txthrpt, wifi_txthrpt,ue_rxthrpt, delay,...
%     rxthrpt_pr(1),rxthrpt_pr(2),rxthrpt_pr(3),rxthrpt_pr(4),...
%     delay_pr(1), delay_pr(2),delay_pr(3),delay_pr(4),ue_bs_attach);
% fclose(fileID);

end
%toc
