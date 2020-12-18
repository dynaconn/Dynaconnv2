function outputImg = dfc_resizeImg(scale, inputImg)
% DFNC_RESIZEIMG Scale the input image 
%   Scale the image using imresize

    % Determine if this is binary data by changing the 1s to 0s then
    % checking if the sum is not equal to 0.
    X = inputImg;
    X(X == 1) = 0;
    if sum(X) > 1E3
        isBinary = 1;
    else
        isBinary = 0;
    end
    
    % New input data size
    dim = size(inputImg);
    newDim = round(dim * scale);
    
    if isBinary
        % Use imresize to scale the 2d images in a for loop through all
        % the z images.
        for i = 1 : dim(3)
            B(:,:,i) = imresize(inputImg(:,:,i),[newDim(1) newDim(2)]);
        end

        % Use imresize to scale the array of voxels in z space.
        for i = 1 : 181
            for j = 1 : 217
                T = squeeze(B(i,j,:));
                C(i,j,:) = imresize(T,[newDim(3) 1]);
            end
        end

        % Convert the data back to binary data (assuming its a mask 1/0).
        C(C >= 0.5) = 1;
        C(C < 0.5) = 0;
        outputImg = C(end:-1:1, :, :);
    else
        % Use imresize to scale the 2d images in a for loop through all
        % the z images.
        for i = 1 : dim(3)
            B(:,:,i) = imresize(inputImg(:,:,i),[newDim(1) newDim(2)],'Method','Nearest');
        end

        % Use imresize to scale the array of voxels in z space.
        for i = 1 : newDim(1)
            for j = 1 : newDim(2)
                T = squeeze(B(i,j,:));
                C(i,j,:) = imresize(T,[newDim(3) 1],'Method','Nearest');
            end
        end
        outputImg = C(end:-1:1, :, :);
    end
