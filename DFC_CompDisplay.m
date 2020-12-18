function varargout = DFC_CompDisplay(varargin)
% DFC_COMPDISPLAY MATLAB code for DFC_CompDisplay.fig
%      DFC_COMPDISPLAY, by itself, creates a new DFC_COMPDISPLAY or raises the existing
%      singleton*.

% Edit the above text to modify the response to help DFC_CompDisplay

% Last Modified by GUIDE v2.5 01-Oct-2013 12:12:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DFC_CompDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @DFC_CompDisplay_OutputFcn, ...
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
end

% --- Executes just before DFC_CompDisplay is made visible.
function DFC_CompDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFC_CompDisplay (see VARARGIN)

% Choose default command line output for DFC_CompDisplay
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize GUIDATA
initialize_gui(hObject, handles, false);

% UIWAIT makes DFC_CompDisplay wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = DFC_CompDisplay_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
    close;
end


% --- Executes on button press in DTdown1.
function DTdown1_Callback(hObject, eventdata, handles)
    ChangeThreshold('down', 1, hObject, handles);
end


% --- Executes on button press in DTup1.
function DTup1_Callback(hObject, eventdata, handles)
    ChangeThreshold('up', 1, hObject, handles);
end


function ChangeThreshold(direction, comp, hObject, handles)
    % Retrieve the image data and other vars from the form
    img = handles.FormData.img;
    mode = handles.mode;
    
    % If direction is up then add 0.1, else subtract 0.1
    if strcmpi(direction,'up')
        pinc_add = 0.1;
    else
        pinc_add = -0.1;
    end
    
    % Update threshold and threshold label
    if comp==1
        pinc = handles.FormData.percent_include1 + pinc_add;
        handles.FormData.percent_include1 = pinc;
        
        DTLabel1Txt = sprintf('Z-score cut-off = %0.1f',handles.FormData.percent_include1);
        set(handles.DTLabel1,'String',DTLabel1Txt,'Value',1);
    elseif comp==2
        pinc = handles.FormData.percent_include2 + pinc_add;
        handles.FormData.percent_include2 = pinc;
        
        DTLabel2Txt = sprintf('Z-score cut-off = %0.1f',handles.FormData.percent_include2);
        set(handles.DTLabel2,'String',DTLabel2Txt,'Value',1);
    end
              
    % Find upper and lower thresholds to seperate data to ignore from data
    % to display (and get regions for in net mode).
    handles.FormData.LL(comp) = -pinc;
    handles.FormData.UL(comp) =  pinc;
    
    % Display component images
    dfc_displaySlices(handles, img);
    
    % Calculate region data from networks
    if strcmpi(mode,'net') || strcmpi(mode,'group')
        dfc_calcNetworkRegions(handles, img);
    end
    
    guidata(hObject,handles);
end


% --- Executes on button press in DTdown2.
function DTdown2_Callback(hObject, eventdata, handles)
    ChangeThreshold('down', 2, hObject, handles);
end


% --- Executes on button press in DTup2.
function DTup2_Callback(hObject, eventdata, handles)
    ChangeThreshold('up', 2, hObject, handles);
end



% --------------------------------------------------------------------
function initialize_gui(hObject, handles, isreset)
% If the FormData field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
    if isfield(handles, 'FormData') && ~isreset
        return;
    end
    
    % Get which mode we are in
    mode = getappdata(0,'mode');
    handles.mode = mode;
    
    % Retrieve data sent from main GUI
    objN1 =   getappdata(0,'objN1');
    objN2 =   getappdata(0,'objN2');
    regMap = getappdata(0,'regMap');
    mask_ind = getappdata(0,'mask_ind');
    subjProp = getappdata(0,'subjProp');
    subjNum = getappdata(0,'subjNum');
    % Save to the form data.
    handles.FormData.objN1 = objN1;
    handles.FormData.objN2 = objN2;
    handles.FormData.regMap = regMap;
    handles.FormData.mask_ind = mask_ind;
    handles.FormData.subjProp = subjProp;
    handles.FormData.subjCodeNum = subjNum;
    if strcmpi(mode,'net') || strcmpi(mode,'group')
        % Set the panels component names
        handles.FormData.panelStr1 = ['Component ' num2str(objN1)];
        handles.FormData.panelStr2 = ['Component ' num2str(objN2)];
    elseif strcmpi(mode,'reg')
        % Set the panels component names
        handles.FormData.panelStr1 = regMap(objN1).name;
        handles.FormData.panelStr2 = regMap(objN2).name;
    end
    

    % Get the image data
    if strcmpi(mode,'net')
        % Open data and extract just 2 comps
        FName = subjProp(subjNum).icFFile;
        V = spm_vol(FName);
        % Load the images, these must be seperated at the 1st dimension for
        % the reshape below to work properly
        img(1,:,:,:) = spm_read_vols(V(objN1));
        img(2,:,:,:) = spm_read_vols(V(objN2));

        % Convert to Z-score
        dim = size(img);
        imgFlat = reshape(img,2,[]);
        mask_ind = (imgFlat ~= 0);
        for i = 1 : 2
            % Remove zero value elements
            x = imgFlat(i,mask_ind(i,:));
            % Remove mean
            x = detrend(x, 0);
            % Normalize
            vstd = norm(x, 2) ./ sqrt(length(x) - 1);
            imgFlat(i,:) = imgFlat(i,:)./(eps + vstd);
        end
        img = reshape(imgFlat,dim);
   
        
        %Andrew Added MM, NN, KK that pulls dimensions from a custom atlas  
    elseif strcmpi(mode,'reg')
        % Build matrix to send to dfc_displaySlices
        MM=subjProp(1).srcDim(1)
        NN=subjProp(1).srcDim(2)
        KK=subjProp(1).srcDim(3)
        img(1,:,:,:) = reshape(squeeze(regMap(objN1).prob),MM,NN,KK);
        img(2,:,:,:) = reshape(squeeze(regMap(objN2).prob),MM,NN,KK);
    elseif strcmpi(mode,'group')
        % Load mean image
        FName = subjProp(1).icFFile;
        V = spm_vol(FName);
        img(1,:,:,:) = spm_read_vols(V(objN1));
        img(2,:,:,:) = spm_read_vols(V(objN2));

        % Convert to Z-score
        dim = size(img);
        imgFlat = reshape(img,2,[]);
        mask_ind = (imgFlat ~= 0);
        for i = 1 : 2
            % Remove zero value elements
            x = imgFlat(i,mask_ind(i,:));
            % Remove mean
            x = detrend(x, 0);
            % Normalize
            vstd = norm(x, 2) ./ sqrt(length(x) - 1);
            imgFlat(i,:) = imgFlat(i,:)./(eps + vstd);
        end
        img = reshape(imgFlat,dim);        
    end
    
    % Initialy how much of the data to the total data to use for the
    % component display and region coverage
    handles.FormData.percent_include1 = 1.0; %Was 25% before chaning to z-score cutoff
    handles.FormData.percent_include2 = 1.0; %Was 25% before chaning to z-score cutoff
    %DTLabelTxt = sprintf('Data Threshold = %d%%',handles.FormData.percent_include);
    DTLabel1Txt = sprintf('Z-score cut-off = %0.1f',handles.FormData.percent_include1);
    DTLabel2Txt = sprintf('Z-score cut-off = %0.1f',handles.FormData.percent_include2);
    set(handles.DTLabel1,'String',DTLabel1Txt,'Value',1);
    set(handles.DTLabel2,'String',DTLabel2Txt,'Value',1);
    
    
    if strcmpi(mode,'net') || strcmpi(mode,'group')
        % Find upper and lower thresholds to seperate data to ignore from data
        % to display (and get regions for in net mode).
        %[handles.FormData.LL, handles.FormData.UL] = findThresholds(handles, img);
        % 29jly2013 request to make threshold just 1.0 in z-score
        handles.FormData.LL = [-1.0, -1.0];
        handles.FormData.UL = [1.0, 1.0];
    elseif strcmpi(mode,'reg')
        % Don't care about the limits in region mode since we are
        % displaying the region map
        handles.FormData.LL = [0 0];
        handles.FormData.UL = [0 0];
        % Since we have no threshold, turn off threshold controls
        set(handles.DTLabel1,'Visible','off');
        set(handles.DTup1,'Visible','off');
        set(handles.DTdown1,'Visible','off');
    end
    
    if strcmpi(mode,'reg')
        set(handles.DTLabel2,'Visible','off');
        set(handles.DTup2,'Visible','off');
        set(handles.DTdown2,'Visible','off');
    end
    
    % Display component images
    % The initial draw is a messy hack to shrink the image to the correct
    % size on both windows and mac so that there is room for the color bar.
    handles.FormData.InitialDraw = 1;
    dfc_displaySlices(handles, img);
    % Don't need to resize again if we happend to redraw (like during
    % theshold change).
    handles.FormData.InitialDraw = 0;
    
    % Calculate region data from networks
    if strcmpi(mode,'net') || strcmpi(mode,'group')
        dfc_calcNetworkRegions(handles, img);
    end
    
    % Resize window for ev and reg mode
    if strcmpi(mode,'reg')
        % For region we don't need component over region tables
        set(handles.uitable1,'Visible','off');
        set(handles.uitable2,'Visible','off');
    end 
    
    % Add a menu bar so the user can use the zoom in tool
    set(handles.figure1, 'Toolbar', 'figure', 'menubar', 'figure');
    
    % Add up and down arrow images to up/down buttons
    ulf = imread('U.png');
    dlf = imread('D.png');
    set(handles.DTup1,'Cdata',ulf);
    set(handles.DTup2,'Cdata',ulf);
    set(handles.DTdown1,'Cdata',dlf);
    set(handles.DTdown2,'Cdata',dlf);
    
    % Save the data to guidata incase the user wants to change thresholds
    handles.FormData.img = img;
    guidata(hObject,handles);
end
