function ransac_F(I1,I2)
   %ransac method
    [F,matches] = fit_fundamental_ransac(I1,I2);
    
    N = size(matches,1);
   
    
    L = ((F) * [matches(:,1:2) ones(N,1)]')'; % transform points from 
    % the first image to get epipolar lines in the second image

    % find points on epipolar lines L closest to matches(:,3:4)
    L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3); % rescale the line
    pt_line_dist = sum(L .* [matches(:,3:4) ones(N,1)],2);
    closest_pt = matches(:,3:4) - L(:,1:2) .* repmat(pt_line_dist, 1, 2);

    residual_distances = sum(sum((closest_pt - matches(:,3:4)).^2))/size(matches,1);


    disp('the average residual distance of closest point to epipolar line is');
    disp(residual_distances);
    % find endpoints of segment on epipolar line (for display purposes)
    pt1 = closest_pt - [L(:,2) -L(:,1)] * 10; % offset from the closest point is 10 pixels
    pt2 = closest_pt + [L(:,2) -L(:,1)] * 10;

    % display points and segments of corresponding epipolar lines
    clf;
    imshow(I2); hold on;
    plot(matches(:,3), matches(:,4), '+r');
    line([matches(:,3) closest_pt(:,1)]', [matches(:,4) closest_pt(:,2)]', 'Color', 'r');
    line([pt1(:,1) pt2(:,1)]', [pt1(:,2) pt2(:,2)]', 'Color', 'g');


    L = (F' * [matches(:,3:4) ones(N,1)]')'; % transform points from 
    % the first image to get epipolar lines in the second image

    % find points on epipolar lines L closest to matches(:,3:4)
    L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3); % rescale the line
    pt_line_dist = sum(L .* [matches(:,1:2) ones(N,1)],2);
    closest_pt = matches(:,1:2) - L(:,1:2) .* repmat(pt_line_dist, 1, 2);

    residual_distancesB = sum(sum((closest_pt - matches(:,1:2)).^2))/size(matches,1);


    disp('the average residual distance of closest point to epipolar line is');
    disp(residual_distancesB);

    % find endpoints of segment on epipolar line (for display purposes)
    pt1 = closest_pt - [L(:,2) -L(:,1)] * 10; % offset from the closest point is 10 pixels
    pt2 = closest_pt + [L(:,2) -L(:,1)] * 10;
    clf;
    imshow(I1); hold on;
    plot(matches(:,1), matches(:,2), '+r');
    line([matches(:,1) closest_pt(:,1)]', [matches(:,2) closest_pt(:,2)]', 'Color', 'r');
    line([pt1(:,1) pt2(:,1)]', [pt1(:,2) pt2(:,2)]', 'Color', 'g');
end