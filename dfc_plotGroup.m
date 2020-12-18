function dfc_plotGroup( handles )
% DFC_PLOTREG Plot Regions and correlation data
%       Checks handles.FormData.GroupDataExist to see if precompiled
%       group average data exists. If so this data will be used.  If not
%       each plot will generate its own region averages for plotting.

    GN1 = handles.FormData.groupN1;
    GN2 = handles.FormData.groupN2;
    CN1 = handles.FormData.objN1;
    CN2 = handles.FormData.objN2;

    % Get the average for CPG1 and CPG2
    [CPG1, CPG2, pV, hV] = dfc_calcGroupDFCTTest(handles,GN1,GN2,CN1,CN2);
    avgCPG1 = mean(CPG1,1);
    avgCPG2 = mean(CPG2,1);
        
   
    % UPPER PLOT WINDOW
    
    % Plot the 1st region
    hold(handles.axes1,'off');   % plot both on same figure
    plot(avgCPG1,'Parent',handles.axes1,'color','blue');
        
    % Plot the 2nd region
    hold(handles.axes1,'all');   % plot both on same figure
    plot(avgCPG2,'Parent',handles.axes1,'color','red')
        
    % Labels
    label1 = ['Group ' num2str(GN1)];
    label2 = ['Group ' num2str(GN2)];
    % Add label to plots. Interpreter none turns off latex to prevent
    % interpreting "_" char as subscript.
    hleg1 = legend(handles.axes1, label1, label2);
    set(hleg1,'Location','SouthWest','Interpreter','none');
    empty_str = '';
    set(handles.corrResult,'String',empty_str,'Value',1);
    
    
    
    % LOWER PLOT WINDOW
        
    % Plot P-values
    hold(handles.axes2,'off');
    plot(pV,'Parent',handles.axes2,'color','blue')
    % Plot the null-hypothesis
    hold(handles.axes2,'all');
    plot(hV,'Parent',handles.axes2,'color','red')
    % Create the legend
    hleg1 = legend(handles.axes2, 'p-value', 'Reject 5% null-hypothesis = 1');
    set(hleg1,'Location','SouthWest');
    
    % Report mean p-value and mean hypothesis
    pv_mean = mean(pV);
    hv_mean = mean(hV);
    pv_str = num2str(sprintf('%0.3f',pv_mean));
    hv_str = num2str(sprintf('%0.3f',hv_mean));
    empty_str = '';
    top_str = ['Average p-value = ' pv_str];
    bottom_str = ['Average hypothesis = ' hv_str];
    set(handles.corrResult,'String',top_str,'Value',1);
    set(handles.text12,'String',bottom_str,'Value',1);
    set(handles.evResult,'String',empty_str,'Value',1);
end

