function outWave = dfc_expVal(handles, winMode, sig)
    % This function builds the hrf waveform from the EV file.
    % The hrf is windowed using step size and window size if winMode is
    % true

    %% SETUP    
    useSig = 0;
    if nargin == 3  % If there are 3 vars, then we have sig
        useSig = 1;
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
    
    % Setup data for building hrf waveform
    setupData.verbose = 'off';
    setupData.slideCount = timeN;  % Number of time points
    setupData.evScanUnitType = handles.FormData.evScanUnitType;
    setupData.evTR = handles.FormData.evTR;
    % Get onset times
    evFile = subjProp(subjNum).evFile;
    onsetTimes = parseEVFile(evFile);

    if useSig
        % Sort the onset times so we can go through serially
        onsetTimes = sort(onsetTimes);

        % Make sig a row vector is its not already
        if size(sig,1) > size(sig,2), sig = sig'; end;
    end
        
    
    %% BUILD HRF
    
    if useSig
        % Create tmp list of onsets and polarity
        onset = [];
        pol = [];  Ppol = [];  Npol = [];

        % Loop through each onset, testing each one
        for i = 1 : length(onsetTimes)       
            % Append next value to vectors
            onset = [ onset onsetTimes(i)];
            Ppol = [pol 1];
            Npol = [pol -1];

            %Build the hrf waveforms
            hrfwaveP = build_hrfwave(setupData, onset, Ppol);
            hrfwaveN = build_hrfwave(setupData, onset, Npol);

            % Correlate both with signal
            avgP = mean(corr(sig',hrfwaveP'));
            avgN = mean(corr(sig',hrfwaveN'));

            % Whichever is better becomes the new polarity vector
            if avgP > avgN, pol = Ppol;
            else pol = Npol; end;
        end
    
        %Build the hrf waveform
        hrfwave = build_hrfwave(setupData, onsetTimes, pol);
    
    else      
        %Build the hrf waveform
        hrfwave = build_hrfwave(setupData, onsetTimes);
    end
                

    %% WINDOWING
    
    % Move window across timepoints and get correlation
    % between waveforms
    if strcmpi(winMode, 'on')   
        outWave = zeros(1,uint16(ceil((timeN - windowSize) / stepSize)));
        index = 1;
        for i = 1 : stepSize : (timeN - windowSize)
            wave1 = hrfwave(i:i+windowSize-1);
            outWave(index) = mean(wave1);
            index = index + 1;
        end
    else
        outWave = hrfwave;
    end

    % Normalize output
    myRange = max(outWave) - min(outWave);
    outWave = outWave * (2/myRange); % Set range to +/- 1
    myMean = mean(outWave);
    outWave = outWave - myMean; % Set mean to 0


end



function [ t_data ] = build_hrfwave( setupData, onsetTimes, polarity )
    %BUILD_HRFWAVE
    %
    % Build temporal waveform which has hdr waveforms inserted at every 
    % onset that is specified in the onsetSlides array
    % The polarity vector contains 1s and -1s giving the polarity of each
    % hrf.  If no polarity vector is given then all are poisitive.
    %
    % Required: setupData.verbose
    %           setupData.slideCount
    %           sorted onsetTimes
    % Optional: polarity
    %
    % Returns: t_data

    % If no polarity vector exist then make one of all positives
    if nargin < 3
        polarity = ones(1,length(onsetTimes));
    end
    
    if strcmpi(setupData.verbose, 'on'), fprintf('\nBuilding hrf waveform'); end;

    % Calculate difference between the time the scan occurs and the onset
    % time.
    tOffset = zeros(length(onsetTimes),1);
    scanN = zeros(length(onsetTimes),1);
    for i = 1 : length(onsetTimes)
        % So if the onset time is 33.45 and the scans are every 3.5 seconds
        % then floor(33.45/3.5) is the number of scans b
        % offset = 33.45 - (b * 3.5)
        scanN(i) = floor(onsetTimes(i)/setupData.evTR);
        tOffset(i) = onsetTimes(i) - (scanN(i) * setupData.evTR);
    end 

    % Get default spm_hrf settings.
    [~, p] = spm_hrf(1); 
    
    t_data = zeros(1,setupData.slideCount);
    % Build and insert HRF into waveform at the scan number specified by 
    % times specified by hrf_inst_pnt
    for i = 1 : length(scanN)
        % Add offset to hrf parameters
        p(6) = tOffset(i);
        % Build the hrf
        hrf = spm_hrf(setupData.evTR, p);
        slide = scanN(i);
        Pl = polarity(i);
        start = slide;
        stop = slide + length(hrf) - 1;
        if (stop > setupData.slideCount), stop = setupData.slideCount; end;
        range = (stop-start)+1;
        t_data(start:stop) = t_data(start:stop) + (Pl*hrf(1:range))';
    end
    
end



function [ onSets ] = parseEVFile( evFile )
%PARSEEVFILE Parse EV file to get onset times
%   Build full file name and attempt to open

    fileID = fopen(evFile);
    if fileID == -1
        fprintf('\nERROR - Couldn''t open %s\n', evFile);
        return
    end

    % Begin parsing
    row = 1;
    expr = '^\s*\t*([\d.]+)[\s\t]+\d*';  % What to search for
    % Read each line till end of file, which is -1
    while 1 % Escape from loop using break
        line = fgetl(fileID);
        if line == -1;  % Exit condition
            break;
        end
        % Check for label data
        [token,~] = regexpi(line,expr,'tokens');

        % If we do have a label then store and increment row
        if length(token) >= 1
            onSets(row) = str2double(token{1});
            row = row + 1;
        end
    end   
    fclose(fileID);
    
end

