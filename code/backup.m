% Script 
clear all;
clc;
%loading the image..
I_left = imread('../data/part1/uttower/left.jpg');
I_right = imread('../data/part1/uttower/right.jpg');

% converting to gray scale
I_left = rgb2gray(I_left);
I_right = rgb2gray(I_right);

I_left = im2double(I_left);
I_right = im2double(I_right);

%padding the image inorder to pick 21 neighbours
padding = 10;


%detecting corners for both the images
[cim_l, r_l, c_l] = harris(I_left, 1, 0.01, 1, 0);
[cim_r, r_r, c_r] = harris(I_right, 1, 0.01, 1, 0);

%displaying corners in both the images
figure; imshow([I_left I_right]); 
  hold on; title('corners');
 hold on; plot(c_l, r_l,'ys'); plot(c_r + size(I_left,2), r_r, 'ys'); 

%picking the neighbourhoods
N = 3;
reshapedVal = (2*padding+1)^2; %441 in this case

%picking the neighbours of detected corners from both the images
features_neigh_l= zeros(size(r_l,1),reshapedVal);
features_neigh_r= zeros(size(r_r,1),reshapedVal);

%(r_l,c_l) for left image

for i=1:1:size(r_l,1)
%     rowVal_left = r_l(i,1)-padding;
%     rowVal_right = r_l(i,1)+padding;
%     colVal_left = c_l(i,1)-padding;
%     colVal_right = c_l(i,1)+padding;
    neighbours_l = [];
    padHelper = zeros(2 * padding + 1); 
    padHelper(padding + 1, padding + 1) = 1;
    paddedImg = imfilter(I_left, padHelper, 'replicate', 'full');
    %picking the neighbours of each (r_l,c_l)
    row_val = r_l(i) : r_l(i) + 2 * padding;
    col_val = c_l(i) : c_l(i) + 2 * padding;
    neighbours_l = paddedImg(row_val, col_val );
    
    neighbours_l = reshape(neighbours_l,[1,reshapedVal]);
    features_neigh_l(i,:) = neighbours_l;
end

%(r_r,c_r) for right image
for i=1:1:size(r_r,1)
%     rowVal_left = r_r(i,1)-padding;
%     rowVal_right = r_r(i,1)+padding;
%     
%     colVal_left = c_r(i,1)-padding;
%     colVal_right = c_r(i,1)+padding;
    neighbours_r = [];
    padHelper = zeros(2 * padding + 1);
    padHelper(padding + 1, padding + 1) = 1;
    paddedImg = imfilter(I_right, padHelper, 'replicate', 'full');
    %picking the neighbours of each (r_l,c_l)
    row_val = r_r(i) : r_r(i) + 2 * padding;
    col_val = c_r(i) : c_r(i) + 2 * padding;
    neighbours_r = paddedImg(row_val, col_val );
    %neighbours_r = I_right_padded(rowVal_left:rowVal_right,colVal_left:colVal_right);
   
    neighbours_r = reshape(neighbours_r,[1,reshapedVal]);
    features_neigh_r(i,:) = neighbours_r;
end

features_neigh_l = zscore(features_neigh_l);
features_neigh_r = zscore(features_neigh_r);
row = [];
col = [];
% for i=1:1:size(features_neigh_l,1)
%        n = dist2(features_neigh_l(i,:),features_neigh_r);
%        [minVal,idx] = min(n);
%        if minVal < 4
%            [a,b] = ind2sub(size(n),idx);
%           row = [row;i];
%           col = [col;b];
%       end
%       
%   end
n = dist2(features_neigh_l,features_neigh_r);
[~,distance] = sort(n(:), 'ascend');
% 
% %threshHold = 100;
matches = distance(1:1000);
[row, col] = ind2sub(size(n), matches);
%[row,col] = find(n < threshHold);

%left_coord = zeros(size(row,1),2);
%right_coord = zeros(size(col,1),2);

%forming two lists of coordinates
%left_coord(:,1) = c_l(row);
%left_coord(:,2) = r_l(row);

%picking the matched coordinates from corresponding images
%row for left image
%col for right image
match_r_l = r_l(row);
match_c_l = c_l(row);
match_r_r = r_r(col);
match_c_r = c_r(col);

% 

 %right_coord(:,1) = c_r(col);
 %right_coord(:,2) = r_r(col);

%plotting the matches
figure; imshow([I_left I_right]); 
hold on; title('Matches');
hold on; plot(match_c_l, match_r_l,'ys');plot(match_c_r + 1024, match_r_r, 'ys'); 


%  plot_x = [match_r_l, match_r_r];
%  plot_y = [match_c_l, match_c_r +  size(I_left,2)];
%  figure; imshow([I_left I_right]); hold on; title('connected');
%  hold on; 
%  plot(match_c_l, match_r_l,'ys');          
%  plot(match_c_r + 1024, match_r_r, 'ys');
%  for i = 1:size(col,1)             
%      plot(plot_y(i,:), plot_x(i,:));
% end

%forming the homogenous coordinates
left_coord = [match_r_l,match_c_l,ones(size(match_r_l,1),1)];
right_coord = [match_r_r,match_c_r,ones(size(match_r_r,1),1)];

final_homography = zeros(3,3);
final_ratio = 0;
final_inliers = 0;
for i =0:1:size(col,1)
%randomly selecting 4 points
    randVal = randperm(size(col,1),4);
    h = zeros(8,9);
    
    src = [141, 131;480, 159 ;493, 630;64, 601];
     dest = [318, 256;534, 372;316, 670;73, 473];
    for i=0:1:3
        x = right_coord(randVal(i+1),1);
        y = right_coord(randVal(i+1),2);
        a = left_coord(randVal(i+1),1);
        b = left_coord(randVal(i+1),2); 
        
       h1 = [-x -y -1 0 0 0 x*a y*a a];
       h2 = [0 0 0 -x -y -1 x*b y*b b];

        h((2*i+1),:) = h1;
        h((2*i+2),:) = h2;
    end
    
    [~,~,V] = svd(h);
    
    X = V(:,9);
    X = reshape(X,[3,3]);
%     X(3,3) = 1;
    X = X';
    X = X ./ X(3,3);
    
    noOfInliers = 0;
    for t=1:1:size(col,1)
        mat = left_coord(t,:) * X;
        mat = mat ./mat(1,3);
%         cartDistX = mat(:,1)  - right_coord(:,1);
%     cartDistY = mat(:,2)  - right_coord(:,2);
%     ssdVal = cartDistX .* cartDistX + cartDistY .* cartDistY;
        diff = right_coord(t,:) - mat;
         ssdVal = sqrt(sum(diff(:).^2));
%         
        if ssdVal < 10
            noOfInliers = noOfInliers + 1;
        end
    end
    ratio = noOfInliers / size(col,1);
    if final_ratio < ratio
        final_homography = X;
        final_ratio = ratio;
        final_inliers = noOfInliers;
    end
    
end

final_homography =  final_homography ./ final_homography(3,3);
% final_homography=final_homography';
T = maketform('projective',final_homography');
figure; imshow(imtransform(I_left,T));
