
function volume = findVolume(heart, numSlice, cmPerPixel)

    widthSlices = putSlicesInArray(heart, numSlice);
    sectorVolumes = zeros(numSlice, 1);

    for i = 1:numSlice
        
        currentSlice = widthSlices(:,:,i);
        figure(2)
        imshow(currentSlice, []);
        title(num2str(i));

        % Create a binary mask from the drawn freehand region
        freehandROI = drawfreehand('Closed', true);

        % User input the apex and mitral valve
        [x,y] = ginput(2);
        
        % Assume the point have the have the same column (x-value) since
        % the long axis is supposedly vertical

        col = round(x(1));

        % Row corresponding to apex
        topRow = round(y(1));

        % Row corresponding to mitral valve
        botRow = round(y(2));
        
        % These arrays will store the radii determined by the distance
        % between the long axis and LV walls on either side
        radiusLeft = zeros(botRow-topRow,1);
        radiusRight = zeros(botRow-topRow,1);
        
        % Create a binary mask from the drawn region, this will zero out
        % everything outside the LV walls
        binaryMask = createMask(freehandROI);

        % Iterate through each row, left and right of col to get the left
        % and right radius respectively. Remember to convert number of
        % pixels to centimeters, and square the result

        for row = topRow:botRow
            % Extract the current row of the binaryMask
            currentRow = binaryMask(row,:);

            % Separate the current row into left and right sides of col
            leftArray = currentRow(1:col-1);
            rightArray = currentRow(col+1:end);
        
            % Number of pixels in left and right arrays before hitting the
            % LV wall
            first = sum(leftArray);
            second = sum(rightArray);
        
            % Store the radii, make sure to convert to cm
            radiusLeft(row-topRow+1) = first*cmPerPixel;
            radiusRight(row-topRow+1) = second*cmPerPixel; 

            % sectorVolume finds the combined volume of the left and right
            % sector prisms. Make sure each sector is multiplied by
            % cmPerPixel as that is the thickness of a sector
            
            SV = sectorVolume(radiusLeft, radiusRight, cmPerPixel, numSlice);

            % Put each sector volume in sectorVolumes, the units should be
            % cc
            sectorVolumes(i) = SV;
        end
        pause(1);
    end

    % Finally, sum up the volume of each sector prism
    volume = sum(sectorVolumes);
end    

function sv = sectorVolume(left, right, cmPerPixel, numSlice)
    % Each small sector volume (pretend it spans the entire circle)* is (sector radius)^2*pi. *The final answer is
    % divided by the number of slices
    sumLeft = 0;
    sumRight = 0;
    for i = 1:length(left)
        sumLeft = sumLeft + pi*left(i)^2*cmPerPixel;
        sumRight = sumRight + pi*right(i)^2*cmPerPixel;
    end
    sv = (sumLeft+sumRight)/(2*numSlice);
end

function widthSlices = putSlicesInArray(heart, numSlice)

    currentHeart = heart;

    % heart is 3D image with long axis aligned
    % numSlices is how many long axis slices used for volume calculation

    % Get size of heart:
    [m, n, p] = size(heart);
    centerW = round(m/2);

    % Calculating rotation angle
    angle = 180/numSlice;

    % Creating array to store long axis slices
    % Consider a long axis slice, p is the image width, n is the image
    % length

    widthSlices = zeros(p, n, numSlice);

    % Assigning middle index of width

    rvecDepth = [0 0 1];

    % Adding slices to widthSlices
    for i = 1:numSlice
        currentSlice = currentHeart(centerW,:,:);

        currentSlice = squeeze(currentSlice);

        % Transposing to get correct orientation
        currentSlice = currentSlice';
        
        % Adding slice to the array
        widthSlices(:,:,i) = currentSlice;

        % Rotate heart by angle to get next slice
        currentHeart = imrotate3(heart, angle*i, rvecDepth, "linear", "crop");
    end 
end


