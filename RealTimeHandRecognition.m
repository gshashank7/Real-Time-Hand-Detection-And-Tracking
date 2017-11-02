function  RealTimeHandRecognition()
%This program accesses the web camera of the Laptop and detects a hand if
%kept in front of the web camera



        cam = webcam; % Creating a web camera object
        pause(4);
        for snap = 1:1000 % Taking snapshot from the web camera in a loop for 1000 times.
            image = snapshot(cam);
           
                
                
        image = im2double(image); % converting the image to double
        fltr = fspecial('gaussian',20, 2);   % applying gaussian filter for noise cleaning on the image
        image = imfilter(image,fltr,'same','replicate');

% -------------------------------------------------------------------------
% This line is for quantizing the image. This works for some conditions
% and doesn't work for some (Lighting and Background). Uncomment this line
% based on requirement

%         image = round( image * (20-1) ) ./ (20-1);  

%--------------------------------------------------------------------------
        
        
        
%--------------------------------------------------------------------------  

% This block of code was written to test different color spaces for skin
% color detection. The command impixelinfo will open an image window and
% show us the value of each pixel.

%         imageLAB = rgb2lab(image);
%         imageYCBCR = rgb2ycbcr(image);
        imageHSV = rgb2hsv(image);
%         imagexyz = rgb2xyz(image);
%         
        hue = imageHSV(:,:,1);
        saturation = imageHSV(:,:,2);
        value = imageHSV(:,:,3);
%         
%         cb = imageYCBCR(:,:,2);
%         cr = imageYCBCR(:,:,3);
%         
%         l = imageLAB(:,:,1);
%         a = imageLAB(:,:,2);
%         b = imageLAB(:,:,3);
%         
%         x = imagexyz(:,:,1);
%         y = imagexyz(:,:,2);
%         z = imagexyz(:,:,3);
%         
%         j = imshow(l);
%         impixelinfo(j);

% -------------------------------------------------------------------------



%--------------------------------------------------------------------------

% This block of code gets the dinensions of the image, creates a matrix of
% the same dimensions with 0s in it. It then parses though each pixel of
% the original image and checks for the H, S and V values if they lie
% within the range of what the skin color should be. If it does, it
% converts them to white pixels and if not, it converts them to black
% pixels. This gives us a binary image.

        dims = size(image);
        binaryImage = zeros(dims(1),dims(2));

        for row = 1:dims(1)
            for column = 1:dims(2)

% The two if statements have different ranges. 
%The first one works with light directly focused on hand with white or black backgrounds.
% The second one works with the lighting conditions of the classroom
                

%                 if hue(row,column) >= 0.03 && hue(row,column)<=0.11 && saturation(row,column) >= 0.035 && saturation(row,column)<=0.80 && value(row,column) >= 0.20 && value(row,column) <= 0.80
                    if hue(row,column) >= 0.03 && hue(row,column)<=0.11 && saturation(row,column) >= 0.20 && saturation(row,column)<=0.40 && value(row,column) >= 0.20 && value(row,column) <= 0.60

                    binaryImage(row,column) = 1;

                else
                    binaryImage(row,column) = 0;

                end 
            end
        end

        
% Uncomment the below three lines to display the binary image

%         figure;
%         imshow(binaryImage);
%         colormap(gray); 
%         

%--------------------------------------------------------------------------
% Getting the perimeter of all the contours and determinf the biggest
% contour by finding the countour with longest perimeter. All other contours
% are made into black pixels.I looked up stackoverflow for performing these operations.

        perimeterImage = bwperim(binaryImage,4);
        
        perimeters= regionprops(perimeterImage, 'Perimeter','PixelIdxList');

        [~,idx] = max([perimeters.Perimeter]);
         
        [coordinates] = perimeters(idx).PixelIdxList;

        LargestContour = false(size(perimeterImage));

        LargestContour(coordinates) = 1;


% uncomment the below lines to display the image with only the largest
% contour

%         imshow(LargestContour);
%         hold on;

%--------------------------------------------------------------------------

% once I have the largest contour, I get indicies of all the pixels that
% form the perimeter of that contour. These pixels are then used to find
% the convex hull of that contour. I looked up the mathworks-blogs on how
% to do these.

        [y,x] = find(LargestContour);
        dx = [-0.5 -0.5  0.5  0.5];
        dy = [-0.5  0.5 -0.5  0.5];
        xCorners = bsxfun(@plus, x, dx);
        yCorners = bsxfun(@plus, y, dy);
        xCorners = xCorners(:);
        yCorners = yCorners(:);
        

%  Plotting the border of the hand.

%         plot(x_corners, y_corners, 'og');
%         hold off;
        
        
        imshow(image);
        

        polygon = convhull(xCorners, yCorners);
        xCoordinatesOfHull = xCorners(polygon);
        yCoordinatesOfHull = yCorners(polygon);
        hold on
        plot(xCoordinatesOfHull, yCoordinatesOfHull, 'r', 'LineWidth', 4)
        hold off
        

            
            
        end
end

