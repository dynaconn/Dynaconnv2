function varargout = DFC_RegionMap(varargin)
% DFC_REGIONMAP MATLAB code for DFC_RegionMap.fig
%      DFC_REGIONMAP, by itself, creates a new DFC_REGIONMAP or raises the existing
%      singleton*.
%
%      H = DFC_REGIONMAP returns the handle to a new DFC_REGIONMAP or the handle to
%      the existing singleton*.
%
%      DFC_REGIONMAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFC_REGIONMAP.M with the given input arguments.
%
%      DFC_REGIONMAP('Property','Value',...) creates a new DFC_REGIONMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFC_RegionMap_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFC_RegionMap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFC_RegionMap

% Last Modified by GUIDE v2.5 02-Oct-2013 00:13:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DFC_RegionMap_OpeningFcn, ...
                   'gui_OutputFcn',  @DFC_RegionMap_OutputFcn, ...
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


% --- Executes just before DFC_RegionMap is made visible.
function DFC_RegionMap_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFC_RegionMap (see VARARGIN)

% Choose default command line output for DFC_RegionMap
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize GUIDATA
initialize_gui(hObject, handles, false);

% UIWAIT makes DFC_RegionMap wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DFC_RegionMap_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in aalButton.
function aalButton_Callback(hObject, eventdata, handles)
    % Load the AAL map from templates
    handles = dfc_loadAAL(handles);
    
    % Report region mask loaded and then save data and return.
    myLog{1} = 'AAL Region Map converted';
    myLog{2} = 'AAL Region Map loaded';
    set(handles.logTxt, 'String', myLog);

    guidata(hObject,handles);
    
    

% --- Executes on button press in regMapButton.
function regMapButton_Callback(hObject, eventdata, handles)
% regMapButton_Callback - Dialog to load a region map file of nii format
    
    % Get log text and index
    myLog = get(handles.logTxt, 'String');
    ix = length(myLog);
    if ~strcmpi(myLog{2},'Empty')
        ix = ix + 1; % No longer empty so erase empty by overwriting.
    end
        
    % Ask user to select region probability folder
    [FileName,PathName,FilterIndex] = ...
        uigetfile('../*.nii','Select a Region Map file');
        
    % If we got a file then update
    if FileName ~= 0
        % Load the nifti file
        regMapFile = [PathName FileName];    % Full file path
        vol_info = spm_vol(regMapFile);    % open data file
        img = spm_read_vols(vol_info); % Retrive data
        dim = size(img);
        
        % Count the number of layers
        if ndims(img)==3
            layers = unique(img);
            if ~isempty(find(layers==0))
                nLayers = length(layers) - 1;
            else
                nLayers = length(layers);
            end
        elseif ndims(img)==4
            nLayers = size(img,4);
        end
        
        % Scale the img if required
        % If this img is not 2mm (x=91) then scale
        if dim(1) ~= 91        
            if ndims(img)==3
                newImg = dfc_resizeImg((91/dim(1)), img);
            elseif ndims(img)==4
                % Create progress bar for resizing image
                h = waitbar(0,'1','Name','Resizing Image to 2mm Space',...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
                
                for i = 1 : dim(4)
                    % Check for Cancel button press
                    if getappdata(h,'canceling')
                        break
                    end
                    % Report current estimate in the waitbar's message field
                    progress = i/dim(4);
                    status = sprintf('Converting slice %d of %d', i, dim(4));
                    waitbar(progress,h,status)
                    newImg(:,:,:,i) = ...
                        dfc_resizeImg((91/dim(1)), img(:,:,:,i));
                end
                delete(h)   % DELETE the waitbar; don't try to CLOSE it.
            end
            clear img;
            img = newImg;
            clear newImg;
        end
        
        % Check the reg map status
        status = handles.FormData.regMapStatus;
        % Status=none meaining no regMap have been loaded or
        % Status=ready meaning has a map loaded, can take another
        if strcmpi(status, 'none') || strcmpi(status,'ready')
            handles.FormData.tmpRegMap = img;
            handles.FormData.regMapStatus = 'need label';
        elseif strcmpi(status, 'need map')
            % Get the number of complete map/label sets so that the next
            % reg maps can be loaded on top of them.
            if isfield(handles.FormData,'regMap')
                nComp = get_numCompleteRegionSet(handles.FormData.regMap);
            else
                nComp = 0;
            end
            
            % Attempt to combine the labels and map together 
            regMap = dfc_build_regMap(handles, img, ...
                handles.FormData.tmpLabel, nComp+1);
            if length(regMap) <= 1
                myLog{ix} = 'Error, # of layers ~= # of labels';
                ix = ix + 1;
                set(handles.logTxt, 'String', myLog);
                return
            else
                handles.FormData.regMap = regMap;
                handles.FormData.regMapStatus = 'ready';
            end
        elseif strcmpi(status, 'need label')
                myLog{ix} = 'Warning. A map was previously loaded, now overwriting';
                ix = ix + 1;
            handles.FormData.tmpRegMap = img;
        elseif strcmpi(status, 'default')
                myLog{ix} = 'Warning. A map was previously loaded, now overwriting';
                ix = ix + 1;
            handles.FormData.tmpRegMap = img;
            handles.FormData.regMapStatus = 'need label';
        end

        % Report number of regions read
        myLog{ix} = [num2str(nLayers) ' regions were loaded'];
        set(handles.logTxt, 'String', myLog);
        
        guidata(hObject,handles);
    end
    
    
function n = get_numCompleteRegionSet(regMap)
    % get_numCompleteRegionSet - Return the number of complete region map /
    % label sets.  For instance if there are 30 labels and 20 region map
    % layer then return 20.
    
    numRegions = 0;
    numLabels = 0;
    for i = 1 : length(regMap)
        if ~strcmpi(regMap(i).name,'')  % Not empty
            numLabels = numLabels + 1;
        end
        if length(regMap(i).prob) > 1
            numRegions = numRegions + 1;
        end
    end
    if numLabels <= numRegions
        n = numLabels;
    else
        n = numRegions;
    end
    
    
% --- Executes on button press in labelButton.
function labelButton_Callback(hObject, eventdata, handles)
% labelButton_Callback - Dialog to load a region map file of nii format
    
    % Get log text and index
    myLog = get(handles.logTxt, 'String');
    ix = length(myLog);
    if ~strcmpi(myLog{2},'Empty')
        ix = ix + 1; % No longer empty so erase empty by overwriting.
    end
    
    % Ask user to select region probability folder
    [FileName,PathName,FilterIndex] = ...
        uigetfile({'*.xml', 'XML Label File'; ...
                   '*.txt', 'Text Label File'}, ...
                   'Select a region map legend file');

    % If we got a file then update
    if FileName ~= 0
        % Parse the label file
        labelFile = [PathName FileName];    % Full file path
        labels = dfc_parseRegMapLegend(labelFile);
        
        % Check the label status
        status = handles.FormData.regMapStatus;
        % Status=none meaining no labels have been loaded or
        % Status=ready meaning has a label loaded, can take another
        if strcmpi(status, 'none') || strcmpi(status,'ready')
            handles.FormData.tmpLabel = labels;
            handles.FormData.regMapStatus = 'need map';
        elseif strcmpi(status, 'need label')
            % Get the number of complete map/label sets so that the next
            % reg maps can be loaded on top of them.
            if isfield(handles.FormData,'regMap')
                nComp = get_numCompleteRegionSet(handles.FormData.regMap);
            else
                nComp = 0;
            end
            
            % Attempt to combine the labels and map together
            regMap = dfc_build_regMap(handles, ... 
                handles.FormData.tmpRegMap, labels, nComp+1);
            if length(regMap) <= 1
                myLog{ix} = 'Error, # of layers ~= # of labels';
                ix = ix + 1;
                set(handles.logTxt, 'String', myLog);
                return
            else
                handles.FormData.regMap = regMap;
                handles.FormData.regMapStatus = 'ready';
            end
        elseif strcmpi(status, 'need map')
            myLog{ix} = 'Warning. A legend was previously loaded, now overwriting';
            ix = ix + 1;
            set(handles.logTxt, 'String', myLog);
            handles.FormData.tmpLabel = labels;
        elseif strcmpi(status, 'default')
            myLog{ix} = 'Warning. A legend was previously loaded, now overwriting';
            ix = ix + 1;
            handles.FormData.tmpLabel = labels;
            handles.FormData.regMapStatus = 'need map';
        end
        
        % Report number of labels read
        numOfLabels = length(labels);
        myLog{ix} = [num2str(numOfLabels) ' labels were loaded'];
        set(handles.logTxt, 'String', myLog);

        guidata(hObject,handles);
    end
    


% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
    % If there is regMap data then send it, if not send the status to 0
    if isfield(handles.FormData,'regMap')
        setappdata(0, 'status', 1);
        % Save the region map to the calling app
        setappdata(0,'regMap', handles.FormData.regMap);
    else
        setappdata(0, 'status', 0);
        % Save the region map to the calling app
        %setappdata(0,'regMap', handles.FormData.regMap);
    end
    % Close this child GUI
    close;


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% No longer exists

% --------------------------------------------------------------------
function initialize_gui(hObject, handles, isreset)
% If the FormData field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
    if isfield(handles, 'FormData') && ~isreset
        return;
    end

    % Set initial region map status
    handles.FormData.regMapStatus = 'none';
    guidata(hObject,handles);
    
