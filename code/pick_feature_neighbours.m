function feat_neigh = pick_feature_neighbours(img, row , col,padding)
    numOfFeatures = size(row,1);
    reshapedVal = (2*padding+1)^2;
    features_neigh= zeros(numOfFeatures,reshapedVal);
    for i=1:1:numOfFeatures

        neighbours = [];
        padder = zeros(2 * padding + 1); 
        padder(padding + 1, padding + 1) = 1;
        paddedImg = imfilter(img, padder, 'replicate', 'full');
        %picking the neighbours of each (r_l,c_l)
        row_val = row(i) : row(i) + 2 * padding;
        col_val = col(i) : col(i) + 2 * padding;
        neighbours = paddedImg(row_val, col_val );

        neighbours = neighbours(:);
        features_neigh(i,:) = neighbours;
    end
    
    feat_neigh = zscore(features_neigh')';
    
end