function [ codeList ] = popPopMenu( subjProp, type )
%POPPOPMENU Creates string list to send to pop-up menu
%   Input:
%       subjProp = Subject property structure
%
%       type = Which property to build the string list from which can be
%              'code' = Subject code, such as AQI. Used in GIFT mode.
%              'ic' = IC file name, such as prefix_sub002_component...
%              'tc' = TC file name, such as prefix_sub002_timecourses...
%              'src' = Source file name, such as AQI3.
%   Output:
%       Create the codeList from subjProp.name or subjProp.code

    % Add each subject to the list
    for i = 1 : length(subjProp)
        if strcmpi(type, 'code')
            cellList{i} = subjProp(i).code;
        elseif strcmpi(type, 'ic')
            [~,fname,~] = fileparts(subjProp(i).icFFile);
            cellList{i} = fname;
        elseif strcmpi(type, 'tc')
            [~,fname,~] = fileparts(subjProp(i).tcFFile);
            cellList{i} = fname;
        elseif strcmpi(type, 'src')
            [~,fname,~] = fileparts(subjProp(i).srcFFile);
            cellList{i} = fname;
        end
    end
    
    % Convert cell array to char array
    codeList = cellArray2charArray(cellList);

end

