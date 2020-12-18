function dfc_plotNet( handles )
%DFC_PLOTNET Plot TC and correlation data
    rehash path
    
    % Pull needed vars out of handle
    compN1 = handles.FormData.objN1;
    compN2 = handles.FormData.objN2;
    subjNum = handles.FormData.subjNum;
    subjProp = handles.FormData.subjProp;

    % Open the data image
    FName = subjProp(subjNum).tcFFile;  % Retrive timecourse file name
    vol_info = spm_vol(FName);    % open data file
    data_img = spm_read_vols(vol_info); % Retrive data 

    % Get the tc data
    orig_tc1 = data_img(:,compN1);
    orig_tc2 = data_img(:,compN2);
    
    % Normalize the TCs ( THis is NOT RIGHT)
    tc1 = orig_tc1/norm(orig_tc1);
    tc2 = orig_tc2/norm(orig_tc2);

    % Calculate correlation
    cp = dfc_corrTWin(tc1,tc2, handles);

    % Start by assuming the best corr is with a positive tc1
    pos = 1;

    % Get means of cp(s) to compare which is correct
    cp_mean = mean(cp);
    if cp_mean < 0
        pos = 0;  cp = -cp;
    end

    % Get min and max to scale ev waveform
    cp_min = min(cp);
    cp_max = max(cp);
    cp_mean = mean(cp);

    % Plot the 1st component
    hold(handles.axes1,'off');   % plot both on same figure
    if pos
        plot(tc1,'Parent',handles.axes1)
        label1 = ['Comp' num2str(compN1)];
    else
        plot(-tc1,'Parent',handles.axes1)
        label1 = ['~Comp' num2str(compN1)];
    end
    title(handles.axes1, 'TC of the Components','FontSize',12);

    % Plot the 2nd component
    hold(handles.axes1,'all');   % plot both on same figure
    plot(tc2,'Parent',handles.axes1,'color','red')
    label2 = ['Comp' num2str(compN2)];
    hleg1 = legend(handles.axes1, label1, label2);
    set(hleg1,'Location','SouthWest');

    % Plot correlation data
    hold(handles.axes2,'off');
    plot(cp,'Parent',handles.axes2)

    % EV Files is optional so if no EV file then skip correlation
    if isfield(handles.FormData.subjProp(subjNum), 'evFile')
        % Calculate and plot expected data
        ev = dfc_expVal(handles, 'on');
        % Plot the correlation waveform
        hold(handles.axes2,'all');   % plot both on same figure
        p=plot(ev,'Parent',handles.axes2);
        set(p,'color','red');  % Change plot color to red
        hleg1 = legend(handles.axes2, 'TC corr.', 'Expected');
    else
        hleg1 = legend(handles.axes2, 'TC corr.');   
    end
    
    set(hleg1,'Location','SouthWest');
    title(handles.axes2, 'Component Correlation (Normalized)','FontSize',12);
    
    % Mean Correlation
    cpm_str = num2str(sprintf('%0.3f',cp_mean));
    tot_str = ['Avg comp. corr between TCs = ' cpm_str];
    set(handles.corrResult,'String',tot_str,'Value',1);
    clear tot_str;
        
    % EV Files is optional so if no EV file then skip correlation
    if isfield(handles.FormData.subjProp(subjNum), 'evFile')
        % Correlation between cp and ev
        corr_cp_ev = corr(cp', ev');
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

