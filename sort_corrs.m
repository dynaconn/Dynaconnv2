function [ new_img, compOrder ] = sort_corrs( img, subjProp, mode )
%SORT_CORRS Sort all components based on group1
%   Sum all the 1st group's component combination correlations, then sort
%   based on the sums.  Sort all rows but only use the group1 sums as
%   the sorting criteria

    % Get dimensions of the data
    dim = size(img);
    
    % Get amount of group 1 subject, except in the case of group mode where
    % you just use all the group combinations
    if strcmpi(mode,'group')
        numOfGroup1 = size(img,1);
    else
        numOfGroup1 = 0;
        for i = 1 : length(subjProp)
            if subjProp(i).group == 1
                numOfGroup1 = numOfGroup1 + 1;
            end
        end
    end

    % Allocate memory for new image
    new_img = zeros(size(img));

    % Find sum for all columns but just using group1;
    group1_column_sum = zeros(2,dim(2));
    for i = 1 : dim(2)
        group1_column_sum(1,i) = i;
        group1_column_sum(2,i) = sum(img(1:numOfGroup1,i));
    end

    % Sort Ave_DFNC_Combined based on column_sum
    group1_column_sum = sortrows(group1_column_sum',2);
    group1_column_sum = group1_column_sum';

    % Copy data from img to sorted new_img
    for r = 1 : dim(1) % Go though all subjects
        for c = 1 : dim(2) % Go through all comp combinations
            new_img(r,c) = img(r,group1_column_sum(1,c));
        end
    end

    % Strip of everything but new order of comp combinations to return
    compOrder = group1_column_sum(1,:);
    
end

