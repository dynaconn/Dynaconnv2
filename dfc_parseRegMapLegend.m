function [ labels ] = dfc_parseRegMapLegend( labelFile )
%DFC_PARSEREGMAPLEGEND  - Return the a cell array that is a list of
    % strings which are the labels for each layer of a region map loaded
    % elsewhere.
    
    % Is this file a xml type or text type
    sub_expr1 = '.*\.xml$';
    sub_expr2 = '.*\.txt$';
    if any(regexpi(labelFile, sub_expr1)) && 1
        type = 1;
    elseif any(regexpi(labelFile, sub_expr2)) && 1
        type = 2;
    else
        fprintf('ERROR - Can''t read this type of region map legend file\n');
        return;
    end
    
    % Attempt to open the label file
    fileID = fopen(labelFile);
    if fileID == -1
        fprintf('\nERROR - Couldn''t open %s\n', labelFile);
        return
    end
        
    % Set search expression
    if type == 1  % xml case
        expr = 'label.*>([-,\(\)''\w\s]+)</label>';  % What to search for in xml
    elseif type == 2 % txt file case
        expr = '\d+\s+([\w_\d]+)\s*\d*';  % What to search for in xml
    end
  
    % Begin parsing
    row = 1;   
    % Read each line till end of file, which is -1
    while 1 % Escape from loop using break
        line = fgetl(fileID);
        if line == -1;  % Exit condition
            break;
        end
        % Check for label data
        [token,ix] = regexpi(line,expr,'tokens');

        % If we do have a label then store and increment row
        if length(token) >= 1
            labels{row} = token{1};
            row = row + 1;
        end
    end   
    fclose(fileID);

end

