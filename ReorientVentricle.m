function [outputVolume] = ReorientVentricle(heart, time)
    
    
    % Created by Jose on 10/26/23
    % Updated by Kevin on 10/27/23
    % Updated by Jose on 10/27/23
    % Updated by Jose on 10/30/23
    % Updated by Jose on 10/31/23
    % Updated by Jose on 11/7/23

    currentVersion = "10/26/23";
    

    
    centerH = floor(heart.height/2);
    centerW = floor(heart.width/2);
    centerD = floor(heart.depth/2);
    
    extractW = heart.data(centerW,:,:,time);
    extractH = heart.data(:,centerH,:,time);
    extractD = heart.data(:,:,centerD,time);
    
    imgW = squeeze(extractW);
    imgH = squeeze(extractH);
    imgD = squeeze(extractD); 
    
    d = floor(heart.depth);
    w = floor(heart.width);
    h = floor(heart.height);

    widthdistance = heart.widthspan; %cm
    heightdistance = heart.heightspan; %cm
    depthdistance = heart.depthspan; %cm
    
    figure(1);
    % width
    sp2_1 = subplot(2, 2, 1);
    imshow(imgW', []);
    title('Width');
    line([centerH centerH], [1 d],'Color','red','LineWidth',2) 
    line([1 h], [centerD centerD],'Color','green','LineWidth',2)
    addborder(1, d, h, 1, 'blue');
    
    % height
    sp2_2 = subplot(2, 2, 2);
    imshow(imgH', []);
    title('Height');
    line([centerW centerW], [1 d],'Color','blue','LineWidth',2) 
    line([1 w], [centerD centerD],'Color','green','LineWidth',2)
    addborder(1, d, w, 1, 'red');
    
    
    % depth
    sp2_3 = subplot(2, 2, 3);
    imshow(imgD', []);
    title('Depth');
    line([centerW centerW], [1 h],'Color','blue','LineWidth',2) 
    line([1 w], [centerH centerH],'Color','red','LineWidth',2)
    addborder(1, h, w, 1, 'green');
    
    
    [x, y] = ginput(2);
    
    % Identify the subplot user clicked on
    ax = gca; % Get the current axes handle
    if ax == sp2_1
        dimension = 'W';
    elseif ax == sp2_2
        dimension = 'H';
    elseif ax == sp2_3
        dimension = 'D';
        disp 'You have selected the Depth image, which has incorrect rotations as of' 
        disp(currentVersion);
    else
        error('Unexpected axes handle.');
    end
    
    linemaker(x(1), y(1), x(2), y(2));
    
    midpoint = midptofline(x(1), y(1), x(2), y(2));
    lengthofline = distanceinpixels(x(1), y(1), x(2), y(2));


    % Calculate pixels per centimeter ratio
    switch dimension
        case 'W'
            pixelsPerCm = w / widthdistance;
        case 'H'
            pixelsPerCm = h / heightdistance;
        case 'D'
            pixelsPerCm = d / depthdistance;
        otherwise
            error('Unexpected dimension.');
    end

    % Calculate the length of the line in centimeters
    lengthOfLineCm = lengthofline / pixelsPerCm;

% Display the length of the line in centimeters
fprintf('Distance from base to apex is %.2f cm.\n', lengthOfLineCm);
    
    centerX = midpoint(1);
    centerY = midpoint(2);
    radiusofcircle = lengthofline/8;
    circlemakerforlines(centerX, centerY, radiusofcircle);


    
    % Default translations
    d_D = 0;
    d_H = 0;
    d_W = 0;
    
    % Compute translations based on selected dimension
    switch dimension
        case 'W'
            d_D = 2 * (heart.depth/2 - centerY);
            d_W = 2 * (heart.width/2 - centerX);
            d_H = 0;
        case 'H'
            d_D = 2 * (heart.depth/2 - centerY); 
            d_H = 2 * (heart.width/2 - centerX); 
            d_W = 0; 
        case 'D'
            d_H = 2 * (heart.depth/2 - centerY);
            d_W = 2 * (heart.width/2 - centerX);
            d_D = 0; 
    end
    
    % Compute the translated volume
    vol_transfull = imtranslate(heart.data(:,:,:,1), [d_W d_H d_D], 'OutputView', 'full', 'FillValues', 128);
    
    % Extract the relevant slice based on the selected dimension
    switch dimension
        case 'W'
            extract_transfull = vol_transfull(centerW, :, :, time);
            originalTitle = get(get(sp2_1, 'Title'), 'String');
        case 'H'
            extract_transfull = vol_transfull(:, centerH, :, time);
            originalTitle = get(get(sp2_2, 'Title'), 'String');
        case 'D'
            extract_transfull = vol_transfull(:, :, centerD, time);
            originalTitle = get(get(sp2_3, 'Title'), 'String');
    end
    
    img_transfull = squeeze(extract_transfull);
    figure(1)
    imshow(img_transfull', []);
    title(originalTitle); % Set the original title
    
    [newrows, newcols, ~] = size(img_transfull');
    newcenter_y = newrows / 2;
    newcenter_x = newcols / 2;
    
    circlemakerforlines(newcenter_x, newcenter_y, radiusofcircle);
    
    
    
    
    % Calculate the angle with the vertical axis
    deltaY = y(2) - y(1);
    deltaX = x(1) - x(2);
    angle = atan(deltaY/deltaX); 
    angleDeg = rad2deg(angle);
    ccwangle = 90 - angleDeg;
    
    % setting the rotation vector
    rvecWidth = [0 -1 0];
    rvecHeight = [1 0 0];
    rvecDepth = [0 0 -1];
    
    rvec = [0 0 0];
    
    switch dimension
        case 'W'
            rvec = rvecWidth;
        case 'H'
            rvec = rvecHeight;   
        case 'D'
            rvec = rvecDepth;
    end
    
    
    vol_transfull_rotated = imrotate3(vol_transfull, ccwangle, rvec,  'FillValues', 100);
    
    
    
    % Extract the relevant slice based on the selected dimension
    switch dimension
        case 'W'
            extract_transfull = vol_transfull_rotated(centerW, :, :, time);
            originalTitle = get(get(sp2_1, 'Title'), 'String');
        case 'H'
            extract_transfull = vol_transfull_rotated(:, centerH, :, time);
            originalTitle = get(get(sp2_2, 'Title'), 'String');
        case 'D'
            extract_transfull = vol_transfull_rotated(:, :, centerD, time);
            originalTitle = get(get(sp2_3, 'Title'), 'String');
    end
    
    img_transfull = squeeze(extract_transfull);
    figure(1)
    imshow(img_transfull', []);
    title(originalTitle); % Set the original title
    
    [newrows, newcols, ~] = size(img_transfull');
    newcenter_y = newrows / 2;
    newcenter_x = newcols / 2;
    
    circlemakerforlines(newcenter_x, newcenter_y, radiusofcircle);
    
    

    % Reorient based on the translations performed earlier
    switch dimension
        case 'W'
            x1 = newcenter_x - w/2 + d_W/2; 
            y1 = newcenter_y - d/2 + d_D/2;
            cropRect = [x1, y1, h, d];
            % Crop the image
            croppedImage = imcrop(img_transfull', cropRect);
    
            % Display the cropped image
            figure(1)
            imshow(croppedImage, []);
            title('Reoriented Width');
            dimension = 'W';

        case 'H'
            x1 = newcenter_x - h/2 + d_H/2; 
            y1 = newcenter_y - d/2 + d_D/2;
            cropRect = [x1, y1, w, d];
            % Crop the image
            croppedImage = imcrop(img_transfull', cropRect);
    
            % Display the cropped image
            figure(1)
            imshow(croppedImage, []);
            title('Reoriented Height');
            dimension = 'H';
        
        case 'D'
            x1 = newcenter_x - w/2 + d_W/2; 
            y1 = newcenter_y - h/2 + d_H/2;
            cropRect = [x1, y1, w, h];
            % Crop the image
            croppedImage = imcrop(img_transfull', cropRect);
    
            % Display the cropped image
            figure(1)
            imshow(croppedImage, []);
            title('Reoriented Depth');
            dimension = 'd';
    end



    [newCropHeight, newCropWidth] = size(croppedImage);
    
    % Preallocate the array for the cropped volume
    % The depth of the volume will depend on the selected dimension
    switch dimension
        case 'W'
            croppedVolume = zeros(newCropHeight, newCropWidth, size(vol_transfull_rotated, 1), time);
        case 'H'
            croppedVolume = zeros(newCropHeight, newCropWidth, size(vol_transfull_rotated, 2), time);
        case 'D'
            croppedVolume = zeros(newCropHeight, newCropWidth, size(vol_transfull_rotated, 3), time);
    end
    disp(size(croppedVolume))



    switch dimension
        case 'W'
            % Loop through each slice depending on the selected dimension
            for i = 1:size(vol_transfull_rotated, 1)

                slice = squeeze(vol_transfull_rotated(i, :, :, time));
                x1 = newcenter_x - w/2 + d_W/2; 
                y1 = newcenter_y - d/2 + d_D/2; 
                cropRect = [x1, y1, h, d]; 
                
                % Crop the slice to match the display orientation
                croppedSlice = imcrop(slice', cropRect);
                
                % Assign the cropped slice into the corresponding position of the 3D volume
                croppedVolume(:, :, i, time) = croppedSlice;
            end
            finaltitle = 'Reoriented Width';

        case 'H'
            % Loop through each slice depending on the selected dimension
            for i = 1:size(vol_transfull_rotated, 2)

                slice = squeeze(vol_transfull_rotated(:, i, :, time));
                x1 = newcenter_x - h/2 + d_H/2; 
                y1 = newcenter_y - d/2 + d_D/2; 
                cropRect = [x1, y1, w, d]; 
                
                % Crop the slice to match the display orientation
                croppedSlice = imcrop(slice', cropRect);

                croppedVolume(:, :, i, time) = croppedSlice;
            end
            finaltitle = 'Reoriented Height';

        case 'D'
            % Loop through each slice depending on the selected dimension
            for i = 1:size(vol_transfull_rotated, 3)

                slice = squeeze(vol_transfull_rotated(:, :, i, time));
                x1 =newcenter_x - w/2 + d_W/2; 
                y1 = newcenter_y - h/2 + d_H/2; 
                cropRect = [x1, y1, w, h]; 
                
                % Crop the slice to match the display orientation
                croppedSlice = imcrop(slice', cropRect);
                
                % Assign the cropped slice into the corresponding position of the 3D volume
                croppedVolume(:, :, i, time) = croppedSlice;
            end
            finaltitle = 'Reoriented Depth';
    end
    
    new_center = floor(size(croppedVolume, 3)/2);
    
    new_extract = croppedVolume(:,:,new_center,1);

    finalimg = squeeze(new_extract);

    figure(1)
    imshow(finalimg, []);
    title(finaltitle); % Set the final title

    outputVolume = croppedVolume; % This is now a 3D volume
end 