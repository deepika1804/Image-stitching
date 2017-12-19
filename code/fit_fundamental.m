function F = fit_fundamental(matches,isNormalized)
     points = 8;
     if isNormalized
         matches(:,1:2) = zscore( matches(:,1:2));
         matches(:,3:4) = zscore( matches(:,3:4));
     end
    
     numOfmatches = size(matches,1);
     randVal = randperm(numOfmatches,8);
     F = [];
     for i=1:1:points
         x = matches(randVal(i),1); %x1
         y = matches(randVal(i),2);
         a = matches(randVal(i),3); %x2
         b = matches(randVal(i),4);
         estimated_mat = [(a * x) (a * y) a (b*x) (y * b) b x y 1];
         F = [F;estimated_mat];
     end
     
     [U,D,V] = svd(F);
     X = V(:,9);
     X = reshape(X,[3,3]);
     [U,D,V]=svd(X);
     D(3,3) = 0;
     F = U * D * V';
end