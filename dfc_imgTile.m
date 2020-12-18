function [ outData, sliceRange, maxVal, minVal ] = dfc_imgTile( param, img )
%% DFC_IMGTILE Summary of this function goes here
%   Detailed explanation goes here

    convertToZ = 1;
    
    numOfComp = param.numOfComp;
    start = param.start;
    stop = param.stop;
    mm = param.mm;
    nn = param.nn;
    LL = param.LL;
    UL = param.UL;

    % Number of windows for slices in the GUI
    nSlice = 20;
    
    % Get step size for slices
    SSize = (stop - start) / (nSlice -1);
    
    ind = start;
    sliceRange = zeros(1,20);
    for i = 1 : 20
        sliceRange(i) = round(ind);
        ind = ind + SSize;
    end
    
    
    % Load the structural image
    load('overlayIm.mat');
    
    
    for comp = 1 : numOfComp  % Operate on both components
    
        icaData = squeeze(img(comp,:,:,:)); % Retrive data    
        
        % Get just the z slices we want out of the data
        [structIm, icasig] = grabSelectedSlices(structuralImage, icaData,sliceRange);
        clear icaData;
    
        siz = size(icasig);
        A = zeros(siz(2),siz(1),siz(3));
        B = A;
        % Transpose and flip the data and reverse z slice order
        for z = 1: siz(3)
            A(:,:,siz(3)+1-z) = fliplr(flipud(icasig(:,:,z)'));
            B(:,:,siz(3)+1-z) = fliplr(flipud(structIm(:,:,z)'));
        end

        icasig = A; structIm = B; clear A B;
        siz = size(icasig);

        % Build montages of both slice sets
        icasigMot = buildMontage(icasig, mm, nn);
        structImMot = buildMontage(structIm, mm, nn);
        clear icasig;

        % Flatten the data
        siz = size(icasigMot);
        icaFlatMot = reshape(icasigMot,siz(1)*siz(2),1);
        structFlatMot = reshape(structImMot,siz(1)*siz(2),1);
        clear icasig;
 
        % Overlay ica data onto fMRI background
        [overlays,maxVal(comp),minVal(comp)] = add_overlay(icaFlatMot, ...
            structFlatMot, LL(comp), UL(comp));

        % Inflate the data
        outData(:,:,comp) = reshape(overlays,siz(1),siz(2));
    end
              
    % Since we reversed the order of z images, also flip the sliceRange
    % numbers
    sliceRange = fliplr(sliceRange); 
    

end
    

    
% Overlay ica data onto fMRI background
function [outData, maxICAIM, minICAIM] = add_overlay(cflat, sflat, ll, ul)
%% ADD_OVERLAY Adds the fMRI background image to the ica data

    % Range to set the ica data to
    maxInterval = 100;

    % Find min and max of the data
    minICAIM = min(cflat);
    maxICAIM = max(cflat);
    if maxICAIM > abs(minICAIM), minICAIM = -maxICAIM;
    else maxICAIM = abs(minICAIM); end;
        
    %get unit color
    unitColor = (max(cflat) - min(cflat))/64;
    
    %nonList = find(cflat ~= 0); % get indices of non-zero elements
    
    % Only copy data that is outside the limits.  This will be the data to
    % display.
    index = 1;
    for i = 1 : length(cflat)
        if (cflat(i) > ul)||(cflat(i) < ll)
            nonList(index) = i;
            index = index + 1;
        end
    end

    
    % If maxICAIM(i) is equal to zero
    if(maxICAIM == 0) 
        maxICAIM = 10^-8;
    end
    
    cflat(cflat==maxICAIM) = cflat(cflat==maxICAIM)-unitColor;
    
    %scale values in component from minInterval to maxInterval
    multi = maxICAIM/abs(maxICAIM - minICAIM);
    cflat = ( (cflat./maxICAIM) +  abs(minICAIM)/maxICAIM) * (multi) * maxInterval;

    %Scale structural to maxInterval to 2*matInterval
    newMin = maxInterval;
    newRange = maxInterval;
    dataMin = min(sflat);
    dataMax = max(sflat);
    dataRange = dataMax - dataMin;
    scaleFactor = newRange / dataRange;
    offset = newMin - dataMin;
    sflat = sflat * scaleFactor + offset;

    %overlay structural
    outData = sflat(:);

    %overlay components
    if exist('nonList','var')
        outData(nonList) = cflat(nonList);
    end
end


    
function B = buildMontage(A, mm, nn)
    % This function is set up to make a montage tranformation of:
    %  in(x,y,slice) = out(x*mm,y*nn)
    
    siz = size(A);
    
    B = A(1,1); % to inherit type 
    B = repmat(B, [nn*siz(1), mm*siz(2)]);
    rows = 1:siz(1); cols = 1:siz(2);
    for i=0:nn-1,
       for j=0:mm-1,
          k = j+i*mm+1;
          if k<=siz(3),
             B(rows+i*siz(1),cols+j*siz(2)) = A(:,:,k);
          end
       end
    end
    
end



 function [structIm, icaOut] = grabSelectedSlices(structuralImage, icasig, sliceRange)
%% GRABSELECTEDSLICES Get just the z slices we want out of the data 

    DIM = size(icasig);
    icaOut = zeros(DIM(1),DIM(2),length(sliceRange));
    structIm = zeros(DIM(1),DIM(2),length(sliceRange));
    % Filter out z data except whats in sliceRange
    for x = 1 : DIM(1)
        for y = 1 : DIM(2)
            sri = 1; % sliceRange index
            for z = 1: DIM(3)
                if sliceRange(sri) == z
                    icaOut(x,y,sri) = icasig(x,y,z);
                    structIm(x,y,sri) = structuralImage(x,y,z);
                    sri = sri + 1;
                    if sri > length(sliceRange), break; end;
                end
            end
        end
    end
    
 end
    
