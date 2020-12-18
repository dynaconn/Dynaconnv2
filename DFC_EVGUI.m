function varargout = DFC_EVGUI(varargin)
% DFC_EVGUI MATLAB code for DFC_EVGUI.fig
%      DFC_EVGUI, by itself, creates a new DFC_EVGUI or raises the existing
%      singleton*.
%
%      H = DFC_EVGUI returns the handle to a new DFC_EVGUI or the handle to
%      the existing singleton*.
%
%      DFC_EVGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFC_EVGUI.M with the given input arguments.
%
%      DFC_EVGUI('Property','Value',...) creates a new DFC_EVGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFC_EVGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFC_EVGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFC_EVGUI

% Last Modified by GUIDE v2.5 19-Nov-2013 08:12:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DFC_EVGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DFC_EVGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DFC_EVGUI is made visible.
function DFC_EVGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFC_EVGUI (see VARARGIN)

% Choose default command line output for DFC_EVGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize GUIDATA
initialize_gui(hObject, handles, false);

% UIWAIT makes DFC_EVGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DFC_EVGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function TRedit_Callback(hObject, eventdata, handles) 
    % Get new TR value
    TR = str2double(get(hObject,'String'));
    handles.FormData.evTR = TR;
    handles.FormData.status.dataMod = 1;
    guidata(hObject,handles);
    

% --- Executes during object creation, after setting all properties.
function TRedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TRedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TAedit_Callback(hObject, eventdata, handles)
% This field is not used yet, but is here for future use.


% --- Executes during object creation, after setting all properties.
function TAedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TAedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
    % User asked to select ev text file
    [FileName,PathName, ~] = uigetfile('../*.txt','Select EV List File');
    % If we got a file then continue
    if FileName == 0
        return;
    end
    handles.FormData.evFile = [PathName filesep FileName];
    % Pares the ev file
    status = loadEVFile(handles);
    % If loaded sucessfully then update status
    if status == 2
        handles.FormData.status.dataMod = true;
        handles.FormData.status.ev = true;
        guidata(hObject, handles);
    end
    

    
 function status = loadEVFile(handles)
    status = 1; % 0=Error, 1=No error, 2=Successful load
    % Shorten variable name
    file = handles.FormData.evFile;
    % Make sure the file exists
    if exist(file,'file') ~= 2
        tline{1} = 'The following file could not be loaded:';
        tline{2} = file;
    else
        % Open file and copy each line to the text edit area
        fid = fopen(file,'r');
        ix = 1;
        while 1
            nl = fgetl(fid);
            if nl == -1
                break;
            end
            tline{ix} = nl;
            ix = ix + 1;
        end
        fclose(fid);
        status = 2;
    end
    % Make the font fixed width so the group numbers line up
    set(handles.edit1,'fontname','fixedwidth')
    % Put the loaded text into the edit region
    set(handles.edit1, 'String', tline);


    
% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
    % Make sure there is text in the text area
    evMapData = get(handles.edit1, 'String');
    if length(evMapData) <= 1
        errordlg('No data in edit area');
        return;
    end
    % Get file name to write to
    [file,path] = uiputfile('*.txt','Save EV List');
    % Open file and write out subject full file names
    saveFile = [path file];
    fileID = fopen(saveFile,'w');
    for i = 1 : length(evMapData)
        fprintf(fileID, '%s\n', evMapData{i});
    end
    fclose(fileID);
    % Keep file name
    handles.FormData.evFile = saveFile;
    handles.FormData.status.dataMod = true;
    handles.FormData.status.ev = true;
    guidata(hObject, handles);  



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SingleEVCheckbox.
function SingleEVCheckbox_Callback(hObject, eventdata, handles)
    handles.FormData.singleEV = get(hObject,'Value');
    guidata(hObject,handles);

    
% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
    evScanUnitType = get(hObject,'Value');
    % Set evseconds field to visible or not
    if evScanUnitType == 1
        set(handles.text1,'visible','on');
        set(handles.TRedit,'visible','on');
        set(handles.text2,'visible','on');
        set(handles.TAedit,'visible','on');
    elseif evScanUnitType == 2
        set(handles.text1,'visible','off');
        set(handles.TRedit,'visible','off');
        set(handles.text2,'visible','off');
        set(handles.TAedit,'visible','off');
    end
    handles.FormData.evScanUnitType = evScanUnitType;
    handles.FormData.status.dataMod = true;
    guidata(hObject,handles);
    
    
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
    

% --- Executes on button press in showSubjButton.
function showSubjButton_Callback(hObject, eventdata, handles)
    % Show a quick list of the subjects so the user can know
    % which subject goes with which EV file
    DFC_showSubjList;


% --- Executes on button press in addButton.
function addButton_Callback(hObject, eventdata, handles)
    % Ask user to select ev text file
    [FileName,PathName, ~] = uigetfile('../*.txt','Select EV text File');
    % If we got a file then continue
    if FileName == 0
        return;
    end
    newEVFile = [PathName FileName];
    % Get current text from edit area, then add the new line
    currEditTxt = get(handles.edit1,'String');
    currEditTxt{length(currEditTxt)+1} = newEVFile;
    % Update edit area
    set(handles.edit1,'String',currEditTxt);
  


% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
    % Shorten variable names
    subjProp = handles.FormData.subjProp;
    singleEV = handles.FormData.singleEV;
    % Parse the text area
    txt2Parse = get(handles.edit1, 'String');
    [subjProp, status] = parseEVMapText(subjProp, txt2Parse, singleEV);

    % If we find group data then update the status
    if status >= 1
        if status == 2
            handles.FormData.status.dataMod = 1;
            handles.FormData.status.ev = 1;
            handles.FormData.subjProp = subjProp;
        end
        % Return data to setup
        setappdata(0,'dataMod', handles.FormData.status.dataMod);
        setappdata(0,'evStatus', handles.FormData.status.ev);
        setappdata(0,'subjProp', handles.FormData.subjProp);
        setappdata(0,'evTR', handles.FormData.evTR);
        setappdata(0,'evScanUnitType', handles.FormData.evScanUnitType);
        setappdata(0,'evFile',handles.FormData.evFile);
        setappdata(0,'singleEV',handles.FormData.singleEV);
        % Close this child GUI
        close;
    end
      
    
function [subjProp, status] = parseEVMapText(subjProp, strCells, singleEV)
    % Parse the EV file from the text
    status = 1;  % 0=Error, 1=No Error, 2=No Error and updated
    
    % Pull out file list and group number
    ix = 1;
    for i = 1 : length(strCells)
        % Assure that the line is not a comment and is longer than 2
        if ~(any(regexpi(strCells{i},'^\s*%')) && 1) && length(strCells{i}) > 2
            % Not a comment so parse the line
            [token,~] = regexpi(strCells{i},'\s*(.+)','tokens');
            fileList{ix} = deblank(token{1}{1});
            ix = ix + 1;
            status = 2;
        end
    end    
    % Make sure each ev file exists
    for i = 1 : length(fileList)
        if exist(fileList{i},'file') ~= 2
            status = 0;
        end
    end
    if status == 0
        errordlg('One or more of the EV files does not exist.');
    elseif status == 2
        % If using a singleEV file, then assign this 1st EV file to every
        % subject
        if singleEV
            for i = 1 : length(subjProp)
                subjProp(i).evFile = fileList{1};
            end
        else
            % Else, equate each EV file with each subject
            if length(fileList) > length(subjProp)
                errordlg('There are more EV files than subjects!');
                status = 0;
            elseif length(fileList) < length(subjProp)
                errordlg('There are more subjects than EV files!');
                status = 0;
            else
                for i = 1 : length(subjProp)
                    subjProp(i).evFile = fileList{i};
                end
            end
        end
    end
    
    
% --------------------------------------------------------------------
function initialize_gui(hObject, handles, isreset)
% If the FormData field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
    if isfield(handles, 'FormData') && ~isreset
        return;
    end
    
    % Retrive values from setup gui
    handles.mode = getappdata(0,'mode');
    handles.FormData.status.dataMod = getappdata(0,'dataMod');
    handles.FormData.status.ev = getappdata(0,'evStatus');
    handles.FormData.subjProp = getappdata(0,'subjProp');
    handles.FormData.evTR = getappdata(0,'evTR');
    handles.FormData.evScanUnitType = getappdata(0,'evScanUnitType');
    handles.FormData.evFile = getappdata(0,'evFile');
    handles.FormData.singleEV = getappdata(0,'singleEV');

    % Set GUI objects from retrieved values
    set(handles.TRedit,'String',num2str(handles.FormData.evTR));
    % Hide GUI components based on retrieved values
    if handles.FormData.evScanUnitType == 1
        set(handles.text1,'visible','on');
        set(handles.TRedit,'visible','on');
        set(handles.text2,'visible','on');
        set(handles.TAedit,'visible','on');
    elseif handles.FormData.evScanUnitType == 2
        set(handles.text1,'visible','off');
        set(handles.TRedit,'visible','off');
        set(handles.text2,'visible','off');
        set(handles.TAedit,'visible','off');
    end
    % If a ev file exists then load the data
    if ~isempty(handles.FormData.evFile)
        loadEVFile(handles);
    end
    
    % Add instructions to edit area if it is blank.
    % Start by first check if the text area is empty
    existingTxt = get(handles.edit1,'String');
    % If it is emtpy then add some instructions
    if isempty(existingTxt) 
        strIns{1} = '% Add a EV full path file name on each line manually,';
        strIns{2} = '% or using the "Add" button.  The EV files will be';
        strIns{2} = '% associated with each subject sequentially.';
        strIns{3} = '% Ex:  /evfilepath/evfilename.txt';
        strIns{4} = '';
        % If running on a pc, change example to match path structure
        if ispc
           strIns{3} = '% Ex: C:\evfilepath\evfilename.txt';
        end
        % Update text edit area
        set(handles.edit1,'String',strIns);
    end
    guidata(hObject,handles);
