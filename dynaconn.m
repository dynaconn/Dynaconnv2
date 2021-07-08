
function varargout = dynaconn(varargin)
% DYNACONN Main gui for dynaconn program
% main program for dynaconn program
%
% Title: dynaconn.m
% Creation data: 6-13-2013
% Original Author: johne
%
% Last modified: 8/4/2013
% Author: johne
% Descr:
%   Main GUI for the dynaconn program.  This program starts with the init
%   function at the bottom of this m file.  Dynaconn starts in component
%   mode.
%

% Edit the above text to modify the response to help dynaconn

% Last Modified by GUIDE v2.5 01-Jun-2021 13:34:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dynaconn_OpeningFcn, ...
                   'gui_OutputFcn',  @dynaconn_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    display('pwd in Dynaconn.m: dy')
    pwd
    gui_mainfcn(gui_State, varargin{:});
    
end
% End initialization code - DO NOT EDIT


% --- Executes just before dynaconn is made visible.
function dynaconn_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dynaconn (see VARARGIN)

% Choose default command line output for dynaconn
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize GUIDATA
%if 
%handles.mode = varargin{1};
initialize_gui(hObject, handles, false);

% UIWAIT makes dynaconn wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dynaconn_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in setupButton.
function setupButton_Callback(hObject, eventdata, handles)
    % Set initial status of setup to not complete
    if ~isfield(handles.FormData.status, 'setup')
        handles.FormData.status.setup = false;
    end
    % Tell the setup GUI what mode to work in
    setappdata(0,'mode',handles.mode);
    % Call and wait for setup GUI
    h = DFC_Setup;  
    waitfor(h);

    % Check if setup was run to completion
    setupStatus = getappdata(0,'setupStatus');
    
    % If the setup was completed then retrieve data sent from setup GUI
    if setupStatus
        % Retrieve data sent from setup GUI
        handles.FormData.mask_ind =         getappdata(0,'mask_ind');
        handles.FormData.subjDir =          getappdata(0,'subjDir');
        handles.FormData.subjProp =         getappdata(0,'subjProp');
        handles.FormData.regMap =           getappdata(0,'regMap');  
        handles.FormData.evTR =             getappdata(0,'evTR');
        handles.FormData.evScanUnitType =   getappdata(0,'evScanUnitType');
        handles.FormData.workDir =          getappdata(0,'workDir');
        handles.FormData.status =           getappdata(0,'status');
        handles.FormData.status.setup = setupStatus;
        % Enable GUI buttons now
        toggleGUIelements(handles, 'on');

        % Shorten some of the vars for use in this function
        subjNum = handles.FormData.subjNum;
        subjProp = handles.FormData.subjProp;
        regMap = handles.FormData.regMap;

        if strcmpi(handles.mode,'net')
            % Update list_items with component numbers
            for i = 1 : handles.FormData.subjProp(subjNum).icDim(4)
                list_items{i} = ['Component ' num2str(i)];
            end
        elseif strcmpi(handles.mode,'reg')
        % Update list_items with regions
            for i = 1 : length(regMap)
                reg_items{i} = regMap(i).name{1};
            end  
            list_items = cellArray2charArray(reg_items);
        elseif strcmpi(handles.mode,'group')
        % Update list_items with groups
            for i = 1 : length(subjProp)
                groupNums(i) = handles.FormData.subjProp(i).group;
            end
            % Build list of groups
            uniqueGN = unique(groupNums);
            for i = 1 : length(uniqueGN)
                group_items{i} = ['Group ' num2str(i)];
            end
            % Build list of components
            for i = 1 : handles.FormData.subjProp(subjNum).icDim(4)
                list_items{i} = ['Component ' num2str(i)];
            end
            set(handles.popupmenu3,'String',group_items,'Value',1);
            set(handles.popupmenu4,'String',group_items,'Value',1);
        end

        % Update popup menus
        set(handles.popupmenu1,'String',list_items,'Value',1);
        set(handles.popupmenu2,'String',list_items,'Value',1);
        codeList = popPopMenu(subjProp, 'code');
        handles.FormData.subjNum = 1;
        set(handles.subjSelPopupmenu,'String', codeList,'Value',handles.FormData.subjNum);
    
        % If in region mode find or build precompiled region data
        if strcmpi(handles.mode,'reg')
            handles = dfc_findPreCompRegData(handles); % If found sets PCRADataExist = 1
        end
    end
    
    guidata(hObject,handles); % Save the handle data


    
% Replot the component-component graph and the corr-ev graph
function replotDFCGraphs(hObject, handles)
    % Plot TC, and correlation data
    if strcmpi(handles.mode,'net')
        dfc_plotNet(handles);
    elseif strcmpi(handles.mode,'reg')
        % If mean was selected make sure it was build
        if ~handles.FormData.PCRADataExist
            errordlg('All region mean data must be precompiled first');
            return;
        end
        dfc_plotReg(handles);
    elseif strcmpi(handles.mode,'group')
        dfc_plotGroup(handles);
    end
    % Update the component display window if its open
    if isfield(handles,'compsHandle')
        if ishandle(handles.compsHandle);
            % Get the position of the current component window
            oldPosition = get(handles.compsHandle,'Position');
            close(handles.compsHandle); % close the window
            % Open a new component window and save the handle
            h = callCompDisplayWindow(handles);
            handles.compsHandle = h;
            guidata(hObject,handles); % Save the handle data
            % Move the new comp window to the old location
            set(handles.compsHandle,'Position',oldPosition);
        end
    end
    

    
% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
    % 1st check is subject has already been selected
    if  handles.FormData.status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    % Save the new component 1 selection
    handles.FormData.objN1 = get(hObject,'Value');
    guidata(hObject,handles);
    replotDFCGraphs(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
    % 1st check is subject has already been selected
    if  handles.FormData.status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    % Save the new component 2 selection
    handles.FormData.objN2 = get(hObject,'Value');
    guidata(hObject,handles);
    replotDFCGraphs(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
    % 1st check is subject has already been selected
    if  handles.FormData.status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    % Save the new group 1 selection
    handles.FormData.groupN1 = get(hObject,'Value');
    guidata(hObject,handles);
    replotDFCGraphs(handles);


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
    % 1st check is subject has already been selected
    if  handles.FormData.status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    % Save the new group 2 selection
    handles.FormData.groupN2 = get(hObject,'Value');
    guidata(hObject,handles);
    replotDFCGraphs(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
    close all;


% --- Executes on button press in winUpButton.
function winUpButton_Callback(hObject, eventdata, handles)
    % 1st check is subject has already been selected
    if  handles.FormData.status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    handles.FormData.windowSize = handles.FormData.windowSize + 1;
    guidata(hObject,handles);
    set(handles.winSizeLabel,'String',handles.FormData.windowSize,'Value',1);
    % Plot regions, and correlation data
    if strcmpi(handles.mode,'net')
        dfc_plotNet(handles);
    elseif strcmpi(handles.mode,'reg')
        if ~handles.FormData.PCRADataExist
            errordlg('All region mean data must be precompiled first');
            return;
        end
        dfc_plotReg(handles);
    elseif strcmpi(handles.mode,'group')
        dfc_plotGroup(handles);
    end


% --- Executes on button press in winDnButton.
function winDnButton_Callback(hObject, eventdata, handles)
    % 1st check is subject has already been selected
    if  handles.FormData.status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    handles.FormData.windowSize = handles.FormData.windowSize - 1;
    guidata(hObject,handles);
    set(handles.winSizeLabel,'String',handles.FormData.windowSize,'Value',1);
    % Plot regions, and correlation data
    if strcmpi(handles.mode,'net')
        dfc_plotNet(handles);
    elseif strcmpi(handles.mode,'reg')
        if ~handles.FormData.PCRADataExist
            errordlg('All region mean data must be precompiled first');
            return;
        end
        dfc_plotReg(handles);
    elseif strcmpi(handles.mode,'group')
        dfc_plotGroup(handles);
    end


% --- Executes on button press in stepUpButton.
function stepUpButton_Callback(hObject, eventdata, handles)
    % 1st check is subject has already been selected
    if  handles.FormData.status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    handles.FormData.stepSize = handles.FormData.stepSize + 1;
    guidata(hObject,handles);
    set(handles.stepSizeLabel,'String',handles.FormData.stepSize,'Value',1);
    % Plot TC, and correlation data
    if strcmpi(handles.mode,'net')
        dfc_plotNet(handles);
    elseif strcmpi(handles.mode,'reg')
        if ~handles.FormData.PCRADataExist
            errordlg('All region mean data must be precompiled first');
            return;
        end
        dfc_plotReg(handles);
    elseif strcmpi(handles.mode,'group')
        dfc_plotGroup(handles);
    end


% --- Executes on button press in stepDnButton.
function stepDnButton_Callback(hObject, eventdata, handles)
    % 1st check is subject has already been selected
    if  handles.FormData.status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    handles.FormData.stepSize = handles.FormData.stepSize -1;
    guidata(hObject,handles);
    set(handles.stepSizeLabel,'String',handles.FormData.stepSize,'Value',1);
    % Plot TC, and correlation data
    if strcmpi(handles.mode,'net')
        dfc_plotNet(handles);
    elseif strcmpi(handles.mode,'reg')
        if ~handles.FormData.PCRADataExist
            errordlg('All region mean data must be precompiled first');
            return;
        end
        dfc_plotReg(handles);
    elseif strcmpi(handles.mode,'group')
        dfc_plotGroup(handles);
    end


% SHOW COMPONENTS
function showComponents(hObject, eventdata, handles)
    h = callCompDisplayWindow(handles);
    handles.compsHandle = h;
    guidata(hObject,handles); % Save the handle data
 
    
    
function compsHandle = callCompDisplayWindow(handles)
    % 1st check is subject has already been selected
    if  handles.FormData.status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    
    % Save data to be retrieved by "Show Comps" GUI
    setappdata(0,'mode',handles.mode);
    setappdata(0,'regMap',handles.FormData.regMap);
    setappdata(0,'objN1',handles.FormData.objN1);
    setappdata(0,'objN2',handles.FormData.objN2);
    setappdata(0,'mask_ind',handles.FormData.mask_ind);
    setappdata(0,'subjProp',handles.FormData.subjProp);
    setappdata(0,'subjNum',handles.FormData.subjNum);
    % Show Components
    compsHandle = DFC_CompDisplay();
    
% --- Executes on button press in regionComponent.
function regionComponent_Callback(hObject, eventdata, handles)
    % Shorten some form data var names to simplify code
    
    %TODO Andrew: Save these to output location
    status = handles.FormData.status;
    subjProp = handles.FormData.subjProp;
    regMap = handles.FormData.regMap;
    PCRADataExist = handles.FormData.PCRADataExist;

    % 1st check is subject has already been selected
    if  status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    % 2nd check is subject has already been selected
    if  status.group == 0
        errordlg('Group setup must be run first');
        return;
    end

    if ~PCRADataExist && strcmpi(handles.mode,'reg')
        errordlg('All region mean data must be precompiled first');
        return;
    end

    % Call function to find or generate DFC data
    [DfcData, h] = dfc_buildRegDFC(regMap, subjProp);
    waitfor(DfcData);
    if h ~= 0, close(h); end;

    % Ask where to save this data
    [filename, pathname] = uiputfile;
    
    % Save the data to mat file
    save(strcat(pathname, filename), 'DfcData');


% --- Executes on button press in matrixButton.
function matrixButton_Callback(hObject, eventdata, handles)
    % Shorten some form data var names to simplify code
    status = handles.FormData.status;
    subjProp = handles.FormData.subjProp;
    PCRADataExist = handles.FormData.PCRADataExist;
    
    % 1st check is subject has already been selected
    if  status.setup == 0
        errordlg('Setup must be run first');
        return;
    end
    % 2nd check is subject has already been selected
    if  status.group == 0
        errordlg('Group setup must be run first');
        return;
    end
    
    if ~PCRADataExist && strcmpi(handles.mode,'reg')
        errordlg('All region mean data must be precompiled first');
        return;
    end
        
    % Call function to find or generate DFC data
    [AveFileName,h] = dfc_findDFCData(handles);
    waitfor(AveFileName);
    if h ~= 0, close(h); end

    % Save data to be retrieved network plot window
    setappdata(0,'dataFile',AveFileName);
    setappdata(0,'mode',handles.mode);
    setappdata(0,'cmap',handles.FormData.cmap);
    % Bring up network plot window
    h = DFC_NetworkPlot;
    waitfor(h);

    % Retrieve data sent from setup GUI
    objN1 = getappdata(0,'objN1');
    objN2 = getappdata(0,'objN2');
    subjNum = getappdata(0,'subjNum');
    handles.FormData.cmap = getappdata(0,'cmap');  
    if objN1 ~= 0
        % Update form data
        handles.FormData.objN1 = objN1;
        handles.FormData.objN2 = objN2;
        if strcmpi(handles.mode,'group')
            for i = 1 : length(subjProp)
                groupNums(i) = subjProp(i).group;
            end
            uniqueGroups = unique(groupNums);
            nGroup = length(uniqueGroups);
            groupList = combnk(1:nGroup,2);
            groupN1 = groupList(subjNum,1);
            groupN2 = groupList(subjNum,2);
            % Set the groups based of the new subjNum
            set(handles.popupmenu3, 'value', groupN1);
            set(handles.popupmenu4, 'value', groupN2);            
        else
            handles.FormData.subjNum = subjNum;
        end

        % Set the popup component selectors based on data returned from corrMap
        set(handles.popupmenu1, 'value', objN1);
        set(handles.popupmenu2, 'value', objN2);
        set(handles.subjSelPopupmenu,'value', subjNum);
    
        % Update label and plot based on retrieved data
        if strcmpi(handles.mode,'net')
            dfc_plotNet(handles);
        elseif strcmpi(handles.mode,'reg')
            dfc_plotReg(handles);
        elseif strcmpi(handles.mode,'group')
            dfc_plotGroup(handles);
        end
        
        % Update the component display window if its open
        if isfield(handles,'compsHandle')
            if ishandle(handles.compsHandle);
                % Get the position of the current component window
                oldPosition = get(handles.compsHandle,'Position');
                close(handles.compsHandle); % close the window
                % Open a new component window and save the handle
                h = callCompDisplayWindow(handles);
                handles.compsHandle = h;
                guidata(hObject,handles); % Save the handle data
                % Move the new comp window to the old location
                set(handles.compsHandle,'Position',oldPosition);
            end
        end
        
    end
    guidata(hObject,handles); % Save the handle data

    

% --- Executes on button press in modeButton.
function modeButton_Callback(modeStep, hObject, eventdata, handles)
    % Clear form data
    handles.FormData = [];
    
    % If in network mode
    if strcmpi(handles.mode,'net')
        if modeStep == 1
            handles.mode = 'reg';
        else
            handles.mode = 'group';
        end
    elseif strcmpi(handles.mode,'reg')
        if modeStep == 1
            handles.mode = 'net';
        else
            handles.mode = 'group';
        end
    elseif strcmpi(handles.mode,'group')
        if modeStep == 1
            handles.mode = 'net';
        else
            handles.mode = 'reg';
        end
    end
    % Clear current axes before changing modes
    cla(handles.axes1,'reset');
    cla(handles.axes2,'reset');
    % Start GUI again
    isreset = 1;
    initialize_gui(hObject, handles, isreset)
   


% --- Executes on selection change in subjSelPopupmenu.
function subjSelPopupmenu_Callback(hObject, eventdata, handles)
    % Get the code selection number from the GUI
    handles.FormData.subjNum = get(hObject,'Value');
    guidata(hObject,handles);
    replotDFCGraphs(hObject, handles);


% --- Executes during object creation, after setting all properties.
function subjSelPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjSelPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

  
    % --- Create the DFC data thats is modulated with task load.
function outputDFCData(handles)
    % Get file name to write to
    [file,path] = uiputfile('*.mat','Save mat file');
    if file ~= 0
        % Open file and write out subject full file names
        saveFile = [path file];
        outData = dfc_outputDFCData(handles);
        save(saveFile, 'outData');
    end

        
% --- Output the region coverage data.
function outputRegCover(handles)
    % Get file name to write to
    [file,path] = uiputfile('*.txt','Save txt file');
    if file ~= 0
        % Open file and write out subject full file names
        saveFile = [path file];
        dfc_outputRegCover(saveFile, handles);
    end
    
   
    
% Open the help manual
function openUserGuide(hObject, eventdata)
    open('DynaConnUserGuide.pdf')

%     function dfc_buildRegDFC( regMap,subjProp,settings )
        
    
% --- Executes on selection change in actionPopupmenu.
function actionPopupmenu_Callback(hObject, eventdata, handles)
    action = get(handles.actionPopupmenu,'Value');
    if action == 1
    elseif action == 2
        setupButton_Callback(hObject, eventdata, handles);
    elseif action == 3
        modeButton_Callback(1, hObject, eventdata, handles);
    elseif action == 4
        modeButton_Callback(2, hObject, eventdata, handles); 
    elseif action == 5
        showComponents(hObject, eventdata, handles);
    %Andrew added 5/20/21
%     elseif action == 6
%         dfc_buildRegDFC(regMap,subjProp,settings);
    end
    
    % Since menu will be different if group info has not been loaded
    if handles.FormData.status.group == 1
        if action == 6
            matrixButton_Callback(hObject, eventdata, handles);
        elseif action == 7 && strcmpi(handles.mode, 'reg')
            regionComponent_Callback(hObject, eventdata, handles);
        elseif action == 7
            handles.FormData.dataType = 1;
            outputDFCData(handles);
        elseif action == 8
            handles.FormData.dataType = 2;
            outputDFCData(handles);
        elseif action == 9
            handles.FormData.dataType = 3;
            outputDFCData(handles);
        elseif action == 10
            handles.FormData.dataType = 4;
            outputDFCData(handles);
        elseif action == 11
            handles.defaults.zscorecut = 1.7;
            outputRegCover(handles);
        end
    else
        if action == 6
            handles.FormData.dataType = 1;
            outputDFCData(handles);
        elseif action == 7
            handles.FormData.dataType = 2;
            outputDFCData(handles);
        elseif action == 8
            handles.FormData.dataType = 3;
            outputDFCData(handles);
        elseif action == 9
            handles.FormData.dataType = 4;
            outputDFCData(handles);
        elseif action == 10
            outputRegCover(handles);
        end
        
    end
    % Return action selection back to default position
    set(handles.actionPopupmenu,'Value',1);
    

% --- Executes during object creation, after setting all properties.
function actionPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actionPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% Enable all GUI buttons and popup menus
function toggleGUIelements(handles, state)
% Turn on or off all the GUI buttons and popups not  associated with
% choosing the next action (ie setup)
    set(handles.popupmenu1,     'Visible', state);
    set(handles.popupmenu2,     'Visible', state);
    set(handles.winUpButton,    'Visible', state);
    set(handles.winDnButton,    'Visible', state);
    set(handles.stepUpButton,   'Visible', state);
    set(handles.stepDnButton,   'Visible', state);
    set(handles.winSizeText,    'Visible', state);
    set(handles.winSizeLabel,   'Visible', state);
    set(handles.stepSizeText,   'Visible', state);
    set(handles.stepSizeLabel,  'Visible', state);
    set(handles.selectionText,  'Visible', state);
    set(handles.corrResult,     'Visible', state);
    set(handles.text12,         'Visible', state);
    set(handles.evResult,       'Visible', state);
    set(handles.axes1,          'Visible', state);
    set(handles.axes2,          'Visible', state);
    set(handles.subjText,       'Visible', state);
    set(handles.subjSelPopupmenu,'Visible', state);
    % Set value of group select popups if in group mode
    if strcmpi(handles.mode,'group')
        set(handles.groupText,  'Visible', state);
        set(handles.popupmenu3, 'Visible', state);
        set(handles.popupmenu4, 'Visible', state);
        set(handles.subjText,   'Visible','off');
        set(handles.subjSelPopupmenu,'Visible','off');
    else
        set(handles.groupText,  'Visible', 'off');
        set(handles.popupmenu3, 'Visible', 'off');
        set(handles.popupmenu4, 'Visible', 'off');
    end
    % Set value of action/function popup menu
    ix = 1;   % Menu index
    actionString{ix} = 'Select function';
    ix = ix + 1;
    actionString{ix} = 'Configure setup';
    ix = ix + 1;
    if strcmpi(handles.mode, 'net')
        actionString{ix} = 'Change to Region mode';
        ix = ix + 1;
        actionString{ix} = 'Change to Group mode';
        ix = ix + 1;
    elseif strcmpi(handles.mode, 'reg')
        actionString{ix} = 'Change to GIFT mode';
        ix = ix + 1;
        actionString{ix} = 'Change to Group mode';
        ix = ix + 1;
    elseif strcmpi(handles.mode, 'group')
        actionString{ix} = 'Change to GIFT mode';
        ix = ix + 1;
        actionString{ix} = 'Change to Region mode';
        ix = ix + 1;
    end 
    if strcmpi(state, 'on')
        actionString{ix} = 'Show Regions';
        ix = ix + 1;
        actionString{ix} = 'New Gui';
        if  handles.FormData.status.group == 1
            actionString{ix} = 'Component Region Matrix';
            ix = ix + 1;
            %Andrew added 5/20/21
            actionString{ix} = 'Save DFC Matrix';
            ix = ix + 1;
        end
        if strcmpi(handles.mode, 'net')
            actionString{ix} = 'Output DFC data';
            ix = ix + 1;
            actionString{ix} = 'Output EV modulated data';
            ix = ix + 1;
            actionString{ix} = 'Output Static FC data';
            ix = ix + 1;
            actionString{ix} = 'Output all correlation window';
            ix = ix + 1;
            actionString{ix} = 'Output region coverage';
        end
    end
    set(handles.actionPopupmenu,'String',actionString,'Value',1);

    
    
% --------------------------------------------------------------------
function initialize_gui(hObject, handles, isreset)
% If the FormData field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
    if isfield(handles, 'FormData') && ~isreset
        return;
    end
    % Start in network mode instead of region ('reg') mode if mode hasn't
    % been defined yet (ie. staring up the GUI). If it's already defined
    % then we must be resetting
    if ~isfield(handles, 'mode')
        handles.mode = 'net';
    end
    
    % Add required paths
    %addpath([pwd filesep 'spm8']);

    % Initialize the form data
    handles.FormData.subjNum = 1;
    handles.FormData.status.setup = 0; % 1 when setup has been run
    handles.FormData.status.group = 0; % 1 when there is group info loaded.
    handles.FormData.objN1 = 1;
    handles.FormData.objN2 = 1;
    handles.FormData.groupN1 = 1;
    handles.FormData.groupN2 = 1;
    handles.FormData.windowSize = 32;
    handles.FormData.stepSize = 8;
    handles.FormData.cmap = 1;
   % handles.FormData.FullFileName = 'none';
    handles.FormData.PCRADataExist = 0;  % Check for data after set-up

    % Add up and down arrow images to up/down buttons
    ulf = imread('U.png');
    set(handles.winUpButton,'Cdata',ulf);
    set(handles.stepUpButton,'Cdata',ulf);
    dlf = imread('D.png');
    set(handles.winDnButton,'Cdata',dlf);
    set(handles.stepDnButton,'Cdata',dlf);
    
    % Init the GUI strings
    toggleGUIelements(handles, 'off'); % Until setup is run all popup menus are hidden
    
    if strcmpi(handles.mode,'net')
        set(handles.uipanel1,'Title','GIFT Mode','FontSize',16, ...
        'FontName', 'Helvetica', 'FontUnits', 'pixels');
        set(handles.corrResult,'String','Avg comp. corr between TCs = ');
        set(handles.text12,'String','Total corr between comp. corr from plot');
        set(handles.selectionText,'String','Component selection');
        title(handles.axes1, 'TC of the Components (Normalized)', ...
        'FontSize',14, 'FontName', 'Helvetica', 'FontUnits', 'pixels');
        title(handles.axes2, 'Component Correlation (Normalized)', ...
        'FontSize',14, 'FontName', 'Helvetica', 'FontUnits', 'pixels');
    elseif strcmpi(handles.mode,'reg')
        set(handles.uipanel1,'Title','Region Mode','FontSize',16, ...
        'FontName', 'Helvetica', 'FontUnits', 'pixels');
        set(handles.corrResult,'String','Avg comp. corr between regions = ');
        set(handles.text12,'String','Total corr between region corr from plot');
        set(handles.selectionText,'String','Region selection');
        title(handles.axes1, 'Average of Regions (Normalized)', ...
        'FontSize',14, 'FontName', 'Helvetica', 'FontUnits', 'pixels');
        title(handles.axes2, 'Region Correlation (Normalized)', ...
        'FontSize',14, 'FontName', 'Helvetica', 'FontUnits', 'pixels');
        %Andrew TODO: Add DFC Result (handles.dfcResult?)
    elseif strcmpi(handles.mode,'group')
        set(handles.uipanel1,'Title','Group Mode','FontSize',16, ...
        'FontName', 'Helvetica', 'FontUnits', 'pixels');
        set(handles.corrResult,'String','Avg comp. corr with EV = ');
        set(handles.text12,'String','Total corr between EV corr from plot');
        set(handles.selectionText,'String','Component selection');
        title(handles.axes1, 'Group DFC Avg', ...
        'FontSize',14, 'FontName', 'Helvetica', 'FontUnits', 'pixels');
        title(handles.axes2, 'p-values', ...
        'FontSize',14, 'FontName', 'Helvetica', 'FontUnits', 'pixels');
    end
    
    % If on windows, use parallel computing, on mac the OS does parallel itself
    if strcmpi(computer('arch'),'win64')
        handles.FormData.usePfor = 1;
    else
        handles.FormData.usePfor = 0;
    end
    
    % Add a menu bar so the user can use the zoom in tool
    %set(handles.figure1, 'Toolbar', 'figure', 'menubar', 'figure');
    %drawnow;
    
    % Add a help menu that brings up the users guide, but don't re-add if
    % we are just reseting
    if ~isreset
        mh = uimenu(handles.figure1,'Label','Help'); 
        frh = uimenu(mh,'Label','User Manual ...',...
                                        'Callback', @openUserGuide);
    end
    
    % Save any data placed in handles
    guidata(hObject,handles);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
