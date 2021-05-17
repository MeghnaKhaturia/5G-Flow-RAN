%% Global Variables
clear all;
clc;
tic;
global param;
global bs;
global wifi;
global ue;

%% Running Simulation
nwifi = 10;
nuser = 80;
% str = sprintf('results/5g_%dU_%dW_20_20_20_20.csv',80,10);
% fileID = fopen(str,'a');
% fprintf(fileID,"seed, Phy Thrpt, gNB Tx Thrpt, Wifi Tx Thrpt, App Thrpt, Delay, PR1 Thrpt, PR2 Thrpt, PR3 Thrpt, PR4 Thrpt, PR1 delay, PR2 delay, PR3 delay, PR4 delay");
% fclose(fileID);

for seed = 1:50            
    % Run simulation
    main(seed,nwifi,nuser);
    param = []; bs = []; wifi = []; ue =[];            
end

tot_time = toc;