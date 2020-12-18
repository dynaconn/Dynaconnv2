
% 
function [rnames] = dfc_outputRegCover(saveFile, handles)
% outputRegCover - This function returns a matrix of region coverage
% percentages for each IC(column). Each row is a string name
% of regions for each IC

    % Make the z-score cutoff part of a dafault file as some point
    zcut = 1.7;

    % Pull needed data from handles
    regMap = handles.FormData.regMap;
    mask_ind = handles.FormData.mask_ind;
    subjProp = handles.FormData.subjProp;
    subjNum = handles.FormData.subjNum;
 
    % Variables for calculating the IC region coverage
    param.dataType = 'average';     % Data type can be average or sum
    param.compForRegionSize = 'on';
    param.UL = zcut;
    param.LL = -zcut;
            
    % Get how many ICs there are.
    icDim = handles.FormData.subjProp(subjNum).icDim;
    numOfIC = icDim(4);
    
    % Open data and extract just 2 comps
    FName = subjProp(subjNum).icFFile;
    V = spm_vol(FName);
    
    % Create progress bar for getting region average
    title = 'Calculating region coverages';
    hdl1 = 'ICs Complete';
    multiWaitbar( 'CloseAll', title );
    multiWaitbar( hdl1, title, 0, 'Color', 'r', 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );
    qString = 'Are you sure you want to cancel?';
    abort = false;
    
    
    for ic = 1 : numOfIC
        % Report current estimate in the waitbar's message field
        abort = multiWaitbar( hdl1, title, ic/numOfIC );
        if abort
            %Here we would normally ask the user if they're sure
            button = questdlg(qString,'Cancel?','No');
            if strcmpi(button,'yes')
                break;
            else
                abort = multiWaitbar( hdl1, title, ...
                    ic/numOfIC, 'ResetCancel' );
            end
        end
        
        % Load the images, these must be seperated at the 1st dimension for
        % the reshape below to work properly
        img = spm_read_vols(V(ic));

        % Convert to Z-score
        dim = size(img);
        imgFlat = reshape(img,1,[]);
        mask_nonZero = (imgFlat ~= 0);
        x = imgFlat(mask_nonZero);
        % Remove mean
        x = detrend(x, 0);
        % Normalize
        vstd = norm(x, 2) ./ sqrt(length(x) - 1);
        imgFlat = imgFlat./(eps + vstd);
        img = reshape(imgFlat,dim);

        % Get scores
        [scores,~] = calc_comp_region(img, regMap, mask_ind, param); 

        % Get rid of results less than 10
        good_ind = scores(:,1) > 10;
        scores = scores(good_ind,:);

        % Sort the data
        [scores, sort_ind] = sortrows(scores,1);
        scores = flipud(scores);
         
        % Plot the region data to the tables
        % Only use the 1st 10 sorted entries or as many as there are
        last_entry = min(size(scores,1), 6);
        
        if last_entry ~= 0
            scores2List = scores(1:last_entry,:);
            clear scores;
            
            % Get region names and shorten to fit in table
            for i = 1 : size(scores2List,1)
                tmp_rnames = regMap(int16(scores2List(i,2))).name;
                if length(tmp_rnames) > 20
                    rnames{ic,i,1} = tmp_rnames{1}(1:20);
        
                else
                    rnames{ic,i,1} = tmp_rnames{1};
                end
                rnames{ic,i,2} = sprintf('%0.1f%%',scores2List(i,1));
            end
        else
            rnames{ic,1,1}='Nothing above 10%';
            rnames{ic,1,2}='';
        end
    end
    
    % Close the progress bar
    multiWaitbar( hdl1, title, 'Close' );
    
    %Output the data to the saveFile txt file.
    fileID = fopen(saveFile,'w');
    for ic = 1 : numOfIC
        numOfRow = size(rnames,2);
        fprintf(fileID,'IC%d\n', ic);
        for r = 1 : numOfRow
            if ~isempty(rnames{ic,r,1})
                fprintf(fileID,'%5s  -  %s\n', rnames{ic,r,2}, rnames{ic,r,1});
            end
        end
        fprintf(fileID, '\n\n');
    end
    fclose(fileID);
    