function stitchImages(homography,img1,img2,orgImg1,orgImg2)

    T = maketform('projective',homography);
    [~,xData,yData] =  imtransform(img1,T);
    
    xdata_out=[min(1,xData(1)) max(size(img2,2), xData(2))];
    ydata_out=[min(1,yData(1)) max(size(img2,1), yData(2))];
    result1 = imtransform((orgImg1), maketform('projective',homography),'XData',xdata_out,'YData',ydata_out);
    result2 = imtransform((orgImg2), maketform('affine',eye(3)),'XData',xdata_out,'YData',ydata_out);
    result2 = im2double(result2);
    result1 = im2double(result1);
    result_avg = (result1 + result2)/2;
    overlap = result1 & result2;
    
    
    mask = (result1) > 0;
    result = bsxfun(@times, result2, ~mask) + result1;
    result(overlap) = result_avg(overlap);
   
    panormaImg = result;
    figure;
    imshow(panormaImg);
     hold on; title('Panorma view of 2 images');
    
end