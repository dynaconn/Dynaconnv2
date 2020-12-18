function varargout = DFC_Setup(varargin)
% DFC_SETUP MATLAB code for DFC_Setup.fig
%      DFC_SETUP, by itself, creates a new DFC_SETUP or raises the existing
%      singleton*.
%
%      H = DFC_SETUP returns the handle to a new DFC_SETUP or the handle to
%      the existing singleton*.
%
%      DFC_SETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFC_SETUP.M with the given input arguments.
%
%      DFC_SETUP('Property','Value',...) creates a new DFC_SETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFC_Setup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFC_Setup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFC_Setup

% Last Modified by GUIDE v2.5 09-Apr-2014 12:17:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DFC_Setup_OpeningFcn, ...
                   'gui_OutputFcn',  @DFC_Setup_OutputFcn, ...
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


% --- Executes just before DFC_Setup is made visible.
function DFC_Setup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFC_Setup (see VARARGIN)

% Choose default command line output for DFC_Setup
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize GUIDATA
initialize_gui(hObject, handles, false);
    
% UIWAIT makes DFC_Setup wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DFC_Setup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
% Send all the data back to the main GUI
    % Check if there is a mask loaded, if not load the default mask
    if ~handles.FormData.status.mask
        % Load the AAL map from templates
        handles = get_MaskFile(handles, 1);
        handles.FormData.status.mask = 1;
        handles.FormData.status.dataMod = 1;
    end
    % Check if there is a region map loaded, if not load the default mask
    if ~handles.FormData.status.regMap
        handles = dfc_loadAAL(handles);
        % Update status notifications
        handles.FormData.status.regMap = 1;
        handles.FormData.status.dataMod = 1;
        updateStatusButtons(handles); 
    end   
    % Make sure everything has been selected before continuing
    % formCompleteCheck returns 1 if everything is completed
    if formCompleteCheck(handles)
        % Data from fileSearch to return
        setappdata(0,'workDir',handles.FormData.workDir);
        setappdata(0,'status',handles.FormData.status);
        setappdata(0,'groupFile', handles.FormData.groupFile);
        setappdata(0,'subjProp', handles.FormData.subjProp);      
        setappdata(0,'regMap',handles.FormData.regMap);
        setappdata(0,'subjDir',handles.FormData.subjDir);
        setappdata(0,'mask_ind',handles.FormData.mask_ind);
        % Data for EV
        setappdata(0,'evTR', handles.FormData.evTR);
        setappdata(0,'evScanUnitType', handles.FormData.evScanUnitType);
        setappdata(0,'setupStatus', true); % Setup was completed
        % Save the session
        handles.FormData.status.dataMod = 0;
        set(handles.modLabel, 'String', '');
        HFD = handles.FormData;
        save(handles.FormData.sessionFile,'HFD');    
        guidata(hObject, handles);
        % Close this child GUI
        close;
    end


% --- Executes on button press in subjFileButton.
function addSubjButton_Callback(hObject, eventdata, handles)
% Call the Subject GUI
    % Defaults for EV GUI
    setappdata(0,'mode', handles.mode);
    setappdata(0,'dataMod', handles.FormData.status.dataMod);
    setappdata(0,'subjFile', handles.FormData.subjFile);
    setappdata(0,'subjDir', handles.FormData.subjDir);
    setappdata(0,'subjProp', handles.FormData.subjProp);
    % Call the EV GUI
    h = DFC_Subject;
    waitfor(h);

    % Retrieve the data from subject gui
    handles.FormData.status.dataMod = getappdata(0,'dataMod');
    handles.FormData.status.subj = getappdata(0,'subjStatus');
    handles.FormData.subjDir = getappdata(0,'subjDir');
    handles.FormData.subjFile = getappdata(0,'subjFile');
    subjProp = getappdata(0,'subjProp');
    handles.FormData.subjProp = subjProp;

    % Update status indicators and save
    updateStatusButtons(handles);
    guidata(hObject,handles);
    
 
% --- Executes on button press in atlasButton.
function atlasButton_Callback(hObject, eventdata, handles)
    % Call the region map GUI
    h = DFC_RegionMap;
    waitfor(h);
    
    % Check the status from the returning data
    handles.FormData.status.regMap = getappdata(0,'status');
    % If there is any data to save, then save it
    if handles.FormData.status.regMap == 1
        handles.FormData.regMap = getappdata(0,'regMap');
    end
    
    % Update status
    updateStatusButtons(handles);
    guidata(hObject,handles);
    
    
function complete = formCompleteCheck(handles)
    % Go through each status entry and make sure they are complete. If not
    % give an error message

    complete = 1; % Start by assuming the form is complete
    
    % 1st check if subject has already been selected
    if ~handles.FormData.status.subj
        errordlg('Subject dir must be selected first');
        complete=0;
    % next check if regMap has been selected
    elseif ~handles.FormData.status.regMap
        errordlg('Region map must be selected first');
        complete=0;
    % next check if mask has been selected
    elseif ~handles.FormData.status.mask
        errordlg('Data mask must be selected first');
        complete=0;
    end

     
function updateStatusButtons(handles)
    % Load images
    ulfg = imread('Good.png');
    ulfb = imread('Bad.png');
    % Setup for ev file notification
    if handles.FormData.status.ev
        image(ulfg,'Parent',handles.evAxes);
        axis(handles.evAxes,'off');
    else
        image(ulfb,'Parent',handles.evAxes);
        axis(handles.evAxes,'off');
    end
    % Setup for subject notification
    if handles.FormData.status.subj 
        image(ulfg,'Parent',handles.subjAxes);
        axis(handles.subjAxes,'off');
    else
        image(ulfb,'Parent',handles.subjAxes);
        axis(handles.subjAxes,'off');
    end
    % Setup for rMap notification
    if handles.FormData.status.regMap  
        image(ulfg,'Parent',handles.regMapAxes);
        axis(handles.regMapAxes,'off');
    else
        image(ulfb,'Parent',handles.regMapAxes);
        axis(handles.regMapAxes,'off');
    end
    % Setup for mask notification
    if handles.FormData.status.mask  
        image(ulfg,'Parent',handles.maskAxes);
        axis(handles.maskAxes,'off');
    else
        image(ulfb,'Parent',handles.maskAxes);
        axis(handles.maskAxes,'off');
    end
     % Setup for class notification
    if handles.FormData.status.group
        image(ulfg,'Parent',handles.classAxes);
        axis(handles.classAxes,'off');
    else
        image(ulfb,'Parent',handles.classAxes);
        axis(handles.classAxes,'off');
    end
    % Create a star by the save setup button if the data has been modified
    if handles.FormData.status.dataMod
        set(handles.modLabel, 'String', '*');
    else
        set(handles.modLabel, 'String', '');
    end
    
    
% --- Executes on button press in maskButton.
function maskButton_Callback(hObject, eventdata, handles)
    % ASK IF WE SHOULD GENERATE NEW DATA
    Message = sprintf('Select a mask file or use the default mask.');
    choice = questdlg(Message,'Select Mask?','Select Mask','Use Default','Select Mask');
    % Handle response
    switch choice
        case 'Select Mask'
             handles = get_MaskFile(handles, 0);
        case 'Use Default'
             handles = get_MaskFile(handles, 1);
    end
    guidata(hObject,handles);
    
    
    
function handles = get_MaskFile(handles, loadDefault)
% GET_MASKFILE Get the maskfile and covert to mask indicies
    if loadDefault
        h = msgbox('Loading default mask');
        % Convert mask to mask indicies
        maskFile = ['templates' filesep 'defaultMask.nii'];
        zMaskFile = [maskFile '.zip'];
        unzip(zMaskFile,'templates');
        handles.FormData.mask_ind = dfc_getMaskInd(maskFile);
        delete(maskFile);
        handles.FormData.status.mask = 1;
        handles.FormData.status.dataMod = 1;
        close(h);
    else
        % Ask user to select region probability folder
        [FileName,PathName,~] = uigetfile('../*.nii','Select Data Mask');
        % If we got a file then update
        if FileName ~= 0
            % Full mask file name
            maskFile = [PathName FileName];

        % Convert mask to mask indicies                
        handles.FormData.mask_ind = dfc_getMaskInd(maskFile);
        handles.FormData.status.mask = 1;
        handles.FormData.status.dataMod = 1;
        end
    end

    % Update status notifications
    updateStatusButtons(handles);


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
    handles = set_initialValues(handles);
    updateStatusButtons(handles);
    guidata(hObject,handles);
     
 
           
% --- Executes on button press in evButton.
function evButton_Callback(hObject, eventdata, handles)
    % EV Button function
    % Make sure we have subject before calling the function
    if ~handles.FormData.status.subj
        warndlg('This function requries subjects to be loaded first');
    else
        % Set data needed for EV builder
        setappdata(0,'mode', handles.mode);
        setappdata(0,'dataMod',handles.FormData.status.dataMod);
        setappdata(0,'evStatus',handles.FormData.status.ev);
        setappdata(0,'subjProp', handles.FormData.subjProp);
        setappdata(0,'evTR', handles.FormData.evTR);
        setappdata(0,'evScanUnitType', handles.FormData.evScanUnitType);
        setappdata(0,'evFile', handles.FormData.evFile);
        setappdata(0,'singleEV',handles.FormData.singleEV);

        % Call the EV GUI
        h = DFC_EVGUI;
        waitfor(h);

        % Load data returned by the EV GUI
        handles.FormData.status.dataMod = getappdata(0,'dataMod');
        handles.FormData.status.ev = getappdata(0,'evStatus');
        handles.FormData.subjProp = getappdata(0,'subjProp');
        handles.FormData.evTR = getappdata(0,'evTR');
        handles.FormData.evScanUnitType = getappdata(0,'evScanUnitType');
        handles.FormData.evFile = getappdata(0,'evFile');
        handles.FormData.singleEV = getappdata(0,'singleEV');
        % Update EV selection text
        updateStatusButtons(handles);
        guidata(hObject,handles);
    end
    
    
    
% --- Executes on button press in groupButton.
function groupButton_Callback(hObject, eventdata, handles)
    % Check if subjects are loaded 1st
    if length(handles.FormData.subjProp) <= 1
        warndlg('Subjects must be loaded first');
        return
    end
        
    % Set data needed for group builder
    setappdata(0,'mode', handles.mode);
    setappdata(0,'dataMod',handles.FormData.status.dataMod);
    setappdata(0,'groupStatus',handles.FormData.status.group);
    setappdata(0,'subjProp', handles.FormData.subjProp);
    setappdata(0,'groupFile', handles.FormData.groupFile);
    
    
    % Call the class catagorization GUI
    h = DFC_Group;
    waitfor(h);
    
    % Retrieve the data generated by the group gui
    handles.FormData.status.dataMod = getappdata(0,'dataMod');
    handles.FormData.groupFile = getappdata(0,'groupFile');
    subjProp = getappdata(0, 'subjProp');
    handles.FormData.subjProp = subjProp;
    
    % Check if all subjects have a group id, if so then groupStatus=true
    gstat = true; % Start by assuming all have a group id
    if ~isfield(subjProp,'group')
        gstat = false;
    else
        for i = 1 : length(subjProp)
            if isempty(subjProp(i).group)
                gstat = false;
            end
        end
    end
    if gstat
        handles.FormData.status.group = true;
    else
        handles.FormData.status.group = false;
    end
        
    % Update the status if data was generated
    updateStatusButtons(handles);
    guidata(hObject,handles);
    
    
    
% Set all form data to default values
function handles = set_initialValues(handles)
% SET_INITIALVLAUES create the initial values for form data
    % Default status
    handles.FormData.status.subj = false;
    handles.FormData.status.pop = false;
    handles.FormData.status.regMap = false;
    handles.FormData.status.mask = false;
    handles.FormData.status.ev = false;
    handles.FormData.status.group = false;
    handles.FormData.status.dataMod = false;
    % Defaults for EV GUI
    handles.FormData.evTR = 1.7;
    handles.FormData.evScanUnitType = 1;
    handles.FormData.evFile = '';
    handles.FormData.singleEV = false;
    % Subject Properties
    handles.FormData.subjProp(1).index = 0;
    % Other form defaults

    handles.FormData.groupFile = '';
    handles.FormData.windowSize = 32;
    handles.FormData.stepSize = 8;
    handles.FormData.subjDir = '';
    handles.FormData.subjFile = '';


% Find the location of the saved setup data
function [found, sessionFile] = find_setupData(mode, saveDir)
    % File name for .mat file that contains that values loaded at then end
    % of the last session.
    if strcmpi(mode,'net') || strcmpi(mode,'group')
        sessionFile = 'dfc_setup_session_data_n.mat';
    elseif strcmpi(mode,'reg')
        sessionFile = 'dfc_setup_session_data_r.mat';
    end
    
    found = 0;  % Assume we didn't find data from the last session
    

    % List the contents of the saveDir and check if the session file is in
    % the saveDir
    listing = dir(saveDir);
    for i = 1 : length(listing)
        if strcmpi(listing(i).name,sessionFile) == 1
            found = 1;
            sessionFile = [saveDir filesep sessionFile];
            break;
        end
    end
    


% --- Executes on button press in openSetupButton.
function openSetupButton_Callback(hObject, eventdata, handles)
    % Ask the user to select the dir that has all the saved setup info
    saveDir = uigetdir('../','Select Saved Setup Directory');
    if ~saveDir, return; end  % In case user presses cancel
    handles.FormData.saveDir = saveDir;
    
    % If the user didn't press the cancel button then look for the setup in
    % the saveDir
    [found, sessionFile] = find_setupData(handles.mode, saveDir);

    % If we found data from the last session, load it as default.  If not
    % then load the default values below.
    if found
        load(sessionFile);
        handles.FormData = HFD;
        clear HFD;
    else
        handles = set_initialValues(handles);
    end
    updateStatusButtons(handles);
    guidata(hObject,handles);
         

% --- Executes on button press in saveSetupButton.
function saveSetupButton_Callback(hObject, eventdata, handles)
    % Ask user to select the directory to save the data to.
    saveDir = uigetdir('../','Select Save Directory');
    if ~saveDir, return; end  % In case user presses cancel
    
    % If the user didn't press cancel then use this dir as the dir
    % to save all data to.
    handles.FormData.saveDir = saveDir;

    % Create the full path name of the session file
    if strcmpi(handles.mode,'net') || strcmpi(handles.mode,'group')
        sessionFile = 'dfc_setup_session_data_n.mat';
    elseif strcmpi(handles.mode,'reg')
        sessionFile = 'dfc_setup_session_data_r.mat';
    end
    sessionFile = [saveDir filesep sessionFile];
    handles.FormData.sessionFile = sessionFile;
    
    % Save data to the session mat file in the saveDir so the user can load
    % this setup next time.
    handles.FormData.status.dataMod = 0;
    set(handles.modLabel, 'String', '');
    HFD = handles.FormData;
    save(sessionFile,'HFD');    
    guidata(hObject, handles);


% --- Executes on button press in openSetupButton.
function [handles] = selectWorkingDir(hObject, handles)
    % Ask the user to select the dir that has all the saved setup info
    workDir = uigetdir('../','Select Analysis Output Directory');
    if ~workDir, return; end  % In case user presses cancel
    
    % If the user didn't press the cancel button then look for the setup in
    % the saveDir
    [found, sessionFile] = find_setupData(handles.mode, workDir);

    % If we found data from the last session, load it as default.  If not
    % then load the default values below.
    if found
        % Ask the user if they wish to load the found data
        set(0, 'DefaultUicontrolFontsize', 12);
        choice = questdlg(['A previous session was found.' ...
            ' Do you wish to load the previous session?'], ...
            'Load Previous Session', 'Yes', 'No', 'No');
        % Handle response
        switch choice
            case 'Yes'
                load(sessionFile);
                handles.FormData = HFD;
                clear HFD;
            case 'No'
                handles = set_initialValues(handles);
        end
        handles.FormData.sessionFile = sessionFile;
    else
        handles = set_initialValues(handles);
        handles.FormData.sessionFile = [workDir filesep sessionFile];
    end
    handles.FormData.workDir = workDir;
    guidata(hObject,handles);

    
% --------------------------------------------------------------------
function initialize_gui(hObject, handles, isreset)
% Initialize GUI and FormData
% If the FormData field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
    if isfield(handles, 'FormData') && ~isreset
        return;
    end

    % Get data from calling GUI
    handles.mode = getappdata(0,'mode');
    
    % Load initial values
    handles = set_initialValues(handles);
    
    % Selected working directory
    handles = selectWorkingDir(hObject, handles);
    
    updateStatusButtons(handles);    
    guidata(hObject,handles);
    
%--------------------- - - - - - - - -  -  -   -   -    -      -
