function [RegDFCData, h] = dfc_buildRegDFC(handles, regMap, subjProp)
%DFC_BUILDRegDFC Build a .mat file with DFC Results
%   Detailed explanation goes here
%TODO: Add to action menu and generate after user is able to view region
%average and can play with window length and stepsize to determine ideal
%settings
       
    bContinue = true;
    %TODO add save message
    load(uigetfile);
    nRegions = length(regMap);
    nSubjects = length(RegAveData(:,1,1,1));
    %maxTP = subjProp(1).srcDim(4);
   
%      V = spm_vol(subjProp(s).srcFFile);    % open data file
%     nTP = length(V);
%     windowStart = [1:stepSize:nTP-windowLength+1];
%     numWindows=length(windowStart);
%     RegDFCData = zeros(nSubjects, nRegions, numRegions, numWindows);
    
    % If on windows, use parallel computing, on mac the OS does parallel itself
    if strcmpi(computer('arch'),'win64')
        usePfor = 1;
    else
        usePfor = 0;
    end

   
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
            windowLength = str2num(winstep{1})
            stepSize = str2num(winstep{2})
           
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
%     timeN = handles.FormData.subjProp(1).srcDim(4)
%     windowSize = handles.FormData.windowSize
%     stepSize = handles.FormData.stepSize
%     display('pwd of buildRegDFC.m: ')
%     pwd
%     windowSize = load('windowSize')
%     timeN = load('timeN')
%     stepSize = load('stepSize')
    timeN = size(RegAveData,3)
    numWindows = ceil(.0001+(timeN - windowLength) / stepSize)
    nRegions = length(RegAveData(1,:,1));
    RegDFCData = zeros(nSubjects, nRegions, nRegions, numWindows);
    
    tic;
   
    
    %  This is where you would do whatever analysis you are
    % wanting to do.  
    
    %load the forms.
    for ns = 1 : nSubjects
        for nw = 1 : numWindows
            myavgsignal_window1 = squeeze(RegAveData(ns,:,(nw-1)*stepSize+1:(nw-1)*stepSize+windowLength)); %changed from myavgsignal to _allsubjects
            myROIfc_window1 = corr(myavgsignal_window1');
            RegDFCData(ns, :, :, nw)=myROIfc_window1;
        end
        
    end

    tEnd=toc;
    fprintf('Construction of Dynamic Functional Connectivity Matrix took ');
    fprintf('%d minutes and %f seconds\n\n',floor(tEnd/60),rem(tEnd,60));
