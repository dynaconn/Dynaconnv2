function [ charArray ] = cellArray2charArray( cellList )
%CELLARRAY2CHARARRAY Converts a string cell array to a char array
%   Converts a cell array of strings into a char array.  Strings that are
%   shorter than the longest string are paddded with blank characters.

%     % Get longest code
%     maxColumns = 0;
%     for i = 1 : length(cellList)
%         a = length(cellList{i});
%         if a > maxColumns, maxColumns = a; end
%     end

    % Convert cell array to char array
    cList = cell(size(cellList,2),1);
    for i = 1 : length(cellList)
        cList(i) = cellList(i);
    end
    charArray = char(cList);
end

