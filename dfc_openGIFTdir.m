function [ subjProp, status ] = dfc_openGIFTdir(GIFTDir)
%dfc_openGIFTdir Search for all subjects in a GIFT ICA directory
%
%   Requires:
%       GIFTDir = Directory of GIFT ICA results, need the 
%                 SelectedDataFolders to be in the dir.
%   Returns:
%       subjProp.index
%       subjProp.code
%       subjProp.srcFFile
%       subjProp.srcDim
%       subjProp.icFFile
%       subjProp.icDim
%       subjProp.tcFFile
%       subjProp.tcDim
%       status.subj
%       status.dataMod
    
    % Make sure this directory exists then list it
    if exist(GIFTDir,'dir') == 7
        listing = dir(GIFTDir);
        numOfItems = length(listing);
    else
        errordlg('Input directory does not exist in openGIFTdir.m');
        return;
    end
    
    % Get data prefix (ie. Prefix_sub001_component_ica_s1.nii)
    found = 0;  % Assume we have no match
    expr = '([\w\d]+)_sub\d+_component_ica_s';
    for i = 1 : numOfItems
        tokens = regexp(listing(i).name, expr, 'tokens');
        if length(tokens) == 1
            found = 1;
            prefix = tokens{1}{1};
            handles.FormData.prefix = prefix;
            break;
        else % In else case there is no prefix
            found = 1;
            prefix = '';
            handles.FormData.prefix = prefix;
        end
    end
    if ~found
        errordlg('Didn''t find the data prefix (ie. Prefix_sub001_co...');
        return;
    end
    
        
    % Create subjProp struct for storing the subject data
    % Populate with 'Mean', so to check if it is empty you must check if
    % length(subjProp) > 1
    subjProp(1).index = 1;
    subjProp(1).code = 'Mean';
    subjProp(1).srcFFile = '';
    subjProp(1).srcDim = [0 0 0 0];
    subjProp(1).icFFile = [GIFTDir filesep prefix '_mean_component_ica_s1_.nii'];
    subjProp(1).tcFFile = [GIFTDir filesep prefix '_mean_timecourses_ica_s1_.nii'];
    % Get dimension of comp mean by reading the vol info
    vol_info = spm_vol(subjProp(1).icFFile);
    subjProp(1).icDim = vol_info(1).dim;
    subjProp(1).icDim(4) = length(vol_info);
    % Get dimension of tc mean by reading the vol info
    vol_info = spm_vol(subjProp(1).tcFFile);
    subjProp(1).tcDim = vol_info(1).dim;
    
    
    % Check for selectedDataFolders.txt
    found = 0;  % Assume we have no match
    expr = ['(' prefix 'SelectedDataFolders.txt)'];
    for i = 1 : numOfItems
        tokens = regexpi(listing(i).name, expr, 'tokens');
        if length(tokens) == 1
            found = 1;
            %mapFullPath = strcat(subjDir, filesep, tokens{1}{1});
            mapFullPath = [GIFTDir, filesep, tokens{1}{1}];
            break;
        end
    end
    if ~found
        errordlf(['Couldn''t find ' expr]);
        return;
    end
    
    
    % Read the subject map which returns full directory of nii file
    fid = fopen(mapFullPath);
    % Check if file exists
    if fid == - 1
        fprintf('\n\nERROR - File %s, doesn''t exist\n\n', mapFullPath);
        return;
    end
    % Parse the text data file
    pat = '%s';  % Pattern to read
    % Parse the file; replace whitespace with '\ '
    fileList = textscan(fid, pat, 'delimiter', {'\r','\n'}, 'whitespace', '\\');
    numOfSubj = length(fileList{1});
    fclose(fid); % Close the txt file.
    
    % Create progress bar for scanning subjects for subjProp info
    h = waitbar(0,'1','Name','Scanning for subjects',...
    'CreateCancelBtn',...
    'setappdata(gcbf,''canceling'',1)');

    % Get code list from fileList and build subjProp.  Start subjProp at 2
    % since mean is 1
    expr = '([\w\d_]+$)';
    for i = 1 : numOfSubj
        % Check for Cancel button press
        if getappdata(h,'canceling')
            break
        end
        % Report current estimate in the waitbar's message field
        progress = i/numOfSubj;
        progStatus = sprintf('Reading %d of %d', i, numOfSubj);
        waitbar(progress,h,progStatus)
        % Populate subjProp
        [tokens, matchStr] = regexpi(fileList{1}{i}, expr, 'tokens', 'match');
        subjProp(i+1).index = i+1; % +1 for mean
        subjProp(i+1).code = tokens{1}{1};
        subjNumTxt = char(sprintf('%03d',i)); % Add leading zeros like 6 = 006
        subjProp(i+1).icFFile = [GIFTDir filesep prefix '_sub' subjNumTxt '_component_ica_s1_.nii'];
        subjProp(i+1).tcFFile = [GIFTDir filesep prefix '_sub' subjNumTxt '_timecourses_ica_s1_.nii'];
        % Get dimension of comp mean by reading the vol info
        vol_info = spm_vol(subjProp(i+1).icFFile);
        subjProp(i+1).icDim = vol_info(1).dim;
        subjProp(i+1).icDim(4) = length(vol_info);
        % Get dimension of tc mean by reading the vol info
        vol_info = spm_vol(subjProp(i+1).tcFFile);
        subjProp(i+1).tcDim = vol_info(1).dim;
        % Find source nifti file
        subjProp(i+1).srcFFile = getSrcNiftiFromDir(fileList{1}{i});
        % Get dimension of src File
        vol_info = spm_vol(subjProp(i+1).srcFFile);
        subjProp(i+1).srcDim = vol_info(1).dim;
    end 
    delete(h)   % DELETE the waitbar; don't try to CLOSE it.
    
    % If we read in some subject then update the status
    if length(subjProp) > 1
        status.dataMod = 1;
        status.subj = 1;
    else
        warndlg('Didn''t find any nifti files');
        status.dataMod = 0;
        status.subj = 0;
    end
end
    


function [ fullFile ] = getSrcNiftiFromDir( inputDir )
    % Return the nifti file in this dir
    nifti_expr = '.+\.nii';  % Expression for nifti files.
    
    listing = dir(inputDir);
    
    for f = 1 : length(listing)
        [~, matchStr] = regexpi(listing(f).name, nifti_expr, 'tokens', 'match');
        if length(matchStr) > 0
            fullFile = [inputDir filesep matchStr{1}];
            break;
        end
    end
end
