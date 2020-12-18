function varargout = DFC_Subject(varargin)
% DFC_SUBJECT MATLAB code for DFC_Subject.fig
%      DFC_SUBJECT, by itself, creates a new DFC_SUBJECT or raises the existing
%      singleton*.
%
%      H = DFC_SUBJECT returns the handle to a new DFC_SUBJECT or the handle to
%      the existing singleton*.
%
%      DFC_SUBJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFC_SUBJECT.M with the given input arguments.
%
%      DFC_SUBJECT('Property','Value',...) creates a new DFC_SUBJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFC_Subject_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFC_Subject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFC_Subject

% Last Modified by GUIDE v2.5 27-Nov-2013 15:00:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DFC_Subject_OpeningFcn, ...
                   'gui_OutputFcn',  @DFC_Subject_OutputFcn, ...
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


% --- Executes just before DFC_Subject is made visible.
function DFC_Subject_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFC_Subject (see VARARGIN)

% Choose default command line output for DFC_Subject
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize GUIDATA
initialize_gui(hObject, handles, false);

% UIWAIT makes DFC_Subject wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DFC_Subject_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in addSubjButton.
function addSubjButton_Callback(hObject, eventdata, handles)
    % Shorted variable name length
    subjProp = handles.FormData.subjProp;
    
    % Make a list of strings to add to the build list
    if strcmpi(handles.mode, 'net')||strcmpi(handles.mode,'group')
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
    if strcmpi(handles.mode,'net')||strcmpi(handles.mode,'group')
        if handles.FormData.status.subj
            status = 2;
        end
    elseif strcmpi(handles.mode, 'reg')
        txt2Parse = get(handles.edit1, 'String');
        [subjProp, status] = parseSubjText(subjProp, txt2Parse, mode);
    end


    % If we find group data then update the status
    if status >= 1
        if status == 2
            handles.FormData.status.dataMod = 1;
            handles.FormData.status.subj = 1;
            handles.FormData.subjProp = subjProp;       
                
            % Get the subject dir from the 1st subject.  The subject dir will be
            % used to store the pre-compiled region average data.
            if strcmpi(handles.mode, 'net')||strcmpi(handles.mode,'group')
                [handles.FormData.subjDir,~,~] = fileparts(subjProp(1).icFFile);
            elseif strcmpi(handles.mode, 'reg')
                [handles.FormData.subjDir,~,~] = fileparts(subjProp(1).srcFFile);
            end
        end
        % Return data to setup
        setappdata(0,'dataMod', handles.FormData.status.dataMod);
        setappdata(0,'subjFile', handles.FormData.subjFile);
        setappdata(0,'subjDir', handles.FormData.subjDir);
        setappdata(0,'subjStatus', handles.FormData.status.subj);
        setappdata(0,'subjProp', handles.FormData.subjProp);
        % Close this child GUI
        close;
    end
    
        
function [subjProp, status] = parseSubjText(varargin)
    % Inputs
    subjProp = varargin{1};
    strCells = varargin{2};
    mode = varargin{3};
    
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
    % Make sure each subj file exists
    for i = 1 : length(fileList)
        if exist(fileList{i},'file') ~= 2
            status = 0;
        end
    end
    for i = 1 : length(fileList)
        if ~(any(regexp(fileList{i}, '\.nii\s*$'))&&1)
            status = -1;
        end
    end
    if status == 0
        errordlg('One or more of the subject files does not exist.');
    elseif status == -1
        errordlf('One or more of the subject files is not a nifti file.');
    elseif status == 2
        % Store each subject
        for i = 1 : length(fileList)
            [~,fileName,~] = fileparts(fileList{i});
            subjProp(i).index = i;
            subjProp(i).srcFFile = fileList{i};
            subjProp(i).code = fileName;
            subjProp(i).icFFile = '';
            subjProp(i).tcFFile = '';
            % Open volume to get time point length
            V = spm_vol(subjProp(i).srcFFile);
            subjProp(i).srcDim = V(1).dim;
            subjProp(i).srcDim(4) = length(V);
            subjProp(i).icDim = [0 0 0 0];
            subjProp(i).tcDim = [0 0 0];
        end
    end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
    % Get file name to read from
    [file,path] = uigetfile('*.txt','Select subject list file');
    fileName = [path filesep file];
    % If we got a file then continue
    if fileName == 0
        return;
    end
    handles.FormData.subjFile = fileName;
    % Parse the group file
    status = loadSubjFile(handles);
    % If loaded sucessfully then update status
    if status == 2
        handles.FormData.status.dataMod = true;
        guidata(hObject, handles);
    end
    
    
function [status] = loadSubjFile(handles)
    status = 1; % 0=Error, 1=No error, 2=Successful load
    % Shorten variable name
    file = handles.FormData.subjFile;
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
    subjData = get(handles.edit1, 'String');
    if length(subjData) <= 1
        errordlg('No data in edit area');
        return;
    end
    % Get file name to write to
    [file,path] = uiputfile('*.txt','Save Subject List');
    % Open file and write out subject full file names
    saveFile = [path file];
    fileID = fopen(saveFile,'w');
    for i = 1 : length(subjData)
        fprintf(fileID, '%s\n', subjData{i});
    end
    fclose(fileID);
    % Keep file name
    handles.FormData.subjFile = saveFile;
    guidata(hObject, handles);  
    
  


% --- Executes on button press in addFolderButton.
function addFolderButton_Callback(hObject, eventdata, handles)
    if strcmpi(handles.mode,'net') || strcmpi(handles.mode,'group')
        % This is GIFT mode right now, so open the icadir
        % User asked to select ica GIFT dir
        subjDir = uigetdir('../','Select Post ICA Directory');
        if ~subjDir, return; end  % In case user presses cancel
        
        % Get all subject info from this directory
        [subjProp, status] = dfc_openGIFTdir(subjDir);
        handles.FormData.status.dataMod = status.dataMod;
        handles.FormData.status.subj = status.subj;
        handles.FormData.subjProp = subjProp;        
    elseif strcmpi(handles.mode,'reg')
        subjDir = uigetdir('../','Select Parent Subject Directory');
        % Store this directory
        handles.FormData.subjDir = subjDir;
        if ~subjDir, return; end  % In case user presses cancel

        % Attempt to get subjects from this dir
        [subjProp, status] = dfc_subjFileSearch(subjDir);
        % If subject were found then put them on the edit box
        if status.subj
            % Get current text in edit box
            editTxt = get(handles.edit1, 'String');
            ix = length(editTxt) + 1;
            for i = 1 : length(subjProp)
                editTxt{ix} = subjProp(i).srcFFile;
                ix = ix + 1;
            end
            % Place new txt back on edit box
            set(handles.edit1, 'String', editTxt);
        end
    end
    % Save all data using GUIDATA for later retrivel
    guidata(hObject,handles)
 


    
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
    handles.FormData.subjProp = getappdata(0,'subjProp');
    handles.FormData.subjFile = getappdata(0,'subjFile');
    
    % If the subject file exists then load the data
    if ~isempty(handles.FormData.subjFile)
        loadSubjFile(handles);
    end
    
    % Add instructions to edit area if it is blank.
    % Start by first check if the text area is empty
    existingTxt = get(handles.edit1,'String');
    % If it is emtpy then add some instructions
    if isempty(existingTxt) 
        strIns{1} = '% Add a subject''s Nifti full path file name on each line';
        strIns{2} = '% manually or using the "Add" button.  The subject files';
        strIns{2} = '% will be associated with each subject sequentially.';
        strIns{3} = '% Ex:  /subjectfilepath/subjectfilename.nii';
        strIns{4} = '';
        % If running on a pc, change example to match path structure
        if ispc
           strIns{3} = '% Ex: C:\subjectfilepath\subjectfilename.txt';
        end
        % Update text edit area
        set(handles.edit1,'String',strIns);
    end
    
    % Disable all unnessary components
    if strcmpi(handles.mode, 'net')||strcmpi(handles.mode,'group')
        set(handles.text3,'Visible','off');
        set(handles.text4,'Visible','off');
        set(handles.text5,'Visible','off');
        set(handles.addSubjButton,'Visible','off');
        set(handles.loadButton,'Visible','off');
        set(handles.saveButton,'Visible','off');
        set(handles.edit1,'Visible','off');
    end
    
    % Update handles structure
    guidata(hObject, handles);
