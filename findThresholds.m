function [ ll, ul ] = findThresholds( handles, icaData )
%FINDTHRESHOLDS Summary of this function goes here
%   Detailed explanation goes here

    % Pull needed data from handles
    mask_ind = handles.FormData.mask_ind;
    percent_include = handles.FormData.percent_include;
    
    % Flatten data
    for comp = 1 : size(icaData,4)
        flatIca(comp,:) = reshape(icaData(:,:,:,comp), 1, []);
    end
    
    % Make sure this is a row vector
    if size(flatIca,1) > size(flatIca,2)
        flatIca = flatIca';
    end
    
    % Go through each component
    for comp = 1 : size(flatIca,1)
        % Pull unmasked data for this component
        img = flatIca(comp, mask_ind);
        
%         % Remove zero-ish data
%         zero_ind = find(img > 0.1);
%         zero_ind = [zero_ind find(img < -0.1)];
%         zero_ind = unique(zero_ind);
%         img = img(zero_ind);
                
        meanVal = mean(img); % Get mean of non-zero data;
        
        % Recenter all datapoints to mean
        img = img - meanVal;
        
        % Fold the data to be all >= 0 and sort from highest to lowest
        img = fliplr(sort(abs(img)));
        
        % Get threshold value index
        index = ceil((percent_include/(2*100)) * length(img));
        
        % Add mean back to threshold values
        ul(comp) = img(index);
        ll(comp) = -1 * ul(comp); % Can just negate since we are centered at 0
        ul(comp) = ul(comp) + meanVal;
        ll(comp) = ll(comp) + meanVal;
        
        % If the upper limit is negative or the lower limit is positive
        % then make that limit zero since the distribution is one sided.
        if ul(comp) < 0, ul(comp) = 0; end;
        if ll(comp) > 0, ll(comp) = 0; end;      
    end

end

