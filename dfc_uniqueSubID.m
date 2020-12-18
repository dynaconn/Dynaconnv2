function [ subjProp ] = dfc_uniqueSubID( subjProp )
%dfc_uniqueSubID    Find unique subjects
%
%  Inputs:
%       subjProp.code - Parent folder name, which is the subject name in
%       GIFT
%
%
% The unique subject ID is specifically for SST and RRT analysis. It uses
% only the inner character code.
% For instance, for the following 6 subject, there are 4 unique IDs.
% RR1_AQI3_C = 1
% RR1_LFR2_P = 2
% RR1_LFR3_P = 2
% RR2_AQI3_C = 1
% RR2_MNW_C = 3
% RR2_ZMI_P = 4
% RR3_ZMI_P = 4
%
    % Expression to find central code
    expression = 'R*\d*_?(\w\w\w)\d*';
    
    % Get the central code out of this subjProp
    cenCodeInd = 1;
    cenCode = struct('name','');
    for i = 1 : length(subjProp)
        [tokens, ~] = regexp(subjProp(i).code,expression,'tokens','match');
        if ~isempty(tokens)
            % Get code from tokens
            code = tokens{1}{1};
            
            % See if this code already exists
            match = 0;
            for j = 1 : length(cenCode)
                if strcmpi(cenCode(j).name,code)
                    match = 1;
                end
            end
                
            % If no match to this code then add to subjProp
            if match == 0
                cenCode(cenCodeInd).name = code;
                subjProp(i).codeID = cenCodeInd;
                cenCodeInd = cenCodeInd + 1;
            else
                % Get cenCodeNum for this code
                for k = 1 : length(cenCode)
                    if strcmpi(cenCode(k).name,code)
                        subjProp(i).codeID = k;
                        break;
                    end
                end
            end
        end
    end

end

