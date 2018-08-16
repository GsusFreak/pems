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
% handles.A.classify = {};
handles.A.readings = {};
% handles.A.timestamps = {};
handles.A.readFiles = {};
% handles.A.cntClassify = 1;
handles.A.cntReadings = 1;
% handles.A.cntTimestamps = 1;
handles.A.cntReadFiles = 1;
handles.A.baseDirAddr = pwd;
% handles.A.classifyDirAddr = strcat(handles.A.baseDirAddr,'\classify\');
handles.A.readingsDirAddr = strcat(handles.A.baseDirAddr,'\readings\');
% handles.A.timestampsDirAddr = strcat(handles.A.baseDirAddr,'\timestamps\');
% handles.A.statusDirAddr = strcat(handles.A.baseDirAddr, '\status\');
%handles.A.timestamplog = struct();
%handles.A.voltage = struct();
%handles.A.current = struct();
handles.A.idList = {};
handles.A.cntIdList = 1;
handles.A.graphFrame = 1;
handles.popupmenu_selectDevice.String{1} = '';
handles.A.cntClassification = 1;
handles.A.activeDeviceIndex = 1;
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
    disp('ERROR -- One of the required files (nets.mat, labels.mat, or runNums.mat) didn''t load correctly.');
end

% try
%     load tariff.mat
%     handles.A.nets = tariff_new;
% catch
%     disp('ERROR -- tariff.mat didn''t load correctly.');
% end


% Set up the data structure for each device
handles.A.device = {};
for iaa = 1:length(nets)
    handles.A.device{iaa} = struct();
%     handles.A.device{iaa}.timestamplog = getTimestamp(hObject, eventdata, handles, id);
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
%     handles.A.device{iaa}.deviceNum = deviceNum;
%     handles.A.device{iaa}.idf = idf;
%     switch deviceNum
%         case 1
%             handles.A.(idf).deviceLabel = 'Drill';
%         case 2
%             handles.A.(idf).deviceLabel = 'Soldering Iron';
%     end

%     handles.A.idList{handles.A.cntIdList} = id;

    % Please note that the first entry in the pop up menu is the
    % 'All Devices' tab.
    handles.A.device{iaa}.popUpListNum = iaa + 1;
    handles.popupmenu_selectDevice.String{iaa + 1} = handles.A.device{iaa}.label;
%     handles.A.cntIdList = handles.A.cntIdList + 1;
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

%handles.A.status = 0;
%handles.text18.FontSize = 20;




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

%save('handles', 'handles');
guidata(hObject, handles);
end

function updateAxes(hObject, eventdata, handles)
% statusDir = dir(handles.A.statusDirAddr);
% for iaa = 1:length(statusDir)
%     if strCompare(statusDir(iaa).name, '.txt')
%         
%     end
% end

% classifyDir = dir(handles.A.classifyDirAddr);
% for iaa = 1:length(classifyDir)
%     if strCompare(classifyDir(iaa).name, '.csv')
%         nameTmp = classifyDir(iaa).name;
%         if strCellSearch(nameTmp, handles.A.readFiles) ~= 1
%             dataTmp = csvread(strcat(handles.A.classifyDirAddr, nameTmp));
%             while size(dataTmp(:, 2)) ~= 500000
%                 pause(1);
%                 dataTmp = csvread(strcat(handles.A.classifyDirAddr, nameTmp));
%             end
%             handles.A.classify{handles.A.cntClassify} = struct('name', nameTmp, 'data', dataTmp);
%             handles.A.classify{handles.A.cntClassify}.id = getID(nameTmp);
%             %disp(size(dataTmp(:, 2)));
%             handles.A.classify{handles.A.cntClassify}.classification = doClassify(dataTmp(:, 2));
%             %handles.A.classify{handles.A.cntClassify}.classification = 1;
%             handles.A.readFiles{handles.A.cntReadFiles} = nameTmp;
%             
%             handles.A.cntClassify = handles.A.cntClassify + 1;
%             handles.A.cntReadFiles = handles.A.cntReadFiles + 1;
%             handles.A.cntClassification = handles.A.cntClassification + 1;
%         else
%             %disp(strcat(nameTmp, ' is already in readFile'));
%         end
%     end
% end
% timestampsDir = dir(handles.A.timestampsDirAddr);
% for iaa = 1:length(timestampsDir)
%     if strCompare(timestampsDir(iaa).name, '.csv')
%         nameTmp = timestampsDir(iaa).name;
%         if strCellSearch(nameTmp, handles.A.readFiles) ~= 1
%             fID = fopen(strcat(handles.A.timestampsDirAddr, nameTmp));
%             dataTmp = fgetl(fID);
%             fclose(fID);
%             handles.A.timestamps{handles.A.cntTimestamps} = struct('name', nameTmp, 'data', dataTmp);
%             handles.A.timestamps{handles.A.cntTimestamps}.id = getID(nameTmp);
%             handles.A.readFiles{handles.A.cntReadFiles} = nameTmp;
%             
%             handles.A.cntTimestamps = handles.A.cntTimestamps + 1;
%             handles.A.cntReadFiles = handles.A.cntReadFiles + 1;
%         else
%             %disp(strcat(nameTmp, ' is already in readFile'));
%         end
%     end
% end
readingsDir = dir(handles.A.readingsDirAddr);
for iaa = 1:length(readingsDir)
    if strCompare(readingsDir(iaa).name, '.csv')
        nameTmp = readingsDir(iaa).name;
        if strCellSearch(nameTmp, handles.A.readFiles) ~= 1
            dataTmp = csvread(strcat(handles.A.readingsDirAddr, nameTmp));
            % idTmp = getID(nameTmp);
            % classTmp = getClassification(hObject, eventdata, handles, idTmp);
            classIndex = Run_Classifiers(dataTmp, handles.A.nets);
            handles.A.activeDeviceIndex = classIndex;
%             classNum = handles.A.runNums(classIndex);
%             classLabels = handles.A.labels(classIndex);
            % handles.A.readings{handles.A.cntReadings} = struct('name', nameTmp, 'data', dataTmp);
            % handles.A.readings{handles.A.cntReadings}.id = idTmp;
%             handles.A.readings{handles.A.cntReadings}.classification = classIndex;
            handles.A.readFiles{handles.A.cntReadFiles} = nameTmp;
            
            processData(hObject, eventdata, handles, dataTmp, classIndex);
            handles = guidata(hObject);

            handles.A.cntReadFiles = handles.A.cntReadFiles + 1;
            handles.A.cntReadings = handles.A.cntReadings + 1;
        else
            %disp(strcat(nameTmp, ' is already in readFile'));
        end
    end
end
guidata(hObject, handles);
end

function processData(hObject, eventdata, handles, data, index)
% This function sorts the power readings by adding them
% to the appropriatly labeled struct
% idf = strcat('f', id);


% if ~strCellSearch(id, handles.A.idList)
%     handles.A.(idf) = struct();
%     handles.A.(idf).timestamplog = getTimestamp(hObject, eventdata, handles, id);
%     handles.A.(idf).voltage = double.empty;
%     handles.A.(idf).current = double.empty;
%     handles.A.(idf).popUpListNum = handles.A.cntIdList;
%     handles.A.(idf).averagePwr = 0;
%     handles.A.(idf).energy = 0;
%     handles.A.(idf).cost = 0;
%     handles.A.(idf).cntAveragePwr = 0;
%     handles.A.(idf).deviceNum = deviceNum;
%     handles.A.(idf).idf = idf;
%     switch deviceNum
%         case 1
%             handles.A.(idf).deviceLabel = 'Drill';
%         case 2
%             handles.A.(idf).deviceLabel = 'Soldering Iron';
%     end
%     handles.A.(idf).popUpListStr = strcat(strcat(strcat(handles.A.(idf).deviceLabel, ' (run: '), id), ')');
%     
%     handles.A.idList{handles.A.cntIdList} = id;
%     handles.popupmenu_selectDevice.String{handles.A.cntIdList} = handles.A.(idf).popUpListStr;
%     handles.A.cntIdList = handles.A.cntIdList + 1;
% end
% Add auto-update if statement here
%handles.popupmenu_selectDevice.Value = handles.A.device{index}.popUpListNum;

voltTmp = (data(:, 1)/1023*3.31 - 1.6556)*10790/(2.5*25.3)/sqrt(2); %1.33
currTmp = (data(:, 2)/1023*3.31 - 1.6524)/(25.2*0.002); %1.45

% handles.A.device{index}.instVolt = getAverageOfPeaks(voltTmp);
% handles.A.device{index}.instCurr = getAverageOfPeaks(currTmp);
% handles.A.device{index}.instPwr = handles.A.device{index}.instVolt*handles.A.device{index}.instCurr;
[p_real, p_app, pf] = calcPowerUsage(voltTmp, currTmp);
handles.A.device{index}.instPwr = p_real;
handles.A.device{index}.instRePwr = sqrt(p_app.^2 - p_real.^2);
handles.A.device{index}.powerFactor = pf;
handles.A.device{index}.energy = handles.A.device{index}.energy + ...
    (handles.A.device{index}.instPwr/3600/1000);
cost_of_power = findElectricityCost(datetime, handles.A.tariff);
handles.A.device{index}.cost = handles.A.device{index}.energy * cost_of_power;
if(handles.A.device{index}.cntAveragePwr == 0)
    handles.A.device{index}.averagePwr = handles.A.device{index}.instPwr;
    handles.A.device{index}.cntAveragePwr = handles.A.device{index}.cntAveragePwr + 1;
else
    handles.A.device{index}.averagePwr = ((handles.A.device{index}.averagePwr*handles.A.device{index}.cntAveragePwr) ...
        + handles.A.device{index}.instPwr)/(handles.A.device{index}.cntAveragePwr + 1);
    handles.A.device{index}.cntAveragePwr = handles.A.device{index}.cntAveragePwr + 1;
end

if(handles.A.device{index}.cntReactivePwr == 0)
    handles.A.device{index}.reactivePwr = handles.A.device{index}.instRePwr;
    handles.A.device{index}.cntReactivePwr = handles.A.device{index}.cntReactivePwr + 1;
else
    handles.A.device{index}.reactivePwr = ((handles.A.device{index}.reactivePwr*handles.A.device{index}.cntReactivePwr) ...
        + handles.A.device{index}.instRePwr)/(handles.A.device{index}.cntReactivePwr + 1);
    handles.A.device{index}.cntReactivePwr = handles.A.device{index}.cntReactivePwr + 1;
end



handles.A.device{index}.voltage = vertcat(handles.A.device{index}.voltage, voltTmp);
handles.A.device{index}.current = vertcat(handles.A.device{index}.current, currTmp);

% Update the information for all of the devices
% handles.A.all.instVolt = handles.A.device{index}.instVolt;
% handles.A.all.instCurr = handles.A.device{index}.instCurr;
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


function out = getAverageOfPeaks(data)
pkValues = double.empty;
for cntPkValues = 1:10
    tempMaxValue = 0;
    for iaa = ((cntPkValues - 1)*50 + 1):cntPkValues*50
        if(tempMaxValue < data(iaa))
            tempMaxValue = data(iaa);
        end
    end
    pkValues(cntPkValues) = tempMaxValue;
end
out = mean(pkValues);
end

function drawGraphs(hObject, eventdata, handles, index)
NUM_SEC_REC = 60;

% This is necessary because the 'All Devices' tab is actually in the first
% slot
index = index - 1;

if index == 0
%     handles.text17.String = handles.A.device{index}.timestamplog;
%     handles.text18.String = handles.A.all.label;
    handles.text18.String = 'All Devices';
    handles.avgPwr.String = sprintf('%.2f', handles.A.all.averagePwr);
    handles.text22.String = sprintf('%.2f', handles.A.all.reactivePwr);
    handles.activePwr.String = sprintf('%.2f', handles.A.all.instPwr);
    handles.reactivePwr.String = sprintf('%.2f', handles.A.all.instRePwr);
    handles.text24.String = sprintf('%.6f', handles.A.all.energy);
    handles.text26.String = sprintf('%.6f', handles.A.all.cost);

    graphFrame = floor(length(handles.A.all.current) / (16000*NUM_SEC_REC));

    xValues4Current = (0:length(handles.A.all.current)-1)/16000;
    xValues4Voltage = (0:length(handles.A.all.voltage)-1)/16000;
    plot(handles.axesCurrent, xValues4Current, handles.A.all.current, 'b', 'LineWidth', 3);
    plot(handles.axesVoltage, xValues4Voltage, handles.A.all.voltage, 'b', 'LineWidth', 3);
else
    handles.text18.String = handles.A.device{index}.label;
    handles.avgPwr.String = sprintf('%.2f', handles.A.device{index}.averagePwr);
    handles.text22.String = sprintf('%.2f', handles.A.device{index}.reactivePwr);
    handles.activePwr.String = sprintf('%.2f', handles.A.device{index}.instPwr);
    handles.reactivePwr.String = sprintf('%.2f', handles.A.device{index}.instRePwr);
    handles.text24.String = sprintf('%.6f', handles.A.device{index}.energy);
    handles.text26.String = sprintf('%.6f', handles.A.device{index}.cost);

    graphFrame = floor(length(handles.A.device{index}.current) / (16000*NUM_SEC_REC));

    xValues4Current = (0:length(handles.A.device{index}.current)-1)/16000;
    xValues4Voltage = (0:length(handles.A.device{index}.voltage)-1)/16000;
    plot(handles.axesCurrent, xValues4Current, handles.A.device{index}.current, 'b', 'LineWidth', 3);
    plot(handles.axesVoltage, xValues4Voltage, handles.A.device{index}.voltage, 'b', 'LineWidth', 3);
end
% handles.text18.String = handles.A.device{handles.A.activeDeviceIndex}.label;

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

% function classID = getClassification(hObject, eventdata, handles, id)
% for iaa = 1:(handles.A.cntClassify - 1)
%     if strcmp(id, handles.A.classify{iaa}.id)
%         classID = handles.A.classify{iaa}.classification;
%         break;
%     end
% end
% guidata(hObject, handles);
% end

function GUIUpdate(~, ~, hObject, eventdata, handles)
handles = guidata(hObject);
updateAxes(hObject, eventdata, handles);
handles = guidata(hObject);
id = get(handles.popupmenu_selectDevice, 'Value');
drawGraphs(hObject, eventdata, handles, id);
%disp('It''s printing!');

% function IDF = findID(hObject, eventdata, handles, menuStr)
% for iaa = 1:(handles.A.cntIdList - 1)
%     if strcmp(menuStr, handles.A.(handles.A.idList{iaa}).popUpListStr);
%         IDF = handles.A.(handles.A.idList{iaa}).idf;
%         break;
%     end
% end
end

function out = strCompare(str1, str2)
out = ~isempty(strfind(str1, str2));
end

function idStr = getID(name)
splitStr = strsplit(name, '_');
split2 = strsplit(splitStr{2}, '.');
idStr = split2{1};
end

% function timestamp = getTimestamp(hObject, eventdata, handles, id)
% for iaa = 1:length(handles.A.timestamps)
%     if handles.A.timestamps{iaa}.id == id
%         timestamp = strrep(handles.A.timestamps{iaa}.data, ' ', '_');
%     end
% end
% guidata(hObject, handles);
% end

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
Train_All_Classifiers
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