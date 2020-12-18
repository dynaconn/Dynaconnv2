function handles = dfc_findPreCompRegData(handles)
    % dfc_findPreCompRegData - Find or build preComp region data.
    %       This function 1st checks if there is already pre-compiled
    %       component region data.  If not it builds it.

    


    %% CHECK FOR PRE-EXISTING DATA

    % Pull data need from handle
    regMap = handles.FormData.regMap;
    subjProp = handles.FormData.subjProp;
    workDir = handles.FormData.workDir;
    usePfor = handles.FormData.usePfor; % Run in parallel
    
    % Build 1st part of mat file name to check if a mat file already exists
    matFileName = 'DFC_PreCompRegionData';
    saveFileName = [workDir filesep matFileName '.mat'];  % Save complete file name for saving data
    
    % Build pattern match for mat file
    express1 = [matFileName '\.mat'];  % To match DFNC_NetworkData_w32_s8_1.mat  
    
    % Get directory contents to check
    listing = dir(workDir);
        
    % Initialize h so that if the h message window is not needed it can be
    % detected as not existing.
    h = 0;
    
    % Check if a .mat file with previous data exists
    for i = 1 : length(listing)
        [tokens, ~] = regexp(listing(i).name,express1,'tokens','match');
        if length(tokens) == 1  %If this directory matches then read it
            handles.FormData.PCRADataExist = 1;
            return; % Found data so don't need to look anymore
        end
    end
       
    
    %% ASK IF WE SHOULD GENERATE NEW DATA
    Message = sprintf(['Would you like to generate average data for all subjects?\n' ...
        ' Without this data Region mode can''t be used, but it could' ...
        ' take a long time to generate the data, depending on the number of' ...
        ' subjects.']);
    set(0, 'DefaultUicontrolFontsize', 12);
    choice = questdlg(Message,'Precompile Region Averge Data?','Continue','Cancel','Continue');
    % Handle response
    switch choice
        case 'Continue'
            disp(['Generation Region Average Data'])
        case 'Cancel'
            handles.FormData.PCRADataExist = 0;
            return; % Found data so don't need to look anymore
    end

    %% NO PRE-EXISTING SO MAKE NEW DATA
    settings.usePfor = usePfor;
    settings.regAveFile = saveFileName;
    dfc_buildRegAveData(regMap,subjProp,settings);
    handles.FormData.PCRADataExist = 1;
    handles.FormData.PCRAFile = saveFileName;
end

    
