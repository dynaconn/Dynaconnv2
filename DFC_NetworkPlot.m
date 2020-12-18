function varargout = DFC_NetworkPlot(varargin)
% DFC_NETWORKPLOT MATLAB code for DFC_NetworkPlot.fig
%      DFC_NETWORKPLOT, by itself, creates a new DFC_NETWORKPLOT or raises the existing
%      singleton*.
%
%      H = DFC_NETWORKPLOT returns the handle to a new DFC_NETWORKPLOT or the handle to
%      the existing singleton*.
%
%      DFC_NETWORKPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFC_NETWORKPLOT.M with the given input arguments.
%
%      DFC_NETWORKPLOT('Property','Value',...) creates a new DFC_NETWORKPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFC_NetworkPlot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFC_NetworkPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFC_NetworkPlot

% Last Modified by GUIDE v2.5 04-Dec-2013 19:05:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DFC_NetworkPlot_OpeningFcn, ...
                   'gui_OutputFcn',  @DFC_NetworkPlot_OutputFcn, ...
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


% --- Executes just before DFC_NetworkPlot is made visible.
function DFC_NetworkPlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFC_NetworkPlot (see VARARGIN)

% Choose default command line output for DFC_NetworkPlot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize GUIDATA
initialize_gui(hObject, handles, false);

% UIWAIT makes DFC_NetworkPlot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DFC_NetworkPlot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;





% --- Executes on "Select Point" button press (pushbutton1).
function selectPoint(hObject, eventdata, handles)
    % Shorten handle var names.
    dim = handles.FormData.dim;
    compList = handles.FormData.compList;
    compOrder = handles.FormData.compOrder;
    subjProp = handles.FormData.subjProp;
    
    % Bring up a cursor to be able to select a data point
    [x,y] = ginput(1);
    % Data is real numbers so make into integers.
    x = round(x);  y = round(y);
    % Translate out-of-bounds numbers
    if x < 1, x = 1; end;
    if y < 1, y = 1; end;
    if x > dim(2), x = dim(2); end;
    if y > dim(1), y = dim(1); end;
    
    % Convert y into subject
    % If the border was select, then move up 1
    if subjProp(y).group == 0
        y = y + 1;
    end

    if strcmpi(handles.mode,'group')
        subj = y;
    else
        % Since subjects are seperated where controls are 1st then patients,
        % convert back to real subject number.
        subj = subjProp(y).index;
        handles.FormData.subjCode = deblank(subjProp(y).code);
    end
    
    % Since components are sorted on the map, covert back to real component
    % numbers. comp_order was saved in the .mat file and loaded here.
    unsortX = compOrder(x);
    
    % Convert x into components
    compN1 = compList(unsortX,1);
    compN2 = compList(unsortX,2);

    % Save data to be retrieved by parent GUI
    setappdata(0,'objN1',compN1);
    setappdata(0,'objN2',compN2);
    setappdata(0,'subjNum',subj);
    setappdata(0,'cmap', handles.FormData.cmap);
    % Close this GUI and return to the parent GUI
    close;

    
% --- Executes on button press in "Exit" button
function pushbutton2_Callback(hObject, eventdata, handles)
    setappdata(0,'objN1',0);
    setappdata(0,'objN2',0);
    setappdata(0,'cmap', handles.FormData.cmap);
    close;
    

% --- Executes on button press in cmapButton.
function changeCMAP(hObject, eventdata, handles)
    % Pull cmap
    cmap = handles.FormData.cmap;
    % Increment cmap
    cmap = cmap + 1;
    if cmap == 5
        cmap = 1;
    end
    handles.FormData.cmap = cmap;
    guidata(hObject,handles);
    % Set the color map
    if cmap == 1
        colormap(linspecer);  % Human linear spaced colors
    elseif cmap == 2
        colormap(jet);  % Matlab default (not human linear spacing)
    elseif cmap == 3
        colormap(copper);
    elseif cmap == 4
        colormap(gray);
    end



% --- Executes on selection change in actionPopupmenu.
function actionPopupmenu_Callback(hObject, eventdata, handles)
    sel = get(hObject,'Value');
    % Choose the function depending on the function selected.
    if sel == 1
    elseif sel == 2
        selectPoint(hObject, eventdata, handles);
    elseif sel == 3
        changeCMAP(hObject, eventdata, handles);
        % Change the function back the original.  Don't need to do this for
        % the selectPoint function because it closes the window.
        set(handles.actionPopupmenu, 'Value', 1);
    end



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


    
function [SADC, subjProp] = printSortMean(SADC, subjProp, cmpL, cmpOrder)
%PRINTSORTMEAN If mean exist then sort and print the top 30
%   Detailed explanation goes here

    % If there is a mean in the list it will be the last row
    if strcmpi(subjProp(end).code, 'Mean')
         meanExist = 1;
    else meanExist = 0;
    end
    
    if meanExist
        % Strip off mean from all Lists, but keep the SADC mean data
        % in a seperate var
        meanSADC = SADC(end, :);
        SADC = SADC(1 : end-1, :);
        subjProp = subjProp(1 : end-1);
        
        % Sort the meanSADC
        [B,IX] = sort(meanSADC);
        B = fliplr(B);
        IX = fliplr(IX);
        
        % Print top 30
        listCutOff = 30;
        fprintf('\n Top %d Mean Avg. Corr of Components\n',listCutOff);
        for i = 1 : listCutOff
            fprintf('avgCorr( Comp %2d, ', cmpL(cmpOrder(IX(i)),1));
            fprintf('Comp %2d ) ', cmpL(cmpOrder(IX(i)),2)); 
            fprintf('= %0.4f\n', B(i));
        end
        fprintf('\n');
    end



% --------------------------------------------------------------------
function initialize_gui(hObject, handles, isreset)
% If the FormData field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
    if isfield(handles, 'FormData') && ~isreset
        return;
    end
    
    % Retrieve data sent from main GUI
    netFName = getappdata(0,'dataFile');
    mode = getappdata(0,'mode');
    cmap = getappdata(0,'cmap');
            
    % Open Data
    load(netFName);
    % Save vars from netFName file
    handles.FormData.compList = compList;
    handles.FormData.compOrder = compOrder;
    handles.FormData.workDir = workDir;
    handles.FormData.subjProp = subjProp;
    handles.mode = mode;
    handles.FormData.cmap = cmap;
    
    % Add a menu bar so the user can use the zoom in tool
    set(handles.figure1, 'Toolbar', 'figure', 'menubar', 'figure');
    
    % Strip off the mean if it exists, then sort and print to screen
    if strcmpi(mode,'net')
        [Sorted_Ave_DFC_Combined, subjProp] = ...
            printSortMean(Sorted_Ave_DFC_Combined, subjProp, ...
            compList, compOrder);
    end
    
    % Plot sorted correlation
    imagesc(Sorted_Ave_DFC_Combined,'Parent',handles.axes1);
    % Set the color map
    if cmap == 1
        colormap(linspecer);  % Human linear spaced colors
    elseif cmap == 2
        colormap(jet);  % Matlab default (not human linear spacing)
    elseif cmap == 3
        colormap(copper);
    elseif cmap == 4
        colormap(gray);
    end
    
    colorbar('peer',handles.axes1);
    if strcmpi(mode,'net')
        title('Network to Network Correlations','FontSize',16);
        xlabel('Network-Network Combination','FontSize',16);
        ylabel('Subjects [groups seperated by bar] ','FontSize',16);
    elseif strcmpi(mode,'reg')
        title('Region to Region Correlations','FontSize',16);
        xlabel('Region-Region Combination','FontSize',16);
        ylabel('Subjects [groups seperated by bar] ','FontSize',16);
    elseif strcmpi(mode,'group')
        title('p-values of DFC between component combinations','FontSize',16);
        xlabel('Component Combinations','FontSize',16);
        ylabel('Group Combinations ','FontSize',16);
    end
    

    
    handles.FormData.dim = size(Sorted_Ave_DFC_Combined);
    %handles.FormData.borderLineNum = borderLineNum; %borderLineNum form netFName
    guidata(hObject,handles);
