function [ mask_ind ] = dfc_getMaskInd( maskFile )
%DFC_GETMASKIND Retrieve the mask indicies
%   Input - Char mask file name
%   Ouput - Vector of mask indicies


    vol_info = spm_vol(maskFile);
    img = spm_read_vols(vol_info);
    dim = size(img);
    
    % If this img is not 2mm (x=91) then scale
    if dim(1) ~= 91        
        if ndims(img)==3
            newImg = dfc_resizeImg((91/dim(1)), img);
        elseif ndims(img)==4
            % Create progress bar for resizing image
            h = waitbar(0,'1','Name','Resizing Image to 2mm Space',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');

            for i = 1 : dim(4)
                % Check for Cancel button press
                if getappdata(h,'canceling')
                    break
                end
                % Report current estimate in the waitbar's message field
                progress = i/dim(4);
                status = sprintf('Converting slice %d of %d', i, dim(4));
                waitbar(progress,h,status)
                newImg(:,:,:,i) = ...
                    dfc_resizeImg((91/dim(1)), img(:,:,:,i));
            end
            delete(h)   % DELETE the waitbar; don't try to CLOSE it.
        end
        clear img;
        img = newImg;
        clear newImg;
    end
      
    imgFlat = reshape(img,[],1);
    mask_ind = find(imgFlat ~= 0);
end

