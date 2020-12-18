function dfc_buildRegAveData( regMap,subjProp,settings )
%DFC_BUILDREGAVGDATA Build a .mat file with all subject region averages
%   Detailed explanation goes here

    nRegions = length(regMap);
    nSubjects = length(subjProp);
    maxTP = subjProp(1).srcDim(4);
 
    tic
    % Build list of indices from each reg prob layer that is above 50
    % The indices are without being masked
    for i = 1 : length(regMap)
        regMap(i).ind = find(regMap(i).prob > 50);
    end
    
    % Create progress bar for getting region average
    title = 'Building Region Averages';
    hdl1 = 'Subject Completion';
    hdl2 = 'Region Completion';
    multiWaitbar( 'CloseAll', title );
    if settings.usePfor
        multiWaitbar( hdl1, title, 0, 'Color', 'g', 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );
    else
        multiWaitbar( hdl1, title, 0, 'Color', 'g', 'CanCancel', 'off');
        multiWaitbar( hdl2, title, 0, 'Color', 'r', 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );
    end
    qString = 'Are you sure you want to cancel?';
    abort = false;

    RegAveData = zeros(nSubjects, nRegions, maxTP); % +1 for mean
    % Go through all the subjects building averages for each region
    settings.usePfor = 0; % Disable till a better way to update the progress bar is found
    if settings.usePfor
        matlabpool(feature('numCores'));  % Open parallel threads
        for s = 1 : nSubjects
            file = subjProp(s).srcFFile;
            regCount = zeros(1,nRegions);
            parfor r = 1 : nRegions
                % Report current estimate in the waitbar's message field
                totalRegs = sum(regCount);
                multiWaitbar( hdl2, title, totalRegs/nRegions );
                % Get region mean signal
                rmap_ind = regMap(r);
                RegAveData(s,r,:) = dfc_getRegionMean(file, rmap_ind, maxTP);
                %regCount(r) = 1;
            end
            
            % Report current estimate in the waitbar's message field
            abort = multiWaitbar( hdl2, title, s/nSubjects );
            if abort
                %Here we would normally ask the user if they're sure
                button = questdlg(qString,'Cancel?','No');
                if strcmpi(button,'yes')
                    break;
                else
                    multiWaitbar( hdl2, title, s/nSubjects, 'ResetCancel' );
                end
            end
            % Report current estimate in the waitbar's message field
            abort = multiWaitbar( hdl1, title, s/nSubjects );
        end
        matlabpool close;  % Close parallel threads
    else
        for s = 1 : nSubjects        
            % Load img for this subject and flatten
            V = spm_vol(subjProp(s).srcFFile);    % open data file
            nTP = length(V);
            for r = 1 : nRegions
                % Report current estimate in the waitbar's message field
                abort = multiWaitbar( hdl2, title, r/nRegions );
                if abort
                    %Here we would normally ask the user if they're sure
                    button = questdlg(qString,'Cancel?','No');
                    if strcmpi(button,'yes')
                        break;
                    else
                        abort = multiWaitbar( hdl2, title, ...
                            r/nRegions, 'ResetCancel' );
                    end
                end

                % Covert flat indices to 3d indices
                [x,y,z] = ind2sub(V(1).dim, regMap(r).ind);
                % Go through all time points
                % Get the mean of just the region data
                %Andrew changed mean to median on 10/28
                for t = 1 : nTP
                    RegAveData(s,r,t) = median(spm_sample_vol(V(t),x,y,z,0));
                end
            end
            
            % Report current estimate in the waitbar's message field
            multiWaitbar( hdl1, title, s/nSubjects ); %s-1 for mean
            if abort
                % If we aborted in the region loop, then break here.
                break
            end
        end
    end
    
    % Remove mean and make unit variance  %RegAveData(s,r,t)
    RegAveData = bsxfun(@minus, RegAveData, mean(RegAveData,3));
    RegAveData = bsxfun(@rdivide, RegAveData, std(RegAveData,0,3));
    RegAveData(isnan(RegAveData)) = 0;

    % Close the progress bar
    multiWaitbar( hdl1, title, 'Close' );
    multiWaitbar( hdl2, title, 'Close' );

    tEnd=toc;
    fprintf('Construction of region avgs took ');
    fprintf('%d minutes and %f seconds\n\n',floor(tEnd/60),rem(tEnd,60));
    
    if abort
        errordlg( 'Didn''t get region means!');
        return
    else
        % Save the data to mat file
        save(settings.regAveFile,'RegAveData');
    end
    
end

