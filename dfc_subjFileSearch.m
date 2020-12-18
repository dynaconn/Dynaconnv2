function [ subjProp, status ] = dfc_subjFileSearch( subjDir )
%DFC_SUBJFILESEARCH Find the subject files and codes in subjDir
%   Check if this subjDir has nii files in it.
%   If this fails then search each sub dir for nii files.
%   If this fails, then we give up and report no nii files found.
%
%   Requires:
%       handles.FormData.subj
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
%
% 20Aug2013 - Original
% 10Oct2013 - Added waitbar/progressbar
% 05Dec2013 - Remove mean subject

    % Get contents of this directory
    listing = dir(subjDir);
    numOfItems = length(listing);

    % Create progress bar for scanning subjects for subjProp info
    h = waitbar(0,'1','Name','Scanning for subjects',...
    'CreateCancelBtn',...
    'setappdata(gcbf,''canceling'',1)');

    nifti_expr = '.+\.nii';  % Expression for nifti files.
    file_expr = '(.+)\.nii';

    % Check if this subjDir has nii files in it.
    % If this fails then search each sub dir for nii files.
    % If this fails, then we give up and report no nii files found.
    found_thisLvlNifti = 0;
    ix = 1; % subject index
    iy = 1; % Sub-folder index
    for f = 1 : length(listing)
        % Check for Cancel button press
        if getappdata(h,'canceling')
            break
        end
        % Report current estimate in the waitbar's message field
        progress = f/numOfItems;
        progStatus = sprintf('Reading top level directory. Processing %d of %d', f, 2*numOfItems);
        waitbar(progress,h,progStatus)
  
        % Check if this is a nifti file
        if any(regexp(listing(f).name, nifti_expr)) && 1
            found_thisLvlNifti = 1;
            [tokens, matchStr] = regexpi(listing(f).name, file_expr, 'tokens', 'match');
            subjProp(ix).index = ix;
            subjProp(ix).srcFFile = [subjDir filesep matchStr{1}];
            subjProp(ix).code = tokens{1}{1};
            subjProp(ix).icFFile = '';
            subjProp(ix).tcFFile = '';
            % Open volume to get time point length
            V = spm_vol(subjProp(ix).srcFFile);
            subjProp(ix).srcDim = V(1).dim;
            subjProp(ix).srcDim(4) = length(V);
            subjProp(ix).icDim = [0 0 0 0];
            subjProp(ix).tcDim = [0 0 0];
            ix = ix + 1;
        end
        % In case we need to search sub folders later keep a list of them.
        fullSubDir = [subjDir filesep listing(f).name];
        if  exist(fullSubDir, 'dir') == 7 && ~strcmpi(listing(f).name, '.') ...
          && ~strcmpi(listing(f).name, '..')
            subFolder{iy} = fullSubDir;
            iy = iy + 1;
        end
    end
    
    % If we didn't find any nifti files in this lvl, then search the sub
    % folders
    % First get all the sub folders and files in those sub folder.
    if found_thisLvlNifti == 0 && ~isempty(subFolder)
        numOfItems = length(subFolder);
        ix = 1; % Subject index
        % Go through every dir and check if it contains a nifti file
        for f = 1 : numOfItems
            % Check for Cancel button press
            if getappdata(h,'canceling')
                break
            end       
            % Report current estimate in the waitbar's message field
            progress = f/numOfItems;
            progStatus = sprintf('Reading sub directories. Reading %d of %d', f, numOfItems);
            waitbar(progress,h,progStatus)

            dirFiles = dir(subFolder{f}); % Get itemss from this directory
            for lf = 1 : length(dirFiles)
                % Check if this is a nifti file
                if any(regexp(dirFiles(lf).name, nifti_expr)) && 1
                    [tokens, matchStr] = regexpi(dirFiles(lf).name, file_expr, 'tokens', 'match');
                    subjProp(ix).index = ix;
                    subjProp(ix).code = tokens{1}{1};
                    subjProp(ix).srcFFile = [subFolder{f} filesep matchStr{1}];
                    subjProp(ix).icFFile = '';
                    subjProp(ix).tcFFile = '';
                    % Open volume to get time point length
                    V = spm_vol(subjProp(ix).srcFFile);
                    subjProp(ix).srcDim = V(1).dim;
                    subjProp(ix).srcDim(4) = length(V);
                    subjProp(ix).icDim = [0 0 0 0];
                    subjProp(ix).tcDim = [0 0 0];
                    ix = ix + 1;
                end
            end
        end
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
    
    

