function [ratio,noOfInliers,InlierMatches] = estimate_F_inliers(FundamentalMat,img_left,img_right,itr)
 noOfInlier = 0;
 InlierMatches = [];
    for t=1:1:itr
        mat = img_left(t,:) * FundamentalMat * img_right(t,:)';
       
        if abs(mat) < 0.1
            InlierMatches = [InlierMatches ; img_left(t,1) img_left(t,2) img_right(t,1) img_right(t,2)];
            noOfInlier = noOfInlier + 1;
        end
    end
    ratio = noOfInlier / itr;
    noOfInliers = noOfInlier;
    
end