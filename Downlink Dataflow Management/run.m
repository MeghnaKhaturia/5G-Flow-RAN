%% Global Variables
clear all;
clc;
tic;
global param;
global bs;
global wifi;
global ue;

%% Running Simulation
nuser = 80; % Number of users
nwifi = 10;
N = [0,10,20,50,80;
    0,30,60,70,80;
    0,40,80,80,80];

policy = [1,2];

parfor i = 1:6  
    M = N(ceil(i/2),:);
    P = policy(mod(i,2)+1);
    for seed = 1:50
        % Simulation Progress
        %clc;        
        if P == 1
            fprintf('\n 5G-Flow Network \n');
        else
            fprintf('\n 5G Network \n');
        end
        fprintf('User service profile (1,2,3,4) - %d, %d, %d, %d \n \n', M(2), M(3)-M(2), M(4)-M(3), M(5)-M(4));
        fprintf("[%d,%d,%d,%d]\n", P, seed, 80, 10);
        fprintf("Progress: %3d %%\n",(seed-1)*2);
        
        % Run simulation
        main(seed,nuser,nwifi,P,M);
        param = []; bs = []; wifi = []; ue =[];            
    end
end
tot_time = toc;