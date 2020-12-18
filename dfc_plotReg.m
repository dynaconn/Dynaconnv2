function dfc_plotReg( handles )
% DFC_PLOTREG Plot Regions and correlation data
%       Checks handles.FormData.PCRADataExist to see if precompiled
%       regional average data exists. If so this data will be used.  If not
%       each plot will generate its own region averages for plotting.

        % Number of character in label
        labelN = 18;
        
        % Shorten some variable names for more readable code
        PCRADataExist = handles.FormData.PCRADataExist;
        regN1 = handles.FormData.objN1;
        regN2 = handles.FormData.objN2;
        regMap = handles.FormData.regMap;
        workDir = handles.FormData.workDir;
        subjNum = handles.FormData.subjNum;
        subjProp = handles.FormData.subjProp;
        FName = subjProp(subjNum).srcFFile;
        subjCode = subjProp(subjNum).code;
        dim = subjProp(subjNum).srcDim;
        %usePfor = handles.FormData.usePfor; for the future
        
        % Retrieve precompiled data if it exists
        if PCRADataExist
            % Build 1st part of mat file name to check if a mat file already exists
            matFileName = 'DFC_PreCompRegionData';
            regAveFileName = [workDir filesep matFileName '.mat'];
    
            if ~exist(regAveFileName,'file') == 2
                errordlg('Couldn''t file precompiled region data!');
            end
            load(regAveFileName);  % Retrieves RegAveData(s,r,t)
            rmsig1 = squeeze(RegAveData(subjNum,regN1,:));
            rmsig2 = squeeze(RegAveData(subjNum,regN2,:));
        
        else %Build regional data
            fprintf('Getting region averages for %s\n', subjCode);
            rmask_ind = regMap(r).ind;
            rmsig1 = squeeze(dfc_getRegionMean(FName, rmask_ind, dim(4) ));
            rmsig2 = squeeze(dfc_getRegionMean(FName, rmask_ind, dim(4) ));
        end;
        
        % Resize based on num of time points
        rmsig1 = rmsig1(1 : dim(4));
        rmsig2 = rmsig2(1 : dim(4));
        
        % Start by assuming the best corr is with a positive rmsig1
        pos = 1;
        % Calculate both positive and negative correlation
        cp = dfc_corrTWin(rmsig1,rmsig2, handles);
        ncp = dfc_corrTWin(-rmsig1,rmsig2, handles);
        if ncp > cp
            pos = 0;  cp = ncp;
        end   
        
        % Plot the 1st region
        hold(handles.axes1,'off');   % plot both on same figure
        if pos
            plot(rmsig1,'Parent',handles.axes1);
        else
            plot(-rmsig1,'Parent',handles.axes1);
        end
        title(handles.axes1, 'Average of Regions (Normalized)','FontSize',12);
        
        % Plot the 2nd region
        hold(handles.axes1,'all');   % plot both on same figure
        plot(rmsig2,'Parent',handles.axes1,'color','red')
        
        % Shortening label1 length to prevent labels from disappearing
        label1 = handles.FormData.regMap(regN1).name{1};
        charL1 = length(label1);
        if pos
            if charL1 > labelN, charL1=labelN; end;
            label1 = label1(1:charL1);
        else
            if charL1 > (labelN-1), charL1=(labelN-1); end;
            label1 = ['~' label1(1:charL1)];
        end
            
        % Shortening label2 length to prevent labels from disappearing
        label2 = handles.FormData.regMap(regN2).name{1};
        charL2 = length(label2);
        if charL2 > labelN, charL2=labelN; end;
        label2 = label2(1:charL2);
        
        % Add label to plots. Interpreter none turns off latex to prevent
        % interpreting "_" char as subscript.
        hleg1 = legend(handles.axes1, label1, label2);
        set(hleg1,'Location','SouthWest','Interpreter','none');

        % Plot correlation data
        hold(handles.axes2,'off');
        plot(cp,'Parent',handles.axes2)
        
        % Get min and max to scale ev waveform
        cp_min = min(cp);
        cp_max = max(cp);
        cp_mean = mean(cp);

        % EV Files is optional so if no EV file then skip correlation
        if isfield(handles.FormData.subjProp(subjNum), 'evFile')
            % Calculate and plot expected data
            ev = dfc_expVal(handles,'on');
            % Plot the correlation waveform
            hold(handles.axes2,'all');   % plot both on same figure

            p=plot(ev,'Parent',handles.axes2);
            set(p,'color','red');  % Change plot color to red
            hleg1 = legend(handles.axes2, 'corrTC', 'Expected');
        else
            hleg1 = legend(handles.axes2, 'corrTC');
        end
            
        set(hleg1,'Location','SouthWest');
        title(handles.axes2, 'Region Correlation (Normalized)','FontSize',12);
                        
        % Mean Correlation
        cpm_str = num2str(sprintf('%0.3f',cp_mean));
        tot_str = ['Avg comp. corr between regions = ' cpm_str];
        set(handles.corrResult,'String',tot_str,'Value',1);
        clear tot_str;
        
        if isfield(handles.FormData.subjProp(subjNum), 'evFile')
            % Correlation between cp and ev
            corr_cp_ev = corr(cp', ev');
            corr_cp_ev(isnan(corr_cp_ev)) = 0;
            cce_str = num2str(sprintf('%0.3f',corr_cp_ev));
            top_str = 'Total corr between region corr from plot';
            tot_str = ['above and expected value from EV file = ' cce_str];
        else
            top_str = '';
            tot_str = ''; 
        end
        set(handles.text12,'String',top_str,'Value',1);
        set(handles.evResult,'String',tot_str,'Value',1); 
end

