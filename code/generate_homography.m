function H = generate_homography(left_coord,right_coord)
     itr = size(left_coord,1);
     noOfPoints = 4;
     %randomly selecting 4 points
     randVal = randperm(itr,noOfPoints);
     h = zeros(8,9);
     
    
    for i=0:1:noOfPoints-1
        x = left_coord(randVal(i+1),1);
        y = left_coord(randVal(i+1),2);
        a = right_coord(randVal(i+1),1);
        b = right_coord(randVal(i+1),2); 
        
        h1 = [-x -y -1 0 0 0 x*a y*a a];
        h2 = [0 0 0 -x -y -1 x*b y*b b];

        h((2*i+1),:) = h1;
        h((2*i+2),:) = h2;
    end
    
    [~,~,V] = svd(h);
    
    X = V(:,9);
    X = reshape(X,[3,3]);

   
    X = X ./ X(3,3);
    H = X;
end