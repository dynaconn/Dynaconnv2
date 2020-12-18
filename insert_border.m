function [ new_img, new_subjProp ] = insert_border( img, mode, subjProp, color )
%INSERT_BORDER Insert Border
%   Add a horizontal border to the surf image at the point line where the
%   group number (subjProp.group) changes.
%   If color='mid', which is the default, the value for the border is set
%   to the mid value which is an attempt to make the boder yellow or red.
%   If color='low', the value for the border is set to the lowest value
%   found in all of the data.
%   If color='high', the value for the border is set to the highest value
%   found in all of the data.

    % Get values of img at corners (and center)
    low_value = min(min(img));
    high_value = max(max(img));
    mid_value = 5*(high_value - low_value) / 6;
    
    % Check what color to use for the border
    if nargin == 3 % color var exists
        if strcmpi(color,'low')
            borderColor = low_value;
        elseif strcmpi(color,'high')
            borderColor = high_value;
        else
            borderColor = mid_value;
        end
    else
        borderColor = mid_value;
    end
    
    % Go through the subjects and inject a border when a new group number
    % is encountered.
    ix = 1;
    currGroupNum = 1;
    for i = 1 : length(subjProp)
        if currGroupNum ~= subjProp(i).group
            % Insert border row
            for j = 1 : size(img,2) % Go through all comp combinations
                new_img(ix,j) = borderColor;
            end
            new_subjProp(ix) = subjProp(i); % Make a copy then overwrite
            new_subjProp(ix).index = 0;
            new_subjProp(ix).code = 'b';
            new_subjProp(ix).group = 0;
            ix = ix + 1;
            currGroupNum = currGroupNum + 1;
        end
        new_img(ix,:) = img(i,:);
        new_subjProp(ix) = subjProp(i);
        ix = ix + 1;
    end
end

