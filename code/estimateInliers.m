function [ratio,noOfInliers,storedSsdData,InlierMatches] = estimateInliers(homographyMat,img_left,img_right,itr)
 noOfInlier = 0;
 storedSsdData = [];
 InlierMatches = [];
    for t=1:1:itr
        mat = img_left(t,:) * homographyMat;
        mat = mat ./mat(1,3);

        diff = img_right(t,:) - mat;
        ssdVal = sqrt(sum(diff(:).^2));
        
%          ssdVal = sqrt(dist2(img_right(t,:),mat));
        if ssdVal < 10
            storedSsdData = [storedSsdData;(ssdVal^2)];
            noOfInlier = noOfInlier + 1;
            InlierMatches = [InlierMatches ; img_left(t,1) img_left(t,2) img_right(t,1) img_right(t,2)];
        end
    end
    ratio = noOfInlier / itr;
    noOfInliers = noOfInlier;
    
end