function dfc_calcNetworkRegions(handles, img)
%DFC_CALCNETWORKREGIONS Calculate how much coverage an img has over a region
%   This function fills in the table in DFC_CompDisplay with how much a
%   region is coverted by the img data.

    % Pull needed data from handles
    regMap = handles.FormData.regMap;
    mask_ind = handles.FormData.mask_ind;
    
    % Table handles
    table(1) = handles.uitable1;
    table(2) = handles.uitable2;
    
    % Start looping through all networks
    for comp = 1 : 2
        icaData = squeeze(img(comp,:,:,:)); % Retrive data

        % Get scores
        param.dataType = 'average';     % Data type can be average or sum
        param.compForRegionSize = 'on';
        param.UL = handles.FormData.UL(comp);
        param.LL = handles.FormData.LL(comp);
        [scores,freq] = calc_comp_region(icaData, regMap, mask_ind, param); 
    
        % Get rid of results less than 10
        good_ind = scores(:,1) > 10;
        scores = scores(good_ind,:);
        freq = freq(good_ind,:);
            
        % Sort the data
        [scores, sort_ind] = sortrows(scores,1);
        scores = flipud(scores);
        freq = freq(sort_ind);
        freq = flipud(freq);
        
        
        % Plot the region data to the tables
        % Only use the 1st 10 sorted entries or as many as there are
        last_entry = min(size(scores,1), 10);
        
        if last_entry ~= 0
            scores2List = scores(1:last_entry,:);
            freq2List = freq(1:last_entry,:);
            clear scores freq;
            
            % Get region names and shorten to fit in table
            for i = 1 : size(scores2List,1)
                tmp_rnames = regMap(int16(scores2List(i,2))).name;
                if length(tmp_rnames) > 20
                    rnames{i,1} = tmp_rnames{1}(1:20);
        
                else
                    rnames{i,1} = tmp_rnames{1};
                end
                rnames{i,2} = sprintf('%0.1f%%',scores2List(i,1));
                rnames{i,3} = sprintf('%0.1f%%',freq2List(i,1));
            end
        else
            rnames{1,1}='Nothing above 5%';
            rnames{1,2}='';
        end
            
        % Send new data to table
        set(table(comp),'Data',rnames,'ColumnName',{'Region','Coverage','Freq'});
        set(table(comp),'ColumnWidth',{260 100 100})
        clear rnames;
    end
    
end

