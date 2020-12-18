function outData = dfc_subjRegionCorr(handles, regList, settings, sortedSubjProp)
%DFC_SUBJREGIONCORR Summary of this function goes here
%   Detailed explanation goes here
   
    % Shorten form data var name for readability
    %subjProp = handles.FormData.subjProp;
    %regMap = handles.FormData.regMap;
    
    % % % % This section of code would cause a problem because it would
    % build the region average data with the reordered subjProp
    % % % % 
    % Build saved data name to either use or build
    %if settings.useRegData == 0
    %    dfc_buildRegAveData(regMap, subjProp, settings);
    %end
    
    % Retrieves RegAveData(s,r,t)
    load(settings.regAveFile);

    % Allocate memory for outData (final data)
    outData = zeros(length(sortedSubjProp),length(regList));
   
    % Create progress bar for getting region average
    title = 'Correlating subject''s Region combinations';
    hdl1 = 'Subject Completion';
    hdl2 = 'Region Combination Completion';
    multiWaitbar( 'CloseAll', title );
    if settings.usePfor
        multiWaitbar( hdl1, title, 0, 'Color', 'g', 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );
    else
        multiWaitbar( hdl1, title, 0, 'Color', 'g', 'CanCancel', 'off');
        multiWaitbar( hdl2, title, 0, 'Color', 'r', 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );
    end
    qString = 'Are you sure you want to cancel?';
    abort = false;
    
    % Go through all subjects
    numOfSubj = size(RegAveData,1);
    numOfRegCs = length(regList);
    for s = 1 : numOfSubj
        % Go through all region combinations
        for rc = 1 : numOfRegCs
            % Report current estimate in the waitbar's message field
            abort = multiWaitbar( hdl2, title, rc/numOfRegCs );
            if abort
                %Here we would normally ask the user if they're sure
                button = questdlg(qString,'Cancel?','No');
                if strcmpi(button,'yes')
                    break;
                else
                    abort = multiWaitbar( hdl2, title, ...
                        rc/numOfRegCs, 'ResetCancel' );
                end
            end
            % Translate this subject number to the reordered numbers
            st = sortedSubjProp(s).index;
            sig1 = squeeze(RegAveData(st,regList(rc,1),:));
            sig2 = squeeze(RegAveData(st,regList(rc,2),:));     
            % Get correlation between these 2 regions
            tmpCorrData = dfc_corrTWin(sig1,sig2, handles);
            tmpCorrData(isnan(tmpCorrData)) = 0;
            % Store mean correlation
            aveCorrData = mean(tmpCorrData);
            if aveCorrData > 0
                outData(s,rc) = aveCorrData;
            else
                outData(s,rc) = -aveCorrData;
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

    % Get rid of Nan values
    outData(isnan(outData)) = 0; 
end

