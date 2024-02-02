function GUI_AutomatedAnalysis()
% AutomatedAnalysisTool (MC)
%
% This tool is designed to perform the analysis of neuronal signals (e.g.
% spikedetection, burstdetection ect.) automatically for many data files.
%
% 1) convert Labview-Data (.dat) into .mat (use button in DrCell "convert
% .dat to .mat". After, the suffix of the filename is _RAW
%
% 2) create one thresholdfile for every chip using DrCell (suffix: _Th)
%
% 3) use this tool for the spikedetection (tab1). It creates files with the
% amplitude and time of each spike (= time stamp file, suffix: _TS)
%
% 4) tab2: load all time stamp files that you want to analyze and press
% "calculate parameter". It creates files with the parameter like firing
% rate, burst rate, networkbursts, cross-correlation ect. (suffix: _P)
%
% 5) tab3: laod all parameter files that you want to look at. Select the
% parameter from the dropdown-menu. You can also combine several parameter
% files that are belonging to a group (e.g. control group) and create a
% goup file (suffix: _G) (BETA)
%
% 6) load group files for a statistical comparison (BETA)
%
% written by Manuel Ciba in 2015

global mainpath temp_filename
temp_filename='';
mainpath=[];

global hmain

% Gui Color
global GUI_Color_BG GUI_Color_Buttons GUI_Color_BigButton GUI_Color_Tabs GUI_Color_FG
GUI_Color_BG = [1 1 1]; % old: [.98 .99 1]
GUI_Color_Buttons = ([89 189 207]+40)/255; %[.75 0.9 1]; % rgb(89, 189, 207)
GUI_Color_BigButton = ([0 204 187]+50)/255; %rgb(0, 204, 187)
GUI_Color_Tabs = GUI_Color_BG; % Does not work. Bug in Matlab
GUI_Color_FG = [0.2 0.2 0.2]; % FontColor of tabs

%% GUI

% MainWindow
hmain = figure('Visible','on','units','normalized','outerposition',[0 0 1 1],'Name','Automated Analysis','NumberTitle','off','Toolbar','none','Resize','on','Color',GUI_Color_BG);

% Tabs
tabgroup = uitabgroup('Parent',hmain,'Units','Normalized','Position',[0 0 1 1]);
tab1 = uitab(tabgroup,'Title','Spikedetection','BackgroundColor',GUI_Color_Tabs,'ForegroundColor',GUI_Color_FG);
tab2 = uitab(tabgroup,'Title','Feature Calculation','BackgroundColor',GUI_Color_Tabs,'ForegroundColor',GUI_Color_FG);
tab3 = uitab(tabgroup,'Title','Feature Visualization','BackgroundColor',GUI_Color_Tabs,'ForegroundColor',GUI_Color_FG);
tab4 = uitab(tabgroup,'Title','Statistics','BackgroundColor',GUI_Color_Tabs,'ForegroundColor',GUI_Color_FG);


% --- TAB 1 --------------------------------------

% Panel1_1 - RAW-Data Selection:
hp1_1 = uipanel('Parent',tab1,'Title','Data selection','Position',[.05 .55 .95 .45],'BackgroundColor',GUI_Color_BG);
% Listboxes
uicontrol('style','text','parent',hp1_1,'Units','Normalized','position',[.25 .725 .3 .1],'string','RAW data:','BackgroundColor',GUI_Color_BG)
uicontrol('style','listbox','parent',hp1_1,'Units','Normalized','position',[.25 .1 .3 .6],'tag','listbox_raw','BackgroundColor',GUI_Color_BG)

uicontrol('style','text','parent',hp1_1,'Units','Normalized','position',[.6 .725 .3 .1],'string','Threshold data:','BackgroundColor',GUI_Color_BG)
uicontrol('style','listbox','parent',hp1_1,'Units','Normalized','position',[.6 .1 .3 .6],'tag','listbox_th','BackgroundColor',GUI_Color_BG)

% "Load Files" - Button
uicontrol('parent',hp1_1,'Units','Normalized','Position',[.01 .85 .2 .1],'String','Load Files','FontSize',9,'TooltipString','Load files (or directory if checkbox is checked) containing raw and threshold data into the list.','BackgroundColor',GUI_Color_Buttons,'Callback',@Select1_ButtonCallback);
uicontrol('style','checkbox','parent',hp1_1,'Units','Normalized','Position',[.01 .75 .3 .1], 'string','Select folder and subfolders','Tag','Box_subfolder','BackgroundColor',GUI_Color_BG)

% Remove1
uicontrol('Units','Normalized','parent',hp1_1,'Position',[.22 .85 .2 .1],'String','Remove Selected','FontSize',9,'TooltipString','Rmove selected files from list','BackgroundColor',GUI_Color_Buttons,'Callback',@Remove1_ButtonCallback);

% Root-Path
uicontrol('style','text','parent',hp1_1,'Units','Normalized','Position',[.5 .85 .12 .07],'String','Root path:','BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp1_1,'Units','Normalized','Position',[.6 .85 .3 .07],'string','','Tag','Cell1_RootPath','BackgroundColor',GUI_Color_BG);


% Panel1_2 - Options:
hp1_2 = uipanel('Parent',tab1,'Title','Options','Position',[.05 .05 .95 .5],'BackgroundColor',GUI_Color_BG);
% Options:
uicontrol('style','checkbox','parent',hp1_2,'Units','Normalized','Position',[.01 .8 .3 .1], 'string','Six-well MEA mode','Tag','Box_sixwell','BackgroundColor',GUI_Color_BG)
uicontrol('style','checkbox','parent',hp1_2,'Units','Normalized','Position',[.01 .7 .3 .1], 'string','Detect negative spikes','Tag','Box_negSpikes','value',1,'BackgroundColor',GUI_Color_BG)
uicontrol('style','checkbox','parent',hp1_2,'Units','Normalized','Position',[.01 .6 .3 .1], 'string','Detect positive spikes','Tag','Box_posSpikes','BackgroundColor',GUI_Color_BG)


uicontrol('style','text','parent',hp1_2,'Units','Normalized','Position',[.4 .5 .25 .1],'String','f edge /Hz:','BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp1_2,'Units','Normalized','Position',[.31 .5 .1 .1],'string','50','Tag','Cell_fedge','BackgroundColor',GUI_Color_BG);

uicontrol('style','text','parent',hp1_2,'Units','Normalized','Position',[.4 .4 .25 .1],'String','Refractory Time /ms:','BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp1_2,'Units','Normalized','Position',[.31 .4 .1 .1],'string','0','Tag','Cell_idleTime','BackgroundColor',GUI_Color_BG);

uicontrol('style','text','parent',hp1_2,'Units','Normalized','Position',[.4 .8 .25 .1],'String',{'Spikedetection' '(0: DrCell, 1: SWTEO, 2: Cardio, 3: Only save pictures)'},'BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp1_2,'Units','Normalized','Position',[.31 .8 .1 .1], 'string','0','Tag','Cell_spikedetection','BackgroundColor',GUI_Color_BG)

uicontrol('style','text','parent',hp1_2,'Units','Normalized','Position',[.4 .7 .25 .1],'String',{'Threshold Factor and Basefactor Noise'},'BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp1_2,'Units','Normalized','Position',[.31 .7 .1/2 .1], 'string','5','Tag','Cell_thresholdFactor','BackgroundColor',GUI_Color_BG)

%uicontrol('style','text','parent',hp1_2,'Units','Normalized','Position',[.4 .6 .25 .1],'String',{'Threshold Base Noise Factor' '(e.g. 5, Note)'},'BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp1_2,'Units','Normalized','Position',[.31+.1/2 .7 .1/2 .1], 'string','5','Tag','Cell_baseFactor','BackgroundColor',GUI_Color_BG)


% "Start Spikedetection"
uicontrol('Units','Normalized','parent',hp1_2,'Position',[.5 .1 .3 .2],'String','Start Spikedetection','FontSize',15,'fontweight', 'bold','TooltipString','Start spikedetection for all selected files','BackgroundColor',GUI_Color_BigButton,'Callback',@StartSpikedetection_ButtonCallback);

% DrCell Logo
panax2 = axes('Parent', hp1_2, 'Units','normalized', 'Position', [0.025 0.05 0.15 0.15]);
[img] = imread('biomems.tif');
imshow(img,'Parent',panax2,'InitialMagnification','fit');

% --- TAB 2 --------------------------------------

% Panel2_1 - TS-Data Selection:
hp2_1 = uipanel('Parent',tab2,'Title','TimeStamp-Data selection','Position',[.05 .55 .95 .45],'BackgroundColor',GUI_Color_BG);
% Listbox
uicontrol('style','listbox','parent',hp2_1,'Units','Normalized','position',[.01 .1 .3 .7],'tag','listbox_ts','BackgroundColor',GUI_Color_BG)

% "Load TS-Files" - Button
uicontrol('Units','Normalized','parent',hp2_1,'Position',[.01 .85 .2 .1],'String','Load TS-Files','FontSize',9,'TooltipString','Select TimeStamp-Files (_TS)','BackgroundColor',GUI_Color_Buttons,'Callback',@Select2_ButtonCallback);

% Remove2
uicontrol('Units','Normalized','parent',hp2_1,'Position',[.22 .85 .2 .1],'String','Remove Selected','FontSize',9,'TooltipString','Rmove selected files from list','BackgroundColor',GUI_Color_Buttons,'Callback',@Remove2_ButtonCallback);

% "Feature Calculation" - Button
uicontrol('Units','Normalized','parent',hp2_1,'Position',[.7 .3 .2 .1],'String','Calculate Neuro Features','FontSize',12,'fontweight', 'bold','TooltipString','Calculate features such as spike rate, bursts, synchrony ect.','BackgroundColor',GUI_Color_BigButton,'Callback',@CalcNeuroFeatures_ButtonCallback);
uicontrol('Units','Normalized','parent',hp2_1,'Position',[.7 .1 .2 .1],'String','Calculate Cardio Features','FontSize',12,'fontweight', 'bold','TooltipString','Calculate features such as spike rate, conduction velocity ect.','BackgroundColor',GUI_Color_BigButton,'Callback',@CalcCardioFeatures_ButtonCallback);

% Save/Load List
uicontrol('Units','Normalized','parent',hp2_1,'Position',[.35 .2 .12 .07],'String','Save List','FontSize',7,'TooltipString','Save List with pathes of loaded files','BackgroundColor',GUI_Color_Buttons,'Callback',@SaveList2_ButtonCallback);
uicontrol('Units','Normalized','parent',hp2_1,'Position',[.35 .1 .12 .07],'String','Load List','FontSize',7,'TooltipString','Load List with pathes of loaded files','BackgroundColor',GUI_Color_Buttons,'Callback',@LoadList2_ButtonCallback);

% Preferences:
uicontrol('style','text','parent',hp2_1,'Units','Normalized','Position',[.4 .7 .2 .1],'String','Time Window /s:','BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp2_1,'Units','Normalized','Position',[.55 .7 .1 .1],'string','300','Tag','Cell2_TimeWin','BackgroundColor',GUI_Color_BG);
uicontrol('style','text','parent',hp2_1,'Units','Normalized','Position',[.4 .55 .2 .1],'String','Min. FR /Spikes/min:','BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp2_1,'Units','Normalized','Position',[.55 .55 .1 .1],'string','6','Tag','Cell2_FR_min','BackgroundColor',GUI_Color_BG);
uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.55 .4 .1 .1], 'string','neg. Spikes','Tag','Box2_neg','TooltipString','if checked: only use negative spikes. if neg+pos is checked: use positive and negative spikes, if nothing is checked: use current spikes which are defined by the spike detection','Value',0,'BackgroundColor',GUI_Color_BG)
uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.55 .3 .1 .1], 'string','pos. Spikes','Tag','Box2_pos','TooltipString','if checked: only use positive spikes. if neg+pos is checked: use positive and negative spikes, if nothing is checked: use current spikes which are defined by the spike detection','BackgroundColor',GUI_Color_BG)
uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.55 .2 .1 .1], 'string','60HDMEA','Tag','Box2_60HDMEA','TooltipString','if checked: use 60HDMEA layout instead of 8x8 layout for cardio velocity calculation.','BackgroundColor',GUI_Color_BG)
%uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.81 .85 .2 .1], 'string','Investigate bin/win-size','Tag','Box2_investigate')

% Feature Selection
y1 = .8; dy1 = .05;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Spike rate','Tag','Box2_parameter_FR'); y1=y1-dy1;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Amplitude','Tag','Box2_parameter_AMP'); y1=y1-dy1;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Active Electrodes','Tag','Box2_parameter_ActEL'); y1=y1-dy1;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Burstdetection (Baker)','Tag','Box2_parameter_Burst-Baker'); y1=y1-dy1;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Burstdetection (Selinger)','Tag','Box2_parameter_Burst-Selinger'); y1=y1-dy1;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Networkbursts (Chiappalone)','Tag','Box2_parameter_NB-Chiappalone'); y1=y1-dy1;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Synchrony (Selinger)','Tag','Box2_parameter_Sync-Selinger'); y1=y1-dy1;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Synchrony (MI2)','Tag','Box2_parameter_Sync-MI2'); y1=y1-dy1;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Synchrony (Spike-contrast)','Tag','Box2_parameter_Sync-SC'); y1=y1-dy1;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Entropy (bin: 100 ms)','Tag','Box2_parameter_Entropy1'); y1=y1-dy1;
% uicontrol('style','checkbox','parent',hp2_1,'Units','Normalized','Position',[.7 y1 .2 dy1], 'Value',1, 'string','Entropy (Capurro)','Tag','Box2_parameter_Entropy2'); y1=y1-dy1;

% Export Rasterplot as TS file
uicontrol('Units','Normalized','parent',hp2_1,'Position',[.35 .3 .12 .07],'String','Export merged TS-File','FontSize',9,'TooltipString','Merge all TS-files in listbox to one file and export as new TS-file.','BackgroundColor',GUI_Color_Buttons,'Callback',@ExportTS_ButtonCallback);


% Panel2_2 - Spiketrainwindow:
hp2_2 = uipanel('Parent',tab2,'Title','Rasterplot','Position',[.05 .05 .95 .5],'BackgroundColor',GUI_Color_BG);

% Show Rasterplot Button
uicontrol('Units','Normalized','parent',hp2_2,'Position',[.1 0 .2 .1],'String','Show Rasterplot','FontSize',9,'TooltipString','Display Rasterplot','BackgroundColor',GUI_Color_Buttons,'Callback',@Rasterplot_ButtonCallback);
uicontrol('style','checkbox','parent',hp2_2,'Units','Normalized','Position',[.3 0 .2 .1], 'string','use real clock time to combine TS files','Tag','Box2_realClock','Value',0,'BackgroundColor',GUI_Color_BG)

% "Export Figure" - Button
uicontrol('Units','Normalized','parent',hp2_2,'Position',[.7 .0 .2 .1],'String','Export Figure','FontSize',9,'TooltipString','Export figure in new window','BackgroundColor',GUI_Color_Buttons,'Callback',@Export2_ButtonCallback);

% Axes
axes('Parent',hp2_2,'Units','Normalized','Position',[.1 .2 0.8 .7],'Tag','axes_tab2');


% --- TAB 3 --------------------------------------

% Panel3_1 - Feature-Data Selection:
hp3_1 = uipanel('Parent',tab3,'Title','Feature-Data selection','Position',[.05 .55 .95 .45],'BackgroundColor',GUI_Color_BG);
% Listbox
uicontrol('style','listbox','parent',hp3_1,'Units','Normalized','position',[.01 .1 .3 .7],'tag','listbox_features','BackgroundColor',GUI_Color_BG)

% "Load Files" - Button
uicontrol('Units','Normalized','parent',hp3_1,'Position',[.01 .85 .2 .1],'String','Load Feature-Files','FontSize',9,'TooltipString','Select Feature-Files','BackgroundColor',GUI_Color_Buttons,'Callback',@Select3_ButtonCallback);

% Remove3
uicontrol('Units','Normalized','parent',hp3_1,'Position',[.22 .85 .2 .1],'String','Remove Selected','FontSize',9,'TooltipString','Rmove selected files from list','BackgroundColor',GUI_Color_Buttons,'Callback',@Remove3_ButtonCallback);

% Preferences:
uicontrol('style','text','parent',hp3_1,'Units','Normalized','Position',[.5 .7 .2 .1],'String','X-Label:','BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp3_1,'Units','Normalized','Position',[.7 .7 .1 .1],'String','t /min','Tag','Cell3_XLabel','BackgroundColor',GUI_Color_BG);
uicontrol('style','text','parent',hp3_1,'Units','Normalized','Position',[.5 .55 .2 .1],'String','X-Values:','BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp3_1,'Units','Normalized','Position',[.7 .55 .1 .1],'String','time','Tag','Cell3_XValues','BackgroundColor',GUI_Color_BG);
uicontrol('style','checkbox','parent',hp3_1,'Units','Normalized','Position',[.81 .55 .2 .1], 'string','Log-Scale','Tag','Box3_logscale','BackgroundColor',GUI_Color_BG,'Callback',@Logscale3_BoxCallback)
uicontrol('style','checkbox','parent',hp3_1,'Units','Normalized','Position',[.81 .4 .2 .1], 'string','Boxplot-Mode','Tag','Box3_boxplot','BackgroundColor',GUI_Color_BG)
uicontrol('style','checkbox','parent',hp3_1,'Units','Normalized','Position',[.81 .25 .2 .1], 'string','Normalize','Tag','Box3_normalize','BackgroundColor',GUI_Color_BG)

% "Group Calculation" - Button
uicontrol('Units','Normalized','parent',hp3_1,'Position',[.5 .85 .2 .1],'String','Make Groups','FontSize',12,'fontweight', 'bold','TooltipString','Save selected files as group file (with mean and std)','BackgroundColor',GUI_Color_BigButton,'Callback',@MakeGroups_ButtonCallback);



% Panel3_2 - Spiketrainwindow:
hp3_2 = uipanel('Parent',tab3,'Title','Feature','Position',[.05 .05 .95 .5],'BackgroundColor',GUI_Color_BG);

% Dropdown Menu - Plot Feature
uicontrol('Parent',hp3_2,'Style','popup','Units','Normalized','Position',[0.01 0 .3 .1],'Tag','menu3_plotfeatures','String','empty','Callback',@PlotFeatures_Callback);

% Axes
axes('Parent',hp3_2,'Units','Normalized','Position',[.1 .2 0.8 .7],'Tag','axes_tab3');

% "Export Figure" - Button
uicontrol('Units','Normalized','parent',hp3_2,'Position',[.7 .0 .2 .1],'String','Export Figure','FontSize',9,'TooltipString','Export figure in new window','BackgroundColor',GUI_Color_Buttons,'Callback',@Export3_ButtonCallback);


% --- TAB 4 --------------------------------------

% Panel4_1 - Group-Data Selection:
hp4_1 = uipanel('Parent',tab4,'Title','Group-Data selection','Position',[.05 .55 .95 .45],'BackgroundColor',GUI_Color_BG);
% Listbox
uicontrol('style','listbox','parent',hp4_1,'Units','Normalized','position',[.01 .1 .3 .7],'tag','listbox_group','BackgroundColor',GUI_Color_BG)

% "Load Files" - Button
uicontrol('Units','Normalized','parent',hp4_1,'Position',[.01 .85 .2 .1],'String','Load Group-Files','FontSize',9,'TooltipString','Select Group-Files','BackgroundColor',GUI_Color_Buttons,'Callback',@Select4_ButtonCallback);

% Remove4
uicontrol('Units','Normalized','parent',hp4_1,'Position',[.22 .85 .2 .1],'String','Remove Selected','FontSize',9,'TooltipString','Rmove selected files from list','BackgroundColor',GUI_Color_Buttons,'Callback',@Remove4_ButtonCallback);

% Preferences:
uicontrol('style','text','parent',hp4_1,'Units','Normalized','Position',[.5 .7 .2 .1],'String','X-Label:','BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp4_1,'Units','Normalized','Position',[.7 .7 .1 .1],'String','t /min','Tag','Cell4_XLabel','BackgroundColor',GUI_Color_BG);
uicontrol('style','text','parent',hp4_1,'Units','Normalized','Position',[.5 .55 .2 .1],'String','X-Values:','BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp4_1,'Units','Normalized','Position',[.7 .55 .1 .1],'String','time','Tag','Cell4_XValues','BackgroundColor',GUI_Color_BG);

uicontrol('style','text','parent',hp4_1,'Units','Normalized','Position',[.71 .83 .04 .1],'String','Merge:','BackgroundColor',GUI_Color_BG);
uicontrol('style','edit','parent',hp4_1,'Units','Normalized','Position',[.76 .85 .03 .08],'String','1','Tag','Cell4_Merge','BackgroundColor',GUI_Color_BG);

uicontrol('style','checkbox','parent',hp4_1,'Units','Normalized','Position',[.81 .85 .2 .1], 'string','Log-Scale','Tag','Box4_logscale','BackgroundColor',GUI_Color_BG,'Callback',@Logscale4_BoxCallback)
uicontrol('style','checkbox','parent',hp4_1,'Units','Normalized','Position',[.81 .7 .2 .1], 'string','Median','Tag','Box4_median','BackgroundColor',GUI_Color_BG)
uicontrol('style','checkbox','parent',hp4_1,'Units','Normalized','Position',[.81 .55 .2 .1], 'string','Hill-Fitting','Tag','Box4_fit','BackgroundColor',GUI_Color_BG)
uicontrol('style','checkbox','parent',hp4_1,'Units','Normalized','Position',[.81 .4 .2 .1], 'string','Normalize by mean','Tag','Box4_normalizeByMean','BackgroundColor',GUI_Color_BG)
uicontrol('style','checkbox','parent',hp4_1,'Units','Normalized','Position',[.81 .25 .2 .1], 'string','Normalize by chip','Tag','Box4_normalizeByChip','BackgroundColor',GUI_Color_BG)
uicontrol('style','checkbox','parent',hp4_1,'Units','Normalized','Position',[.81 .10 .2 .1], 'string','ttest','Tag','Box4_ttest','BackgroundColor',GUI_Color_BG)
uicontrol('style','checkbox','parent',hp4_1,'Units','Normalized','Position',[.86 .10 .2 .1], 'string','ks-test','Tag','Box4_kstest','BackgroundColor',GUI_Color_BG)


% Panel4_2 - Spiketrainwindow:
hp4_2 = uipanel('Parent',tab4,'Title','Group','Position',[.05 .05 .95 .5],'BackgroundColor',GUI_Color_BG);

% Dropdown Menu - Plot Group
uicontrol('Parent',hp4_2,'Style','popup','Units','Normalized','Position',[0.01 0 .3 .1],'Tag','menu4_plotgroup','String','empty','Callback',@PlotGroup_Callback);

% "Export CSV" - Button
uicontrol('Units','Normalized','parent',hp4_2,'Position',[.5 .0 .2 .1],'String','Export csv','FontSize',9,'TooltipString','Export all group files into a csv file.','BackgroundColor',GUI_Color_Buttons,'Callback',@ExportCSV_ButtonCallback);

% "Export Figure" - Button
uicontrol('Units','Normalized','parent',hp4_2,'Position',[.7 .0 .2 .1],'String','Export Figure','FontSize',9,'TooltipString','Export figure in new window','BackgroundColor',GUI_Color_Buttons,'Callback',@Export4_ButtonCallback);

% Axes
axes('Parent',hp4_2,'Units','Normalized','Position',[.1 .2 0.8 .7],'Tag','axes_tab4');



%% CALLBACKS

% --- TAB 1 --------------------------------------

% -------------------------------------------------------
    function Select1_ButtonCallback(hObject,event)
        dirarray=[];
        files=[];
        filearray=[];
        
        subfolder = get(findobj(gcf,'Tag','Box_subfolder'),'value');
        
        if ~isempty(mainpath) & mainpath ~= 0
            cd(mainpath)
        end
        
        if subfolder
            % 'Open directory' Window
            dir_name=uigetdir();
            if dir_name == 0
                return
            end
            [dirarray,files]=subdir(dir_name);
            
            if isempty(dirarray)            % if there is no subdirectory
                dirData = dir(dir_name);      % Get the data for the current directory
                dirIndex = [dirData.isdir];  % Find the index for directories
                files = {dirData(~dirIndex).name};  % Get a list of the files
                files = {files};        % make a cell
                dirarray = {dir_name};  % make a cell
            else
                dirData = dir(dir_name);      % Get the data for the current directory
                dirIndex = [dirData.isdir];  % Find the index for directories
                files(1,end+1) = {{dirData(~dirIndex).name}};  % put files of first selected folder into array
                dirarray(1,end+1)={dir_name}; % put first selected folder also in dirarray
            end
        end
        
        if ~subfolder
            % 'Open file' - Window
            %[files,dir_name] = uigetfile({'*_RAW.mat;*_TH.mat','mat files (*_RAW.mat; *_TH.mat)'},'Select all RAW and TH files for spikedetection','MultiSelect','on');
            %filearray = files;
            
            [files,dir_name] =uigetfile({ '*', 'All files'; ...
                '*_RAW.mat;*_TH.mat','mat files (*_RAW.mat; *_TH.mat)'; ...
                '*_RAW.mat; *.brw; *.dat', 'RAW files'; ...
                '*_RAW.mat','Raw data file'; ...
                '*.brw','3brain raw data'; ...
                '*.dat','Labview raw data'; ...
                '*.txt','MCRACK raw data'; ...
                '*.rhd','RHD2000 raw data'; ...
                '*.h5','MCS raw data'; },'Select all RAW data and optionally also TH files for spikedetection.','MultiSelect','on');
            
            if not(iscell(files)) && not(ischar(files)) % if canceled - dont do anything
                return
            end
            if ~iscell(files) %&& ischar( a )
                files = {files}; % force it to be a cell array of strings
            end
            dirarray = {dir_name};
            files={files};
        end
        
        hw = waitbar(0,'Loading data.');
        
        mainpath=dir_name;
        for jjj=1:size(dirarray,2) % loop trough all subdirectories
            
            % waitbar
            waitbar(jjj/size(dirarray,2),hw)
            
            current_dir=dirarray{jjj};
            if ~strcmp(current_dir(end),filesep) % ensure that directory name ends with a fileseperator (\ or /)
                current_dir(end+1)=filesep;
            end
            filearray=files{jjj};
            for iii=1:size(filearray,2) % Loop from 1 to last selected file
                current_file = filearray{iii};
                
                if any(strfind(current_file,'_RAW.mat')) || any(strfind(current_file,'_raw.mat')) || any(strfind(current_file,'.brw')) || any(strfind(current_file,'.dat'))
                    h_raw = findobj('Tag','listbox_raw');
                    %disp(['Loaded into listbox: ' current_file])
                    set(h_raw,'string',[get(h_raw,'String');cellstr([current_dir current_file])]) % info: "filesep" gives / on unix and \ on win
                end
                if any(strfind(current_file,'_TH.mat'))
                    h_th = findobj('Tag','listbox_th');
                    %disp(['Loaded into listbox: ' current_file])
                    set(h_th,'string',[get(h_th,'String');cellstr([current_dir current_file])])
                    clearThresholdFactorField()
                end
            end
        end
        delete(hw);
        h_raw.Max=1000; % maximal 1000 files are selectable in listbox
        h_raw.Min=0;
        h_th.Max=1000;
        h_th.Min=0;
        
        setExampleRootPath(current_dir)
        
    end

    function clearThresholdFactorField()
        h = findobj(hmain,'Tag','Cell_thresholdFactor');
        h.String = '-';
        h = findobj(hmain,'Tag','Cell_baseFactor');
        h.String = '-';
    end

    function setExampleRootPath(exampleRootPath)
        h = findobj('Tag','Cell1_RootPath');
        h.String = exampleRootPath;
    end

% -------------------------------------------------------
    function Remove1_ButtonCallback(~,~)
        h = findobj('Tag','listbox_raw');
        if size(h.String,1)==1
            h.String=[];
        elseif size(h.String,1)>1
            h.String(h.Value)=[];
        end
        h.Value=[];
        
        h = findobj('Tag','listbox_th');
        if size(h.String,1)==1
            h.String=[];
        elseif size(h.String,1)>1
            h.String(h.Value)=[];
        end
        h.Value=[];
    end

% -------------------------------------------------------
    function StartSpikedetection_ButtonCallback(hObject,event)

        disp('Spikedetection started')
        
        % Init
        SPIKEZ=[];
        dirarray=[];
        files=[];
        filearray=[];
        
        % Read options from GUI
        SPIKEZ.PREF.idleTime = str2num(get(findobj(gcf,'Tag','Cell_idleTime'),'string'))/1000; % save value in seconds
        PREF.f_edge = str2num(get(findobj(gcf,'Tag','Cell_fedge'),'string'));
        SPIKEZ.neg.flag = get(findobj(gcf,'Tag','Box_negSpikes'),'value');
        SPIKEZ.pos.flag = get(findobj(gcf,'Tag','Box_posSpikes'),'value');
        SPIKEZ.PREF.sixwell = get(findobj(gcf,'Tag','Box_sixwell'),'value');
        PREF.subfolder = get(findobj(gcf,'Tag','Box_subfolder'),'value');
        flag_spikedetection = str2num(get(findobj(gcf,'Tag','Cell_spikedetection'),'string')); % 0: DrCell, 1: FLieb, 2: Cardio, 3: only save pic of raw data
        PREF.root_path=get(findobj(gcf,'Tag','Cell1_RootPath'),'string');
        PREF.thresholdFactor=str2num(get(findobj(gcf,'Tag','Cell_thresholdFactor'),'string'));
        PREF.baseFactor=str2num(get(findobj(gcf,'Tag','Cell_baseFactor'),'string'));
        
        % Start logging the command window text
        cd(PREF.root_path)
        
        diary logFile_AutoSpikedetection
        diary on
        
        % 'Open directory' Window
        mainpath=uigetdir(PREF.root_path, 'Select a location where you want to save the folder containing the spike trains and pictures');
        if mainpath == 0
            return
        end
        
        dir_name=mainpath;
        
        % get path and filename from listboxes:
        h_raw = findobj('Tag','listbox_raw');
        h_th = findobj('Tag','listbox_th');
        fullpath_raw=h_raw.String;
        fullpath_th=h_th.String;
        
        if flag_spikedetection == 0
            disp('0: Spikedetection (Dr.Cell standard, threshold-based)')
            SPIKEZ=spikedetection_DrCell(SPIKEZ,fullpath_raw,fullpath_th, PREF);
        end
        
        if flag_spikedetection == 1
            disp('1: Spikedetection SWTEO')
            SPIKEZ=spikedetection_SWTEO(SPIKEZ,fullpath_raw,fullpath_th, PREF);
        end
        
        if flag_spikedetection == 2
            disp('2: Spikedetection Cardio')
            SPIKEZ=spikedetection_Cardio(SPIKEZ,fullpath_raw,fullpath_th, PREF);
        end
        
        if flag_spikedetection == 3 % Save only picture of RAW signal without spikedetection
            disp('3: Only save pictures of RAW signal')
            spikedetection_OnlyPictures(fullpath_raw)
        end
        
        
        
        
        disp('Spikedetection finished')
        
        
        diary off
    end

    function SPIKEZ=spikedetection_DrCell(SPIKEZ,fullpath_raw,fullpath_th, PREF)
        f_edge = PREF.f_edge;
        sixwell = SPIKEZ.PREF.sixwell;
        subfolder = PREF.subfolder;
        thresholdFactor = PREF.thresholdFactor;
        baseFactor = PREF.baseFactor;
        root_path = PREF.root_path;
        
        
        for iii=1:size(fullpath_raw,1)
            [p_raw,f_raw,e_raw]=fileparts(fullpath_raw{iii}); % path, filename, extension
            
            disp(['Path of raw file loaded: ' p_raw filesep f_raw e_raw])
            
            % path of original data: root/data/subfolder/files
            % new path for saving data: root/newFolder/subfolder/newfiles
            path_subfolder=erase(p_raw, root_path(1:end-1)); % p_raw - mainpath
            newFolder_TS = 'TS';
            newFolder_Pics = 'Pics_RAW_TS';
            path_savelocation_TS = [mainpath filesep newFolder_TS path_subfolder filesep];
            path_savelocation_Pics = [mainpath filesep newFolder_Pics path_subfolder filesep];
            
            % load threshold file
            if ~isempty(fullpath_th)
                flag_calculateThreshold=0;
                for jjj=1:size(fullpath_th,1)
                    [p_th,f_th,e_th]=fileparts(fullpath_th{jjj});
                    if strcmp(p_raw,p_th) % if path of th file is same as path of raw files, load th file
                        if strcmp(f_raw,f_th(1:end-3)) % if file name is the same, load th file
                            disp(['Path of threshold file loaded: ' p_th filesep f_th e_th])
                            SPIKEZ=LoadThreshold(SPIKEZ,[p_th filesep f_th e_th], thresholdFactor); % load thresholdfile
                        end
                    end
                end
            else % no threshold files loaded, so calculate threshold
                flag_calculateThreshold=1;
            end
            
            % load data and calculate threshold
            flag_waitbar=1;
            file=[f_raw e_raw];
            myPath=p_raw;
            [RAW,~]=readFileFunctionCaller(file,myPath,flag_waitbar,sixwell); % LOAD RAW DATA
            HDrawdata = strcmp(e_raw,'.brw');
            [RAW, SPIKEZ.FILTER.Name, SPIKEZ.FILTER.f_edge]=ApplyFilter(RAW,f_edge,HDrawdata,flag_waitbar);
            SPIKEZ=initSPIKEZ(SPIKEZ,RAW);
            
            if flag_calculateThreshold
                Multiplier_neg=thresholdFactor;
                Multiplier_pos=thresholdFactor;
                if ~HDrawdata; Std_noisewindow=baseFactor; else; Std_noisewindow=9999; end
                Size_noisewindow=0.05; % 50 ms
                HDrawdata = strcmp(e_raw,'.brw');
                [~,~,~,SPIKEZ,COL_RMS,COL_SDT]=calculateThreshold(RAW,SPIKEZ,Multiplier_neg,Multiplier_pos,Std_noisewindow,Size_noisewindow,HDrawdata,flag_waitbar); % using default values of: flag_waitbar,auto,win_beg,win_end,threshrmsdecide);
                % calc SNR
                SPIKEZ=calc_snr_fast(SPIKEZ, COL_RMS, COL_SDT);
                SPIKEZ.PREF.CLEL = zeros(size(RAW.M,2),1);
                SPIKEZ.PREF.Invert_M = zeros(size(RAW.M,2),1);
            end
            
            RAW=invertAndDeleteElectrodes(RAW, SPIKEZ.PREF.CLEL, SPIKEZ.PREF.Invert_M);
            
            % single well mode:
            if ~sixwell
                
                % spikedetection
                SPIKEZ.PREF.flag_isHDMEAmode = HDrawdata;
                SPIKEZ=spikedetection(RAW,SPIKEZ);
                [SPIKEZ]=applyRefractoryAndGetAmplitudes(RAW,SPIKEZ);
                SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
                SPIKEZ=calc_snr(RAW,SPIKEZ);
                SaveSpikes(SPIKEZ,f_raw,path_savelocation_TS)
                if ~HDrawdata; savePlot(RAW,SPIKEZ,f_raw, path_savelocation_Pics); end
            end
            % six well mode:
            if sixwell
                for chamber=1:6
                    path_savelocation_TS = [mainpath filesep newFolder_TS '_ch' num2str(chamber) path_subfolder filesep];
                    path_savelocation_Pics = [mainpath filesep newFolder_Pics '_ch' num2str(chamber) path_subfolder filesep];
                    
                    % Select chamber
                    RAW_ch=RAW;
                    RAW_ch.M(:,:)=0;
                    RAW_ch.M(:,getSixWellChamberIdx(chamber))=RAW.M(:,getSixWellChamberIdx(chamber));
                    
                    % spikedetection
                    SPIKEZ.PREF.flag_isHDMEAmode = HDrawdata;
                    SPIKEZ=spikedetection(RAW_ch,SPIKEZ);
                    
                    SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
                    SPIKEZ=calc_snr(RAW_ch,SPIKEZ);
                    SaveSpikes(SPIKEZ,[f_raw '_ch' num2str(chamber)],path_savelocation_TS)
                    savePlot(RAW_ch,SPIKEZ,[f_raw '_ch' num2str(chamber)],path_savelocation_Pics)
                    disp([f_raw '_ch' num2str(chamber)])
                end
            end
        end
    end

    function SPIKEZ=spikedetection_SWTEO(SPIKEZ,fullpath_raw,fullpath_th, PREF)
        
        f_edge = PREF.f_edge;
        sixwell = SPIKEZ.PREF.sixwell;
        subfolder = PREF.subfolder;
        thresholdFactor = PREF.thresholdFactor;
        baseFactor = PREF.baseFactor;
        root_path = PREF.root_path;
        
        for iii=1:size(fullpath_raw,1)
            
            [p_raw,f_raw,e_raw]=fileparts(fullpath_raw{iii}); % path, filename, extension
            
            disp(['Path of raw file loaded: ' p_raw filesep f_raw e_raw])
            
            % path of original data: root/data/subfolder/files
            % new path for saving data: root/newFolder/subfolder/newfiles
            path_subfolder=erase(p_raw, root_path(1:end-1)); % p_raw - mainpath
            newFolder_TS = 'TS_SWTEO';
            newFolder_Pics = 'Pics_RAW_TS_SWTEO';
            path_savelocation_TS = [mainpath filesep newFolder_TS path_subfolder filesep];
            path_savelocation_Pics = [mainpath filesep newFolder_Pics path_subfolder filesep];
            
            % load threshold file
            if ~isempty(fullpath_th)
                flag_calculateThreshold=0;
                for jjj=1:size(fullpath_th,1)
                    [p_th,f_th,e_th]=fileparts(fullpath_th{jjj});
                    if strcmp(p_raw,p_th) % if path of th file is same as path of raw files, load th file
                        if strcmp(f_raw,f_th(1:end-3)) % if file name is the same, load th file
                            disp(['Path of threshold file loaded: ' p_th filesep f_th e_th])
                            SPIKEZ=LoadThreshold(SPIKEZ,[p_th filesep f_th e_th], thresholdFactor); % load thresholdfile
                        end
                    end
                end
            else % no threshold files loaded, so calculate threshold
                flag_calculateThreshold=1;
            end
            cd(p_raw)
            
            % Load Raw data
            flag_waitbar=1;
            file=[f_raw e_raw];
            myPath=p_raw;
            [RAW,~]=readFileFunctionCaller(file,myPath,flag_waitbar,sixwell); % LOAD RAW DATA
            HDrawdata = strcmp(e_raw,'.brw');
            [RAW, SPIKEZ.FILTER.Name, SPIKEZ.FILTER.f_edge]=ApplyFilter(RAW,f_edge,HDrawdata,flag_waitbar);
            SPIKEZ=initSPIKEZ(SPIKEZ,RAW);
            SPIKEZ.PREF.flag_isHDMEAmode = HDrawdata;
            
            if flag_calculateThreshold
                Multiplier_neg=thresholdFactor;
                Multiplier_pos=thresholdFactor;
                if ~HDrawdata; Std_noisewindow=baseFactor; else; Std_noisewindow=9999; end
                Size_noisewindow=0.05; % 50 ms
                HDrawdata = strcmp(e_raw,'.brw');
                [~,~,~,SPIKEZ,COL_RMS,COL_SDT]=calculateThreshold(RAW,SPIKEZ,Multiplier_neg,Multiplier_pos,Std_noisewindow,Size_noisewindow,HDrawdata,flag_waitbar); % using default values of: flag_waitbar,auto,win_beg,win_end,threshrmsdecide);
                % calc SNR
                SPIKEZ=calc_snr_fast(SPIKEZ, COL_RMS, COL_SDT);
                SPIKEZ.PREF.CLEL = zeros(size(RAW.M,2),1);
                SPIKEZ.PREF.Invert_M = zeros(size(RAW.M,2),1);
            end
            
            RAW=invertAndDeleteElectrodes(RAW, SPIKEZ.PREF.CLEL, SPIKEZ.PREF.Invert_M);
            
            if ~sixwell
                % Spikedetection SWTEO:
                SPIKEZ.PREF.flag_isHDMEAmode = HDrawdata;
                [SPIKEZ]=combinedSpikeDetection(RAW,SPIKEZ); % spikedetection according to Lieb et al. (2017) ("SWTEO")
                [SPIKEZ]=applyRefractoryAndGetAmplitudes(RAW,SPIKEZ);
                SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
                SPIKEZ=calc_snr(RAW,SPIKEZ);
                SaveSpikes(SPIKEZ,f_raw, path_savelocation_TS)
                if ~HDrawdata; savePlot(RAW,SPIKEZ,f_raw, path_savelocation_Pics); end
                disp(f_raw)
            end
            
            if sixwell
                for chamber=1:6
                    path_savelocation_TS = [mainpath filesep newFolder_TS '_ch' num2str(chamber) path_subfolder filesep];
                    path_savelocation_Pics = [mainpath filesep newFolder_Pics '_ch' num2str(chamber) path_subfolder filesep];
                    
                    % Select chamber
                    RAW_ch=RAW;
                    RAW_ch.M(:,:)=0;
                    RAW_ch.M(:,getSixWellChamberIdx(chamber))=RAW.M(:,getSixWellChamberIdx(chamber));
                    
                    % Spikedetection SWTEO:
                    SPIKEZ.PREF.flag_isHDMEAmode = HDrawdata;
                    [SPIKEZ]=combinedSpikeDetection(RAW_ch,SPIKEZ); % spikedetection according to Lieb et al. (2017) ("SWTEO")
                    [SPIKEZ]=applyRefractoryAndGetAmplitudes(RAW_ch,SPIKEZ);
                    SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
                    SPIKEZ=calc_snr(RAW_ch,SPIKEZ);
                    SaveSpikes(SPIKEZ,[f_raw '_ch' num2str(chamber)], path_savelocation_TS)
                    if ~HDrawdata; savePlot(RAW_ch,SPIKEZ,[f_raw '_ch' num2str(chamber)], path_savelocation_Pics); end
                end
            end
        end
    end

    function SPIKEZ=spikedetection_Cardio(SPIKEZ,fullpath_raw,fullpath_th, PREF)
        
        f_edge = PREF.f_edge;
        sixwell = SPIKEZ.PREF.sixwell;
        subfolder = PREF.subfolder;
        thresholdFactor = PREF.thresholdFactor;
        baseFactor = PREF.baseFactor;
        root_path = PREF.root_path;
        
        for iii=1:size(fullpath_raw,1)
            [p_raw,f_raw,e_raw]=fileparts(fullpath_raw{iii}); % path, filename, extension
            
            disp(['Path of raw file loaded: ' p_raw filesep f_raw e_raw])
            
            % path of original data: root/data/subfolder/files
            % new path for saving data: root/newFolder/subfolder/newfiles
            path_subfolder=erase(p_raw, root_path(1:end-1)); % p_raw - mainpath
            newFolder_TS = 'TS';
            newFolder_Pics = 'Pics_RAW_TS';
            path_savelocation_TS = [mainpath filesep newFolder_TS path_subfolder filesep];
            path_savelocation_Pics = [mainpath filesep newFolder_Pics path_subfolder filesep];
            
            % load threshold file
            if ~isempty(fullpath_th)
                flag_calculateThreshold=0;
                for jjj=1:size(fullpath_th,1)
                    [p_th,f_th,e_th]=fileparts(fullpath_th{jjj});
                    if strcmp(p_raw,p_th) % if path of th file is same as path of raw files, load th file
                        if strcmp(f_raw,f_th(1:end-3)) % if file name is the same, load th file
                            disp(['Path of threshold file loaded: ' p_th filesep f_th e_th])
                            SPIKEZ=LoadThreshold(SPIKEZ,[p_th filesep f_th e_th], thresholdFactor); % load thresholdfile
                        end
                    end
                end
            else % no threshold files loaded, so calculate threshold
                flag_calculateThreshold=1;
            end
            
            % read raw file and filter
            flag_waitbar=1;
            file=[f_raw e_raw];
            myPath=p_raw;
            [RAW,~]=readFileFunctionCaller(file,myPath,flag_waitbar,sixwell); % LOAD RAW DATA
            HDrawdata = strcmp(e_raw,'.brw');
            [RAW, SPIKEZ.FILTER.Name, SPIKEZ.FILTER.f_edge]=ApplyFilter(RAW,f_edge,HDrawdata,flag_waitbar);
            SPIKEZ=initSPIKEZ(SPIKEZ,RAW);
            
            if flag_calculateThreshold
                Multiplier_neg=thresholdFactor;
                Multiplier_pos=thresholdFactor;
                if ~HDrawdata; Std_noisewindow=baseFactor; else; Std_noisewindow=9999; end
                Size_noisewindow=0.05; % 50 ms
                HDrawdata = strcmp(e_raw,'.brw');
                [~,~,~,SPIKEZ,COL_RMS,COL_SDT]=calculateThreshold(RAW,SPIKEZ,Multiplier_neg,Multiplier_pos,Std_noisewindow,Size_noisewindow,HDrawdata,flag_waitbar); % using default values of: flag_waitbar,auto,win_beg,win_end,threshrmsdecide);
                SPIKEZ.PREF.CLEL = zeros(size(RAW.M,2),1);
                SPIKEZ.PREF.Invert_M = zeros(size(RAW.M,2),1);
            end
            
            RAW=invertAndDeleteElectrodes(RAW, SPIKEZ.PREF.CLEL, SPIKEZ.PREF.Invert_M);
            
            % single well mode:
            if ~sixwell
                SPIKEZ.PREF.flag_isHDMEAmode = HDrawdata;
                
                [SPIKEZ] = cardioSpikedetection(RAW,SPIKEZ);
                if SPIKEZ.S ==1; SaveSpikes(SPIKEZ,f_raw,path_savelocation_TS); end % only save SPIKEZ if perfectly synchronous
                if ~HDrawdata; savePlot(RAW,SPIKEZ,f_raw(1:length(f_raw)-4), path_savelocation_Pics); end
            end
            % six well mode:
            if sixwell
                HDrawdata = 0; % this function only works with 60 electrode 6-Well chips
                
                for chamber=1:6
                    path_savelocation_TS = [mainpath filesep newFolder_TS '_ch' num2str(chamber) path_subfolder filesep];
                    path_savelocation_Pics = [mainpath filesep newFolder_Pics '_ch' num2str(chamber) path_subfolder filesep];
                    
                    % Select chamber
                    RAW_ch=RAW;
                    RAW_ch.M(:,:)=0;
                    RAW_ch.M(:,getSixWellChamberIdx(chamber))=RAW.M(:,getSixWellChamberIdx(chamber));
                    
                    % spikedetection
                    SPIKEZ.PREF.flag_isHDMEAmode = HDrawdata;
                    [SPIKEZ] = cardioSpikedetection(RAW_ch,SPIKEZ);
                    
                    if SPIKEZ.S ==1; SaveSpikes(SPIKEZ,[f_raw '_ch' num2str(chamber)],path_savelocation_TS); end % only save SPIKEZ if perfectly synchronous
                    savePlot(RAW_ch,SPIKEZ,[f_raw '_ch' num2str(chamber)],path_savelocation_Pics)
                    disp([f_raw '_ch' num2str(chamber)])
                end
            end
        end
    end

    function spikedetection_OnlyPictures(fullpath_raw)
        for iii=1:size(fullpath_raw,1)
            [p_raw,f_raw,e_raw]=fileparts(fullpath_raw{iii}); % path, filename, extension
            
            % path of original data: root/data/subfolder/files
            % new path for saving data: root/newFolder/subfolder/newfiles
            path_subfolder=strrep(p_raw, mainpath,''); % p_raw - mainpath
            newFolder = 'Pics_RAW';
            path_savelocation = [mainpath filesep newFolder path_subfolder filesep];
            
            RAW=LoadRawData([p_raw filesep f_raw e_raw], 0, 0); % path, Clear_EL, Invert_EL
            SPIKEZ.neg.THRESHOLDS.Th=0; % init th, needed for SavePlot()
            SPIKEZ.neg.TS=0;
            
            savePlotRaw(RAW,f_raw(1:length(f_raw)-4),path_savelocation)
            disp(f_raw)
            pack % performs memory garbage collection in order to consolidate workspace memory
        end
    end


% --- TAB 2 --------------------------------------
% -------------------------------------------------------
    function Select2_ButtonCallback(hObject,event)
        dirarray=[];
        files=[];
        filearray=[];
        
        %subfolder = get(findobj(gcf,'Tag','Box_subfolder'),'value');
        subfolder=0;
        
        if ~isempty(mainpath)
            if mainpath~=0
                cd(mainpath)
            end
        end
        
        if subfolder
            % 'Open directory' Window
            dir_name=uigetdir();
            if dir_name == 0
                return
            end
            [dirarray,files]=subdir(dir_name);
            
            if isempty(dirarray)            % if there is no subdirectory
                dirData = dir(dir_name);      % Get the data for the current directory
                dirIndex = [dirData.isdir];  % Find the index for directories
                files = {dirData(~dirIndex).name};  % Get a list of the files
                files = {files};        % make a cell
                dirarray = {dir_name};  % make a cell
            else
                dirData = dir(dir_name);      % Get the data for the current directory
                dirIndex = [dirData.isdir];  % Find the index for directories
                files(1,end+1) = {{dirData(~dirIndex).name}};  % put files of first selected folder into array
                dirarray(1,end+1)={dir_name}; % put first selected folder also in dirarray
            end
        end
        
        if ~subfolder
            % 'Open file' - Window
            [files,dir_name] = uigetfile({'*_TS.mat;', 'mat files (*_TS.mat)'},'Select all consecutive TS files.','MultiSelect','on');
            %filearray = files;
            if not(iscell(files)) && not(ischar(files)) % if canceled - dont do anything
                return
            end
            if ~iscell(files) %&& ischar( a )
                files = {files}; % force it to be a cell array of strings
            end
            dirarray = {dir_name};
            files={files};
        end
        
        
        root_path=get(findobj(gcf,'Tag','Cell1_RootPath'),'string');
        
        mainpath=dir_name;
        for jjj=1:size(dirarray,2) % loop trough all subdirectories
            current_dir=dirarray{jjj};
            % delete root path from directory if available:
            if strncmp(current_dir,root_path,length(root_path)) % only compare first N strings
                current_dir=current_dir(length(root_path)+1:end);
            end
            filearray=files{jjj};
            for iii=1:size(filearray,2) % Loop from 1 to last selected file
                current_file = filearray{iii};
                if any(strfind(current_file,'_TS.mat'))
                    h = findobj('Tag','listbox_ts');
                    set(h,'string',[get(h,'String');cellstr([current_dir current_file])]) % info: "filesep" gives / on unix and \ on win
                end
            end
        end
        h.Max=1000; % maximal 1000 files are selectable in listbox
    end

% -------------------------------------------------------
    function Remove2_ButtonCallback(~,~)
        h = findobj('Tag','listbox_ts');
        h.Max=1000;
        h.Min=0;
        if size(h.String,1)==1
            h.String=[];
        elseif size(h.String,1)>1
            h.String(h.Value)=[];
        end
        h.Value=[];
    end

% -------------------------------------------------------
    function CalcNeuroFeatures_ButtonCallback(hObject,event)
        disp('Calculating Neuro Features')
        
        time_win = str2num(get(findobj(gcf,'Tag','Cell2_TimeWin'),'string'));
        FR_min = str2num(get(findobj(gcf,'Tag','Cell2_FR_min'),'string'));
        
        % get path and filename from listboxes:
        h_ts = findobj('Tag','listbox_ts');
        fullpath_ts=h_ts.String;
        
        % get root path
        root_path=get(findobj(gcf,'Tag','Cell1_RootPath'),'string');
        if ~isempty(root_path)
            mainpath=root_path;
        end
        
        % get flag if real clock time should be used to combine TS files or
        % rather just "glue" all TS files together
        flag_realClock = get(findobj(gcf,'Tag','Box2_realClock'),'value');
        
        % if only one list is loaded (then only _TS-files are in listbox):
        if ~isempty(strfind(fullpath_ts{1},'_TS.mat'))
            MERGED=Init_MERGED();
            for iii=1:size(fullpath_ts,1)
                [p,f,e]=fileparts([root_path fullpath_ts{iii}]); % path, filename, extension
                SPIKEZ=LoadTS([p filesep f e]);
                MERGED=MergeTS(SPIKEZ,MERGED,fullpath_ts{iii},flag_realClock);
            end
            clear SPIKEZ
            
            %% XXX: Delete Noise Spikes (this was used for HDMEA data)
            %th=-30;
            %[MERGED.TS, MERGED.AMP]=DeleteSpikesByAmplitude(MERGED.TS,MERGED.AMP,th);
            
            if testWindowSizeChoice(time_win,MERGED.PREF.rec_dur)
                % continue code
            else
                return
            end
            
            [~,FEATURES]=CalcNeuroFeatures(MERGED,time_win,FR_min); % [MERGED,FEATURES]=CalcFeatures(MERGED,time_win,FR_min)
            FEATURES(1).files=fullpath_ts;
            clear MERGED
            
            % save Features
            cd(p)
            cd ..
            filename=['_F.mat'];
            [filename,mainpath] = uiputfile('*.mat','Save Features to file',filename);
            if not(iscell(filename)) && not(ischar(filename)) % if canceled - dont do anything
                return
            end
            save([mainpath filename],'FEATURES', '-v7.3')
            % put file into listbox
            h=findobj(gcf,'Tag','listbox_features');
            set(h,'string',[get(h,'String');cellstr([mainpath filename])])
            
            h=findobj(gcf,'Tag','listbox_ts');
            h.Max=1000;
            h.Min=0;
        end
        
        % if several lists are in listbox, calc parameter for every list
        if ~isempty(strfind(fullpath_ts{1},'_List.mat'))
            [mainpath] = uigetdir(mainpath,'Select folder where parameter files will be saved');
            for i=1:size(fullpath_ts,1) % loop trough all lists
                disp(['List ' num2str(i) ' of ' num2str(size(fullpath_ts,1))])
                % load _TS-files from current list
                [dir_name,filename]=fileparts([fullpath_ts{i}]);
                temp_filename=filename(1:strfind(filename,'_List')-1); % save filename without "_List" in global variable
                temp=load([dir_name filesep filename]); % temp.fullpath_ts
                
                MERGED=Init_MERGED();
                for iii=1:size(temp.fullpath_ts,1) % loop through all _TS-files
                    [p,f,e]=fileparts([root_path temp.fullpath_ts{iii}]); % path, filename, extension
                    SPIKEZ=LoadTS([p filesep f e]);
                    MERGED=MergeTS(SPIKEZ,MERGED,temp.fullpath_ts{iii},flag_realClock);
                end
                clear SPIKEZ
                
                if testWindowSizeChoice(time_win,MERGED.PREF.rec_dur)
                    % continue code
                else
                    return
                end
                
                [~,FEATURES]=CalcNeuroFeatures(MERGED,time_win,FR_min);
                FEATURES(1).files=temp.fullpath_ts;
                clear MERGED
                
                % save Features
                folder_name = [mainpath filesep 'Features_temp'];
                if ~exist(folder_name,'dir')
                    mkdir(folder_name);
                end
                filename=[temp_filename '_F.mat'];
                save([folder_name filesep filename],'FEATURES', '-v7.3')
                cd ..
                % put file into listbox
                h=findobj(gcf,'Tag','listbox_features');
                set(h,'string',[get(h,'String');cellstr([folder_name filesep filename])])
            end
        end
        
        disp('Feature calculation finished')
    end

% -------------------------------------------------------
    function CalcCardioFeatures_ButtonCallback(hObject,event)
        disp('Calculating Cardio Features')
        
        time_win = str2num(get(findobj(gcf,'Tag','Cell2_TimeWin'),'string'));
        FR_min = str2num(get(findobj(gcf,'Tag','Cell2_FR_min'),'string'));
        
        % get path and filename from listboxes:
        h_ts = findobj('Tag','listbox_ts');
        fullpath_ts=h_ts.String;
        
        % get root path
        root_path=get(findobj(gcf,'Tag','Cell1_RootPath'),'string');
        if ~isempty(root_path)
            mainpath=root_path;
        end
        
        % get flag if real clock time should be used to combine TS files or
        % rather just "glue" all TS files together
        flag_realClock = get(findobj(gcf,'Tag','Box2_realClock'),'value');
        
        % if only one list is loaded (then only _TS-files are in listbox):
        if ~isempty(strfind(fullpath_ts{1},'_TS.mat'))
            MERGED=Init_MERGED();
            for iii=1:size(fullpath_ts,1)
                [p,f,e]=fileparts([fullpath_ts{iii}]); % path, filename, extension
                SPIKEZ=LoadTS([p filesep f e]);
                MERGED=MergeTS(SPIKEZ,MERGED,fullpath_ts{iii},flag_realClock);
            end
            clear SPIKEZ
            
            if testWindowSizeChoice(time_win,MERGED.PREF.rec_dur)
                % continue code
            else
                return
            end
            
            [~,FEATURES]=CalcCardioFeatures(MERGED,time_win,FR_min); % [MERGED,FEATURES]=CalcFeatures(MERGED,time_win,FR_min)
            FEATURES(1).files=fullpath_ts;
            clear MERGED
            
            % save Features
            cd(p)
            cd ..
            filename=['_F.mat'];
            [filename,mainpath] = uiputfile('*.mat','Save Features to file',filename);
            if not(iscell(filename)) && not(ischar(filename)) % if canceled - dont do anything
                return
            end
            save([mainpath filename],'FEATURES', '-v7.3')
            % put file into listbox
            h=findobj(gcf,'Tag','listbox_features');
            set(h,'string',[get(h,'String');cellstr([mainpath filename])])
            
            h=findobj(gcf,'Tag','listbox_ts');
            h.Max=1000;
            h.Min=0;
        end
        
        % if several lists are in listbox, calc parameter for every list
        if ~isempty(strfind(fullpath_ts{1},'_List.mat'))
            [mainpath] = uigetdir(mainpath,'Select folder where parameter files will be saved');
            for i=1:size(fullpath_ts,1) % loop trough all lists
                disp(['List ' num2str(i) ' of ' num2str(size(fullpath_ts,1))])
                % load _TS-files from current list
                [dir_name,filename]=fileparts([fullpath_ts{i}]);
                temp_filename=filename(1:strfind(filename,'_List')-1); % save filename without "_List" in global variable
                temp=load([dir_name filesep filename]); % temp.fullpath_ts
                
                MERGED=Init_MERGED();
                for iii=1:size(temp.fullpath_ts,1) % loop through all _TS-files
                    [p,f,e]=fileparts([root_path temp.fullpath_ts{iii}]); % path, filename, extension
                    SPIKEZ=LoadTS([p filesep f e]);
                    MERGED=MergeTS(SPIKEZ,MERGED,temp.fullpath_ts{iii},flag_realClock);
                end
                clear SPIKEZ
                
                if testWindowSizeChoice(time_win,MERGED.PREF.rec_dur)
                    % continue code
                else
                    return
                end
                
                [~,FEATURES]=CalcCardioFeatures(MERGED,time_win,FR_min);
                FEATURES(1).files=temp.fullpath_ts;
                clear MERGED
                
                % save Features
                folder_name = [mainpath filesep 'Features_temp'];
                if ~exist(folder_name,'dir')
                    mkdir(folder_name);
                end
                filename=[temp_filename '_F.mat'];
                save([folder_name filesep filename],'FEATURES', '-v7.3')
                cd ..
                % put file into listbox
                h=findobj(gcf,'Tag','listbox_features');
                set(h,'string',[get(h,'String');cellstr([folder_name filesep filename])])
            end
        end
        
        disp('Feature calculation finished')
    end

% --------------------------------------------------------
    function [flag_isValid]=testWindowSizeChoice(winSize,rec_dur) % winSize has to be smaller or eual to rec_dur
        if winSize> rec_dur
            errordlg(['Time window size has to be smaller or equal to the entire recording duration of ' num2str(rec_dur) ' s.'])
            flag_isValid = false;
            return
        else
            flag_isValid = true;
        end
    end

% -------------------------------------------------------
    function SaveList2_ButtonCallback(~,~)
        % get path and filename from listboxes:
        h_ts = findobj('Tag','listbox_ts');
        fullpath_ts=h_ts.String;
        
        [filename,mainpath] = uiputfile('*.mat','Save Features to file',[temp_filename '_List.mat']);
        if not(iscell(filename)) && not(ischar(filename)) % if canceled - dont do anything
            return
        end
        save([mainpath filename],'fullpath_ts', '-v7.3')
    end

% -------------------------------------------------------
    function LoadList2_ButtonCallback(~,~)
        global fullpath_ts
        
        % get root path
        root_path=get(findobj(gcf,'Tag','Cell1_RootPath'),'string');
        if ~isempty(root_path)
            mainpath=root_path;
            cd(root_path)
        end
        
        % 'Open file' - Window
        [filename,dir_name] = uigetfile({'*_List.mat;', 'mat files (*_List.mat)'},'Select one or several lists containing spike-train-pathes.','MultiSelect','on');
        if not(iscell(filename)) && not(ischar(filename)) % if canceled - dont do anything
            return
        end
        
        % if only one list is selected, load _TS-files into listbox
        if ~iscell(filename)
            temp_filename=filename(1:strfind(filename,'_List')-1); % save filename without "_List" in global variable
            
            load([dir_name filesep filename])
            
            % get path and filename from listboxes:
            h_ts = findobj('Tag','listbox_ts');
            h_ts.String=fullpath_ts;
        end
        
        % if several lists are selected, load lists into listbox
        if iscell(filename)
            % get path and filename from listboxes:
            h_ts = findobj('Tag','listbox_ts');
            for i=1:size(filename,2)
                set(h_ts,'string',[get(h_ts,'String');cellstr([dir_name filename{i}])])
            end
            %h_ts.String=[dir_name filesep filename];
        end
        
    end

% -------------------------------------------------------
    function Export2_ButtonCallback(hObj,~)
        ha2 = findobj(gcf,'Type','Axes','Tag','axes_tab2');
        hf = figure; % Open a new figure with handle f1
        s = copyobj(ha2,hf); % Copy axes object ha4 into figure hf
    end

% -------------------------------------------------------
    function ExportTS_ButtonCallback(hObj,~)
        % get path and filename from listboxes:
        h_ts = findobj('Tag','listbox_ts');
        fullpath_ts=h_ts.String;
        
        % get root path
        root_path=get(findobj(gcf,'Tag','Cell1_RootPath'),'string');
        
        % get flag if real clock time should be used to combine TS files or
        % rather just "glue" all TS files together
        flag_realClock = get(findobj(gcf,'Tag','Box2_realClock'),'value');
        
        % if only one list is loaded (then only _TS-files are in listbox):
        if ~isempty(strfind(fullpath_ts{1},'_TS.mat'))
            MERGED=Init_MERGED();
            for iii=1:size(fullpath_ts,1)
                [p,f,e]=fileparts([root_path fullpath_ts{iii}]); % path, filename, extension
                
                file = [f e];
                myPath = p;
                flag_waitbar = 0;
                [~,SPIKEZ]=readFileFunctionCaller(file,myPath,flag_waitbar);
                %SPIKEZ=LoadTS([p filesep f e]);
                MERGED=MergeTS(SPIKEZ,MERGED,fullpath_ts{iii},flag_realClock); % SPIKEZ,MERGED,filename
            end
            temp.SPIKEZ=MERGED;
            clear SPIKEZ MERGED
            
            [filename,save_path] = uiputfile('*.mat','Save merged spike trains as TS.mat',[root_path fullpath_ts{1}(1:end-7) '_merged_TS.mat']);
            if not(iscell(filename)) && not(ischar(filename)) % if canceled - dont do anything
                return
            end
            %[p,f,e]=fileparts([save_path filename]);
            save([save_path filename], 'temp', '-v7.3') % use '-v7.3' to allow saving data greater than 2 GB (but takes longer as compression is used!)
        end
    end

% -------------------------------------------------------
    function Rasterplot_ButtonCallback(~,~)
        
        % get path and filename from listboxes:
        h_ts = findobj('Tag','listbox_ts');
        fullpath_ts=h_ts.String;
        
        % get root path
        root_path=get(findobj(gcf,'Tag','Cell1_RootPath'),'string');
        
        % get flag if real clock time should be used to combine TS files or
        % rather just "glue" all TS files together
        flag_realClock = get(findobj(gcf,'Tag','Box2_realClock'),'value');
        
        % if only one list is loaded (then only _TS-files are in listbox):
        if ~isempty(strfind(fullpath_ts{1},'_TS.mat'))
            MERGED=Init_MERGED();
            for iii=1:size(fullpath_ts,1)
                [p,f,e]=fileparts([root_path fullpath_ts{iii}]); % path, filename, extension
                %SPIKEZ=LoadTS([p filesep f e]);
                
                file = [f e];
                myPath = p;
                flag_waitbar = 0;
                [~,SPIKEZ]=readFileFunctionCaller(file,myPath,flag_waitbar);
                MERGED=MergeTS(SPIKEZ,MERGED,fullpath_ts{iii},flag_realClock); % SPIKEZ,MERGED,filename
            end
            
            %% XXX: Delete Noise Spikes
            %%th=-30;
            %%[MERGED.TS, MERGED.AMP]=DeleteSpikesByAmplitude(MERGED.TS,MERGED.AMP,th);
            
            Rasterplot(MERGED)
        end
    end

% --- TAB 3 ---------------------------------------

% -------------------------------------------------------
    function Select3_ButtonCallback(hObject,event)
        dirarray=[];
        files=[];
        filearray=[];
        
        %subfolder = get(findobj(gcf,'Tag','Box_subfolder'),'value');
        subfolder=0;
        
        if ~isempty(mainpath) & mainpath~=0
            cd(mainpath)
        end
        
        if subfolder
            % 'Open directory' Window
            dir_name=uigetdir();
            if dir_name == 0
                return
            end
            [dirarray,files]=subdir(dir_name);
            
            if isempty(dirarray)            % if there is no subdirectory
                dirData = dir(dir_name);      % Get the data for the current directory
                dirIndex = [dirData.isdir];  % Find the index for directories
                files = {dirData(~dirIndex).name};  % Get a list of the files
                files = {files};        % make a cell
                dirarray = {dir_name};  % make a cell
            else
                dirData = dir(dir_name);      % Get the data for the current directory
                dirIndex = [dirData.isdir];  % Find the index for directories
                files(1,end+1) = {{dirData(~dirIndex).name}};  % put files of first selected folder into array
                dirarray(1,end+1)={dir_name}; % put first selected folder also in dirarray
            end
        end
        
        if ~subfolder
            % 'Open file' - Window
            [files,dir_name] = uigetfile({'*_F.mat;', 'mat files (*_F.mat)'},'Select Features File.','MultiSelect','on');
            %filearray = files;
            if not(iscell(files)) && not(ischar(files)) % if canceled - dont do anything
                return
            end
            if ~iscell(files) %&& ischar( a )
                files = {files}; % force it to be a cell array of strings
            end
            dirarray = {dir_name};
            files={files};
        end
        
        
        mainpath=dir_name;
        for jjj=1:size(dirarray,2) % loop trough all subdirectories
            current_dir=dirarray{jjj};
            filearray=files{jjj};
            for iii=1:size(filearray,2) % Loop from 1 to last selected file
                current_file = filearray{iii};
                if any(strfind(current_file,'.mat'))
                    h = findobj('Tag','listbox_features');
                    set(h,'string',[get(h,'String');cellstr([current_dir current_file])]) % info: "filesep" gives / on unix and \ on win
                end
            end
        end
        h.Max=1000; % maximal 1000 files are selectable in listbox
        
        % Load Features File
        global FEATURES
        load(h.String{1})
        
        % Update Dropdown menu:
        h=findobj(gcf,'Tag','menu3_plotfeatures');
        h.String={FEATURES(:).YLabel};
    end

% -------------------------------------------------------
    function Remove3_ButtonCallback(~,~)
        h = findobj('Tag','listbox_features');
        h.Max=1000;
        h.Min=0;
        if size(h.String,1)==1
            h.String=[];
        elseif size(h.String,1)>1
            h.String(h.Value)=[];
        end
        h.Value=[];
    end

% -------------------------------------------------------
    function PlotFeatures_Callback(hObj,~)
        global FEATURES
        
        
        % clear current plot
        ha3 = findobj(gcf,'Type','Axes','Tag','axes_tab3');
        axes(ha3)
        cla % clear axes
        
        % get XLabel and XValues
        XLabel = get(findobj(gcf,'Tag','Cell3_XLabel'),'string');
        XValue = get(findobj(gcf,'Tag','Cell3_XValues'),'string');
        
        % boxplot or normal plot?
        boxplot_flag = get(findobj(gcf,'Tag','Box3_boxplot'),'value');
        
        
        % Load all files in features listbox
        h = findobj('Tag','listbox_features');
        m=hObj.Value; % parameter index
        for iii=1:size(h.String,1) % plot all files
            if ~iscell(h.String)
                load(h.String)
                [p,f,e]=fileparts(h.String);
            else
                load(h.String{iii})
                [p,f,e]=fileparts(h.String{iii});
            end
            Legend{iii}=f; % filename as content in legend
            if ~strcmp(XValue,'time') FEATURES(1).x = str2num(XValue); end % get x values
            FEATURES(1).XLabel=XLabel; % get x label
            
            %YLim(2)=max(FEATURES(m).mean+FEATURES(m).std)*1.1;
            %XLim(2)=max(FEATURES(1).x)*1.1;
            %YLim(isnan(YLim))=1;
            %XLim(isnan(XLim))=1;
            if boxplot_flag
                BoxPlotFeatures(FEATURES(1).x,FEATURES(m).values,FEATURES(1).XLabel,FEATURES(m).YLabel,Legend)
            else
                PlotFeatures(FEATURES(1).x,FEATURES(m).mean,FEATURES(m).std,FEATURES(1).XLabel,FEATURES(m).YLabel,Legend)
            end
        end
        
        % set marker and linestyle of all curves to different styles
        marker_array={'o','<','d','s','^','>','v','p','h','x','*','+','.','o','<','d','s','^','>','v','p','h','x','*','+','.'};
        linestyle_array={'--','-.','-',':','--','-.','-',':','--','-.','-',':','--','-.','-',':'}; % '-' | '--' | ':' | '-.'
        color_array=[0 0 1; 0 1 0; 0.635 0.078 0.184; 0 .5 .5; 1 0 0; 0 0 0; .5 .5 0; .5 0 .5; 0    0.4470    0.7410; 0.8500    0.3250    0.0980; 0.9290    0.6940    0.1250; 0.4940    0.1840    0.5560; 0.4660    0.6740    0.1880; 0.3010    0.7450    0.9330 ];
        
        j=0;
        for i=1:size(ha3.Children,1)
            if strcmp(ha3.Children(i).Type,'line')%'errorbar')
                j=j+1;
                ha3.Children(i).Marker=marker_array{j};
                ha3.Children(i).LineStyle=linestyle_array{j};
                ha3.Children(i).Color=color_array(j,:);
            end
        end
    end

% -------------------------------------------------------
    function Logscale3_BoxCallback(hObj,~)
        ha3 = findobj(gcf,'Type','Axes','Tag','axes_tab3');
        
        if hObj.Value
            ha3.XScale='log';
        else
            ha3.XScale='linear';
        end
    end

% -------------------------------------------------------
    function MakeGroups_ButtonCallback(~,~)
        global FEATURES
        % Load all selected files in features listbox
        h = findobj('Tag','listbox_features');
        list=h.String(h.Value);
        for iii=1:size(list,1) % plot all files
            load(list{iii})
            GROUP(iii).FEATURES=FEATURES;
        end
        
        [filename,mainpath] = uiputfile('*.mat','Save selected features as group to file','_G.mat');
        if not(iscell(filename)) && not(ischar(filename)) % if canceled - dont do anything
            return
        end
        save([mainpath filename],'GROUP', '-v7.3')
    end

% -------------------------------------------------------
    function Export3_ButtonCallback(hObj,~)
        ha3 = findobj(gcf,'Type','Axes','Tag','axes_tab3');
        hf = figure; % Open a new figure with handle f1
        s = copyobj(ha3,hf); % Copy axes object ha4 into figure hf
    end


% --- TAB 4 ---------------------------------------

% -------------------------------------------------------
    function Select4_ButtonCallback(hObject,event)
        dirarray=[];
        files=[];
        filearray=[];
        
        %subfolder = get(findobj(gcf,'Tag','Box_subfolder'),'value');
        subfolder=0;
        
        % if ~isempty(mainpath)
        %     cd(mainpath)
        % end
        
        if subfolder
            % 'Open directory' Window
            dir_name=uigetdir();
            if dir_name == 0
                return
            end
            [dirarray,files]=subdir(dir_name);
            
            if isempty(dirarray)            % if there is no subdirectory
                dirData = dir(dir_name);      % Get the data for the current directory
                dirIndex = [dirData.isdir];  % Find the index for directories
                files = {dirData(~dirIndex).name};  % Get a list of the files
                files = {files};        % make a cell
                dirarray = {dir_name};  % make a cell
            else
                dirData = dir(dir_name);      % Get the data for the current directory
                dirIndex = [dirData.isdir];  % Find the index for directories
                files(1,end+1) = {{dirData(~dirIndex).name}};  % put files of first selected folder into array
                dirarray(1,end+1)={dir_name}; % put first selected folder also in dirarray
            end
        end
        
        if ~subfolder
            % 'Open file' - Window
            [files,dir_name] = uigetfile({'*_G.mat;', 'mat files (*_G.mat)'},'Select Group Files.','MultiSelect','on');
            %filearray = files;
            if not(iscell(files)) && not(ischar(files)) % if canceled - dont do anything
                return
            end
            if ~iscell(files) %&& ischar( a )
                files = {files}; % force it to be a cell array of strings
            end
            dirarray = {dir_name};
            files={files};
        end
        
        
        mainpath=dir_name;
        for jjj=1:size(dirarray,2) % loop trough all subdirectories
            current_dir=dirarray{jjj};
            filearray=files{jjj};
            for iii=1:size(filearray,2) % Loop from 1 to last selected file
                current_file = filearray{iii};
                if any(strfind(current_file,'.mat'))
                    h = findobj('Tag','listbox_group');
                    set(h,'string',[get(h,'String');cellstr([current_dir current_file])]) % info: "filesep" gives / on unix and \ on win
                end
            end
        end
        h.Max=1000; % maximal 1000 files are selectable in listbox
        
        % Load FILE
        FILE(1)=load(h.String{1});
        
        % Update Dropdown menu:
        h=findobj(gcf,'Tag','menu4_plotgroup');
        h.String={FILE(1).GROUP(1).FEATURES(:).YLabel};
    end

% -------------------------------------------------------
    function Remove4_ButtonCallback(~,~)
        h = findobj('Tag','listbox_group');
        h.Max=1000;
        h.Min=0;
        if size(h.String,1)==1
            h.String=[];
        elseif size(h.String,1)>1
            h.String(h.Value)=[];
        end
        h.Value=[];
    end

% -------------------------------------------------------
    function PlotGroup_Callback(hObj,~)
        
        % clear current plot
        ha4 = findobj(gcf,'Type','Axes','Tag','axes_tab4');
        axes(ha4)
        cla % clear axes
        
        % hill-fitting?
        fit_flag = get(findobj(gcf,'Tag','Box4_fit'),'value');
        
        % ttest?
        ttest_flag = get(findobj(gcf,'Tag','Box4_ttest'),'value');
        
        % ks-test?
        kstest_flag = get(findobj(gcf,'Tag','Box4_kstest'),'value');
        
        % normalize?
        normalizeByChip_flag = get(findobj(gcf,'Tag','Box4_normalizeByChip'),'value'); % normalize every Chip to its first x value
        normalizeByMean_flag = get(findobj(gcf,'Tag','Box4_normalizeByMean'),'value'); % first calc the mean of all chips, then normalize means by the mean of first x value
        
        % median or mean?
        median_flag = get(findobj(gcf,'Tag','Box4_median'),'value');
        
        % merge datapoints? (e.g. point 1...5 belongs to c=0uM, and point
        % 6...10 belongs to c=10uM)
        merge = str2double(get(findobj(gcf,'Tag','Cell4_Merge'),'string'));
        
        % Load all files in listbox
        h = findobj('Tag','listbox_group');
        m=hObj.Value; % parameter index
        for iii=1:size(h.String,1) % plot all files
            if ~iscell(h.String)
                FILE(iii)=load(h.String);
                [p,f,e]=fileparts(h.String);
            else
                FILE(iii)=load(h.String{iii});
                [p,f,e]=fileparts(h.String{iii});
            end
            Legend{iii}=[f ' (n=' num2str(size(FILE(iii).GROUP,2)) ')']; % filename and number of chips as content in legend
        end
        
        % get XLabel and XValues
        XLabel = get(findobj(gcf,'Tag','Cell4_XLabel'),'string');
        XValue = get(findobj(gcf,'Tag','Cell4_XValues'),'string');
        if ~strcmp(XValue,'time')
            FILE(1).GROUP(1).FEATURES(1).x=str2num(XValue);
        end
        
        % Merge datapoints if demanded
        if merge>1
            for f=1:size(FILE,2) % for every file(=group)
                for g=1:size(FILE(f).GROUP,2) % for every chip
                    p=m; % only consider selected features
                    FILE(f).GROUP(g).FEATURES(p).mean=squeeze(FILE(f).GROUP(g).FEATURES(p).mean); % reduce to singleton in case it's e.g. 1x1x10
                    for k=1:ceil(size(FILE(f).GROUP(g).FEATURES(1).x,2)/merge)
                        datapoint_beg=1+merge*(k-1);
                        datapoint_end=merge*k;
                        temp(k)=mean(FILE(f).GROUP(g).FEATURES(p).mean(datapoint_beg:datapoint_end),1);
                    end
                    FILE(f).GROUP(g).FEATURES(p).mean=temp;
                    FILE(f).GROUP(g).FEATURES(1).x=1:size(FILE(f).GROUP(g).FEATURES(p).mean,2); % new x values
                end
            end
            
        end
        
        % calculate mean and std for each group
        for f=1:size(FILE,2) % for every file(=group)
            for g=1:size(FILE(f).GROUP,2) % for every chip
                for p=m %1:size(FILE(f).GROUP(g).FEATURES,2) % for every parameter
                    
                    % ks-test (Kolmogorov Smirnow Test)
                    if kstest_flag
                        if size(FILE(1).GROUP(1).FEATURES(1).x,2)==2 % if two x values
                            if size(size(FILE(f).GROUP(g).FEATURES(p).values),2)==3 % if values are 3D (e.g. cross-correlation-matrix 60 x 60 x XValues)
                                [~,p_ks(g)]=kstest2(nonzeros(FILE(f).GROUP(g).FEATURES(p).values(:,:,5)),nonzeros(FILE(f).GROUP(g).FEATURES(p).values(:,:,10)));
                            end
                        end
                    end
                    
                    FILE(f).GROUP(g).mean(:,p)=FILE(f).GROUP(g).FEATURES(p).mean; % all mean values of a single chip mean(y(c),p)
                    
                    % normalize all values to their first x-value (for each
                    % chip)
                    if normalizeByChip_flag
                        first_x = FILE(f).GROUP(g).mean(1,p);
                        for c=1:size(FILE(f).GROUP(g).mean(:,p),1) % for all x values (e.g. concentrations)
                            FILE(f).GROUP(g).mean(c,p) = FILE(f).GROUP(g).mean(c,p) / first_x;
                        end
                    end
                    
                    % Median of every chip
                    if median_flag
                        FILE(f).GROUP(g).FEATURES(p).values(FILE(f).GROUP(g).FEATURES(p).values==0)=NaN; % set all 0 to NaN and than calculate median
                        if size(size(FILE(f).GROUP(g).FEATURES(p).values),2)==2
                            FILE(f).GROUP(g).median(:,p)=median(median(FILE(f).GROUP(g).FEATURES(p).values,3,'omitnan'),1,'omitnan');
                        end
                        if size(size(FILE(f).GROUP(g).FEATURES(p).values),2)==3
                            FILE(f).GROUP(g).median(:,p)=median(median(median(FILE(f).GROUP(g).FEATURES(p).values,4,'omitnan'),2,'omitnan'),1,'omitnan');
                        end
                    end
                    
                    %[EWmean,EWstd,EW]=electrodeWiseVariance(FILE(f).GROUP(g).FEATURES(p).values);
                    % FILE(f).GROUP(g).FEATURES(p).values2D=transform3Dto2D(FILE(f).GROUP(g).FEATURES(p).values,0);
                    
                end
                FILE(f).mean(:,:,g)=FILE(f).GROUP(g).mean; % all mean values of several chips belonging to a group mean(y(c),p,chips)
                if median_flag FILE(f).median(:,:,g)=FILE(f).GROUP(g).median; end
                % FILE(f).values2D(:,:,g)=FILE(f).GROUP(g).values2D;
            end
            
            % up to now the old standard variation is not considered.
            % Therefore, only parameter without standard variation are
            % handled correct:
            if ~median_flag % calculate mean from mean values
                FILE(f).y(:,:)=mean(FILE(f).mean(:,:,:),3,'omitnan'); % dim: (y values over x, parameter)
                FILE(f).err(:,:)=std(FILE(f).mean(:,:,:),0,3,'omitnan');
            else % calculate mean from median values
                FILE(f).y(:,:)=mean(FILE(f).median(:,:,:),3,'omitnan'); % dim: (y values over x, parameter)
                FILE(f).err(:,:)=std(FILE(f).median(:,:,:),0,3,'omitnan');
            end
            
            
            PlotGroup(FILE(1).GROUP(1).FEATURES(1).x, FILE(f).y(:,m), FILE(f).err(:,m),XLabel,FILE(f).GROUP(1).FEATURES(m).YLabel,Legend)
        end
        
        
        % calculate EC50 for every chip:
        %         if 1
        %         for f=1:size(FILE,2)
        %             y_all=squeeze(FILE(f).mean(:,m,:));
        %             %y_all(isnan(y_all))=0;
        %             x=FILE(1).GROUP(1).FEATURES(1).x;
        %             for i=1:size(y_all,2)
        %                 [FILE(f).coeffs_chips(:,i),~]=doseResponse(x,y_all(:,i)',normalize_flag); % min, max, ec50, hill
        %             end
        %         end
        %         end
        
        % t-test:
        if ttest_flag
            if size(FILE,2)==1 && size(FILE(1).GROUP(1).FEATURES(1).x,2)==2  % if only one group file is loaded with two x-values, use ttest (paired) to compare y(x1) with y(x2) (e.g. c=0 µM vs. c=1 µM)
                ttest_call(FILE(1).GROUP(1).FEATURES(1).x, FILE(1).mean(1,m,:), FILE(1).mean(2,m,:), normalizeByMean_flag)
            end
            if size(FILE,2)==2 % if two group files are loaded, use ttest2 to campare both files
                ttest2_call(FILE(1).GROUP(1).FEATURES(1).x, FILE(1).mean(:,m,:), FILE(2).mean(:,m,:), normalizeByMean_flag)
            end
            % test if EC50 of two chips are significant different
            %             ttest2_call(2000, FILE(1).coeffs_chips(3,:), FILE(2).coeffs_chips(3,:), 0)
        end
        
        % show ks-test values
        if kstest_flag
            text(0,0.1,['Chips: ' num2str(p_ks)])
            text(0,0.2,['Median: ' num2str(median(p_ks))])
            text(0,0.3,['Mean: ' num2str(mean(p_ks))])
        end
        
        % set marker and linestyle of all curves to different styles
        marker_array={'o','<','d','s','^','>','v','p','h','x','*','+','.','o','<','d','s','^','>','v','p','h','x','*','+','.'};
        linestyle_array={'--','-.','-',':','--','-.','-',':','--','-.','-',':','--','-.','-',':'}; % '-' | '--' | ':' | '-.'
        color_array=[0 .2 .8; 0 .8 .2; 0.635 0.078 0.184; 0 .5 .5; 1 0 0; 0 0 0; .5 .5 0; .5 0 .5; 0    0.4470    0.7410; 0.8500    0.3250    0.0980; 0.9290    0.6940    0.1250; 0.4940    0.1840    0.5560; 0.4660    0.6740    0.1880; 0.3010    0.7450    0.9330 ];
        j=0;
        for i=1:size(ha4.Children,1)
            if strcmp(ha4.Children(i).Type,'errorbar')
                j=j+1;
                ha4.Children(i).Marker=marker_array{j};
                ha4.Children(i).LineStyle=linestyle_array{j};
                ha4.Children(i).Color=color_array(j,:);
            end
        end
        
        % hill-fitting
        if fit_flag
            hill_fit_call(FILE(1).GROUP(1).FEATURES(1).x, FILE(1).mean(:,m,:))
        end
        
        % [x,varges,n]=AnalysisOfVariance(xj,sj,nj)
        
    end

% -------------------------------------------------------
    function Logscale4_BoxCallback(hObj,~)
        ha = findobj(gcf,'Type','Axes','Tag','axes_tab4');
        
        if hObj.Value
            ha.XScale='log';
        else
            ha.XScale='linear';
        end
    end

% -------------------------------------------------------
    function ExportCSV_ButtonCallback(hObj,~)
        
        disp('csv export started')
        
        % Load all files in listbox
        h = findobj('Tag','listbox_group');
        m=hObj.Value; % parameter index
        for iii=1:size(h.String,1) % for all files
            if ~iscell(h.String)
                FILE(iii)=load(h.String);
                Name(iii) = {h.String};
                [p,f,e]=fileparts(h.String);
            else
                FILE(iii)=load(h.String{iii});
                Name(iii) = {h.String{iii}};
                [p,f,e]=fileparts(h.String{iii});
            end
            Legend{iii}=[f ' (n=' num2str(size(FILE(iii).GROUP,2)) ')']; % filename and number of chips as content in legend
        end
        
        
        % save as csv
        for idx_file=1:size(FILE,2) % for all files
            for idx_chip=1:size(FILE(idx_file).GROUP,2)
                for f=1:size(FILE(idx_file).GROUP(idx_chip).FEATURES,2) % for all features
                    allMeanValues(:,f) = FILE(idx_file).GROUP(idx_chip).FEATURES(f).mean; % dim: x-values, features
                    allLabels{f} = FILE(idx_file).GROUP(idx_chip).FEATURES(f).YLabel;
                end
                
                [p,f,e]=fileparts(Name{idx_file});
                filename = [p filesep f '_Chip_' num2str(idx_chip) '_of_' num2str(size(FILE(idx_file).GROUP,2)) '.csv'];
                T = array2table(allMeanValues, 'VariableNames', allLabels);
                writetable(T,filename)
            end
        end
        
        disp('csv export finished')
        
    end

% -------------------------------------------------------
    function Export4_ButtonCallback(hObj,~)
        ha4 = findobj(gcf,'Type','Axes','Tag','axes_tab4');
        hf = figure; % Open a new figure with handle f1
        s = copyobj(ha4,hf); % Copy axes object ha4 into figure hf
    end

%% NESTED FUNCTIONS

% --- TAB 1 --------------------------------------------------------------

% --- invertAndDeleteElectrodes -------------------------------------------
    function RAW=invertAndDeleteElectrodes(RAW,CLEL,Invert_M)
        
        % clear electrodes
        if CLEL ~= 0
            RAW.M(:,CLEL)=0;
        end
        % invert electrodes
        if Invert_M ~= 0
            RAW.M(:,Invert_M)=RAW.M(:,Invert_M).*(-1);
        end
        
    end

% --- Load TH Data -------------------------------------------
    function SPIKEZ=LoadThreshold(SPIKEZ,fullpath, thresholdFactor)
        
        global temp
        
        temp = load(fullpath);
        if isfield(temp, 'THRESHOLDS')
            %SPIKEZ.THRESHOLDS.Th=temp.THRESHOLDS;
            SPIKEZ.neg.THRESHOLDS.Th=temp.THRESHOLDS;
            SPIKEZ.neg.THRESHOLDS.Th(SPIKEZ.neg.THRESHOLDS.Th==0)=10000; % set zeros to high value, so no spikes are detected
        end
        if isfield(temp, 'CLEL')
            SPIKEZ.PREF.CLEL=temp.CLEL;
        end
        if isfield(temp, 'Invert_M')
            SPIKEZ.PREF.Invert_M=temp.Invert_M;
        end
        if isfield(temp,'THRESHOLDS_pos')
            SPIKEZ.pos.THRESHOLDS.Th=temp.THRESHOLDS_pos;
            SPIKEZ.pos.THRESHOLDS.Th(SPIKEZ.pos.THRESHOLDS.Th==0)=10000; % set zeros to high value, so no spikes are detected
        end
        
        if isfield(temp, 'PREF')
            SPIKEZ.neg.THRESHOLDS.Multiplier=temp.PREF(1);
            SPIKEZ.neg.THRESHOLDS.Std_noisewindow=temp.PREF(15);
            SPIKEZ.neg.THRESHOLDS.Size_noisewindow=temp.PREF(16);
        else
            SPIKEZ.neg.THRESHOLDS.Multiplier=5;
            SPIKEZ.neg.THRESHOLDS.Std_noisewindow=5;
            SPIKEZ.neg.THRESHOLDS.Size_noisewindow=50/1000;
        end
        
        if isfield(temp, 'COL_RMS')
            SPIKEZ.PREF.COL_RMS=temp.COL_RMS;
        else
            disp(['WARNING: no COL_RMS in Threshold file: ' fullpath])
        end
        if isfield(temp, 'COL_SDT')
            SPIKEZ.PREF.COL_SDT=temp.COL_SDT;
        end
        
        % load noise level if exist, and
        % re-calculate threshold by means of the specified
        % threshold factor (e.g. 5 * noise-level)
        if isfield(SPIKEZ.PREF,'COL_RMS') && ~isempty(thresholdFactor)
            disp('Warning: Threshold factor of _TH file was replaced by the user selected threshold factor in the GUI!')
            if isfield(temp,'THRESHOLDS') % for negative threshold
                SPIKEZ.neg.THRESHOLDS.Th = thresholdFactor.* SPIKEZ.PREF.COL_RMS .*(-1);
                SPIKEZ.neg.THRESHOLDS.Multiplier = thresholdFactor;
                SPIKEZ.neg.THRESHOLDS.Th(SPIKEZ.neg.THRESHOLDS.Th==0)=10000; % set zeros to high value, so no spikes are detected
            end
            if isfield(temp,'THRESHOLDS_pos') % for positive threshold
                SPIKEZ.pos.THRESHOLDS.Th = thresholdFactor.* SPIKEZ.PREF.COL_RMS .*(1);
                SPIKEZ.pos.THRESHOLDS.Multiplier = thresholdFactor;
                SPIKEZ.pos.THRESHOLDS.Th(SPIKEZ.pos.THRESHOLDS.Th==0)=10000; % set zeros to high value, so no spikes are detected
            end
        end
        
    end

% --- Save Spikes Data -------------------------------------------
    function SaveSpikes(SPIKEZ,filename,dir_name)
        
        
        filename=[filename '_TS.mat'];
        fullpath = [dir_name filename];
        
        
        % --- DIRECTORY ----
        if ~exist(dir_name,'dir')
            mkdir(dir_name);
        end
        % --- DIRECTORY ----
        
        saveSpikes(fullpath, SPIKEZ)
        
    end

% --- SixWell -------------------------------------------
    function idx=getSixWellChamberIdx(chamber)
        
        switch chamber
            case 0
                
            case 1
                idx=[15,23:26,31:34];
            case 2
                idx=[40:42,47:50,55:56];
            case 3
                idx=[43:44,51:54,58:60];
            case 4
                idx=[27:30,35:38,46];
            case 5
                idx=[5:6,11:14,19:21];
            case 6
                idx=[1:3,7:10,17:18];
        end
    end


% --- Save Pictures -------------------------------------------
    function savePlot(RAW,SPIKEZ,filename,dir_name)
        
        % --- DIRECTORY ----
        if ~exist(dir_name,'dir')
            mkdir(dir_name);
        end
        % --- DIRECTORY ----
        
        fullpath = [dir_name filename];
        
        hf=figure;
        hf.Visible='off';
        hf.Units='pixels';
        N = size(RAW.M,2);  % number of electrodes
        
        y_delta = 100;
        RAW.M(RAW.M>100)=y_delta;
        RAW.M(RAW.M<-100)=-y_delta;
        
        for n=1:N % for each electrode
            
            % display RAW data
            step=6; % undersampling: 1/step
            offset=(n-1)*y_delta;
            hp=plot(RAW.T(1:step:end), RAW.M(1:step:end,n) + offset, 'green'); hold all
            hp.LineWidth=0.05;
            hp.Parent.XLim=[0 RAW.rec_dur];
            hp.Parent.LineWidth=0.05;
            
            % Display data with spike-marker
            scale=0;
            SP = nonzeros(SPIKEZ.TS(:,n));                       % (green triangles)
            y_axis = ones(length(SP),1).*scale;
            line ('Xdata',SP,'Ydata', y_axis + offset + y_delta/2,...
                'LineStyle','none','Marker','.',...
                'MarkerFaceColor','red','MarkerEdgeColor','red','MarkerSize',10);
            
            % Display Threshold
            if SPIKEZ.neg.flag
                if size(SPIKEZ.neg.THRESHOLDS.Th,2)==size(SPIKEZ.neg.TS,2)
                    line ('Xdata',[0 RAW.T(length(RAW.T))],...
                        'Ydata',[SPIKEZ.neg.THRESHOLDS.Th(n)+offset, SPIKEZ.neg.THRESHOLDS.Th(n)+offset],...
                        'LineStyle','--','LineWidth',0.05,'Color','black');
                end
            end
            
            if SPIKEZ.pos.flag
                if size(SPIKEZ.pos.THRESHOLDS.Th,2)==size(SPIKEZ.pos.TS,2)
                    line ('Xdata',[0 RAW.T(length(RAW.T))],...
                        'Ydata',[SPIKEZ.pos.THRESHOLDS.Th(n)+offset, SPIKEZ.pos.THRESHOLDS.Th(n)+offset],...
                        'LineStyle','--','LineWidth',0.05,'Color','black');
                end
            end
        end
        
        hp.Parent.TickLength=[0 0];%[0.3 0.3];
        hp.Parent.FontSize=12;
        hp.Parent.YTick=[1:y_delta:N*y_delta];
        hp.Parent.YTickLabel=num2str(RAW.EL_NUMS(:));
        hp.Parent.YLim=[-y_delta y_delta*N];
        xlabel('t /s');
        
        
        % save
        if 1
            hf.PaperPositionMode = 'auto';
            hf.Units='points';
            hf.Position=[0 0 1200*2 800*2];
            print(hf, [fullpath '.jpg'],'-djpeg','-r100') % -dtiff: compressed, -dtiffn: not compressed, -r0: screen resolution, -r300: 300dpi
        end
        
    end

% --- Save Pictures -------------------------------------------
    function savePlotRaw(RAW,filename,dir_name)
        
        % --- DIRECTORY ----
        if ~exist(dir_name,'dir')
            mkdir(dir_name);
        end
        % --- DIRECTORY ----
        
        fullpath = [dir_name filename];
        
        
        hf=figure;
        hf.Visible='off';
        hf.Units='pixels';
        N = size(RAW.M,2);
        
        RAW.M(RAW.M>100)=100;
        RAW.M(RAW.M<-100)=-100;
        
        i=-1; % current subplot position
        for n=1:N
            
            i=i+1;
            
            % skip edges of matrix (for MEA-Layout)
            if 0
                if n==1
                    i=i+1;
                end
                if n==7
                    i=i+1;
                end
                if n==55
                    i=i+1;
                end
                hsp=subplot(8,8,i);
            end
            
            %hsp=subplot(N,1,i);
            
            
            step=6;
            hp=plot(RAW.T(1:step:end), RAW.M(1:step:end,n)+(i*100), 'blue');
            %xlabel('t /s');
            %ylabel(['EL ' num2str(RAW.EL_NUMS(n))]);
            hp.LineWidth=0.05;
            
            hp.Parent.XLim=[0 RAW.rec_dur];
            %hp.Parent.YLim=[-70 20];
            
            %hp.Parent.XTickLabel=[];
            %hp.Parent.YTickLabel=[];
            %hp.Parent.Box='off';
            hp.Parent.LineWidth=0.05;
            
            hold all
        end
        
        hp.Parent.TickLength=[0 0];%[0.3 0.3];
        hp.Parent.FontSize=12;
        hp.Parent.YTick=[1:100:60*100];
        hp.Parent.YTickLabel=num2str(RAW.EL_NUMS(:));
        hp.Parent.YLim=[-100 100*60];
        xlabel('t /s');
        %linkaxes();
        
        %saveas(hf, [filename '.fig'], 'fig');
        %saveas(hf, [filename '.jpg'],'jpg');
        
        if 1
            hf.PaperPositionMode = 'auto';
            hf.Units='points';
            %hf.PaperPosition=[0 0 21/2 21/2];
            hf.Position=[0 0 1200*2 800*2];
            
            print(hf, [fullpath '.jpg'],'-djpeg','-r100') % -dtiff: compressed, -dtiffn: not compressed, -r0: screen resolution, -r300: 300dpi
        end
    end

% --- TAB 2 ---------------------------------------------------------------

% --- Load TimeStamps -------------------------------------------
    function SPIKEZ=LoadTS(fullpath)
        
        disp('Load spike train file')
        
        temp=load(fullpath);
        SPIKEZ=temp.temp.SPIKEZ;
        clear temp
        
        flag_neg = get(findobj(gcf,'Tag','Box2_neg'),'value');
        flag_pos = get(findobj(gcf,'Tag','Box2_pos'),'value');
        
        % create field 'AMP', 'neg' and 'pos' if not exist
        if ~isfield(SPIKEZ,'AMP')
            SPIKEZ.AMP=zeros(size(SPIKEZ.TS)); % create dummy amps
            SPIKEZ.AMP(SPIKEZ.TS~=0) = 1;
        end
        if isempty(SPIKEZ.AMP)  % old SPIKEZ files exist, that contain a field AMP but which is empty
           SPIKEZ.AMP=zeros(size(SPIKEZ.TS)); % create dummy amps
           SPIKEZ.AMP(SPIKEZ.TS~=0) = 1;
        end 
        if ~isfield(SPIKEZ,'neg')
            SPIKEZ.neg.TS=NaN;
            SPIKEZ.neg.AMP=NaN;
        elseif ~isfield(SPIKEZ.neg,'TS') % sometimes field "neg" exists but not TS and AMP
            SPIKEZ=rmfield(SPIKEZ,'neg'); % first remove 'neg' as it is probably no structure element
            SPIKEZ.pos.TS=NaN;
            SPIKEZ.pos.AMP=NaN;
        end
        if ~isfield(SPIKEZ,'pos')
            SPIKEZ.pos.TS=NaN;
            SPIKEZ.pos.AMP=NaN;
        elseif ~isfield(SPIKEZ.pos,'TS') % sometimes field "pos" exists but not TS and AMP
            SPIKEZ=rmfield(SPIKEZ,'pos'); % first remove 'pos' as it is probably no structure element
            SPIKEZ.pos.TS=NaN;
            SPIKEZ.pos.AMP=NaN;
        end
        if ~isfield(SPIKEZ.PREF, 'sixwell')  % if no field exist, assume that file is not a sixwell-MEA recording
           SPIKEZ.PREF.sixwell = 0; 
        end
        
        
        % if TS contains NaN replace it by zero (as this software needs the
        % old format)
        SPIKEZ.TS(isnan(SPIKEZ.TS))=0;
        SPIKEZ.AMP(isnan(SPIKEZ.AMP))=0;
        SPIKEZ.neg.TS(isnan(SPIKEZ.neg.TS))=0;
        SPIKEZ.neg.AMP(isnan(SPIKEZ.neg.AMP))=0;
        SPIKEZ.pos.TS(isnan(SPIKEZ.pos.TS))=0;
        SPIKEZ.pos.AMP(isnan(SPIKEZ.pos.AMP))=0;
        
        
        % ensure that all TS and AMP matrices have same size
        if size(SPIKEZ.neg.TS,1)>1 || size(SPIKEZ.pos.TS,1)>1 % only if negative or positive fields have values inside
            % TS:
            I=max([size(SPIKEZ.TS,1),size(SPIKEZ.neg.TS,1),size(SPIKEZ.pos.TS,1)]);
            N=max([size(SPIKEZ.TS,2),size(SPIKEZ.neg.TS,2),size(SPIKEZ.pos.TS,2)]);
            TS=zeros(I,N);
            TSneg=zeros(I,N);
            TSpos=zeros(I,N);
            TS(1:size(SPIKEZ.TS,1),1:size(SPIKEZ.TS,2))=SPIKEZ.TS(:,:);
            TSneg(1:size(SPIKEZ.neg.TS,1),1:size(SPIKEZ.neg.TS,2))=SPIKEZ.neg.TS(:,:);
            TSpos(1:size(SPIKEZ.pos.TS,1),1:size(SPIKEZ.pos.TS,2))=SPIKEZ.pos.TS(:,:);
            SPIKEZ.TS=TS;
            SPIKEZ.neg.TS=TSneg;
            SPIKEZ.pos.TS=TSpos;
            clear TS TSneg TSpos
            % AMP:
            I=max([size(SPIKEZ.AMP,1),size(SPIKEZ.neg.AMP,1),size(SPIKEZ.pos.AMP,1)]);
            N=max([size(SPIKEZ.AMP,2),size(SPIKEZ.neg.AMP,2),size(SPIKEZ.pos.AMP,2)]);
            AMP=zeros(I,N);
            AMPneg=zeros(I,N);
            AMPpos=zeros(I,N);
            AMP(1:size(SPIKEZ.AMP,1),1:size(SPIKEZ.AMP,2))=SPIKEZ.AMP(:,:);
            AMPneg(1:size(SPIKEZ.neg.AMP,1),1:size(SPIKEZ.neg.AMP,2))=SPIKEZ.neg.AMP(:,:);
            AMPpos(1:size(SPIKEZ.pos.AMP,1),1:size(SPIKEZ.pos.AMP,2))=SPIKEZ.pos.AMP(:,:);
            SPIKEZ.AMP=AMP;
            SPIKEZ.neg.AMP=AMPneg;
            SPIKEZ.pos.AMP=AMPpos;
            clear AMP AMPneg AMPpos
        elseif size(SPIKEZ.TS,1) ~= size(SPIKEZ.AMP,1)
            % TS:
            I=max([size(SPIKEZ.TS,1),size(SPIKEZ.neg.TS,1),size(SPIKEZ.pos.TS,1)]);
            N=max([size(SPIKEZ.TS,2),size(SPIKEZ.neg.TS,2),size(SPIKEZ.pos.TS,2)]);
            TS=zeros(I,N);
            TS(1:size(SPIKEZ.TS,1),1:size(SPIKEZ.TS,2))=SPIKEZ.TS(:,:);
            SPIKEZ.TS=TS;
            clear TS
            % AMP:
            I=max([size(SPIKEZ.AMP,1),size(SPIKEZ.neg.AMP,1),size(SPIKEZ.pos.AMP,1)]);
            N=max([size(SPIKEZ.AMP,2),size(SPIKEZ.neg.AMP,2),size(SPIKEZ.pos.AMP,2)]);
            AMP=zeros(I,N);
            AMP(1:size(SPIKEZ.AMP,1),1:size(SPIKEZ.AMP,2))=SPIKEZ.AMP(:,:);
            SPIKEZ.AMP=AMP;
            clear AMP
        end
        
        
        % delete rows that only contain zeros
        SPIKEZ.TS( ~any(SPIKEZ.TS,2), : ) = [];  %rows
        SPIKEZ.AMP( ~any(SPIKEZ.AMP,2), : ) = [];  %rows
        SPIKEZ.neg.TS( ~any(SPIKEZ.neg.TS,2), : ) = [];  %rows
        SPIKEZ.neg.AMP( ~any(SPIKEZ.neg.AMP,2), : ) = [];  %rows
        SPIKEZ.pos.TS( ~any(SPIKEZ.pos.TS,2), : ) = [];  %rows
        SPIKEZ.pos.AMP( ~any(SPIKEZ.pos.AMP,2), : ) = [];  %rows
        
        
        
        % use negative or positive or negative+positive Spikes or current spikes?
        SPIKEZ=setNegativeAndOrPositiveSpikesAsCurrentSpikes(SPIKEZ,flag_neg,flag_pos);
        
    end

% --- Rasterplot ------------------------------------------------
    function Rasterplot(MERGED)
        
        disp('Show Rasterplot')
        
        ha2=findobj(gcf,'Type','Axes','Tag','axes_tab2');
        ha2.NextPlot='replacechildren'; % so Tag of axes isn't cleared by plot function
        axes(ha2) % make axes on tab2 the current axes
        plot(0,0)
        
        
        %ha2=plotSpikeTrain_Color(MERGED.TS./60,MERGED.AMP,ha2,'dot_ColorBar');
        ha2=plotSpikeTrain(MERGED.TS./60,ha2,'dot');
        ha2.XLabel.String='Time in minutes';
        
        zoom on
    end

% --- Calculate Neuro Features ------------------------------------------------
    function [MERGED,FEATURES]=CalcNeuroFeatures(MERGED,time_win,FR_min)
        
        %% Call function to calcuate all selected features like spikerate ect.
        
        %         Selection={''}; % init variable "Selection"
        %         if get(findobj(gcf,'Tag','Box2_parameter_FR'),'value'); Selection(end+1)={'Spikerate'}; end
        %         if get(findobj(gcf,'Tag','Box2_parameter_AMP'),'value'); Selection(end+1)={'Amplitude'}; end
        %         if get(findobj(gcf,'Tag','Box2_parameter_ActEL'),'value'); Selection(end+1)={'ActiveElectrodes'}; end
        %         if get(findobj(gcf,'Tag','Box2_parameter_Burst-Baker'),'value'); Selection(end+1)={'BR_baker100'}; Selection(end+1)={'BD_baker100'}; Selection(end+1)={'SIB_baker100'}; Selection(end+1)={'IBI_baker100'}; end
        %         if get(findobj(gcf,'Tag','Box2_parameter_Burst-Selinger'),'value'); Selection(end+1)={'BR_selinger'}; Selection(end+1)={'BD_selinger'}; Selection(end+1)={'SIB_selinger'}; Selection(end+1)={'IBI_selinger'}; end
        %         if get(findobj(gcf,'Tag','Box2_parameter_NB-Chiappalone'),'value'); Selection(end+1)={'NBR_chiappalone'}; Selection(end+1)={'NBD_chiappalone'}; Selection(end+1)={'SINB_chiappalone'}; Selection(end+1)={'INBI_chiappalone'}; end
        %         if get(findobj(gcf,'Tag','Box2_parameter_Sync-Selinger'),'value'); Selection(end+1)={'Sync_CC_selinger'}; end
        %         if get(findobj(gcf,'Tag','Box2_parameter_Sync-MI2'),'value'); Selection(end+1)={'Sync_MI2'}; end
        %         if get(findobj(gcf,'Tag','Box2_parameter_Sync-SC'),'value'); Selection(end+1)={'Sync_Contrast'}; end
        %         if get(findobj(gcf,'Tag','Box2_parameter_Entropy1'),'value'); Selection(end+1)={'Entropy_bin100'}; end
        %         if get(findobj(gcf,'Tag','Box2_parameter_Entropy2'),'value'); Selection(end+1)={'Entropy_capurro'}; end
        
        Selection={ ...
            'Spikerate', ...
            'Number of spikes', ...
            'Amplitude', ...
            'ActiveElectrodes', ...
            'BR_baker100', ...
            'BD_baker100', ...
            'SIB_baker100', ...
            'IBI_baker100', ...
            'BR_selinger', ...
            'BD_selinger', ...
            'SIB_selinger', ...
            'IBI_selinger', ...
            'Entropy_bin100', ...
            'Entropy_capurro', ...
            'NBR_chiappalone', ...
            'NBD_chiappalone', ...
            'SINB_chiappalone', ...
            'INBI_chiappalone', ...
            'NBR_jimbo', ...
            'NBD_jimbo', ...
            'SINB_jimbo', ...
            'INBI_jimbo', ...
            'NBR_MC', ...
            'NBD_MC', ...
            'SINB_MC', ...
            'INBI_MC', ...
            'Sync_CC_selinger', ...
            'Sync_MI1', ...
            'Sync_MI2', ...
            'Sync_PS', ...
            'Sync_PS_M', ...
            'Sync_Contrast', ...
            ...'Sync_Contrast_fixed', ...
            'Sync_STTC', ...
            'Connectivity_TSPE', ...
            'Connectivity_TSPE_withSurrogateThreshold'
            };
        
        [WIN,MERGED]=CalcFeatures_function(MERGED,Selection,time_win,FR_min);
        
        %% Pack WIN to FEATURES and calculate electrode wise (ew) parameter
        FEATURES=unpackWIN2FEATURES(WIN);
        % save other PREFS:
        FEATURES(1).PREF.time_win=time_win;
        FEATURES(1).PREF.FR_min=FR_min;
        FEATURES(1).x=MERGED.x;
        FEATURES(1).XLabel='t /min';
        
        %% set NaNs to zero
        for k=1:size(FEATURES,2)
            FEATURES(k).mean(isnan(FEATURES(k).mean))=0;
            FEATURES(k).std(isnan(FEATURES(k).std))=0;
        end
        
        
        [MERGED.TS, MERGED.AMP]=deleteLowFiringRateSpiketrains(MERGED.TS,MERGED.AMP,MERGED.PREF.rec_dur,FR_min);
        MERGED=SpikeFeaturesCalculation(MERGED);
        
        
        % Update Dropdown menu:
        h=findobj(gcf,'Tag','menu3_plotfeatures');
        h.String={FEATURES(:).YLabel};
        
    end

% --- Calculate Cardio Features ------------------------------------------------
    function [MERGED,FEATURES]=CalcCardioFeatures(MERGED,time_win,FR_min)
        
        %% Call function to calcuate all selected features like spikerate ect.
        
        Selection={ ...
            'Cardio - Beat Rate', ...
            'ActiveElectrodes', ...
            'Cardio - Propagation Velocity', ...
            'Cardio - Spike-contrast', ...
            };
        
        flag_60HDMEA = get(findobj(gcf,'Tag','Box2_60HDMEA'),'value');
        [WIN,MERGED]=CalcFeatures_function(MERGED,Selection,time_win,FR_min,60,[],flag_60HDMEA); % 60 , []: these two values are just place holder
        
        %% Pack WIN to FEATURES and calculate electrode wise (ew) parameter
        FEATURES=unpackWIN2FEATURES(WIN);
        % save other PREFS:
        FEATURES(1).PREF.time_win=time_win;
        FEATURES(1).PREF.FR_min=FR_min;
        FEATURES(1).x=MERGED.x;
        FEATURES(1).XLabel='t /min';
        
        %% set NaNs to zero
        for k=1:size(FEATURES,2)
            FEATURES(k).mean(isnan(FEATURES(k).mean))=0;
            FEATURES(k).std(isnan(FEATURES(k).std))=0;
        end
        
        [MERGED.TS, MERGED.AMP]=deleteLowFiringRateSpiketrains(MERGED.TS,MERGED.AMP,MERGED.PREF.rec_dur,FR_min);
        MERGED=SpikeFeaturesCalculation(MERGED);
        
        
        % Update Dropdown menu:
        h=findobj(gcf,'Tag','menu3_plotfeatures');
        h.String={FEATURES(:).YLabel};
        
    end


% --- TAB 3 ---------------------------------------------------------------

% --- Plot Features ------------------------------------------------
    function PlotFeatures(x,average,sd,XLabel,YLabel,Legend)
        
        normalize_flag = get(findobj(gcf,'Tag','Box3_normalize'),'value');
        
        ha3 = findobj(gcf,'Type','Axes','Tag','axes_tab3');
        ha3.NextPlot='add'; % so Tag of axes isn't cleared by plot function
        axes(ha3) % make axes on tab3 the current axes
        
        % normalize
        if normalize_flag
            sd=sd./average(1);
            average=average./average(1);
        end
        
        % plot
        average(isnan(average))=0; % set all NaN values to zero
        sd(isnan(sd))=0;
        sd=squeeze(sd);
        average=squeeze(average);
        h=plot(x,average);
        %h=errorbar(x,average,sd);
        h.Marker='.';
        %h.LineStyle='--';
        h.Clipping='off'; % errorbars can be beyond axis limit
        
        % calculate axis borders:
        ha3.YLimMode='auto';
        ha3.XLimMode='auto';
        if ha3.YLim(1)<0
        else
            ha3.YLim(1)=0;
        end
        
        if sum(x)>0
            ha3.XLim(1)=0;
            ha3.XLim(2)=max(x);
        else
            ha3.XLim(1)=-1;
            ha3.XLim(2)=1;
        end
        
        % Axis label and Legend
        ha3.XLabel.String=XLabel;
        ha3.YLabel.String=YLabel;
        hl=legend(Legend);
        hl.FontSize=5;
        
        % zoom/pan on
        pan on
        
        % MARKER:
        
        % BIC native, wash, 0, 1, 5, 10, wash
        if 0
            t=[0,30,60,75,90,105,120];
            for i=1:size(t,2)
                %line([t(i) t(i)],[ha3.YLim(1) ha3.YLim(2)],'Linestyle','--','Color',[1 0 0])
            end
            text(t,ha3.YLim(2)*.5.*ones(size(t)),[{'native'},{'3xwash'},{'0 uM'},{'1 uM'},{'5 uM'},{'10 uM'},{'3xwash'}],'FontSize',6)
        end
        
        % BIC native, wash, 0, 10, wash
        if 0
            t=[0,10,40,55,70];
            for i=1:size(t,2)
                %line([t(i) t(i)],[ha3.YLim(1) ha3.YLim(2)],'Linestyle','--','Color',[1 0 0])
            end
            text(t,ha3.YLim(2)*.5.*ones(size(t)),[{'native'},{'3xwash'},{'0 uM'},{'10 uM'},{'3xwash'}],'FontSize',6)
        end
        
        % CBZ  0,2,20,40,60,100,200,1000,wash
        if 0
            t=[0,20,30,40,50,60,70,80,90];
            for i=1:size(t,2)
                %line([t(i) t(i)],[ha3.YLim(1) ha3.YLim(2)],'Linestyle','--','Color',[1 0 0])
            end
            text(t,ha3.YLim(2)*.5.*ones(size(t)),[{'0 uM'},{'2 uM'},{'20 uM'},{'40 uM'},{'60 uM'},{'100 uM'},{'200 uM'},{'1000 uM'},{'3xwash'}],'FontSize',6)
        end
        
        
        % Response curves:
        % CBZ 0, 2, 20, 40, 60, 100, 200, 1000
        if 0
            t=[0,5,10,15,20,25,30,35];
            for i=1:size(t,2)
                %line([t(i) t(i)],[ha3.YLim(1) ha3.YLim(2)],'Linestyle','--','Color',[1 0 0])
            end
            text(t,ha3.YLim(2)*.5.*ones(size(t)),[{'0 uM'},{'2 uM'},{'20 uM'},{'40 uM'},{'60 uM'},{'100 uM'},{'200 uM'},{'1000 uM'}],'FontSize',6)
        end
        
    end

% --- BoxPlot Features ----------------------------------------------
    function BoxPlotFeatures(x,y,XLabel,YLabel,Legend)
        
        normalize_flag = get(findobj(gcf,'Tag','Box3_normalize'),'value');
        
        ha3 = findobj(gcf,'Type','Axes','Tag','axes_tab3');
        ha3.NextPlot='add'; % so Tag of axes isn't cleared by plot function
        axes(ha3) % make axes on tab3 the current axes
        
        y=transform3Dto2D(y,normalize_flag);
        
        % transform all zeros to nan
        temp=y;
        temp(y==0)=nan;
        y=temp;
        boxplot(y,x)
        
        % calculate axis borders:
        ha3.YLimMode='auto';
        if ha3.YLim(1)<0
        else
            ha3.YLim(1)=0;
        end
        ha3.XLim(1)=0;
        %         XLim_new=[0 0];
        %         YLim_new=[0 0];
        %         YLim_new(2)=max(y)*1.1;
        %         XLim_new(2)=max(x)*1.1;
        %         if XLim_new(2) > ha3.XLim(2) ha3.XLim(2)=XLim_new(2); end
        %         if YLim_new(2) > ha3.YLim(2) ha3.YLim(2)=YLim_new(2); end
        %         ha3.YLim(1)=0;
        %         ha3.XLim(1)=0;
        
        ha3.XLabel.String=XLabel;
        ha3.YLabel.String=YLabel;
        %legend(Legend);
    end


% --- TAB 4 ---------------------------------------------------------------

% --- transform3Dto2D ---------------------------------------------------------
    function y= transform3Dto2D(y,normalize_flag)
        % if y has e.g. this dimension (nx60xi) transform to (n*60 x i)
        if size(size(y),2)==3
            temp=zeros(size(y,1)*size(y,2),size(y,3));
            for i=1:size(y,3)
                for n=1:size(y,2)
                    temp(1:length(nonzeros(y(:,:,i))),i)=nonzeros(y(:,:,i));
                end
            end
            y=temp;
        end
        
        if normalize_flag
            for k=1:size(y,1)
                y(k,:)=y(k,:)./y(k,1);
            end
        end
    end

% --- hill_fit ---------------------------------------------------------
    function hill_fit_call(x,y_all)
        y_all=squeeze(y_all); % erase singleton dimension -> y_all(y(c),MEA#)
        
        normalize_flag = get(findobj(gcf,'Tag','Box4_normalizeByMean'),'value');
        if normalize_flag
            for i=1:size(y_all,1)
                y_temp(i,:)=y_all(i,:)./y_all(1,:);
            end
            y_all=y_temp;
        end
        
        maxVal=max(max(y_all));
        if maxVal<=1.5 maxVal=1.5; end
        
        
        % calculate EC50 for every chip:
        %         for i=1:size(y_all,2)
        %             [coeffs_chips(:,i),sigmoid]=doseResponse(x,y_all(:,i)',0);
        %         end
        %         mean_coeffs=mean(coeffs_chips,2);
        %         std_coeffs=std(coeffs_chips,1,2);
        %         EC50_2=mean_coeffs(3);
        %         hill_2=mean_coeffs(4);
        %         EC50_std=std_coeffs(3);
        
        
        % write values to array "dose" and "response" as this format is
        % needed for function "doseResponse"
        j=0;
        for c=1:size(x,2)
            for i=1:size(y_all,2)
                j=j+1;
                dose(j)=x(c);
                response(j)=y_all(c,i);
            end
        end
        % calculate ec50 and hill-coefficient
        [coeffs,sigmoid]=doseResponse(dose,response,0); % 0: no normalization as norm. is performed by current function
        
        % plot the fitted sigmoid
        x_wo_zero=x(x~=0);
        xpoints=x_wo_zero(1):0.001:x(size(x,2));%logspace(log10(minDose),log10(maxDose),1000);
        
        y_sigmoid=sigmoid(coeffs,xpoints);
        hp=plot(xpoints,y_sigmoid,'Color',[0 0 0]);
        
        %         y_sigmoid=sigmoid(mean_coeffs,xpoints);  % also plot mean parameter
        %         plot(xpoints,y_sigmoid,'Color',[1 0 0]);
        
        hp.DisplayName='Fitting with Hill equation';
        ha4 = findobj(gcf,'Type','Axes','Tag','axes_tab4');
        hl=legend([ha4.Children(2),ha4.Children(1)]);
        hl.Location='northeastoutside';
        
        EC50=coeffs(3);
        hill=coeffs(4);
        
        text(max(x)*.2,maxVal*5/10,['IC_{50} = ' num2str(EC50, '%.0f') ' \muM']); %' \pm ' num2str(EC50_std, '%.0f') ' \muM']);
        text(max(x)*.2,maxVal*4/10,['n_{hill} = ' num2str(hill, '%.2f')]);
        
        %         text(max(x),maxVal*2/10,['IC_{50} = ' num2str(EC50_2, '%.0f') ' \pm ' num2str(EC50_std, '%.0f') ' \muM']);
        %         text(max(x),maxVal*1/10,['n_{hill} = ' num2str(hill_2, '%.2f')]);
    end

% --- Response Curve --------------------------------------------------
    function [coeffs,sigmoid]=doseResponse(dose,response,normalize_flag)
        % coeffs(1): min
        % coeffs(2): max
        % coeffs(3): ec50
        % coeffs(4): hill
        %deal with 0 dosage by using it to normalise the results.
        % normalised=0;
        % if (sum(dose(:)==0)>0)
        if normalize_flag
            response=response./response(1);
            %compute mean control response
            %controlResponse=mean(response(dose==0));
            %remove controls from dose/response curve
            %response=response(dose~=0)/controlResponse;
            %dose=dose(dose~=0);
            %normalised=1;
        end
        
        %hill equation sigmoid
        sigmoid=@(beta,x)beta(1)+(beta(2)-beta(1))./(1+(x/beta(3)).^beta(4));
        % hill: y=min+(max-min)./(1+(x1/ec).^hillc);
        % beta(1): min
        % beta(2): max
        % beta(3): ec50
        % beta(4): hill
        
        
        
        
        %calculate some rough guesses for initial parameters
        minResponse=min(response);
        maxResponse=max(response);
        midResponse=mean([minResponse maxResponse],'omitnan');
        minDose=min(dose);
        maxDose=max(dose);
        
        %fit the curve and compute the values
        response(isnan(response))=0;
        [coeffs,r,J]=nlinfit(dose,response,sigmoid,[minResponse maxResponse midResponse 1]);
        coeffs=abs(coeffs);
        
        % set sigmoid to max=1 (if normalized)
        % sigmoid=@(beta,x)minResponse+(maxResponse-minResponse)./(1+(x/beta(1)).^beta(2));
        % [coeffs,r,J]=nlinfit(dose,response,sigmoid,[midResponse 1]);
        % coeffs=abs(coeffs);
        
    end

% --- Plot Features ------------------------------------------------
    function PlotGroup(x,average,sd,XLabel,YLabel,Legend)
        
        normalize_flag = get(findobj(gcf,'Tag','Box4_normalizeByMean'),'value');
        
        ha4 = findobj(gcf,'Type','Axes','Tag','axes_tab4');
        ha4.NextPlot='add'; % so Tag of axes isn't cleared by plot function
        axes(ha4) % make axes on tab3 the current axes
        
        % normalize
        if normalize_flag
            sd=sd./average(1);
            average=average./average(1);
        end
        
        % plot
        average(isnan(average))=0; % set all NaN values to zero
        sd(isnan(sd))=0;
        %h=plot(x,average);
        h=errorbar(x,average,sd);
        h.Marker='.';
        h.LineStyle='--';
        h.Clipping='off'; % errorbars can be beyond axis limit
        
        % calculate axis borders:
        ha4.YLimMode='auto';
        ha4.XLimMode='auto';
        if ha4.YLim(1)<0
        else
            ha4.YLim(1)=0;
        end
        ha4.XLim(1)=0;
        ha4.XLim(2)=max(x);
        
        % Axis label and Legend
        ha4.XLabel.String=XLabel;
        ha4.YLabel.String=YLabel;
        hl=legend(Legend);
        hl.FontSize=5;
        hl.Location='northeastoutside';
        
        
    end

% --- ttest_call - compare variable x with variable y (using ttest2 -> two unpaired samples)
    function [p]=ttest2_call(c,x_all,y_all, normalize_flag) % x_all(y(c),1,MEA#)
        
        x_all=squeeze(x_all); % x_all(y(c),MEA#)
        y_all=squeeze(y_all); % y_all(y(c),MEA#)
        
        if normalize_flag
            for i=1:size(x_all,1)
                x_temp(i,:)=x_all(i,:)./x_all(1,:);
                y_temp(i,:)=y_all(i,:)./y_all(1,:);
            end
            x_all=x_temp;
            y_all=y_temp;
        end
        
        x_all(isnan(x_all))=0; % set all NaN-Values to zero
        y_all(isnan(y_all))=0;
        
        ha4 = findobj(gcf,'Type','Axes','Tag','axes_tab4');
        y_pos=ha4.YLim(2);
        
        for c_nr=1:size(x_all,1)
            x=x_all(c_nr,:)';
            y=y_all(c_nr,:)';
            
            x_normalDistributed=NaN;
            y_normalDistributed=NaN;
            
            if size(nonzeros(~isnan(x)),1)>=4
                x_notTestedIFnormalDistributed=0;
                if lillietest(x)==0
                    x_normalDistributed=1;
                else
                    x_normalDistributed=0;
                end % 0: normalverteilt
            else
                x_notTestedIFnormalDistributed=1;
            end
            if size(nonzeros(~isnan(y)),1)>=4
                y_notTestedIFnormalDistributed=0;
                if lillietest(y)==0
                    y_normalDistributed=1;
                else
                    y_normalDistributed=0;
                end % 0: normalverteilt
            else
                y_notTestedIFnormalDistributed=1;
            end
            
            h=0; hp=0; p=1; pp=1;
            
            % pseudo test (+)
            if x_notTestedIFnormalDistributed==1 || y_notTestedIFnormalDistributed==1 || x_normalDistributed==0 || y_normalDistributed==0
                if vartest2(x,y)==0 % vartest = 0 -> sd1 = sd2
                    [hp,pp,ci,stats] = ttest2(x,y,'vartype','equal'); % 1: Unterschied zwischen x und y
                else
                    [hp,pp,ci,stats] = ttest2(x,y,'vartype','unequal'); % 1: Unterschied zwischen x und y
                end
            end
            
            % real test (*)
            if x_normalDistributed==1 && y_normalDistributed==1
                if vartest2(x,y) == 0  % vartest = 0 -> sd1 = sd2
                    [h,p,ci,stats] = ttest2(x,y,'vartype','equal'); % 1: Unterschied zwischen x und y
                else
                    [h,p,ci,stats] = ttest2(x,y,'vartype','unequal'); % 1: Unterschied zwischen x und y
                end
            end
            
            % t-test:
            if (p <= 0.05) && (p > 0.01)
                text(c(c_nr),y_pos,'*');
            elseif (p<= 0.01)
                text(c(c_nr),y_pos,'**');
            end
            
            % pseudo test:
            if (pp <= 0.05) && (pp > 0.01)
                text(c(c_nr),y_pos,'+');
            elseif pp<= 0.01
                text(c(c_nr),y_pos,'++');
            end
            
            % show p-values for each point:
            text(c(c_nr),y_pos,['p=' num2str(p)]);
            
        end
    end

% --- ttest_call - compare variable x with variable y (using ttest -> two paired samples)
    function [p]=ttest_call(c,x_all,y_all, normalize_flag) % x_all(y(c),1,MEA#)
        
        x_all=squeeze(x_all); % x_all(y(c),MEA#)
        y_all=squeeze(y_all); % y_all(y(c),MEA#)
        
        if normalize_flag
            for i=1:size(x_all,1)
                x_temp(i,:)=x_all(i,:)./x_all(1,:);
                y_temp(i,:)=y_all(i,:)./y_all(1,:);
            end
            x_all=x_temp;
            y_all=y_temp;
        end
        
        x_all(isnan(x_all))=0; % set all NaN-Values to zero
        y_all(isnan(y_all))=0;
        
        ha4 = findobj(gcf,'Type','Axes','Tag','axes_tab4');
        y_pos=ha4.YLim(2);
        
        for c_nr=1%:size(x_all,1)
            x=x_all(:,1)';
            y=y_all(:,1)';
            
            x_normalDistributed=NaN;
            y_normalDistributed=NaN;
            
            if size(nonzeros(~isnan(x)),1)>=4
                x_notTestedIFnormalDistributed=0;
                if lillietest(x)==0
                    x_normalDistributed=1;
                else
                    x_normalDistributed=0;
                end % 0: normalverteilt
            else
                x_notTestedIFnormalDistributed=1;
            end
            if size(nonzeros(~isnan(y)),1)>=4
                y_notTestedIFnormalDistributed=0;
                if lillietest(y)==0
                    y_normalDistributed=1;
                else
                    y_normalDistributed=0;
                end % 0: normalverteilt
            else
                y_notTestedIFnormalDistributed=1;
            end
            
            h=0; hp=0; p=1; pp=1;
            
            % pseudo test (+)
            if x_notTestedIFnormalDistributed==1 || y_notTestedIFnormalDistributed==1 || x_normalDistributed==0 || y_normalDistributed==0
                % if vartest2(x,y)==0 % vartest = 0 -> sd1 = sd2
                [hp,pp,ci,stats] = ttest(x,y); % 1: Unterschied zwischen x und y
                % else
                %    [hp,pp,ci,stats] = ttest(x,y,'vartype','unequal'); % 1: Unterschied zwischen x und y
                %    p=999;
                % end
            end
            
            % real test (*)
            if x_normalDistributed==1 && y_normalDistributed==1
                %  if vartest2(x,y) == 0  % vartest = 0 -> sd1 = sd2
                [h,p,ci,stats] = ttest(x,y); % 1: Unterschied zwischen x und y
                % else
                %   [h,p,ci,stats] = ttest(x,y,'vartype','unequal'); % 1: Unterschied zwischen x und y
                %  p=999;
                %  end
            end
            
            % t-test:
            if (p <= 0.05) && (p > 0.01)
                text(c(c_nr+1),y_pos,'*');
            elseif (p<= 0.01)
                text(c(c_nr+1),y_pos,'**');
            end
            
            % pseudo test:
            if (pp <= 0.05) && (pp > 0.01)
                text(c(c_nr+1),y_pos,'+');
            elseif pp<= 0.01
                text(c(c_nr+1),y_pos,'++');
            end
            
            % show p-values for each point:
            text(c(c_nr+1),y_pos,['p=' num2str(p)]);
            text(c(c_nr+1),y_pos/2,['pp=' num2str(pp)]);
            
        end
    end
%% final end
end


% SPIKEZ (structure)
% SPIKEZ.TS:                            Timestamps of spikes
% SPIKEZ.AMP:                           Amplitude of each spike
% SPIKEZ.N:                             number of spikes per el.
% SPIKEZ.FR:                            firing rate per el.
% SPIKEZ.aeFRmean:                      mean firing rate
% SPIKEZ.aeFRstd:                       st. deviation of firing rate
% SPIKEZ.aeN_FR:                        number of firing rates =
% number of active electrodes
%
% SPIKEZ.FILTER.Name:                   band-low-highpass/stop
% SPIKEZ.FILTER.f_edge:                 edge frequency/ies
%
% SPIKEZ.PREF.fileinfo:                 manually written comment
% SPIKEZ.PREF.Time:                     Time of recording
% SPIKEZ.PREF.Date:                     Date of recording
% SPIKEZ.PREF.SaRa:                     Sample rate
% SPIKEZ.PREF.rec_dur:                  recording duration in seconds
% SPIKEZ.PREF.EL_NUMS:                  Electrode numbers
% SPIKEZ.PREF.EL_NAMES:                 Electrode names
% SPIKEZ.PREF.idleTime:                 apllied idle time
% SPIKEZ.PREF.minFR:                    minimum FR to be active el.
% SPIKEZ.PREF.CLEL:                     cleared electrodes
% SPIKEZ.PREF.Invert_M:                 inverted electrodes
% SPIKEZ.PREF.dyn_TH:                   1: threshold is dynamic, 0 or not
% existing: threshold is constant
%
% SPIKEZ.SNR.SNR:                       signal to noise ratio /el
% SPIKEZ.SNR.SNR_dB:                    signal to noise in dB /el
% SPIKEZ.SNR.Mean_SNR_dB:               mean snr value over all el
%
% SPIKEZ.pos.flag:                      0/1: de/activate pos spike detection
% SPIKEZ.pos.TS:                        positive spikes
% SPIKEZ.pos.AMP:                       positive amplitudes
% SPIKEZ.pos.N:                         number of pos. spikes
% SPIKEZ.pos.THRESHOLDS.Th:             positive thresholds
% SPIKEZ.pos.THRESHOLDS.Multiplier:     positive th.calc. parameter1
% SPIKEZ.pos.THRESHOLDS.Std_noizewindow: positive th.calc. parameter2
% SPIKEZ.pos.THRESHOLDS.Size_noizewindow: positive th.calc. parameter3
% SPIKEZ.pos.SNR.SNR:                   signal to noise ratio /el
% SPIKEZ.pos.SNR.SNR_dB:                signal to noise in dB /el
% SPIKEZ.pos.SNR.Mean_SNR_dB:           mean snr value over all el
%
% SPIKEZ.neg.flag:                      0/1: de/activate neg spike detection
% SPIKEZ.neg.TS:                        negative spikes
% SPIKEZ.neg.AMP:                       negative amplitudes
% SPIKEZ.neg.N:                         number of neg. spikes
% SPIKEZ.neg.THRESHOLDS.Th:             negative thresholds
% SPIKEZ.neg.THRESHOLDS.Multiplier:     negative th.calc. parameter1
% SPIKEZ.neg.THRESHOLDS.Std_noizewindow: neg. th.calc. parameter2
% SPIKEZ.neg.THRESHOLDS.Size_noizewindow: neg. th.calc. parameter3
% SPIKEZ.neg.SNR.SNR:                   signal to noise ratio /el
% SPIKEZ.neg.SNR.SNR_dB:                signal to noise in dB /el
% SPIKEZ.neg.SNR.Mean_SNR_dB:           mean snr value over all el