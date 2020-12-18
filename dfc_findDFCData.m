function [dataFileName, h] = dfc_findDFCData(handles)
    % dfc_findDFCData - Find DFC Data.
    %       This function 1st checks if there is already correlation matrix
    %       data in the workDir.  If so it just returns the .mat filename
    %       containing the data.  If not, then a new .mat file is generated
    %       with the data and placed in the workDir.
    %
    %       The data that is calculated is the correlation between all
    %       component combinations for all subjects.  The number of component
    %       combinations is based on nComp.  The number of subjects is based on
    %       what is found in the ICA_DIR.  ICA_Dir is a ICA post processed
    %       directory.  It helps to have the prefix_SelectedSubject.txt in
    %       there.

    


    %% CHECK FOR PRE-EXISTING DATA

    % Pull data need from handle
    window = handles.FormData.windowSize;
    step = handles.FormData.stepSize;
    workDir = handles.FormData.workDir;
    subjProp = handles.FormData.subjProp;
    mode = handles.mode;
    
    
    if strcmpi(mode,'reg')
        % By default we assume there is no region mean precompiled data
        useRegData = 0;
        % Build 1st part of mat file name to check if a mat file already
        % exists for pre-compiled region average data
        if handles.FormData.PCRADataExist == 1
            % Build 1st part of mat file name to check if a mat file already exists
            matFileName = 'DFC_PreCompRegionData';
            % Build pattern match for mat file
            expression1 = [matFileName '\.mat'];  % To match DFC_NetworkData_w32_s8_1.mat  
            % Get directory contents to check
            listing = dir(workDir);
            % Check if a .mat file with previous data exists
            for i = 1 : length(listing)
                [tokens, matchStr] = regexp(listing(i).name,expression1,'tokens','match');
                if length(tokens) == 1  %If this directory matches then read it
                    useRegData = 1;
                    regDataFile = matchStr;
                end
            end
        end
    end
    
    % Build pattern match for matrix correlation mat file
    matFileName = ['DFC_' mode '_w' num2str(window) '_s' num2str(step)];
    expression1 = [matFileName '\.mat'];  % To match DFC_NetworkData_w32_s8_1.mat
    dataFileName = [workDir filesep matFileName '.mat'];  % Save complete file name for saving data
    
    % Get directory contents to check
    listing = dir(workDir);
        
    % Initialize h so that if the h message window is not needed it can be
    % detected as not existing.
    h = 0;
    
    % Check if a .mat file with previous data exists
    for i = 1 : length(listing)
        [tokens,~] = regexp(listing(i).name,expression1,'tokens','match');
        if length(tokens) == 1  %If this directory matches then read it
            return; % Found data so don't need to look anymore
        end
    end
       
    
    %% NO PRE-EXISTING SO MAKE NEW DATA

    % Give user a message that we must build new data
    set(0, 'DefaultUicontrolFontsize', 12);
    Message = 'There isn''t any pre-existing data so new data is being built now';
    Title = 'Corr. Running';
    Icon = 'warn';
    h = msgbox(Message,Title,Icon);

    tic  
    if strcmpi(mode,'net')||strcmpi(mode,'group')
        subjProp = sortSubjPropByGroup(subjProp);
        % What is the smallest amount of components in the files
        nComp = subjProp(1).icDim(4);
        for s = 2 : length(subjProp)
            if subjProp(s).icDim(4) < nComp
                nComp = subjProp(s).nComp;
            end
        end
    elseif strcmpi(mode,'reg')
        subjProp = sortSubjPropByGroup(subjProp);
        nComp = length(handles.FormData.regMap);  %Number of regions
    end       
    % Get number of unique groups
    if strcmpi(mode,'group')
        for i = 1 : length(subjProp)
            groupNums(i) = subjProp(i).group;
        end
        uniqueGroups = unique(groupNums);
        nGroup = length(uniqueGroups);
    end
    
    

    %% RUNNING CORRELATION

    % Create combination list of components or regions 
    compList = combnk(1:nComp,2);
        
    % Run correlation for each combination of each subject
    if strcmpi(mode,'net')
        Ave_DFC_Combined = dfc_subjNetCorr(handles, compList, subjProp, 1);
    elseif strcmpi(mode,'reg')
        % Settings for running region dfc
        settings.useRegData = useRegData;
        settings.usePfor = handles.FormData.usePfor; % Run in parallel if set
        settings.workDir = workDir;
        settings.regAveFile = [workDir filesep 'DFC_PreCompRegionData.mat'];
        
        Ave_DFC_Combined = ...
            dfc_subjRegionCorr(handles, compList, settings, subjProp);
    elseif strcmpi(mode,'group')
        groupList = combnk(1:nGroup,2);
        Ave_DFC_Combined = dfc_groupTTest2(handles, compList, groupList);
    end

    % Insert a border
    if strcmpi(mode,'net')||strcmpi(mode,'reg')
        [Ave_DFC_Combined, subjProp] = ...
            insert_border(Ave_DFC_Combined, mode, subjProp,'low');
    end

    % Build sorted Ave list based on ctrl sum correlation.
    % Also build list of sorted corr averages for ctrl and patients
    [Sorted_Ave_DFC_Combined, compOrder] = ...
        sort_corrs(Ave_DFC_Combined, subjProp, mode);


    % Save the data
    save(dataFileName, 'Sorted_Ave_DFC_Combined', ...
        'compList','compOrder','workDir','subjProp');
    
    tEnd=toc;
    fprintf('Construction of DFC matrix took ');
    fprintf('%d minutes and %f seconds\n\n',floor(tEnd/60),rem(tEnd,60));
end

    
function [ new_subjProp ] = sortSubjPropByGroup(subjProp)
%% Sort subjects by group number
    gNum = [subjProp.group];
    [~,gIx] = sort(gNum);
    ix = 1;
    for i = gIx
        new_subjProp(ix) = subjProp(i);
        ix = ix + 1;
    end
end

