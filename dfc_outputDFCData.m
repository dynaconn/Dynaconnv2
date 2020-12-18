function [ DFNC_Matrix ] = dfc_outputDFCData( handles )
%dfc_outputDFCData Generate a matrix of DFNC results from GIFT data
%   Input:
%       mode = can be net, reg, or group, which means GIFT, Region, or Group mode.
%       subjProp = properties for all subjects
%       dataType = Type of DFC output
%         1) DFC Data
%         2) EV modulated DFC Data
%         3) Static FC Data
%         4) DFC with all correlation windows
%         5) DFC with region coverage
%       windowSize = window size determine the number of time point used for
%                correlation between the 2 components during DFNC
%       stepSize = step size used to determine how many time points the window
%              will move across the time space after each correlation.
%   Output:
%     DFNC_Matrix is a matrix of the dynamic functional network averages.
%     Row 1: Column index
%     Row 2: IC1 of the IC combinations
%     Row 3: IC2 of the IC combinations
%     (only for type 4 & 5) Row 4: cross-correlation coeff # (1 through 44)
%
%     Last column: Group number (ie. 1,2,..)
%     2nd to last column: Unique subject ID
%
%   Procedure:
%       First scan the directory for the mean file
%       Find the positive and negative significate regions of each mean
%       component
%       Iterate through each subject and get average of each seperate
%       positive or negative regions.
%
%   Original: 1Nov2013 - johne
%   Modified:
%            26Nov2013 - johne, Added rows 2&3 to be component number from
%            DFNC component combination correlation.
%
%

    % If used inside DFC_GUI then just add the relative paths
    %addpath('spm8');
    
    status = 1; % 1 = no error,  0 = error
    
    % Shorten handle var names for readability
    mode = handles.mode;
    subjProp = handles.FormData.subjProp;
    dataType = handles.FormData.dataType;
    windowSize = handles.FormData.windowSize;
    stepSize = handles.FormData.stepSize;
    
    % Remove the mean for this analysis.  Mean is the 1st subjProp
    ix = 1;
    for i = 2 : length(subjProp);
        tmp_subjProp(ix) = subjProp(i);
        ix = ix + 1;
    end
    
    % Copy over the tmp subjProp to subjProp, clear the tmp variable and 
    % get count of subjects.
    subjProp = tmp_subjProp;
    clear tmp_subjProp;
    numOfSubj = length(subjProp);

    % Make sure all subjects have same # of timepoints
    numOfTP = subjProp(1).tcDim(1);
    for i = 2 : length(subjProp)
        if subjProp(i).tcDim(1) ~= numOfTP
            etxt = sprintf('Mismatch in time points for subject %s = %d', ...
                subjProp(i).code, subjProp(i).tcDim(1));
            errordlg(etxt);
            status = 0;
            break;
        end
    end
    
    % Make sure all subjects have same # of components
    numOfComp = subjProp(1).tcDim(2);
    for i = 2 : length(subjProp)
        if subjProp(i).tcDim(2) ~= numOfComp
            etxt = sprintf('Mismatch in components for subject %s = %d', ...
                subjProp(i).code, subjProp(i).tcDim(2));
            errordlg(etxt);
            status = 0;
            break;
        end
    end
    
    % Get timeN number of time points (basically number of windows)
    if strcmpi(mode, 'net') || strcmpi(mode, 'ev')
        timeN = subjProp(1).tcDim(1);
    elseif strcmpi(mode, 'reg')
        timeN = subjProp(1).srcDim(4);
    end
            
    % Create list of component combinations
    compList = combnk(1:numOfComp,2);
    if dataType <= 3
        numOfCols = size(compList,1);
    elseif dataType == 4
        numOfWindows = uint16(ceil((timeN - windowSize) / stepSize));
        numOfCols = size(compList,1) * numOfWindows;
    end
        
    if status
        % Get correlation between all combinations
        handles.FormData.subjProp = subjProp; % Send "no mean" subjProp
        DFNC_Matrix = dfc_subjNetCorr(handles, compList, subjProp, dataType);

        % Create list of unique identifiers
        subjProp = dfc_uniqueSubID(subjProp);

        % Go through each subject (excluding mean) and add unique and group IDs.
        col_UID = numOfCols + 1;
        col_Grp = col_UID + 1;
        for subj = 1 : numOfSubj
            % Add unique ID
            DFNC_Matrix(subj,col_UID) = subjProp(subj).codeID;

            % Add subject type for last column
            DFNC_Matrix(subj,col_Grp) = subjProp(subj).group;
        end
        
        % Add component combination as labels. row2 = comp1, row3 = comp2
        if dataType <= 3
            DFNC_Matrix = [compList(:,1)',0,0; compList(:,2)',0,0; DFNC_Matrix()];
            % Add features ID to row 1
            DFNC_Matrix=[1:size(DFNC_Matrix,2);DFNC_Matrix()];
        elseif dataType == 4
            % Make list of column headers be combination * windows long
            colIx = 1;
            for i = 1 : size(compList,1)
                for j = 1 : numOfWindows
                    row1(colIx) = colIx;
                    row2(colIx) = compList(i,1);
                    row3(colIx) = compList(i,2);
                    row4(colIx) = j;
                    colIx = colIx + 1;
                end
            end
            r1 = double(row1); r2 = double(row2); r3 = double(row3); r4 = double(row4);
            DFNC_Matrix = [r1,0,0; r2,0,0; r3,0,0; r4,0,0; DFNC_Matrix];
        end

    end
end



