function outData = dfc_subjNetCorr(handles, compList, sortedSubjProp, corrType)
%DFC_SUBJCOMPCORR Correlation for all component combinations
%   This function goes through every subject and finds the largest average
%   correlation between either the positive or negative correlation of
%   every subject's component combinations

% We pull in sortedSubjProp instead of using subjProp from handles sincethe
% region matrix is sorted.
    
    % Create progress bar for getting region average
    title = 'Correlating subject''s IC combinations';
    hdl1 = 'Subject Completion';
    hdl2 = 'IC Combination Completion';
    multiWaitbar( 'CloseAll', title );
    % For now don't use pfor
    %settings.usePfor = 0;
    %if settings.usePfor
    % If a mex version exists use it
    if exist('dfcmexfile1','file')
        multiWaitbar( hdl1, title, 0, 'Color', 'g', 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );
    else
        multiWaitbar( hdl1, title, 0, 'Color', 'g', 'CanCancel', 'off');
        multiWaitbar( hdl2, title, 0, 'Color', 'r', 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );
    end
    qString = 'Are you sure you want to cancel?';
    abort = false;
    
    numOfSubj = length(sortedSubjProp);
    numOfIcc = length(compList);
    
    % Start the DFC correlation
    
    if exist('dfcmexfile1','file') && corrType == 1
        % Use mex version if available
        for s = 1 : numOfSubj % Go though all subjects
            % Open each subject
            vol_info = spm_vol(sortedSubjProp(s).tcFFile);    % open data file
            data_img = spm_read_vols(vol_info); % Retrive data
            handles.FormData.subjNum = s; % Add the subj code num
            
            ix = 1; % Column index for window data
      
            if corrType == 1
                % Get the correlation between all subject components
                nTCs = sortedSubjProp(1).tcDim(2);
                nSubjects = 1;
                windowSize = handles.FormData.windowSize;
                stepSize = handles.FormData.stepSize;
                nTimePoints = sortedSubjProp(1).tcDim(1);
                % Calc dfc data using mex file, note that data_img must be
                % transposed.
                avePosCorrData = dfcmexfile1(nTCs,nSubjects,windowSize,nTimePoints,stepSize,data_img');
                if avePosCorrData > 0
                    outData(s,:) = avePosCorrData;
                else
                    outData(s,:) = -avePosCorrData;
                end
            end

            % Report current estimate in the waitbar's message field
            multiWaitbar( hdl1, title, s/numOfSubj ); %s-1 for mean
            if abort
                % If we aborted in the region loop, then break here.
                break
            end
        end
        % Close the progress bar
        multiWaitbar( hdl1, title, 'Close' );
        multiWaitbar( hdl2, title, 'Close' );
        
    else
        % Else, then use the matlab version instead of mex
        for s = 1 : numOfSubj % Go though all subjects
            % Open each subject
            vol_info = spm_vol(sortedSubjProp(s).tcFFile);    % open data file
            data_img = spm_read_vols(vol_info); % Retrive data
            handles.FormData.subjNum = s; % Add the subj code num

            ix = 1; % Column index for window data
            for icc = 1 : numOfIcc % Go through all comp combinations
                % Report current estimate in the waitbar's message field
                abort = multiWaitbar( hdl2, title, icc/numOfIcc );
                if abort
                    %Here we would normally ask the user if they're sure
                    button = questdlg(qString,'Cancel?','No');
                    if strcmpi(button,'yes')
                        break;
                    else
                        abort = multiWaitbar( hdl2, title, ...
                            icc/numOfIcc, 'ResetCancel' );
                    end
                end

                compN1 = compList(icc,1);
                compN2 = compList(icc,2);

                if corrType == 1
                    % Get the correlation between the 2 components
                    cp = dfc_corrTWin(data_img(:,compN1),data_img(:,compN2),handles);
                    avePosCorrData = mean(cp); % Average the correlation to a point
                    % Store the largest of either the negative or the positive correlation
                    if avePosCorrData > 0
                        outData(s,icc) = avePosCorrData;
                    else
                        outData(s,icc) = -avePosCorrData;
                    end
                elseif corrType == 2
                    % Get the correlation between the 2 components
                    cp = dfc_corrTWin(data_img(:,compN1),data_img(:,compN2),handles);
                    % Calculate and plot expected data
                    ev = dfc_expVal(handles, 'on');
                    % Correlation between cp and ev
                    outData(s,icc) = corr(cp', ev');
                elseif corrType == 3 % Static DFC case
                    cp = dfc_corrTWin(data_img(:,compN1),data_img(:,compN2),handles,'windowing','off');
                    outData(s,icc) = cp;
                elseif corrType == 4 % Send the whole correlation window case
                    cp = dfc_corrTWin(data_img(:,compN1),data_img(:,compN2),handles);
                    iy = ix + length(cp) - 1;
                    outData(s,ix:iy) = cp;
                    ix = iy + 1;
                end
            end
            % Report current estimate in the waitbar's message field
            multiWaitbar( hdl1, title, s/numOfSubj ); %s-1 for mean
            if abort
                % If we aborted in the region loop, then break here.
                break
            end
        end
        % Close the progress bar
        multiWaitbar( hdl1, title, 'Close' );
        multiWaitbar( hdl2, title, 'Close' );
    end

    % Get rid of Nan values
    outData(isnan(outData)) = 0; 
end

