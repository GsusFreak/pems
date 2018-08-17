function varargout = Main_Program(varargin)
% MAIN_PROGRAM MATLAB code for Main_Program.fig
%      MAIN_PROGRAM, by itself, creates a new MAIN_PROGRAM or raises the existing
%      singleton*.
%
%      H = MAIN_PROGRAM returns the handle to a new MAIN_PROGRAM or the handle to
%      the existing singleton*.
%
%      MAIN_PROGRAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_PROGRAM.M with the given input arguments.
%
%      MAIN_PROGRAM('Property','Value',...) creates a new MAIN_PROGRAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_Program_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_Program_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main_Program

% Last Modified by GUIDE v2.5 24-Apr-2018 16:24:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_Program_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_Program_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT


% --- Executes just before Main_Program is made visible.
function Main_Program_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main_Program (see VARARGIN)

% Choose default command line output for Main_Program
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Main_Program wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% STEP 1 - Read the classify folder to populate the Pop-up Menu with
%          timestamp
% STEP 2 - Call the ANN classifier to classify the devices and generate a
%          .csv file with the names of devices with timestamp and populate
%          the pop-up menu

% Declare user variables
% The struct handles.A is for various user variables
handles.A = struct();
handles.A.readings = {};
handles.A.readFiles = {};
handles.A.cntReadings = 1;
handles.A.cntReadFiles = 1;
handles.A.baseDirAddr = pwd;
handles.A.readingsDirAddr = strcat(handles.A.baseDirAddr,'\readings\');
handles.A.idList = {};
handles.A.cntIdList = 1;
handles.A.graphFrame = 1;
handles.popupmenu_selectDevice.String{1} = '';
handles.A.cntClassification = 1;
handles.A.activeDeviceIndex = 1;
handles.A.SAMPLING_RATE = 16000;
try
    load nets.mat
    load labels.mat
    load runNums.mat
    load tariff_New.mat
    handles.A.nets = nets;
    handles.A.labels = labels;
    handles.A.runNums = runNums;
    handles.A.tariff = tariff;
catch
    disp('ERROR -- One of the required files didn''t load correctly.');
end


% Set up the data structure for each device
handles.A.device = {};
for iaa = 1:length(nets)
    handles.A.device{iaa} = struct();
    handles.A.device{iaa}.voltage = double.empty;
    handles.A.device{iaa}.current = double.empty;
    handles.A.device{iaa}.averagePwr = 0;
    handles.A.device{iaa}.reactivePwr = 0;
    handles.A.device{iaa}.powerFactor = 0;
    handles.A.device{iaa}.instPwr = 0;
    handles.A.device{iaa}.instRePwr = 0;
    handles.A.device{iaa}.energy = 0;
    handles.A.device{iaa}.cost = 0;
    handles.A.device{iaa}.cntAveragePwr = 0;
    handles.A.device{iaa}.cntReactivePwr = 0;
    sizeTmp = size(handles.A.labels{iaa});
    if sizeTmp(2) ~= 0
        handles.A.device{iaa}.label = handles.A.labels{iaa};
    else
        handles.A.device{iaa}.label = handles.A.runNums{iaa};
    end
    
    % Please note that the first entry in the pop up menu is the
    % 'All Devices' tab.
    handles.A.device{iaa}.popUpListNum = iaa + 1;
    handles.popupmenu_selectDevice.String{iaa + 1} = handles.A.device{iaa}.label;
end

% Initialize data structure covering use of all devices
handles.A.all = struct();
handles.A.all.voltage = double.empty;
handles.A.all.current = double.empty;
handles.A.all.popUpListNum = 1;
handles.A.all.averagePwr = 0;
handles.A.all.reactivePwr = 0;
handles.A.all.instPwr = 0;
handles.A.all.instRePwr = 0;
handles.A.all.powerFactor = 0;
handles.A.all.energy = 0;
handles.A.all.cost = 0;
handles.A.all.cntAveragePwr = 0;
handles.A.all.cntReactivePwr = 0;
handles.A.all.label = 'All Devices';
handles.A.all.popUpListNum = 1;
handles.popupmenu_selectDevice.String{1} = handles.A.all.label;

setupIPSocket(hObject, eventdata, handles);

updateAxes(hObject, eventdata, handles);
handles = guidata(hObject);

handles.popupmenu_selectDevice.Value = 1;
drawGraphs(hObject, eventdata, handles, 1);
handles = guidata(hObject);
handles.A.tmr = timer('TimerFcn', {@GUIUpdate, hObject, eventdata, handles}, ...
            'Period', 1, ...
            'ExecutionMode', 'FixedRate');
guidata(hObject, handles);
start(handles.A.tmr);

guidata(hObject, handles);
end



function updateAxes(hObject, eventdata, handles)
out = readDataIPSocket(hObject, eventdata, handles);
%Convert the csv string "out" to an array "dataTmp"
classIndex = Run_Classifier(dataTmp, handles.A.nets);
handles.A.activeDeviceIndex = classIndex;
handles.A.readFiles{handles.A.cntReadFiles} = nameTmp;

processData(hObject, eventdata, handles, dataTmp, classIndex);
handles = guidata(hObject);

handles.A.cntReadFiles = handles.A.cntReadFiles + 1;
handles.A.cntReadings = handles.A.cntReadings + 1;
guidata(hObject, handles);
end

function processData(hObject, eventdata, handles, data, index)
% This function sorts the power readings by adding them
% to the appropriatly labeled struct

% Series of Offset values: 1.33 => 1.6556
voltTmp = (data(:, 1)/1023*3.31 - 1.6556)*10790/(2.5*25.3)/sqrt(2);

% Series of Offset values: 1.45 => 1.6524
currTmp = (data(:, 2)/1023*3.31 - 1.6524)/(25.2*0.002);

[p_real, p_app, p_fac] = calcPowerUsage(voltTmp, currTmp);
handles.A.device{index}.instPwr = p_real;
handles.A.device{index}.instRePwr = sqrt(p_app.^2 - p_real.^2);
handles.A.device{index}.powerFactor = p_fac;
handles.A.device{index}.energy = handles.A.device{index}.energy + ...
    (handles.A.device{index}.instPwr/3600/1000);
cost_of_power = findElectricityCost(datetime, handles.A.tariff);
handles.A.device{index}.cost = handles.A.device{index}.energy * cost_of_power;
if (handles.A.device{index}.cntAveragePwr == 0)
    handles.A.device{index}.averagePwr = handles.A.device{index}.instPwr;
    handles.A.device{index}.cntAveragePwr = handles.A.device{index}.cntAveragePwr + 1;
else
    handles.A.device{index}.averagePwr = ...
        ((handles.A.device{index}.averagePwr*handles.A.device{index}.cntAveragePwr) ...
        + handles.A.device{index}.instPwr)/(handles.A.device{index}.cntAveragePwr + 1);
    handles.A.device{index}.cntAveragePwr = handles.A.device{index}.cntAveragePwr + 1;
end

if (handles.A.device{index}.cntReactivePwr == 0)
    handles.A.device{index}.reactivePwr = handles.A.device{index}.instRePwr;
    handles.A.device{index}.cntReactivePwr = handles.A.device{index}.cntReactivePwr + 1;
else
    handles.A.device{index}.reactivePwr = ...
        ((handles.A.device{index}.reactivePwr*handles.A.device{index}.cntReactivePwr) ...
        + handles.A.device{index}.instRePwr)/(handles.A.device{index}.cntReactivePwr + 1);
    handles.A.device{index}.cntReactivePwr = handles.A.device{index}.cntReactivePwr + 1;
end

handles.A.device{index}.voltage = vertcat(handles.A.device{index}.voltage, voltTmp);
handles.A.device{index}.current = vertcat(handles.A.device{index}.current, currTmp);

% Update the information for all of the devices
handles.A.all.instPwr = handles.A.device{index}.instPwr;
handles.A.all.instRePwr = handles.A.device{index}.instRePwr;
handles.A.all.energy = handles.A.all.energy + ...
    (handles.A.all.instPwr/3600/1000);
cost_of_power = findElectricityCost(datetime, handles.A.tariff);
handles.A.all.cost = handles.A.all.energy * cost_of_power;
if(handles.A.all.cntAveragePwr == 0)
    handles.A.all.averagePwr = handles.A.all.instPwr;
    handles.A.all.cntAveragePwr = 1;
else
    handles.A.all.averagePwr = ((handles.A.all.averagePwr*handles.A.all.cntAveragePwr) ...
        + handles.A.all.instPwr)/(handles.A.all.cntAveragePwr + 1);
    handles.A.all.cntAveragePwr = handles.A.all.cntAveragePwr + 1;
end

if(handles.A.all.cntReactivePwr == 0)
    handles.A.all.reactivePwr = handles.A.all.instRePwr;
    handles.A.all.cntReactivePwr = handles.A.all.cntReactivePwr + 1;
else
    handles.A.all.reactivePwr = ((handles.A.all.reactivePwr*handles.A.all.cntReactivePwr) ...
        + handles.A.all.instRePwr)/(handles.A.all.cntReactivePwr + 1);
    handles.A.all.cntReactivePwr = handles.A.all.cntReactivePwr + 1;
end

handles.A.all.voltage = vertcat(handles.A.all.voltage, voltTmp);
handles.A.all.current = vertcat(handles.A.all.current, currTmp);

guidata(hObject, handles);
end

function [p_real, p_app, pf] = calcPowerUsage(volt, curr)
N = length(volt);
p_real = 0;
rms_volt = 0;
rms_curr = 0;
for iaa = 1:N
    p_real = p_real + volt(iaa).*curr(iaa);
    rms_volt = rms_volt + volt(iaa).*volt(iaa);
    rms_curr = rms_curr + curr(iaa).*curr(iaa);
end
p_real = p_real/N;
rms_volt = sqrt(rms_volt./N);
rms_curr = sqrt(rms_curr./N);
p_app = rms_volt.*rms_curr;
pf = p_real./p_app;
end


function cost = findElectricityCost(t, tariff)
[h, ~, ~] = hms(t);
[~, m, d] = ymd(t);
days_per_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
for iaa = 1:m-1
    d = d + days_per_month(iaa);
end
cost = tariff(d, h);
end


function drawGraphs(hObject, eventdata, handles, index)
NUM_SEC_REC = 60;

% This is necessary because the 'All Devices' tab is actually in 
% the first slot
index = index - 1;

if index == 0
    handles.text18.String = 'All Devices';
    handles.avgPwr.String = sprintf('%.2f', handles.A.all.averagePwr);
    handles.text22.String = sprintf('%.2f', handles.A.all.reactivePwr);
    handles.activePwr.String = sprintf('%.2f', handles.A.all.instPwr);
    handles.reactivePwr.String = sprintf('%.2f', handles.A.all.instRePwr);
    handles.text24.String = sprintf('%.6f', handles.A.all.energy);
    handles.text26.String = sprintf('%.6f', handles.A.all.cost);

    graphFrame = floor(length(handles.A.all.current) / (16000*NUM_SEC_REC));
    
    lenCurr = length(handles.A.all.current);
    if (lenCurr > 0)
        xValues4Current = (0:lenCurr-1)/16000;
        plot(handles.axesCurrent, xValues4Current, handles.A.all.current, ...
            'b', 'LineWidth', 3);
    else
        cla(handles.axesCurrent);
    end
    lenVolt = length(handles.A.all.voltage);
    if (lenVolt > 0)
        xValues4Voltage = (0:lenVolt-1)/16000;
        plot(handles.axesVoltage, xValues4Voltage, handles.A.all.voltage, ...
            'b', 'LineWidth', 3);
    else
        cla(handles.axesVoltage);
    end
    
else
    handles.text18.String = handles.A.device{index}.label;
    handles.avgPwr.String = sprintf('%.2f', handles.A.device{index}.averagePwr);
    handles.text22.String = sprintf('%.2f', handles.A.device{index}.reactivePwr);
    handles.activePwr.String = sprintf('%.2f', handles.A.device{index}.instPwr);
    handles.reactivePwr.String = sprintf('%.2f', handles.A.device{index}.instRePwr);
    handles.text24.String = sprintf('%.6f', handles.A.device{index}.energy);
    handles.text26.String = sprintf('%.6f', handles.A.device{index}.cost);

    graphFrame = floor(length(handles.A.device{index}.current) / (16000*NUM_SEC_REC));

    
    lenCurr = length(handles.A.device{index}.current);
    if (lenCurr > 0)
        xValues4Current = (0:lenCurr-1)/16000;
        plot(handles.axesCurrent, xValues4Current, handles.A.device{index}.current, ...
            'b', 'LineWidth', 3);
    else
        cla(handles.axesCurrent);
    end
    lenVolt = length(handles.A.device{index}.voltage);
    if (lenVolt > 0)
        xValues4Voltage = (0:lenVolt-1)/16000;
        plot(handles.axesVoltage, xValues4Voltage, handles.A.device{index}.voltage, ...
            'b', 'LineWidth', 3);
    else
        cla(handles.axesVoltage);
    end
end

ylim(handles.axesCurrent, [-34, 34]);
ylim(handles.axesVoltage, [-205, 205]);
xlim(handles.axesCurrent, [NUM_SEC_REC*graphFrame, NUM_SEC_REC*(graphFrame + 1)]);
xlim(handles.axesVoltage, [NUM_SEC_REC*graphFrame, NUM_SEC_REC*(graphFrame + 1)]);
xlabel(handles.axesCurrent, 'Time (sec)');
xlabel(handles.axesVoltage, 'Time (sec)');
ylabel(handles.axesCurrent, 'Current (A)');
ylabel(handles.axesVoltage, 'Voltage (V)');

matlabImage = imread('NSF_Logo2.PNG');
image(handles.axes6, matlabImage);
axis(handles.axes6, 'off');

matlabImage = imread('ONSmart_Logo.PNG');
image(handles.axes7, matlabImage);
axis(handles.axes7, 'off');

guidata(hObject, handles);
end

function GUIUpdate(~, ~, hObject, eventdata, handles)
handles = guidata(hObject);
updateAxes(hObject, eventdata, handles);
handles = guidata(hObject);
id = get(handles.popupmenu_selectDevice, 'Value');
drawGraphs(hObject, eventdata, handles, id);
end

function out = strCompare(str1, str2)
out = ~isempty(strfind(str1, str2));
end

function idStr = getID(name)
splitStr = strsplit(name, '_');
split2 = strsplit(splitStr{2}, '.');
idStr = split2{1};
end

function setupIPSocket(hObject, eventdata, handles)
handles.A.charsPerSecond = handles.A.SAMPLING_RATE*10; 
            % There are 10 characters for each set
            % of two samples (voltage, current). 

handles.A.t = tcpip('0.0.0.0', 30000, 'NetworkRole', 'server', ...
    'InputBufferSize', 1048576);
fopen(handles.A.t);

handles.A.numRun = 0;
load('numRun.mat');
numRun = numRun + 1;
handles.A.numRun = numRun;
save('numRun.mat', 'numRun');
guidata(hObject, handles);
end

function out = readDataIPSocket(hObject, eventdata, handles)
if handles.A.t.BytesAvailable >= handles.A.charsPerSecond
    printf("bytes available: %d\n", handles.A.t.BytesAvailable);
    out = char(fread(handles.A.t, handles.A.charsPerSecond)');
end
guidata(hObject, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = Main_Program_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;
end

% --- Executes on selection change in popupmenu_selectDevice.
function popupmenu_selectDevice_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_selectDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_selectDevice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_selectDevice

id = get(handles.popupmenu_selectDevice, 'Value');
drawGraphs(hObject, eventdata, handles, id);
end

% --- Executes during object creation, after setting all properties.
function popupmenu_selectDevice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_selectDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function axesCurrent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesCurrent
end

% --- Executes during object creation, after setting all properties.
function axesVoltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesVoltage


end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

if handles.A.t.BytesAvailable >= 0
    out = char(fread(handles.A.t, handles.A.t.BytesAvailable)');
end

% Insert code to save the received data.

try
    stop(handles.A.tmr);
    delete(handles.A.tmr);
catch
    fprintf('Timer could not be closed.\n');
end
delete(hObject);
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Train_All_Classifiers;
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Remove Device

end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Start Training
label = get(handles.edit3,'String');
runNum = get(handles.edit4,'String');
Train_One_Classifier(runNum, label);
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% End Training

end


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


end

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



