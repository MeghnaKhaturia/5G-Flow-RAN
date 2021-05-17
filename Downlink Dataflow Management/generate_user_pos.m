function [pos, XY] = generate_user_pos()
    global param;
    %%
    L = param.ISD;
    l = param.wifirange;
    N = param.nUEs;
    n = param.nWiFi;
    
    %% Wi-Fi position
    XY = zeros(2,n);
    nWant = length(XY);
    R = 2*l; % Minimum distance between two Wi-Fi APs based on Wi-Fi Range
    dist_2  = R^2;  % Squared once instead of SQRT each time    
    iLoop   = 1;      % Security break to yoid infinite loop
    nValid  = 0;
    while nValid < nWant && iLoop < 1e6
        newXY = L*(rand(2,1));
        if all(sum((XY(:,1:nValid) - newXY).^2) > dist_2) && (sum((newXY - [L/2;L/2]).^2) < ((L-2*l)/2)^2)
            % Success: The new point does not touch existing points:
            nValid    = nValid + 1;  % Append this point
            XY(:,nValid) = newXY;
        end
        iLoop = iLoop + 1;
    end
    % An error is safer than a warning:
    if nValid < nWant
        error('Cannot find wanted number of points in %d iterations.', iLoop)
    end
    
    %% User position
    pos = [];
    tot_usrs = floor(0.8*param.nUEs); %dually connected users
    tmp = partitions(tot_usrs/2,[1,1,1,1,1],8);
    tmp(sum(tmp == 0,2)>=1,:) = [];
    uu = tmp(randi(length(tmp)),:);
    uu = [uu, uu];
    %     uu_last = mod(0.8*param.nUEs,(param.nWiFi-1));
    
    for i = 1:n
        user_per_wifi = uu(i);
        temp = l*rand(2,3*user_per_wifi)+ XY(:,i); % Position of users
        ind = sqrt(sum((temp - XY(:,i)).^2)) < l;
        temp(:,~ind) = [];
        pos = [pos, temp(:,1:user_per_wifi)];
    end
    user_per_wifi = N-length(pos);
    temp = L*rand(2,3*user_per_wifi); % Position of users
    ind = sqrt(sum((temp - [L/2;L/2]).^2)) < L/2;
    temp(:,~ind) = [];
    pos = [pos, temp(:,1:user_per_wifi)];
    
    %% Plot
%     clf;
%     figure(1);
%     plot(pos(1, :), pos(2, :), 'ok','MarkerFaceColor','black','MarkerSize',4);
%     hold on;
%     plot((L)/2,(L)/2, 'sqb','MarkerSize',8,'MarkerFaceColor','blue');
%     plot(XY(1,:), XY(2,:), '^r','MarkerFaceColor','red');
%     labels = cellstr(num2str([1:param.nWiFi]'));
%     labels_usr = cellstr(num2str([1:param.nUEs]'));
%     %text(XY(1,:), XY(2,:), labels, 'VerticalAlignment','bottom','HorizontalAlignment','right');
%     %text(pos(1,:), pos(2,:), labels_usr, 'VerticalAlignment','bottom','HorizontalAlignment','right');
%     th = 0:pi/50:2*pi;
%     for i=1:param.nWiFi
%         xunit = (l)*cos(th) + XY(1,i);
%         yunit = (l)*sin(th) + XY(2,i);
%         plot(xunit, yunit, '-k');
%     end
%     xunit = (L/2)*cos(th) + (L/2);
%     yunit = (L/2)*sin(th) + (L/2);
%     plot(xunit, yunit, '-k');
%     axis square;
%     axis([0 L 0 L]);
%     legend('UEs','gNB','Wi-Fi APs')
%     ax = gca;
%     ax.Visible = 'off';
%     saveas(gcf,['results/5gflow_' num2str(23) '_' num2str(param.nUEs) '_' num2str(param.nWiFi) '.eps']);
%     hold off;
%     drawnow;
%     pause
    %%
    pos = pos';
    XY = XY';
end
