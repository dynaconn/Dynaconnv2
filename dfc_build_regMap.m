function [ regMap ] = dfc_build_regMap(handles, img, labels, start )
%DFNC_BUILD_REGMAP Create region map for image data and region labels
%   Detailed explanation goes here

    dim = size(img);  % Get all dimensions
    
    % If start wasn't sent then set it to start at 1
    if nargin <= 3
        start = 1;
    end

    % If start isn't 1, then load the previous regMap data before appending
    % more
    if start > 1
        regMap = handles.FormData.regMap;
    end
    
    % If the image is only 3 dimensions then it needs to be broken down to
    % one image per
    if ndims(img) == 3
        % Make sure the number of labels matches the number of layers, if 0
        % is in the list then remove 1 from the count.
        uniNums = unique(img);
        if ~isempty(find(uniNums==0))
            uniNumsN = length(uniNums) - 1;
        else
            uniNumsN = length(uniNums);
        end
        if length(labels) ~= uniNumsN
            fprintf('\nERROR - number of layers doesn''t match number of labels\n');
            regMap.prob = 0;
            regMap.label ='';
            return
        end
            
        % Go through each layer and create a 3d mask with label for each.
        % Flatten the img to vectorize the operation
        ix = 1;
        flatImg = reshape(img, 1, dim(1)*dim(2)*dim(3));
        for i = start : (start - 1) + length(labels)
            regMap(i).name = labels{ix};  % Copy region name
            
            % Create a region map for this layer which is the indices of
            % this layer
            %regMap(i).ind = find(flatImg == ix);
            tmpImg = zeros(size(flatImg));
            tmpImg(flatImg == ix) = 100;
            regMap(i).prob = tmpImg;
            ix = ix + 1;
        end
    % If the image is 4 dimension, then it can be load
    elseif ndims(img) == 4
        % Make sure the number of labels matches the number of layers.
        if length(labels) ~= size(img,4);
            fprintf('\nERROR - number of layers doesn''t match number of labels\n');
            regMap.ind = 0;
            regMap.label ='';
            return
        end
            
        % Go through each layer and create a 3d mask with label for each.
        % Flatten the img to vectorize the operation
        ix = 1;
        for i = start : (start - 1) + length(labels)
            regMap(i).name = labels{ix};  % Copy region name
            
            % Create a region map for this layer which is the indices of
            % this layer
            flatImg = squeeze(reshape(img(:,:,:,ix), 1, dim(1)*dim(2)*dim(3)));
            %regMap(i).ind = find(flatImg >= probThres);
            regMap(i).prob = flatImg;
            ix = ix + 1;
        end
    end
end

