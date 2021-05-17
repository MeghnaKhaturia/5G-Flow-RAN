function rate = snr_2_rate_wifi(wifi,rss)
    % Cisco Aironet 1570 Series (outdoor wifi) (802.11n, 2.4 GHz)
    %SS = wifi.spatialstream; % Spatial Stream
    B = wifi.Bandwidth; % in MHz
    GI = wifi.GI; % 1 for 800ns and 2 for 400 ns guard interval

    ReferenceRSS = [ -94, -93, -91, -88, -85, -80, -79, -78];
    Rate = [6.5, 13, 19.5, 26, 39, 52, 58.5, 65;
    7.2, 14.4, 21.7, 28.9, 43.3, 57.8, 65, 72.2];

    ind = find(ReferenceRSS < rss);
    if isempty(ind)
        rate = 0;
        return;
    end
    rate = Rate(GI, ind(end));

end