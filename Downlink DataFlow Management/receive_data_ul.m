function receive_data_ul()  
%% Global Variables
global param;
global bs;
global wifi;
global ue;


%% UE Uplink
for i = param.ind_voice
    if isempty(ue(i).tcp_data_ul)
        continue;
    end
   if sum([ue(i).tcp_data_ul.ack] == 1)
    %Finding the destination for this received packet and adding it
    %to the appropriate queue   
    j = ue(i).tcp_data_ul(1).destination;
    ind = find([ue(i).tcp_data_ul.ack] == 1);
    ue(i).tcp_data_ul(ind).ack = 0;
    ue(j).txpckts_dl = ue(j).txpckts_dl + 1;
    IDi = ue(i).attach;
    IDj = ue(j).attach;
    key = bi2de([IDi==0,IDj==0],'left-msb');
    switch key
        case 0            
            wifi(IDi).rxbits_ul = wifi(IDi).rxbits_ul + sum([ue(i).tcp_data_ul(ind).org_size])*8;
            wifi(IDi).rxpckts_ul = wifi(IDi).rxpckts_ul + 1;
            wifi(IDj).tcp_data_dl = [ue(i).tcp_data_ul(ind), wifi(IDj).tcp_data_dl];
            wifi(IDj).txpckts_dl = wifi(IDj).txpckts_dl + sum([ue(i).tcp_data_ul.ack]);
            
        case 1
            wifi(IDi).rxbits_ul = wifi(IDi).rxbits_ul + sum([ue(i).tcp_data_ul(ind).org_size])*8;
            wifi(IDi).rxpckts_ul = wifi(IDi).rxpckts_ul + 1;
            bs.txpckts_dl = bs.txpckts_dl + sum([ue(i).tcp_data_ul.ack]);        
            bs.tcp_data_dl = [bs.tcp_data_dl, ue(i).tcp_data_ul(ind)];
            
        case 2            
            bs.rxpckts_ul = bs.rxpckts_ul + 1;
            bs.rxbits_ul = bs.rxbits_ul + sum([ue(i).tcp_data_ul(ind).org_size])*8;  
            wifi(IDj).tcp_data_dl = [ue(i).tcp_data_ul(ind), wifi(IDj).tcp_data_dl];
            wifi(IDj).txpckts_dl = wifi(IDj).txpckts_dl + sum([ue(i).tcp_data_ul.ack]);
            
        case 3
            bs.rxpckts_ul = bs.rxpckts_ul + 1;
            bs.rxbits_ul = bs.rxbits_ul + sum([ue(i).tcp_data_ul(ind).org_size])*8;  
            bs.txpckts_dl = bs.txpckts_dl + 1;        
            bs.tcp_data_dl = [bs.tcp_data_dl, ue(i).tcp_data_ul(ind)];
    end
    ue(i).tcp_data_ul(ind) = [];  
   end
end