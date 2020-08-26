function [ue,xy] = user_def(ue)
    % User Position   
    N = size(ue,2);
    pos = zeros(N,2);
    [pos, xy] = generate_user_pos();
    for i = 1:N
        ue(i).ID = i;
        ue(i).pos = pos(i,:)'; %in meters        
    end
    
    % Device Parameters (3GPP TR 36.931)
    [ue.rxsensitivity] = deal(-94); % dBm (TS 36.101)
    [ue.mobility] = deal(0); % 0 for stationary, 1 for mobile
    [ue.txpow] = deal(23); % in dBm (Power Class 3)
    [ue.txpow_wifi] = deal(15); % in dBm
    [ue.height] = deal(1.5); % in meters
    [ue.rxAntGain] = deal(2); % in dBi   (ericcson)
    [ue.txAntGain] = deal(2); % in dBi  (ericcson)
    
    % Analysis parameters
    
    [ue.rxbits_dl] = deal(0);
    [ue.txbits_dl] = deal(0);
    [ue.rxpckts_dl] = deal(0);
    [ue.txpckts_dl] = deal(0);
    [ue.rxbits_ul] = deal(0);
    [ue.txbits_ul] = deal(0);
    [ue.rxpckts_ul] = deal(0);
    [ue.txpckts_ul] = deal(0);
    [ue.delay_dl] = deal(0);
end