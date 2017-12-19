% Script 
clear all;
clc;
%loading the image..

I_left = imread('../data/part1/uttower/left.jpg');
I_right = imread('../data/part1/uttower/right.jpg');
leftImg = I_left;
rightImg = I_right;

% converting to gray scale
I_left = rgb2gray(I_left);
I_right = rgb2gray(I_right);

I_left = im2double(I_left);
I_right = im2double(I_right);

%padding the image inorder to pick 21 neighbours
padding = 10;


%detecting corners for both the images
[cim_l, r_l, c_l] = harris(I_left, 1, 0.05, 1, 0);
[cim_r, r_r, c_r] = harris(I_right, 1, 0.05 , 1, 0);

%displaying corners in both the images
figure; imshow([I_left I_right]); 
   hold on; title('Corners generated via Harris Detector');
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
 matches = distance(1:threshHold);
[row, col] = ind2sub(size(n), matches);


%picking the matched coordinates from corresponding images
%row for left image
%col for right image
match_r_l = r_l(row);
match_c_l = c_l(row);
match_r_r = r_r(col);
match_c_r = c_r(col);



%plotting the matches
figure; imshow([I_left I_right]); 
hold on; title('Features Matched');
hold on; plot(match_c_l, match_r_l,'ys');plot(match_c_r + 1024, match_r_r, 'ys'); 
%forming the homogenous coordinates
left_coord = [match_c_l,match_r_l,ones(size(match_r_l,1),1)];
right_coord = [match_c_r,match_r_r,ones(size(match_r_r,1),1)];

final_homography = zeros(3,3);
final_ratio = 0;
final_inliers = 0;
final_residuals = [];
noOfIterations = size(col,1);
finalInlierMatches = [];
for i =0:1:noOfIterations*4

   X = generate_homography(left_coord,right_coord);
    
    
   [ratio,noOfInliers,storedSsdData,InlierMatches] = estimateInliers(X,left_coord,right_coord,noOfIterations);
    if final_ratio < ratio
        final_homography = X;
        final_ratio = ratio;
        final_inliers = noOfInliers;
        final_residuals = storedSsdData;
        finalInlierMatches = InlierMatches;
    end
    
end

final_homography =  final_homography ./ final_homography(3,3);
disp('The average residuals for the inliers is:');
disp(sum(final_residuals(:)) / size(final_residuals,1));



  plot_x = [finalInlierMatches(:,2), finalInlierMatches(:,4)];
  plot_y = [finalInlierMatches(:,1), finalInlierMatches(:,3) +  size(I_left,2)];
  figure; imshow([I_left I_right]); hold on; title('Final Inliers Detected ');
  hold on; 
  plot(finalInlierMatches(:,1), finalInlierMatches(:,2),'ys');          
  plot(finalInlierMatches(:,3) + 1024, finalInlierMatches(:,4), 'ys');
  for i = 1:size(finalInlierMatches,1)             
      plot(plot_y(i,:), plot_x(i,:));
 end

stitchImages(final_homography,I_left,I_right,leftImg,rightImg);

