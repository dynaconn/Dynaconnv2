function varargout = DFC_showSubjList(varargin)
% DFC_SHOWSUBJLIST MATLAB code for DFC_showSubjList.fig
%      DFC_SHOWSUBJLIST, by itself, creates a new DFC_SHOWSUBJLIST or raises the existing
%      singleton*.
%
%      H = DFC_SHOWSUBJLIST returns the handle to a new DFC_SHOWSUBJLIST or the handle to
%      the existing singleton*.
%
%      DFC_SHOWSUBJLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFC_SHOWSUBJLIST.M with the given input arguments.
%
%      DFC_SHOWSUBJLIST('Property','Value',...) creates a new DFC_SHOWSUBJLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFC_showSubjList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFC_showSubjList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFC_showSubjList

% Last Modified by GUIDE v2.5 08-Dec-2013 21:04:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DFC_showSubjList_OpeningFcn, ...
                   'gui_OutputFcn',  @DFC_showSubjList_OutputFcn, ...
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


% --- Executes just before DFC_showSubjList is made visible.
function DFC_showSubjList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFC_showSubjList (see VARARGIN)

% Choose default command line output for DFC_showSubjList
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize GUIDATA
initialize_gui(hObject, handles, false);

% UIWAIT makes DFC_showSubjList wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DFC_showSubjList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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


    
    
    
% --------------------------------------------------------------------
function initialize_gui(hObject, handles, isreset)
% If the FormData field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
    if isfield(handles, 'FormData') && ~isreset
        return;
    end

    % Initialize
    mode = getappdata(0,'mode');
    subjProp = getappdata(0,'subjProp');
    
    % Build list
    for i = 1 : length(subjProp)
        if strcmpi(mode,'net') || strcmpi(mode,'group')
            strIns{i} = subjProp(i).code;
        elseif strcmpi(mode,'reg')
            strIns{i} = subjProp(i).srcFFile;
        end
    end
    
    % Display the list of file
    set(handles.edit1, 'String', strIns);

    
%--------------------- - - - - - - - -  -  -   -   -    -      -
