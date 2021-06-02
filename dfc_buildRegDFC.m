function dfc_buildRegDFC(regMap,subjProp,settings )
%DFC_BUILDRegDFC Build a .mat file with DFC Results
%   Detailed explanation goes here
%TODO: Add to action menu and generate after user is able to view region
%average and can play with window length and stepsize to determine ideal
%settings

    nRegions = length(regMap);
    nSubjects = length(subjProp);
    maxTP = subjProp(1).srcDim(4);
    
    %TODO: Make window length and step size allow user inputs
    %User can configure after region averages generated and output to the
    %Dynaconn window
   
    selection = input('use default Window Length and stepSize? Y/N ', 's')
    %Andrew and Zak added case for user input atlas and labels
    switch selection
        case 'Y'
            windowLength = 32;
            stepSize = 8;  
%             
        case 'N'
            
            prompt1 = 'Please provide the Window Length: ';
            prompt2 = 'Please provide the Step Size: ';
            windowLength = input(prompt1);
            stepSize = input(prompt2);
           

    end    
    V = spm_vol(subjProp(s).srcFFile);    % open data file
    nTP = length(V);
    windowStart = [1:stepSize:nTP-windowLength+1];
    numWindows=length(windowStart);
    RegDFCData = zeros(nSubjects, nRegions, numRegions, numWindows);

    tic
    % Build list of indices from each reg prob layer that is above 50
    % The indices are without being masked
    for i = 1 : length(regMap)
        regMap(i).ind = find(regMap(i).prob > 50);
    end
    
    % Create progress bar for getting region average
    title = 'Building Region Dynamic Functional Correlations';
    hdl1 = 'Completion';
    %hdl2 = 'Region Completion';
    multiWaitbar( 'CloseAll', title );
    if settings.usePfor
        multiWaitbar( hdl1, title, 0, 'Color', 'g', 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );
    else
        multiWaitbar( hdl1, title, 0, 'Color', 'g', 'CanCancel', 'off');
        multiWaitbar( hdl2, title, 0, 'Color', 'r', 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );
    end
    qString = 'Are you sure you want to cancel?';
    abort = false;
    
    
    
  %This is the DFC Loop  
    for iss=1:nSubjects,
        iss=iss
        
        for iww = 1:numWindows
            myavgsignal_window1 = squeeze(RegAveData(iss,:,(iww-1)*stepSize+1:(iww-1)*stepSize+windowLength)); %changed from myavgsignal to _allsubjects
            myROIfc_window1 = corr(myavgsignal_window1');
            RegDFCData(iss, :, :, iww)=myROIfc_window1;
        end
    end
    
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