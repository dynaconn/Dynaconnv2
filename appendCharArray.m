function [ new_char_array ] = appendCharArray( array1, array2 )
%APPENDCHARARRAY Append char array2 to char array1
%   Detailed explanation goes here

    % Go through all input char arrays and get max string size
   if size(array1,2) > size(array2,2)
       maxColumns = size(array1,2);
   else maxColumns = size(array2,2);
   end
    
    % Make new char array to fit all strings
    index = 1;
    pad = blanks(maxColumns - size(array1,2));
    for i = 1 : size(array1,1)
        new_char_array(index,:) = [array1(i,:), pad];
        index = index + 1;
    end

    pad = blanks(maxColumns - size(array2,2));
    for i = 1 : size(array2,1)
        new_char_array(index,:) = [array2(i,:), pad];
        index = index + 1;
    end
end

