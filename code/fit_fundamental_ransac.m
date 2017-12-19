function [R,final_InlierMatches] = fit_fundamental_ransac(I1,I2)
    % converting to gray scale
    I_left = rgb2gray(I1);
    I_right = rgb2gray(I2);

    I_left = im2double(I_left);
    I_right = im2double(I_right);

    %padding the image inorder to pick 21 neighbours
    padding = 10;


    %detecting corners for both the images
    [~, r_l, c_l] = harris(I_left, 1, 0.05, 1, 0);
    [~, r_r, c_r] = harris(I_right, 1, 0.05 , 1, 0);

    %displaying corners in both the images
    figure; imshow([I_left I_right]); 
       hold on; title('corners');
      hold on; plot(c_l, r_l,'ys'); plot(c_r + size(I_left,2), r_r, 'ys'); 

    %picking the neighbourhoods


    %picking the neighbours of detected corners from both the images
    features_neigh_l= pick_feature_neighbours(I_left, r_l ,c_l,padding);
    features_neigh_r= pick_feature_neighbours(I_right, r_r ,c_r,padding);

    row = [];
    col = [];

    n = dist2(features_neigh_l,features_neigh_r);
    [~,distance] = sort(n(:), 'ascend');
    % 
    threshHold = 200;
    matches_idx = distance(1:threshHold);
    [row, col] = ind2sub(size(n), matches_idx);
    
    match_r_l = r_l(row);
    match_c_l = c_l(row);
    match_r_r = r_r(col);
    match_c_r = c_r(col);

    left_coord = [match_c_l,match_r_l,ones(size(match_r_l,1),1)];
    right_coord = [match_c_r,match_r_r,ones(size(match_r_r,1),1)];
    
    matches = [match_c_l match_r_l match_c_r match_r_r];
    
    final_Fmat = zeros(3,3);
    final_ratio = 0;
    final_inliers = 0;
    final_InlierMatches = [];
    noOfIterations = size(matches,1);
    
    for i=1:1:noOfIterations*10
        %image already normalized while calculating feature neighbors.
        Fmat = fit_fundamental(matches,0);
        [ratio,noOfInliers,InlierMatches] = estimate_F_inliers(Fmat,left_coord,right_coord,noOfIterations);
        if final_ratio < ratio
            final_Fmat = Fmat;
            final_ratio = ratio;
            final_inliers = noOfInliers;
            final_InlierMatches = InlierMatches;
        end
    end
    R = final_Fmat;
  
end