function [RegDFCData, h] = dfc_buildRegDFC(regMap, subjProp)
%DFC_BUILDRegDFC Build a .mat file with DFC Results
%   Detailed explanation goes here
%TODO: Add to action menu and generate after user is able to view region
%average and can play with window length and stepsize to determine ideal
%settings
    bContinue = true;
    nRegions = length(regMap);
    nSubjects = length(subjProp);
    maxTP = subjProp(1).srcDim(4);
    
    % If on windows, use parallel computing, on mac the OS does parallel itself
    if strcmpi(computer('arch'),'win64')
        usePfor = 1;
    else
        usePfor = 0;
    end

    %TODO: Make window length and step size allow user inputs
    %User can configure after region averages generated and output to the
    %Dynaconn window
   
    selection = questdlg("Use default window length and step size?");
    
    %Andrew and Zak added case for user input atlas and labels
    switch selection
        case 'Yes'
            windowLength = 32;
            stepSize = 8;  
%             
        case 'No'
            
            prompt = {'Please provide the Window Length:', 'Please provide the Step Size:'};
            dlgtitle = 'Window Step Selection';
            dims = [1 35];
            winstep = inputdlg(prompt, dlgtitle, dims);
            windowLength = winstep{1};
            stepSize = winstep{2};
           
        case 'Cancel'
            return
    end    
   
    % Initialize h so that if the h message window is not needed it can be
    % detected as not existing.
    h = 0;

    % Give user a message that we must build new data
    set(0, 'DefaultUicontrolFontsize', 12);
    Message = 'There isn''t any pre-existing data so new data is being built now';
    Title = 'Corr. Running';
    Icon = 'warn';
    h = msgbox(Message,Title,Icon);
    
    % TODO(Johnny) not sure what this is so just make it fixed for now
    numWindows = 5000;
    
    RegDFCData = zeros(nSubjects, nRegions, numWindows);
    
    tic;
   
    
    % TODO(Johnny) Andrew, this is where you would do whatever analysis you are
    % wanting to do.  For this example I'll just do an avg and you can
    % replace it.
    for ns = 1 : nSubjects
        for nr = 1 : nRegions
            for nw = 1 : numWindows
                RegDFCData(ns, nr, nw) = ns*nr*nw;
            end
        end
    end

    tEnd=toc;
    fprintf('Construction of region avgs took ');
    fprintf('%d minutes and %f seconds\n\n',floor(tEnd/60),rem(tEnd,60));
