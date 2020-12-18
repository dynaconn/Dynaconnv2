function outData = dfc_corrTWin(varargin)
    % Default variables
    windowing = 1; % 1 runs the DFNC window, 0 means static DFNC
    
    % Read input variables
    tc1 = varargin{1};
    tc2 = varargin{2};
    handles = varargin{3};
    if nargin >= 4
        if strcmpi(varargin{4}, 'windowing')
            if strcmpi(varargin{5}, 'off')
                windowing = 0;
            else
                windowing = 1;
            end
        end
    end
    
    % Shorten form data var names to make code more readable
    mode = handles.mode;
    windowSize = handles.FormData.windowSize;
    stepSize = handles.FormData.stepSize;
    subjNum = handles.FormData.subjNum;
    subjProp = handles.FormData.subjProp;
    if strcmpi(mode, 'net') || strcmpi(mode, 'group')
        timeN = subjProp(subjNum).tcDim(1);
    elseif strcmpi(mode, 'reg')
        timeN = subjProp(subjNum).srcDim(4);
    end
    
    % Calculate data length
    Noutput = uint16(ceil((timeN - windowSize) / stepSize)); % Number of points in output
    outData = zeros(1, Noutput);   % Allocate data for output
 
   % Force TCs to be a column vector (as opposed to row vector)
    if size(tc1,1) < size(tc1,2), tc1 = tc1'; end;
    if size(tc2,1) < size(tc2,2), tc2 = tc2'; end;

    % Move window across timepoints and get correlation
    % between waveforms
    if windowing
        index = 1;
        for i = 1 : stepSize : (timeN - windowSize)
            sig1 = tc1(i:i+windowSize-1);
            sig2 = tc2(i:i+windowSize-1);
            outData(index) = corr(sig1,sig2);
            index = index + 1;
        end
    else
        outData = corr(tc1,tc2);
    end
    
    %Remove non-number values
    outData(isnan(outData)) = 0;

end

