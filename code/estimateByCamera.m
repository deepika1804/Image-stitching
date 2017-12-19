function estimateByCamera(matches)
    P1 = load('../data/part2/house1_camera.txt');
    P2 = load('../data/part2/house2_camera.txt');
    
    %finding the centers of camera matrix
     [~,~,V] = svd(P1);
     P1_c = V(:,end);
     P1_c = P1_c ./ P1_c(4,1);
     P1_c = P1_c';
     [~,~,V] = svd(P2);
     P2_c = V(:,end);
     P2_c = P2_c ./ P2_c(4,1);
     P2_c = P2_c';
    points3D = [];
    for i=1:1:size(matches,1)
        img_pt_l = matches(i,1:2);
        img_pt_r = matches(i,3:4);
        x = img_pt_l(1);
        y = img_pt_l(2);
        u = img_pt_r(1);
        v = img_pt_r(2);
        skew_1 = [0 -1 y;1 0 -x;-y x 0];
        skew_2 = [0 -1 v;1 0 -u;-v u 0];
        estimation1 = skew_1 * P1;
        estimation2 = skew_2 * P2;
        A = [estimation1(1:2,:);estimation2(1:2,:)];
        
        [~,~,V] = svd(A);
        X = V(:,end);
        X = X./X(4,1);
        points3D = [points3D;X'];
    end
    display(points3D);
    img1_mat = [];
    img2_mat = [];
    img1_mat = [matches(:,1) matches(:,2) ones(size(matches,1),1)];
    residual_distances1 = sum(sum((points3D(:,1:3) - img1_mat).^2))/size(matches,1);
    img2_mat = [matches(:,3) matches(:,4) ones(size(matches,1),1)]
    residual_distances2 = sum(sum((points3D(:,1:3) - img2_mat).^2))/size(matches,1);

    %for i=1:1:size(matches,1)
    disp('The average residual distance of 2D point of image 1 to 3d point X is');
    disp(residual_distances1);
    disp('The average residual distance of 2D point of image 2 to 3d point X is');
    disp(residual_distances2);
    plot3(points3D(:,1),points3D(:,2),points3D(:,3),'b+');
    hold on;
    for i=1:1:size(matches,1)
        
        plot3([P1_c(1,1);points3D(i,1)],[P1_c(1,2);points3D(i,2)],[P1_c(1,3);points3D(i,3)]);
        hold on;
        plot3([P2_c(1,1);points3D(i,1)],[P2_c(1,2);points3D(i,2)],[P2_c(1,3);points3D(i,3)]);
   end

    
   
end