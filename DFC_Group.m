function varargout = DFC_Group(varargin)
% DFC_GROUP MATLAB code for DFC_Group.fig
%      DFC_GROUP, by itself, creates a new DFC_GROUP or raises the existing
%      singleton*.
%
%      H = DFC_GROUP returns the handle to a new DFC_GROUP or the handle to
%      the existing singleton*.
%
%      DFC_GROUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFC_GROUP.M with the given input arguments.
%
%      DFC_GROUP('Property','Value',...) creates a new DFC_GROUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFC_Group_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFC_Group_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFC_Group

% Last Modified by GUIDE v2.5 14-Nov-2013 11:49:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DFC_Group_OpeningFcn, ...
                   'gui_OutputFcn',  @DFC_Group_OutputFcn, ...
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


% --- Executes just before DFC_Group is made visible.
function DFC_Group_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFC_Group (see VARARGIN)

% Choose default command line output for DFC_Group
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize GUIDATA
initialize_gui(hObject, handles, false);

% UIWAIT makes DFC_Group wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DFC_Group_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buildMapButton.
function buildMapButton_Callback(hObject, eventdata, handles)
    % Shorted variable name length
    subjProp = handles.FormData.subjProp;
    
    % Make a list of strings to add to the build list
    if (strcmpi(handles.mode, 'net')||strcmpi(handles.mode,'group'))
        for i  =  1 : length(subjProp)
            strList{i} = subjProp(i).code;
        end
    elseif strcmpi(handles.mode, 'reg')
        for i  =  1 : length(subjProp)
            strList{i} = subjProp(i).srcFFile;
        end
    end
        
    strIns{1} = '% Add group # after subject name seperated by  1 or more spaces';
    strIns{2} = '% Add to group 0 if you don''t want to use a subject';
    strIns{3} = '% Ex: /filepath/filename.nii  2';
    strIns{4} = '';
    
    % Find the longest code length
    maxLength = 0;
    for i = 1 : length(strList)
        if length(strList{i}) > maxLength
            maxLength = length(strList{i});
        end
    end
    
    % Add file names from subjects, adding space to even the line lengths
    extraSpace = 3;  % Number of extra spaces to add
    for i = 1 : length(strList)
        addSpace = (maxLength + extraSpace) - length(strList{i});
        sp = blanks(uint8(addSpace));
        strIns{i+5} = [strList{i} sp ' 1'];
    end
    % Make the font fixed width so the group numbers line up
    set(handles.edit1,'fontname','fixedwidth')
    % Replace the text in edit windows with this text
    set(handles.edit1, 'String', strIns);

    

% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
    % Shorten variable names
    subjProp = handles.FormData.subjProp;
    mode = handles.mode;
    % Parse the text area
    txt2Parse = get(handles.edit1, 'String');
    [subjProp, status] = parseGroupData(subjProp, txt2Parse, mode);

    % If we find group data then update the status
    if status >= 1
        if status == 2
            handles.FormData.status.dataMod = 1;
            handles.FormData.status.group = 1;
            handles.FormData.subjProp = subjProp;
        end
        % Return data to setup
        setappdata(0,'dataMod', handles.FormData.status.dataMod);
        setappdata(0,'groupFile', handles.FormData.groupFile);
        setappdata(0,'groupStatus', handles.FormData.status.group);
        setappdata(0,'subjProp', handles.FormData.subjProp);
        % Close this child GUI
        close;
    end
    
    
function [subjProp, status] = parseGroupData(subjProp, strCells, mode)
    % Parse the group number from the text
    status = 1;  % 0=Error, 1=No Error, 2=No Error and updated

    % Pull out file list and group number
    ix = 1;
    for i = 1 : length(strCells)
        if ~(any(regexpi(strCells{i},'^\s*%')) && 1) && length(strCells{i}) > 2
            % Not a comment so parse the line
            [token,~] = regexpi(strCells{i},'\s*(.+)\s+(\d)','tokens');
            fileList{ix} = deblank(token{1}{1});
            groupNum(ix) = str2double(token{1}{2});
            ix = ix + 1;
            status = 2;
        end
    end
    
    % Check if the have the same number of fileList items as subjProp
    if length(fileList) > length(subjProp)
        status = 0;
        errordlg('There are more group listings than subjects');
    elseif length(fileList) < length(subjProp)
        status = 0;
        errordlg('There are more subjects than group listings');
    end
    
    if status > 0
        % Build a subject list to match fileList to
        if (strcmpi(mode, 'net') || strcmpi(mode, 'group'))
            for i = 1 : length(subjProp)
                subjList{i} = subjProp(i).code;
            end
        elseif strcmpi(mode, 'reg')
            for i = 1 : length(subjProp)
                subjList{i} = subjProp(i).srcFFile;
            end
        end
        
        % Go through each line fileList pulled from the text and find a
        % subjProp for it.  If none exists then throw an error.
        for i = 1 : length(fileList)
            subjMatch = false;
            for j = 1 : length(subjProp)
                if strcmpi(fileList{i}, subjList{i})
                    subjMatch = true;
                    subjOrder(i) = j;
                    break;
                end
            end
            if ~subjMatch
                status = 0;
                errordlg('One or more of the group listings did not match a subject');
                break;
            end
        end
    end
    
    if status > 0
        % Add group numbers to each subject
        for i = 1 : length(subjProp)
            subjProp(i).group = groupNum(subjOrder(i));
        end
    end
                    
            
    % Match file list to file in subjProp then add group number
    for i = 1 : length(subjProp)
        if (strcmpi(mode, 'net')||strcmpi(mode,'group'))
            for j = 1 : length(groupNum)
                if strcmpi(fileList{i}, subjProp(i).code)
                    subjProp(i).group = groupNum(i);
                    groupMatch = true;
                end
            end
        end
        if strcmpi(mode, 'reg')
            for j = 1 : length(groupNum)
                if strcmpi(fileList{i}, subjProp(i).srcFFile)
                    subjProp(i).group = groupNum(i);
                    groupMatch = true;
                end
            end
        end
    end

    
    

% --- Executes on button press in LoadMapButton.
function LoadMapButton_Callback(hObject, eventdata, handles)
    % Get file name to read from
    [file,path] = uigetfile('*.txt','Select group list file');
    fileName = [path filesep file];
    % If we got a file then continue
    if fileName == 0
        return;
    end
    handles.FormData.groupFile = fileName;
    % Parse the group file
    status = loadGroupFile(handles);
    % If loaded sucessfully then update status
    if status == 2
        handles.FormData.status.dataMod = true;
        guidata(hObject, handles);
    end
    
    
function [status] = loadGroupFile(handles)
    status = 1; % 0=Error, 1=No error, 2=Successful load
    % Shorten variable name
    file = handles.FormData.groupFile;
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


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
    % Make sure there is text in the text area
    groupData = get(handles.edit1, 'String');
    if length(groupData) <= 1
        errordlg('No data in edit area');
        return;
    end
    % Get file name to write to
    [file,path] = uiputfile('*.txt','Save Group List');
    % Open file and write out subject full file names
    saveFile = [path file];
    fileID = fopen(saveFile,'w');
    for i = 1 : length(groupData)
        fprintf(fileID, '%s\n', groupData{i});
    end
    fclose(fileID);
    % Keep file name
    handles.FormData.groupFile = saveFile;
    guidata(hObject, handles);  
    
    
    
% --------------------------------------------------------------------
function initialize_gui(hObject, handles, isreset)
% If the FormData field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
    if isfield(handles, 'FormData') && ~isreset
        return;
    end

    % Initialize
    handles.mode = getappdata(0,'mode');
    handles.FormData.status.dataMod = getappdata(0,'dataMod');
    handles.FormData.status.group = getappdata(0,'groupStatus');
    handles.FormData.subjProp = getappdata(0,'subjProp');
    handles.FormData.groupFile = getappdata(0,'groupFile');
    
    % If a group file exists then load the data
    if ~isempty(handles.FormData.groupFile)
        loadGroupFile(handles);
    end
        
    % Update handles structure
    guidata(hObject, handles);
