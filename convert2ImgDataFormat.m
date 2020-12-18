function [ data_out, sliceRange ] = convert2ImgDataFormat( CFName, start, stop )
%CONVERT2IMGDATAFORMAT Summary of this function goes here
%   Detailed explanation goes here
    
    % Open the data image for the 1st comp and 2nd comp
    vol_info = spm_vol(CFName(1).name);    % open data file
    data_img(:,:,:,1) = spm_read_vols(vol_info); % Retrive data
    clear vol_info;
    vol_info = spm_vol(CFName(2).name);    % open data file
    data_img(:,:,:,2) = spm_read_vols(vol_info); % Retrive data
    clear vol_info
    
    % This assumes img1 and img2 are the same size, which should be true
    % because they are just 2 different components of the same post ICA
    % data.
    DIM = size(data_img);
    
    % Number of windows for slices in the GUI
    nSlice = 20;
    
    % Get step size for slices
    SSize = (stop - start) / (nSlice -1);
    
    ind = start;
    for i = 1 : 20
        sliceRange(i) = round(ind);
        ind = ind + SSize;
    end
        
    
        % Slice numbers
    %sliceRange = [-80 -74 -68 -62 -56 -50 -44 -38 -32 -26 -20 -14 -8 -2 4 10 16];
    %sliceRange = 1:6:91;
    
    data_out = zeros(2,DIM(1),DIM(2),length(sliceRange));
    
    for comp = 1 : DIM(4)
        for x = 1 : DIM(1)
            for y = 1 : DIM(2)
                sri = 1; % sliceRange index
                for z = 1: DIM(3)
                    if sliceRange(sri) == z
                        data_out(comp,x,y,sri) = data_img(x,y,z,comp);
                        sri = sri + 1;
                        if sri > length(sliceRange), break; end;
                    end
                end
            end
        end
    end

end
