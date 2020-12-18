function outData = dfc_groupTTest2(handles, compList, groupList)
%DFC_SUBJEVCORR Summary of this function goes here
%   Detailed explanation goes here
    
    % How many component and group combinations are there
    nComps = size(compList,1);
    nGroups = size(groupList,1);
    
    % Create progress bar for calculating all dfc
    title = 'Building Group p-value averages';
    hdl1 = 'Group Completion';
    hdl2 = 'Component Completion';
    multiWaitbar( 'CloseAll', title );
    multiWaitbar( hdl1, title, 0, 'Color', 'g', 'CanCancel', 'off');
    multiWaitbar( hdl2, title, 0, 'Color', 'r', 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );

    % output matrix
    outData = zeros(nGroups, nComps);
    
    % Go through every group combination
    for i = 1 : nGroups
        GN1 = groupList(i,1);
        GN2 = groupList(i,2);
        % Go through every component combination
        for j = 1 : nComps          
            % Report current estimate in the waitbar's message field
            abort = multiWaitbar( hdl2, title, j/nComps );
            if abort
                %Here we would normally ask the user if they're sure
                button = questdlg(qString,'Cancel?','No');
                if strcmpi(button,'yes')
                    break;
                else
                    abort = multiWaitbar( hdl2, title, ...
                        j/nComps, 'ResetCancel' );
                end
            end 
            CN1 = compList(j,1);
            CN2 = compList(j,2);
            [~,~,pV,hV] = dfc_calcGroupDFCTTest(handles,GN1,GN2,CN1,CN2);
            % Create a matrix of p-values values. Change output to hV
            % to create a matrix of null hypo instead.
            outData(i,j) = mean(pV);
            %outData(i,j) = mean(hV);
        end     
                    
        % Report current estimate in the waitbar's message field
        multiWaitbar( hdl1, title, i/nGroups ); %s-1 for mean
        if abort
            % If we aborted in the region loop, then break here.
            break
        end
    end
    
    % Remove non number values
    outData(isnan(outData)) = 0;
    
    % Close the progress bar
    multiWaitbar( hdl1, title, 'Close' );
    multiWaitbar( hdl2, title, 'Close' );
    
end

