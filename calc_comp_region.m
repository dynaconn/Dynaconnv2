function [scores,freq] = calc_comp_region(icaData, regMap, mask_ind, param)
%calc_comp_region Get the region sum or average of voxels in the
%probability mask that line-up with voxels above a threshold in the icaData
% Title: region_map.m
% Last modified: 8/4/2013
% Author: johne
% Descr:
%   score_data = F( region_prob_map(icaData > threshold) )
%   where is F is mean or sum depending on if param.dataType is 'average'
%   or 'sum'.
%   This function also return the frequency of each region, so in other
%   words if a region has 50 voxels and 20 of those are above the
%   threshold then the frequency is 40%.
%

    % pre-allocate scores part of score_data structure ,1 = score, ,2=index
    scores = zeros(length(regMap),2);
        
    % Flatten the data while throwing out masked data.
    flatIca = reshape(icaData, 1, []);
    flatIca = flatIca(mask_ind);
    clear icaData;
 
    % Dont need the data between the thresholds
    thr_ind = find(flatIca > param.UL);
    thr_ind = [thr_ind find(flatIca < param.LL)];
    thr_ind = unique(thr_ind);
    
    for rindex = 1 : length(regMap)
        %  Get this region and flatten while throwing out masked data
        rprob = regMap(rindex).prob;

        % Get total sum for later posssible region size compensation.
        % In case there is overlap of mask with region probabilty, get rid
        % of the masked voxels.
        rprob = rprob(mask_ind);
        regionTot = sum(rprob);
        
        % Get count of region voxels that aren't zero for freq count
        total_freq_count = length(find(rprob > 0));
        
        % Get the sum of the region data that is beyond the threshold
        % limits
        rprob = rprob(thr_ind);
        rsum = sum(rprob);
        
        % Get count of region voxels that arent' zero and that are above
        % the threshold. This is for the frequency count.
        freq_count = length(find(rprob > 0));

        % If compensate for region selected then scale rsum
        if strcmpi(param.compForRegionSize, 'on')
        % Normalize sum to 0 to 100 regardless of region size
            regionTot = regionTot / 100;
            rsum = rsum / regionTot;
        end
        
        % Store score results
        scores(rindex,1) = rsum;
        scores(rindex,2) = rindex;
        
        % Store frequency results
        freq(rindex,1) = 100 * (freq_count / total_freq_count);
    end
    
end
