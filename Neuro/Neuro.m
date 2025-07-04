% ++++++++++++++++++++++++++++++++++
% ++++++++ Neuro +++++++++++++++++++
% ++++++++++++++++++++++++++++++++++


function Neuro()

close all;
clc
disp ('--- Neuro ---');


warning off all;

global nr_channel nr_channel_old T M_OR SaRa NR_SPIKES EL_NAMES SPIKES3D SPIKES_OR waitbaradd waitbar_counter h_wait ACTIVITY END BEG EL_NUMS PREF rec_dur rec_dur_string
global allorone threshrmsdecide ELEC_CHECK CALC COL_SDT COL_RMS SNR SNR_dB  Mean_SNR_dB EL_Auswahl ELEKTRODEN signal_draw signalCorr_draw timePr kappa_mean
global MinRise MaxRise MinFall MaxFall MinDuration MaxDuration Meanrise stdMeanRise Meanfall stdMeanFall MeanDuration stdMeanDuration ORDER BURSTTIME numberfiles file filearray
global SubMEA SubMEA_vier
global ST_EL_Auswahl ST_ELEKTRODEN spiketrainWindow INV_ELEKTRODEN EL_invert_Auswahl varT varTdata varoffset Shapesvar
global is_open CORRBIN TESTcorr CurElec S
global Shapes data ti Coeff TEST MX y;
global SPIKES3D_Norm Min Max check Elektrode SPIKES_Discrete Class cln SPIKES3D_discard Sorting Window SubmitSorting SubmitRefinement M_old SPIKES_Class NR_SPIKES_Sorted  NR_BURSTS_Sorted SPIKES_FPCA;
global Time_Amp Time_Shape backup_M backup_EL CLEL Invert_M
global isAlreadyFiltered % flag which is used for quick cardio and neuro analysis buttons
% HDMEA
global HDspikedata HDrawdata HDmode el_no bottomPanel_HD
%  data
global myPath full_path M path_Neuro RAW
global Date Time
% Connectivity
global CM CM_inh CM_exh
% GUI Color
global GUI_Color_BG GUI_Color_Buttons GUI_Color_BigButton % Vectors containing R G B

% Spikeparameter:
global SPIKES AMPLITUDES FR aeFRmean aeFRstd N_FR % FR=firing rate=spiking rate
%global THRESHOLDS THRESHOLDS_pos  % MC positive threshold
global SPIKEZ % SPIKEZ is a stucture

 

% Burstdetection:
global BURSTS % BURSTS is a structure (BURSTS.BEG -> timestamps of burst begin, BURTS.END -> end of bursts. see burstdetection.m for documentation)

% Synchronous burst events (SBE):
global SBE % SBE is a structure
global SBE_old

% Networkbursts
global NETWORKBURSTS  % NETWORKBURSTS is a structure (NETWORKBURTS.BEG -> timestamps of networkburst begin ...)
global SI_EVENTS Nr_SI_EVENTS

% Synchronization Measure
global SYNC % SYNC.CC: Cross-correlation, SYNC.MI1: Mutual information (normalization 1), SYNC.MI2: Mutual information (normalization 2), SYNC.PS: Phase Synchronization
SYNC.CC=0;
SYNC.MI1=0;
SYNC.MI2=0;
SYNC.PS=0;

% --- Initializing ---
full_path       = 0;    % File path
fileinfo        = 0;    % File info
%fileN           = 0;    % HD-file name
%M               = 0;    % Data
M_OR            = 0;    % Copy of the data
T               = 0;    % Timestamps
EL_NAMES        = 0;    % Electrode names
EL_NUMS         = 0;


% --- set GUI Color -----
GUI_Color_BG = [1 1 1]; % white
GUI_Color_Buttons = ([89 189 207]+40)/255; % blue
GUI_Color_BigButton = ([0 204 187]+50)/255; % green

set(0,'DefaultUicontrolBackgroundColor',GUI_Color_Buttons);
set(0,'DefaultFigureColor',GUI_Color_BG);

PREF            = 0;    % Preferences for analysis [1:facotr RMS for Threshold; 2:Beginning of threshold calculation; 3: Endtime to (2);
% 4: Refractory time between 2 Spikes; 5: Min. number Spikes per Burst; 6: time between 1st and 2nd Spike in a Burst; 7: time between other Spikes;
% 8: Refractory time between Bursts; 9: Elektrode for ZeroOut Calculation; 10: Threshold for ZeroOut; 11: time to set to zero after stimulation interference,
% 12: Highpassfilter, 13: Lowpassfilter, 14: ZeroOut, 15: factor for STD to discover noise, 16: Windowsize for Basenoise]

SPIKES3D        = [];   % 3D-Matrix: Zeile: Betreffender Spike; Spalte:Betreffende Elektrode;
% Blatt 1: Timestamp des Spikes; Blatt 2: Negative Amplitude des Spikes;
% Blatt 3: Positive Amplitude des Spikes; Blatt 4: Ergebnis des NEO des Spikes;
% Blatt 5: Negative Signalenergie des Spikes; % Blatt 6: Positive Signalenergie des Spikes
% Blatt 7: Spikedauer; Blatt 8: Oeffnungswinkel nach links;
% Blatt 9: Oeffnungswinkel nach rechts; Blatt 10: varAmplitude;
% Blatt 11: varSpikedauer; Blatt 12: varoeffnungswinkel nach links; Blatt 13: varoeffnungswinkel nach rechts
Viewselect      = true;
el_no           = 0;
waitbar_counter = 0;
THRESHOLDS      = 0;    % Thresholds of all electrodes
THRESHOLDS_pos  = 0;
spikedata       = false;    % 1, if Spikedaten exists
HDspikedata     = false;        % 1 , if HDMEA spikedata(.brw)
HDrawdata       = false;        % 1 , if HDMEA rawdata(.brx)
HDmode = false;
bottomPanel_HD  = [];
thresholddata   = false;    % 1, if thresholds were calculated
SPIKES          = [];    % Spike-Timestamps
AMPLITUDES      = [];
BURSTS.BEG      = [];    % Burst-Timestamps
NETWORKBURSTS.BEG   = 0;    % Networkburst-Timestamps
SI_EVENTS       = 0;    % SBE-Timestamps
NR_SPIKES       = 0;    % number of Spikes on each electrode
auto            = true;    % Automatic Threshold calculation (true) oder manuell (false)
cellselect      = 1;    % 1  or 2 if Neurons, 0 if MCC
Mean_SIB        = 0;    % Average Spikes per Burst over all Electrodes
Mean_SNR_dB     = 0;    % Average SNR in dB
MBDae           = 0;    % Average BDation over all electrodes
STDburstae      = 0;    % STD BDation over all electrodes
aeIBImean       = 0;    % Average Interburstinterval over all electrodes
aeIBIstd        = 0;    % STD Interburstinterval over all electrodes
spiketraincheck = false;    % 1, if a spiketrain was opend
rawcheck        = false;    % 1, if raw-data was opend
first_open      = false;
first_open4     = false;
drawnbefore4    = false;
drawnbeforeall  = false;
is_open         = false;
NCh             = 0;    % number of Electrodes
% Stimulation:
stimulidata     = false;    % 1, if Stimulidata is calculated
STIMULI_1       = 0;    % negativ slopes of Stimulation
STIMULI_2       = 0;    % positiv slopes of Stimulation
BEGEND          = 0;    % Timestamps of Stimuli (Beginning and End)
BEG             = 0;    % Timestamps der Stimulistarts
END             = 0;    % Timestamps der Stimuliends

% Autokorrelation
CORRBIN = 0;

% Threshold
varT            = 0;
varTdata        = 0;

% Spike Analyse, Refinement, Sorting
data = false;   % 1 if data were analyzed at first call
ti = 0;         % Berechnet die moeglichen Spike-Shape Betrachtungsintervalle
Sorting = 1;    % necessary Parameter to determine whether Cluster Functions are being called by Refinement or Sorting tool
Window = 0;     % necessary Parameter to determine whether Spike Sorting Window is open or not
submit_data = 0; % test if Spike Sorting cluster was submitted so that new Wavelet Coeffs and PCA can be derived
M_old = [];     % Variable to hold the original Electrode Signal during Sorting Process (only for the currrently sorted Electrode)
SPIKES_Class = []; % Variable to hold the Class of Sorted Spikes
SubmitSorting = 0; % necessary Parameter to determine Spikes have already been submitted to the Electrode that is currently sorted
SubmitRefinement = 0; % necessary Parameter to determine Spikes have already been submitted to the Electrode that is currently refined
NR_SPIKES_Sorted = []; % Number of the SPIKES of the different Cells after Spike Sorting
NR_BURSTS_Sorted = []; % Number of the BURSTS of the different Cells after Spike
NR_SPIKES_temp = 0; % temporary Variable to store NR_SPIKES_Sorted when Spike Numbers are refreshed through Submit function
SPIKES_FPCA =[];  % Array of PCA Features calculated from the evaluated Spike Features (First 4 PCA's of the derived Feauture Space)
preti = 0;
postti = 0;
backup_EL = {};
Invert_M = [];

% save current path of Neuro.m
fullpath = mfilename('fullpath'); % get path of this m-file (.../path/Neuro.m)
[path_Neuro,~] = fileparts(fullpath); % separate path and m-file-name

% ---------------------------------------------------------------------
% --- GUI -------------------------------------------------------------
% ---------------------------------------------------------------------

% Main window
mainWindow = figure('Position',[20 20 1224 700],'Tag','Neuro','Name','Dr.Cell - Neuro','NumberTitle','off','Toolbar','none','Resize','off','Color',GUI_Color_BG);

% Infopanel (top left)
leftPanel = uipanel('Parent',mainWindow,'Units','pixels','Position',[5 560 370 140],'BackgroundColor',GUI_Color_BG);

% space for logo
panax2 = axes('Parent', leftPanel, 'Units','pixels', 'Position', [75 80 218 50]);
[img] = imread('biomems.tif');
imshow(img,'Parent',panax2,'InitialMagnification','fit');


%Selection view - 4 or all at once (Sh.Kh)
uicontrol('Parent',leftPanel,'Units','pixels','Position',[8 70 50 20],'style','text','HorizontalAlignment','left','FontWeight','bold','BackgroundColor',GUI_Color_BG,'FontSize',10,'units','pixels','String','View','Enable','off','tag','VIEWtext');
radiogroupview = uibuttongroup('Parent',leftPanel,'Visible','on','Units','Pixels','Position',[8 10 280 60],'BackgroundColor',GUI_Color_BG,'BorderType','none','SelectionChangeFcn',@viewhandler);
uicontrol('Parent',radiogroupview,'Units','normalized','Position',[0 .6 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','radio_allinone','Enable','off','String','All electrodes for 1 sec.','FontSize',7,'BackgroundColor', GUI_Color_BG,'TooltipString','Shows 1 sec of all 60 Electrodes at the same time');
uicontrol('Parent',radiogroupview,'Units','normalized','Position',[0 .3 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','radio_fouralltime','Enable','off','String','4 electrodes for the recorded time','FontSize',7,'BackgroundColor', GUI_Color_BG,'TooltipString','Shows 4 Electrodes for the full recorded time.');
uicontrol('Parent',radiogroupview,'Units','normalized','Position',[0 0 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','HDredraw','Enable','off','String','HDMEA Mode','FontSize',7,'BackgroundColor', GUI_Color_BG,'TooltipString','Shows 1 Electrodes for the full recorded time');

% Selection for Y-scale
uicontrol('Parent',leftPanel,'units','pixels','position',[250 60 100 20],'style','text','FontWeight','bold','BackgroundColor',GUI_Color_BG,'FontSize',10,'Enable','off','Tag','CELL_scaleBoxLabel','String','y-Axis Scale');
scalehandle = uicontrol('Parent',leftPanel,'Units','pixels','Position',[250 30 100 25],'Tag','CELL_scaleBox','String',['50 uV  ';'100 uV ';'200 uV ';'500 uV ';'1000 uV'],'Enable','off','Tooltipstring','y-Skalierung','Value',2,'Style','popupmenu','callback',@redrawdecide);


% Tabpanel (top right)
tabgroup = uitabgroup('Parent',mainWindow,'Units','pixels','Position',[380 560 842 140]); drawnow;
tab1 = uitab(tabgroup,'Title','Data','BackgroundColor', GUI_Color_BG);
tab2 = uitab(tabgroup,'Title','Preprocessing','BackgroundColor', GUI_Color_BG);
tab3 = uitab(tabgroup,'Title','Threshold','BackgroundColor', GUI_Color_BG);
tab4 = uitab(tabgroup,'Title','Analysis','BackgroundColor', GUI_Color_BG);
tab5 = uitab(tabgroup,'Title','Postprocessing','BackgroundColor', GUI_Color_BG);
tab6 = uitab(tabgroup,'Title','Spike Sorting','BackgroundColor', GUI_Color_BG);
tab7 = uitab(tabgroup,'Title','Export','BackgroundColor', GUI_Color_BG);
tab8 = uitab(tabgroup,'Title','Fileinfo','BackgroundColor', GUI_Color_BG);
tab9 = uitab(tabgroup, 'Title','About','BackgroundColor', GUI_Color_BG);
tab10 = uitab(tabgroup, 'Title','Tools','BackgroundColor', GUI_Color_BG);

t1 = uipanel('Parent',tab1,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', GUI_Color_BG);
t2 = uipanel('Parent',tab2,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', GUI_Color_BG);
t3 = uipanel('Parent',tab3,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', GUI_Color_BG);
t4 = uipanel('Parent',tab4,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', GUI_Color_BG);
t5 = uipanel('Parent',tab5,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', GUI_Color_BG);
t6 = uipanel('Parent',tab6,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', GUI_Color_BG);
t7 = uipanel('Parent',tab7,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', GUI_Color_BG);
t8 = uipanel('Parent',tab8,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', GUI_Color_BG);
t9 = uipanel('Parent',tab9,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', GUI_Color_BG);
t10 = uipanel('Parent',tab10,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', GUI_Color_BG);


%% Tab 1 (Data):

% "Import File" - Button
uicontrol('Parent',t1,'Units','pixels','Position',[8 66 180 24],'Tag','CELL_openMatButton','String','Import File','FontSize',9,'fontweight','bold','TooltipString','Load a raw-file or spiketrain-file.','BackgroundColor',GUI_Color_Buttons,'Callback',@openButtonCallback);

% "Export RAW" - Button
uicontrol('Parent',t1,'Units','pixels','Position',[8 37 180 24],'Tag','CELL_exportFileButton','String','Export RAW','FontSize',9,'TooltipString','Export the currently loaded raw-file as _RAW.mat.','Callback',@exportButtonCallback);

% "Quick Neuro Analysis" - Button
uicontrol('Parent',t1,'Units','pixels','Position',[8+180+25 66 180/2+50 24],'Tag','CELL_quickNeuroAnalysisButton','String','Neuro Analysis','FontSize',9,'fontweight','bold','TooltipString','Perform filtering (tab 2), threshold calculation (tab 3) and analysis (tab 4).','Enable','off','BackgroundColor',GUI_Color_BigButton,'Callback',@quickNeuroAnalysisButtonCallback);

% "Quick Cardio Analysis" - Button
uicontrol('Parent',t1,'Units','pixels','Position',[8+180+25 37 180/2+50 24],'Tag','CELL_quickCardioAnalysisButton','String','Cardio Analysis','FontSize',9,'fontweight','bold','TooltipString','Perform complete cardio analysis.','Enable','off','BackgroundColor',GUI_Color_BigButton,'Callback',@quickCardioAnalysisButtonCallback);


% Import McRack-Datei
%uicontrol('enable','on','Parent',t1,'Units','pixels','Position',[8 37 180 24],'Tag','CELL_openMcRackButton','String','Import ASCII from McRack','FontSize',9,'TooltipString','Load a recorded McRack file(.txt)','Callback',@openMcRackButtonCallback);

% "Next File" und "Previous File" - Buttons
%uicontrol('enable','off','visible','off','Parent',t1,'Units','pixels','Position',[8 8 85 24],'Tag','CELL_previousfile','String','Previous File','FontSize',9,'TooltipString','Load previous file of selected list','enable','off','Callback',@openFileButtonCallback);
%uicontrol('enable','off','visible','off','Parent',t1,'Units','pixels','Position',[95 8 85 24],'Tag','CELL_nextfile','String','Next File','FontSize',9,'TooltipString','Load next file of selected list','enable','off','Callback',@openFileButtonCallback);

% "Convert .dat-Files" - Button
uicontrol('Parent',t1,'Units','pixels','Position',[392 37 180 24],'Tag','CELL_convertButton','String','Convert .dat to .mat','FontSize',9,'TooltipString','Convert one or more raw data files from .dat to .mat format to get better performance.','Callback',@convertDat2MatButtonCallback);

% "Split raw files" - Button
uicontrol('Parent',t1,'Units','pixels','Position',[392 66 180 24],'Tag','CELL_splitRawFileButton','String','Split Raw-File','FontSize',9,'TooltipString','Split raw files (.dat or .mat) into smaller files which length can be set and save files as .mat.','Callback',@splitRawFileButtonCallback);

% "txt2TS" - Button
uicontrol('enable','on','Parent',t1,'Units','pixels','Position',[590 37 180 24],'Tag','CELL_perElectrodeButton','String','TimeAmp.txt to TS','FontSize',9,'TooltipString','Load several TimeAmp.txt-Files and convert it to _TS.mat.','Callback',@txt2TSButtonCallback);

% "6-Well-MEA" - Button
uicontrol('Parent',t1,'Units','pixels','Position',[590 66 180 24],'Tag','CELL_SixWellButton','String','6-Well-MEA','FontSize',9,'TooltipString','Consinder only one chamber of 6-Well-MEA.','Callback',@SixWellButtonCallback);

% "Convert Axion-Files" - Button
uicontrol('Parent',t1,'Units','pixels','Position',[392 37-29 180 24],'Tag','CELL_convertAxionButton','String','Convert Axion files','FontSize',9,'TooltipString','Convert one or more Axion 24-well files (*.raw converted to *.csv) to DrCell compatible *.mat files. For each well a separate *.mat file is generated','Callback',@convertAxionWellButtonCallback);


% % "Import.brw-File" - Button
% uicontrol('Parent',t1,'Units','pixels','Position',[590 37 180 24],'Tag','?','String','Import.brw-File(HD_Raw)','FontSize',9,'TooltipString','Load a .brw raw-file (HDMEA) .','Callback',@ImportbrwFileCallback);
% % "Import.bxr-File" - Button
% uicontrol('Parent',t1,'Units','pixels','Position',[590 7 180 24],'Tag','?','String','Import.bxr-File(HD_Spike)','FontSize',9,'TooltipString','Load a .bxr spiketrain-file (HDMEA) .','Callback',@ImportbxrFileCallback);

%% Tab 2 (Preprocessing):

% Filter
uicontrol('Parent',t2,'Units','pixels','Position',[27 85 40 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Filter');
uicontrol('Parent',t2,'Units','pixels','Position',[8 89 20 15],'Style','checkbox','Tag','CELL_filterCheckbox','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','apply digital filter.', 'CallBack',@onofilter);

uicontrol('Parent',t2,'Units','pixels','Position',[8 53 120 15],'Tag','CELL_low_filter','style','slider','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','min',0,'max',5000,'sliderstep',[0.001,0.01],'Enable','off','String','low boundary','CallBack',@filter_slider);
uicontrol('Parent',t2,'Units','pixels','Position',[140 50 150 20],'Tag','CELL_low_boundary','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','Enable','off','String','low boundary');
uicontrol('Parent',t2,'Units','pixels','Position',[10 72 180 12],'Tag','CELL_filterBoxtext','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','Enable','off','String','0');
uicontrol('Parent',t2,'Units','pixels','Position',[103 72 180 12],'Tag','CELL_filterBoxtext','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','Enable','off','String','5000');
uicontrol('Parent',t2,'Units','pixels','Position',[52 70 35 15],'Tag','CELL_low_edit','style','edit','HorizontalAlignment','right','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','Enable','off','String','0','CallBack',@filter_edit);

uicontrol('Parent',t2,'Units','pixels','Position',[8 11 120 15],'Tag','CELL_high_filter','style','slider','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','min',0,'max',5000,'sliderstep',[0.0002,0.002],'Enable','off','String','high boundary','CallBack',@filter_slider);
uicontrol('Parent',t2,'Units','pixels','Position',[140 8 150 20],'Tag','CELL_high_boundary','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','Enable','off','String','high boundary');
uicontrol('Parent',t2,'Units','pixels','Position',[10 31 180 12],'Tag','CELL_filterBoxtext','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','Enable','off','String','0');
uicontrol('Parent',t2,'Units','pixels','Position',[103 31 180 12],'Tag','CELL_filterBoxtext','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','Enable','off','String','5000');
uicontrol('Parent',t2,'Units','pixels','Position',[52 28 35 15],'Tag','CELL_high_edit','style','edit','HorizontalAlignment','right','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','Enable','off','String','50','CallBack',@filter_edit);

uicontrol('Parent',t2,'Units','pixels','Position',[240 20 100 20],'Style','checkbox','Tag','CELL_bandpass','String','bandpass','FontSize',10,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','use bandpass that filters all frequencies outside of the specified range.', 'CallBack',@filter_choice1);
uicontrol('Parent',t2,'Units','pixels','Position',[240 45 100 20],'Style','checkbox','Tag','CELL_bandstop','String','bandstop','FontSize',10,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','use bandstop that filters the specified frequency range out of the signal', 'CallBack',@filter_choice2);

%Zero Out Elektrode und artifact-time
uicontrol('Parent',t2,'Units','pixels','Position',[379 85 100 20],'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','FontWeight','bold','String','Clear artefacts','Tag','headlines','enable','off');
uicontrol('Parent',t2,'Units','pixels','Position',[360 89 20 15],'Style','checkbox','Tag','CELL_ZeroOutCheckbox','FontSize',9,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','apply Zero Out-algorithm, to get rid of stimulation artefakts.', 'CallBack',@onofffkt);
uicontrol('Parent',t2,'Units','pixels','Position',[360 62 100 20],'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Threshold [uV]','TooltipString','Threshold to detect stimulation.','Tag','threshstim','enable','off');
uicontrol('Parent',t2,'Units','pixels','Position',[450 63 50 20],'style','edit','HorizontalAlignment','left','FontSize',9,'units','pixels','String',700,'Tag','th_stim','enable','off');
uicontrol('Parent',t2,'Units','Pixels','position',[360 35 90 20],'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'String','Electrode','Tag','Elekstimname','enable','off');
uicontrol('Parent',t2,'Units','Pixels','Position',[450 33 100 25],'Tag','CELL_selectelectrode','FontSize',8,'enable','on','String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Tooltipstring','Elektrodenauswahl','Style','popupmenu','enable','off');
uicontrol('Parent',t2,'Units','pixels','Position',[360 8 100 20],'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','clear until','TooltipString','clear signal from beginning to end of stimulation + this time.','Tag','text_aftertime','enable','off');
uicontrol('Parent',t2,'Units','pixels','Position',[450 10 55 20],'style','edit','HorizontalAlignment','left','FontSize',9,'units','pixels','String','0.005','Tag','aftertime','enable','off');
uicontrol('Parent',t2,'Units','pixels','Position',[436 8 10 20],'style','text','HorizontalAlignment','right','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','+','TooltipString','clear signal from beginning to end of stimulation + this time.','Tag','textplus','enable','off');
uicontrol('Parent',t2,'Units','pixels','Position',[505 8 20 20],'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','s','TooltipString','clear signal from beginning to end of stimulation + this time.','Tag','textsek','enable','off');

% "clear Els" - Button
uicontrol('Parent',t2,'Units','pixels','Position',[580 66 110 24],'Tag','CELL_ElnullenButton','String','Clear Els.','FontSize',10,'Enable','off','TooltipString','clears electrodes.','Callback',@ELnullenCallback);

% "Invert Signals" - Button
uicontrol('Parent',t2,'Units','pixels','Position',[580 37 110 24],'Tag','CELL_invertButton','String','Invert Signal','FontSize',10,'Enable','off','TooltipString','invert single electrodes.','Callback',@invertButtonCallback);

% "Restore Data" - Button
uicontrol('Parent',t2,'Units','pixels','Position',[705 37 110 24],'Tag','CELL_restoreButton','String','Restore Data','FontSize',10,'Enable','off','TooltipString','undo all filters and restore original data.','Callback',@unfilterButtonCallback);

% "Apply" - Button
uicontrol('Parent',t2,'Units','pixels','Position',[705 8 110 24],'Tag','CELL_applyButton','String','Apply...','FontSize',10,'Enable','off','TooltipString','Apply the filter.','fontweight','bold','BackgroundColor',GUI_Color_BigButton,'Callback',@Applyfilter);

% "Partially clear Signal" - Button
uicontrol('Parent',t2,'Units','pixels','Position',[705 66 110 24],'Tag','CELL_partClearButton','String','part. clear Signal','FontSize',10,'Enable','off','TooltipString','Partially clear raw signal (from t1 to t2) on all electrodes.','Callback',@partClearCallback);

% "Smoothing" - Button
uicontrol('Parent',t2,'Units','pixels','Position',[580 8 110 24],'Tag','CELL_smoothButton','String','Smooth Signal','FontSize',10,'Enable','off','TooltipString','smooth single electrodes.','Callback',@smoothButtonCallback);


%% Tab3 (Threshold)

% Basenoise settings:
% String: Headline
uicontrol('Parent',t3,'Units','pixels','Position',[8 85 220 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','Enable','off','FontWeight','bold','String','Basenoise Settings');
uicontrol('Parent',t3,'Units','pixels','Position',[8 60 112 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Basefactor Noise');
uicontrol('Parent',t3,'Units','pixels','Position',[120 62 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','5','Tag','STD_noisewindow');
uicontrol('Parent',t3,'Units','pixels','Position',[8 31 112 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Windowsize in ms');
uicontrol('Parent',t3,'Units','pixels','Position',[120 33 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','50','Tag','Size_noisewindow');
% Manual window region:
uicontrol('Parent',t3,'Units','pixels','Position',[8 5 40 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','time_start','String','-','enable','off');
uicontrol('Parent',t3,'Units','pixels','Position',[8+44 5 10 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','-','Tag','text_2','enable','off');
uicontrol('Parent',t3,'Units','pixels','Position',[8+44+20 5 40 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','time_end','String','-','enable','off');
uicontrol('Parent',t3,'Units','pixels','Position',[8+44+20+40 5 15 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','s','Tag','text_3','enable','off');
% help button
uicontrol('Parent',t3,'Units','pixels','Position',[150 90 20 20],'Tag','CELL_HelpThreshold','String','?','FontSize',10,'Enable','off','TooltipString','Explanations Threshold Calculation.','fontweight','bold','Callback',@HelpThresholdFunction);
% auto or manual
radiogroup2 = uibuttongroup('Parent',t3,'visible','on','Units','Pixels','Position',[150 10 100 40],'BackgroundColor', GUI_Color_BG,'BorderType','none','SelectionChangeFcn',@handler2);
uicontrol('Parent',radiogroup2,'Units','normalized','Position',[0 0.5 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','thresh_auto','String','Auto','Enable','off','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','find threshold in thermal noise');
uicontrol('Parent',radiogroup2,'Units','normalized','Position',[0 0 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','thresh_manu','String','Manual','Enable','off','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','find threshold in given interval');
% rsm or sigma
radiogroup3 = uibuttongroup('Parent',t3,'visible','on','Units','Pixels','Position',[150 50 100 40],'BackgroundColor', GUI_Color_BG,'BorderType','none','SelectionChangeFcn',@handler3);
uicontrol('Parent',radiogroup3,'Units','normalized','Position',[0 0.5 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','thresh_rms','String','rms','Enable','off','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','find threshold in thermal noise');
uicontrol('Parent',radiogroup3,'Units','normalized','Position',[0 0 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','thresh_sigma','String','sigma','Enable','off','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','find threshold in given interval');


% Thresholds settings:
xpos = 40;
% String: Headline
uicontrol('Parent',t3,'Units','pixels','Position',[240+xpos 85 220 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Threshold Settings');
% Edit: Factor (neg)
%uicontrol('Parent',t3,'Units','pixels','Position',[280 31 50 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Factor');
uicontrol('Parent',t3,'Units','pixels','Position',[350+xpos 20 18 20],'style','edit','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','5','Tag','CELL_sensitivityBox','TooltipString','Factor which is used to calculate the positive threshold.');
% Edit: Factor (pos)
uicontrol('Parent',t3,'Units','pixels','Position',[350+xpos 0 18 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','5','Tag','CELL_sensitivityBox_pos','TooltipString','Factor which is used to calculate the positive threshold.'); % factor for positive threshold
% Checkbox Simple Threshold
uicontrol('Parent',t3,'Units','Pixels','Position', [240+xpos 60 110 22],'Tag','Checkbox_simpleThreshold','String','Simple','Enable','off','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Use simple threshold calculation: threshold = std(Signal)*Factor');
% Checkbox Dynamic Threshold
uicontrol('Parent',t3,'Units','Pixels','Position', [240+xpos 40 110 22],'Tag','dynThCheckbox','String','Dyn. Th','Enable','off','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Calcuate a dynamic threshold in case the raw signal is not highpass filtered (negative and/or positive thresholds possible)'); % checkbox to activate dynamic threshold
% Checkbox positive threshold
uicontrol('Parent',t3,'Units','Pixels','Position', [240+xpos 0 110 22],'Tag','posThCheckbox','String','Pos. Spikes','Enable','off','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Positive thresholds','Callback',@activatePosTh); % checkbox to activate positive threshold
% Checkbox negative threshold
uicontrol('Parent',t3,'Units','Pixels','Position', [240+xpos 20 110 22],'Tag','negThCheckbox','String','Neg. Spikes','Enable','off','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Negative thresholds','Callback',@activateNegTh); % checkbox to activate negative threshold
% "Calculate" - Button
uicontrol('Parent',t3,'Units','pixels','Position',[380+xpos 5 100 24],'Tag','CELL_calculateButton','String','Calculate...','FontSize',11,'Enable','off','TooltipString','Threshold. ','fontweight','bold','BackgroundColor',GUI_Color_BigButton,'Callback',@CalculateThreshold);
% "Open TH-File" and "Save TH-File" (FS)
uicontrol('Parent',t3,'Units','pixels','Position',[380+xpos 35 80 24],'Tag','THFile_openButton','String','Open','FontSize',10,'Enable','off','TooltipString','Open Threshold from external File (_TH.mat) in current folder','Callback',@ELgetThresholdFile);
uicontrol('Parent',t3,'Units','pixels','Position',[380+xpos 60 80 24],'Tag','THFile_saveButton','String','Save','FontSize',10,'Enable','off','TooltipString','Safe Threshold in external File in current folder','Callback',@ELsaveThresholdFile);


% Set Thresholds manually
% String: Headline
uicontrol('Parent',t3,'Units','pixels','Position',[550 85 180 20],'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Manual Threshold');
% String: all after
uicontrol('Parent',t3,'Units','Pixels','Position', [550 60 110 25],'Tag','Manual_threshold','String','All after','Enable','off','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Setting all thresholds after the selected one');
% String: Electrode
uicontrol('Parent',t3,'Units','pixels','Position',[550 58 100 22],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Electrode');
% Edit: electrode select
uicontrol('Parent',t3,'Units','pixels','Position',[620+50 60 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','Elsel_Thresh');
% String: current threshold
uicontrol('Parent',t3,'Units','pixels','Position',[550 31 150 22],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Current Threshold');
% Edit: current threshold value
uicontrol('Parent',t3,'Units','pixels','Position',[620+50 33 50 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','CELL_ShowcurrentThresh');
% Button: +
uicontrol('Parent',t3,'Units','pixels','Position',[590+50 60 20 20],'Tag','CELL_safeButton','String','-','FontSize',10,'Enable','off','TooltipString','Safe Threshold. ','fontweight','bold','Callback',@Elminus);
% Button: -
uicontrol('Parent',t3,'Units','pixels','Position',[660+50 60 20 20],'Tag','CELL_safeButton','String','+','FontSize',10,'Enable','off','TooltipString','Safe Threshold. ','fontweight','bold','Callback',@Elplus);
% "Show" - Button
uicontrol('Parent',t3,'Units','pixels','Position',[760 60 60 24],'Tag','CELL_safeButton','String','Show...','FontSize',10,'Enable','off','TooltipString','Show Threshold. ','fontweight','bold','Callback',@ElgetThresholdfunction);
% "Set" - Button
uicontrol('Parent',t3,'Units','pixels','Position',[760 35 60 24],'Tag','CELL_safeButton','String','Set...','FontSize',10,'Enable','off','TooltipString','Set Threshold. ','fontweight','bold','Callback',@ELsaveThresholdfunction);
% "Save TH for all EL" - Button
uicontrol('Parent',t3,'Units','pixels','Position',[690 5.5 130 24],'Tag','CELL_calculateButton','String','Set TH for all EL','FontSize',10,'Enable','off','TooltipString','Threshold. ','fontweight','bold','Callback',@Thresholdforall);





%% Tab 4 (Analysis):

% Burst Settings
% Preferences Drop Down
uicontrol('Parent',t4,'Units','pixels','Position',[8 85 130 20],'style','text','HorizontalAlignment','left','FontWeight','bold','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','String','Burst Settings','Enable','off');
defaulthandle = uicontrol('Parent',t4,'Units','pixels','Position',[8 66 130 20],'Tag','CELL_DefaultBox','String',['[Baker]    ';'[Kapucu]   ';'[Selinger] ';'[Wagenaar4]';'[Wagenaar3]';'16Hz       ';'[Cocatre]  '],'Enable','off','Tooltipstring','Default settings for Spike and Burstdetection','Value',1,'Style','popupmenu','callback',@handler);
%Help - Info about burstdetection
uicontrol('Parent',t4,'Units','pixels','Position',[8 37 100 20],'Tag','CELL_HelpBurst','String','Help?...','FontSize',10,'Enable','off','TooltipString','Explanations for different Burstdefinitions.','fontweight','bold','Callback',@HelpBurstFunction);
%uicontrol('Parent',t4,'Units','pixels','Position',[160 85 180 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','FontWeight','bold','String','Spike & Burst Criteria');

uicontrol('Parent',t4,'Units','pixels','Position',[160 58  120 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Min. SIB','TooltipString','Minimum spikes in burst (SIB): a burst has to contain at least this number of spikes.');
uicontrol('Parent',t4,'Units','pixels','Position',[290 60  30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','3','Tag','SIB_min');
uicontrol('Parent',t4,'Units','pixels','Position',[160 36  120 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Max. IBI (ms)','TooltipString','Maximum inter burst interval (IBI): time after a burst, where no other burst can be detected.');
uicontrol('Parent',t4,'Units','pixels','Position',[290 38  30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','0','Tag','IBI_max');
uicontrol('Parent',t4,'Units','pixels','Position',[160 14  150 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Max. ISI (ms)','TooltipString','Maximum inter spike interval (ISI): if time between spikes is smaller than this value, spikes belong to a burst.');
uicontrol('Parent',t4,'Units','pixels','Position',[290 16 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','100','Tag','ISI_max');

% Spike-Settings
uicontrol('Parent',t4,'Units','pixels','Position',[450 85 130 20],'style','text','HorizontalAlignment','left','FontWeight','bold','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','String','Spike Settings','Enable','off');
% Refractory time
uicontrol('Parent',t4,'Units','pixels','Position',[450 58 120 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Refract. Time (ms)','TooltipString','Refractory time: time after a spike, where no other spike can be detected.');
uicontrol('Parent',t4,'Units','pixels','Position',[450+130 60  30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','0','Tag','t_ref');

% negative/positive spike decision and preferences
uicontrol('Parent',t4,'Units','pixels','Position',[450 22 200 20],'Style','checkbox','Tag','negSpike_Box','String','neg. Spikes','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','only analyse negative Spikes');
uicontrol('Parent',t4,'Units','pixels','Position',[450 2 200 20],'Style','checkbox','Tag','posSpike_Box','String','pos. Spikes','FontSize',9,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','only analyse positive Spikes');
% Spikedetection (SWTTEO, F. Lieb)
uicontrol('Parent',t4,'Units','pixels','Position',[450 42 200 20],'Style','checkbox','Tag','Spike2_Box','String','SWTTEO','FontSize',9,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','If checked, use a combination of the normal spikedetection and those of F. Lieb');


% "Analyse" - Button
uicontrol('Parent',t4,'Units','pixels','Position',[705 8 110 24],'Tag','CELL_analyzeButton','String','Analyze...','FontSize',11,'Enable','off','TooltipString','Automated Spike/Burst-Analysis.','fontweight','bold','BackgroundColor',GUI_Color_BigButton,'Callback',@Analysedecide);

% Spikedetection
xoff = 500; % set it outside of GUI because currently not needed
uicontrol('Parent',t4,'Units','pixels','Position',[680+xoff 87 200 20],'Style','checkbox','Tag','Spike_Box','String','Spikedetection','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','En/Disables Spikedetection');
% Burstdetection activate
uicontrol('Parent',t4,'Units','pixels','Position',[680+xoff  67 200 20],'Style','checkbox','Tag','Burst_Box','String','Burstdetection','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','En/Disables Burstdetection');
% SBE-detection activate
uicontrol('Parent',t4,'Units','pixels','Position',[680+xoff  47 200 20],'Style','checkbox','Tag','SBE_Box','String','SBEdetection','FontSize',9,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','En/Disables SBEdetection (SBE=synchronous burst events)');
% SBE-detection_old activate
uicontrol('Parent',t4,'Units','pixels','Position',[680+xoff  27 200 20],'Style','checkbox','Tag','SBE_old_Box','String','SBEdetection (old)','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','En/Disables SBEdetection (old version)');
% NETWORKBURSTS activate
uicontrol('Parent',t4,'Units','pixels','Position',[680+xoff  7 200 20],'Style','checkbox','Tag','NB_Box','String','Networkbursts','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','En/Disables Networkburstdetection');


%% Tab 5 (Postprocessing):

%"Checkboxen for Spike/Burst/Stimuli/Threshold-Marks"
uicontrol('Parent',t5,'style','text','position',[10 85 40 20],'BackgroundColor', GUI_Color_BG,'FontSize',9,'Enable','off','Tag','CELL_showMarksCheckbox','units','pixels','String','Show...');
uicontrol('Parent',t5,'Units','pixels','Position',[10 65 100 27],'Style','checkbox','Tag','CELL_showThresholdsCheckbox','String','Thresholds','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the used tresholds.','Callback',@redrawdecide);
uicontrol('Parent',t5,'Units','pixels','Position',[10 45 100 27],'Style','checkbox','Tag','CELL_showSpikesCheckbox','String','Spikes (green)','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the detected spikes.','Callback',@redrawdecide);
uicontrol('Parent',t5,'Units','pixels','Position',[10 25 100 27],'Style','checkbox','Tag','CELL_showBurstsCheckbox','String','Bursts (yellow)','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the detected bursts.','Callback',@redrawdecide);
uicontrol('Parent',t5,'Units','pixels','Position',[10 5 100 27],'Style','checkbox','Tag','CELL_showStimuliCheckbox','String','Stimuli (red)','FontSize',9,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the detected stimuli.','Callback',@redrawdecide);

% Headline: Networkanalysis
uicontrol('Parent',t5,'Units','pixels','Position',[130 85 180 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','FontWeight','bold','String','Networkanalysis');

% "Rasterplot" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[130 66 110 24],'String','Raster Plot','Tag','t4_buttons','FontSize',9,'Enable','off','TooltipString','Spike Sorting Function.','Callback',@rasterplotButtonCallback);

% "Networkbursts" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[130 37 110 24],'String','Networkbursts','Tag','CELL_Networkburst','FontSize',9,'Enable','off','TooltipString','Find networkbursts according to Chiappalone et al.','Callback',@NetworkburstsButtonCallback);

% "Spike-contrast" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[130 8 110 24],'String','Spike-contrast','Tag','CELL_test','FontSize',9,'Enable','off','TooltipString','Measure synchrony using Spike-contrast (Ciba et al. 2018).','Callback',@SpikeContrastButtonCallback);


% "Networkb. test" - Button
%uicontrol('Parent',t5,'Units','pixels','Position',[130 37 110 24],'Tag','CELL_Networkbursts','String','Networkb. test','FontSize',9,'Enable','off','TooltipString','Find network bursts','Callback',@NetworkburstsMCButtonCallback);


% "Analyse SBE Events" - Button
%uicontrol('Parent',t5,'Units','pixels','Position',[130 8 110 24],'Tag','CELL_Networkbursts','String','Analyse SBE','FontSize',9,'Enable','off','TooltipString','Analyse network bursts','Callback',@AnalyseSBE_ButtonCallback);


% "Cross-correlation " - Button
%uicontrol('Parent',t5,'Units','pixels','Position',[245 66 110 24],'String','Cross-Correlation','Tag','CELL_test3','FontSize',8,'Enable','off','TooltipString','Quantifie spike synchronicity between electrodes by means of "Cross-Correlation".','Callback',@Cross_correlation);

% "EventSync " - Button
%uicontrol('Parent',t5,'Units','pixels','Position',[245 37 110 24],'String','Event Synchronisation','Tag','CELL_test3','FontSize',8,'Enable','off','TooltipString','Quantifie spike synchronicity between electrodes by means of "Event Synchronisation".','Callback',@Event_Synchronisation);

% "Mutual Information" - Button
%uicontrol('Parent',t5,'Units','pixels','Position',[245 8 110 24],'String','Mutual Information','Tag','CELL_test1','FontSize',9,'Enable','off','TooltipString','Quantifie spike synchronicity between electrodes by means of "Mutual Information"','Callback',@Mutual_Information);


% "Measure Sync " - Button
uicontrol('Parent',t5,'Units','pixels','Position',[245 66 110 24],'String','Measure Sync','Tag','CELL_MeasureSync','FontSize',9,'Enable','off','TooltipString','Measure Synchronization like cross-correlation, mutual information, phase synchronization.','Callback',@MeasureSyncButtonCallback);

% "Connectivity Estimation " - Button
uicontrol('Parent',t5,'Units','pixels','Position',[245 37 110 24],'String','Connectivity','Tag','CELL_test','FontSize',9,'Enable','off','TooltipString','Estimate functional connectivity of the network by means of TSPE (Stefano et al. 2018).','Callback',@EstimateConnectivityButtonCallback);


% Headline: Cardio
uicontrol('Parent',t5,'Units','pixels','Position',[475 85 180 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','FontWeight','bold','String','Cardio');

% "Signalprocessing" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[475 66 110 24],'String','Signalprocessing','Tag','CELL_Signalprocessing','FontSize',9,'Enable','off','TooltipString','Opens a GUI to analyze cardio signals.','Callback',@signalprocessingButtonCallback);



% Headline: Other
uicontrol('Parent',t5,'Units','pixels','Position',[705 85 180 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','FontWeight','bold','String','Other');

%"Spiketrain" - Button
%uicontrol('Parent',t5,'Units','pixels','Position',[475 66 110 24],'Tag','CELL_frequenzanalyseButton','String','Spike Train','FontSize',9,'Enable','off','TooltipString','Spike train for individual electrodes.','Callback',@spiketrainButtonCallback);  %ANDY

% "minimal spikerate" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[705 66 110 24],'String','min. Spikerate','Tag','CELL_minFR','FontSize',9,'Enable','off','TooltipString','Clear all spiketrains which number of spikes are lower than the choosen threshold.','Callback',@minFiringRateButtonCallback);

% "Stationarity"- Button
uicontrol('Parent',t5,'Units','pixels','Position',[705 37 110 24],'String','Stationarity','Tag','CELL_Stationarity','FontSize',9,'Enable','off','TooltipString','Test all spike trains for non-stationarity according to Eggermont et al.','Callback',@Stationarity_ButtonCallback);

% "ISI-Histogram" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[705 8 110 24],'Tag','CELL_ISIhistogram','String','ISI-Histogram','FontSize',11,'Enable','off','TooltipString','Show Interspikeinterval-Histogram.','Callback',@ISIhistogramButtonCallback);


% "Autocorrelation" - Button
%uicontrol('Parent',t5,'Units','pixels','Position',[590 66 110 24],'String','Autocorrelation','Tag','CELL_Autocorrelation','FontSize',9,'Enable','off','TooltipString','Autocorrelation Function.','Callback',@correlationButtonCallback);

% "Crosscorrelation" - Button
%uicontrol('Parent',t5,'Units','pixels','Position',[590 37 110 24],'String','Crosscorrelation','Tag','CELL_Crosscorrelation','FontSize',9,'Enable','off','TooltipString','Autocorrelation Function.','Callback',@crosscorrelationButtonCallback);

% "Zero-Out Example" - Button
%uicontrol('Parent',t5,'Units','pixels','Position',[590 8 110 24],'Tag','CELL_ShowZeroOutExample','String','Example ZeroOut','FontSize',9,'Enable','off','TooltipString','Shows an Example of ZeroOut algorithm','Callback',@ZeroOutExampleButtonCallback);

% "Clear Artefacts" - Button
%uicontrol('Parent',t5,'Units','pixels','Position',[705 66 110 24],'String','Clear Artefacts','Tag','CELL_test','FontSize',9,'Enable','off','TooltipString','Clear all Spikes that appear too regularly.','Callback',@clearArtefactsCallback);




%% Tab 6 (Spike Sorting):

% "Spike Analysis" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[360 66 110 24],'String','Spike Analyse','Tag','CELL_Spike Analyse','FontSize',9,'Enable','off','TooltipString','Spike Analyse','Callback',@Spike_Analyse);

% "Detection Refinement" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[360 37 110 24],'String','Detection Refinement','Tag','CELL_Detektion Refinement','FontSize',8,'Enable','off','TooltipString','Detektion Refinement','Callback',@Detektion_Refinement);

%Apply Expectation Maximation Algorithm
uicontrol('Parent',t6,'Units','Pixels','Position',[475 70 170 20],'FontSize',9,'Tag','S_EM_GM','String','Expectation Maximation','Enable','off','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG);

%Apply EM k-means Algorithm
uicontrol('Parent',t6,'Units','Pixels','Position',[475 50 170 20],'FontSize',9,'Tag','S_EM_k-means','String','EM k-means','Enable','off','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG);

%Wavelets on/off
uicontrol('Parent',t6,'Units','Pixels','Position',[475 30 170 20],'FontSize',9,'Tag','S_Wavelet','String','Wavelet Packet Analysis','Enable','off','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG);

%FPCA Features
uicontrol('Parent',t6,'Units','Pixels','Position',[475 10 170 20],'FontSize',9,'Tag','S_FPCA','String','FPCA Features','Enable','off','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG);

%Electrode Selection
uicontrol('Parent',t6,'Style', 'text','Position',[630 40 100 21],'HorizontalAlignment','left','String','Electrode: ','Enable','off','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
uicontrol('Parent',t6,'Units','Pixels','Position',[700 12 50 51],'Tag','S_Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Enable','off','Value',1,'Style','popupmenu','callback',@recalculate);

% Shapes Window Dimension
uicontrol('Parent',t6,'Style', 'text','Position', [630 72 80 20],'HorizontalAlignment','left','String', 'Window: ','FontSize',10,'Enable','off','FontWeight','bold','BackgroundColor', GUI_Color_BG);
uicontrol('Parent',t6,'Units','Pixels','Position',[700 65 50 30],'Tag','S_pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','Enable','off','callback',@recalculate);
uicontrol('Parent',t6,'Units','Pixels','Position',[760 65 50 30],'Tag','S_posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','Enable','off','callback',@recalculate);

% Class Nr.
uicontrol('Parent',t6,'Style', 'text','Position', [630 8 100 21],'HorizontalAlignment','left','String','Cluster Nr.:','Enable','off','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
uicontrol ('Parent',t6,'Units','Pixels','Position', [710 10 40 21],'Tag','S_K_Nr','HorizontalAlignment','right','FontSize',8,'Enable','off','Value',1,'String',0,'Style','edit');

% "Analyse" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[760 8 70 24],'Tag','Spike_Sorting','String','Analyse','FontSize',11,'fontweight','bold','Enable','off','TooltipString','Starts Spike Sorting','Callback',@Spike_Sorting);

%% Tab 7 (Export):

% "Export Summary" - Preferences checkboxes
uicontrol('Parent',t7,'Units','pixels','Position',[8 66 180 24],'Tag','CELL_exportButton','String','Export Summary to .xls','FontSize',9,'Enable','off','TooltipString','Saves analysis results as .xls file (use xlswrite)','Callback',@safexlsButtonCallback);
uicontrol('Parent',t7,'Units','pixels','Position',[15 28 120 27],'Style','checkbox','Tag','CELL_exportAllCheckbox','String','with Timestamps','FontSize',9,'Enable','off','Value',1,'BackgroundColor', GUI_Color_BG,'TooltipString','Write timestamps to file?');
uicontrol('Parent',t7,'Units','pixels','Position',[15 8 120 27],'Style','checkbox','Tag','CELL_showExportCheckbox','String','open File now','FontSize',9,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Should the file be opened after exporting?');

% "Save Spikes"
uicontrol('Parent',t7,'Units','pixels','Position',[584 66 180 24],'Tag','CELL_exportTimeAmpButton','String','Save Spikes as mat','FontSize',9,'Enable','on','TooltipString','Saves SPIKEZ (timestamps, amplitudes of spikes and fileinfos) as .mat-file','Callback',@SaveSpikesCallback);

% "Export Time_Shape Matrix" (old function)
% uicontrol('Parent',t7,'Units','pixels','Position',[584 36 180 24],'Tag','CELL_exportTimeShapeButton','String','Export Time Shape','FontSize',9,'Enable','on','TooltipString','Saves txt file without cleared electrodes','Callback',@ExportTimeShapeCallback);



%% Tab 8 (Fileinfo):
%Filename
uicontrol('Parent',t8,'Units','pixels','Position',[55 75 250 20],'Tag','CELL_dataFile','Style','edit','BackgroundColor', GUI_Color_BG,'TooltipString','Data file name.','Enable','off');
uicontrol('Parent',t8,'style','text','position', [5 75 35 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Name:','Enable','off');

%Comment
uicontrol('Parent',t8,'Units','pixels','Position',[55 50 250 20],'Tag','CELL_fileInfo','Style','edit','BackgroundColor', GUI_Color_BG,'TooltipString','Data details.','Enable','off');
uicontrol('Parent',t8,'style','text','position', [5 50 40 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Details:','Enable','off');

%Date and Time
uicontrol('Parent',t8,'Units','pixels','Position',[55 25 100 20],'Tag','CELL_dataDate','Style','edit','BackgroundColor', GUI_Color_BG,'TooltipString','day of recording.','Enable','off');
uicontrol('Parent',t8,'style','text','position', [5 25 40 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Date:','Enable','off');

uicontrol('Parent',t8,'Units','pixels','Position',[205 25 100 20],'Tag','CELL_dataTime','Style','edit','BackgroundColor', GUI_Color_BG,'TooltipString','time, when the recording was started.','Enable','off');
uicontrol('Parent',t8,'style','text','position', [165 25 40 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Time:','Enable','off');

%Samplerate
uicontrol('Parent',t8,'Units','pixels','Position',[455 75 100 20],'Tag','CELL_dataSaRa','Style','edit','BackgroundColor', GUI_Color_BG,'TooltipString','Samplerate.','Enable','off');
uicontrol('Parent',t8,'style','text','position', [325 75 100 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','SampleRate [Hz]:','Enable','off');

%Number of Electrodes
uicontrol('Parent',t8,'Units','pixels','Position',[455 50 100 20],'Tag','CELL_dataNrEl','Style','edit','BackgroundColor', GUI_Color_BG,'TooltipString','Number of Electrodes.','Enable','off');
uicontrol('Parent',t8,'style','text','position', [325 50 80 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','#Electrodes:','Enable','off');

%Signal Duration
uicontrol('Parent',t8,'Units','pixels','Position',[455 25 100 20],'Tag','CELL_dataDur','Style','edit','BackgroundColor', GUI_Color_BG,'TooltipString','measuring time of the recorded data.','Enable','off');
uicontrol('Parent',t8,'style','text','position', [325 25 120 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Measuring time [s]:','Enable','off');



%% Tab 9 (About):
%uicontrol('Parent',t9,'style','text','position', [5 75 600 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','This software is property of the biomems lab of the University of Applied Sciences Aschaffenburg, Germany.','Enable','on');
uicontrol('Parent',t9,'style','text','position', [5 46 600 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Contact us: www.th-ab.de\biomems or christiane.thielemann@th-ab.de .','Enable','on');
uicontrol('Parent',t9,'style','text','position', [5 25 600 30],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Postal: University of Applied Sciences - BioMEMS, Wuerzburger Str 45, 63743 Aschaffenburg, Germany','Enable','on');

uicontrol('Parent',t9,'Units','pixels','Position',[5 75 150 20],'Tag','CELL_License','String','License Disclaimer','FontSize',10,'Enable','on','TooltipString','GNU GPL 2007','fontweight','bold','Callback',@HelpLicenseFunction);


panax1 = axes('Parent', t9, 'Units','pixels', 'Position', [630 5 201 100]);
I1 = imread('hablogo.tif');
imshow(I1,'Parent',panax1,'InitialMagnification','fit');


%% Tab 10 (Tools):
uicontrol('Parent',t10,'Units','pixels','Position',[10 66 200 24],'String','Automated Analysis','FontSize',9,'Enable','on','TooltipString','Open tool for automated  in new window.','Callback',@AutomatedAnalysis_Callback);


%% Signal windows:

% Bottom Panel
bottomPanel = uipanel('Parent',mainWindow,'Units','pixels','Position',[5 5 1214 553],'Tag','CELL_BottomPanel','BackgroundColor', GUI_Color_BG);

% Scrollbar vertical
uicontrol('Parent',bottomPanel,'style', 'slider','Tag','CELL_slider','units', 'pixels', 'position', [1189 5 20 543],'Enable','off','visible','off','callback',@redrawdecide);

% "Zoom"-Buttons
dist = 120;
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 495 45 20],'Tag','CELL_zoomGraphButton1','String','Zoom','Visible','off','TooltipString','zoom into this Graph.','Callback',@zoomButton1Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 495-dist 45 20],'Tag','CELL_zoomGraphButton2','String','Zoom','Visible','off','TooltipString','zoom into this Graph.','Callback',@zoomButton2Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 495-2*dist 45 20],'Tag','CELL_zoomGraphButton3','String','Zoom','Visible','off','TooltipString','zoom into this Graph.','Callback',@zoomButton3Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 495-3*dist 45 20],'Tag','CELL_zoomGraphButton4','String','Zoom','Visible','off','TooltipString','zoom into this Graph.','Callback',@zoomButton4Callback);

% 'Invert'-Buttons
dist = 120;
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 470 45 20],'Tag','CELL_invertButton1','String','Invert.','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton1Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 470-dist 45 20],'Tag','CELL_invertButton2','String','Invert.','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton2Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 470-2*dist 45 20],'Tag','CELL_invertButton3','String','Invert.','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton3Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 470-3*dist 45 20],'Tag','CELL_invertButton4','String','Invert.','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton4Callback);

% 'Zero'-Buttons
dist = 120;
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 445 45 20],'Tag','CELL_zeroButton1','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton1Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 445-dist 45 20],'Tag','CELL_zeroButton2','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton2Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 445-2*dist 45 20],'Tag','CELL_zeroButton3','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton3Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 445-3*dist 45 20],'Tag','CELL_zeroButton4','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton4Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 375-3*dist 60 20],'Tag','CELL_zeroButton4','String','Clear all','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButtonallCallback);

% 'Undo'-Buttons
dist = 120;
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 420 45 20],'Tag','CELL_zeroButton1','String','Undo','Visible','off','TooltipString','clear signal of this electrode.','Callback',@undoButton1Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 420-dist 45 20],'Tag','CELL_zeroButton2','String','Undo','Visible','off','TooltipString','clear signal of this electrode.','Callback',@undoButton2Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 420-2*dist 45 20],'Tag','CELL_zeroButton3','String','Undo','Visible','off','TooltipString','clear signal of this electrode.','Callback',@undoButton3Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 420-3*dist 45 20],'Tag','CELL_zeroButton4','String','Undo','Visible','off','TooltipString','clear signal of this electrode.','Callback',@undoButton4Callback);

% Bottom Panel 2
bottomPanel_zwei = uipanel('Parent',mainWindow,'Units','pixels','Position',[5 5 1214 553],'Tag','CELL_BottomPanel_zwei','BackgroundColor', GUI_Color_BG);

% Scrollbar horizontal
uicontrol('Parent', bottomPanel_zwei,'style', 'slider','Tag','MEA_slider','units', 'pixels', 'position', [5 5 1204 20],'Enable','off','value',1,'callback',@redrawdecide);

% Bottom Panel HD
%bottomPanel_HD = uipanel('Parent',mainWindow,'Units','pixels','Position',[5 553 1214 553],'Tag','CELL_BottomPanel_HD','BackgroundColor', GUI_Color_BG);

% "Zoom"-Buttons
uicontrol('Parent',bottomPanel_zwei,'Units','pixels','Position',[1105 135 45 20],'Tag','CELL_zoomGraphButton4','String','Zoom','Visible','off','TooltipString','zoom into this Graph.','Callback',@zoomButton4Callback);

% 'Invert'-Buttons
uicontrol('Parent',bottomPanel_zwei,'Units','pixels','Position',[1105 110 45 20],'Tag','CELL_invertButton4','String','Invert.','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton4Callback);

% 'Zero'-Buttons
uicontrol('Parent',bottomPanel_zwei,'Units','pixels','Position',[1105 15 60 20],'Tag','CELL_zeroButton4','String','Clear all','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButtonallCallback);

% 'Undo'-Buttons
uicontrol('Parent',bottomPanel_zwei,'Units','pixels','Position',[1105 60 45 20],'Tag','CELL_zeroButton4','String','Undo','Visible','off','TooltipString','clear signal of this electrode.','Callback',@undoButton4Callback);





% ---------------------------------------------------------------------
% --- Functions ------------------------------------------------------
% ---------------------------------------------------------------------

% --- Empty Function (CN)-----------------------------------------
    function unknwonButtonCallback(source,event) %#ok
        
        msgbox('You can write your own algorithm and use this button to call it','Dr.CELL´s hint','help');
        uiwait;
        
    end

% --- ScaleRedraw-Selection (CN,MC)-----------------------------------------
    function redrawdecide(source,event) %#ok
        set(0,'CurrentFigure',mainWindow) % changes current figure so that gcf and sliderpos works
        if HDmode
            HDredraw;
        elseif Viewselect == 1
            redraw_allinone;
        elseif Viewselect == 0
            redraw;
        end
    end

% --- View-Selection (CN)------------------------------------------------
    function viewhandler(source,event) %#ok<INUSL>
        set(0, 'currentfigure', mainWindow); % set main window to current figure so "gcf" works correctly
        t = get(event.NewValue,'Tag');
        switch(t)
            case 'radio_allinone'
                Viewselect = 1;
                
                set(findobj(gcf,'Tag','CELL_slider'),'Enable','off')
                set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...
                    'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[0.25/rec_dur 1/rec_dur]);
                set(findobj(gcf,'Parent',bottomPanel,'Visible','on'),'Visible','off');
                redraw_allinone;
            case 'radio_fouralltime'
                Viewselect = 0;
                
                set(findobj(gcf,'Tag','MEA_slider'),'Enable','off')
                if nr_channel > 4
                    set(findobj(gcf,'Tag','CELL_slider'),'Enable','on',...
                        'Min', 0, 'Max', nr_channel-4, 'Value', nr_channel-4,...
                        'SliderStep', [1/(nr_channel-4) 4/(nr_channel-4)]);
                end
                set(findobj(gcf,'Parent',bottomPanel,'Visible','off'),'Visible','on');
                redraw;
        end
    end

% --- Redraw 1 graphs-view whit HDMEA(.brw)Data(Sh.Kh)-------------------
    function HDredraw(~,~)
        
        if rec_dur > 1
            set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...
                'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[1/rec_dur 1/rec_dur])
        else
            set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...
                'Min', 0, 'Max', rec_dur,'Value', 1, 'SliderStep',[0.1 0.1])
        end
        
        % update file info if Panels were already loaded
        if ~isempty(bottomPanel_HD) % if handle exist
            if isvalid(bottomPanel_HD) % if handle is valid (it is not valid if it has been deleted before)
                uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units', 'pixels', 'position', [50 5 400 20],'Parent', bottomPanel_HD, 'Tag','Showfilepath','String', file);
            end
        end
        
        if isempty(findobj(gcf,'Tag','CELL_BottomPanel_HD')) % ensure that uicontrol is only created at first time
            bottomPanel_HD= uipanel('Parent',mainWindow,'Units','pixels','Position',[5 5 1214 553],'Tag','CELL_BottomPanel_HD','BackgroundColor', GUI_Color_BG);
            
            %         if  HDrawdata == true
            
            set(findobj(gcf,'Tag','CELL_BottomPanel_zwei'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_BottomPanel'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_BottomPanel_HD'),'Visible','on');
            %---single analysis
            
            set(0,'CurrentFigure',mainWindow) % changes current figure so that gcf and sliderpos works
            %             slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));  % Position of Scrollbar
            uicontrol('Parent',bottomPanel_HD,'style','text','units','Pixels','position', [20 5 30 20],'HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'Tag','CELL_electrodeLabel','String',' File: ','FontWeight','normal');
            uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units', 'pixels', 'position', [50 5 400 20],'Parent', bottomPanel_HD, 'Tag','Showfilepath','String', file);
            uicontrol('Parent',bottomPanel_HD,'style','text','units','Pixels','position', [20 160 140 25],'HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'Tag','CELL_electrodeLabel','String',' Electrode Nummber: ','FontWeight','bold');
            uicontrol('Parent',bottomPanel_HD,'Style','PushButton','Units','Pixels','Position',[20 50 100 30],'String','Ok','ToolTipString','Start Analysis','CallBack',@View_Signal);
            uicontrol('Parent',bottomPanel_HD,'Units','pixels','Position',[45 110 60 25],'style','edit','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','1','Tag','EL_Select');
            
            % "Zoom"-Buttons
            uicontrol('Parent',bottomPanel_HD,'Units','pixels','Position',[1105 135 45 20],'Tag','CELL_zoomGraphButton4','String','Zoom','Visible','on','TooltipString','zoom into this Graph.','Callback',@zoomButton4Callback);
            
            % 'Invert'-Buttons
            uicontrol('Parent',bottomPanel_HD,'Units','pixels','Position',[1105 110 45 20],'Tag','CELL_invertButton4','String','Invert.','Visible','on','TooltipString','invert signal of this electrode.','Callback',@invertButton4Callback);
            
            % 'Zero'-Buttons
            uicontrol('Parent',bottomPanel_HD,'Units','pixels','Position',[1105 15 60 20],'Tag','CELL_zeroButton4','String','Clear all','Visible','on','TooltipString','clear signal of this electrode.','Callback',@clearButtonallCallback);
            uicontrol('Parent',bottomPanel_HD,'Units','pixels','Position',[1105 85 45 20],'Tag','CELL_zeroButton4','String','Clear','Visible','on','TooltipString','clear signal of this electrode.','Callback',@clearButton4Callback);
            % 'Undo'-Buttons
            uicontrol('Parent',bottomPanel_HD,'Units','pixels','Position',[1105 60 45 20],'Tag','CELL_zeroButton4','String','Undo','Visible','on','TooltipString','clear signal of this electrode.','Callback',@undoButton4Callback);
            
        end
        
        View_Signal;
    end
    function View_Signal(~,~)
        set(findobj(gcf,'Tag','CELL_BottomPanel_zwei'),'Visible','off');
        set(findobj(gcf,'Tag','CELL_BottomPanel'),'Visible','off');
        set(findobj(gcf,'Tag','CELL_BottomPanel_HD'),'Visible','on');
        SubMEA_vier(4)=0;
        SubMEA_vier(4)=subplot(4,1,4,'Parent',bottomPanel_HD);
        el_no=0;
        el_no = str2double(get(findobj(bottomPanel_HD,'Tag','EL_Select'),'string'));
        
        if el_no(1)<1 || el_no(1)> nr_channel
            msgbox('Electrode Nummber is incorrect!','Error','error')
        else
            
            uicontrol('style', 'text',...
                'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',12,'units', 'pixels', 'position', [600 150 70 25],...
                'Parent', bottomPanel_HD, 'Tag', 'ShowElNames','String', EL_NAMES(el_no(1)));
            scale = get(scalehandle,'value');   % set Y-Scale
            switch scale
                case 1, scale = 50;
                case 2, scale = 100;
                case 3, scale = 200;
                case 4, scale = 500;
                case 5, scale = 1000;
            end
            SubMEA_vier(4)=subplot(4,1,4,'Parent',bottomPanel_HD);
            % RAW signal
            if HDrawdata==1
                mm=RAW.M(:,el_no(1));
                %mm=double(mm); % rather use function digital2analog_sh() to ensure same ampl. values (MC)
                if RAW.MaxVolt==-RAW.MinVolt
                    RAW.BitDepth= double(RAW.BitDepth);
                    %mm=(mm-(2^RAW.BitDepth)/2)*(RAW.MaxVolt*2/2^RAW.BitDepth);
                    mm = digital2analog_sh(mm,RAW.BitDepth, RAW.MaxVolt, RAW.SignalInversion); % rather use function to ensure same ampl. values (MC)
                    mm(mm<-4000)=0;
                    mm(mm>4000)=0;
                end
                plot(T,mm);
                %                   plot(T,RAW.M(:,el_no(1)));
            end
            %Spikes
            if spikedata==1 || HDspikedata==true
                if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value')
                    if  HDspikedata==1
                        m(:,size(T,2))=0;
                        plot(T,m);
                        clear m;
                    end
                    %     SP = SPIKEZ.TS(:,el_no);
                    SP = SPIKEZ.TSC(el_no); %for Cell Array(SPIKEZ.TSC)
                    SP = SP{1,1};   %Cell to double.  for Cell Array(SPIKEZ.TSC)
                    if sum(SP)>0
                        %while SP(i)>0 %..
                        for i=1:size(find(SP),1)
                            x(1)=SP(i);
                            x(2)=SP(i);
                            Y(1)=scale;
                            Y(2)=-scale;
                            line(x,Y,'LineStyle','-','Color','b')
                            sp(i,1)=SP(i,1);
                        end   %size(sp,1) equals number of spikes (to display in GUI)
                        y_axis = ones(length(sp),1).*scale.*.9;
                        line ('Xdata',sp,'Ydata', y_axis,...
                            'LineStyle','none','Marker','v','MarkerFaceColor','green','MarkerSize',9);
                    end
                end
            end
            % Bursts
            if  max(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value'))>=1 && size(BURSTS.BEG,1)>1
                SP = nonzeros(BURSTS.BEG(:,el_no));                            % (yellow triangle)
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*scale.*.9;
                    line ('Xdata',SP,'Ydata', y_axis,...
                        'LineStyle','none','Marker','v',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
            
            
            axis([0 T(size(T,2)) -1*scale scale]); grid on;
            xlabel('time / s','FontSize',12);
        end
        
        
        if thresholddata
            if  get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','Parent',t5),'value')
                % display negative thresholds
                hold on
                if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                    T_new=0:size(T,2)/(size(SPIKEZ.neg.THRESHOLDS.Th,1)*SaRa):T(end);
                    plot(T_new,SPIKEZ.neg.THRESHOLDS.Th(:,el_no),'LineStyle','--','Color','red');
                else
                    line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.neg.THRESHOLDS.Th(1,el_no) SPIKEZ.neg.THRESHOLDS.Th(1,el_no)],'LineStyle','--','Color','red');
                end
                hold off
                % display positive thresholds
                if size(SPIKEZ.pos.THRESHOLDS.Th,2)==size(RAW.M,2)
                    hold on
                    if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                        T_new=0:size(T,2)/(size(SPIKEZ.pos.THRESHOLDS.Th,1)*SaRa):T(end);
                        plot(T_new,SPIKEZ.pos.THRESHOLDS.Th(:,el_no),'LineStyle','--','Color','red');
                    else
                        line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.pos.THRESHOLDS.Th(1,el_no) SPIKEZ.pos.THRESHOLDS.Th(1,el_no)],'LineStyle','--','Color','red');
                    end
                    hold off
                end
            end
        end
        
        
        if stimulidata==1
            if get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','Parent',t5),'value')
                for k=1:length(BEGEND)                                       % (red lines)
                    line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                        'Color','red', 'LineWidth', 1);
                end
            end
        end
        
        
        %         first_open=true;
        %         drawnbeforeall=true;
        
        %         for n=1:8
        %             Elzeile = strcat('El X ',num2str(n));
        %             uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'FontSize', 11,'units', 'pixels', 'position', [30 525-n*57 60 25],...
        %                 'Parent', bottomPanel_zwei, 'String', Elzeile);
        %         end
        %
        %         for n=1:8
        %             Elspalte = strcat({'El '}, num2str(n),{'X'});
        %             uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'FontSize', 11,'units', 'pixels', 'position', [54+n*121 520 60 25],...
        %                 'Parent', bottomPanel_zwei, 'String', Elspalte);
        %         end
        %
        %         uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'FontSize', 7,'units', 'pixels', 'position', [180 94 40 15],...
        %             'Parent', bottomPanel_zwei, 'String', 'time / s');
        %
    end

% --- Redraw 4 graphs-view (GH)-------------------
    function redraw(~,~)
        set(findobj(gcf,'Tag','CELL_BottomPanel_zwei'),'Visible','off');
        set(findobj(gcf,'Tag','CELL_BottomPanel'),'Visible','on');
        set(findobj(gcf,'Tag','CELL_BottomPanel_HD'),'Visible','off');
        set(0,'CurrentFigure',mainWindow) % changes current figure so that gcf and sliderpos works
        slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));  % Position of Scrollbar
        %nr_channel = min([nr_channel, 100]); % MC
        graph_no = nr_channel-slider_pos-3; %shiva
        
        if first_open4 == 0 && drawnbefore4 == 1
            if nr_channel_old>=4
                delete(SubMEA_vier);
            elseif nr_channel_old==3
                delete(SubMEA_vier(1:3))
            elseif nr_channel_old==2
                delete(SubMEA_vier(1:2))
            end
            delete(findobj(gcf,'Tag','ShowElNames'));
        end
        
        
        if nr_channel >= 4
            set(findobj(gcf,'Tag','CELL_slider'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton4'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_invertButton4'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zeroButton4'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton3'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_invertButton3'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zeroButton3'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton2'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_invertButton2'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zeroButton2'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton1'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_invertButton1'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zeroButton1'),'Visible','on');
        elseif nr_channel==3
            set(findobj(gcf,'Tag','CELL_slider'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton4'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_invertButton4'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zeroButton4'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton3'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_invertButton3'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zeroButton3'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton2'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_invertButton2'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zeroButton2'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton1'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_invertButton1'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zeroButton1'),'Visible','on');
        elseif nr_channel==2
            set(findobj(gcf,'Tag','CELL_slider'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton4'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_invertButton4'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zeroButton4'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton3'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_invertButton3'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zeroButton3'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton2'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_invertButton2'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zeroButton2'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton1'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_invertButton1'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zeroButton1'),'Visible','on');
        elseif nr_channel==1
            set(findobj(gcf,'Tag','CELL_slider'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton4'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_invertButton4'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zeroButton4'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton3'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_invertButton3'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zeroButton3'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton2'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_invertButton2'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zeroButton2'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_zoomGraphButton1'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_invertButton1'),'Visible','on');
            set(findobj(gcf,'Tag','CELL_zeroButton1'),'Visible','on');
        end
        
        scale = get(scalehandle,'value');   % set Y-Scale
        switch scale
            case 1, scale = 50;
            case 2, scale = 100;
            case 3, scale = 200;
            case 4, scale = 500;
            case 5, scale = 1000;
        end
        
        if max(SubmitSorting) >= 1
            delete(findobj(0,'Tag','ShowSpikesBurstsperCell')); % refresh display
        end
        
        if nr_channel>4
            
            for n=0:3
                
                uicontrol('style', 'text',...
                    'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 12,'units', 'pixels', 'position', [50 480-n*120 50 25],...
                    'Parent', bottomPanel, 'Tag', 'ShowElNames','String', EL_NAMES(graph_no+n));
                SubMEA_vier(n+1)=subplot(4,1,n+1,'Parent',bottomPanel);
                
                plot(T,RAW.M(:,graph_no+n));
                axis([0 T(size(T,2)) -1*scale scale]); grid on;
                
                if thresholddata
                    if  get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','Parent',t5),'value')
                        hold on
                        if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                            T_new=0:size(T,2)/(size(SPIKEZ.neg.THRESHOLDS.Th,1)*SaRa):T(end);
                            plot(T_new,SPIKEZ.neg.THRESHOLDS.Th(:,graph_no+n),'LineStyle','--','Color','red');
                        else
                            line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.neg.THRESHOLDS.Th(1,graph_no+n) SPIKEZ.neg.THRESHOLDS.Th(1,graph_no+n)],'LineStyle','--','Color','red');
                        end
                        hold off
                        if size(SPIKEZ.pos.THRESHOLDS.Th,2)==size(RAW.M,2)
                            hold on
                            if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                                T_new=0:size(T,2)/(size(SPIKEZ.pos.THRESHOLDS.Th,1)*SaRa):T(end);
                                plot(T_new,SPIKEZ.pos.THRESHOLDS.Th(:,graph_no+n),'LineStyle','--','Color','red');
                            else
                                line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.pos.THRESHOLDS.Th(1,graph_no+n) SPIKEZ.pos.THRESHOLDS.Th(1,graph_no+n)],'LineStyle','--','Color','red');
                            end
                            hold off
                        end
                    end
                end
                
                if spikedata==1
                    
                    if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value')     % Spikes
                        
                        if max(SubmitSorting) > 0
                            set(findobj(gcf,'Tag','ShowSpikesBurstsperEL'),'Visible','off');
                            colormap('Lines');
                            cmap = colormap;
                            
                            if SubmitSorting(graph_no+n) >= 1
                                
                                for i = 1:max(SPIKES_Class(:,graph_no+n,2))
                                    SP = nonzeros(SPIKES_Class((SPIKES_Class(:,graph_no+n,2)==i),graph_no+n,1));
                                    y_axis = ones(length(SP),1).*scale.*.9;
                                    line ('Xdata',SP,'Ydata', y_axis,...
                                        'LineStyle','none','Marker','v',...
                                        'MarkerFaceColor',[cmap(i,1),cmap(i,2),cmap(i,3)],'MarkerSize',6);
                                    
                                    SpikeString = ['S/B: ', num2str(NR_SPIKES_Sorted(i,graph_no+n)),' / ',num2str(NR_BURSTS_Sorted(i,graph_no+n))];
                                    
                                    %Show number of spikes and bursts
                                    uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1102 (490-(n*120)-((i-1)*20)) 80 20],...
                                        'Parent',bottomPanel, 'Tag','ShowSpikesBurstsperCell','ForegroundColor',[cmap(i,1),cmap(i,2),cmap(i,3)],'String',SpikeString);
                                end
                            else
                                SP = nonzeros(SPIKES(:,graph_no+n));
                                y_axis = ones(length(SP),1).*scale.*.9;
                                line ('Xdata',SP,'Ydata', y_axis,...
                                    'LineStyle','none','Marker','v',...
                                    'MarkerFaceColor',[cmap(1,1),cmap(1,2),cmap(1,3)],'MarkerSize',6);
                                
                                SpikeString = ['S/B: ', num2str(NR_SPIKES_Sorted(1,graph_no+n)),' / ',num2str(NR_BURSTS_Sorted(1,graph_no+n))];
                                
                                %Show number of spikes and bursts
                                uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1102 (490-(n*120)) 80 20],...
                                    'Parent',bottomPanel, 'Tag','ShowSpikesBurstsperCell','ForegroundColor',[cmap(1,1),cmap(1,2),cmap(1,3)],'String',SpikeString);
                            end
                            set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','on'); % after changes set visibility "on"
                            
                        else
                            set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','off');
                            set(findobj(gcf,'Tag','ShowSpikesBurstsperEL'),'Visible','on');
                            
                            %Write #Spikes und #Bursts fuer jede El.
                            uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [50 458-n*120 39 20],...
                                'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', '#Spikes','Visible','off');
                            uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [50 428-n*120 39 20],...
                                'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', '#Bursts','Visible','off');
                            
                            %Show number of spikes
                            uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [95 458-n*120 30 20],...
                                'Parent', bottomPanel, 'Tag', 'ShowSpikesBurstsperEL','String', NR_SPIKES(graph_no+n));
                            %Show number of bursts
                            if isfield(BURSTS,'BRn') && size(BURSTS.BEG,2) == size(SPIKEZ.TS,2)
                                uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [95 428-n*120 30 20],...
                                    'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', BURSTS.BRn(graph_no+n));
                            end
                            
                            if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value')
                                SP = nonzeros(SPIKES(:,graph_no+n));                            % (green triangles)
                                if isempty(SP)==0
                                    y_axis = ones(length(SP),1).*scale.*.9;
                                    line ('Xdata',SP,'Ydata', y_axis,...
                                        'LineStyle','none','Marker','v',...
                                        'MarkerFaceColor','green','MarkerSize',9);
                                end
                            end
                        end
                        if  max(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value'))>=1 && size(BURSTS.BEG,2)==size(SPIKES,2)
                            SP = nonzeros(BURSTS.BEG(:,graph_no+n));                            % (yellow triangles)
                            if isempty(SP)==0
                                y_axis = ones(length(SP),1).*scale.*.9;
                                line ('Xdata',SP,'Ydata', y_axis,...
                                    'LineStyle','none','Marker','v',...
                                    'MarkerFaceColor','yellow','MarkerSize',9);
                            end
                        end
                    end
                end
                if stimulidata==1
                    if get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','Parent',t5),'value')
                        for k=1:length(BEGEND)                                       % (red lines)
                            line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                                'Color','red', 'LineWidth', 1);
                        end
                    end
                end
            end
            
        else %if less than 4 electrodes were recorded
            for n=1:(nr_channel)
                
                uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1105 462-(n-1)*120 39 20],...
                    'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', '#Spikes','Visible','off');
                uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1105 432-(n-1)*120 39 20],...
                    'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', '#Bursts','Visible','off');
                
                
                uicontrol('style', 'text',...
                    'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 12,'units', 'pixels', 'position', [25 450-(n-1)*120 50 25],...
                    'Parent', bottomPanel,'Tag', 'ShowElNames','String', EL_NAMES(n));
                
                SubMEA_vier(n)=subplot(4,1,n,'Parent',bottomPanel);
                plot(T,RAW.M(:,n));
                axis([0 T(size(T,2)) -1*scale scale]); grid on;
                
                hold on;
                if varTdata==1
                    plot (T,varT(:,n),...
                        'LineStyle','--','Color','red');
                end
                hold off;
                
                if thresholddata
                    if varTdata==0
                        if get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','Parent',t5),'value')
                            line ('Xdata',[0 T(length(T))],...
                                'Ydata',[THRESHOLDS(n) THRESHOLDS(n)],...
                                'LineStyle','--','Color','red');
                            if size(THRESHOLDS_pos,2)==size(RAW.M,2)
                                line ('Xdata',[0 T(length(T))],...
                                    'Ydata',[THRESHOLDS_pos(graph_no+n) THRESHOLDS_pos(graph_no+n)],...
                                    'LineStyle','--','Color','red');
                            end
                        end
                    end
                end
                
                if spikedata==1
                    
                    if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value')    % Spikes
                        
                        if max(SubmitSorting) > 0
                            set(findobj(gcf,'Tag','ShowSpikesBurstsperEL'),'Visible','off');
                            colormap('Lines');
                            cmap = colormap;
                            
                            if SubmitSorting(n) >= 1
                                
                                for i = 1:max(SPIKES_Class(:,n,2))
                                    SP = nonzeros(SPIKES_Class((SPIKES_Class(:,n,2)==i),n,1));
                                    y_axis = ones(length(SP),1).*scale.*.9;
                                    line ('Xdata',SP,'Ydata', y_axis,...
                                        'LineStyle','none','Marker','v',...
                                        'MarkerFaceColor',[cmap(i,1),cmap(i,2),cmap(i,3)],'MarkerSize',6);
                                    
                                    SpikeString = ['S/B: ', num2str(NR_SPIKES_Sorted(i,n)),' / ',num2str(NR_BURSTS_Sorted(i,n))];
                                    
                                    
                                    uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1102 (490-((n-1)*120)-((i-1)*20)) 180 20],...
                                        'Parent',bottomPanel, 'Tag','ShowSpikesBurstsperCell','ForegroundColor',[cmap(i,1),cmap(i,2),cmap(i,3)],'String',SpikeString);
                                end
                            else
                                SP = nonzeros(SPIKES(:,n));
                                y_axis = ones(length(SP),1).*scale.*.9;
                                line ('Xdata',SP,'Ydata', y_axis,...
                                    'LineStyle','none','Marker','v',...
                                    'MarkerFaceColor',[cmap(1,1),cmap(1,2),cmap(1,3)],'MarkerSize',6);
                                
                                SpikeString = ['S/B: ', num2str(NR_SPIKES_Sorted(1,n)),' / ',num2str(NR_BURSTS_Sorted(1,n))];
                                
                                
                                uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1102 (490-(n-1)*120) 80 20],...
                                    'Parent',bottomPanel, 'Tag','ShowSpikesBurstsperCell','ForegroundColor',[cmap(1,1),cmap(1,2),cmap(1,3)],'String',SpikeString);
                            end
                            set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','on');
                        else
                            SP = nonzeros(SPIKES(:,n));
                            set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','off');
                            set(findobj('Tag','ShowSpikesBurstsperEL','Parent',bottomPanel),'Visible','on');
                            
                            uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 462-((n-1)*120) 30 20],...
                                'Parent', bottomPanel, 'Tag', 'ShowSpikesBurstsperEL','String',NR_SPIKES(n));
                            
                            y_axis = ones(length(SP),1).*scale.*.9;
                            line ('Xdata',SP,'Ydata', y_axis,...
                                'LineStyle','none','Marker','v',...
                                'MarkerFaceColor','green','MarkerSize',9);
                            
                            
                            uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 432-((n-1)*120) 30 20],...
                                'Parent',bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String',BURSTS.BRn(n));
                        end
                        
                        if  max(cell2mat(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value')))>=1;
                            SP = nonzeros(BURSTS.BEG(:,n));
                            if isempty(SP)==0
                                y_axis = ones(length(SP),1).*scale.*.9;
                                line ('Xdata',SP,'Ydata', y_axis,...
                                    'LineStyle','none','Marker','v',...
                                    'MarkerFaceColor','yellow','MarkerSize',9);
                            end
                        end
                    end
                end
                if stimulidata==1
                    if get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','Parent',t5),'value')
                        for k=1:length(BEGEND)
                            line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                                'Color','red', 'LineWidth', 1);
                        end
                    end
                end
            end
            
        end
        if max(SubmitSorting) > 0
            set(findobj(gcf,'Tag','ShowSpikesBurstsperEL'),'Visible','off');
            set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','on'); % refresh Spike/Burst Nr. display
        else
            set(findobj(gcf,'Tag','ShowSpikesBurstsperEL'),'Visible','on');
            set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','off'); % refresh Spike/Burst Nr. display
        end
        
        first_open4=true;
        drawnbefore4=true;
        xlabel('time / s','FontSize',12);
        
        set(SubMEA_vier,'ButtonDownFcn',@click)
        
    end
    function click(hObj,tmp) % click on signal in mainwindow sets threshold (click mainwindow)
        h = gca;
        if h == SubMEA_vier(1)
            mea = 1;
        elseif h == SubMEA_vier(2)
            mea = 2;
        elseif h == SubMEA_vier(3)
            mea = 3;
        elseif h == SubMEA_vier(4)
            mea = 4;
        end
        slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
        Zoom_Electrode = nr_channel-slider_pos-4+mea;
        
        
        ab = get(gca,'CurrentPoint');
        disp(get(gcbf, 'SelectionType'))
        
        if ~isfield(SPIKEZ, 'PREF')
            disp('Click button "Calculate..." in order to activate manual setting of thresholds.')
            return
        end
        
        if strcmp((get(gcbf, 'SelectionType')),'normal') % left click
            if SPIKEZ.PREF.dyn_TH == 0
                SPIKEZ.neg.THRESHOLDS.Th(1,Zoom_Electrode) = ab(1,2);
            else
                SPIKEZ.neg.THRESHOLDS.Th(:,Zoom_Electrode) = ab(1,2);
            end
        else % right click
            if SPIKEZ.PREF.dyn_TH == 0
                SPIKEZ.pos.THRESHOLDS.Th(1,Zoom_Electrode) = ab(1,2);
            else
                SPIKEZ.pos.THRESHOLDS.Th(:,Zoom_Electrode) = ab(1,2);
            end
        end
        
        
        redraw();
    end

% --- Redraw in overview (CN) ------------------------
    function redraw_allinone(source,event) %#ok<INUSD>
        if nr_channel>60
            %View_Signal
        else
            set(0,'CurrentFigure',mainWindow) % changes current figure so that gcf and sliderpos works
            set(findobj(gcf,'Tag','CELL_BottomPanel'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_BottomPanel_HD'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_BottomPanel_zwei'),'Visible','on');
            MEAslider_pos = double(int8(get(findobj(gcf,'Tag','MEA_slider'),'value')));
            
            scale = get(scalehandle,'value');   % set y-scale
            switch scale
                case 1, scale = 50;
                case 2, scale = 100;
                case 3, scale = 200;
                case 4, scale = 500;
                case 5, scale = 1000;
            end
            
            if first_open == 0 && drawnbeforeall == 1
                delete(SubMEA(2:7));
                delete(SubMEA(9:56));
                delete(SubMEA(58:63));
            end
            
            showend = int32(MEAslider_pos*SaRa);
            showstart = showend - int32(SaRa) +1;
            n=2;
            ALL_CHANNELS = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
            ZUORDNUNG2= [9 17 25 33 41 49 2 10 18 26 34 42 50 58 3 11 19 27 35 43 51 59 4 12 20 28 36 44 52 60 5 13 21 29 37 45 53 61 6 14 22 30 38 46 54 62 7 15 23 31 39 47 55 63 16 24 32 40 48 56];
            
            bool_std_layout = length(ALL_CHANNELS)==length(EL_NUMS);
            if bool_std_layout
                bool_std_layout = all(ALL_CHANNELS == EL_NUMS);
            end
            
            if bool_std_layout % if standard layout
                while n <= 63                       %draw empty Subplots
                    if n==8 || n==57
                        n = n+1;
                    end
                    bottomPanel_zwei;
                    SubMEA(n) = subplot(8,8,n,'Parent',bottomPanel_zwei);
                    %set(gca,'xlim',([T(showstart) T(showend)]),'XTickLabel',[],'YTickLabel',[]);
                    set(gca,'XTickLabel',[],'YTickLabel',[]);
                    
                    if n == 49
                        set(gca,'xlim',([T(showstart) T(showend)]),'XTickLabel',T(showstart):0.5:T(showend+1),'YTickLabel',[-1*scale 0 scale], 'FontSize',6);
                    end
                    n=n+1;
                end
                
            else % if no standard layout
                rows = ceil(sqrt(nr_channel));
                for n=1:nr_channel % show not more than 64 electrodes (Sh.Kh)
                    SubMEA(n) = subplot(rows,rows,n,'Parent',bottomPanel_zwei);
                    set(gca,'XTickLabel',[],'YTickLabel',[]);
                    disp(['Electrode ' num2str(n)])
                end
            end
            
            for n=1:nr_channel
                if bool_std_layout
                    subplotposition = ZUORDNUNG2(find(ALL_CHANNELS==EL_NUMS(n)));%#ok
                    subplot(8,8,subplotposition);
                else
                    subplotposition = n; % MC
                    subplot(rows,rows,subplotposition);
                end
                
                plot(T(showstart:showend),RAW.M(showstart:showend,n))                   %draw in Subplot
                axis([T(showstart) T(showend) -1*scale scale])
                set(gca,'XTickLabel',[],'YTickLabel',[]);
                
                if (EL_NUMS(n) == 17)
                    set(gca,'xlim',([T(showstart) T(showend)]),'XTickLabel',T(showstart):0.5:T(showend+1),'YTickLabel',[-1*scale 0 scale], 'FontSize',6);
                end
                
                if thresholddata
                    if  get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','Parent',t5),'value')
                        % display negative thresholds
                        hold on
                        if SPIKEZ.PREF.dyn_TH % if threshold is dynamic
                            T_new=0:size(T,2)/(size(SPIKEZ.neg.THRESHOLDS.Th,1)*SaRa):T(end);
                            plot(T_new,SPIKEZ.neg.THRESHOLDS.Th(:,n),'LineStyle','--','Color','red');
                        elseif SPIKEZ.neg.flag % if negative threshold
                            line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.neg.THRESHOLDS.Th(1,n) SPIKEZ.neg.THRESHOLDS.Th(1,n)],'LineStyle','--','Color','red');
                        end
                        hold off
                        % display positive thresholds
                        if SPIKEZ.pos.flag
                            hold on
                            if SPIKEZ.PREF.dyn_TH % if threshold is dynamic
                                T_new=0:size(T,2)/(size(SPIKEZ.pos.THRESHOLDS.Th,1)*SaRa):T(end);
                                plot(T_new,SPIKEZ.pos.THRESHOLDS.Th(:,n),'LineStyle','--','Color','red');
                            else
                                line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.pos.THRESHOLDS.Th(1,n) SPIKEZ.pos.THRESHOLDS.Th(1,n)],'LineStyle','--','Color','red');
                            end
                            hold off
                        end
                    end
                end
                
                
                
                if spikedata==1
                    if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value')
                        SP = nonzeros(SPIKES(:,n));                            % (green triangles)
                        if isempty(SP)==0
                            y_axis = ones(length(SP),1).*scale.*.9;
                            line ('Xdata',SP,'Ydata', y_axis,...
                                'LineStyle','none','Marker','v','MarkerFaceColor','green','MarkerSize',9);
                        end
                    end
                    if  max(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value'))>=1 && size(BURSTS.BEG,1)>1
                        SP = nonzeros(BURSTS.BEG(:,n));                            % (yellow triangle)
                        if isempty(SP)==0
                            y_axis = ones(length(SP),1).*scale.*.9;
                            line ('Xdata',SP,'Ydata', y_axis,...
                                'LineStyle','none','Marker','v',...
                                'MarkerFaceColor','yellow','MarkerSize',9);
                        end
                    end
                end
                
                if stimulidata==1
                    if get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','Parent',t5),'value')
                        for k=1:length(BEGEND)                                       % (red lines)
                            line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                                'Color','red', 'LineWidth', 1);
                        end
                    end
                end
            end
            
            first_open=true;
            drawnbeforeall=true;
            
            for n=1:8
                Elzeile = strcat('El X ',num2str(n));
                uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'FontSize', 11,'units', 'pixels', 'position', [30 525-n*57 60 25],...
                    'Parent', bottomPanel_zwei, 'String', Elzeile);
            end
            
            for n=1:8
                Elspalte = strcat({'El '}, num2str(n),{'X'});
                uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'FontSize', 11,'units', 'pixels', 'position', [54+n*121 520 60 25],...
                    'Parent', bottomPanel_zwei, 'String', Elspalte);
            end
            
            uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'FontSize', 7,'units', 'pixels', 'position', [180 94 40 15],...
                'Parent', bottomPanel_zwei, 'String', 'time / s');
        end
    end

% --- functions of zoom-buttoms (MG)-------------------------------

    function zoomButton1Callback(source,event) %#ok<INUSD>
        if rawcheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Zoom_Electrode = nr_channel-slider_pos-3;
                
                if SubmitSorting(Zoom_Electrode) >= 1
                    M_Zoom(1:size(RAW.M,1),1)=zeros;
                    colormap('Lines');
                    cmap = colormap;
                    Cell = ['Cell ' num2str(Zoom_Electrode)];
                    figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                    Graph_offset = 0.035;
                    Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                    for m=1:SubmitSorting(Zoom_Electrode)
                        M_Zoom(1:size(RAW.M,1),1) = zeros;
                        SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                        for i=1:size(SPI1,1)
                            if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(RAW.M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0)
                                M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = RAW.M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode);
                            end
                        end
                        subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                        hold on;
                        plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                        hold off;
                    end
                else
                    figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                    plot(T,RAW.M(:,Zoom_Electrode)); grid on;
                    
                    if thresholddata
                        hold on
                        if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                            T_new=0:size(T,2)/(size(SPIKEZ.neg.THRESHOLDS.Th,1)*SaRa):T(end);
                            plot(T_new,SPIKEZ.neg.THRESHOLDS.Th(:,Zoom_Electrode),'LineStyle','--','Color','red');
                        else
                            line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.neg.THRESHOLDS.Th(1,Zoom_Electrode) SPIKEZ.neg.THRESHOLDS.Th(1,Zoom_Electrode)],'LineStyle','--','Color','red');
                        end
                        hold off
                        if size(SPIKEZ.pos.THRESHOLDS.Th,2)==size(RAW.M,2)
                            hold on
                            if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                                T_new=0:size(T,2)/(size(SPIKEZ.pos.THRESHOLDS.Th,1)*SaRa):T(end);
                                plot(T_new,SPIKEZ.pos.THRESHOLDS.Th(:,Zoom_Electrode),'LineStyle','--','Color','black');
                            else
                                line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.pos.THRESHOLDS.Th(1,Zoom_Electrode) SPIKEZ.pos.THRESHOLDS.Th(1,Zoom_Electrode)],'LineStyle','--','Color','black');
                            end
                            hold off
                        end
                    end
                end
            else
                Zoom_Electrode = 1;
                
                if SubmitSorting(Zoom_Electrode) >= 1
                    M_Zoom(1:size(RAW.M,1),1)=zeros;
                    colormap('Lines');
                    cmap = colormap;
                    Cell = ['Cell ' num2str(Zoom_Electrode)];
                    figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                    Graph_offset = 0.035;
                    Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                    for m=1:SubmitSorting(Zoom_Electrode)
                        M_Zoom(1:size(RAW.M,1),1) = zeros;
                        SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                        for i=1:size(SPI1,1)
                            if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(RAW.M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0)
                                M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = RAW.M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode);
                            end
                        end
                        subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                        hold on;
                        plot(T,RAW.M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                        hold off;
                    end
                else
                    figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                    plot(T,RAW.M(:,Zoom_Electrode)); grid on;
                end
            end
            xlabel('Time / s'); ylabel('Voltage / uV');
            
        elseif spiketraincheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                graph_no = size(SPIKES,2)-slider_pos-3;
                plot(T,RAW.M); grid on;
                SP = nonzeros(SPIKES(:,graph_no));
                if isempty(SP)==0
                    for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);
                    end
                end
                xlabel('Time / s'); ylabel('Voltage / uV');
            else
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                plot(T,RAW.M); grid on;
                SP = nonzeros(SPIKES(:,1));
                if isempty(SP)==0
                    for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);
                    end
                end
                xlabel('Time / s'); ylabel('Voltage / uV');
            end
        end
        mea = Zoom_Electrode;
        iu = 1;
        set(gca,'ButtonDownFcn',{@clicks,mea,iu})
        
        % insert marks (MC)
        if  get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t5),'value')==1
            if ~isempty(SPIKES)
                SP = nonzeros(SPIKES(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Green',...
                        'LineStyle','none','Marker','v',...
                        'MarkerFaceColor','green','MarkerSize',9);
                end
            end
        end
        if  get(findobj('Tag','CELL_showBurstsCheckbox','Parent',t5),'value')==1
            if ~isempty(BURSTS.BEG)    % display burstbegin
                SP = nonzeros(BURSTS.BEG(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','>',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
            if ~isempty(BURSTS.END)   % display burstend
                SP = nonzeros(BURSTS.END(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','<',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
        end
        
    end
    function zoomButton2Callback(source,event) %#ok<INUSD>
        if rawcheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Zoom_Electrode = nr_channel-slider_pos-2;
                
                if SubmitSorting(Zoom_Electrode) >= 1
                    M_Zoom(1:size(RAW.M,1),1)=zeros;
                    colormap('Lines');
                    cmap = colormap;
                    Cell = ['Cell ' num2str(Zoom_Electrode)];
                    figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                    Graph_offset = 0.035;
                    Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                    for m=1:SubmitSorting(Zoom_Electrode)
                        M_Zoom(1:size(RAW.M,1),1) = zeros;
                        SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                        for i=1:size(SPI1,1)
                            if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(RAW.M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0)
                                M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = RAW.M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode);
                            end
                        end
                        subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                        hold on;
                        plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                        hold off;
                    end
                else
                    figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                    plot(T,RAW.M(:,Zoom_Electrode)); grid on;
                    if thresholddata
                        hold on
                        if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                            T_new=0:size(T,2)/(size(SPIKEZ.neg.THRESHOLDS.Th,1)*SaRa):T(end);
                            plot(T_new,SPIKEZ.neg.THRESHOLDS.Th(:,Zoom_Electrode),'LineStyle','--','Color','red');
                        else
                            line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.neg.THRESHOLDS.Th(1,Zoom_Electrode) SPIKEZ.neg.THRESHOLDS.Th(1,Zoom_Electrode)],'LineStyle','--','Color','red');
                        end
                        hold off
                        if size(SPIKEZ.pos.THRESHOLDS.Th,2)==size(RAW.M,2)
                            hold on
                            if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                                T_new=0:size(T,2)/(size(SPIKEZ.pos.THRESHOLDS.Th,1)*SaRa):T(end);
                                plot(T_new,SPIKEZ.pos.THRESHOLDS.Th(:,Zoom_Electrode),'LineStyle','--','Color','black');
                            else
                                line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.pos.THRESHOLDS.Th(1,Zoom_Electrode) SPIKEZ.pos.THRESHOLDS.Th(1,Zoom_Electrode)],'LineStyle','--','Color','black');
                            end
                            hold off
                        end
                    end
                end
            else
                Zoom_Electrode = 2;
                
                if SubmitSorting(Zoom_Electrode) >= 1
                    M_Zoom(1:size(RAW.M,1),1)=zeros;
                    colormap('Lines');
                    cmap = colormap;
                    Cell = ['Cell ' num2str(Zoom_Electrode)];
                    figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                    Graph_offset = 0.035;
                    Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                    for m=1:SubmitSorting(Zoom_Electrode)
                        M_Zoom(1:size(RAW.M,1),1) = zeros;
                        SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                        for i=1:size(SPI1,1)
                            if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(RAW.M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0)
                                M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = RAW.M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode);
                            end
                        end
                        subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                        hold on;
                        plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                        hold off;
                    end
                else
                    figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                    plot(T,RAW.M(:,Zoom_Electrode)); grid on;
                end
            end
            xlabel('Time / s'); ylabel('Voltage / uV');
            
        elseif spiketraincheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                graph_no = size(SPIKES,2)-slider_pos-2;
                plot(T,RAW.M); grid on;
                SP = nonzeros(SPIKES(:,graph_no));
                if isempty(SP)==0
                    for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);
                    end
                end
                xlabel('Time / s'); ylabel('Voltage / uV');
            else
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                plot(T,RAW.M); grid on;
                SP = nonzeros(SPIKES(:,2));
                if isempty(SP)==0
                    for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);
                    end
                end
                xlabel('Time / s'); ylabel('Voltage / uV');
            end
        end
        mea = Zoom_Electrode;
        iu = 2;
        set(gca,'ButtonDownFcn',{@clicks,mea,iu})
        
        % insert marks (MC)
        if  get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t5),'value')==1
            if ~isempty(SPIKES)   % display spikes
                SP = nonzeros(SPIKES(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Green',...
                        'LineStyle','none','Marker','v',...
                        'MarkerFaceColor','green','MarkerSize',9);
                end
            end
        end
        if  get(findobj('Tag','CELL_showBurstsCheckbox','Parent',t5),'value')==1
            if ~isempty(BURSTS.BEG)   % display burstbegin
                SP = nonzeros(BURSTS.BEG(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','>',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
            if ~isempty(BURSTS.END)  % display burstend
                SP = nonzeros(BURSTS.END(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','<',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
        end
        
    end
    function zoomButton3Callback(source,event) %#ok<INUSD>
        if rawcheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Zoom_Electrode = nr_channel-slider_pos-1;
                
                if SubmitSorting(Zoom_Electrode) >= 1
                    M_Zoom(1:size(RAW.M,1),1)=zeros;
                    colormap('Lines');
                    cmap = colormap;
                    Cell = ['Cell ' num2str(Zoom_Electrode)];
                    figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                    Graph_offset = 0.035;
                    Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                    for m=1:SubmitSorting(Zoom_Electrode)
                        M_Zoom(1:size(RAW.M,1),1) = zeros;
                        SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                        for i=1:size(SPI1,1)
                            if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(RAW.M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0)
                                M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = RAW.M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode);
                            end
                        end
                        subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                        hold on;
                        plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                        hold off;
                    end
                else
                    figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                    plot(T,RAW.M(:,Zoom_Electrode)); grid on;
                    
                    if thresholddata
                        hold on
                        if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                            T_new=0:size(T,2)/(size(SPIKEZ.neg.THRESHOLDS.Th,1)*SaRa):T(end);
                            plot(T_new,SPIKEZ.neg.THRESHOLDS.Th(:,Zoom_Electrode),'LineStyle','--','Color','red');
                        else
                            line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.neg.THRESHOLDS.Th(1,Zoom_Electrode) SPIKEZ.neg.THRESHOLDS.Th(1,Zoom_Electrode)],'LineStyle','--','Color','red');
                        end
                        hold off
                        if size(SPIKEZ.pos.THRESHOLDS.Th,2)==size(RAW.M,2)
                            hold on
                            if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                                T_new=0:size(T,2)/(size(SPIKEZ.pos.THRESHOLDS.Th,1)*SaRa):T(end);
                                plot(T_new,SPIKEZ.pos.THRESHOLDS.Th(:,Zoom_Electrode),'LineStyle','--','Color','black');
                            else
                                line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.pos.THRESHOLDS.Th(1,Zoom_Electrode) SPIKEZ.pos.THRESHOLDS.Th(1,Zoom_Electrode)],'LineStyle','--','Color','black');
                            end
                            hold off
                        end
                    end
                end
            else
                Zoom_Electrode = 3;
                
                if SubmitSorting(Zoom_Electrode) >= 1
                    M_Zoom(1:size(RAW.M,1),1)=zeros;
                    colormap('Lines');
                    cmap = colormap;
                    Cell = ['Cell ' num2str(Zoom_Electrode)];
                    figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                    Graph_offset = 0.035;
                    Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                    for m=1:SubmitSorting(Zoom_Electrode)
                        M_Zoom(1:size(RAW.M,1),1) = zeros;
                        SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                        for i=1:size(SPI1,1)
                            if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(RAW.M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0)
                                M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = RAW.M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode);
                            end
                        end
                        subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                        hold on;
                        plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                        hold off;
                    end
                else
                    figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                    plot(T,RAW.M(:,Zoom_Electrode)); grid on;
                end
            end
            xlabel('Time / s'); ylabel('Voltage / uV');
            
        elseif spiketraincheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                graph_no = size(SPIKES,2)-slider_pos-1;
                plot(T,RAW.M); grid on;
                SP = nonzeros(SPIKES(:,graph_no));
                if isempty(SP)==0
                    for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);
                    end
                end
                xlabel('Time / s'); ylabel('Voltage / uV');
            else
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                plot(T,RAW.M); grid on;
                SP = nonzeros(SPIKES(:,3));
                if isempty(SP)==0
                    for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);
                    end
                end
                xlabel('Time / s'); ylabel('Voltage / uV');
            end
        end
        mea = Zoom_Electrode;
        iu = 3;
        set(gca,'ButtonDownFcn',{@clicks,mea,iu})
        
        % insert marks (MC)
        if  get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t5),'value')==1
            if ~isempty(SPIKES)   % display spikes
                SP = nonzeros(SPIKES(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Green',...
                        'LineStyle','none','Marker','v',...
                        'MarkerFaceColor','green','MarkerSize',9);
                end
            end
        end
        if  get(findobj('Tag','CELL_showBurstsCheckbox','Parent',t5),'value')==1
            if ~isempty(BURSTS.BEG)    % display burstbegin
                SP = nonzeros(BURSTS.BEG(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','>',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
            if ~isempty(BURSTS.END)   % display burstend
                SP = nonzeros(BURSTS.END(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','<',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
        end
        
    end
    function zoomButton4Callback(source,event) %#ok<INUSD>
        
        if rawcheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Zoom_Electrode = nr_channel-slider_pos;
                if HDrawdata == true || HDspikedata==true
                    Zoom_Electrode = el_no;
                end
                if SubmitSorting(Zoom_Electrode) >= 1
                    M_Zoom(1:size(RAW.M,1),1)=zeros;
                    colormap('Lines');
                    cmap = colormap;
                    Cell = ['Cell ' num2str(Zoom_Electrode)];
                    figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                    Graph_offset = 0.035;
                    Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                    for m=1:SubmitSorting(Zoom_Electrode)
                        M_Zoom(1:size(RAW.M,1),1) = zeros;
                        SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                        for i=1:size(SPI1,1)
                            if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(RAW.M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0)
                                M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = RAW.M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode);
                            end
                        end
                        subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                        hold on;
                        plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                        hold off;
                    end
                else
                    figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                    if HDspikedata==true
                        SP = SPIKEZ.TSC(el_no);
                        SP = SP{1,1};
                        if isempty(SP)==0
                            y_axis = 0.7;
                            for i=1:size(SP,1)
                                x(1)=SP(i);
                                x(2)=SP(i);
                                Y(1)=1;
                                Y(2)=-1;
                                line(x,Y,'LineStyle','-','Color','blue','LineWidth',1)
                            end
                            %                             y_axis = ones(length(SP),1).*scale.*.9;
                            line ('Xdata',SP,'Ydata', y_axis,...
                                'LineStyle','none','Marker','v','MarkerFaceColor','green','MarkerSize',9);
                            %                             line ('Xdata',SP,'Ydata', y_axis,...
                            %                                 'LineStyle','none','Marker','v','MarkerFaceColor','green','MarkerSize',9);
                        end
                    else
                        if HDrawdata==true
                            m = digital2analog_sh(RAW.M(:,Zoom_Electrode),RAW);
                            plot(T,m); grid on;
                        else
                            plot(T,RAW.M(:,Zoom_Electrode)); grid on;
                        end
                    end
                    if thresholddata
                        hold on
                        if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                            T_new=0:size(T,2)/(size(SPIKEZ.neg.THRESHOLDS.Th,1)*SaRa):T(end);
                            plot(T_new,SPIKEZ.neg.THRESHOLDS.Th(:,Zoom_Electrode),'LineStyle','--','Color','red');
                        else
                            line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.neg.THRESHOLDS.Th(1,Zoom_Electrode) SPIKEZ.neg.THRESHOLDS.Th(1,Zoom_Electrode)],'LineStyle','--','Color','red');
                        end
                        hold off
                        if size(SPIKEZ.pos.THRESHOLDS.Th,2)==size(RAW.M,2)
                            hold on
                            if SPIKEZ.PREF.dyn_TH==1 % if threshold is dynamic
                                T_new=0:size(T,2)/(size(SPIKEZ.pos.THRESHOLDS.Th,1)*SaRa):T(end);
                                plot(T_new,SPIKEZ.pos.THRESHOLDS.Th(:,Zoom_Electrode),'LineStyle','--','Color','black');
                            else
                                line ('Xdata',[0 T(1,end)],'Ydata',[SPIKEZ.pos.THRESHOLDS.Th(1,Zoom_Electrode) SPIKEZ.pos.THRESHOLDS.Th(1,Zoom_Electrode)],'LineStyle','--','Color','black');
                            end
                            hold off
                        end
                    end
                end
            else
                Zoom_Electrode = 4;
                
                if SubmitSorting(Zoom_Electrode) >= 1
                    M_Zoom(1:size(RAW.M,1),1)=zeros;
                    colormap('Lines');
                    cmap = colormap;
                    Cell = ['Cell ' num2str(Zoom_Electrode)];
                    figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                    Graph_offset = 0.035;
                    Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                    for m=1:SubmitSorting(Zoom_Electrode)
                        M_Zoom(1:size(RAW.M,1),1) = zeros;
                        SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                        for i=1:size(SPI1,1)
                            if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(RAW.M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0)
                                M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = RAW.M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode);
                            end
                        end
                        subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                        hold on;
                        plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                        hold off;
                    end
                else
                    figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                    plot(T,RAW.M(:,Zoom_Electrode)); grid on;
                end
            end
            xlabel('Time / s'); ylabel('Voltage / uV');
            
        elseif spiketraincheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                graph_no = size(SPIKES,2)-slider_pos;
                if  HDspikedata==true
                    %                    Zoom_Electrode = el_no;
                else
                    plot(T,RAW.M);grid on;
                end
                SP = nonzeros(SPIKES(:,graph_no));
                if isempty(SP)==0
                    for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);
                    end
                end
                xlabel('Time / s'); ylabel('Voltage / uV');
            else
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                plot(T,RAW.M); grid on;
                SP = nonzeros(SPIKES(:,4));
                if isempty(SP)==0
                    for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);
                    end
                end
                xlabel('Time / s'); ylabel('Voltage / uV');
            end
        end
        mea = Zoom_Electrode;
        iu = 4;
        set(gca,'ButtonDownFcn',{@clicks,mea,iu})
        
        % insert marks (MC)
        if  get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t5),'value')==1
            if size(SPIKEZ.TS, 2) > Zoom_Electrode   
                SP = nonzeros(SPIKEZ.TS(:,Zoom_Electrode));
                if isempty(SP)==0
                    if spiketraincheck==1
                        y_axis=0.75;
                    else
                        Scale=0;
                        y_axis = ones(length(SP),1).*Scale.*.92;
                        % y_axis=0;
                    end
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Green',...
                        'LineStyle','none','Marker','v',...
                        'MarkerFaceColor','green','MarkerSize',9);
                end
            end
        end
        if  get(findobj('Tag','CELL_showBurstsCheckbox','Parent',t5),'value')==1
            if ~isempty(BURSTS.BEG)    % display burstbegin
                SP = nonzeros(BURSTS.BEG(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','>',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
            if ~isempty(BURSTS.END)   % display burstend
                SP = nonzeros(BURSTS.END(:,Zoom_Electrode));
                Scale=0;
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*Scale.*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','<',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
        end
        
    end
    function clicks(~,~,mea,iu) % click in zoomwindow sets threshold (click zoomwindow)
        ab = get(gca,'CurrentPoint');
        [~,~,BUTTON]=ginput(1);
        close('Zoom');
        
        % old code:
        %          if strcmp((get(gcbf, 'SelectionType')),'normal') % left click
        %             THRESHOLDS(mea) = ab(1,2);
        %          else
        %             THRESHOLDS_pos(mea) = ab(1,2); % MC: right click sets positive Threshold
        %         end
        
        if BUTTON==1 % left click
            if SPIKEZ.PREF.dyn_TH == 0
                SPIKEZ.neg.THRESHOLDS.Th(1,mea) = ab(1,2);
            else
                SPIKEZ.neg.THRESHOLDS.Th(:,mea) = ab(1,2);
            end
        else
            if SPIKEZ.PREF.dyn_TH == 0
                SPIKEZ.pos.THRESHOLDS.Th(1,mea) = ab(1,2);
            else
                SPIKEZ.pos.THRESHOLDS.Th(:,mea) = ab(1,2);
            end
        end
        
        if HDmode
            HDredraw();
        else
            redraw();
        end
        
        switch iu
            case 1
                zoomButton1Callback();
            case 2
                zoomButton2Callback();
            case 3
                zoomButton3Callback();
            case 4
                zoomButton4Callback();
        end
    end

% --- functions of 'invert'-Buttons (AD)-----------------------------
    function invertButton1Callback(source,event) %#ok
        if rawcheck == 1 %only for raw data
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Inv_Elektrode=nr_channel-slider_pos-3;
                if isempty(find(Invert_M==Inv_Elektrode, 1))
                    Invert_M = [Invert_M Inv_Elektrode];
                else
                    Invert_M(find(Invert_M==Inv_Elektrode,1)) = [];
                end
                RAW.M(:,Inv_Elektrode)=RAW.M(:,Inv_Elektrode)*(-1);
            else
                if isempty(find(Invert_M==1, 1))
                    Invert_M = [Invert_M 1];
                else
                    Invert_M(find(Invert_M== 1,1)) = [];
                end
                RAW.M(:,1)=RAW.M(:,1)*(-1);
            end
            redraw;
        end
    end
    function invertButton2Callback(source,event) %#ok
        if rawcheck == 1
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Inv_Elektrode=nr_channel-slider_pos-2;
                
                if isempty(find(Invert_M==Inv_Elektrode, 1))
                    Invert_M = [Invert_M Inv_Elektrode];
                else
                    Invert_M(find(Invert_M==Inv_Elektrode,1)) = [];
                end
                
                RAW.M(:,Inv_Elektrode)=RAW.M(:,Inv_Elektrode)*(-1);
            else
                
                if isempty(find(Invert_M==2, 1))
                    Invert_M = [Invert_M 2];
                else
                    Invert_M(find(Invert_M== 2,1)) = [];
                end
                
                RAW.M(:,2)=RAW.M(:,2)*(-1);
            end
            redraw;
        end
    end
    function invertButton3Callback(source,event) %#ok
        if rawcheck == 1
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Inv_Elektrode=nr_channel-slider_pos-1;
                if isempty(find(Invert_M==Inv_Elektrode, 1))
                    Invert_M = [Invert_M Inv_Elektrode];
                else
                    Invert_M(find(Invert_M==Inv_Elektrode,1)) = [];
                end
                RAW.M(:,Inv_Elektrode)=RAW.M(:,Inv_Elektrode)*(-1);
            else
                if isempty(find(Invert_M==3, 1))
                    Invert_M = [Invert_M 3];
                else
                    Invert_M(find(Invert_M== 3,1)) = [];
                end
                RAW.M(:,3)=RAW.M(:,3)*(-1);
            end
            redraw;
        end
    end
    function invertButton4Callback(source,event) %#ok
        if rawcheck == 1
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Inv_Elektrode=nr_channel-slider_pos;
                if isempty(find(Invert_M==Inv_Elektrode, 1))
                    Invert_M = [Invert_M Inv_Elektrode];
                else
                    Invert_M(find(Invert_M==Inv_Elektrode,1)) = [];
                end
                RAW.M(:,Inv_Elektrode)=RAW.M(:,Inv_Elektrode)*(-1);
            else
                if isempty(find(Invert_M==4, 1))
                    Invert_M = [Invert_M 4];
                else
                    Invert_M(find(Invert_M== 4,1)) = [];
                end
                RAW.M(:,4)=RAW.M(:,4)*(-1);
            end
            redraw;
        end
    end

% --- functions of 'Zero'-Buttons (CN)--------------------------
    function clearButton1Callback(source,event)   %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos-3;
        else
            Clear_Elektrode = 1;
        end
        RAW.M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS.BEG(:,Clear_Elektrode)=0;
        end
        redraw;
    end
    function clearButton2Callback(source,event)   %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos-2;
        else
            Clear_Elektrode = 2;
        end
        
        RAW.M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS.BEG(:,Clear_Elektrode)=0;
        end
        redraw;
    end
    function clearButton3Callback(source,event)   %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos-1;
        else
            Clear_Elektrode = 3;
        end
        
        RAW.M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS.BEG(:,Clear_Elektrode)=0;
        end
        redraw;
    end
    function clearButton4Callback(source,event)   %#ok
        
        if nr_channel>4 && ~(HDrawdata || HDspikedata)
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos;
        elseif ~HDmode
            Clear_Elektrode = 4;
        elseif HDmode % if HDMEA mode
            Clear_Elektrode = str2double(get(findobj(bottomPanel_HD,'Tag','EL_Select'),'string'));
        end
        
        RAW.M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS.BEG(:,Clear_Elektrode)=0;
        end
        redrawdecide
    end
    function clearButtonallCallback(source,event) %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            tb=nr_channel-slider_pos;
            tr = tb - 3;
        else
            tb= nr_channel;
            tr = 1;
        end
        for Clear_Elektrode = tr:tb
            RAW.M(:,Clear_Elektrode)=0;
            if spiketraincheck == 1
                SPIKES(:,Clear_Elektrode)=0;
                BURSTS.BEG(:,Clear_Elektrode)=0;
            end
        end
        redraw;
    end

% --- functions of 'Zero'-Buttons (CN)--------------------------
    function undoButton1Callback(source,event)  %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos-3;
        else
            Clear_Elektrode = 1;
        end
        
        RAW.M(:,Clear_Elektrode) = backup_M(:,Clear_Elektrode);
        redraw;
    end
    function undoButton2Callback(source,event)  %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos-2;
        else
            Clear_Elektrode = 2;
        end
        RAW.M(:,Clear_Elektrode) = backup_M(:,Clear_Elektrode);
        redraw;
    end
    function undoButton3Callback(source,event)  %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos-1;
        else
            Clear_Elektrode = 3;
        end
        RAW.M(:,Clear_Elektrode) = backup_M(:,Clear_Elektrode);
        redraw;
    end
    function undoButton4Callback(source,event)  %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos;
        else
            Clear_Elektrode = 4;
        end
        RAW.M(:,Clear_Elektrode) = backup_M(:,Clear_Elektrode);
        redraw;
    end

%Functions - Tab Data
%----------------------------------------------------------------------

% --- Open Files (sh-Kh, MC)
    function openButtonCallback(~,~)
        
        % 'Open file' - Window
        [file,myPath] = uigetfile({'*.*',  'All Files (*.*)'
            '*_RAW.mat; *_ST.mat; *.bxr; *.brw; *.dat', 'RAW or TS files'; ...
            '*_RAW.mat','Raw data file'; ...
            '*_TS.mat','Time stamp file'; ...
            '*.bxr','3brain TS file'; ...
            '*.brw','3brain raw data'; ...
            '*.dat','Labview raw data'; ...
            '*.txt','MCRACK raw data'; ...
            '*.rhd','RHD2000 raw data'; ...
            '*.h5','MCS raw or time stamp data'; },'Select one File with raw data or spiketrains.','MultiSelect','off');
        
        if not(iscell(file)) && not(ischar(file)) % if canceled - dont do anything
            return
        end

        % get file extension
        [~,~,ext] = fileparts(file);
        
        % if Labview ASCII file is selected
        if strcmp(ext,'.dat')
            openFileDat(file,myPath)
            % if RHD file is selected (Fileformat used at GSI)
        elseif strcmp(ext,'.rhd')
            openFileRHD2000(file,myPath)
            % if MCRACK file is selected (NOTE: ACTUALLY NOT USED ANYMORE)
        elseif strcmp(ext,'.txt')
            openFileMcRack(file,myPath)
            % if .mat file is selected (_TS or _RAW files)
        elseif strcmp(ext,'.mat')
            openFileMat(file,myPath)
            % if .brw (3brain Raw File) file is selected
        elseif strcmp(ext,'.brw')
            openFileBrw(file,myPath)
            % if .bxr (3brain Spike File) file is selected
        elseif strcmp(ext,'.bxr')
            openFileBxr(file,myPath)
            % if .h5 (Multichannel systems format, converted from .mcd to .h5 using "Multichannel Data Manager" (available online)
        elseif strcmp(ext,'.h5')
            openFileMcsH5(file,myPath)
            % fileformat not supported
        else
            errordlg('Unknown Fileformat')
        end
 
    end

% --- Init Variables before open a file (MC)
    function initVariablesBeforeOpenFile()
        clear Energy Variance;
        %temp = []; % must be initialized here in order to avoid error in function "openMatButtonCallback"
        SPIKES3D = [];
        SPIKES = [];
        M_OR = []; % used in function: SixWellButtonCallback
        BURSTS.BEG = [];
        BURSTS.END = [];
        SubmitSorting = 0; % Sorting Variable is reset
        SPIKES_Class = [];
        set(findobj('Tag','S_K_Nr','parent',t6),'String',0); % Cluster Number in Sorting tab is reset
        
        clear BEGEND;
        waitbar_counter = 0;
        stimulidata     = false;
        thresholddata   = false;
        STIMULI_1       = 0;
        STIMULI_2       = 0;
        BEGEND          = 0;
        BEG             = 0;
        END             = 0;
        cellselect      = 1;
        ELEC_CHECK      = [];
        handler;
        Nr_SI_EVENTS    = 0;
        Mean_SIB        = 0;
        Mean_SNR_dB     = 0;
        MBDae           = 0;
        STDburstae      = 0;
        aeIBImean       = 0;
        aeIBIstd        = 0;
        SI_EVENTS       = 0;
        spikedata       = false;
        EL_NUMS         = 0;
        nr_channel      = 0;
        first_open      = false;
        first_open4     = false;
        spiketraincheck = false;
        rawcheck        = false;
        NR_SPIKES       = 0;
        BURSTS.BRn      = 0;
        THRESHOLDS      = 0;
        kappa_mean      = 0;
        threshrmsdecide = 1; %As Default setting use rms for threshold calculation
        SPIKEZ          = [];
        SPIKEZ.TSC      = 0;
        SPIKEZ.TS       = 0;
        %SPIKEZ.PREF.dyn_TH = 0;
        NCh             = 0;
        varT            = 0;
        varTdata        = 0;
        RAW             = struct([]);
        rec_dur         = 0;
        SaRa            = 0;
        %     fileN           = 0;
        T               = 0;
        EL_NUMS         = 0;
        PREF            = 0;
        THRESHOLDS_pos  = 0;
        AMPLITUDES      = [];
        NETWORKBURSTS.BEG= 0;
        drawnbefore4    = false;
        drawnbeforeall  = false;
        is_open         = false;
        NCh             = 0;
        HDspikedata     = false;
        HDrawdata       = true;
        
        set(findobj(gcf,'Tag','radio_allinone'),'Value',0,'Enable','on');
        set(findobj(gcf,'Tag','radio_fouralltime'),'Value',1,'Enable','on');
        set(findobj(gcf,'Tag','HDredraw'),'Value',0,'Enable','off');
        
    end

% --- set settings after file has opened (old Code, put into separate function by MC)
    function setSettingsAfterOpenFile()
        
        % Switch to HDMEA Mode or stay at normal mode:
        HDmode = HDspikedata || HDrawdata;
        
        if HDmode
            Viewselect = 2;
            set(findobj(gcf,'Tag','Checkbox_simpleThreshold'),'Value',1,'Enable','off');
        end
        
        % Settings:
        set(0, 'currentfigure', mainWindow); % set main window as current figure so "gcf" works correctly
        if spiketraincheck == 1
            set(findobj(gcf,'Tag','CELL_dataFile'),'String',file);
            set(findobj(gcf,'Tag','CELL_fileInfo'),'String',fileinfo{1});
            set(findobj(gcf,'Tag','CELL_dataSaRa'),'String',SaRa);
            set(findobj(gcf,'Tag','CELL_dataNrEl'),'String',nr_channel);
            set(findobj(gcf,'Tag','CELL_dataDate'),'String',Date);
            set(findobj(gcf,'Tag','CELL_dataTime'),'String',Time);
            set(findobj(gcf,'Tag','CELL_dataDur'),'String',num2str(rec_dur));
            set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
            set(findobj(gcf,'Parent',t3,'Enable','on'),'Enable','off');
            uicontrol('Parent',t3,'Units','pixels','Position',[120 62 30 20],'style','edit','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','5','Tag','STD_noisewindow');
            set(findobj(gcf,'Parent',t2,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t5),'Enable','on');
            set(findobj(gcf,'Parent',t6),'Enable','on');
            set(findobj(gcf,'Parent',t7),'Enable','on');
            set(findobj(gcf,'Tag','Spike_Box'),'value',0,'Enable','off');
            set(findobj(gcf,'Tag','Spike2_Box'),'value',0,'Enable','off');
            set(findobj(gcf,'Tag','CELL_partClearButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_restoreButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_ElnullenButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_invertButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_smoothButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_scaleBox'),'value',2,'Enable','on');
            set(findobj(gcf,'Tag','CELL_scaleBoxLabel'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_DefaultBox'),'Enable','on');
            set(findobj(gcf,'Parent',radiogroup2),'Enable','off');
            set(findobj(gcf,'Parent',radiogroup3),'Enable','off');
            set(findobj(gcf,'Tag','Manual_threshold'),'Enable','off')
            set(findobj(gcf,'Tag','time_start'),'Enable','off');
            set(findobj(gcf,'Tag','time_end'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_sensitivityBox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_sensitivityBoxtext'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_Autocorrelation'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showSpikesCheckbox'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');
            set(findobj(gcf,'Tag','radio_allinone'),'Value',1,'Enable','on');
            set(findobj(gcf,'Tag','radio_fouralltime'),'Enable','on');
            set(findobj(gcf,'Tag','HDredraw'),'Enable','off');
            set(findobj(gcf,'Tag','VIEWtext'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_exportClearedMButton'),'enable','on');
            
            if nr_channel>1
                set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
            end
        end
        
        if spiketraincheck==0
            %Settings:
            isAlreadyFiltered = false;
            set(findobj(gcf,'Tag','CELL_dataFile'),'String',file);
            set(findobj(gcf,'Tag','CELL_fileInfo'),'String',fileinfo{1});
            set(findobj(gcf,'Tag','CELL_dataSaRa'),'String',SaRa);
            set(findobj(gcf,'Tag','CELL_dataNrEl'),'String',nr_channel);
            set(findobj(gcf,'Tag','CELL_dataDate'),'String',Date);
            set(findobj(gcf,'Tag','CELL_dataTime'),'String',Time);
            set(findobj(gcf,'Tag','CELL_dataDur'),'String',num2str(rec_dur));
            delete(findobj(0,'Tag','ShowSpikesBurstsperEL'));
            delete(findobj(0,'Tag','ShowSpikesBurstsperCell'));
            if nr_channel>1
                set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
            end
            set(findobj(gcf,'Parent',t3,'Enable','off'),'Enable','on');
            uicontrol('Parent',t3,'Units','pixels','Position',[120 62 30 20],'style','edit','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','5','Tag','STD_noisewindow');
            set(findobj(gcf,'Parent',t3,'Tag','CELL_sensitivityBox_pos'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_partClearButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_filterCheckbox'),'Enable','on','value',1);  % MC: value = 1 as default
            onofilter(); % MC: call this function to update filter GUI
            set(findobj(gcf,'Tag','CELL_quickNeuroAnalysisButton'),'Enable','on'); % MC: enable quickNeuroAnalysis Button
            set(findobj(gcf,'Tag','CELL_quickCardioAnalysisButton'),'Enable','on'); % MC: enable quickCardioAnalysis Button
            set(findobj(gcf,'Tag','CELL_ZeroOutCheckbox'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_restoreButton'),'Enable','on')
            set(findobj(gcf,'Tag','CELL_ElnullenButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_invertButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_smoothButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_savitzkygolayButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_applyButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_scaleBox'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_scaleBoxLabel'),'Enable','on');
            set(findobj(gcf,'Parent',radiogroup2),'Enable','on');
            set(findobj(gcf,'Parent',radiogroup3),'Enable','on');
            set(findobj(gcf,'Tag','Manual_threshold'),'Enable','on')
            set(findobj(gcf,'Tag','time_start'),'Enable','off');
            set(findobj(gcf,'Tag','time_end'),'Enable','off');
            set(findobj(gcf,'Parent',t4,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t5,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t6,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t7,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t8,'Enable','off'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_Autocorrelation'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showSpikesCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');
            set(findobj(gcf,'Tag','CELL_exportButton'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_exportAllCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showExportCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','radio_allinone'),'Value',1,'Enable','on');
            set(findobj(gcf,'Tag','radio_fouralltime'),'Enable','on');
            set(findobj(gcf,'Tag','HDredraw'),'Enable','off');
            set(findobj(gcf,'Tag','VIEWtext'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_sensitivityBoxtext'),'enable','on');
            set(findobj(gcf,'Tag','headlines'),'enable','on');
            set(findobj(gcf,'Tag','CELL_exportClearedMButton'),'enable','on');
            
            onofilter();
            if nr_channel>1
                set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
            end
        end
        
        %------ redraw:
        if Viewselect == 0
            
            set(findobj('Tag','radio_fouralltime'),'Value',1);
            if nr_channel>4
                %                 set(findobj(gcf,'Tag','CELL_slider'),'Enable','on',...
                %                     'Min', 0, 'Max', size(RAW.M,2)-4, 'Value', size(RAW.M,2)-4,...
                %                     'SliderStep', [1/(size(RAW.M,2)-4) 4/(size(RAW.M,2)-4)]);
                set(findobj(gcf,'Tag','CELL_slider'),'Enable','on',...
                    'Min', 0, 'Max', nr_channel-4, 'Value', nr_channel-4,...
                    'SliderStep', [1/(nr_channel-4) 4/(nr_channel-4)]);
            end
            redraw
        elseif Viewselect == 1
            set(findobj('Tag','radio_allinone'),'Value',1);
            set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...
                'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[1/rec_dur 1/rec_dur]);
            redraw_allinone
        elseif Viewselect == 2 % HDmeamode
            set(findobj(gcf,'Tag','radio_allinone'),'Value',0,'Enable','off');
            set(findobj(gcf,'Tag','radio_fouralltime'),'Value',0,'Enable','off');
            set(findobj(gcf,'Tag','HDredraw'),'Value',1,'Enable','on');
            redrawdecide
        end
        is_open = true;
        rawcheck = true;
        
        %Electrode Selection
        delete(findobj('Tag','S_Elektrodenauswahl'));
        uicontrol('Parent',t6,'Units','Pixels','Position',[700 12 50 51],'Tag','S_Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Enable','off','Value',1,'Style','popupmenu','callback',@recalculate);
        SubmitSorting(1:size(RAW.M,2)) = zeros;
        
        preti = (0.5:1000/SaRa:2);
        postti = (0.5:1000/SaRa:2);
        
        delete(findobj('Tag','S_pretime'));
        delete(findobj('Tag','S_posttime'));
        uicontrol('Parent',t6,'Units','Pixels','Position',[700 65 50 30],'Tag','S_pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','Enable','off','callback',@recalculate);
        uicontrol('Parent',t6,'Units','Pixels','Position',[760 65 50 30],'Tag','S_posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','Enable','off','callback',@recalculate);
        
    end

% --- Open raw .mat-Files (MC) ------------------------------------------
    function openFileMat(file,myPath)
        
        % init variables
        initVariablesBeforeOpenFile;
        HDrawdata       = 0;
        HDspikedata     = 0;
        
        cd(myPath)
        [SPIKEZ,RAW,spiketraincheck,spikedata,Date,Time,SaRa,EL_NAMES,EL_NUMS,NR_SPIKES,T,rec_dur,fileinfo,nr_channel,SPIKES,AMPLITUDES,HDspikedata] =read_mat(file, 1);
        
        % set Settings
        setSettingsAfterOpenFile;
        
    end

% --- Open .h5-Files (MC) ------------------------------------------
    function openFileMcsH5(file,myPath)
        
        % init variables
        initVariablesBeforeOpenFile;
        HDrawdata       = 0;
        HDspikedata     = 0;
        
        cd(myPath)
        %-------------load file
        
        % load RAW data if available
        [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel] = read_MCS_hd5_RAW(file, 1);
        RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel);
        
        % load spike Timestamp data if available
        SPIKEZ.TS = read_MCS_hd5_TS([myPath filesep file]);
        
        % set Settings
        if ~isempty(SPIKEZ.TS)
            spiketraincheck=1;
        else
            spiketraincheck=0;
        end
        setSettingsAfterOpenFile;
        
    end

% -- Open RHD2000 files (MC) --------------------------------------------
    function openFileRHD2000(file,myPath)
        
        % init variables
        initVariablesBeforeOpenFile;
        HDrawdata       = 0;
        HDspikedata     = 0;
        
        % use path of last loaded file if exist
        if myPath ~= 0
            cd(myPath)
        end
        
        % Load Data
        [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel]=read_Intan_RHD2000_file(myPath, file);
        
        % Save Data in RAW structure
        RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel);
        
        % set Settings
        spiketraincheck = 0;
        setSettingsAfterOpenFile;
        
    end

% --- Open file (.dat) (MG&CN)-------------------------------------------
% Note: this function uses external function "read_dat.m" to load a ".dat". file (MC)
    function openFileDat(file,myPath)
        
        % init variables
        initVariablesBeforeOpenFile;
        HDrawdata       = 0;
        HDspikedata     = 0;
        
        % use path of last loaded file if exist
        if myPath ~= 0
            cd(myPath)
        end
        
        % load data
        filepath = [myPath filesep file];
        flag_waitbar=1; % waitbar enabled
        [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel] = read_dat(filepath, flag_waitbar);
        
        % Save Data in RAW structure
        RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel);
        
        % set Settings
        spiketraincheck = 0;
        setSettingsAfterOpenFile;
        
    end

% --- Import 3brain HDMEA Raw Data (Sh.Kh) ------------------------------------------
    function openFileBrw(file,myPath)
        
        % init variables
        initVariablesBeforeOpenFile;
        HDrawdata       = 1;
        HDspikedata     = 0;
        HDmode = 1;
        
        spiketraincheck = 0;
        
        if myPath ~= 0
            cd(myPath)
        end
        
        % read data
        [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel,MaxVolt,MinVolt,BitDepth,SignalInversion]=read_brw(file,1);
        
        % Save Data in RAW structure
        RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel);
        RAW.MaxVolt = MaxVolt;
        RAW.MinVolt = MinVolt;
        RAW.BitDepth = BitDepth;
        RAW.SignalInversion = SignalInversion;

        setSettingsAfterOpenFile() 

    end

% --- Import 3brain HDMEA Spike Data (Sh.Kh) ------------------------------------------
    function openFileBxr(file,myPath)
        
        % init variables
        initVariablesBeforeOpenFile;
        HDrawdata       = 0;
        HDspikedata     = 1;
        HDmode = 1;
        
        spiketraincheck = 1;
        
        if myPath ~= 0
            cd(myPath)
        end
        
        % read data
        [TS,TSC,Date,Time,SaRa,EL_NAMES,EL_NUMS,T,rec_dur,fileinfo,nr_channel,ChIDs2NSpikes] = read_bxr(file,1);
        
        set(0, 'currentfigure', mainWindow);  % set main window as current figure
        
        % create structure
        temp.M= struct([]);
        RAW=temp;
        RAW.T=T;
        SPIKEZ.TS=TS;
        SPIKEZ.TSC=TSC;
        SPIKEZ.N=ChIDs2NSpikes;
        SPIKEZ.PREF.rec_dur=rec_dur;
        SPIKEZ.PREF.nr_channel = NCh;
        SPIKEZ.PREF.fileinfo=fileinfo;
        fileinfo = SPIKEZ.PREF.fileinfo;
        SPIKEZ.AMP = ~isnan(TS);
        SPIKEZ.neg.flag=1;
        SPIKEZ.pos.flag=0;
        SPIKEZ.neg.TS=TS;
        SPIKEZ.neg.AMP=SPIKEZ.AMP;
        SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
        % old variables used by some old functions:
        temp.M= struct([]);
        SPIKES=temp;
        SPIKES=SPIKEZ.TS; % SPIKES, AMPLITUDES, rec_dur, SaRa, EL_NUMS, optional: fileinfo, Time, Date
        NR_SPIKES=SPIKEZ.N;
        
        setSettingsAfterOpenFile()
        
    end

% --- Open McRack-file (exported into ASCII) (CN)------------------
    function openFileMcRack(file,myPath)
        
        
        % init variables
        initVariablesBeforeOpenFile;
        
        % 'Open McRack-File' - Menu
        full_path = [myPath,file];
        disp ('Importing McRack file:'); tic
        h = waitbar(0,'Please wait - importing McRack file...');
        fid = fopen([myPath file]);
        
        fseek(fid,0,'eof');
        filesize = ftell(fid);
        fseek(fid,0,'bof');
        fileinfo = textscan(fid,'%s',1,'delimiter','\n');
        Date = 'unknown';
        Time = 'unknown';
        fseek(fid,0,'bof');
        
        textscan(fid,'%s',1,'whitespace','\b\t','headerlines',2);
        elresult = textscan(fid,'%5s',61*1,'whitespace','\b\t');
        EL_NAMES = [elresult{:}];
        
        if is_open==1
            nr_channel_old = nr_channel;
        end
        
        nr_channel = find(ismember(EL_NAMES, '[ms]')==1)-1;
        EL_NAMES = EL_NAMES(1:nr_channel);
        EL_CHAR = char(EL_NAMES);
        
        for n=1:size(EL_CHAR,1)
            EL_NUMS(n) = str2double(EL_CHAR(n,4:5));
        end
        fseek(fid,0,'bof');
        
        mresult = textscan(fid,'',1,'headerlines',4);
        T = [mresult{1}];
        RAW.M = [mresult{2:length(mresult)}];
        while ftell(fid)<filesize
            mresult = textscan(fid,'',round(filesize/10000));
            T = cat(1,T,[mresult{1}]);
            RAW.M = cat(1,RAW.M,[mresult{2:length(mresult)}]);
            waitbar(ftell(fid)*.98/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
        end
        T = (T')./1000;
        SaRa = 1/T(2);
        clear mresult;
        
        RAW.M = cat(2,EL_NUMS',RAW.M');
        RAW.M = sortrows(RAW.M);
        RAW.M = RAW.M(:,2:size(RAW.M,2));               % RAW.M wieder in Ursprungsform bringen
        RAW.M = RAW.M';                             % "
        EL_NAMES = sortrows(EL_NAMES);      % Elektrodennamen sortieren
        EL_NUMS = sort(EL_NUMS);            % Elektrodennummern sortieren
        rec_dur = ceil(T(length(T)));
        rec_dur_string = num2str(rec_dur);
        
        %if needed delete %
        %M_OR = M;                           % Copy of M
        
        fclose(fid);
        waitbar(1,h,'Complete.'); close(h);
        toc
        
        % refresh
        set(findobj(gcf,'Tag','CELL_dataFile'),'String',file);
        set(findobj(gcf,'Tag','CELL_fileInfo'),'String',fileinfo{1});
        
        %refresh
        set(findobj(gcf,'Tag','CELL_dataSaRa'),'String',SaRa);
        set(findobj(gcf,'Tag','CELL_dataNrEl'),'String',nr_channel);
        set(findobj(gcf,'Tag','CELL_dataDate'),'String',Date);
        set(findobj(gcf,'Tag','CELL_dataTime'),'String',Time);
        set(findobj(gcf,'Tag','CELL_dataDur'),'String',rec_dur_string);
        
        %set(findobj(gcf,'Parent',t2,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_filterCheckbox'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_ZeroOutCheckbox'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_restoreButton'),'Enable','on')
        set(findobj(gcf,'Tag','CELL_ElnullenButton'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_invertButton'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_smoothButton'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_savitzkygolayButton'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_applyButton'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_scaleBox'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_scaleBoxLabel'),'Enable','on');
        set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_DefaultBox'),'Enable','on');
        set(findobj(gcf,'Parent',radiogroup2),'Enable','on');
        set(findobj(gcf,'Parent',radiogroup3),'Enable','on');
        set(findobj(gcf,'Tag','Manual_threshold'),'Enable','on')
        set(findobj(gcf,'Tag','time_start'),'Enable','off');
        set(findobj(gcf,'Tag','time_end'),'Enable','off');
        set(findobj(gcf,'Parent',t5,'Enable','on'),'Enable','off');
        set(findobj(gcf,'Parent',t6,'Enable','on'),'Enable','off');
        set(findobj(gcf,'Parent',t7,'Enable','on'),'Enable','off');
        set(findobj(gcf,'Parent',t8,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_Autocorrelation'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_showSpikesCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');
        set(findobj(gcf,'Tag','CELL_exportButton'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_exportAllCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_showExportCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','radio_allinone'),'Enable','on');
        set(findobj(gcf,'Tag','radio_fouralltime'),'Enable','on');
        set(findobj(gcf,'Tag','VIEWtext'),'Enable','on');
        set(findobj(gcf,'Parent',t3,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_sensitivityBoxtext'),'enable','on');
        set(findobj(gcf,'Tag','headlines'),'enable','on');
        set(findobj(gcf,'Tag','CELL_exportClearedMButton'),'enable','on');
        
        if nr_channel>1
            set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
        end
        
        % rekonfigure Scrollbar and redraw
        if Viewselect == 0
            if nr_channel>4
                set(findobj(gcf,'Tag','CELL_slider'),'Enable','on',...
                    'Min', 0, 'Max', size(RAW.M,2)-4, 'Value', size(RAW.M,2)-4,...
                    'SliderStep', [1/(size(RAW.M,2)-4) 4/(size(RAW.M,2)-4)]);
            end
            redraw
        elseif Viewselect == 1
            set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...
                'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[1/rec_dur 1/rec_dur]);
            redraw_allinone
        end
        is_open = true;
        rawcheck = true;
    end

% --- Export File (MC) --------------------------------------------
    function exportButtonCallback(~,~)
        
        % 'Open file' - Window
        [filename,myPathname] = uiputfile();
        
        if not(iscell(filename)) && not(ischar(filename)) % if canceled - dont do anything
            return
        end
        
        filepath = [myPathname filename];
        
        [p,f,e]=fileparts(filepath);
        filename = [p filesep f];
        
        saveRAW(RAW, filename)
    end

% --- Quick Neuro Analysis (MC) -----------------------------------------
    function quickNeuroAnalysisButtonCallback(~,~)
        
        disp('------ QUICK NEURO ANALYIS ---------')
        
        % Filter
        if ~isAlreadyFiltered
            Applyfilter();
        else
            disp('Raw data already filtered')
        end
        
        CalculateThreshold(); % same function call as pressing button "Calculate" (tab 3)
        Analysedecide(); % same function call as pressing button "Analyze..." (tab 4)
        
        disp('------ QUICK NEURO ANALYIS finished ---------')
    end

% --- Quick Cardio Analysis (MC) -----------------------------------------
    function quickCardioAnalysisButtonCallback(~,~)
        
        disp('------ QUICK CARDIO ANALYIS ---------')
        
        % Filter
        if ~isAlreadyFiltered
            Applyfilter();
        else
            disp('Raw data already filtered')
        end
        
        spikedata = 0;
        CalculateThreshold(); % same function call as pressing button "Calculate" (tab 3)
        
        % Detect spikes with 200 ms refractory time setting (hard coded in
        % cardioSpikedetection function)
        SPIKEZ.PREF.sixwell = 0;  % don't use sixwell MEA mode
        SPIKEZ.PREF.flag_isHDMEAmode = HDmode;
        SPIKEZ.PREF.idle_time = 0.2; % refractory time 200 ms
        SPIKEZ = cardioSpikedetection(RAW,SPIKEZ);
        
        spikedata = true;
        set(findobj(gcf,'Parent',t5),'Enable','on');
        set(findobj(gcf,'Parent',t6),'Enable','on');
        set(findobj(gcf,'Parent',t7),'Enable','on');
        disp('Spikedetection finished')
        
        
        
        
        % calculate signal speed
        [velocity_airline,velocity_min_mean,velocity_max_mean] = cardioCalculateSpeed(SPIKEZ);
        disp('---')
        for i = 1 : length(velocity_airline)
            disp(['Velocity (air line) in m/s: ' num2str(velocity_airline(i))])
        end
        disp('---')
        for i = 1 : length(velocity_min_mean)
            disp(['Velocity_min (mean over neighboring electrodes) in m/s: ' num2str(velocity_min_mean(i))])
        end
        disp('---')
        for i = 1 : length(velocity_max_mean)
            disp(['Velocity_max (mean over neighboring electrodes) in m/s: ' num2str(velocity_max_mean(i))])
        end
        
        [SPIKEZ,SPIKES,AMPLITUDES,NR_SPIKES,FR,N_FR,aeFRmean,aeFRstd,SNR,SNR_dB,Mean_SNR_dB]=copySpikesIntoOldStructure(SPIKEZ);
        %[SPIKEZ,SPIKES,AMPLITUDES,NR_SPIKES,FR,N_FR,aeFRmean,aeFRstd,SNR,SNR_dB,Mean_SNR_dB]=cardioCopySpikesIntoOldStructure(SPIKEZ);
        
        redrawdecide()
        disp('------ QUICK CARDIO ANALYIS finished ---------')
        
    end


% --- 6-Well-View (MC) --------------------------------------------
    function SixWellButtonCallback(source,event) % clear all electrodes except of selected chamber
        if isempty(M_OR)
            M_OR=RAW.M;     % save all data as backup
        end
        
        RAW.M=M_OR;      % restore data
        M_mask=zeros(size(RAW.M));
        
        chamber = str2num(cell2mat(inputdlg('Enter number of desired chamber (1: Chamber A, 2: Chamber B, 3: Chamber C, 4: Chamber D, 5: Chamber E, 6: Chamber F, 0: show all Electrodes)')));
        
        switch chamber % case 0: show all electrodes, case 1: only show chamber 1 ect.
            case 0
                
            case 1
                
                for n=15                % n: electrode number (1 - 60)
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=23:26
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=31:34
                    M_mask(:,n)=RAW.M(:,n);
                end
                RAW.M=M_mask;
                
            case 2
                for n=40:42
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=47:50
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=55:56
                    M_mask(:,n)=RAW.M(:,n);
                end
                RAW.M=M_mask;
                
            case 3
                for n=43:44
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=51:54
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=58:60
                    M_mask(:,n)=RAW.M(:,n);
                end
                RAW.M=M_mask;
                
            case 4
                for n=27:30
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=35:38
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=46
                    M_mask(:,n)=RAW.M(:,n);
                end
                RAW.M=M_mask;
                
            case 5
                for n=5:6
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=11:14
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=19:21
                    M_mask(:,n)=RAW.M(:,n);
                end
                RAW.M=M_mask;
                
            case 6
                for n=1:3
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=7:10
                    M_mask(:,n)=RAW.M(:,n);
                end
                for n=17:18
                    M_mask(:,n)=RAW.M(:,n);
                end
                RAW.M=M_mask;
                
        end
        
        %RAW.M=M;
        
        % Rekonfigure Scrollbar and redraw
        if Viewselect == 0
            if nr_channel>4
                set(findobj(gcf,'Tag','CELL_slider'),'Enable','on',...
                    'Min', 0, 'Max', size(RAW.M,2)-4, 'Value', size(RAW.M,2)-4,...
                    'SliderStep', [1/(size(RAW.M,2)-4) 4/(size(RAW.M,2)-4)]);
            end
            redraw
        elseif Viewselect == 1
            set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...
                'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[1/rec_dur 1/rec_dur]);
            redraw_allinone
        end
        
    end

% --- Convert txt to _TS.mat (MC) ------------------------------------------
    function txt2TSButtonCallback(source,event) % select several TimeAmp.txt-Files and convert it to .mat
        if ~isempty(myPath)
            cd(myPath)
        end
        
        % "Open directory" Window
        dir_name=uigetdir();
        if dir_name == 0
            return
        end
        
        % Question: Overwrite files?
        choice=questdlg('Overwrite TimeAmp.txt-files?','Convert Files','Yes', 'No','No');
        if isempty(choice)
            return
        end
        
        [dirarray,files]=subdir(dir_name);
        
        
        myPath=dirarray{1};
        
        number_of_files=0;
        for i=1:size(files,2)
            number_of_files=number_of_files+size(files{i},2);
        end
        disp([num2str(number_of_files) ' files are inside selected folder'])
        
        for jjj=1:size(dirarray,2) % loop trough all subdirectories
            current_dir=dirarray{jjj};
            filearray=files{jjj};
            
            for iii=1:size(filearray,2) % Loop from 1 to last selected file
                current_file = filearray{iii};
                [~,filename,ext] = fileparts(current_file); % get file extension
                if strcmp(ext,'.txt')
                    cd(current_dir)
                    
                    % load txt
                    [temp.SPIKEZ]=convertTXT2TS(current_file);
                    
                    filename_new=[filename(1:strfind(filename,'-TimeAmp')-1) '_TS.mat'];
                    save(filename_new, 'temp');
                    disp([filename_new ' saved'])
                    switch choice
                        case 'Yes'
                            delete([filename ext]); % delete TimeAmp.txt file
                            disp([filename ext ' deleted'])
                        case 'No'
                    end
                end
                
            end
        end
        
        msgbox('Conversion finished');
        
    end

    function STRUC=convertTXT2TS(file_name)
        
        if 0 %old
            A=dlmread(file_name);
            
            % write timestamps to TS
            TS=zeros(size(A,1),size(A,2)/2);
            n_new=1; n=1;
            while(n<=120)
                TS(1:size(A,1)-1,n_new)=A(2:size(A,1),n);
                n=n+2;
                n_new=n_new+1;
            end
            STRUC.neg.TS=TS;
            
            % write amplitudes to AMP
            AMP=zeros(size(A,1),size(A,2)/2);
            n_new=1; n=2;
            while(n<=120)
                AMP(1:size(A,1)-1,n_new)=A(2:size(A,1),n);
                n=n+2;
                n_new=n_new+1;
            end
            STRUC.neg.AMP=AMP;
        end
        
        data_raw = load(file_name);
        STRUC.neg.TS = data_raw(2:end,1:2:end);
        STRUC.neg.AMP = data_raw(2:end,2:2:end);
        STRUC.neg.AMP(STRUC.neg.TS==0)=NaN; % NaN-padding
        STRUC.neg.TS(STRUC.neg.TS==0)=NaN; % NaN-padding
        
        % init other fields that are needed for automated analysis tool
        STRUC.pos=0;
        STRUC.TS=0;
        STRUC.AMP=0;
        STRUC.FILTER.f_edge=50;
        STRUC.SNR=0;
        STRUC.PREF.SaRa=10000;
        STRUC.PREF.rec_dur=60;
    end

% --- Split raw file (MC)
    function splitRawFileButtonCallback(~,~)
        
        % 'Open file' - Window
        [filename,pathname] = uigetfile({'*_RAW.mat','Raw data file (*_RAW.mat)'; ...
            '*.dat','Raw data file (*.dat)'},'Select one raw file (.dat or _RAW.mat).','MultiSelect','off');
        if not(iscell(filename)) && not(ischar(filename)) % if canceled - dont do anything
            return
        end
        
        % get new file length
        new_length = str2num(cell2mat(inputdlg('Enter new file length in seconds (e.g. file-length is 60s, entering 10s generates 6 new files):')));
        
        
        % get file extension
        [~,fname,ext] = fileparts(filename);
        
        % if mat file is selected, load it directly
        if strcmp(ext,'.mat')
            load(filename)
            RAW.M=temp.M;
            T=temp.T;
            fname=fname(1:findstr('_RAW',filename)-1); % delete "_RAW" from filename
        end
        
        % if dat file is selected convert it to mat
        if strcmp(ext,'.dat')
            loadRawData(pathname,filename)
            temp.T=T;
            temp.rec_dur=rec_dur;
            temp.SaRa=SaRa;
            temp.EL_NAMES=EL_NAMES;
            temp.EL_NUMS=EL_NUMS;
            temp.nr_channel=nr_channel;
            temp.Date=Date;
            temp.Time=Time;
            temp.fileinfo=fileinfo;
        end
        
        % split raw file
        numOfFiles=ceil(T(1,end)/new_length);
        for i=1:numOfFiles
            clear M_new T_new
            if new_length*i*temp.SaRa > size(RAW.M,1) % if current end position is greater than file-length
                M_new=RAW.M(1+(new_length*(i-1)*temp.SaRa) : end , :);
                T_new(1,:)=T(1,1+(new_length*(i-1)*temp.SaRa) : end);
            else
                M_new=RAW.M(1+(new_length*(i-1)*temp.SaRa) : new_length*i*temp.SaRa , :);
                T_new(1,:)=T(1,1+(new_length*(i-1)*temp.SaRa) : new_length*i*temp.SaRa);
            end
            T_new(1,:)=T_new(1,:)-(new_length*(i-1)); % every file starts at T=0 seconds
            rec_dur_new=T_new(1,end)+1/temp.SaRa;
            temp.M=M_new;
            temp.T=T_new;
            temp.rec_dur=rec_dur_new;
            filename_new=[fname '_' num2str(i) '_RAW.mat'];
            save(filename_new,'temp')
        end
        
    end

% --- Convert .dat files to .mat (MC) ------------------------------------------
    function convertDat2MatButtonCallback(~,~) % convert raw-file .dat to .mat
        
        if ~isempty(myPath) && ischar(myPath)
            cd(myPath)
        end
        
        % "Open directory" Window
        dir_name=uigetdir('Pick a Directory');
        if dir_name == 0
            return
        end
        
        % Question: Overwrite files?
        choice=questdlg('Overwrite .dat-files?','Convert Files','Yes', 'No','No');
        if isempty(choice)
            return
        end
        
        [dirarray,files]=subdir(dir_name);
        if ~iscell(dirarray)
            dirarray = {dir_name}; % force it to be a cell array of strings in case only one file is selected
            tmp=dir(dir_name);
            files{1}={tmp.name};
        end
        
        
        myPath=dirarray{1};
        
        number_of_files=0;
        for i=1:size(files,2)
            number_of_files=number_of_files+size(files{i},2);
        end
        disp([num2str(number_of_files) ' files are inside selected folder'])
        
        for jjj=1:size(dirarray,2) % loop trough all subdirectories
            current_dir=dirarray{jjj};
            filearray=files{jjj};
            
            for iii=1:size(filearray,2) % Loop from 1 to last selected file
                current_file = filearray{iii};
                
                % also look at next file, if mat file has been already
                % created, it will appear in filearray{iii+1}. In that case skip current file
                if iii < size(filearray,2)
                    next_file = filearray{iii+1};
                else
                    next_file = filearray{iii};
                end
                
                [~,filename,ext] = fileparts(current_file); % get file extension
                [~,filename_next,ext_next] = fileparts(next_file); % get file extension
                
                if strcmp(ext,'.dat') && ~strcmp([filename_next,ext_next],[filename,'_RAW.mat']) % if .dat file and if not already converted
                    
                    filepath = [current_dir filesep current_file];
                    flag_waitbar = 1; % if 1: display waitbar
                    [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel] = read_dat(filepath, flag_waitbar);
                    temp = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel);
                    
                    saveRAW(temp, [current_dir filesep current_file])
                    disp([filename_next ' converted'])
                    
                    switch choice
                        case 'Yes'
                            delete([current_dir filesep current_file]); % delete .dat file
                        case 'No'
                    end
                end
                
            end
        end
        
        msgbox('Conversion finished');
        
    end


% --- Convert .dat files to .mat (MC) ------------------------------------------
    function convertAxionWellButtonCallback(~,~) % convert Axion spk to TS.mat or raw .csv data to _RAW.mat files for each well
        
        if ~isempty(myPath) && ischar(myPath)
            try
                cd(myPath) 
            end
        end

        msgbox('In the next window, please select the folder that contains the axion files (*.spk files). It is also possible to select a folder containing subfolders.');
        %msgbox('In the next window, please select the folder that contains the axion files (raw *.csv and/or *.spk files). It is also possible to select a folder containing subfolders.');
        uiwait(gcf); % wait until user clicks ok

        % "Open directory" Window
        dir_name=uigetdir('Pick a Directory that contains axion *.spk files.');
        %dir_name=uigetdir('Pick a Directory that contains axion *.csv and/or *.spk files.');
        if dir_name == 0
            return
        end

        %input = inputdlg('Please enter the recording duration in seconds (will be used for *_spike_list.csv files): ');
        %axion_rec_dur = str2num(cell2mat(input));
        %input = inputdlg('Please enter the sample rate in Hz (will be used for *_spike_list.csv files): ');
        %axion_SaRa = str2num(cell2mat(input));
                
        [dirarray,files]=subdir(dir_name);
        if ~iscell(dirarray)
            dirarray = {dir_name}; % force it to be a cell array of strings in case only one file is selected
            tmp=dir(dir_name);
            files{1}={tmp.name};
        end
        
        myPath=dirarray{1};
        
        number_of_files=0;
        for i=1:size(files,2)
            number_of_files=number_of_files+size(files{i},2);
        end
        disp([num2str(number_of_files) ' files are inside selected folder'])
        
        for jjj=1:size(dirarray,2) % loop trough all subdirectories
            current_dir=dirarray{jjj};
            filearray=files{jjj};
            
            for iii=1:size(filearray,2) % Loop through all files
                current_file = filearray{iii};
                
                [~,filename,ext] = fileparts(current_file); % get file extension
                filepath = [current_dir filesep current_file];
                
                % if raw data (just ends with .csv)
                %if strcmp(ext,'.csv') && ~contains(filename, '_list') && ~contains(filename, '_counts')
                %    disp(['Converting raw data ' filepath ' ...'])
                %    axion24well_csv2RAW(filepath)
                %end

                % if spike data (ends with _spike_list.csv)
                %if strcmp(ext,'.csv') && contains(filename, '_spike_list')
                %    disp(['Converting spike data ' filepath ' ...'])
                %    axion24well_csv2TS(filepath, axion_rec_dur, axion_SaRa)
                %end

                % if .spk file
                if strcmp(ext, '.spk')
                    disp(['Converting spike data ' filepath ' ...'])
                    axion_spk2TS(filepath)
                end
                
            end
        end
        
        msgbox('Conversion finished');
        
    end


%Funktionen - Tab Preprocessing
%----------------------------------------------------------------------


% --- Filter on/off (RB)---------------------------------------------

    function onofilter(source,event)%#ok
        if get(findobj(gcf,'Tag','CELL_filterCheckbox'),'Value')==1
            set(findobj(gcf,'Tag','CELL_low_filter'),'enable','on');
            set(findobj(gcf,'Tag','CELL_high_filter'),'enable','on');
            set(findobj(gcf,'Tag','CELL_filterBoxtext'),'enable','on');
            set(findobj(gcf,'Tag','CELL_low_edit'),'enable','on');
            set(findobj(gcf,'Tag','CELL_high_edit'),'enable','on');
            set(findobj(gcf,'Tag','CELL_bandpass'),'enable','on','value',0);
            set(findobj(gcf,'Tag','CELL_bandstop'),'enable','on','value',1);
            set(findobj(gcf,'Tag','CELL_previewButton'),'enable','on');
            set(findobj(gcf,'Tag','CELL_low_boundary'),'enable','on')
            set(findobj(gcf,'Tag','CELL_high_boundary'),'enable','on')
        else
            set(findobj(gcf,'Tag','CELL_low_filter'),'enable','off');
            set(findobj(gcf,'Tag','CELL_high_filter'),'enable','off');
            set(findobj(gcf,'Tag','CELL_filterBoxtext'),'enable','off');
            set(findobj(gcf,'Tag','CELL_low_edit'),'enable','off');
            set(findobj(gcf,'Tag','CELL_high_edit'),'enable','off');
            set(findobj(gcf,'Tag','CELL_bandpass'),'enable','off','value',0);
            set(findobj(gcf,'Tag','CELL_bandstop'),'enable','off','value',0);
            set(findobj(gcf,'Tag','CELL_previewButton'),'enable','off');
            set(findobj(gcf,'Tag','CELL_low_boundary'),'enable','off')
            set(findobj(gcf,'Tag','CELL_high_boundary'),'enable','off')
        end
    end

% --- update Filter slider (RB)----------------------------------------------
    function filter_edit(source,event) %#ok<INUSD>
        if str2double(get(findobj(gcf,'Tag','CELL_low_edit'),'string'))> 5000
            set(findobj(gcf,'Tag','CELL_low_edit'),'string',5000);
        end
        
        if str2double(get(findobj(gcf,'Tag','CELL_high_edit'),'string'))> 5000
            set(findobj(gcf,'Tag','CELL_high_edit'),'string',5000);
        end
        
        set(findobj(gcf,'Tag','CELL_low_filter'),'value',str2double(get(findobj(gcf,'Tag','CELL_low_edit'),'string')));
        set(findobj(gcf,'Tag','CELL_high_filter'),'value',str2double(get(findobj(gcf,'Tag','CELL_high_edit'),'string')));
    end

% --- update Filter edit fields (RB)----------------------------------------------
    function filter_slider(source,event) %#ok<INUSD>
        set(findobj(gcf,'Tag','CELL_low_edit'),'string',get(findobj(gcf,'Tag','CELL_low_filter'),'value'));
        set(findobj(gcf,'Tag','CELL_high_edit'),'string',get(findobj(gcf,'Tag','CELL_high_filter'),'value'));
    end

% --- guarantee exclusive filter choice (RB)----------------------------------------------
    function filter_choice1(source,event) %#ok<INUSD>
        if get(findobj(gcf,'Tag','CELL_bandpass'),'value') == 1
            set(findobj(gcf,'Tag','CELL_bandstop'),'value',0);
        else
            set(findobj(gcf,'Tag','CELL_bandstop'),'value',1);
        end
    end

    function filter_choice2(source,event) %#ok<INUSD>
        if get(findobj(gcf,'Tag','CELL_bandstop'),'value') == 1
            set(findobj(gcf,'Tag','CELL_bandpass'),'value',0);
        else
            set(findobj(gcf,'Tag','CELL_bandpass'),'value',1);
        end
    end

% --- bandpass filter (Sh.Kh)----------------------------------------------
    function bandpass(~)
        
        MM=RAW.M;
        waitbar_counter = waitbar_counter + 2*waitbaradd;
        waitbar(waitbar_counter);
        
        if str2double(get(findobj('Tag','CELL_low_edit'),'string'))== 0 % in case that lower boundary equals zero use lowpass instead of bandstop
            [z,p,k] = cheby2(3,20,str2double(get(findobj('Tag','CELL_high_edit'),'string'))*2/SaRa,'low');
            [sos,g] = zp2sos(z,p,k);			% Convert to SOS form
            Hd = dfilt.df2tsos(sos,g);
        else
            [z,p,k] = cheby2(3,20,[str2double(get(findobj('Tag','CELL_low_edit'),'string'))*2/SaRa str2double(get(findobj('Tag','CELL_high_edit'),'string'))*2/SaRa],'bandpass');
            [sos,g] = zp2sos(z,p,k);			% Convert to SOS form
            Hd = dfilt.df2tsos(sos,g);
        end
        
        
        if size(MM,2)<=60  %for .mat Data
            MM = filter(Hd,MM);
        else
            j=1;  % bei kleinem Arbeitsspeicher muss j kleiner werden
            if HDrawdata ==1     % for .brw Data
                for i=0:+j:(floor(numel(MM(1,:))/j)-1)*j
                    m=(MM(:,i+1:i+j));
                    m=digital2analog_sh(m,RAW);
                    m(m<-4000)=0;
                    m(m>4000)=0;
                    m=(filter(Hd,m));
                    m=(m/(RAW.MaxVolt*2/2^RAW.BitDepth))+((2^RAW.BitDepth)/2);
                    MM(:,i+1:i+j)=m;
                    clear m;
                end
                i=i+j;
                if i<size(MM,2)
                    m=MM(:,i+1:size(MM,2));
                    m=digital2analog_sh(m,RAW);
                    m(m<-4000)=0;
                    m(m>4000)=0;
                    m=(filter(Hd,m));
                    m=(m/(MaxVolt*2/2^RAW.BitDepth))+((2^RAW.BitDepth)/2);
                    MM(:,i+1:size(MM,2))=m;
                    clear m;
                end
            end
        end
        if stimulidata == 1
            for n = 1:(length(BEG))
                RAW.M((int32(BEG(n)*SaRa)):(int32(END(n)*SaRa)),:) = 0;
            end
        end
        RAW.M=MM;
    end



% --- bandstop filter (RB)----------------------------------------------
    function notchfilter(~,~)
        
        waitbar_counter = waitbar_counter + waitbaradd;
        waitbar(waitbar_counter);
        
        d  = fdesign.notch('N,F0,Q,Ap',6,str2double(get(findobj('Tag','CELL_low_edit'),'string'))*2/SaRa,10,1);
        Hd = design(d);
        RAW.M = filter(Hd,RAW.M);
        
        if stimulidata == 1
            for n = 1:(length(BEG))
                RAW.M((int32(BEG(n)*SaRa)):(int32(END(n)*SaRa)),:) = 0;
            end
        end
    end

%d  = fdesign.notch('N,F0,Q,Ap',6,0.5,10,1);

% --- Zero Out on/off (CN)---------------------------------------------
    function onofffkt(source,event)%#ok
        if get(findobj(gcf,'Tag','CELL_ZeroOutCheckbox'),'Value')==1
            set(findobj(gcf,'Tag','threshstim'),'enable','on');
            set(findobj(gcf,'Tag','th_stim'),'String','700','enable','on');
            set(findobj(gcf,'Tag','CELL_selectelectrode'),'enable','on');
            set(findobj(gcf,'Tag','Elekstimname'),'enable','on');
            set(findobj(gcf,'Tag','text_aftertime'),'enable','on');
            set(findobj(gcf,'Tag','aftertime'),'String','0.005','enable','on');
            set(findobj(gcf,'Tag','textplus'),'enable','on');
            set(findobj(gcf,'Tag','textsek'),'enable','on');
        else
            set(findobj(gcf,'Tag','threshstim'),'enable','off');
            set(findobj(gcf,'Tag','th_stim'),'String','-','enable','off');
            set(findobj(gcf,'Tag','CELL_selectelectrode'),'enable','off');
            set(findobj(gcf,'Tag','Elekstimname'),'enable','off');
            set(findobj(gcf,'Tag','text_aftertime'),'enable','off');
            set(findobj(gcf,'Tag','aftertime'),'String','-','enable','off');
            set(findobj(gcf,'Tag','textplus'),'enable','off');
            set(findobj(gcf,'Tag','textsek'),'enable','off');
        end
    end

% --- ZeroOut Einlesen (CN)--------------------------------------------
    function ZeroOutcallfunction(source,event) %#ok<INUSD>
        PREF(9) = get(findobj(gcf,'Tag','CELL_selectelectrode'),'value');
        PREF(10) = str2double(get(findobj(gcf,'Tag','th_stim'),'string'));
        PREF(11) = str2double(get(findobj(gcf,'Tag','aftertime'),'string'));
        h_wait = waitbar(0,'Please Wait - busy...');
        buttonfunction;
    end

% --- ZeroOut - Find stimuli timestamps (CN)---------------------------
    function buttonfunction(source, event) %#ok<INUSD>
        M_Stim = RAW.M(:,PREF(9));
        M2 = (M_Stim<-(PREF(10)));
        M3 = (M_Stim>PREF(10));
        waitbar_counter = waitbar_counter + 10*waitbaradd;
        waitbar(waitbar_counter);
        
        if ((isempty(nonzeros(M2)))==0) %
            BEGTEST = M_Stim(1:(int32(0.2*SaRa)));
            if ((max(BEGTEST)>PREF(10) )||(min(BEGTEST)<-(PREF(10))));
                RAW.M(1:int32(0.2*SaRa),:) = 0;
            end
            clear BEGTEST
            
            % Timestamps of Stimuli:
            k = 0;
            i = 0;
            q = 0;
            w = 0;
            for m = 2:size(M2)
                if M2(m)>M2(m-1) %negativ slopes Start
                    k = k+1;
                    STIMULI_1(k) = T(m);
                end
                if M2(m)<M2(m-1) %negativ slopes End
                    i = i+1;
                    STIMULI_2(i) = T(m);
                end
                if M3(m)<M3(m-1) %positiv slopes Start
                    q = q+1;
                    STIMULI_3(q) = T(m);
                end
                if M3(m)>M3(m-1) %positive slopes End
                    w = w+1;
                    STIMULI_4(w) = T(m);
                end
            end
            
            waitbar_counter = waitbar_counter + 5*waitbaradd;
            waitbar(waitbar_counter);
            STIMULI = sort(cat(2,STIMULI_1,STIMULI_2,STIMULI_3,STIMULI_4 ));
            
            if k > 0 || i > 0
                BEGEND(1)= (STIMULI(1)-0.001);  %Beginning of first stimulation
                k=1;
                for m = 2:(size(STIMULI,2)-1)
                    if (STIMULI(m+1)-STIMULI(m))>0.075  %Are two stimuli at least 0,075 apart, they are considered as two stimuli
                        k = k+1;
                        BEGEND(k) = (STIMULI(m)+(PREF(11)));
                        k = k+1;
                        BEGEND(k)= (STIMULI(m+1)-0.001);
                    end
                end
                k=k+1;
                BEGEND(k) = (STIMULI(size(STIMULI,2))+(PREF(11))); %End of last stimulation
                
                TEMP = reshape (BEGEND,2,[]);
                BEG = TEMP(1,:);
                END = TEMP(2,:);
                stimulidata = true;
                
                if (T(size(T,2))-END(size(END,2))<= 0.6)
                    RAW.M((int32(BEG(size(BEG,2))*SaRa)):(size(RAW.M,1)),:) = 0;
                    BEG = BEG(1:(size(BEG,2)-1));
                    END = END(1:(size(END,2)-1));
                end
                
                %elimination of artifakt
                stTm = int32(END*SaRa);   % defines times of artifacts
                samplTmMs=1/SaRa*1000;    % samplerate in ms
                tmPre=200;                % time before Stimulus (up to 200)
                tmPost=600;               % time after Stimulus (up to 800)
                stRemoval = 0;
                ptPre=round(tmPre/samplTmMs);
                ptPost=round(tmPost/samplTmMs);
                
                for ch=1:60
                    time=(0:length(RAW.M(:,ch))-1)*samplTmMs;
                    signal=[];
                    for i=1:length(stTm)
                        signal=[signal; RAW.M(stTm(i)-ptPre:stTm(i)+ptPost,ch)'];
                    end
                    signalaver=mean(signal);
                    timePr=time(1:length(signal))-tmPre;
                    TimeStartCor=find(timePr>=stRemoval);
                    TimeStopCor=find(timePr>=25+stRemoval-1 );
                    TimeStartCor0=find(timePr>=7.5+stRemoval-1 );
                    TimeStopCor0=find(timePr>=100+stRemoval-1 );
                    PuntFinTolti=17.5/samplTmMs;
                    anaBin=1;
                    prova_fit=polyfit(time(TimeStartCor(1):anaBin:TimeStopCor(1)),signalaver(TimeStartCor(1):anaBin:TimeStopCor(1)),9);
                    prova_corr=polyval(prova_fit,time(TimeStartCor(1):TimeStopCor(1)-PuntFinTolti));
                    prova_fit=polyfit(time(TimeStartCor0(1):anaBin:TimeStopCor0(1)),signalaver(TimeStartCor0(1):anaBin:TimeStopCor0(1)),9);
                    prova_corr2=polyval(prova_fit,time(TimeStartCor0(1):TimeStopCor0(1)-PuntFinTolti));
                    signalCorr=signal;
                    
                    %safe corrected signal in signalCorr
                    for i=1:length(stTm)
                        signalCorr(i,(TimeStartCor(1):TimeStopCor(1)-PuntFinTolti))=signal(i,(TimeStartCor(1):TimeStopCor(1)-PuntFinTolti))-prova_corr;
                        signalCorr(i,(TimeStartCor0(1):TimeStopCor0(1)-PuntFinTolti))=signal(i,(TimeStartCor0(1):TimeStopCor0(1)-PuntFinTolti))-prova_corr2;
                    end
                    
                    if(ch==PREF(9))
                        signal_draw = signal(1,:);
                        signalCorr_draw = signalCorr(1,:);
                        signalCorr_draw(((200/samplTmMs)+1-(END(1)-BEG(1))*SaRa):((200/samplTmMs)+1)) = 0;
                    end
                    waitbar_counter = waitbar_counter+waitbaradd;
                    waitbar(waitbar_counter);
                    
                    for i=1:length(stTm)
                        ins(i,:) = signalCorr(i,1001:length(signalCorr));
                        RAW.M(stTm(i):(stTm(i)+length(ins)-1),ch)=(ins(i,:))';
                    end
                end
            end
            
            for n = 1:(length(BEG))
                RAW.M((int32(BEG(n)*SaRa)):(int32(END(n)*SaRa)),:) = 0;
            end
            
            clear signal;
            clear stTm;
        end
    end

% --- Apply Filter Function (CN)---------------------------------------
    function Applyfilter(source,event) %#ok
        
        if ~isAlreadyFiltered
    
            PREF(12) = get(findobj(gcf,'Tag','CELL_bandstop'),'value');    % bandstop
            PREF(13) = get(findobj(gcf,'Tag','CELL_bandpass'),'value');     % bandpass
            PREF(14) = get(findobj(gcf,'Tag','CELL_ZeroOutCheckbox'),'value');           % Zero Out
            
            if str2double(get(findobj('Tag','CELL_low_edit'),'string')) > str2double(get(findobj('Tag','CELL_high_edit'),'string')) % switch slider values if lower boundary is higher than upper boundary
                temp = str2double(get(findobj('Tag','CELL_low_edit'),'string'));
                set(findobj('Tag','CELL_low_edit'),'string',str2double(get(findobj('Tag','CELL_high_edit'),'string')));
                set(findobj('Tag','CELL_high_edit'),'string',temp);
                filter_edit;
            end
            
            % save filter parameter to spiketrain:
            SPIKEZ.FILTER.f_edge=[str2double(get(findobj('Tag','CELL_low_edit'),'string')), str2double(get(findobj('Tag','CELL_high_edit'),'string'))];
            
            if (PREF(12) || PREF(13)) && PREF(14)== 0
                waitbaradd = 0.15;
            elseif PREF(14) && PREF(12) == 0 && PREF(13) == 0
                waitbaradd = 0.01275;
            elseif (PREF(14) && PREF(12) && PREF(13)== 0) || (PREF(14) && PREF(13) && PREF(12) == 0)
                waitbaradd = 0.012;
            elseif PREF(12) && PREF(13) && PREF(14)
                waitbaradd = 0.012;
            end
            
            if PREF(14)
                ZeroOutcallfunction;
            else
                h_wait = waitbar(0,'Please Wait - busy...');
            end
            
            waitbar(1); close(h_wait);
            waitbar_counter=0;
            
            if str2double(get(findobj('Tag','CELL_low_edit'),'string')) == str2double(get(findobj('Tag','CELL_high_edit'),'string')) % use notch filter if upper and lower boundary have the same value
                notchfilter;
                SPIKEZ.FILTER.Name='notchfilter';
            else
                if PREF(12)
                    f_edge = str2double(get(findobj('Tag','CELL_high_edit'),'string'));
                    lowerBoundary = str2double(get(findobj('Tag','CELL_low_edit'),'string'));
                    flag_waitbar = 1;
                    [RAW,filterName,f_edge] = bandstop(RAW,f_edge,SaRa,HDrawdata,flag_waitbar,stimulidata,lowerBoundary);
                    SPIKEZ.FILTER.Name = filterName;
                    SPIKEZ.FILTER.f_edge = f_edge;
                end
                
                if PREF(13)
                    %                RAW.M = bandpass(RAW);
                    bandpass;
                    SPIKEZ.FILTER.Name='bandpass';
                end
            end
            
            
            
            if stimulidata
                figure (mainWindow);
                set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Enable','on');
                set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','on');
                set(findobj(gcf,'Tag','CELL_ShowZeroOutExample'),'Enable','on');
            else
                BEG = 0;
                END = 0;
            end
            redrawdecide; % shiva%
            
            isAlreadyFiltered = true;
        
        else
            msgbox('Signals are already filtered!')
        end
        
    end

% --- Zero Els - Popup-Menu (CN)---------------------------------------
    function ELnullenCallback(source,event) %#ok<INUSD>
        allorone = 0;
        fh = figure('Units','Pixels','Position',[350 400 300 280],'Name','select electrodes','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 155 265 100],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'String','the signal of the selected electrodes is clear for the entire recording time. More than one electrode have to be separated by space.');
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 120 80 20],'HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'Tag','CELL_electrodeLabel','String','electrode');
        uicontrol('Parent',fh,'style','edit','units','Pixels','position', [20 100 260 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','CELL_electrode','string','');
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[175 20 110 50],'String','apply','ToolTipString','clears the signals of selected electrodes now','CallBack',@ELnullencallfunction);
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[20 20 110 50],'String','all or none','ToolTipString','clears the signals of selected electrodes now','CallBack',@Allornonecallfunction);
    end

% --- Read Zero Els (CN)-----------------------------------------------
    function ELnullencallfunction(source,event) %#ok<INUSD>
        correctcheck = 1;
        EL_Auswahl = get(findobj(gcf,'Tag','CELL_electrode'),'string');
        ELEKTRODEN = strread(EL_Auswahl) ;
        for n = 1:length(ELEKTRODEN)
            i = find(EL_NUMS==ELEKTRODEN(n)); %#ok
            if isempty(i)
                correctcheck = 0; %#ok
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                uiwait;
                return
            end
        end
        if correctcheck == 1
            close(gcbf)
            Elnullenfunction;
        end
    end

% --- Read Zero Els 2 (CN)---------------------------------------------
    function Allornonecallfunction(source,event) %#ok<INUSD>
        if allorone == 0
            set(findobj(gcf,'Tag','CELL_electrode'),'string','12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87');
            allorone = 1;
        elseif allorone == 1
            set(findobj(gcf,'Tag','CELL_electrode'),'string','');
            allorone = 0;
        end
    end

% --- Zero Els (CN)----------------------------------------------------
    function Elnullenfunction(source,event) %#ok<INUSD>
        if rawcheck == 1
            for n = 1:length(ELEKTRODEN)
                i = find(EL_NUMS==ELEKTRODEN(n));
                RAW.M(:,i)=0;  %#ok
            end
        elseif spiketraincheck == 1
            for n = 1:length(ELEKTRODEN)
                i = find(EL_NUMS==ELEKTRODEN(n));
                SPIKES(:,i)=0;
                BURSTS.BEG(:,i)=0;
            end
        end
        redrawdecide
    end

% --- Invert electrodes pop up menu (AD)-------------------------------
    function invertButtonCallback(source,event) %#ok<INUSD>
        allorone = 0;
        fh2 = figure('Units','Pixels','Position',[350 400 300 280],'Name','select electrodes','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');
        uicontrol('Parent',fh2,'style','text','units','Pixels','position', [20 155 265 100],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'String','the signal of the selected electrodes is inverted for the entire recording time. More than one electrode have to be separated be space.');
        uicontrol('Parent',fh2,'style','text','units','Pixels','position', [20 120 80 20],'HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'Tag','CELL_electrodeLabel','String','electrode');
        uicontrol('Parent',fh2,'style','edit','units','Pixels','position', [20 100 260 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','CELL_electrode','string',EL_invert_Auswahl);
        uicontrol(fh2,'Style','PushButton','Units','Pixels','Position',[175 20 110 50],'String','apply','ToolTipString','clears the signals of selected electrodes now','CallBack',@ELinvertcallfunction);
        uicontrol(fh2,'Style','PushButton','Units','Pixels','Position',[20 20 110 50],'String','all or none','ToolTipString','clears the signals of selected electrodes now','CallBack',@Allornonecallfunction);
    end

% --- Read Invert electrodes (AD)--------------------------------------
    function ELinvertcallfunction(source,event) %#ok<INUSD>
        correctcheck = 1;
        EL_invert_Auswahl = get(findobj(gcf,'Tag','CELL_electrode'),'string');
        INV_ELEKTRODEN = textscan(EL_invert_Auswahl);
        
        for n = 1:length(INV_ELEKTRODEN)
            i = find(EL_NUMS==INV_ELEKTRODEN(n)); %#ok
            if isempty(i)
                correctcheck = 0; %#ok
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                uiwait;
                return
            end
        end
        if correctcheck == 1
            close(gcbf)
            Elinvertfunction;
        end
    end

% --- Invert electrodes (AD)-------------------------------------------
    function Elinvertfunction(source,event) %#ok<INUSD>
        for n = 1:length(INV_ELEKTRODEN)
            i = find(EL_NUMS==INV_ELEKTRODEN(n));
            
            if rawcheck == 1
                RAW.M(:,i)=RAW.M(:,i)*(-1);
            end
        end
        redrawdecide;
    end

% --- smooth electrode signal -----------------------------------------
    function smoothButtonCallback(~,~)
        allorone = 0;
        fh3 = figure('Units','Pixels','Position',[350 400 300 280],'Name','select electrodes','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');
        uicontrol('Parent',fh3,'style','text','units','Pixels','position', [20 155 265 100],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'String','the signal of the selected electrodes is smoothed for the entire recording time. More than one electrode have to be separated be space.');
        uicontrol('Parent',fh3,'style','text','units','Pixels','position', [20 120 80 20],'HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'Tag','CELL_electrodeLabel','String','electrode');
        uicontrol('Parent',fh3,'style','edit','units','Pixels','position', [20 100 260 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','CELL_electrode','string','');
        uicontrol(fh3,'Style','PushButton','Units','Pixels','Position',[175 10 110 50],'String','apply','ToolTipString','clears the signals of selected electrodes now','CallBack',@ELsmoothcallfunction);
        uicontrol(fh3,'Style','PushButton','Units','Pixels','Position',[20 10 110 50],'String','all or none','ToolTipString','clears the signals of selected electrodes now','CallBack',@Allornonecallfunction);
        uicontrol('Parent',fh3,'Style', 'text','Position', [20 65 90 21],'HorizontalAlignment','left','String','Smoothing Nr.:','Enable','on','FontSize',9,'BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',fh3,'Units','Pixels','Position', [110 68 20 21],'Tag','smooth_Nr','HorizontalAlignment','right','FontSize',8,'Enable','on','Value',1,'String',1,'Style','edit');
    end

% --- smooth electrode signal -----------------------------------------
    function ELsmoothcallfunction(~,~)
        
        correctcheck = 1;
        EL_smooth_choice = get(findobj(gcf,'Tag','CELL_electrode'),'string');
        Smooth_electrodes = textscan(EL_smooth_choice);
        
        for n = 1:length(Smooth_electrodes)
            i = find(EL_NUMS==Smooth_electrodes(n)); %#ok
            if isempty(i)
                correctcheck = 0; %#ok
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                uiwait;
                return
            end
        end
        if correctcheck == 1
            close(gcbf)
            Elsmoothfunction(Smooth_electrodes);
        end
        
    end

% --- El smoothing (AD)------------------------------------------------
    function Elsmoothfunction(Smooth_electrodes,event) %#ok<INUSD>
        smooth_Nr = str2double(get(findobj(gcf,'Tag','smooth_Nr'),'string'));
        for n = 1:length(Smooth_electrodes)
            i = find(EL_NUMS==Smooth_electrodes(n));
            if rawcheck == 1
                for ii = 1:smooth_Nr
                    RAW.M(:,i)= smooth(RAW.M(:,i));
                end
            end
        end
        redrawdecide;
    end

% --- preprocessing empty ---------------------------------------------
    function partClearCallback(~,~)
        
        t_1 = str2num(cell2mat(inputdlg('Delete raw signal on all electrodes between t1 and t2. Enter t1 in seconds: ')));
        t_2 = str2num(cell2mat(inputdlg('Delete raw signal on all electrodes between t1 and t2. Enter t2 in seconds: ')));
        
        s_1 = int32(t_1*SaRa);
        s_2 = int32(t_2*SaRa);
        
        RAW.M(s_1:s_2,:)=0;
        
        redrawdecide;
        
    end

% --- load original data (MG)-------------------------------------------
    function unfilterButtonCallback(~,~)
        clear BEGEND;
        waitbar_counter = 0;
        stimulidata     = false;
        cellselect      = 1;
        Nr_SI_EVENTS    = 0;
        Mean_SIB        = 0;
        Mean_SNR_dB     = 0;
        MBDae           = 0;
        STDburstae      = 0;
        aeIBImean       = 0;
        aeIBIstd        = 0;
        BURSTS.BEG          = 0;
        SI_EVENTS       = 0;
        
        if rawcheck ==1
            spikedata       = false;
            SPIKES          = 0;
            STIMULI_1       = 0;
            STIMULI_2       = 0;
            BEGEND          = 0;
            BEG             = 0;
            END             = 0;
            set(findobj(gcf,'Parent',t4,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t5,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_Autocorrelation'),'Enable','on');
            
            
            %M = M_OR;
            msgbox('This Dr. Cell Version does not have a copy of the orignial Signal to speed up the process. If this function is necesarry please uncomment "M_OR" in sourcecode','Dr.CELL´s hint','help');
            uiwait;
        elseif spiketraincheck == 1
            SPIKES = SPIKES_OR;
            set(findobj(gcf,'Parent',t3,'Enable','off'),'Enable','on');
            uicontrol('Parent',t3,'Units','pixels','Position',[120 62 30 20],'style','edit','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','5','Tag','STD_noisewindow');
            set(findobj(gcf,'Tag','CELL_DefaultBox'),'Enable','on');
            set(findobj(gcf,'Parent',radiogroup2),'Enable','on');
            set(findobj(gcf,'Parent',radiogroup3),'Enable','on');
            set(findobj(gcf,'Tag','Manual_threshold'),'Enable','on')
            set(findobj(gcf,'Tag','CELL_sensitivityBoxtext'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_sensitivityBox'),'Enable','off');
            set(findobj(gcf,'Parent',radiogroup2),'Enable','off');
            set(findobj(gcf,'Parent',radiogroup3),'Enable','off');
            set(findobj(gcf,'Tag','Manual_threshold'),'Enable','off')
            set(findobj(gcf,'Tag','time_start'),'Enable','off');
            set(findobj(gcf,'Tag','time_end'),'Enable','off');
            set(findobj(gcf,'Tag','time_start'),'Enable','off');
            set(findobj(gcf,'Tag','time_end'),'Enable','off');
            set(findobj(gcf,'Parent',t4,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t5,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t6,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showSpikesCheckbox'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');
        end
        redrawdecide;
    end





%functions - Tab Threshold
%----------------------------------------------------------------------

% --- HelpThreshold Button - Information about Threshold (CN)-----
    function HelpThresholdFunction(source,event) %#ok
        Threshinfo = figure('color',[1 1 1],'Position',[150 75 700 600],'NumberTitle','off','toolbar','none','Name','Threshold definition');
        uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 690 590],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Spike detection');
        uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 690 570],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','The spike detection algorithm works in four steps, which are summarized here and the first steps explained in detail below: i. A time frame of two seconds on each electrode containing only pure noise is detected. ii.	From this frame the root mean square (rms) value and the standard deviation are calculated. iii.	These values are then multiplied with a negative factor. As a default value a multiple of the rms is used as a threshold, alternatively a multiple of the standard deviation can be chosen instead. iv.	The absolute minimum of every voltage peak that is lower than the threshold is saved as the respective spike´s timestamp.');
        
        uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 690 450],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Find base noise');
        uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 690 430],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','To detect the base noise level, a time window is shifted over the signal of each channel searching for spike-free periods. The size of this window is set to 50 ms as a default value but can be adjusted by the user as whished. The detection of spike free windows is achieved by fitting the signal histogram with a Gaussian distribution, typical for white noise. A low standard deviation (equal or lower than a value defined by the user and set as default to 5) of this Gaussian distribution is interpreted as pure, spike-free noise. In this case the noise data is saved in a separate array and the window is shifted forward by the window size. If the standard deviation is higher than the defined value (i.e. a spike is present in that particular interval) the window is only shifted by half the window size and the condition is checked again. This process is repeated until 2 seconds of spike free signal are identified. Optionally the user can define the timeframe to be used for calculating the rms value or standard deviation of the noise manually and can thus also use the entire recorded signal for further processing.');
        
    end

% --- Threshold calculation auto or manu (CN)--------------------------
    function handler2(~,event)
        t = get(event.NewValue,'Tag');
        switch(t)
            case 'thresh_auto'                                         % Auto
                set(findobj(gcf,'Tag','text_1'),'enable','off');
                set(findobj(gcf,'Tag','time_start'),'String','-','enable','off');
                set(findobj(gcf,'Tag','text_2'),'enable','off');
                set(findobj(gcf,'Tag','time_end'),'String','-','enable','off');
                set(findobj(gcf,'Tag','text_3'),'enable','off');
                auto = true;
            case 'thresh_manu'                                          % Manu
                set(findobj(gcf,'Tag','text_1'),'enable','on');
                set(findobj(gcf,'Tag','time_start'),'String','0','enable','on');
                set(findobj(gcf,'Tag','text_2'),'enable','on');
                set(findobj(gcf,'Tag','time_end'),'String',rec_dur_string,'enable','on');
                set(findobj(gcf,'Tag','text_3'),'enable','on');
                auto = false;
        end
    end

% --- Calculate Threshold sigma or rms(CN)-----------------------------
    function handler3(~,event)
        t = get(event.NewValue,'Tag');
        switch(t)
            case 'thresh_rms'                                         % rms
                threshrmsdecide = true;
            case 'thresh_sigma'                                         % sigma
                threshrmsdecide = false;
        end
    end

% --- positive Threshold on/off (MC)---------------------------------------------

    function activatePosTh(source,event)
        if get(findobj(gcf,'Tag','posThCheckbox'),'Value')==1
            set(findobj(gcf,'Tag','CELL_sensitivityBox_pos'),'enable','on');
        else
            set(findobj(gcf,'Tag','CELL_sensitivityBox_pos'),'enable','off');
        end
    end

% --- Calculate Button - Calculate Threshold (CN)----------------------
    function CalculateThreshold(~,~)
        
        thresholddata = false;
        
        % fill vector PREF (old code)
        PREF(1) = str2double(get(findobj(gcf,'Tag','CELL_sensitivityBox'),'string')); % Threshold
        ST=str2double(get(findobj(gcf,'Tag','STD_noisewindow'),'string'));
        PREF(15) =ST(1);
        % PREF(15) = str2double(get(findobj(gcf,'Tag','STD_noisewindow'),'string'));              %get value for STD to find spike-free windows
        PREF(16) = str2double(get(findobj(gcf,'Tag','Size_noisewindow'),'string'))/1000;       %get windowsize to find spike-free windows
        PREF(17) = str2double(get(findobj(gcf,'Tag','CELL_sensitivityBox_pos'),'string'));       %get factor for positive threshold
        
        Std_noisewindow=PREF(15);
        Size_noisewindow=PREF(16);
        Multiplier_neg=PREF(1);
        Multiplier_pos=PREF(17);
        win_beg=PREF(2);
        win_end=PREF(3);
        
        % call function to calculate threshold
        tmp = get(findobj(Window,'Tag','negThCheckbox'),'Value');
        SPIKEZ.neg.flag = tmp(1); % necessary if more than one instance of DrCell is opended (MC)
        tmp = get(findobj(Window,'Tag','posThCheckbox'),'Value');
        SPIKEZ.pos.flag = tmp(1); % same as above
        flag_simple = get(findobj(Window,'Tag','Checkbox_simpleThreshold'),'Value');
        flag_waitbar=1;
        [THRESHOLDS,THRESHOLDS_pos,ELEC_CHECK,SPIKEZ,COL_RMS,COL_SDT]=calculateThreshold(RAW,SPIKEZ,Multiplier_neg,Multiplier_pos,Std_noisewindow,Size_noisewindow,HDrawdata,flag_waitbar,auto,win_beg,win_end,threshrmsdecide,flag_simple);
        
        % calc SNR
        SPIKEZ=calc_snr_fast(SPIKEZ, COL_RMS, COL_SDT);
        
        % Settings
        if SPIKEZ.neg.flag || SPIKEZ.pos.flag
            thresholddata = true;
        end
        set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Value',1,'Enable','on')
        set(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'String','');
        set(findobj(gcf,'Tag','Elsel_Thresh'),'String','');
        
        
        
        % Call function to calculate a dynamic threshold if checkbox is
        % active
        if get(findobj(Window,'Tag','dynThCheckbox'),'Value')
            DynamicThreshold; % calculate dynamic threshold
        else
            SPIKEZ.PREF.dyn_TH=0;
        end
        redrawdecide;
    end

% --- Calculate dynamic Threshold (MC)----------------------
    function DynamicThreshold(~,~)
        
        
        h_wait = waitbar(.05,'Please wait - Dynamic Thresholds are calculated...');
        disp ('Calculating Dynamic Threshold...');
        
        % lowpass filter the raw signal to get low frequency parts during a
        % networkburst
        f_edge = 3; % 3 Hz
        [z,p,k] = cheby2(3,20, f_edge*2/RAW.SaRa,'low'); %cheby2(N,R,Wst,'high'); N=OrderOfFilter, R=RippleDecibel, Wst=EdgeFrequency:0...1.0 (1=half of SampleRate), 'high'=highpass,'low''stop'
        [sos,g] = zp2sos(z,p,k);			% Convert to SOS form
        Hd = dfilt.df2tsos(sos,g);
        M_lowpass = filter(Hd,RAW.M);
        delay=1000; % lowpass filtered signal is appr. 100 ms delayed, so shift signal by 1000 samples
        M_lowpass(1:end-delay,:)=M_lowpass(1+delay:end,:);
        
        
        waitbar(0.8,h_wait);
        
        % expand variables
        step=1000; % only use every 1000th value to reduce size of Th
        for n=1:size(SPIKEZ.neg.THRESHOLDS.Th,2)
            SPIKEZ.neg.THRESHOLDS.Th(1:length(T)/step,n)=SPIKEZ.neg.THRESHOLDS.Th(1,n);
        end
        for n=1:size(SPIKEZ.pos.THRESHOLDS.Th,2)
            SPIKEZ.pos.THRESHOLDS.Th(1:length(T)/step,n)=SPIKEZ.pos.THRESHOLDS.Th(1,n);
        end
        
        
        
        %negative thresholds
        step=1000; % only use every 1000th value to reduce size of Th
        for n=1:size(SPIKEZ.neg.THRESHOLDS.Th,2)
            SPIKEZ.neg.THRESHOLDS.Th(:,n)=SPIKEZ.neg.THRESHOLDS.Th(:,n)+M_lowpass(1:step:end,n);
        end
        
        % positive thresholds
        flag_positive = get(findobj(Window,'Tag','posThCheckbox'),'Value');
        if flag_positive == 1
            for n=1:size(SPIKEZ.pos.THRESHOLDS.Th,2)
                SPIKEZ.pos.THRESHOLDS.Th(:,n)=SPIKEZ.pos.THRESHOLDS.Th(:,n)+M_lowpass(1:step:end,n);
            end
        end % end THRESHOLDS_pos
        
        SPIKEZ.PREF.dyn_TH=1;
        
        waitbar(1,h_wait,'Done.'), close(h_wait);
        
    end

% --- EL Minus --------------------------------------------------

    function Elminus(~,~)
        EL_A = get(findobj(gcf,'Tag','Elsel_Thresh'),'string');
        CurEl = textscan(EL_A);
        i = find(EL_NUMS==CurEl);
        if i > 1
            i = i-1;
            set(findobj(gcf,'Tag','Elsel_Thresh'),'string',num2str(EL_NUMS(i)));
        end
    end

% --- EL Plus --------------------------------------------------

    function Elplus(~,~)
        EL_A = get(findobj(gcf,'Tag','Elsel_Thresh'),'string');
        CurEl = textscan(EL_A);
        i = find(EL_NUMS==CurEl);
        if i < 60
            i = i+1;
            set(findobj(gcf,'Tag','Elsel_Thresh'),'string',num2str(EL_NUMS(i)));
        end
    end

% --- Show Threshold --------------------------------------------------
    function ElgetThresholdfunction(source,event) %#ok<INUSD>
        EL_Auswahl = get(findobj(gcf,'Tag','Elsel_Thresh'),'string');
        CurElec = textscan(EL_Auswahl);
        
        if rawcheck == 1
            i = find(EL_NUMS==CurElec);
            if isempty(i)
                msgbox('This is not a recorded electrode!','Dr.CELL´s hint','help');
                uiwait;
                return
            end
            set(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'String',SPIKEZ.neg.THRESHOLDS.Th(1,i));
            
        elseif spiketraincheck == 1
            msgbox('Error','Dr.CELL´s hint','help');
            uiwait;
            return
        end
    end

% --- Set Thresholds manually -----------------------------------------
    function ELsaveThresholdfunction(source,event) %#ok<INUSD>
        flag_manual = get(findobj(gcf,'Tag','Manual_threshold'),'value');
        
        EL_Auswahl = get(findobj(gcf,'Tag','Elsel_Thresh'),'string');
        CurElec = textscan(EL_Auswahl);
        i = find(EL_NUMS==CurElec);
        if flag_manual == 1
            for n = i:1:size(EL_NUMS,2)
                if SPIKEZ.PREF.dyn_TH==0
                    SPIKEZ.neg.THRESHOLDS.Th(1,n) = str2num(get(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'string'));
                else
                    SPIKEZ.neg.THRESHOLDS.Th(:,n) = str2num(get(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'string'));
                end
            end
        else
            if SPIKEZ.PREF.dyn_TH==0
                SPIKEZ.neg.THRESHOLDS.Th(1,i) = str2num(get(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'string'));
            else
                SPIKEZ.neg.THRESHOLDS.Th(:,i) = str2num(get(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'string'));
            end
        end
        
        redrawdecide;
    end

% --- read Thresholds from a file (FS,MC)---------
    function ELgetThresholdFile(~,~)
        
        %SPIKEZ.THRESHOLDS=[];
        SPIKEZ.pos.THRESHOLDS=[];
        SPIKEZ.neg.THRESHOLDS=[];
        
        % go to path of loaded file
        %cd(path)
        
        [THfile,THpath] = uigetfile({'*.mat','MAT-files (*.mat)'},file); % MC: manual TH-File selection
        if not(iscell(THfile)) && not(ischar(THfile)) % if canceled - dont do anything
            return
        end
        
        threshold_path = [THpath, THfile];
        if exist(threshold_path,'file')
            temp = load(threshold_path);
            
            % compatible with old threshold files:
            if isfield(temp, 'THRESHOLDS')
                SPIKEZ.neg.THRESHOLDS.Th=temp.THRESHOLDS; % only use SPIKEZ.neg or SPIKEZ.pos to save threshold
                if size(SPIKEZ.neg.THRESHOLDS.Th,1)==1
                    SPIKEZ.PREF.dyn_TH=0;
                end
                if size(SPIKEZ.neg.THRESHOLDS.Th,1)>1
                    SPIKEZ.PREF.dyn_TH=1;
                end
            else
                SPIKEZ.neg.THRESHOLDS.Th=0;
            end
            if isfield(temp, 'CLEL')
                CLEL = temp.CLEL;
                SPIKEZ.PREF.CLEL=CLEL;
            end
            if isfield(temp, 'Invert_M')
                Invert_M = temp.Invert_M;
                SPIKEZ.PREF.Invert_M=Invert_M;
            end
            if isfield(temp,'THRESHOLDS_pos')
                SPIKEZ.pos.THRESHOLDS.Th=temp.THRESHOLDS_pos;
            else
                SPIKEZ.pos.THRESHOLDS.Th=0;
            end
            if isfield(temp,'PREF')
                PREF=temp.PREF;
                SPIKEZ.neg.THRESHOLDS.Multiplier=PREF(1);
                SPIKEZ.neg.THRESHOLDS.Std_noisewindow=PREF(15);
                SPIKEZ.neg.THRESHOLDS.Size_noisewindow=PREF(16);
            else
                SPIKEZ.neg.THRESHOLDS.Multiplier=NaN;
                SPIKEZ.neg.THRESHOLDS.Std_noisewindow=NaN;
                SPIKEZ.neg.THRESHOLDS.Size_noisewindow=NaN;
            end
            
            
            
            
            % loading threshold from spiketrain-file (new) (MC):
            if isfield(temp, 'temp')
                clear temp
                load(threshold_path)
                
                % new parameter:
                SPIKEZ.neg.THRESHOLDS = temp.SPIKEZ.neg.THRESHOLDS;
                SPIKEZ.pos.THRESHOLDS = temp.SPIKEZ.pos.THRESHOLDS;
                SPIKEZ.FILTER = temp.SPIKEZ.FILTER;
                SPIKEZ.PREF.dyn_TH= temp.SPIKEZ.PREF.dyn_TH;
                
                if isfield(temp.SPIKEZ,'THRESHOLDS') % compatible with old SPIKEZ-Struct
                    SPIKEZ.PREF.CLEL = temp.SPIKEZ.THRESHOLDS.CLEL;
                    SPIKEZ.PREF.Invert_M = temp.SPIKEZ.THRESHOLDS.Invert_M;
                end
                if isfield(temp.SPIKEZ.PREF,'CLEL') % compatible with new SPIKEZ-Struct
                    SPIKEZ.PREF.CLEL = temp.SPIKEZ.PREF.CLEL;
                    CLEL = SPIKEZ.PREF.CLEL; % old variable
                end
                if isfield(temp.SPIKEZ.PREF,'Invert_M')
                    SPIKEZ.PREF.Invert_M = temp.SPIKEZ.PREF.Invert_M;
                    Invert_M = SPIKEZ.PREF.Invert_M; % old variable
                end
            end
            
            clear temp;
            
            set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Value',1,'Enable','on')
            set(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'String','');
            set(findobj(gcf,'Tag','Elsel_Thresh'),'String','');
            
            thresholddata = true;
            
            if CLEL ~= 0
                for i = 1:size(CLEL,2)
                    RAW.M(:,CLEL(i))=0;
                    if spiketraincheck == 1
                        SPIKES(:,CLEL(i))=0;
                        BURSTS.BEG(:,CLEL(i))=0;
                    end
                end
            end
            
            for i = 1:size(Invert_M,2)
                RAW.M(:,Invert_M(i))=RAW.M(:,Invert_M(i))*(-1);
            end
            redrawdecide;
        else
            msgbox('Threshold file does not exist','Error','error')
        end
    end

% --- safe Thresholds in a file (FS)-------
    function ELsaveThresholdFile(~,~)
        
        THRESHOLDS=zeros(1,size(SPIKEZ.neg.THRESHOLDS.Th,2));
        THRESHOLDS_pos=zeros(1,size(SPIKEZ.pos.THRESHOLDS.Th,2));
        
        aktDat = strcat(full_path(1:max(strfind(full_path,'\'))),file);
        if exist(strcat(aktDat(1:length(aktDat)-4),'_TH.mat'),'file')
            
            % Construct a questdlg with two options
            choice = questdlg('File already exists. Would you like to replace it?', ...
                'Save File', ...
                'Cancel','Replace','Replace');
            % Handle response
            switch choice
                case 'Cancel'
                case 'Replace'
                    n = 1;
                    CLEL = 0;
                    for i = 1:1:size(RAW.M,2)
                        if sum(RAW.M(:,i)) == 0
                            CLEL(n) = i;
                            n = n+1;
                        end
                    end
                    
                    % Save structure elements in variable so it can be
                    % saved
                    if SPIKEZ.PREF.dyn_TH==1 % if dynamic threshold save all points
                        THRESHOLDS=SPIKEZ.neg.THRESHOLDS.Th;
                        THRESHOLDS_pos=SPIKEZ.pos.THRESHOLDS.Th;
                    else
                        THRESHOLDS(1,:)=SPIKEZ.neg.THRESHOLDS.Th(1,:);
                        THRESHOLDS_pos(1,:)=SPIKEZ.pos.THRESHOLDS.Th(1,:);
                    end
                    
                    save(strcat(aktDat(1:length(aktDat)-4),'_TH.mat'), 'THRESHOLDS','CLEL','Invert_M','THRESHOLDS_pos','PREF');
            end
        else
            n = 1;
            CLEL = 0;
            for i = 1:1:size(RAW.M,2)
                if sum(RAW.M(:,i)) == 0
                    CLEL(n) = i;
                    n = n+1;
                end
            end
            
            % Save structure elements in variable so it can be
            % saved
            if SPIKEZ.PREF.dyn_TH==1 % if dynamic threshold save all points
                THRESHOLDS=SPIKEZ.neg.THRESHOLDS.Th;
                THRESHOLDS_pos=SPIKEZ.pos.THRESHOLDS.Th;
            else
                THRESHOLDS(1,:)=SPIKEZ.neg.THRESHOLDS.Th(1,:);
                THRESHOLDS_pos(1,:)=SPIKEZ.pos.THRESHOLDS.Th(1,:);
            end
            
            save(strcat(aktDat(1:length(aktDat)-4),'_TH.mat'), 'THRESHOLDS','CLEL','Invert_M','THRESHOLDS_pos','PREF','COL_SDT', 'COL_RMS');
        end
        
        clear THRESHOLDS THRESHOLDS_pos
    end


% --- Threshold ALLER Elektroden per Hand einstellen (Andy)---------------
    function Thresholdforall(source,event) %#ok<INUSD>
        i = size(SPIKEZ.neg.THRESHOLDS.Th,2);
        SPIKEZ.neg.THRESHOLDS.Th(1,1:i) = str2num(get(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'string')); %#ok
        redrawdecide;
    end


%functions - Tab Analysis
%----------------------------------------------------------------------

% --- Default-values of analysis (CN&MG)------------------------
    function handler(source,event) %#ok
        defaultset = get(defaulthandle,'value');   % set y scale
        switch defaultset
            
            
            case 1, %Burstdefinition Baker - >= 3 Spikes max 100ms apart
                set(findobj(gcf,'Tag','t_ref'),'String','0','enable','on');
                set(findobj(gcf,'Tag','SIB_min'),'String','3','enable','on');
                set(findobj(gcf,'Tag','ISI_max'),'String','100','enable','on');
                %set(findobj(gcf,'Tag','t_nn'),'String','100','enable','on');
                set(findobj(gcf,'Tag','IBI_max'),'String','0','enable','on');
                BURSTS.name='baker';
                cellselect = 1;
                
            case 2, %Burstdefinition Kapucu - self adaptable algorithm for human (hES) neurons
                set(findobj(gcf,'Tag','t_ref'),'String','0');
                set(findobj(gcf,'Tag','SIB_min'),'String','3','enable','off');
                set(findobj(gcf,'Tag','ISI_max'),'String','100','enable','off');
                %set(findobj(gcf,'Tag','t_nn'),'String','var','enable','on');
                set(findobj(gcf,'Tag','IBI_max'),'String','0','enable','off');
                BURSTS.name='kapucu';
                cellselect = 2;
                
            case 3, %Burstdefinition Selinger - self adaptable algorithm
                set(findobj(gcf,'Tag','t_ref'),'String','0');
                set(findobj(gcf,'Tag','SIB_min'),'String','3','enable','off');
                set(findobj(gcf,'Tag','ISI_max'),'String','100','enable','off');
                %set(findobj(gcf,'Tag','t_nn'),'String','var','enable','on');
                set(findobj(gcf,'Tag','IBI_max'),'String','0','enable','off');
                BURSTS.name='selinger';
                cellselect = 3;
                
            case 4 %Burstdefinition Wagenaar4
                set(findobj(gcf,'Tag','t_ref'),'String','0');
                set(findobj(gcf,'Tag','SIB_min'),'String','4','enable','off');
                set(findobj(gcf,'Tag','ISI_max'),'String','0','enable','off');
                %set(findobj(gcf,'Tag','t_nn'),'String','0','enable','on');
                set(findobj(gcf,'Tag','IBI_max'),'String','0','enable','on');
                BURSTS.name='wagenaar4';
                cellselect = 4;
                
            case 5 %Burstdefinition Wagenaar3
                set(findobj(gcf,'Tag','t_ref'),'String','0');
                set(findobj(gcf,'Tag','SIB_min'),'String','3','enable','off');
                set(findobj(gcf,'Tag','ISI_max'),'String','0','enable','off');
                %set(findobj(gcf,'Tag','t_nn'),'String','0','enable','on');
                set(findobj(gcf,'Tag','IBI_max'),'String','0','enable','on');
                BURSTS.name='wagenaar3';
                cellselect = 5;
                
            case 6, %Burstdefinition 16Hz
                set(findobj(gcf,'Tag','t_ref'),'String','0','enable','off');
                set(findobj(gcf,'Tag','SIB_min'),'String','8','enable','on');
                set(findobj(gcf,'Tag','ISI_max'),'String','500','enable','on');
                %set(findobj(gcf,'Tag','t_nn'),'String','20','enable','off');
                set(findobj(gcf,'Tag','IBI_max'),'String','0','enable','off');
                BURSTS.name='16Hz';
                cellselect = 0;
                
            case 7, %Burstdefinition Cocatre
                set(findobj(gcf,'Tag','t_ref'),'String','0','enable','off');
                set(findobj(gcf,'Tag','SIB_min'),'String','3','enable','off');
                set(findobj(gcf,'Tag','ISI_max'),'String','-','enable','off');
                %set(findobj(gcf,'Tag','t_nn'),'String','20','enable','off');
                set(findobj(gcf,'Tag','IBI_max'),'String','0','enable','off');
                BURSTS.name='cocatre';
                cellselect = 0;
                
        end
    end

% --- HelpBurst Button - Information about Burstdefinitionens (CN)-----
    function HelpBurstFunction(source,event) %#ok
        Burstinfo = figure('color',[1 1 1],'Position',[150 75 700 600],'NumberTitle','off','toolbar','none','Name','Burst definition');
        
        % baker-info
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 590],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Baker et al.');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 570],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as at least 3 Spikes with a maximum interspikeinterval (ISI_max) between all the Spikes of 100 ms. There is no idle time between two bursts. Note: To find the best ISI_max value for your data, use the button "ISI-Histogram".');
        
        % kapucu-info
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 520],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Kapucu et al.');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 500],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','This Algorithm is specially designed for neurons differentiated from human stem cells (hES). A Burst is defined like in Baker et al. but with a variable ISI_max-value. ISI_max is calculated automatically for every electrode by means of the skewness of the CMA of the ISI-Histogram.');
        
        % selinger-info
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 450],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Selinger et al.');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 430],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined like in Baker et al. but with a variable ISI_max-value. ISI_max is calculated automatically for every electrode by means of the logarithmic ISI-Histogram (minimum between two peaks is used as ISI_max value). Here, the ISI_max value is restricted to a minimum value of 100 ms.');
        
        % wagenaar3-info
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 380],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Wagenaar et al. [3]');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 360],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as a core of at least 3 Spikes with a maximum idle time between those Spikes of 100 ms or 1/(4*f), which ever is smaller (f is the mean spike frequency). After a core is found, Spikes with a maximum time difference of 1/(3*f) or 200 ms (which ever is smaller) before or after the core are added to the burst. There is no idle time between two bursts.');
        
        % wagenaar4-info
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 310],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Wagenaar et al. [4]');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 290],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as a core of at least 4 Spikes with a maximum idle time between those Spikes of 100 ms or 1/(4*f), which ever is smaller (f is the mean spike frequency). After a core is found, Spikes with a maximum time difference of 1/(3*f) or 200 ms (which ever is smaller) before or after the core are added to the burst. There is no idle time between two bursts.');
        
        % 16Hz-info
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 240],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','16 Hz burstdefinition');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 220],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','Burst is defined if spikerate increases by 16 Hz (window-size: 500 ms). In other words: 8 spikes per 500 ms define a burst. This definition can be changed by choosing new values for "min Spikes per Burst" and another window-size (use field "max. interspikeinterval in ms").');
        
    end


% --- ISI-Histogram (MC) ----------------------------------------------
    function ISIhistogramButtonCallback(~,~)
        
        % find El with max. number of spikes
        Max=0;
        m=1; % choosen electrode
        for k=1:size(SPIKES,2)
            numberOfSpikes=length(nonzeros(SPIKES(:,k)));
            if numberOfSpikes>Max
                Max=numberOfSpikes;
                m=k;
            end
        end
        
        el=EL_NUMS(m); % convert nth electrode to MEA-position
        
        ISIhist = figure('Position',[150 50 700 660],'Name','ISI-Histogram','NumberTitle','off');
        
        paneltop=uipanel('Parent',ISIhist,'fontweight','b','Units','normalized','Position',[.01 .8 .98 .2]);
        uicontrol('Parent',paneltop,'style','text','units','normalized','Position', [.1 .5 .7 .3],'FontSize',10, 'HorizontalAlignment','left','String','Shows ISI-histogram of selected electrode. Enter the number of an electrode or "all" for all electrodes and press "Apply..."!');
        uicontrol('Parent',paneltop,'style','edit','units','normalized','Position', [.1 .1 .3 .2],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_SelectISIhist_electrode','string',num2str(el));
        uicontrol('Parent',paneltop,'Style','PushButton','Units','normalized','Position',[.65 .1 .3 .2],'FontSize',10,'FontWeight','bold','String','Apply...','ToolTipString','Shows ISI-histogram of the selected electrode','CallBack',@ISIhistogramRedraw);
        panelbot = uipanel('Parent',ISIhist,'Units','normalized','Position',[.01 .01 .98 .78]);
        
        subplot(1,1,1,'Parent',panelbot)
        
        
        
        
        % calculate ISIs
        ISI = diff(SPIKES); % last value will be negative if it is fallowed by a zero
        ISI(ISI<0)=0; % set all negative values to zero
        
        % log ISI:
        logISI=log10(nonzeros(ISI(:,m))); % calculate ln(ISI), without zero because: ln(0)=inf
        
        % plot
        xvalues=log10(0.0001):0.1:log10(10); % xvalues for log10
        h=histogram(logISI,xvalues);
        %nbins=ceil(sqrt(length(logISI))); % number of bins is number of ISIs^0.5
        %h=histogram(logISI,nbins);
        h.Parent.XLabel.String='t /s';
        h.Parent.YLabel.String='Number of ISIs/bin';
        % change xticklabels from log(s) to s
        for i=1:size(h.Parent.XTick,2)
            temp=10.^h.Parent.XTick(i);
            XTickLabel(i)={num2str(temp)};
        end
        h.Parent.XTickLabel=XTickLabel;
        h.Parent.FontSize=10;
        h.Parent.YScale='log';
        
        
        % click on graph to get x value in ms
        [X,Y]=ginput(1);
        ISImax=(10^X)*1000;
        text(X,Y,['ISI_{max} = ' num2str(ISImax) ' ms']);
        
        
        
    end

    function ISIhistogramRedraw(source,event)
        
        % read electrode number
        EL_Select = get(findobj(gcf,'Tag','CELL_SelectISIhist_electrode'),'string');
        
        if strcmp(EL_Select,'all')
            flag_all=1;
        else
            flag_all=0;
            m = find(EL_NUMS==str2double(EL_Select), 1);
            if isempty(m)
                msgbox('Electrodes was not recorded or does not exist! Please check!','Dr.CELL´s hint','help');
                uiwait;
                return
            end
        end
        
        
        
        
        
        % delete single spikes:
        if 0
            ISI_max=0.050;
            SPIKE=SPIKES;
            SPIKEZ.bu=SPIKES;
            ISI=diff(SPIKE); % Test ISIs
            SPIKE(SPIKE==0)=NaN;
            deletedSpikes=zeros(1,60);
            for n=1:size(SPIKE,2)
                if ~isempty(nonzeros(SPIKE(:,n)))
                    for k=1:size(nonzeros(SPIKE(:,n)),1)-2
                        if SPIKE(k+1,n)-SPIKE(k,n) > ISI_max
                            if SPIKE(k+2,n)-SPIKE(k+1,n) > ISI_max
                                SPIKE(k+1,n)=NaN; % delete spike k+1 if time to pre-spike and post-spike is more than ISI_max
                                deletedSpikes(n)=deletedSpikes(n)+1;
                                %                           elseif SPIKE(k+3,n)-SPIKE(k+2,n) > ISI_max
                                %                               SPIKE(k+1,n)=NaN;
                                %                               SPIKE(k+2,n)=NaN; % delte two spikes if time to pre-spike and post-spike is more than ISI_max
                            end
                        end
                    end
                end
            end
            SPIKE=sort(SPIKE);
            SPIKE(isnan(SPIKE))=0;
            ISI2=diff(SPIKE); % test
            SPIKES=SPIKE;
        end
        
        % Return map
        if 0
            figure
            ISI=diff(SPIKE);
            ISI(ISI<0)=0;
            ISI(ISI==0)=NaN;
            ISI=log10(ISI);
            X(:,1)=ISI(1:end-1);
            X(:,2)=ISI(2:end);
            for n=1:size(ISI,2)
                hp=scatter(ISI(1:end-1,n),ISI(2:end,n),'.'); hold on
            end
            %             hp=scatter(ISI(1:end-1),ISI(2:end),'.');
            % hp.Parent.XScale='log';
            % hp.Parent.YScale='log';
            hp.Parent.XLabel.String='ISI(n)';
            hp.Parent.YLabel.String='ISI(n+1)';
            
            if 0
                % Cluster:
                options = statset('Display','final');
                gm = fitgmdist(X,2,'Options',options);
                
                hold on
                ezcontour(@(x,y)pdf(gm,[x y]),[-8 6],[-8 6]);
                hold off
                
                idx = cluster(gm,X);
                cluster1 = (idx == 1);
                cluster2 = (idx == 2);
                
                Th=10^max(X(cluster2))
                
                scatter(X(cluster1,1),X(cluster1,2),10,'r+');
                hold on
                scatter(X(cluster2,1),X(cluster2,2),10,'bo');
                hold off
                legend('Cluster 1','Cluster 2','Location','NW')
                
                % Returnmap k_th order
                if 0
                    figure
                    for k=1:size(ISI)
                        hp=plot(ISI(1:end-k),ISI(1+k:end),'.');
                        hp.Parent.XLabel.String='ISI(n)';
                        hp.Parent.YLabel.String=['ISI(n+' num2str(k) ')'];
                        pause(0.1)
                    end
                end
            end
        end
        
        
        
        % calculate ISIs
        ISI = diff(SPIKES); % last value will be negative if it is fallowed by a zero
        ISI(ISI<0)=0; % set all negative values to zero
        
        % log ISI:
        if flag_all
            SPIKES_all = sort(SPIKES(:));
            ISI= diff(SPIKES_all);
            ISI(ISI<0)=0;
            logISI=log10(nonzeros(ISI));
        else
            logISI=log10(nonzeros(ISI(:,m))); % calculate ln(ISI), without zero because: ln(0)=inf
        end
        
        
        % plot
        %figure
        %xvalues=log10(0.0001):0.1:log10(10); % xvalues for log10
        %h=histogram(logISI,xvalues);
        nbins=ceil(sqrt(length(logISI))); % number of bins is number of ISIs^0.5
        h=histogram(logISI,nbins);
        h.Normalization='count';% number of events
        Values_count=h.Values;
        % h.Normalization='pdf';% 0...1
        h.Parent.XLabel.String='t /s';
        h.Parent.YLabel.String='Number of ISIs/bin';
        h.Parent.YScale='log';
        
        % smoot histogram by median (size 3)
        if 1
            elements=h.Values;
            x=h.BinEdges(1:end-1)+h.BinWidth/2;
            for i=1:size(elements,2)
                if i==1 % first time: use first point as i-1
                    smooth(i)=median([elements(i),elements(i),elements(i+1)]);
                end
                if i==size(elements,2) % last time: use last point as i+1
                    smooth(i)=median([elements(i-1),elements(i),elements(i)]);
                end
                if i~=1 && i~=size(elements,2)
                    smooth(i)=median(elements(i-1:i+1));
                end
            end
            hold on
            plot(x,smooth,'--')
            hold off
        end
        
        % bimodal fitting:
        if 0 % under construction
            x=Values_count;
            pdf_normmixture = @(x,p,mu1,mu2,sigma1,sigma2) ...
                p*normpdf(x,mu1,sigma1) + (1-p)*normpdf(x,mu2,sigma2);
            pStart = .9;
            muStart = quantile(x,[.25 .75]);
            sigmaStart = sqrt(var(x) - .25*diff(muStart).^2);
            start = [pStart muStart sigmaStart sigmaStart];
            lb = [0 -Inf -Inf 0 0];
            ub = [1 Inf Inf Inf Inf];
            %paramEsts = mle(x, 'pdf',pdf_normmixture, 'start',start, 'lower',lb, 'upper',ub)
            statset('mlecustom')
            options = statset('MaxIter',300, 'MaxFunEvals',600);
            paramEsts = mle(x, 'pdf',pdf_normmixture, 'start',start, ...
                'lower',lb, 'upper',ub, 'options',options)
            %xgrid = linspace(1.1*min(x),1.1*max(x),200);
            xgrid=-4:0.001:1.7;
            pdfgrid = pdf_normmixture(xgrid,paramEsts(1),paramEsts(2),paramEsts(3),paramEsts(4),paramEsts(5));
            hold on
            plot(xgrid,pdfgrid,'-')
            hold off
        end
        
        
        % change xticklabels from log(s) to s
        for i=1:size(h.Parent.XTick,2)
            temp=10.^h.Parent.XTick(i);
            XTickLabel(i)={num2str(temp)};
        end
        h.Parent.XTickLabel=XTickLabel;
        h.Parent.FontSize=10;
        
        
        % click on graph to get x value in ms
        if 1
            [X,Y]=ginput(1);
            ISImax=(10^X)*1000;
            text(X,Y,['ISI_{max} = ' num2str(ISImax) ' ms']);
        end
        
    end


% --- Analyse - Button (CN&MG)-----------------------------------------
    function Analysedecide(source,event) %#ok<INUSD>
        PREF(2)= str2double(get(findobj(gcf,'Tag','time_start'),'string'));
        PREF(3) = str2double(get(findobj(gcf,'Tag','time_end'),'string'));
        PREF(4) = str2double(get(findobj(gcf,'Tag','t_ref'),'string'));           % refractory time Spike
        PREF(10) = str2double(get(findobj(gcf,'Tag','th_stim'),'string'));          % Zero Out-Threshold
        PREF(11) = str2double(get(findobj(gcf,'Tag','aftertime'),'string'));
        
        if(get(findobj(gcf,'Tag','SIB_min'),'string'))=='-'
            PREF(5) = 0;
            PREF(6) = 0;
            PREF(7) = 0;
            PREF(8) = 0;
        else
            PREF(5) = str2double(get(findobj(gcf,'Tag','SIB_min'),'string'));     % min. nr Spikes per Burst
            PREF(6) = str2double(get(findobj(gcf,'Tag','ISI_max'),'string'));         % max. time between Spike 1 and 2 in ms
            %PREF(7) = str2double(get(findobj(gcf,'Tag','t_nn'),'string'));         % max. time between other Spikes
            PREF(7)=PREF(6); % t_nn is not needed anymore, however, in case a function needs PREF(7)
            PREF(8) = str2double(get(findobj(gcf,'Tag','IBI_max'),'string'));       % min. time between 2 Bursts in ms
            if PREF(5)<3
                msgbox('A burst consists of at least 3 Spikes...','Dr.CELL�s hint','error');
                uiwait;
                PREF(5)=3;
            end
        end
        
        if spiketraincheck == 1
            Analyse;
            set(findobj(gcf,'Parent',t5),'Enable','on');
            set(findobj(gcf,'Parent',t6),'Enable','on');
            set(findobj(gcf,'Parent',t7),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'value',0,'Enable','off');
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'value',0,'Enable','off');
            set(findobj(gcf,'Tag','CELL_exportNWBButton'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_ShowZeroOutExample'),'Enable','off');
            set(findobj(gcf,'Tag','SpikeSorting'),'Enable','off');
            
        elseif rawcheck == 1
            Analyse;
        end
    end

% --- gaussian fitting of histogram (CN)-----------------------
    function [mu, sigm] = normal(x)
        if ~isvector(x)
            [n,ncols] = size(x);
        else
            n = numel(x);
            ncols = 1;
        end
        
        classX = class(x);
        sumx = sum(x);
        if n == 0
            mu = NaN(1,ncols,classX);
            sigm = NaN(1,ncols,classX);
            return
        else
            mu = sumx ./ n;
            if n > 1
                if numel(mu) == 1
                    xc = x - mu;
                else
                    xc = x - repmat(mu,[n 1]);
                end
                sigm = sqrt(sum(conj(xc).*xc) ./ (n-1));
            else
                sigm = zeros(1,ncols,classX);
            end
            return
        end
    end

% --- AnalyseButton (CN,MG,AD)---------------------------
    function Analyse(source,event) %#ok<INUSD>
        
        
        h_wait=waitbar(0.1,'Analyse...');
        
        if (get(findobj('Tag','Spike_Box'),'value')) == 1 || (get(findobj('Tag','Spike2_Box'),'value')) == 1
            NR_SPIKES=zeros(1,size(RAW.M,2));
            BURSTS.BRn=zeros(1,size(RAW.M,2));
            waitbar(.5,h_wait,'Please wait - Spikedetection in progress...')
            spikedetection_call; % detect spikes
        end
        
        if (get(findobj('Tag','Burst_Box'),'value')) == 1
            waitbar(.75,h_wait,'Please wait - Burstdetection in progress...')
            burstdetection_call; % detect bursts
        end
        
        if (get(findobj('Tag','SBE_Box'),'value')) == 1
            waitbar(.9,h_wait,'Please wait - SBE analysis in progress...')
            SBEdetection_call; % detect SBE
        end
        
        if (get(findobj('Tag','SBE_old_Box'),'value')) == 1
            waitbar(.9,h_wait,'Please wait - SBE (old) analysis in progress...')
            SBEdetection_old_call; % detect SBE_old
        end
        
        if (get(findobj('Tag','NB_Box'),'value')) == 1
            waitbar(.9,h_wait,'Please wait - Networkburst analysis in progress...')
            Networkburstdetection_call; % detect NETWORKBURSTS
        end
        
        
        waitbar(1,h_wait,'Done.'), close(h_wait);
        
        set(findobj(gcf,'Parent',t5),'Enable','on');
        set(findobj(gcf,'Parent',t6),'Enable','on');
        set(findobj(gcf,'Parent',t7),'Enable','on');
        
        set(findobj(gcf,'Tag','CELL_exportNWBButton'),'Enable','off');
        
        if stimulidata ==0
            set(findobj(gcf,'Tag','CELL_ShowZeroOutExample'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Enable','off');
        end
        
        
        % redraw:
        redrawdecide;
    end

% --- Spikedetection_call (MC)
    function spikedetection_call()
        
        disp('Start spikedetection')
        
        
        % init structure SPIKEZ
        SPIKEZ=initSPIKEZ(SPIKEZ,RAW);
        
        % detect negative and/or positve spikes?
        h=findobj('parent',mainWindow);
        SPIKEZ.neg.flag = get(findobj(h,'Tag','negSpike_Box'),'value');
        SPIKEZ.pos.flag = get(findobj(h,'Tag','posSpike_Box'),'value');
        
        SPIKEZ.PREF.flag_isHDMEAmode = HDrawdata;
        SPIKEZ.PREF.rec_dur = rec_dur;
        
        % save idleTime
        SPIKEZ.PREF.idleTime=PREF(4)/1000; % from ms to s
        
        % call spikedetection function
        if (get(findobj('Tag','Spike2_Box'),'value')) == 0 % if unchecked use normal spikedetection
            [SPIKEZ]=spikedetection(RAW,SPIKEZ); % detect spikes
        else
            [SPIKEZ]=combinedSpikeDetection(RAW,SPIKEZ); % spikedetection according to Lieb et al. (2017)
        end
        
        % apply refractory time (aka "idle time") and get amplitude values
        [SPIKEZ]=applyRefractoryAndGetAmplitudes(RAW,SPIKEZ);
        
        % calculate spike features like mean firing rate
        SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
        SPIKEZ=calc_snr_fast(SPIKEZ, COL_RMS, COL_SDT); % calculate signal to noise ratio
        
        %         % apply Refractory time
        %         SPIKEZ.TS=idle_time(SPIKEZ.TS,SPIKEZ.PREF.idleTime);
        %         SPIKEZ.neg.TS=idle_time(SPIKEZ.neg.TS,SPIKEZ.PREF.idleTime);
        %         SPIKEZ.pos.TS=idle_time(SPIKEZ.pos.TS,SPIKEZ.PREF.idleTime);
        %
        %         % delete all rows that only contain zeros:
        %         SPIKEZ.TS=SPIKEZ.TS(any(SPIKEZ.TS,2),:);
        %         SPIKEZ.neg.TS=SPIKEZ.neg.TS(any(SPIKEZ.neg.TS,2),:);
        %         SPIKEZ.pos.TS=SPIKEZ.pos.TS(any(SPIKEZ.pos.TS,2),:);
        %
        %         % get amplitude for each spike
        %         [SPIKEZ.AMP]=getSpikeAmplitudes(RAW,SPIKEZ.TS,SaRa,SPIKEZ.PREF.flag_isHDMEAmode);
        %         [SPIKEZ.neg.AMP]=getSpikeAmplitudes(RAW,SPIKEZ.neg.TS,SaRa,SPIKEZ.PREF.flag_isHDMEAmode);
        %         [SPIKEZ.pos.AMP]=getSpikeAmplitudes(RAW,SPIKEZ.pos.TS,SaRa,SPIKEZ.PREF.flag_isHDMEAmode);
        %
        %         % calculate spikeparameter like mean firing rate ect.
        %         SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
        %         SPIKEZ=calc_snr_fast(SPIKEZ, COL_RMS, COL_SDT);
        
        
        % old variables (just in case there are still used by old DrCell functions):
        %         SPIKES=SPIKEZ.TS;
        %         AMPLITUDES=SPIKEZ.AMP;
        %         NR_SPIKES=SPIKEZ.N;
        %         FR=SPIKEZ.FR;
        %         N_FR=SPIKEZ.aeN_FR; % number of active electrodes
        %         aeFRmean=SPIKEZ.aeFRmean;
        %         aeFRstd=SPIKEZ.aeFRstd;
        %         SNR=SPIKEZ.neg.SNR.SNR;
        %         SNR_dB = SPIKEZ.neg.SNR.SNR_dB;
        %         Mean_SNR_dB = SPIKEZ.neg.SNR.Mean_SNR_dB;
        [SPIKEZ,SPIKES,AMPLITUDES,NR_SPIKES,FR,N_FR,aeFRmean,aeFRstd,SNR,SNR_dB,Mean_SNR_dB]=copySpikesIntoOldStructure(SPIKEZ);
        
        
        
        spikedata = true;
        
        disp('Spikedetection finished')
    end


% --- Burstdetection_call (MC) ---------------------------
    function burstdetection_call()
        
        
        pref.SIB_min=PREF(5); % SIB_min
        pref.ISI_max=PREF(6)/1000; % ISI_max in seconds
        pref.IBI_min=PREF(8)/1000; % IBI_min in seconds
        
        BURSTS=burstdetection(BURSTS.name,SPIKEZ.TS,SPIKEZ.PREF.rec_dur,pref); % detect bursts
        
    end


% --- SBEdetection_Call (MC) ----------------------------------
    function SBEdetection_call()
        Th=3; % minimal number of synchronous bursts
        idleTime=0.5; % idleTime in seconds
        
        %----Ohne HPC-----%  Sh.Kh
        
        [SBE]=SBEdetection_Sh(BURSTS.BEG,rec_dur,SaRa,Th,idleTime,size(RAW.M,1)); % (BURSTS,rec_dur,SaRa,Th,idleTime)  %shivaHPC
        % old parameter:
        SI_EVENTS=SBE.CORE;
        Nr_SI_EVENTS = size(SI_EVENTS,1);
        %-----------------
        
        %----Mit HPC -----%   sh.Kh
        %        c = parcluster('BioMEMS');                  % Verbindung erstellen
        %        j = createJob(c);                           % Einen Job erstellen
        %        t1 = createTask(j, @SBEdetection , 1, {BURSTS.BEG,rec_dur,SaRa,Th,idleTime});
        %        submit(j);          % Starten der Jobs
        %        wait(j);            % Warten bis zur Fertigstellung
        %        SBE=t1.OutputArguments{1,1};
        % %        x=t1.OutputArguments{1,2};
        %        delete(j);
        %        SI_EVENTS=SBE.CORE;
        %        Nr_SI_EVENTS = size(SI_EVENTS,1);
        %
        %------Ende HPC -----%
        
    end

% --- SBEdetection_old_Call (MC) ----------------------------------
    function SBEdetection_old_call()
        
        Th=3; % minimal number of synchronous bursts
        idleTime=0.5; % idleTime in seconds
        [SBE_old]=SBEdetection_old(BURSTS.BEG,T,SaRa,Th,idleTime);
        
        % old parameter:
        SI_EVENTS=SBE_old.CORE;
        ACTIVITY=SBE_old.ACTIVITY;
        Nr_SI_EVENTS = size(SI_EVENTS,1);
        
    end

% --- Calculate Cohnes Kappa -------------------------------------
    function CohenKappa(source,event) %#ok
        SPIKES_COHEN = SPIKES;
        SPM = NR_SPIKES/rec_dur*60;         %Calculate (spikes per minute)
        Too_Low = SPM<50;
        DEL = find(Too_Low==1);
        SPIKES_COHEN(:,DEL)=[]; %#ok
        N = floor(size(T,2)/(0.01*SaRa));
        
        COHENKAPPA = zeros(size(SPIKES_COHEN,2)-1,size(SPIKES_COHEN,2)-1);
        
        %Calculate Cohens Kappa for all potential pairs of electrodes
        for firstEl=1:(size(SPIKES_COHEN,2)-1)
            for n=1:(size(SPIKES_COHEN,2)-firstEl)
                COHENBIN = zeros(2,N);     %Compare two electrodes
                
                %first electrode
                wosp=ceil(nonzeros(SPIKES_COHEN(:,firstEl))*100);
                COHENBIN(1,wosp)=1;
                s1 = size(nonzeros(COHENBIN(1,:)),1);
                
                %second electrode
                wosp=ceil(nonzeros(SPIKES_COHEN(:,(firstEl+n)))*100);
                COHENBIN(2,wosp)=1;
                s2 = size(nonzeros(COHENBIN(2,:)),1);
                
                p_exp = ((N-s1)*(N-s2) + s1*s2)/N^2;                            %Expectation
                p_obs = (N-size(nonzeros(COHENBIN(2,:)-COHENBIN(1,:)),1))/N;    %Observationl
                
                COHENKAPPA(firstEl,firstEl+n-1) = (p_obs-p_exp)/(1-p_exp);        %Cohens Kappa
            end
        end
        
        kappa_mean = mean(nonzeros(COHENKAPPA));                                  %Mean
    end




%functions - Tab Postprocessing
%----------------------------------------------------------------------

% --- Rasterplot (MC - Sh.Kh)  ------------------------------------------------------
    function rasterplotButtonCallback(~,~)
        
        % GUI
        h_main = figure('Position',[150 50 700 660],'Name','Rasterplot','Color',GUI_Color_BG);
        
        h_p1=uipanel('Parent',h_main,'Position',[0.01 0.01 0.99 0.9],'BackgroundColor',GUI_Color_BG);
        axes('Parent',h_p1,'Units','Normalized','Position',[.1 .1 0.8 .8],'Tag','axes_rasterplot');
        
        h_p2=uipanel('Parent',h_main,'Position',[0.01 0.9 0.99 0.1],'BackgroundColor',GUI_Color_BG);
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_spikes','String','Spikes','units','Normalized','position', [.1 .7 .2 .25],'value',0,'TooltipString','Shows spikes.','Callback',@rasterplot);
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_bursts','String','Bursts','units','Normalized','position', [.1 .45 .2 .25],'value',0,'TooltipString','Shows bursts.','Callback',@rasterplot);
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_nb','String','Networkbursts (NB)','units','Normalized','position', [.1 .2 .2 .25],'value',0,'TooltipString','Shows networkbursts.','Callback',@rasterplot);
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_sbe','String','Synchronous Burst Events (SBE)','units','Normalized','position', [.35 .7 .2 .25],'value',0,'TooltipString','Shows synchronous burst events.','Callback',@rasterplot);
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_sbe_old','String','SBE_old','units','Normalized','position', [.35 .45 .2 .25],'value',0,'TooltipString','Shows synchronous burst events.','Callback',@rasterplot);
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_show_num','String','show #Events','units','Normalized','position', [.35 .2 .2 .25],'value',0,'TooltipString','Shows number of bursts per event.','Callback',@rasterplot);
        
        % draw rasterplot
        rasterplot();
        
    end
    function rasterplot(~,~)
        
        handle=gca;
        cla(handle) % clear axis
        
        % draw text
        a=0; e=rec_dur; % display from a to e seconds
        if HDmode  % HDMEA Data
            ROW=nr_channel;
            for n=1:nr_channel
                if ~isempty(nonzeros(SPIKEZ.TS(:,n)))
                    Names(n)= EL_NAMES(n);
                else
                    Names(n)= {['' ]};
                end
            end
            % Cursor - El Names
            dcm = datacursormode(gcf);
            datacursormode on
            set(dcm, 'updatefcn',@newcurserfunction)
            set(gca,'YDir','reverse', 'TickLength',[0 0],'YLim',[1 ROW+1],'FontSize',6);
            xlabel('t /s')
            height=ROW+1;
            
        else % .mat Data
            if ~isempty(SPIKEZ.TS)
                ROW=0;
                for n=1:size(SPIKEZ.TS,2)
                    if ~isempty(nonzeros(SPIKEZ.TS(:,n)))
                        ROW=ROW+1;
                        el=EL_NUMS(n); % convert nth electrode to MEA-position
                        Names(ROW)={['EL ' num2str(el) ' (' num2str(n) ')']};
                    end
                end
                set(gca,'YDir','reverse', 'ytick', [1.25:1:ROW+1], 'TickLength',[0 0], 'YTickLabel', Names','YLim',[0 ROW+1],'FontSize',6);
                xlabel('t /s')
                height=ROW+1;
            else
                f=msgbox('Spikes data not found. Please run the Spikesdetection.');
            end
        end
        % draw spiketrain
        
        if get(findobj(gcf,'Tag','checkbox_spikes'),'Value')==1
            %             set(gca,'YDir','reverse', 'ytick', [1.25:1:R+1], 'TickLength',[0 0], 'YTickLabel',Names','YLim',[0 R+1],'FontSize',6);
            if HDmode % HDMEA Data
                for n=1:size(SPIKEZ.TS,2)
                    if ~isempty(nonzeros(SPIKEZ.TS(:,n)))
                        line ('Xdata',nonzeros(SPIKEZ.TS(:,n)),'Ydata', (n+0.25).*ones(1,length(nonzeros(SPIKEZ.TS(:,n)))),...
                            'LineStyle','none','Marker','.',...
                            'Color','black','MarkerSize',5);
                    end
                end
                
            else % .mat Data
                k=0;
                for n=1:size(SPIKEZ.TS,2)
                    if ~isempty(nonzeros(SPIKEZ.TS(:,n)))
                        k=k+1; %hazf shiva
                        line ('Xdata',nonzeros(SPIKEZ.TS(:,n)),'Ydata', (k+0.25).*ones(1,length(nonzeros(SPIKEZ.TS(:,n)))),...
                            'LineStyle','none','Marker','.',...
                            'Color','black','MarkerSize',5)
                    end
                end
            end
        end
        
        
        % draw bursts
        if get(findobj(gcf,'Tag','checkbox_bursts'),'Value')==1
            COLOR=[0 1 0.4]; % 0 0.8 0.4
            ROW=1;o=1.5;l=1;
            for n=1:size(SPIKEZ.TS,2)
                if size(BURSTS.BEG,2)>1
                    for k=1:length(nonzeros(BURSTS.BEG(:,n)))
                        line([BURSTS.BEG(k,n) BURSTS.BEG(k,n) BURSTS.END(k,n) BURSTS.END(k,n)],[ o l l o],'Color',COLOR)
                    end
                end
                o=o+ROW;
                l=l+ROW;
            end
        end
        
        % draw SBE
        if get(findobj(gcf,'Tag','checkbox_sbe'),'Value')==1
            if ~isempty(SBE)
                for k=1:size(SBE.CORE,1)
                    line([SBE.CORE(k) SBE.CORE(k)],[height 0],'Linestyle','--','Color',[1 0 0])
                    if get(findobj(gcf,'Tag','checkbox_show_num'),'Value')==1
                        text(SBE.CORE(k),0,num2str(SBE.SIB(k)),'FontSize',6)
                    end
                end
                COLOR=[1 0 0]; % 0 0.8 0.4
                o=0.5;l=0;
                if size(SBE.BEG,1)>0
                    for k=1:length(nonzeros(SBE.BEG(:)))
                        line([SBE.BEG(k) SBE.BEG(k) SBE.END(k) SBE.END(k)],[ o l l o],'Color',COLOR)
                    end
                end
                if get(findobj(gcf,'Tag','checkbox_show_num'),'Value')==1
                    text(T(1,end),2,['#SBE: ' num2str(size(SBE.CORE,1))],'FontSize',10)
                end
            end
        end
        
        % draw SBE_old
        if get(findobj(gcf,'Tag','checkbox_sbe_old'),'Value')==1
            for k=1:size(SBE_old.CORE,1)
                line([SBE_old.CORE(k) SBE_old.CORE(k)],[height 0],'Linestyle','--','Color',[1 0 0])
                if get(findobj(gcf,'Tag','checkbox_show_num'),'Value')==1
                    text(SBE_old.CORE(k),0,num2str(SBE_old.SIB(k)),'FontSize',6)
                end
            end
            if get(findobj(gcf,'Tag','checkbox_show_num'),'Value')==1
                text(T(1,end),4,['#SBE-old: ' num2str(size(SBE_old.CORE,1))],'FontSize',10)
            end
            % BEG and END is not available for SBE_old
            %             COLOR=[1 0 0]; % 0 0.8 0.4
            %             o=0.5;l=0;
            %             if size(SBE_old.BEG,1)>0
            %                  for k=1:length(nonzeros(SBE_old.BEG(:)))
            %                      line([SBE_old.BEG(k) SBE_old.BEG(k) SBE_old.END(k) SBE_old.END(k)],[ o l l o],'Color',COLOR)
            %                  end
            %             end
        end
        
        %draw Networkbursts
        if get(findobj(gcf,'Tag','checkbox_nb'),'Value')==1
            for k=1:size(NETWORKBURSTS.CORE,1)
                line([NETWORKBURSTS.CORE(k) NETWORKBURSTS.CORE(k)],[height 0],'Linestyle','--','Color',[0 0 1])
            end
            COLOR=[0 0 1]; % 0 0.8 0.4
            o=0.5;l=0;
            if size(NETWORKBURSTS.BEG,1)>0
                for k=1:length(nonzeros(NETWORKBURSTS.BEG(:)))
                    line([NETWORKBURSTS.BEG(k) NETWORKBURSTS.BEG(k) NETWORKBURSTS.END(k) NETWORKBURSTS.END(k)],[ o l l o],'Color',COLOR)
                end
            end
            if get(findobj(gcf,'Tag','checkbox_show_num'),'Value')==1
                text(T(1,end),0,['#NB: ' num2str(size(NETWORKBURSTS.CORE,1))],'FontSize',10)
            end
        end
    end


% Display the position of the data cursor
    function output_txt = newcurserfunction(obj,event_obj)
        % obj          Currently not used (empty)
        % event_obj    Handle to event object
        % output_txt   Data cursor text string (string or cell array of strings).
        pos = get(event_obj,'Position');
        output_txt = {['t: ',num2str(pos(1),4)],...
            [EL_NAMES{round(pos(2))}]};
        % If there is a Z-coordinate in the position, display it as well
        if length(pos) > 2
            output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
        end
    end


% --- Autocorrelation (CN)-----------------------------------
    function correlationButtonCallback(source,event) %#ok<INUSD>
        autocorrelationWindow = figure('Position',[100 100 700 600],'Tag','Autocorrelation','Name','Autocorrelation','NumberTitle','off','Toolbar','none','Resize','off');
        autopaneltop=uipanel('Parent',autocorrelationWindow,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[5 515 690 80]);
        uicontrol('Parent',autopaneltop,'style','text','units','Pixels','position', [10 35 300 30],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'HorizontalAlignment','left','String','Shows autocorrelation of selected electrode. Please select one electrode and press "Apply..."!');
        uicontrol('Parent',autopaneltop,'style','edit','units','Pixels','position', [10 10 300 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_Selectautocorr_electrode','string','12');
        uicontrol('Parent',autopaneltop,'Style','PushButton','Units','Pixels','Position',[550 10 130 30],'FontSize',10,'FontWeight','bold','String','Apply...','ToolTipString','Calculates the autocorrelation of the selected electrode','CallBack',@redrawcorrelation);
        autopanelbot = uipanel('Parent',autocorrelationWindow,'BackgroundColor',[.8 .8 .8],'Units','pixels','Position',[5 5 690 510]);
        
        AC_EL_Select = strread(get(findobj(gcf,'Tag','CELL_Selectautocorr_electrode'),'string'));
        AutoCorr = find(EL_NUMS==AC_EL_Select);
        
        subplot(1,1,1,'Parent',autopanelbot)
        xlabel('lags')
        ylabel('Probability Autocorrelation')
        
        if isempty(AutoCorr)
            msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
            uiwait;
            return
        end
        
        binsize = 0.05*SaRa;    %50 ms binsize
        TEST = RAW.M(:,AutoCorr);
        TESTsq = TEST.^2;
        
        k=1;
        j=binsize;
        endfor=ceil(size(T,2)/binsize);
        for i=1:endfor
            CORRBIN(i) = sum(TESTsq(k:j));
            j=(i+1)*binsize;
            k = j-binsize+1;
            if j > size(T,2)
                j= size(T,2);
            end
        end
        
        Lagboarder = int32(size(CORRBIN,2)/3);
        [r,p] = xcorr(CORRBIN,CORRBIN,Lagboarder ,'coeff');
        plot(p,r)
        axis([-Lagboarder Lagboarder 0 1]);
        grid on
    end

% --- Autocorrelationredraw erstellen (CN)-----------------------------
    function redrawcorrelation(source,event) %#ok<INUSD>
        CORRBIN = 0;
        AC_EL_Select = strread(get(findobj(gcf,'Tag','CELL_Selectautocorr_electrode'),'string'));
        
        if length(AC_EL_Select)==1
            AutoCorr = find(EL_NUMS==AC_EL_Select);
            if isempty(AutoCorr)
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                uiwait;
                return
            end
            
            binsize = 0.05*SaRa;    %50 ms binsize
            TEST = RAW.M(:,AutoCorr);
            TESTsq = TEST.^2;
            
            k=1;
            j=binsize;
            endfor=ceil(size(T,2)/binsize);
            for i=1:endfor
                CORRBIN(i) = sum(TESTsq(k:j));
                j=(i+1)*binsize;
                k = j-binsize+1;
                if j > size(T,2)
                    j= size(T,2);
                end
            end
            
            Lagboarder = int32(size(CORRBIN,2)/3);
            subplot(1,1,1,'replace')
            [r,p] = xcorr(CORRBIN,CORRBIN,Lagboarder ,'coeff');
            plot(p,r)
            axis([-Lagboarder Lagboarder 0 1]);
            grid on
            xlabel('lags')
            ylabel('Probability Autocorrelation')
            
        else %if multiple electrodes are marked
            for n = 1:length(AC_EL_Select)
                Check = find(EL_NUMS==AC_EL_Select(n)); %#ok
                if isempty(Check)
                    msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                    uiwait;
                    return
                end
            end
            
            binsize = 0.05*SaRa;    %50 ms binsize
            subplot(1,1,1,'replace');
            cla;
            for n = 1:length(AC_EL_Select)
                AutoCorr(n) = find(EL_NUMS==AC_EL_Select(n));
                TEST(:,n) = RAW.M(:,AutoCorr(n));
                TESTsq(:,n)=TEST(:,n).^2;
                
                k=1;
                j=binsize;
                endfor=ceil(size(T,2)/binsize);
                
                for i=1:endfor
                    CORRBIN(i,n) = sum(TESTsq(k:j,n));
                    j=(i+1)*binsize;
                    k = j-binsize+1;
                    if j > size(T,2)
                        j= size(T,2);
                    end
                end
                TESTcorr = CORRBIN;
                Lagboarder = int32(size(CORRBIN,1)/3);
                Lags = -Lagboarder:1:Lagboarder;
                r(:,n) = xcorr(CORRBIN(:,n),CORRBIN(:,n),Lagboarder,'coeff');
                z(1:size(Lags,2),n)=n;
                
                if n == 1
                    subplot(1,1,1,'replace')
                end
                plot3(z(:,n),Lags,r(:,n))
                hold on
                
            end
            axis([1 length(strread(get(findobj(gcf,'Tag','CELL_Selectautocorr_electrode'),'string'))) -Lagboarder Lagboarder 0 1]);
            grid on
            xlabel('El No')
            ylabel('lags')
            zlabel('Probability Autocorrelation')
        end
    end

% --- Crosscorrelation (CN)--------------------------------------------
    function crosscorrelationButtonCallback(source,event) %#ok
        crosscorrelationWindow = figure('Position',[100 100 700 600],'Tag','Crosscorrelation','Name','Crosscorrelation','NumberTitle','off','Toolbar','none','Resize','off');
        crosspaneltop=uipanel('Parent',crosscorrelationWindow,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[5 515 690 80]);
        uicontrol('Parent',crosspaneltop,'style','text','units','Pixels','position', [10 35 300 30],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'HorizontalAlignment','left','String','Please select two electrodes and press "Apply..."!');
        uicontrol('Parent',crosspaneltop,'style','edit','units','Pixels','position', [10 10 80 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_Selectcrosscorr_electrode1','string','12');
        uicontrol('Parent',crosspaneltop,'style','edit','units','Pixels','position', [120 10 80 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_Selectcrosscorr_electrode2','string','13');
        uicontrol('Parent',crosspaneltop,'Style','PushButton','Units','Pixels','Position',[550 10 130 30],'FontSize',10,'FontWeight','bold','String','Apply...','ToolTipString','Calculates the autocorrelation of the selected electrode','CallBack',@redrawcrosscorrelation);
        crosspanelbot = uipanel('Parent',crosscorrelationWindow,'BackgroundColor',[.8 .8 .8],'Units','pixels','Position',[5 5 690 510]);
        uicontrol('Parent',crosspaneltop,'style','text','units','Pixels','position', [370 35 150 35],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'HorizontalAlignment','left','String','Mean (all electrodes) Cohen´s Kappa');
        uicontrol('Parent',crosspaneltop,'style','edit','units','Pixels','position', [370 10 100 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_cokap','string',kappa_mean);
        
        CORRBIN = 0;
        CC_EL_Select1 = strread(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode1'),'string'));
        CC_EL_Select2 = strread(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode2'),'string'));
        
        if length(CC_EL_Select1)==1 && length(CC_EL_Select2)==1
            CrossCorr1 = find(EL_NUMS==CC_EL_Select1);
            CrossCorr2 = find(EL_NUMS==CC_EL_Select2);
            
            subplot(1,1,1,'parent',crosspanelbot)
            xlabel('lags')
            ylabel('Probability Crosscorrelation')
            
            if isempty(CrossCorr1) || isempty(CrossCorr2)
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                uiwait;
                return
            end
            
            binsize = 0.05*SaRa;    %50 ms binsize
            TEST1 = RAW.M(:,CrossCorr1);
            TESTsq1 = TEST1.^2;
            TEST2 = RAW.M(:,CrossCorr2);
            TESTsq2 = TEST2.^2;
            
            k=1;
            j=binsize;
            endfor=ceil(size(T,2)/binsize);
            for i=1:endfor
                CORRBIN1(i) = sum(TESTsq1(k:j));
                CORRBIN2(i) = sum(TESTsq2(k:j));
                j=(i+1)*binsize;
                k = j-binsize+1;
                if j > size(T,2)
                    j= size(T,2);
                end
            end
            
            Lagboarder = int32(size(CORRBIN1,2)/3);
            [r,p] = xcorr(CORRBIN1,CORRBIN2,Lagboarder ,'coeff');
            plot(p,r)
            axis([-Lagboarder Lagboarder 0 1]);
            grid on
            
        else
            msgbox('please only select two electrodes!')
        end
    end

% --- Redraw Crosscorrelation (CN)----------------------------
    function redrawcrosscorrelation(source,event) %#ok
        CORRBIN = 0;
        CC_EL_Select1 = strread(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode1'),'string'));
        CC_EL_Select2 = strread(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode2'),'string'));
        
        if length(CC_EL_Select1)==1 && length(CC_EL_Select2)==1
            CrossCorr1 = find(EL_NUMS==CC_EL_Select1);
            CrossCorr2 = find(EL_NUMS==CC_EL_Select2);
            
            if isempty(CrossCorr1) || isempty(CrossCorr2)
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                uiwait;
                return
            end
            
            binsize = 0.05*SaRa;    %50 ms binsize
            TEST1 = RAW.M(:,CrossCorr1);
            TESTsq1 = TEST1.^2;
            TEST2 = RAW.M(:,CrossCorr2);
            TESTsq2 = TEST2.^2;
            
            k=1;
            j=binsize;
            endfor=ceil(size(T,2)/binsize);
            for i=1:endfor
                CORRBIN1(i) = sum(TESTsq1(k:j));
                CORRBIN2(i) = sum(TESTsq2(k:j));
                j=(i+1)*binsize;
                k = j-binsize+1;
                if j > size(T,2)
                    j= size(T,2);
                end
            end
            
            Lagboarder = int32(size(CORRBIN1,2)/3);
            
            subplot(1,1,1,'replace')
            [r,p] = xcorr(CORRBIN1,CORRBIN2,Lagboarder ,'coeff');
            plot(p,r)
            axis([-Lagboarder Lagboarder 0 1]);
            grid on
            xlabel('lags')
            ylabel('Probability Crosscorrelation')
            
        else
            msgbox('please only select two electrodes!')
        end
    end

% --- Signalprocessing (MC) -------------------------------
    function signalprocessingButtonCallback(~,~)
        
        
        GLOB.file = file;
        GLOB.GUI_Color_BG = GUI_Color_BG;
        
        GUI_cardioSignalProcessing(RAW,SPIKEZ,GLOB)
    end

% --- Delete spike trains with less than a specified mininal firing rate (MC) --------------------------------
    function minFiringRateButtonCallback(~,~)
        
        
        
        dlg_prompt={'Delete all spike trains with less or equal than X spikes per minute. X = '};
        dlg_name='Set minimal spike rate';
        dlg_numlines=1;
        dlg_defaultanswer={'5'};
        minFR = str2double(cell2mat(inputdlg(dlg_prompt,dlg_name,dlg_numlines,dlg_defaultanswer)));
        
        h=waitbar(0.25,['Deleting spike trains with less or equal than ' num2str(minFR) '.']);
        
        [SPIKEZ.TS, SPIKEZ.AMP, numDeletedElectrodes]=deleteLowFiringRateSpiketrains(SPIKEZ.TS,SPIKEZ.AMP,SPIKEZ.PREF.rec_dur,minFR);
        disp(['Electrodes deleted:' num2str(numDeletedElectrodes)])
        disp(['Number of active Electrodes: ' num2str(size(SPIKEZ.TS,2)-numDeletedElectrodes)])
        
        SPIKEZ.PREF.minFR=minFR; % save min. firing rate
        
        waitbar(0.5,h,'Recalculating spike parameter')
        
        SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
        
        % old parameter:
        SPIKES=SPIKEZ.TS;
        AMPLITUDES=SPIKEZ.AMP;
        NR_SPIKES=SPIKEZ.N;
        FR=SPIKEZ.FR;
        N_FR=SPIKEZ.aeFRn; % number of active electrodes
        aeFRmean=SPIKEZ.aeFRmean;
        aeFRstd=SPIKEZ.aeFRstd;
        
        redrawdecide;
        
        waitbar(1,h,'Finished')
        
        close(h)
        
    end

% --- Test if spike train is stationary (MC) --------------------------------
    function Stationarity_ButtonCallback(~,~)
        
        dlg_prompt={'Spike trains will be tested for nonstationarity. 1: Delete nonstationary spike trains. 0: Keep all spike trains'};
        dlg_name='Test spike trains for nonstationarity';
        dlg_numlines=1;
        dlg_defaultanswer={'0'};
        bool_delete = str2double(cell2mat(inputdlg(dlg_prompt,dlg_name,dlg_numlines,dlg_defaultanswer)));
        
        % call function to test for nonstationarity:
        force=2; % only conduct test if number of spikes is equal or greater than "force"
        plot_bool = 0; % 0: don't show plot, 1: show plot
        RES=test_nonstationarity(SPIKEZ.TS,force,SPIKEZ.PREF.rec_dur,plot_bool);  % function by Andreas Raeder
        disp('    #El   Stationary? (0: no, 1: yes)')
        el_nums = EL_NUMS(RES.SP_pos)';
        disp([el_nums RES.S1]) % show stationarity for every spike train (1: is stationary, 0: is not stationary)
        
        if bool_delete > 0 % delete non-stationary spike trains?
            delete_ST = RES.SP_pos(~RES.S1); % RES.SP_pos: electrodes that were considered for nonstat. test % RES.S1: 1: stationary ST
            SPIKEZ.TS(:,delete_ST)=0; % delete nonstationary spike trains
            SPIKEZ.AMP(:,delete_ST)=0; % delete corresponding amplitudes
            redrawdecide;
        end
        
        % test nonstationarity for all spike trains merged to one spike
        % train
        RES=test_nonstationarity(sort(nonzeros(SPIKEZ.TS(:))),force,SPIKEZ.PREF.rec_dur,plot_bool);
        disp(['For all spike trains (1: stationary, 0: nonstat.): ' num2str(RES.S1)])
        
        
        % recalculate spike parameter
        SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
        
        % old parameter:
        SPIKES=SPIKEZ.TS;
        AMPLITUDES=SPIKEZ.AMP;
        NR_SPIKES=SPIKEZ.N;
        FR=SPIKEZ.FR;
        N_FR=SPIKEZ.aeN_FR; % number of active electrodes
        aeFRmean=SPIKEZ.aeFRmean;
        aeFRstd=SPIKEZ.aeFRstd;
        
        
    end

% --- ZeroOut - Show Exapmle (CN)---------------------------
    function ZeroOutExampleButtonCallback(source,event) %#ok<INUSD>
        figure('Position',[150 50 1000 550],'Name','Example of artefactsupression of the first Stimuli','NumberTitle','off','Resize','off');
        plot(timePr,signal_draw(1,:),'k-')
        hold on
        plot(timePr,signalCorr_draw(1,:))
        title(['Electrode ' num2str(EL_NUMS(PREF(9))) ' - Artefactsupression - Black: original signal, Blue: signal after artefaktsupression']);
    end

% --- Spiketrain (AD)--------------------------------------------------
    function spiketrainButtonCallback(source,event) %#ok<INUSD>
        ST_EL_Auswahl=0;
        spiketrainWindow = figure('Position',[25 40 600 700],'Tag','Spiketrain','Name','Spiketrain','NumberTitle','off','Toolbar','none','Resize','off','color','w');
        uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [0 580 600 120],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'HorizontalAlignment','left','String',' ');
        uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [0 0 20 700],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'HorizontalAlignment','left','String',' ');
        uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [580 0 20 700],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'HorizontalAlignment','left','String',' ');
        uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [0 0 600 50],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'HorizontalAlignment','left','String',' ');
        uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [25 620 300 50],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'HorizontalAlignment','left','String','Enter electrode numbers (separated by space) for creating individual spiketrains!');
        
        %--- Electrodes
        
        ST_ENDE_TAT=(T(size(T,2))+T(size(T,2))-T((size(T,2)-1)));
        uicontrol('Parent',spiketrainWindow,'style','edit','units','Pixels','position', [20 600 300 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','ST_CELL_electrode','string','12 13 14 15 16 17 21 22 23 24 25');
        uicontrol('Parent',spiketrainWindow,'Units','Pixels','Position', [450 660 130 20],'Tag','ST_WN','FontSize',8,'String','wide | narrow','Value',2,'Style','popupmenu');
        uicontrol(spiketrainWindow,'Style','PushButton','Units','Pixels','Position',[450 600 130 30],'String','Create...','ToolTipString','Creates Spiketrain','CallBack',@redrawspiketrain);
        uicontrol('Parent',spiketrainWindow,'style','edit','units','Pixels','position', [450 635 45 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','ST_start','string','0');
        uicontrol('Parent',spiketrainWindow,'style','edit','units','Pixels','position', [515 635 45 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','ST_ende','string',ST_ENDE_TAT);
        uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [498 630 15 20],'BackgroundColor', GUI_Color_BG,'FontSize',7, 'HorizontalAlignment','left','String','to');
        uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [565 630 15 20],'BackgroundColor', GUI_Color_BG,'FontSize',7, 'HorizontalAlignment','left','String','sec');
        
        % --- show spiketrains (standard view)---
        for i=1:nr_channel
            
            subplot(70,5,[47+i*5 49+i*5]);
            axis off;
            axis([0 T(size(T,2)) -1*50 50]);
            line([0;0],[-100;100],...
                'LineStyle',':','Linewidth',1,'color','blue','Marker','none');
            line([T(size(T,2));T(size(T,2))],[-100;100],...
                'LineStyle',':','Linewidth',1,'color','blue','Marker','none');
            if SPIKES(1,i)>0;
                for m=1:size(nonzeros(SPIKES(:,i)))
                    line([nonzeros(SPIKES(m,i));nonzeros(SPIKES(m,i))],[-50;50],...
                        'LineStyle','-','Linewidth',1,'color','black','Marker','none');
                end
            end
            subplot(70,5,46+5*i);
            axis off;
            text(0.8,-13.5,EL_NAMES(i),'FontSize',7);
        end
    end

% --- Aktualisieren Button laesst individuelle Ansichten zu (AD)--------
    function redrawspiketrain(source,event) %#ok<INUSD>
        ST_EL_Auswahl = get(findobj(gcf,'Tag','ST_CELL_electrode'),'string');
        ST_view=get(findobj(gcf,'Tag','ST_WN'),'value');
        ST_ELEKTRODEN = strread(ST_EL_Auswahl);
        ST_EL_WAHL=zeros(60,2);
        ST_START=get(findobj(gcf,'Tag','ST_start'),'string');
        ST_ENDE=get(findobj(gcf,'Tag','ST_ende'),'string');
        
        for n = 1:length(ST_ELEKTRODEN)
            i = find(EL_NUMS==ST_ELEKTRODEN(n));
            
            if isempty(i)==1
                errordlg('    Elektrodeneingabe fehlerhaft!');
                return
            end
            
            ST_EL_WAHL(n,1)=i;
            ST_EL_WAHL(n,2)=ST_ELEKTRODEN(n);
        end
        
        % delete old data
        subplot(70,5,[31 350]);
        cla;
        
        % --- show selected spiketrains ---
        subplot(70,5,40+ST_view); axis off; cla;
        text(-0.2,0,[num2str(ST_START) ' sec'],'FontSize',8);
        subplot(70,5,46-ST_view); axis off; cla;
        text(0.75,0,[num2str(ST_ENDE) ' sec'],'FontSize',8);
        
        for i=1:length(ST_ELEKTRODEN)
            temp=ST_EL_WAHL(i,1);
            subplot(70,5,[45+ST_view+i*5 51+i*5-ST_view]);
            cla; axis off;
            axis([str2double(ST_START) str2double(ST_ENDE) -1*50 50]);
            
            
            if temp>0;
                line([str2double(ST_START);str2double(ST_START)],[-100;100],...
                    'LineStyle',':','Linewidth',1,'color','blue','Marker','none');
                line([str2double(ST_ENDE);str2double(ST_ENDE)],[-100;100],...
                    'LineStyle',':','Linewidth',1,'color','blue','Marker','none');
                
                if SPIKES(1,temp)>0;
                    for m=1:size(nonzeros(SPIKES(:,temp)))
                        line([nonzeros(SPIKES(m,temp));nonzeros(SPIKES(m,temp))],[-45;45],...
                            'LineStyle','-','Linewidth',1,'color','black','Marker','none');
                    end
                end
            end
            if ST_view == 2
                subplot(70,5,51+5*i);
                axis off;
                text(0.8,-3.5,['El ' num2str(ST_ELEKTRODEN(i))],'FontSize',7);
            end
        end
        
    end

% --- Analyis of Networkbursts in open file (CN)--------------
    function AnalyseSBE_ButtonCallback(source,event) %#ok
        h_bar2=waitbar(0.05,'Please wait - networkbursts are analysed...');
        numberfiles = 1;
        if SI_EVENTS ~= 0
            ORDER = cell(size(BURSTS.BEG,2),size(SI_EVENTS,2));
            BURSTTIME = zeros(size(BURSTS.BEG,2),size(SI_EVENTS,2));
            waitbar(0.1)
            for n=1:size(SI_EVENTS,2)           %for every SBE
                eventpos = int32(SI_EVENTS(n)*SaRa);
                eventbeg=double(eventpos);
                while ACTIVITY(eventbeg) >= 1           %find beginning of SI_Events
                    eventbeg = eventbeg-1;
                end
                eventtime = eventbeg/SaRa;
                xy = 0;
                yz = 1;
                t=1;
                tol = 1/(2*SaRa);
                waitbar(0.25)
                while(xy<=0.4)
                    zz=1;
                    [row,col] = find((BURSTS.BEG<(eventtime+xy+tol))&(BURSTS.BEG>(eventtime+xy-tol)));
                    if isempty(col)
                    else
                        while zz<=length(col)
                            ORDER(yz,n) = EL_NAMES(col(zz));
                            BURSTTIME(yz,n) = BURSTS.BEG(row(zz),col(zz));
                            yz = yz+1;
                            zz=zz+1;
                        end
                    end
                    t=t+1;
                    xy = xy+1/SaRa;
                end
            end
            waitbar(0.4)
            
            [b,a] = butter(3,400*2/SaRa,'low');    % Butterworth-TP
            ACTIVITY = filter(b,a,ACTIVITY);
            wait_time = int32(.5*SaRa);
            MAX = 0;
            time20_vor = 0;
            time80_vor = 0;
            time80_nach = 0;
            time20_nach = 0;
            Rise = 0;
            Duration = 0;
            waitbar(0.5)
            %Calculate slopes and duration
            for k=1:Nr_SI_EVENTS
                MAX(k) = ACTIVITY(int32(SI_EVENTS(k)*SaRa));
                UG(k) = 0.2*MAX(k);
                OG(k)= 0.8*MAX(k);
                
                countlimit(k)=0;
                for q=1:(10*wait_time)
                    if ACTIVITY(int32(SI_EVENTS(k)*SaRa-q))<0.5
                        countlimit(k)=int32(SI_EVENTS(k)*SaRa-q); %#ok<*AGROW>
                        if countlimit(k)<= 0;
                            countlimit(k) = 1;
                        end
                        break
                    end
                end
                waitbar(0.55)
                for p=1:int32(SI_EVENTS(k)*SaRa-countlimit(k));
                    if ACTIVITY(int32(countlimit(k)+p-1))>= UG(k)
                        time20_vor(k) = (double(countlimit(k)+p-1)/SaRa);
                        break
                    end
                end
                
                for p=1:int32(SI_EVENTS(k)*SaRa-time20_vor(k)*SaRa)
                    if ACTIVITY(int32(time20_vor(k)*SaRa+p-1))>= OG(k)
                        time80_vor(k) = (double(time20_vor(k)*SaRa+p-1))/SaRa;
                        break
                    end
                end
                waitbar(0.6)
                for p=1:int32(wait_time)
                    if ACTIVITY(int32(SI_EVENTS(k)*SaRa+p-1))<= OG(k)
                        time80_nach(k) = double(SI_EVENTS(k)*SaRa+p-1)/SaRa;
                        break
                    end
                end
                
                for p=1:int32((2*wait_time)-(time80_nach(k)*SaRa-SI_EVENTS(k)*SaRa))
                    if ACTIVITY(int32(time80_nach(k)*SaRa)+p-1)<= UG(k)
                        time20_nach(k) = double(time80_nach(k)*SaRa+p-1)/SaRa;
                        break
                    end
                end
                waitbar(0.7)
                Duration(k)= time20_nach(k)-time20_vor(k);
                Rise(k) = time80_vor(k)-time20_vor(k);
                Fall(k) = time20_nach(k)-time80_nach(k);
            end
            waitbar(0.8)
            MinDuration = min(Duration);
            MaxDuration = max(Duration);
            MeanDuration = mean(Duration);
            stdMeanDuration = std(Duration);
            MinRise = min(Rise);
            MaxRise = max(Rise);
            Meanrise = mean(Rise);
            stdMeanRise = std(Rise);
            MinFall = min(Fall);
            MaxFall = max(Fall);
            Meanfall = mean(Fall);
            stdMeanFall = std(Fall);
            waitbar(0.9)
            %clear workspace
            clear Duration;
            clear Rise;
            clear Fall;
        end
        waitbar(1,h_bar2,'Complete.'); close(h_bar2);
        set(findobj(gcf,'Tag','CELL_exportNWBButton'),'Enable','on');
        
        if SI_EVENTS ~= 0
            mainNWB=figure('Position',[150 100 1000 500],'Name','Networkbursts','NumberTitle','off','Resize','off');
            subplot(2,1,1);
            plot(T,ACTIVITY)
            axis([0 T(size(T,2)) -10 60])
            xlabel ('time / s');
            ylabel({'Number of active electrodes (blue)';'Maximum activity (green)'});
            title('Networkactivity','fontweight','b')
            
            for n=1:length(SI_EVENTS)   %draw max
                line ('Xdata',[SI_EVENTS(n) SI_EVENTS(n)],'YData',[-10 60],'Color','green');
            end
            %raising slope
            Risepanel = uipanel('Parent',mainNWB,'Title','rising time 20%-80%','FontSize',10,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[130 40 256 200]);
            uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels', 'position', [5 130 120 30],'String','min time [s]');
            uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels', 'position', [5 90 120 30],'String','max time [s]');
            uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels', 'position', [5 50 120 30],'String','average [s]');
            uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels', 'position', [5 10 140 30],'String','Standard deviation');
            
            uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 142 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_1');
            uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 102 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_2');
            uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 62 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_durch');
            uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 22 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_std');
            
            set(findobj(gcf,'Tag','trise_1'),'String',MinRise);
            set(findobj(gcf,'Tag','trise_2'),'String',MaxRise);
            set(findobj(gcf,'Tag','trise_durch'),'String',Meanrise);
            set(findobj(gcf,'Tag','trise_std'),'String',stdMeanRise);
            
            %decreasing slope
            Fallpanel = uipanel('Parent',mainNWB,'Title','falling time 80%-20%','FontSize',10,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[390 40 256 200]);
            uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','position', [5 130 120 30],'String','min time [s]');
            uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','position', [5 90 120 30],'String','max time [s]');
            uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','position', [5 50 120 30],'String','average [s]');
            uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','position', [5 10 140 30],'String','Standard deviation');
            
            uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 142 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_1');
            uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 102 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_2');
            uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 62 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_durch');
            uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 22 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_std');
            
            set(findobj(gcf,'Tag','tfall_1'),'String',MinFall);
            set(findobj(gcf,'Tag','tfall_2'),'String',MaxFall);
            set(findobj(gcf,'Tag','tfall_durch'),'String',Meanfall);
            set(findobj(gcf,'Tag','tfall_std'),'String',stdMeanFall);
            
            %duration
            Durationpanel = uipanel('Parent',mainNWB,'Title','duration 20%-20%','FontSize',10,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[650 40 256 200]);
            uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','position', [5 130 120 30],'String','min time [s]');
            uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','position', [5 90 120 30],'String','max time [s]');
            uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','position', [5 50 120 30],'String','average [s]');
            uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','position', [5 10 140 30],'String','Standard deviation');
            
            uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 142 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_1');
            uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 102 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_2');
            uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 62 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_durch');
            uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 22 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_std');
            
            set(findobj(gcf,'Tag','tdur_1'),'String',MinDuration);
            set(findobj(gcf,'Tag','tdur_2'),'String',MaxDuration);
            set(findobj(gcf,'Tag','tdur_durch'),'String',MeanDuration);
            set(findobj(gcf,'Tag','tdur_std'),'String',stdMeanDuration);
        end
    end


% --- Networkburstdetection_call (MC) -----------------------------
    function Networkburstdetection_call()
        bin=0.025; % binsize in s
        idleTime=0.5; % idleTime in s
        Th = 9; % Threshold is set to 9
        NETWORKBURSTS=networkburstdetection(SPIKEZ.TS,rec_dur,bin,idleTime,Th);
        %NETWORKBURSTS=networkburstdetection2(SPIKEZ.TS,SPIKEZ.AMP,rec_dur,bin,idleTime);
    end

% --- Networkburstdetection Button Callback (MC) -----------------------------
    function NetworkburstsButtonCallback_nu(~,~)
        
        bin=0.025; % binsize in s
        idleTime=0.5; % idleTime in s
        Th = 9; % Threshold is set to 9
        
        %         ISI=diff(SPIKEZ.TS);
        %         ISI(ISI<0)=0;
        %         ISI_all=log10(nonzeros(ISI));
        %
        %         [N,edges]=histcounts(ISI_all);%,'BinEdges',xvalues);
        %
        %         [mu,sigma] = normfit(N);
        %         x=-300:.1:800;
        %         Y = normpdf(x,mu,sigma);
        %         figure
        %         plot(x,Y)
        %
        %         [~,i]=max(N);
        %         x_max=edges(i);
        %         x_max=10^(x_max);
        %         bin=x_max*3;
        %         idleTime=x_max*30;
        
        
        % call function 'networkburstdetection'
        % it detects networkbursts according to CHIAPPALONE et al.
        [NETWORKBURSTS,AllSpikesPerBin,actElPerBin,Product,numberOFbins,Th]=networkburstdetection2(SPIKEZ.TS,SPIKEZ.AMP,SPIKEZ.PREF.rec_dur,bin,idleTime,Th);
        
        % plot
        a=0; e=SPIKEZ.PREF.rec_dur; % display from a to e seconds
        x=1:numberOFbins;
        x=x.*bin;
        figure('Name','Networkbursts');
        hsub1=subplot(4,1,1); % Spiketrain
        ROW=0; o=0.5;l=0;
        for n=1:size(SPIKEZ.TS,2)
            if ~isempty(nonzeros(SPIKEZ.TS(:,n)))
                ROW=ROW+1;
                el=EL_NUMS(n); % convert nth electrode to MEA-position
                Names(ROW)={['EL ' num2str(el)]};
                %                     for k=1:size(SPIKES,1)
                %                         line([SPIKES(k,n) SPIKES(k,n)],[o+ROW l+ROW],'Color','black');
                %                     end
                line ('Xdata',nonzeros(SPIKEZ.TS(:,n)),...
                    'Ydata', ROW.*ones(1,length(nonzeros(SPIKEZ.TS(:,n))))+0.25,...
                    'LineStyle','none','Marker','.',...
                    'Color','black','MarkerSize',3);
                
            end
        end
        set(gca,'YDir','reverse', 'ytick', [1.25:1:ROW+1], 'TickLength',[0 0], 'YTickLabel', Names','YLim',[0 ROW+1],'FontSize',7);
        hsub2=subplot(4,1,2); % Spikehistogram
        plot(x, AllSpikesPerBin, 'Color',[0 0.8 0.4]);
        ylabel('FR/bin');
        set(gca,'XLim',[a e],'FontSize',7);
        hsub3=subplot(4,1,3); % Electrodehistogram
        plot(x, actElPerBin, 'Color', [0 0.8 0.4]);
        ylabel('AE/bin');
        set(gca,'XLim',[a e],'FontSize',7);
        hsub4=subplot(4,1,4); % Threshold+Networkbursts
        plot(x, Product,'-x','Markersize',2, 'Color', [0 0.8 0.4]); hold on
        plot(x, ones(size(x)).*Th, '--', 'Color', [0 0 0]);
        plot(NETWORKBURSTS.CORE, ones(size(NETWORKBURSTS.CORE,1)).*max(Product), '  *','Color',[0 0 0]);
        plot(NETWORKBURSTS.BEG, ones(size(NETWORKBURSTS.BEG,1)).*Th, '  >','Color',[0 0 0]);
        plot(NETWORKBURSTS.END, ones(size(NETWORKBURSTS.END,1)).*Th, '  <','Color',[0 0 0]);hold off
        linkaxes([hsub1 hsub2 hsub3 hsub4], 'x'); % zoom in all plots simultaniously
        ylabel('FR*AE');
        xlabel('t /s')
        set(gca,'XLim',[a e],'FontSize',7);
        
        % subplot1 change size
        spos=get(hsub1,'Position');
        set(hsub1, 'Position',[spos(1) spos(2)-spos(4)*1.5 spos(3) spos(4)*3]); % [x y width height]
        % subplot2 change size
        spos=get(hsub2,'Position');
        set(hsub2, 'Position',[spos(1) spos(2)-spos(4) spos(3) spos(4)*0.5]);
        % subplot3 change size
        spos=get(hsub3,'Position');
        set(hsub3, 'Position',[spos(1) spos(2)-spos(4)*0.5 spos(3) spos(4)*0.5]);
        % subplot4 change size
        spos=get(hsub4,'Position');
        set(hsub4, 'Position',[spos(1) spos(2) spos(3) spos(4)*0.5]);
        
        
    end

% --- Networkburstdetection Button Callback (MC) -----------------------------
    function NetworkburstsButtonCallback(~,~)
        
        
        
        %         ISI=diff(SPIKEZ.TS);
        %         ISI(ISI<0)=0;
        %         ISI_all=log10(nonzeros(ISI));
        %
        %         [N,edges]=histcounts(ISI_all);%,'BinEdges',xvalues);
        %
        %         [mu,sigma] = normfit(N);
        %         x=-300:.1:800;
        %         Y = normpdf(x,mu,sigma);
        %         figure
        %         plot(x,Y)
        %
        %         [~,i]=max(N);
        %         x_max=edges(i);
        %         x_max=10^(x_max);
        %         bin=x_max*3;
        %         idleTime=x_max*30;
        
        % delete single spikes:
        if 0
            ISI_max=0.100;
            SPIKE=SPIKEZ.TS;
            figure
            
            for i=1:4
                ISI=diff(SPIKE); % Test ISIs
                SPIKE(SPIKE==0)=NaN;
                deletedSpikes=zeros(1,60);
                for n=1:size(SPIKE,2)
                    if ~isempty(nonzeros(SPIKE(:,n)))
                        for k=1:size(nonzeros(SPIKE(:,n)),1)-2
                            if SPIKE(k+1,n)-SPIKE(k,n) > ISI_max
                                if SPIKE(k+2,n)-SPIKE(k+1,n) > ISI_max
                                    SPIKE(k+1,n)=NaN; % delete spike k+1 if time to pre-spike and post-spike is more than ISI_max
                                    deletedSpikes(n)=deletedSpikes(n)+1;
                                end
                            end
                        end
                    end
                end
                SPIKE=sort(SPIKE);
                SPIKE(isnan(SPIKE))=0;
                ISI2=diff(SPIKE); % test
                
                
                % display returnmap:
                ISI=diff(SPIKE);
                ISI(ISI<0)=0;
                ISI(ISI==0)=NaN;
                ISI=log10(ISI);
                for n=1:size(ISI,2)
                    hp=scatter(ISI(1:end-1,n),ISI(2:end,n),'.'); hold on
                end
                hold off
                %             hp=scatter(ISI(1:end-1),ISI(2:end),'.');
                hp.Parent.XLabel.String='ISI(n)';
                hp.Parent.YLabel.String='ISI(n+1)';
                pause(1)
            end
            SPIKEZ.TS=SPIKE;
        end
        
        
        % call function 'networkburstdetection'
        % it detects networkbursts according to CHIAPPALONE et al.
        Th = 9; % Threshold is set to 9
        bin=0.025; % binsize in s
        idleTime=0.5; % idleTime in s
        [NETWORKBURSTS,AllSpikesPerBin,actElPerBin,Product,numberOFbins,Th]=networkburstdetection(SPIKEZ.TS,SPIKEZ.PREF.rec_dur,bin,idleTime,Th);
        
        % plot
        a=0; e=SPIKEZ.PREF.rec_dur; % display from a to e seconds
        x=1:numberOFbins;
        x=x.*bin;
        figure('Name','Networkbursts');
        hsub1=subplot(4,1,1); % Spiketrain
        ROW=0; o=0.5;l=0;
        for n=1:size(SPIKEZ.TS,2)
            if ~isempty(nonzeros(SPIKEZ.TS(:,n)))
                ROW=ROW+1;
                el=EL_NUMS(n); % convert nth electrode to MEA-position
                Names(ROW)={['EL ' num2str(el)]};
                %                     for k=1:size(SPIKES,1)
                %                         line([SPIKES(k,n) SPIKES(k,n)],[o+ROW l+ROW],'Color','black');
                %                     end
                line ('Xdata',nonzeros(SPIKEZ.TS(:,n)),...
                    'Ydata', ROW.*ones(1,length(nonzeros(SPIKEZ.TS(:,n))))+0.25,...
                    'LineStyle','none','Marker','.',...
                    'Color','black','MarkerSize',3);
                
            end
        end
        set(gca,'YDir','reverse', 'ytick', [1.25:1:ROW+1], 'TickLength',[0 0], 'YTickLabel', Names','YLim',[0 ROW+1],'FontSize',7);
        hsub2=subplot(4,1,2); % Spikehistogram
        plot(x, AllSpikesPerBin, 'Color',[0 0.8 0.4]);
        ylabel('FR/bin');
        set(gca,'XLim',[a e],'FontSize',7);
        hsub3=subplot(4,1,3); % Electrodehistogram
        plot(x, actElPerBin, 'Color', [0 0.8 0.4]);
        ylabel('AE/bin');
        set(gca,'XLim',[a e],'FontSize',7);
        hsub4=subplot(4,1,4); % Threshold+Networkbursts
        plot(x, Product,'-x','Markersize',2, 'Color', [0 0.8 0.4]); hold on
        plot(x, ones(size(x)).*Th, '--', 'Color', [0 0 0]);
        plot(NETWORKBURSTS.CORE, ones(size(NETWORKBURSTS.CORE,1)).*max(Product), '  *','Color',[0 0 0]);
        plot(NETWORKBURSTS.BEG, ones(size(NETWORKBURSTS.BEG,1)).*Th, '  >','Color',[0 0 0]);
        plot(NETWORKBURSTS.END, ones(size(NETWORKBURSTS.END,1)).*Th, '  <','Color',[0 0 0]);hold off
        linkaxes([hsub1 hsub2 hsub3 hsub4], 'x'); % zoom in all plots simultaniously
        ylabel('FR*AE');
        xlabel('t /s')
        set(gca,'XLim',[a e],'FontSize',7);
        
        % subplot1 change size
        spos=get(hsub1,'Position');
        set(hsub1, 'Position',[spos(1) spos(2)-spos(4)*1.5 spos(3) spos(4)*3]); % [x y width height]
        % subplot2 change size
        spos=get(hsub2,'Position');
        set(hsub2, 'Position',[spos(1) spos(2)-spos(4) spos(3) spos(4)*0.5]);
        % subplot3 change size
        spos=get(hsub3,'Position');
        set(hsub3, 'Position',[spos(1) spos(2)-spos(4)*0.5 spos(3) spos(4)*0.5]);
        % subplot4 change size
        spos=get(hsub4,'Position');
        set(hsub4, 'Position',[spos(1) spos(2) spos(3) spos(4)*0.5]);
        
        
    end

% --- Networkburstdetection Test (MC)
    function NetworkburstsMCButtonCallback(~,~)
        figure('name','Networkburstdetection_MC')
        
        fig=1;
        [NETWORKBURSTS]=networkburstdetection_mc(SPIKEZ.TS,rec_dur,fig);
    end

% --- Event Snychronisation (RB)-------------------------------
    function Event_Synchronisation(source,~)
        
        global ES ES_figure_active
        ES_figure_active  = 0;
        f = SaRa;
        T_temp = 1/f;
        %Tmax = size(RAW.M,1)+1;
        Tmax=rec_dur*SaRa;
        
        data_original = SPIKES;
        NS = zeros(1, size(SPIKES,2));
        for i=1:size(SPIKES,2)
            NS(i) = size(find(SPIKES(:,i) ~= 0),1);
        end
        
        v = find(NS > 2);
        Ns = NS(v);
        
        % For ES
        data_original_time = SPIKES(:,v);
        %data_original_time = data_original_time*1e-3;
        
        %% Event Synchronization
        ES = zeros(size(v,2));
        ESD = zeros(size(v,2));
        ES_sum = 0;
        ES_mean_shown = 0;
        for x=1:size(v,2)
            for y=1:size(v,2)
                [es,ed] = Event_Sync(round(data_original_time(find(data_original_time(:,x) ~= 0),x)*f+1), round(data_original_time(find(data_original_time(:,y) ~= 0),y)*f+1));
                
                ES(x, y) = es;
                ESD(y, x) = ed;
            end
            ES_sum = ES_sum + sum(ES(x,x+1:size(ES,2)));
        end
        ES_mean = ES_sum/(((size(v,2)-1)^2+(size(v,2)-1))/2);
        
        %Main Window
        EventsynchronizationWindow = figure('Name','Event_synchronization','NumberTitle','off','Position',[45 100 600 600],'Toolbar','none','Resize','off','Color',GUI_Color_BG,'Tag','Event_sync_window');
        
        
        %Main Window header
        uicontrol('Parent', EventsynchronizationWindow,'Style', 'text','Position', [140 575 250 20],'HorizontalAlignment','center','String','Network Synchronizity Plot','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Button-Area
        EventPanel=uipanel('Parent',EventsynchronizationWindow,'Units','pixels','Position',[485 1 115 599],'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',EventPanel,'Style', 'text','Position', [25 575 60 20],'HorizontalAlignment','left','String', 'Display:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %         uicontrol('Parent',EventPanel,'Style','text','Position', [35 550 100 20],'HorizontalAlignment','left','String', 'Sync Threshold:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Colorbar boundary edit-fields
        uicontrol('Parent',EventPanel,'Style', 'text','Position', [7 513 65 40],'HorizontalAlignment','left','String','Upper Boundary:','FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',EventPanel,'Units','Pixels','Position', [65 525 40 20],'Tag','Upper_Sync_Thres','HorizontalAlignment','right','FontSize',8,'Value',1.0,'String',1.0,'Style','edit');
        
        uicontrol('Parent',EventPanel,'Style', 'text','Position', [7 87 65 40],'HorizontalAlignment','left','String','Lower Boundary:','FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',EventPanel,'Units','Pixels','String','Lower Boundary','Position', [67 100 40 20],'Tag','Lower_Sync_Thres','HorizontalAlignment','right','FontSize',8,'Value',0.3,'String',0.3,'Style','edit');
        
        %Synchronicity indicators
        uicontrol('Parent',EventPanel,'Style', 'text','Position', [7 330 100 22],'HorizontalAlignment','left','String',' Synchronicity','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',EventPanel,'Style', 'text','Position', [7 307 100 23],'HorizontalAlignment','left','String',' mean:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',EventPanel,'Style', 'edit','Position', [60 310 40 20],'HorizontalAlignment','right','String',num2str(round(ES_mean*1000)/1000),'FontSize',10,'FontWeight','bold','ForegroundColor','black','Enable','inactive','BackgroundColor',[0.99 0.99 0.99]);
        
        uicontrol('Parent',EventPanel,'Style', 'text','Position', [7 284 100 23],'HorizontalAlignment','left','String',' visible:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',EventPanel,'Style', 'edit','Position', [60 287 40 20],'HorizontalAlignment','right','String',num2str(round(ES_mean_shown*1000)/1000),'FontSize',10,'FontWeight','bold','ForegroundColor','black','Enable','inactive','Tag','ES_shown','BackgroundColor',[0.99 0.99 0.99]);
        
        uicontrol('Parent',EventPanel,'Style', 'text','Position', [7 261 100 23],'HorizontalAlignment','left','String',' select:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',EventPanel,'Style', 'edit','Position', [60 264 40 20],'HorizontalAlignment','right','String',0,'FontSize',10,'FontWeight','bold','ForegroundColor','black','Enable','inactive','Tag','ES_select','BackgroundColor',[0.99 0.99 0.99]);
        
        % Colorbar slider
        uicontrol('Parent',EventsynchronizationWindow,'Tag','Sync_slider','Style','slider','Position', [384 104 18 453],'Min',0.3,'Max',1,'value',0.3,'SliderStep',[0.01,0.01],'BackgroundColor',[0.99 0.99 0.99],'callback',@draw_ES_network_plot);
        
        %Call draw function
        uicontrol('Parent',EventPanel,'Position',[30 50 80 20],'String','redraw','FontSize',11,'FontWeight','bold','callback',@draw_ES_network_plot);
        
        draw_ES_network_plot;
        
    end

% --- draw Event Synchronization network plot (RB)-------------------------------
    function draw_ES_network_plot(~,~)
        
        global ES ES_figure_active ES_network_figure ES_pos1 EL_NUMS_act;
        ES_pos1 = 0;
        ES_sum_shown = 0;
        ES_count = 0;
        % Define electrode area
        ALL_CHANNELS = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
        Matrix_row = [9 17 25 33 41 49 2 10 18 26 34 42 50 58 3 11 19 27 35 43 51 59 4 12 20 28 36 44 52 60 5 13 21 29 37 45 53 61 6 14 22 30 38 46 54 62 7 15 23 31 39 47 55 63 16 24 32 40 48 56];
        
        set(findobj('Tag','Sync_slider'),'Max',str2double(get(findobj('Tag','Upper_Sync_Thres'),'string')));
        set(findobj('Tag','Sync_slider'),'Min',str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')));
        
        if  get(findobj('Tag','Sync_slider'),'value') < str2double(get(findobj('Tag','Lower_Sync_Thres'),'string'))
            set(findobj('Tag','Sync_slider'),'value',str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')));
        end
        EL_POS(:,1) = floor(1:0.125:8.99);
        for i=1:8
            EL_POS(((i-1)*8)+1:i*8,2) = [1 2 3 4 5 6 7 8];
        end
        
        EL_POSITION(1:6,:) = EL_POS(2:7,:);
        EL_POSITION(7:54,:) = EL_POS(9:56,:);
        EL_POSITION(55:60,:) = EL_POS(58:63,:);
        %        EL_POS(1:6,:) = EL_POSITION(2:7,:)
        %        EL_POS(7:54,:) = EL_POSITION(9:56,:);
        %        EL_POS(55:60,:) = EL_POSITION(58:63,:);
        
        
        EL_NUMS_act = EL_NUMS(NR_SPIKES>2);
        %        save('0_Bic_4test.mat','ES','EL_NUMS_act');
        for i = 1 : size(EL_NUMS_act,2)
            active_EL(i) = Matrix_row(find(ALL_CHANNELS==(EL_NUMS_act(i))));
        end
        if ES_figure_active == 1
            cla(ES_network_figure)
        end
        ES_network_figure = subplot('Position',[0.05 0.2 0.7 0.7],'Color',GUI_Color_BG,'Tag','ES_network_plot');
        cmap = colormap(hot(1001));
        cmap = flip(cmap,1);
        ES_figure_active = 1;
        RES(1:1001) = str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')):(str2double(get(findobj('Tag','Upper_Sync_Thres'),'string'))-str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')))/1000:str2double(get(findobj('Tag','Upper_Sync_Thres'),'string'));
        caxis([str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')) str2double(get(findobj('Tag','Upper_Sync_Thres'),'string'))])
        
        hold all;
        
        % slider_step = (str2double(get(findobj('Tag','Upper_Sync_Thres'),'string'))-str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')))*0.01;
        
        if isempty(active_EL)== 0
            for i = 1:size(active_EL,2)
                for j = 1:size(active_EL,2)
                    if ES(i,j) >= str2double(get(findobj('Tag','Lower_Sync_Thres'),'string'))&& ES(i,j) <= str2double(get(findobj('Tag','Upper_Sync_Thres'),'string')) && (ES(i,j) >= get(findobj('Tag','Sync_slider'),'value'))
                        if i~=j
                            line([EL_POS(active_EL(i),2) EL_POS(active_EL(j),2)],[EL_POS(active_EL(i),1) EL_POS(active_EL(j),1)],'LineWidth',3,'Color',cmap(find(ES(i,j)>=RES,1,'last'),:));
                            ES_sum_shown = ES_sum_shown + ES(i,j);
                            ES_count = ES_count + 1;
                        end
                    end
                end
            end
        end
        
        if ES_count == 0
            ES_mean_shown = 0;
        else
            ES_mean_shown = ES_sum_shown / ES_count;
        end
        
        set(findobj('Tag','ES_shown'),'string',num2str(round(ES_mean_shown*1000)/1000));
        cmap_temp = colormap(hot(60));
        cmap_temp = flip(cmap_temp,1);
        scatter(EL_POSITION(:,1),EL_POSITION(:,2),100,cmap_temp);
        
        set(gca,'Color',GUI_Color_BG);
        set(gca,'xlim',[0 9],'ylim',[0 9]);
        set(gca,'XTickLabel',[],'YTickLabel',[]);
        set(gca,'YDir','Reverse');
        colorbar('peer',ES_network_figure)
        
        caxis([str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')) str2double(get(findobj('Tag','Upper_Sync_Thres'),'string'))])
        set(findobj('Tag','Colorbar'),'YDir','Reverse');
        Tick_number = size(get(findobj('Tag','Colorbar'),'YTickLabel'),1);
        label_temp = (str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')):(str2double(get(findobj('Tag','Upper_Sync_Thres'),'string'))-str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')))/Tick_number:str2double(get(findobj('Tag','Upper_Sync_Thres'),'string'))');
        label_temp = flip(label_temp,2);
        label = num2str(label_temp','%0-.3f');
        set(findobj('Tag','Colorbar'),'YTick',flip(label_temp,2));
        set(findobj('Tag','Colorbar'),'YTickLabel',label);
        scatter(EL_POSITION(:,1),EL_POSITION(:,2),100,'MarkerEdgeColor','black','MarkerFaceColor',[0.5 0.5 0.5]);
        if isempty(active_EL)== 0
            plot = scatter(EL_POS(active_EL,2),EL_POS(active_EL,1),100,'MarkerEdgeColor','black','MarkerFaceColor','y');
        end
        box on
        datacursormode on
        dcm_obj = datacursormode(findobj('Tag','Event_sync_window'));
        set(dcm_obj,'UpdateFcn',@ES_cursorfcn)
        
        hold off;
    end

    function txt = ES_cursorfcn(~,event_obj)
        % Customizes text of data tips
        global ES_pos1 pos EL_NUMS_act ES;
        if  ES_pos1 == 0
            datacursormode off
            datacursormode on
            pos(1,:) = get(event_obj,'Position');
            txt = {(['El ' num2str(pos(1,1)) num2str(pos(1,2))])};
            ES_pos1 = 1;
        else
            pos(2,:) = get(event_obj,'Position');
            txt = {['El ' num2str(pos(1,1)) num2str(pos(1,2)) '-' 'El ' num2str(pos(2,1)) num2str(pos(2,2))]} ;
            ES_pos1 = 0;
            row = find(EL_NUMS_act==(pos(1,1)*10+pos(1,2)));
            col = find(EL_NUMS_act==(pos(2,1)*10+pos(2,2)));
            ES_select = ES(row,col);
            set(findobj('Tag','ES_select'),'string',num2str(round(ES_select*1000)/1000));
        end
    end

% --- Mutual Information (RB)----------------------------------
    function Mutual_Information(source,~)
        
        global MI MI_figure_active
        MI_figure_active  = 0;
        f = SaRa;
        T_temp = 1/f;
        %Tmax = size(RAW.M,1)+1;
        Tmax=rec_dur*SaRa;
        
        L = 400 %400;    % size of the time window in sample points (f_sample = 10.000 Hz -> 400 sample points = 40 ms)
        Step = 400 %400; % step
        % if L == Step: there is no overlaping
        
        
        data_original = SPIKES;
        NS = zeros(1, size(SPIKES,2));
        for i=1:size(SPIKES,2)
            NS(i) = size(find(SPIKES(:,i) ~= 0),1);
        end
        
        % For MI
        NSI = zeros(1, 60);
        data = zeros(Tmax, size(data_original, 2));
        data_binned = zeros(floor(Tmax/Step)+1, size(data_original, 2));
        
        for i=1:size(data_original, 1);
            for j=1:size(data_original,2)
                if data_original(i,j) ~= 0
                    id = floor(data_original(i,j)*f);
                    data(id,j) = 1;
                    
                end
            end
        end
        
        
        for j=1:size(data,2)
            id = 1;
            for k=1:ceil(Tmax/Step)
                if(((k-1)*Step+1+L) > size(data,1))
                    data_binned(id, j) = sum(data(((k-1)*Step+1):end,j));
                else
                    data_binned(id, j) = sum(data(((k-1)*Step+1):((k-1)*Step+1+L-1),j));
                end
                id = id +1;
            end
        end
        
        NSI = sum(data_binned,1);
        vI = find(NSI > 2);
        
        %% Information Theory
        data_binned = data_binned(:,vI);
        
        IN = zeros(size(vI,2));
        U = zeros(size(vI,2));
        IN_sum = 0;
        
        for x=1:size(vI,2)
            for y=1:size(vI,2)
                Hj = Entropy(data_binned(:,x));
                Hk = Entropy(data_binned(:,y));
                
                if Hj ~= 0 && Hk ~= 0
                    MI = MutualInformation(data_binned(:,x), data_binned(:,y));
                    I = MI/min(Hj, Hk);
                else
                    I = 0;
                end
                
                IN(x, y) = I;
                U(x, y) = 2*MI/(Hj + Hk);
            end
            IN_sum = IN_sum + sum(IN(x,x+1:size(IN,2)));
        end
        MI = U;
        MI_mean = IN_sum/(((size(vI,2)-1)^2+(size(vI,2)-1))/2);
        MI_sum = IN_sum;
        MI_mean_shown = 0;
        %save('0_Bic_1test.mat','MI');
        %Main Window
        MutualinformationWindow = figure('Name','Mutual_information','NumberTitle','off','Position',[45 100 600 600],'Toolbar','none','Resize','off','Color',GUI_Color_BG,'Tag','mutual_inf_window');
        
        
        %Main Window header
        uicontrol('Parent', MutualinformationWindow,'Style', 'text','Position', [140 575 250 20],'HorizontalAlignment','center','String','Mutual Information Plot','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Button-Area
        muinfPanel=uipanel('Parent',MutualinformationWindow,'Units','pixels','Position',[485 1 115 599],'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [25 575 60 20],'HorizontalAlignment','left','String', 'Display:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %         uicontrol('Parent',EventPanel,'Style','text','Position', [35 550 100 20],'HorizontalAlignment','left','String', 'Sync Threshold:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Colorbar boundary edit-fields
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 513 65 40],'HorizontalAlignment','left','String','Upper Boundary:','FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',muinfPanel,'Units','Pixels','Position', [65 525 40 20],'Tag','Upper_MI_Thres','HorizontalAlignment','right','FontSize',8,'Value',1.0,'String',1.0,'Style','edit');
        
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 87 65 40],'HorizontalAlignment','left','String','Lower Boundary:','FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',muinfPanel,'Units','Pixels','String','Lower Boundary','Position', [67 100 40 20],'Tag','Lower_MI_Thres','HorizontalAlignment','right','FontSize',8,'Value',0.3,'String',0.3,'Style','edit');
        
        %Synchronicity indicators
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 350 100 22],'HorizontalAlignment','left','String',' Mutual','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 330 100 22],'HorizontalAlignment','left','String',' Information','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 307 100 23],'HorizontalAlignment','left','String',' mean:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',muinfPanel,'Style', 'edit','Position', [60 310 40 20],'HorizontalAlignment','right','String',num2str(round(MI_mean*1000)/1000),'FontSize',10,'FontWeight','bold','ForegroundColor','black','Enable','inactive','BackgroundColor',[0.99 0.99 0.99]);
        
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 284 100 23],'HorizontalAlignment','left','String',' visible:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',muinfPanel,'Style', 'edit','Position', [60 287 40 20],'HorizontalAlignment','right','String',num2str(round(MI_mean_shown*1000)/1000),'FontSize',10,'FontWeight','bold','ForegroundColor','black','Enable','inactive','Tag','MI_shown','BackgroundColor',[0.99 0.99 0.99]);
        
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 261 100 23],'HorizontalAlignment','left','String',' select:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',muinfPanel,'Style', 'edit','Position', [60 264 40 20],'HorizontalAlignment','right','String',0,'FontSize',10,'FontWeight','bold','ForegroundColor','black','Enable','inactive','Tag','MI_select','BackgroundColor',[0.99 0.99 0.99]);
        
        % Colorbar slider
        uicontrol('Parent',MutualinformationWindow,'Tag','MI_slider','Style','slider','Position', [384 104 18 453],'Min',0.3,'Max',1,'value',0.3,'SliderStep',[0.01,0.01],'BackgroundColor',[0.99 0.99 0.99],'callback',@draw_MI_network_plot);
        
        %Call draw function
        uicontrol('Parent',muinfPanel,'Position',[30 50 80 20],'String','redraw','FontSize',11,'FontWeight','bold','callback',@draw_MI_network_plot);
        
        draw_MI_network_plot;
    end

% --- draw Mutual Information network plot (RB) -------------------------------
    function draw_MI_network_plot(~,~)
        
        global MI MI_figure_active MI_network_figure MI_pos1 EL_NUMS_act;
        MI_pos1 = 0;
        MI_sum_shown = 0;
        MI_count = 0;
        % Define electrode area
        ALL_CHANNELS = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
        Matrix_row = [9 17 25 33 41 49 2 10 18 26 34 42 50 58 3 11 19 27 35 43 51 59 4 12 20 28 36 44 52 60 5 13 21 29 37 45 53 61 6 14 22 30 38 46 54 62 7 15 23 31 39 47 55 63 16 24 32 40 48 56];
        
        set(findobj('Tag','MI_slider'),'Max',str2double(get(findobj('Tag','Upper_MI_Thres'),'string')));
        set(findobj('Tag','MI_slider'),'Min',str2double(get(findobj('Tag','Lower_MI_Thres'),'string')));
        
        if  get(findobj('Tag','MI_slider'),'value') < str2double(get(findobj('Tag','Lower_MI_Thres'),'string'))
            set(findobj('Tag','MI_slider'),'value',str2double(get(findobj('Tag','Lower_MI_Thres'),'string')));
        end
        EL_POS(:,1) = floor(1:0.125:8.99);
        for i=1:8
            EL_POS(((i-1)*8)+1:i*8,2) = [1 2 3 4 5 6 7 8];
        end
        
        EL_POSITION(1:6,:) = EL_POS(2:7,:);
        EL_POSITION(7:54,:) = EL_POS(9:56,:);
        EL_POSITION(55:60,:) = EL_POS(58:63,:);
        
        EL_NUMS_act = EL_NUMS(NR_SPIKES>2);
        
        for i = 1 : size(EL_NUMS_act,2)
            active_EL(i) = Matrix_row(find(ALL_CHANNELS==(EL_NUMS_act(i))));
        end
        if MI_figure_active == 1
            cla(MI_network_figure)
        end
        MI_network_figure = subplot('Position',[0.05 0.2 0.7 0.7],'Color',GUI_Color_BG,'Tag','MI_network_plot');
        cmap = colormap(hot(1001));
        cmap = flip(cmap,1);
        MI_figure_active = 1;
        RES(1:1001) = str2double(get(findobj('Tag','Lower_MI_Thres'),'string')):(str2double(get(findobj('Tag','Upper_MI_Thres'),'string'))-str2double(get(findobj('Tag','Lower_MI_Thres'),'string')))/1000:str2double(get(findobj('Tag','Upper_MI_Thres'),'string'));
        caxis([str2double(get(findobj('Tag','Lower_MI_Thres'),'string')) str2double(get(findobj('Tag','Upper_MI_Thres'),'string'))])
        
        hold all;
        
        % slider_step = (str2double(get(findobj('Tag','Upper_MI_Thres'),'string'))-str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')))*0.01;
        
        if isempty(active_EL)== 0
            for i = 1:size(active_EL,2)
                for j = 1:size(active_EL,2)
                    if MI(i,j) >= str2double(get(findobj('Tag','Lower_MI_Thres'),'string'))&& MI(i,j) <= str2double(get(findobj('Tag','Upper_MI_Thres'),'string')) && (MI(i,j) >= get(findobj('Tag','MI_slider'),'value'))
                        if i~=j
                            line([EL_POS(active_EL(i),2) EL_POS(active_EL(j),2)],[EL_POS(active_EL(i),1) EL_POS(active_EL(j),1)],'LineWidth',3,'Color',cmap(find(MI(i,j)>=RES,1,'last'),:));
                            MI_sum_shown = MI_sum_shown + MI(i,j);
                            MI_count = MI_count + 1;
                        end
                    end
                end
            end
        end
        
        if MI_count == 0
            MI_mean_shown = 0;
        else
            MI_mean_shown = MI_sum_shown / MI_count;
        end
        
        set(findobj('Tag','MI_shown'),'string',num2str(round(MI_mean_shown*1000)/1000));
        cmap_temp = colormap(hot(60));
        cmap_temp = flip(cmap_temp,1);
        scatter(EL_POSITION(:,1),EL_POSITION(:,2),100,cmap_temp);
        
        set(gca,'Color',GUI_Color_BG);
        set(gca,'xlim',[0 9],'ylim',[0 9]);
        set(gca,'XTickLabel',[],'YTickLabel',[]);
        set(gca,'YDir','Reverse');
        colorbar('peer',MI_network_figure)
        
        caxis([str2double(get(findobj('Tag','Lower_MI_Thres'),'string')) str2double(get(findobj('Tag','Upper_MI_Thres'),'string'))])
        set(findobj('Tag','Colorbar'),'YDir','Reverse');
        Tick_number = size(get(findobj('Tag','Colorbar'),'YTickLabel'),1);
        label_temp = (str2double(get(findobj('Tag','Lower_MI_Thres'),'string')):(str2double(get(findobj('Tag','Upper_MI_Thres'),'string'))-str2double(get(findobj('Tag','Lower_MI_Thres'),'string')))/Tick_number:str2double(get(findobj('Tag','Upper_MI_Thres'),'string'))');
        label_temp = flip(label_temp,2);
        label = num2str(label_temp','%0-.3f');
        set(findobj('Tag','Colorbar'),'YTick',flip(label_temp,2));
        set(findobj('Tag','Colorbar'),'YTickLabel',label);
        scatter(EL_POSITION(:,1),EL_POSITION(:,2),100,'MarkerEdgeColor','black','MarkerFaceColor',[0.5 0.5 0.5]);
        if isempty(active_EL)== 0
            plot = scatter(EL_POS(active_EL,2),EL_POS(active_EL,1),100,'MarkerEdgeColor','black','MarkerFaceColor','y');
        end
        box on
        datacursormode on
        dcm_obj = datacursormode(findobj('Tag','mutual_inf_window'));
        set(dcm_obj,'UpdateFcn',@MI_cursorfcn)
        
        hold off;
    end

    function txt = MI_cursorfcn(~,event_obj)
        % Customizes text of data tips
        global MI_pos1 pos EL_NUMS_act MI;
        if  MI_pos1 == 0
            datacursormode off
            datacursormode on
            pos(1,:) = get(event_obj,'Position');
            txt = {(['El ' num2str(pos(1,1)) num2str(pos(1,2))])};
            MI_pos1 = 1;
        else
            pos(2,:) = get(event_obj,'Position');
            txt = {['El ' num2str(pos(1,1)) num2str(pos(1,2)) '-' 'El ' num2str(pos(2,1)) num2str(pos(2,2))]} ;
            MI_pos1 = 0;
            row = find(EL_NUMS_act==(pos(1,1)*10+pos(1,2)));
            col = find(EL_NUMS_act==(pos(2,1)*10+pos(2,2)));
            MI_select = MI(row,col);
            set(findobj('Tag','MI_select'),'string',num2str(round(MI_select*1000)/1000));
        end
    end

% --- Cross Correlation (RB)----------------------------------
    function Cross_correlation(source,event)
        
        global CC CC_figure_active
        CC_figure_active  = 0;
        
        
        TS=SPIKEZ.TS; % create lokal variable containing the spikes
        
        % delete all electrodes whose number of spikes are less than FR_min
        FR_min = 6; % 6 spikes/file -> here per minute
        for n=1:size(TS,2)
            if length(nonzeros(TS(:,n)))< FR_min
                TS(:,n)=0;
            end
        end
        
        % Cross-correlation:
        if 1
            disp('Cross-correlation')
            tic
            win=rec_dur;
            bin=0.04;
            step=bin;
            lag=NaN;
            binary=0; % no binary binning but multistate binning
            STRUCT=Crosscorrelation_call(TS,rec_dur,win,bin,step,lag,binary);
            SYNC.CC=STRUCT.mean;
            CC_mean= STRUCT.mean;
            CC_mean_shown = 0;
            CC=STRUCT.M;
            CC(isnan(CC))=0; % necessary as in this function all elements are summed and NaN as summand gives NaN als result
            toc
        end
        
        
        CrosscorrelationWindow = figure('Name','cross_correlation','NumberTitle','off','Position',[45 100 600 600],'Toolbar','none','Resize','off','Color',GUI_Color_BG,'Tag','mutual_inf_window');
        
        
        %Main Window header
        uicontrol('Parent', CrosscorrelationWindow,'Style', 'text','Position', [140 575 250 20],'HorizontalAlignment','center','String','Cross-Correlation Plot','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Button-Area
        muinfPanel=uipanel('Parent',CrosscorrelationWindow,'Units','pixels','Position',[485 1 115 599],'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [25 575 60 20],'HorizontalAlignment','left','String', 'Display:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %         uicontrol('Parent',EventPanel,'Style','text','Position', [35 550 100 20],'HorizontalAlignment','left','String', 'Sync Threshold:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Colorbar boundary edit-fields
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 513 65 40],'HorizontalAlignment','left','String','Upper Boundary:','FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',muinfPanel,'Units','Pixels','Position', [65 525 40 20],'Tag','Upper_CC_Thres','HorizontalAlignment','right','FontSize',8,'Value',1.0,'String',1.0,'Style','edit');
        
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 87 65 40],'HorizontalAlignment','left','String','Lower Boundary:','FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',muinfPanel,'Units','Pixels','String','Lower Boundary','Position', [67 100 40 20],'Tag','Lower_CC_Thres','HorizontalAlignment','right','FontSize',8,'Value',0.3,'String',0.3,'Style','edit');
        
        %Synchronicity indicators
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 350 100 22],'HorizontalAlignment','left','String',' Cross-','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 330 100 22],'HorizontalAlignment','left','String',' Correlation','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 307 100 23],'HorizontalAlignment','left','String',' mean:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',muinfPanel,'Style', 'edit','Position', [60 310 40 20],'HorizontalAlignment','right','String',num2str(round(CC_mean*1000)/1000),'FontSize',10,'FontWeight','bold','ForegroundColor','black','Enable','inactive','BackgroundColor',[0.99 0.99 0.99]);
        
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 284 100 23],'HorizontalAlignment','left','String',' visible:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',muinfPanel,'Style', 'edit','Position', [60 287 40 20],'HorizontalAlignment','right','String',num2str(round(CC_mean_shown*1000)/1000),'FontSize',10,'FontWeight','bold','ForegroundColor','black','Enable','inactive','Tag','CC_shown','BackgroundColor',[0.99 0.99 0.99]);
        
        uicontrol('Parent',muinfPanel,'Style', 'text','Position', [7 261 100 23],'HorizontalAlignment','left','String',' select:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.99 0.99 0.99]);
        uicontrol('Parent',muinfPanel,'Style', 'edit','Position', [60 264 40 20],'HorizontalAlignment','right','String',0,'FontSize',10,'FontWeight','bold','ForegroundColor','black','Enable','inactive','Tag','CC_select','BackgroundColor',[0.99 0.99 0.99]);
        
        % Colorbar slider
        uicontrol('Parent',CrosscorrelationWindow,'Tag','CC_slider','Style','slider','Position', [384 104 18 453],'Min',0.3,'Max',1,'value',0.3,'SliderStep',[0.01,0.01],'BackgroundColor',[0.99 0.99 0.99],'callback',@draw_CC_network_plot);
        
        %Call draw function
        uicontrol('Parent',muinfPanel,'Position',[30 50 80 20],'String','redraw','FontSize',11,'FontWeight','bold','callback',@draw_CC_network_plot);
        
        draw_CC_network_plot;
    end

% --- draw CC network plot (RB) -------------------------------
    function draw_CC_network_plot(~,~)
        
        global CC CC_figure_active CC_network_figure CC_pos1 EL_NUMS_act;
        CC_pos1 = 0;
        CC_sum_shown = 0;
        CC_count = 0;
        % Define electrode area
        ALL_CHANNELS = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
        Matrix_row = [9 17 25 33 41 49 2 10 18 26 34 42 50 58 3 11 19 27 35 43 51 59 4 12 20 28 36 44 52 60 5 13 21 29 37 45 53 61 6 14 22 30 38 46 54 62 7 15 23 31 39 47 55 63 16 24 32 40 48 56];
        
        set(findobj('Tag','CC_slider'),'Max',str2double(get(findobj('Tag','Upper_CC_Thres'),'string')));
        set(findobj('Tag','CC_slider'),'Min',str2double(get(findobj('Tag','Lower_CC_Thres'),'string')));
        
        if  get(findobj('Tag','CC_slider'),'value') < str2double(get(findobj('Tag','Lower_CC_Thres'),'string'))
            set(findobj('Tag','CC_slider'),'value',str2double(get(findobj('Tag','Lower_CC_Thres'),'string')));
        end
        EL_POS(:,1) = floor(1:0.125:8.99);
        for i=1:8
            EL_POS(((i-1)*8)+1:i*8,2) = [1 2 3 4 5 6 7 8];
        end
        
        EL_POSITION(1:6,:) = EL_POS(2:7,:);
        EL_POSITION(7:54,:) = EL_POS(9:56,:);
        EL_POSITION(55:60,:) = EL_POS(58:63,:);
        
        EL_NUMS_act = EL_NUMS(NR_SPIKES>2);
        
        for i = 1 : size(EL_NUMS_act,2)
            active_EL(i) = Matrix_row(find(ALL_CHANNELS==(EL_NUMS_act(i))));
        end
        if CC_figure_active == 1
            cla(CC_network_figure)
        end
        CC_network_figure = subplot('Position',[0.05 0.2 0.7 0.7],'Color',GUI_Color_BG,'Tag','CC_network_plot');
        cmap = colormap(hot(1001));
        cmap = flip(cmap,1);
        CC_figure_active = 1;
        RES(1:1001) = str2double(get(findobj('Tag','Lower_CC_Thres'),'string')):(str2double(get(findobj('Tag','Upper_CC_Thres'),'string'))-str2double(get(findobj('Tag','Lower_CC_Thres'),'string')))/1000:str2double(get(findobj('Tag','Upper_CC_Thres'),'string'));
        caxis([str2double(get(findobj('Tag','Lower_CC_Thres'),'string')) str2double(get(findobj('Tag','Upper_CC_Thres'),'string'))])
        
        hold all;
        
        % slider_step = (str2double(get(findobj('Tag','Upper_CC_Thres'),'string'))-str2double(get(findobj('Tag','Lower_Sync_Thres'),'string')))*0.01;
        
        if isempty(active_EL)== 0
            for i = 1:size(active_EL,2)
                for j = 1:size(active_EL,2)
                    if CC(i,j) >= str2double(get(findobj('Tag','Lower_CC_Thres'),'string'))&& CC(i,j) <= str2double(get(findobj('Tag','Upper_CC_Thres'),'string')) && (CC(i,j) >= get(findobj('Tag','CC_slider'),'value'))
                        if i~=j
                            line([EL_POS(active_EL(i),2) EL_POS(active_EL(j),2)],[EL_POS(active_EL(i),1) EL_POS(active_EL(j),1)],'LineWidth',3,'Color',cmap(find(CC(i,j)>=RES,1,'last'),:));
                            CC_sum_shown = CC_sum_shown + CC(i,j);
                            CC_count = CC_count + 1;
                        end
                    end
                end
            end
        end
        
        if CC_count == 0
            CC_mean_shown = 0;
        else
            CC_mean_shown = CC_sum_shown / CC_count;
        end
        
        set(findobj('Tag','CC_shown'),'string',num2str(round(CC_mean_shown*1000)/1000));
        cmap_temp = colormap(hot(60));
        cmap_temp = flip(cmap_temp,1);
        scatter(EL_POSITION(:,1),EL_POSITION(:,2),100,cmap_temp);
        
        set(gca,'Color',GUI_Color_BG);
        set(gca,'xlim',[0 9],'ylim',[0 9]);
        set(gca,'XTickLabel',[],'YTickLabel',[]);
        set(gca,'YDir','Reverse');
        colorbar('peer',CC_network_figure)
        
        caxis([str2double(get(findobj('Tag','Lower_CC_Thres'),'string')) str2double(get(findobj('Tag','Upper_CC_Thres'),'string'))])
        set(findobj('Tag','Colorbar'),'YDir','Reverse');
        Tick_number = size(get(findobj('Tag','Colorbar'),'YTickLabel'),1);
        label_temp = (str2double(get(findobj('Tag','Lower_CC_Thres'),'string')):(str2double(get(findobj('Tag','Upper_CC_Thres'),'string'))-str2double(get(findobj('Tag','Lower_CC_Thres'),'string')))/Tick_number:str2double(get(findobj('Tag','Upper_CC_Thres'),'string'))');
        label_temp = flip(label_temp,2);
        label = num2str(label_temp','%0-.3f');
        set(findobj('Tag','Colorbar'),'YTick',flip(label_temp,2));
        set(findobj('Tag','Colorbar'),'YTickLabel',label);
        scatter(EL_POSITION(:,1),EL_POSITION(:,2),100,'MarkerEdgeColor','black','MarkerFaceColor',[0.5 0.5 0.5]);
        if isempty(active_EL)== 0
            plot = scatter(EL_POS(active_EL,2),EL_POS(active_EL,1),100,'MarkerEdgeColor','black','MarkerFaceColor',[0.5 0.5 0.5]); % 'y' has been changed to [0.5 0.5 0.5] to hide active el. (MC)
        end
        box on
        datacursormode on
        dcm_obj = datacursormode(findobj('Tag','mutual_inf_window'));
        set(dcm_obj,'UpdateFcn',@CC_cursorfcn)
        
        hold off;
    end

    function txt = CC_cursorfcn(~,event_obj)
        % Customizes text of data tips
        global CC_pos1 pos EL_NUMS_act CC;
        if  CC_pos1 == 0
            datacursormode off
            datacursormode on
            pos(1,:) = get(event_obj,'Position');
            txt = {(['El ' num2str(pos(1,1)) num2str(pos(1,2))])};
            CC_pos1 = 1;
        else
            pos(2,:) = get(event_obj,'Position');
            txt = {['El ' num2str(pos(1,1)) num2str(pos(1,2)) '-' 'El ' num2str(pos(2,1)) num2str(pos(2,2))]} ;
            CC_pos1 = 0;
            row = find(EL_NUMS_act==(pos(1,1)*10+pos(1,2)));
            col = find(EL_NUMS_act==(pos(2,1)*10+pos(2,2)));
            CC_select = CC(row,col);
            set(findobj('Tag','CC_select'),'string',num2str(round(CC_select*1000)/1000));
        end
    end


% --- Measure Sync (MC) ------------------------------------------------
    function MeasureSyncButtonCallback(hObj,event)
        
        % GUI
        h_main = figure('Units','Normalized','Position',[.25 .3 .3 .2],'Name','Measure spike train synchrony','Color',GUI_Color_BG);
        
        %h_p1=uipanel('Parent',h_main,'Position',[0.01 0.01 0.99 0.9]);
        %   axes('Parent',h_p1,'Units','Normalized','Position',[.1 .1 0.8 .8],'Tag','axes_rasterplot');
        
        
        
        h_p2=uipanel('Parent',h_main,'Position',[0.01 0.01 0.99 0.9],'BackgroundColor',GUI_Color_BG);
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_SC','String','Spike-contrast','units','Normalized','position', [.1 .75 .3 .2],'value',1,'TooltipString','Calculate spike train synchrony using "Spike-contrast".');
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_CC_Selinger','String','Cross-correlation (Selinger)','units','Normalized','position', [.1 .5 .3 .2],'value',1,'TooltipString','Calculate spike train synchrony using cross-correlation (bin size 500 ms) [Selinger et. al].');
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_MI1','String','Mutual Information 1','units','Normalized','position', [.1 .25 .3 .2],'value',1,'TooltipString','Calculate spike train synchrony using Mutual Information (bin size 500 ms). Normalization method 1');
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_MI2','String','Mutual Information 2','units','Normalized','position', [.45 .75 .3 .2],'value',1,'TooltipString','Calculate spike train synchrony using Mutual Information (bin size 500 ms). Normalization method 2.');
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_PS','String','Phase-synchronization','units','Normalized','position', [.45 .5 .3 .2],'value',1,'TooltipString','Calculate spike train synchrony using Phasesynchronization.');
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_CC_old','String','Cross-correlation (old)','units','Normalized','position', [.45 .25 .3 .2],'value',1,'TooltipString','Calculate spike train synchrony using cross-correlation (bin size 40 ms).');
        
        % Button
        uicontrol('Parent',h_p2,'Units','Normalized','Position',[.6 .1 0.3 0.15],'Tag','CELL_convertButton','String','Start','FontSize',9,'TooltipString','Start measuring synchrony between all spike trains','Callback',@MeasureSynchrony);
        
        
    end

% --- Measure Sync (MC) ------------------------------------------------
    function MeasureSynchrony(~,~)
        
        TS=SPIKEZ.TS;
        clear SYNC
        
        % FR_min:
        FR_min = 6; % 6 spikes/file -> here per minute
        for n=1:size(TS,2)
            if length(nonzeros(TS(:,n)))< FR_min
                TS(:,n)=0;
            end
        end
        
        % Spike-contrast:
        if get(findobj(gcf,'Tag','checkbox_SC'),'Value')==1
            disp('Spike-contrast')
            clear STRUCT
            STRUCT.S=SpikeContrast(TS,rec_dur);
            SYNC.SC=STRUCT.S;
        end
        
        % Cross-correlation old:
        if get(findobj(gcf,'Tag','checkbox_CC_old'),'Value')==1
            disp('Cross-correlation (old: bin size 40 ms)')
            bin=0.04;
            step=bin;
            lag=NaN;
            binary=0; % no binary binning but multistate binning
            clear STRUCT
            STRUCT=SyncMeasure_Crosscorrelation(TS,rec_dur,bin,step,lag,binary);
            SYNC.CC=STRUCT.mean_M;
        end
        
        % Correlation-Selinger:
        if get(findobj(gcf,'Tag','checkbox_CC_Selinger'),'Value')==1
            disp('Cross-correlation (Selinger et. al)')
            bin=0.5;
            step=bin;
            binary=1; % binary binning
            clear STRUCT
            STRUCT=SyncMeasure_Crosscorrelation_Selinger(TS,rec_dur,bin,step,binary);
            SYNC.CCselinger=STRUCT.mean_M;
        end
        
        % MI 1:
        if get(findobj(gcf,'Tag','checkbox_MI1'),'Value')==1
            disp('Mutual Information (normalization 1)')
            bin=0.04;
            step=bin;
            binary=0; % no binary binning but multistate binning
            norm=1; % norm=1: MI/min(H1,H2), norm=2: 2*MI/(H1+H2) -> norm=2 is more stable
            STRUCT=SyncMeasure_MutualInformation(TS,rec_dur,bin,step,binary,norm);
            SYNC.MI1=STRUCT.mean_M;
        end
        
        % MI 2:
        if get(findobj(gcf,'Tag','checkbox_MI2'),'Value')==1
            disp('Mutual Information (normalization 2)')
            bin=0.04;
            step=bin;
            binary=0; % no binary binning but multistate binning
            norm=2; % norm=1: MI/min(H1,H2), norm=2: 2*MI/(H1+H2) -> norm=2 is more stable
            clear STRUCT
            STRUCT=SyncMeasure_MutualInformation(TS,rec_dur,bin,step,binary,norm) ;
            SYNC.MI2=STRUCT.mean_M;
        end
        
        % ES:
        if get(findobj(gcf,'Tag','checkbox_ES'),'Value')==1
            disp('Event Synchronization')
            
            clear STRUCT
            tauMax=0.04;
            STRUCT.M=Event_Sync_MC(TS,tauMax);
            SYNC.ES=mean(nonzeros(STRUCT.M),'omitnan');
            
        end
        
        % PS:
        
        if get(findobj(gcf,'Tag','checkbox_PS'),'Value')==1
            disp('Phase Synchronization') % shiva faghat dar matlab neshan midahad
            STRUCT=SyncMeasure_Phasesynchronization(TS,rec_dur,SaRa);
            SYNC.PS=STRUCT.S;
        end
        
        %--------shiva------mit HPC
        %        tic
        %        if get(findobj(gcf,'Tag','checkbox_PS'),'Value')==1
        %            disp('Phase Synchronization') % shiva faghat dar matlab neshan midahad
        %
        %        c = parcluster('BioMEMS');                  % Verbindung erstellen
        %        j = createJob(c);                           % Einen Job erstellen
        %        t1 = createTask(j, @SyncMeasure_Phasesynchronization , 4, {TS,rec_dur,SaRa});
        %        submit(j);          % Starten der Jobs
        %        wait(j);            % Warten bis zur Fertigstellung
        %        STRUCT=t1.OutputArguments{1,1};
        %        tim1=t1.OutputArguments{2,1};
        %        tim2=t1.OutputArguments{3,1};
        %        tim3=t1.OutputArguments{4,1};
        %        delete(j);
        %
        %        SYNC.PS=STRUCT.S;
        %        end
        %        toc
        %------shiva-----ende HPC
        
        disp(SYNC)
        
        
    end

% --- Estimate Connectivity (MC) ---------------------------------------
    function EstimateConnectivityButtonCallback(~,~)
        
        % GUI
        h_main = figure('Position',[150 50 700 660],'Name','Connectivity','Color',GUI_Color_BG);
        
        h_p1=uipanel('Parent',h_main,'Position',[0.01 0.01 0.99 0.9],'BackgroundColor',GUI_Color_BG);
        axes('Parent',h_p1,'Units','Normalized','Position',[.1 .1 0.8 .8],'Tag','axes_graph');
        
        % Checkboxes
        h_p2=uipanel('Parent',h_main,'Position',[0.01 0.9 0.99 0.1],'BackgroundColor',GUI_Color_BG);
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_Th','String','Use surrogate threshold','units','Normalized','position', [.6 .5 .3 .3],'value',0,'TooltipString','Estimate connectivity using TSPE and delete connections that are not significant according to a surrogate data procedure.');
        uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_CircularGraph','String','Circular graph','units','Normalized','position', [.2 .5 .3 .3],'value',0,'TooltipString','Instead of MEA-Layout use circular Graph.');
        
        
        % Button
        uicontrol('Parent',h_p2,'Units','Normalized','Position',[.6 .1 0.3 0.3],'Tag','CELL_convertButton','String','Start','FontSize',9,'TooltipString','Start estimating connectivity','Callback',@EstimateConnectivityStartButtonCallback);
        
        % define coordinates for plot
        [xx,yy]=get_X_Y_CoordinatesFromMeaLayout(EL_NAMES,HDmode);
        
        % dummy connectivity matrix to create graph
        plotElectrodesOnly(xx,yy)
        
    end

    function EstimateConnectivityStartButtonCallback(~,~)
        [CM,CM_exh,CM_inh,CM_reduced, CM_exh_reduced, CM_inh_reduced]=estimateConnectivity(SPIKEZ);
        
        %[SW,C,L]=getSmallWorldness(CM_reduced);
        
        %[D, D_in, D_out]=getMeanNodeDegree(CM_reduced);
        
        flag_isMeaLayout = not(get(findobj(gcf,'Tag','checkbox_CircularGraph'),'Value'));
        
        handle=gca;
        cla(handle) % clear axis
        plotConnectivity(CM,EL_NAMES,flag_isMeaLayout)
        
        % calculate graph theory mesures (e.g. cluster coefficient)
        if 0
            flag_binary=0; % use weighted matrix (not binary, better performance, see Master thesis of Nahid Nafez)
            graphMeasures=getAllGraphParameter(CM,flag_binary) % calculate and output the graph measures
        end
    end

% --- Calculate Connectivity (MC) --------------------------------------
    function [CM,CM_exh,CM_inh, CM_reduced, CM_exh_reduced, CM_inh_reduced]=estimateConnectivity(SPIKEZ)
        
        flag_waitbar = 1;
        
        [TS_reduced, activeElIdx] = reduceTSsize(SPIKEZ.TS);
        
        if get(findobj(gcf,'Tag','checkbox_Th'),'Value')==0
            if 0 %HDmode % not working yet
                j=initHPC();
                task = createTask(j, @TSPE_call, 3, {TS_reduced, SPIKEZ.PREF.rec_dur, flag_waitbar});   % % (Jobname, @Funktion, Anzahl der R�ckgebevariablen,{�bergabeparameter});
                [CM_reduced,CM_exh_reduced,CM_inh_reduced]=closeHPC(j,task);
            else
                [CM_reduced,CM_exh_reduced,CM_inh_reduced]=TSPE_call(TS_reduced, SPIKEZ.PREF.rec_dur, flag_waitbar);
            end
        else
            [CM_reduced,CM_exh_reduced,CM_inh_reduced]=TSPE_withSurrogateThreshold_call(TS_reduced, SPIKEZ.PREF.rec_dur,flag_waitbar);
        end
        
        [CM,CM_exh,CM_inh] = rearrangeElectrodePosition(CM_reduced,CM_exh_reduced,CM_inh_reduced,activeElIdx,nr_channel);
        
        
        
    end

% --- Plot Connectivity (MC) --------------------------------------
    function plotConnectivity(CM,EL_NAMES,flag_isMeaLayout)
        % define coordinates for plot
        [xx,yy]=get_X_Y_CoordinatesFromMeaLayout(EL_NAMES,HDmode);
        
        % apply threshold (only use connections bigger than 2*std(CM)
        factor=2; % see master thesis of Stefano De Blasi
        [CM,CM_exh,CM_inh]=applyEasyThresholdToCM(CM,factor);
        
        hs=subplot(1,1,1);
        
        if flag_isMeaLayout
            if HDmode
                [hs,h_exh,h_inh]=plotGraph_HDMEA_Layout(CM_exh,CM_inh,xx,yy,hs);
            else
                [hs,h_exh,h_inh]=plotGraph_MEA_Layout(CM_exh,CM_inh,xx,yy,hs);
            end
        else
            circularGraph(CM)
        end
    end

% --- Spike-contrast (MC) ----------------------------------------------
    function SpikeContrastButtonCallback(~,~)
        
        % GUI
        h_main = figure('Units','Normalized','Position',[.1 .3 .6 .6],'Name','Spike-contrast','Color',GUI_Color_BG);
        
        h_p1=uipanel('Parent',h_main,'Position',[0.01 0.01 0.99 0.9],'BackgroundColor',GUI_Color_BG);
        
        pause(0.05)
        
        binStepFactor = 2;
        fig=1;
        rec=0;
        ax = axes(h_p1); % generate axes to plot into it
        SpikeContrast_figure(SPIKEZ.TS,SPIKEZ.PREF.rec_dur,binStepFactor,fig,rec,ax)
    end

% --- Clear Artefacts (MC) ---------------------------------------------
    function clearArtefactsCallback(~,~)
        
        hw=waitbar(0,'Clearing Artefacts');
        
        % calc ISIs
        for n=1:size(SPIKEZ.TS,2)
            
            
            if ~isempty(nonzeros(SPIKEZ.TS(:,n)))
                
                TS = idle_time(SPIKEZ.TS(:,n),0.3); % first delete all spikes that are closer than 300 ms ("bursts" artefacts)
                ISIs = diff(nonzeros(TS));
                
                [ISIhist, edges, bin] = histcounts(ISIs,[0 .1 .2 .3 .4 .5 .6 .7 .8]); % Bin width 100 ms, as temporal variation of artefacts is in this range
                
                numArtefacts = ISIhist(4)+ISIhist(5); % artefact T is between 300 ... 500 ms -> array position 4
                numSpikes = length(nonzeros(TS));
                
                ratio = numArtefacts/numSpikes;
                
                % clear electrode if more than 50 % of all spikes are artefacts
                if ratio >= 0.5
                    SPIKEZ.TS(:,n) = 0;
                    disp(['Electrode cleared: #' num2str(n)])
                end
                
                waitbar(n/size(SPIKEZ.TS,2),hw,'Clearing Artefacts');
                
            end
        end
        
        close(hw)
        
        if HDrawdata || HDspikedata
            HDredraw
        else
            redraw
        end
        
        
    end

% -------------------- Spike Analyse (RB)-------------------------------
    function Spike_Analyse (~,~)
        
        Variables = [{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Max-Min-Max ratio'};{'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
            {'Wavelet Energy 2'};{'Wavelet Energy 3'}];
        
        Variables_var =[{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Max-Min-Max ratio'};{'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
            {'Wavelet Energy 2'};{'Wavelet Energy 3'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};
            {'Left Spk. Angle(Neg./var.'};{'Right Spk. Angle(Neg./var.)'}];
        
        Var_Hist = [{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Max-Min-Max ratio'};{'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
            {'Wavelet Energy 2'};{'Wavelet Energy 3'}];
        
        Var_var_Hist =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Max-Min-Max ratio'};{'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
            {'Wavelet Energy 2'};{'Wavelet Energy 3'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};
            {'Right Spk. Angle(Neg./var.)'}];
        
        Var_both = [{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Max-Min-Max ratio'}];
        
        Var_Hist_both =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Max-Min-Max ratio'}];
        
        Var_no_wave =[{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Max-Min-Max ratio'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};{'Right Spk. Angle(Neg./var.)'}];
        
        Var_Hist_no_wave =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Max-Min-Max ratio'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};{'Right Spk. Angle(Neg./var.)'}];
        
        units = [{'Voltage / uV'};{'Voltage / uV'};{'Scalar'};{'Energy / V ^2 / s'};{'Energy / V ^2 / s'};{'Time / ms'};{'Scalar'};{'Scalar'};
            {'Scalar'};{'Scalar'};{'Gradient uV / s'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};
            {'Voltage / uV'};{'Time / ms'};{'Scalar'};{'Scalar'};];
        
        if varTdata~=1
            V = Variables;
            VH = Var_Hist;
        else
            V = Variables_var;
            VH =  Var_var_Hist;
        end
        
        preti = (0.5:1000/SaRa:2);
        postti = (0.5:1000/SaRa:2);
        Spike = 0;
        first = true;
        first2 = false;
        Elektrode=[];
        Variable1=1;
        Variable2=1;
        pretime=1;
        posttime=1;
        ST = 1;
        Min(1:(size(SPIKES,1))) = zeros;
        Max(1:(size(SPIKES,1))) = zeros;
        XX=[];
        Class(1:size(SPIKES,1))= zeros;
        counter = 0;
        check = [];
        SPIKES_Discrete = [];
        k_old=-1;
        
        %main Window
        SpikeAnalyseWindow = figure('Name','Spike Analyse','NumberTitle','off','Position',[45 30 1270 750],'Toolbar','none','Resize','off');
        uicontrol('Parent',SpikeAnalyseWindow,'Style', 'text','Position', [1082 398 200 20],'HorizontalAlignment','left','String', 'Spike Visualization:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikeAnalyseWindow,'Style', 'text','Position', [697 398 120 20],'HorizontalAlignment','left','String', 'Clustering:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Button-Field
        ControlPanel=uipanel('Parent',SpikeAnalyseWindow,'Units','pixels','Position',[10 360 615 360],'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 331 100 20],'HorizontalAlignment','left','String', 'General:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 228 100 20],'HorizontalAlignment','left','String', 'Histogram:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 331 100 20],'HorizontalAlignment','left','String', 'Statistics:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Electrode Selection
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 312 100 20],'HorizontalAlignment','left','String', 'Electrode: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [93 284 50 50],'Tag','A_Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Value',1,'Style','popupmenu');
        
        %Selection of used Spike Window
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 290 100 20],'HorizontalAlignment','left','String', 'Spike Time: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position',[93 262 70 50],'Tag','pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','callback',@recalc);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position',[168 262 70 50],'Tag','posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','callback',@recalc);
        
        %Selection Variable 1
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 268 100 20],'HorizontalAlignment','left','String', 'Variable 1: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [93 240 147 50],'HorizontalAlignment','left','Tag','Variable 1','FontSize',8,'String',V,'Value',1,'Style','popupmenu');
        
        %Selection Variable 2
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 247 100 20],'HorizontalAlignment','left','String', 'Variable 2: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [93 219 147 50],'HorizontalAlignment','left','Tag','Variable 2','FontSize',8,'String',V,'Value',1,'Style','popupmenu');
        
        %Show Cluster Overview
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [100 228 20 20],'HorizontalAlignment','left','FontSize',8,'Tag','Cluster','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position',[120 228 150 14],'HorizontalAlignment','left','String','Cluster Summary','FontSize',8,'BackgroundColor', GUI_Color_BG);
        
        %Wavelets on/off
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position',[260 16 20 15],'HorizontalAlignment','left','FontSize',8,'Tag','Wavelet','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position',[280 16 150 14],'HorizontalAlignment','left','String','Wavelet Packet Analysis','FontSize',8,'BackgroundColor', GUI_Color_BG);
        
        %integrate/differentiate Signal
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [260 1 15 15],'Tag','Int_dif','HorizontalAlignment','right','FontSize',8,'Value',1,'String',0,'Style','edit','callback',@recalc);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position',[280 1 150 14],'HorizontalAlignment','left','String','Derivation','FontSize',8,'BackgroundColor', GUI_Color_BG);
        
        %Start Calculation
        uicontrol('Parent',ControlPanel,'Position', [509 5 80 20],'String', 'Start','FontSize',11,'FontWeight','bold','callback',@Start);
        
        %Histogram Selection Field
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 208 147 20],'HorizontalAlignment','left','Tag','H1','FontSize',8,'String',VH,'Value',2,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 210 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph1','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ControlPanel,'Units', 'Pixels','Position', [10 186 147 20],'HorizontalAlignment','left','Tag','H2','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 188 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph2','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 164 147 20],'HorizontalAlignment','left','Tag','H3','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 166 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph3','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 142 147 20],'HorizontalAlignment','left','Tag','H4','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 144 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph4','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ControlPanel,'Units', 'Pixels','Position', [10 120 147 20],'HorizontalAlignment','left','Tag','H5','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 122 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph5','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 98 147 20],'HorizontalAlignment','left','Tag','H6','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 100 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph6','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 76 147 20],'HorizontalAlignment','left','Tag','H7','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 78 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph7','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 54 147 20],'HorizontalAlignment','left','Tag','H8','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 56 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph8','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 32 147 20],'HorizontalAlignment','left','Tag','H9','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 34 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph9','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 10 147 20],'HorizontalAlignment','left','Tag','H10','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 12 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph10','BackgroundColor', GUI_Color_BG);
        
        %Statistics
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [420 329 40 20],'HorizontalAlignment','left','String','Mean','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [468 329 30 20],'HorizontalAlignment','left','String','Var','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [511 329 30 20],'HorizontalAlignment','left','String','Min','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [554 329 30 20],'HorizontalAlignment','left','String','Max','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 303 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H1'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 306 40 20],'Tag','Mean1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 306 40 20],'Tag','Var1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 306 40 20],'Tag','Min1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 306 40 20],'Tag','Max1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 273 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H2'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 276 40 20],'Tag','Mean2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 276 40 20],'Tag','Var2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 276 40 20],'Tag','Min2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 276 40 20],'Tag','Max2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 243 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H3'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 246 40 20],'Tag','Mean3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 246 40 20],'Tag','Var3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 246 40 20],'Tag','Min3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 246 40 20],'Tag','Max3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 213 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H4'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 216 40 20],'Tag','Mean4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 216 40 20],'Tag','Var4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 216 40 20],'Tag','Min4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 216 40 20],'Tag','Max4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 183 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H5'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 186 40 20],'Tag','Mean5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 186 40 20],'Tag','Var5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 186 40 20],'Tag','Min5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 186 40 20],'Tag','Max5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 153 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H6'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 156 40 20],'Tag','Mean6','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 156 40 20],'Tag','Var6','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 156 40 20],'Tag','Min6','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 156 40 20],'Tag','Max6','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 123 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H7'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 126 40 20],'Tag','Mean7','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 126 40 20],'Tag','Var7','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 126 40 20],'Tag','Min7','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 126 40 20],'Tag','Max7','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 93 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H8'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 96 40 20],'Tag','Mean8','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 96 40 20],'Tag','Var8','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 96 40 20],'Tag','Min8','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 96 40 20],'Tag','Max8','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 63 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H9'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 66 40 20],'Tag','Mean9','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 66 40 20],'Tag','Var9','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 66 40 20],'Tag','Min9','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 66 40 20],'Tag','Max9','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 33 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H10'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 36 40 20],'Tag','Mean10','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 36 40 20],'Tag','Var10','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 36 40 20],'Tag','Min10','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 36 40 20],'Tag','Max10','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        %Select-Button-Area
        SelectPanel = uipanel('Parent',SpikeAnalyseWindow,'Units','pixels','Position',[1085 342 175 55],'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SelectPanel,'Position', [5 30 80 20],'String', 'Select','FontSize',11,'FontWeight','bold','callback',@Sel);
        uicontrol('Parent',SelectPanel,'Position', [90 30 80 20],'String', 'Reset','FontSize',11,'FontWeight','bold','callback',@Start);
        uicontrol('Parent',SelectPanel,'Position', [5 5 80 20],'String', 'Spike','FontSize',11,'FontWeight','bold','callback',@ShowSpike);
        uicontrol('Parent',SelectPanel,'Position', [90 5 80 20],'String', 'Class','FontSize',11,'FontWeight','bold','callback',@ShowClass);
        
        %Cluster-Area
        ClusterPanel = uipanel('Parent',SpikeAnalyseWindow,'Units','pixels','Position',[695 342 385 55],'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ClusterPanel,'Style', 'text','Position', [5 30 80 20],'HorizontalAlignment','left','String', 'Parameters:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ClusterPanel,'Units','Pixels','Position', [100 40 20 11],'HorizontalAlignment','left','FontSize',8,'Tag','Histogram','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ClusterPanel,'Units','Pixels','Position', [100 27 20 11],'HorizontalAlignment','left','FontSize',8,'Tag','Variables','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ClusterPanel,'Style', 'text','Position', [118 38 50 14],'HorizontalAlignment','left','String', 'Histogram','FontSize',8,'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ClusterPanel,'Style', 'text','Position', [118 27 50 11],'HorizontalAlignment','left','String', 'Variables','FontSize',8,'BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ClusterPanel,'Style', 'text','Position', [5 5 95 20],'HorizontalAlignment','left','String', 'Bin_Nr:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ClusterPanel,'Units','Pixels','Position', [100 5 40 20],'Tag','Bin_Nr','HorizontalAlignment','right','FontSize',10,'Value',1,'Style','edit');
        
        uicontrol('Parent',ClusterPanel,'Style', 'text','Position', [194 30 61 20],'HorizontalAlignment','left','String', 'Class Nr.:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol ('Parent',ClusterPanel,'Units','Pixels','Position', [255 30 40 20],'Tag','K_Nr','HorizontalAlignment','right','FontSize',8,'Value',1,'String',2,'Style','edit');
        
        uicontrol('Parent',ClusterPanel,'Position', [300 30 80 20],'String', 'K-Means','FontSize',11,'FontWeight','bold','callback',@K_Means_choice);
        uicontrol('Parent',ClusterPanel,'Position', [300 5 80 20],'String', 'EM','FontSize',11,'FontWeight','bold','callback',@EM_choice);
        uicontrol('Parent',ClusterPanel,'Position', [215 5 80 20],'String', 'Discretize','FontSize',11,'FontWeight','bold','callback',@Diskretize);
        
        %Shapes Graph
        Spikeplot = subplot('Position',[0.545 0.615 0.445 0.375]);
        axis([0 2 -100 50]);
        
        %Histogram
        histogramm = subplot('Position',[0.045 0.06 0.445 0.41]);
        
        %Scatterplot
        scatterplot = subplot('Position',[0.545 0.06 0.445 0.41]);
        recalc;
        
        
        
        function recalc(~,~) % set data to false if Window is (re-)opened
            data =false;
        end
        
        function calc(~,~) %Amplitude, Neo, Shapes
            
            %     SPIKES3D:      % Sheet 1: Timestamp of the Spikes; Sheet 2: Negative Amplitude of the Spikes;
            % Sheet 3: Positive Amplitude of the Spikes; Sheet 4: Result of NEO;
            % Sheet 5: Negative signal energy of the Spikes; % Sheet 6: Positive signal energy of the Spikes;
            % Sheet 7: Spike duration; Sheet 8: Spike angle left;
            % Sheet 9: Spike angle right; Sheet 10: 1. PC; Sheet 11: 2. PC;
            % Sheet 12: 3. PC; Sheet 13: 4. PC; Sheet 14: Max-Min-Max ratio;
            % Sheet 15: Wavelet Coefficients (variance); Sheet 16: Wavelet Coefficients (energy variance);
            % Sheet 17: varAmplitude; Sheet 18: varSpike duration;
            % Sheet 19: varSpike angle left; Sheet 20: varSpike angle right;
            
            SPIKES3D=SPIKES;
            SPI =SPIKES3D(:,:,1)*SaRa;
            SPIKES3D(:,size(SPIKES,2),2:16)=zeros;
            pretime = preti(get(findobj(gcf,'Tag','pretime'),'value'));
            posttime = postti(get(findobj(gcf,'Tag','posttime'),'value'));
            
            Neo(1:size(RAW.M,1),size(RAW.M,2))=zeros;
            order = str2double(get(findobj(gcf,'Tag','Int_dif'),'String'));
            
            for m=1:size(RAW.M,2)
                for i=2:1:(size(RAW.M,1)-1)
                    Neo(i,m)= RAW.M(i,m)^2-(RAW.M(i-1,m)*RAW.M(i+1,m));
                end
            end
            
            
            for n=1:size(SPIKES3D,2)%for every Elektrode
                
                
                SPI1=nonzeros(SPI(:,n));
                
                for i=1:size(SPI1,1)
                    if ((SPI1(i)+1+floor(SaRa*posttime/1000))>size(RAW.M,1))||((SPI1(i)+1-ceil(SaRa*pretime/1000)) <=0) % spike window to 2*0.5 msec
                        S_orig(i,n,1:1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))= zeros;
                    else
                        S_orig(i,n,:)=RAW.M(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n); % Shapes with variable window
                        S_old = S_orig;
                        Shapes(i,n,:) = S_orig(i,n,:);
                        Neo_Shapes(i,n,:)=Neo(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n);
                        
                        
                        %Amplitude: consider offset of variable threshold
                        if varTdata~=1
                            SPIKES3D(i,n,2)=(Shapes(i,n,ceil((size(Shapes,3))/2)));
                        else
                            clear temp_datal temp_datar temp_pl temp_pr
                            Shapesvar(i,n,:)=varT(SPI1(i)+1-SaRa*pretime/1000:SPI1(i)+1+SaRa*posttime/1000,n); % Shapes with 2ms length
                            Shapesvar(i,n,:)=Shapesvar(i,n,:)-varoffset(1,n);
                            Shapesvar(i,n,:)=Shapes(i,n,:)-Shapesvar(i,n,:);
                            SPIKES3D(i,n,2)=(Shapesvar(i,n,SaRa/1000+1));
                        end
                        
                        SPIKES3D(i,n,2)=(Shapes(i,n,ceil((size(Shapes,3))/2)));
                        SPIKES3D(i,n,3)=max(Shapes(i,n,ceil(0.25*SaRa/1000):size(Shapes,3)-ceil(0.25*SaRa/1000)));
                        SPIKES3D(i,n,4)=(Neo_Shapes(i,n,ceil((size(Shapes,3))/2)));
                        [C(1),I(1)]= max(Shapes(i,n,1:ceil((size(Shapes,3))/2)));
                        [C(2),I(2)]= max(Shapes(i,n,floor(0.25*SaRa/1000):size(Shapes,3)-ceil(0.25*SaRa/1000)));
                        
                        SPIKES3D(i,n,14)=(-(C(1)-SPIKES3D(i,n,2))/((SaRa/1000)+1-I(1)))+((C(2)-SPIKES3D(i,n,2))/(I(2))); % slope difference  between local max before and local max after spike min (Max-Min-Max ratio)
                        clear Neo_Shapes;
                        
                        
                        templeft = [];
                        tempright = [];
                        
                        % Calculation Spike angles (Andy)/(Robert)
                        % 1. left
                        for j = ceil((size(Shapes,3))/2):-1:1
                            if Shapes(i,n,j)>=(0.5*Shapes(i,n,ceil((size(Shapes,3))/2)))
                                templeft =  abs((Shapes(i,n,j)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(j-ceil((size(Shapes,3))/2))); % slope of min to 50% min
                                SPIKES3D(i,n,8) = atand(templeft); % calculation into degrees
                                templeft = j; % save respective index;
                                break
                            end
                        end
                        % 2. right
                        for j = ceil((size(Shapes,3))/2):1:size(Shapes,3)
                            if Shapes(i,n,j)>=(0.5*Shapes(i,n,ceil((size(Shapes,3))/2)))
                                tempright =  abs((Shapes(i,n,j)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(j-ceil((size(Shapes,3))/2))); % slope of min to 50% min
                                SPIKES3D(i,n,9) = atand(tempright); % calculation into degrees
                                tempright = j; % save respective index;
                                break
                            end
                        end
                        if size(templeft) == 0
                            [~,templeft] = max(Shapes(i,n,ceil(0.25*SaRa/1000):ceil((size(Shapes,3))/2)));
                            SPIKES3D(i,n,8) = abs((Shapes(i,n,templeft)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(templeft-ceil((size(Shapes,3))/2)));
                        end
                        if size(tempright) == 0
                            [~,tempright] = max(ceil((size(Shapes,3))/2):(size(Shapes,3)-ceil(0.25*SaRa/1000)));
                            SPIKES3D(i,n,9) = abs((Shapes(i,n,tempright)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(tempright-ceil((size(Shapes,3))/2)));
                        end
                        
                        % Spike duration (interpolation of angle to y = 0)
                        
                        SPIKES3D(i,n,7) = tempright-templeft;
                        
                        % in case of variable threshold
                        
                        if varTdata==1
                            clear temp_datal temp_datar temp_pl temp_pr
                            Shapesvar(i,n,:)=varT(SPI1(i)+1-SaRa*pretime/1000:SPI1(i)+1+SaRa*posttime/1000,n); % Shapes with 2ms length
                            Shapesvar(i,n,:)=Shapesvar(i,n,:)-varoffset(1,n);
                            Shapesvar(i,n,:)=Shapes(i,n,:)-Shapesvar(i,n,:);
                            
                            if Shapesvar(i,n,SaRa/1000+1)< 0
                                j=0;
                                while Shapesvar(i,n,SaRa/1000+1-j) <= 0.5*(Shapesvar(i,n,SaRa/1000+1)) && (SaRa/1000+1-j)>1;  % slope of min to 50% min
                                    
                                    temp_datal(j+1,1)=-1000*j*(1/SaRa);
                                    temp_datal(j+1,2)=Shapesvar(i,n,SaRa/1000+1-j);
                                    j=j+1;  % 1. left
                                end
                                temp_datal(j+1,1)=-1000*j*(1/SaRa);
                                temp_datal(j+1,2)=Shapesvar(i,n,SaRa/1000+1-j);
                                
                                j=0;
                                while Shapesvar(i,n,SaRa/1000+1+j) <= 0.5*(Shapesvar(i,n,SaRa/1000+1)) && (SaRa/1000+1+j)<(size(Shapesvar,3)-1);  % 50% des Amplitudenwertes
                                    
                                    temp_datar(j+1,1)=1000*j*(1/SaRa);
                                    temp_datar(j+1,2)=Shapesvar(i,n,SaRa/1000+1+j);
                                    j=j+1;  %2. right
                                end
                                temp_datar(j+1,1)=1000*j*(1/SaRa);
                                temp_datar(j+1,2)=Shapesvar(i,n,SaRa/1000+1+j);
                                
                                
                                temp_pl = polyfit(temp_datal(:,1),temp_datal(:,2),1);
                                temp_pr = polyfit(temp_datar(:,1),temp_datar(:,2),1);
                                
                                % varAmplitude
                                SPIKES3D(i,n,21)=(Shapesvar(i,n,SaRa/1000+1));
                                
                                % varSpike duration
                                SPIKES3D(i,n,22)= roots(temp_pl)*(-1) + roots(temp_pr);
                                
                                % varSpike angle left
                                SPIKES3D(i,n,23)=atan((roots(temp_pl)*(-1))/(Shapesvar(i,n,SaRa/1000+1)*(-1)));
                                
                                % varSpike angle right
                                SPIKES3D(i,n,24)=atan((roots(temp_pr))/(Shapesvar(i,n,SaRa/1000+1)*(-1)));
                            end
                        end
                    end
                    clear temp_datal temp_datar temp_pl temp_pr
                end
            end
        end
        
        function calc_PCA(~,~) % calculate principal components
            
            XX(1:size(Shapes,1),1:size(Shapes,3))=Shapes(:,n,:); % 3D Shapes array down to temporary 2D array
            [~,Score]=pca(XX);
            
            SPIKES3D(:,n,10)=Score(:,1); %PC 1
            SPIKES3D(:,n,11)=Score(:,2); %PC 2
            SPIKES3D(:,n,12)=Score(:,3); %PC 3
            SPIKES3D(:,n,13)=Score(:,4); %PC 4
            clear Score I;
        end
        
        
        
        function calc_area(~,~) % calculate positive and negative areas
            k=1;
            Temp=0;
            clear MU S i n ZPOS ZNEG POS NEG;
            MU(1:size(Shapes,1),1:size(Shapes,2),1:size(Shapes,3))=zeros;
            
            for n=1:size(Shapes,2)% for every electrode
                for i=1:size(Shapes,1)% determine change in signal "sign"
                    for j=1:size(Shapes,3)% for all values of every spike
                        if Shapes(i,n,j)~=0
                            if sign(Shapes(i,n,j))~= sign(Temp(1,1))
                                if Temp~=0
                                    MU(i,n,k)=j-1;
                                    k=k+1;
                                else
                                end
                                Temp=Shapes(i,n,j);
                            else
                            end
                        else
                        end
                    end
                    Temp=0;
                    k=1;
                end
                i=1;
            end
            
            
            for n=1:size(Shapes,2) % square voltage values to get signal energy estimate
                for i=1:size(Shapes,1)
                    for j=1:size(Shapes,3)
                        S(i,n,j)=sign(Shapes(i,n,j))*(Shapes(i,n,j))^2;
                    end
                end
            end
            
            for n=1:size(S,2)
                
                POS=0;  % necessary to evaluate if ZPOS or ZNEG have already been used
                NEG=0;
                ZPOS(1:size(MU,3),1:size(MU,1))=zeros;
                ZNEG(1:size(MU,3),1:size(MU,1))=zeros;
                for i=1:size(S,1) % seperately calculate POS and NEG areas
                    for j=1:size(MU,3)
                        if (MU(i,n,j)<= 0) && (j>1) % omit filled up zeros in the MU array
                            TMP=((1/SaRa)*(trapz(S(i,n,MU(i,n,j-1)+1:size(S,3)))));
                            if(TMP>=0)
                                if(POS~=0)
                                    POS=POS+1;
                                    ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                                else
                                    POS=1;
                                    ZPOS(POS,i)=TMP;
                                end
                                break
                            else
                                if(NEG~=0)
                                    NEG=NEG+1;
                                    ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                                else
                                    NEG=1;
                                    ZNEG(NEG,i)=TMP;
                                end
                            end
                            break
                        elseif(MU(i,n,j)<=0) && (j<=1) % case of no sign change
                            TMP=(1/SaRa)*((trapz(S(i,n,1:size(S,3)))));
                            if(TMP>=0)
                                POS=1;
                                ZPOS(POS,i)=TMP;
                            else
                                NEG=1;
                                ZNEG(NEG,i)=TMP;
                            end
                            break
                        else
                            if j==1
                                TMP=(1/SaRa)*((trapz(S(i,n,1:MU(i,n,j))))+(0.5*(-S(i,n,MU(i,n,j))/(S(i,n,MU(i,n,j)+1)-S(i,n,MU(i,n,j))))*S(i,n,MU(i,n,j)))); % die Zwischenflaeche beim Vorzeichenwechsel!
                                if(TMP>=0)
                                    if(POS~=0)
                                        POS=POS+1;
                                        ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                                    else
                                        POS=1;
                                        ZPOS(POS,i)=TMP;
                                    end
                                else
                                    if(NEG~=0)
                                        NEG=NEG+1;
                                        ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                                    else
                                        NEG=1;
                                        ZNEG(NEG,i)=TMP;
                                    end
                                end
                            elseif j>=size(MU,3)
                                TMP=(1/SaRa)*(trapz(S(i,n,MU(i,n,j)+1:size(S,3)))); %take rest area of the spike into account (necessary as there is on sign change less than the number of areas needed)
                                if(TMP>=0)
                                    if(POS~=0)
                                        POS=POS+1;
                                        ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                                    else
                                        POS=1;
                                        ZPOS(POS,i)=TMP;
                                    end
                                else
                                    if(NEG~=0)
                                        NEG=NEG+1;
                                        ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                                    else
                                        NEG=1;
                                        ZNEG(NEG,i)=TMP;
                                    end
                                end
                            else
                                TMP=(1/SaRa)*((trapz(S(i,n,MU(i,n,j-1)+1:MU(i,n,j))))+(0.5*(-S(i,n,MU(i,n,j))/(S(i,n,MU(i,n,j)+1)-S(i,n,MU(i,n,j))))*S(i,n,MU(i,n,j)))+(0.5*(1-(-S(i,n,MU(i,n,j-1))/(S(i,n,MU(i,n,j-1)+1)-S(i,n,MU(i,n,j-1)))))*S(i,n,MU(i,n,j-1)+1)));
                                if(TMP>=0)
                                    if(POS~=0)
                                        POS=POS+1;
                                        ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                                    else
                                        POS=1;
                                        ZPOS(POS,i)=TMP;
                                    end
                                else
                                    if(NEG~=0)
                                        NEG=NEG+1;
                                        ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                                    else
                                        NEG=1;
                                        ZNEG(NEG,i)=TMP;
                                    end
                                end
                            end
                        end
                    end
                    POS=0;
                    NEG=0;
                end
                if size(ZPOS,1)~=i
                    ZPOS(1,i)=0;
                end
                if size(ZNEG,1)~=i
                    ZNEG(1,i)=0;
                end
                
                for i=1:size(Shapes,1) % POS and NEG Result for every Spike
                    SPIKES3D(i,n,6)=max(ZPOS(:,i));
                    SPIKES3D(i,n,5)=min(ZNEG(:,i));
                end
                i=1;
            end
            data= true;
        end
        
        function calc_mean(~,~)
            
            Objekts = [{'Mean1'} {'Var1'} {'Min1'} {'Max1'};{'Mean2'} {'Var2'} {'Min2'} {'Max2'};{'Mean3'} {'Var3'} {'Min3'} {'Max3'};
                {'Mean4'} {'Var4'} {'Min4'} {'Max4'};{'Mean5'} {'Var5'} {'Min5'} {'Max5'};{'Mean6'} {'Var6'} {'Min6'} {'Max6'};
                {'Mean7'} {'Var7'} {'Min7'} {'Max7'};{'Mean8'} {'Var8'} {'Min8'} {'Max8'};{'Mean9'} {'Var9'} {'Min9'} {'Max9'};
                {'Mean10'} {'Var10'} {'Min10'} {'Max10'};];
            
            H = [{'H1'} {'H2'} {'H3'} {'H4'} {'H5'} {'H6'} {'H7'} {'H8'} {'H9'} {'H10'}];
            
            for i=1:size(H,2)
                
                check(i) = get(findobj(gcf,'Tag',char(H(i))),'value');
                
                if check(i)~= 1
                    set(findobj(gcf,'Tag',char(Objekts(i,1))),'String',mean(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i)))); % read respective control; (line by line)
                    set(findobj(gcf,'Tag',char(Objekts(i,2))),'String',var(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))));
                    set(findobj(gcf,'Tag',char(Objekts(i,3))),'String',min(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))));
                    set(findobj(gcf,'Tag',char(Objekts(i,4))),'String',max(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))));
                else
                    set(findobj(gcf,'Tag',char(Objekts(i,1))),'String',''); % read respective control; (line by line)
                    set(findobj(gcf,'Tag',char(Objekts(i,2))),'String','');
                    set(findobj(gcf,'Tag',char(Objekts(i,3))),'String','');
                    set(findobj(gcf,'Tag',char(Objekts(i,4))),'String','');
                end
            end
            
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 303 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H1'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 273 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H2'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 243 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H3'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 213 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H4'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 183 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H5'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 153 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H6'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 123 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H7'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 93 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H8'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 63 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H9'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 33 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H10'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            
            clear H Objekts check;
        end
        function Wave_Coeff(~,~)
            
            Energy(1:size(Shapes,1),1:8)=zeros;
            for n=1:size(Shapes,2)
                if size(nonzeros(SPIKES(:,n)),1)<=1
                    continue
                else
                    
                    for Nr=1:3
                        
                        if Nr==1
                            for i=1:1:size(nonzeros(SPIKES(:,n)),1)
                                
                                MX(:,:)=(Shapes(i,n,:));
                                TREE1 = wpdec(MX,3,'db4');
                                Energy(i,:) = wenergy(TREE1);
                                if isnan(Energy(i,:))==1
                                    Energy(i,:)=zeros;
                                end
                                Coeff(i,:)=read(TREE1,'data');
                            end
                        else
                            for i=1:1:size(nonzeros(SPIKES(:,n)),1)
                                
                                Coeff(i,I1)=zeros;
                                TREE = write(TREE1,'data',Coeff(i,:));
                                MX(:,:)=wprec(TREE);
                                TREE = wpdec(MX,3,'db4');
                                Energy(i,:) = wenergy(TREE);
                                if isnan(Energy(i,:))==1
                                    Energy(i,:)=zeros;
                                end
                                Coeff(i,:)=read(TREE,'data');
                            end
                            
                        end
                        
                        for i=1:size(Coeff,2)
                            [y,z] = hist(Coeff(:,i),100); % histogram plot
                            for nn=1:6
                                y = smooth(y);    % plot smoothing
                            end
                            [~,I(1)]=max(y);  % 1.Extremum global Maximum of distribution!!
                            
                            y = y-min(y); % Norm the plots in x and y
                            z = z-min(z);
                            y = y/max(y);
                            z = z/max(z);
                            
                            k=2;
                            
                            ERG = 0;
                            for j=1:size(y)-1
                                dy(j,1)= (y(j+1,1)-y(j,1))/(z(1,j+1)-z(1,j)); % 1.derivative to find extrema
                                if j>1
                                    if (dy(j,1)<0 && dy(j-1,1)>=0)
                                        I(k)= j;                                              % X-component von maximum via slope
                                        [~,best]=min(ERG);
                                        if (y(I(best),1)-y(I(k),1))/(z(1,I(best))-z(1,I(k)))~=0 && (I(best)~=I(k))
                                            if I(best)<I(k)
                                                [~,MIN] = min(y(I(best):I(k)));
                                                MIN = I(best)+MIN;
                                            else
                                                [~,MIN] = min(y(I(k):I(best)));
                                                MIN = I(k)+MIN;
                                            end
                                            ERG(k-1)=((y(I(best),1)-y(I(k),1))/(z(1,I(best))-z(1,I(k))))/((y(I(best),1)-y(MIN,1))/(z(1,I(best))-z(1,MIN)))/(y(I(k))-y(MIN))*y(I(1));
                                            if isnan(ERG(k-1))
                                                ERG(k-1) =0;
                                            else
                                                k=k+1;
                                            end
                                        end
                                    else
                                        RES(i)=1000;
                                    end
                                end
                            end
                            if max(ERG)~=0
                                RES(i) = min(abs(ERG)); % best Result divided by Nr. of extrema found in the distribution
                            end
                            ERG = [];
                            I=[];
                            y = [];
                            
                            if i<=8
                                Variance(i)=var(Energy(:,i)); % calculate energy coeffs
                                Mean(i,2)=mean(Energy(:,i));
                                RESE(i)=abs(Variance(i)/Mean(i,2));
                            end
                        end
                        [~,I1]=min(RES); % find best distribution coefficient
                        SPIKES3D(1:size(Coeff,1),n,14+Nr) = Coeff(:,I1);
                        if Variance(8)~=0
                            Variance(8)=1;
                        end
                        [~,I]=max(RESE); % best energy-coeffs
                        if Nr>1
                            SPIKES3D(:,n,17+Nr)=Energy(:,I);
                            RESE(I) = 0;
                        else
                            SPIKES3D(:,n,17+Nr)=Energy(:,I);
                            RESE(I) = 0;
                        end
                        
                    end
                end
            end
            clear Mean Variance Energy MX RES RESE RESV TREE k I I1 Nr ERG Coeff;
        end
        function Start (~,~)
            
            Class(:,:) = [];
            tic
            Hgraph = [{'Hgraph1'} {'Hgraph2'} {'Hgraph3'} {'Hgraph4'} {'Hgraph5'} {'Hgraph6'} {'Hgraph7'} {'Hgraph8'} {'Hgraph9'} {'Hgraph10'}];
            H = [{'H1'} {'H2'} {'H3'} {'H4'} {'H5'} {'H6'} {'H7'} {'H8'} {'H9'} {'H10'}];
            Elektrode=get(findobj(gcf,'Tag','A_Elektrodenauswahl'),'value');
            Variable1=get(findobj(gcf,'Tag','Variable 1'),'value');
            Variable2=get(findobj(gcf,'Tag','Variable 2'),'value');
            pretime=preti(get(findobj(gcf,'Tag','pretime'),'value'));
            posttime=postti(get(findobj(gcf,'Tag','posttime'),'value'));
            
            if size(nonzeros(SPIKES(:,Elektrode)),1) >= 9
                uicontrol('Parent',ControlPanel,'Style', 'text','Position', [150 321 50 15],'HorizontalAlignment','left','String','Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','k','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',ControlPanel,'Style', 'text','Position', [200 321 50 15],'HorizontalAlignment','left','String',size(nonzeros(SPIKES(:,Elektrode))),'FontSize',10,'FontWeight','bold','ForegroundColor','k','BackgroundColor', GUI_Color_BG);
            else
                uicontrol('Parent',ControlPanel,'Style', 'text','Position', [150 321 50 15],'HorizontalAlignment','left','String','Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','r','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',ControlPanel,'Style', 'text','Position', [200 321 50 15],'HorizontalAlignment','left','String',size(nonzeros(SPIKES(:,Elektrode))),'FontSize',10,'FontWeight','bold','ForegroundColor','r','BackgroundColor', GUI_Color_BG);
            end
            
            %         if varTdata~=1
            if get(findobj(gcf,'Tag','Wavelet'),'value')== 0
                set(findobj(gcf,'Tag','Variable 1'),'String',Var_both);
                set(findobj(gcf,'Tag','Variable 2'),'String',Var_both);
                for i=1:size(H,2)
                    set(findobj(gcf,'Tag',char(H(i))),'String',Var_Hist_both);
                end
                set(findobj(gcf,'Tag','Wavelet'),'enable','off')
            else
                set(findobj(gcf,'Tag','Variable 1'),'String',Variables);
                set(findobj(gcf,'Tag','Variable 2'),'String',Variables);
                for i=1:size(H,2)
                    set(findobj(gcf,'Tag',char(H(i))),'String',Var_Hist);
                end
            end
            
            if data == false % check if data has already been calculated
                Shapes=[];
                XX=[];
                Shapes(1:size(SPIKES,1),1:size(SPIKES,2),1:(((pretime+posttime)*SaRa))/1000+1)=zeros;
                
                calc; % start calculation
                calc_area;
                calculate_PCA;
                if get(findobj(gcf,'Tag','Wavelet'),'value')==1
                    Wave_Coeff;
                end
                
                %Shapes graph
                ST = (-pretime:1000/SaRa:posttime); %Max(1) and Min(1) explizitely for the first Shapes graph; Features used from i=2!!!
                MAX2D = max(Shapes);
                MAX1D = max(MAX2D);
                Max(1) = max(MAX1D);
                MIN2D = min(Shapes);
                MIN1D = min(MIN2D);
                Min(1) = min(MIN1D);
                
                for i=2:(size(SPIKES3D,3))
                    MIN2D = min(nonzeros(SPIKES3D(:,:,i)));
                    MAX2D = max(nonzeros(SPIKES3D(:,:,i)));
                    MIN1D = min(MIN2D);
                    MAX1D = max(MAX2D);
                    if size(MIN1D) ~= 0
                        Min(i) = min(MIN1D);
                    else
                        Min(i)=0;
                    end
                    if size(MAX1D) ~= 0
                        Max(i) = max(MAX1D);
                    else
                        Max(i)=0;
                    end
                end
                clear MIN2D MIN1D MAX2D MAX1D;
            end
            calc_mean;
            XX=[];
            XX(1:size(nonzeros(SPIKES(:,Elektrode)),1),1:size(Shapes,3))= Shapes(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,:); % 3D Shapes array down to temporary 2D array
            Spikeplot = subplot('Position',[0.545 0.615 0.445 0.375]);
            if size(XX,1)~=0
                Spikeplot = plot(ST,XX);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
            else
                Spikeplot = plot(zeros);
            end
            xlabel ('time / ms');
            ylabel({'Voltage / uV'});
            
            %Histogram
            histogramm = subplot('Position',[0.045 0.06 0.445 0.41]);
            CMAP = Colormap;
            counter = 0;
            for i=1:size(H,2)
                check(i) = get(findobj(gcf,'Tag',char(H(i))),'value');
                if check(i)== 1;
                    counter = counter + 1;
                end
            end
            if counter < 9 % if more than one feature is activated
                SPIKES3D_Norm=[];
                count2 = 1;
                for i=1:size(check,2)
                    if check(i)~=1
                        if size(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i)),1)~=0
                            SPIKES3D_Norm(:,count2) = (SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))-min(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))))/(max(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i)))-min(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))));
                            if min(SPIKES3D_Norm(:,count2))~=0
                                SPIKES3D_Norm(:,count2) = SPIKES3D_Norm(:,count2)*(-1);
                            end
                        end
                        count2 = count2 +1;
                    end
                end
                hist(SPIKES3D_Norm,20);
                color = round(linspace(1,size(Colormap,1),count2-1));
                count2 = 1;
                for i=1:size(check,2)
                    if check(i) ~= 1
                        set(findobj(gcf,'Tag',char(Hgraph(i))),'BackgroundColor',[CMAP(color(count2),1) CMAP(color(count2),2) CMAP(color(count2),3)]);
                        count2 = count2 + 1;
                    else
                        set(findobj(gcf,'Tag',char(Hgraph(i))),'BackgroundColor', GUI_Color_BG);
                    end
                end
                xlabel ('Normalized Scale');
                ylabel({'Nr. of Hits'});
            else
                [C,I]=max(check); % % if only one feature is activated
                v= Min(C):(Max(C)-Min(C))/100:Max(C);
                hist(nonzeros(SPIKES3D(:,Elektrode,C)),v);
                for i=1:size(check,2)
                    set(findobj(gcf,'Tag',char(Hgraph(i))),'BackgroundColor', GUI_Color_BG);
                end
                set(findobj(gcf,'Tag',char(Hgraph(I))),'BackgroundColor',[CMAP(1,1) CMAP(1,2) CMAP(1,3)]);
                xlabel (char(units(I)));
                ylabel({'Nr. of Hits'});
            end
            
            %Scatterplot
            scatterplot = subplot('Position',[0.545 0.06 0.445 0.41]);
            scatterplot = scatter(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,Variable1+1),SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,Variable2+1),18,'filled');
            axis([Min(Variable1+1) Max(Variable1+1) Min(Variable2+1) Max(Variable2+1)]);
            xlabel (char(units(Variable1)));
            ylabel(char(units(Variable2)));
            first = true;
            
            if get(findobj(gcf,'Tag','Cluster'),'value')==1
                cluster_view;
            end
            toc
        end
        
        function cluster_view(~,~)
            
            H = [{'H1'} {'H2'} {'H3'} {'H4'} {'H5'} {'H6'} {'H7'} {'H8'} {'H9'} {'H10'}];
            
            Cluster_Window = figure('Name','Cluster','NumberTitle','off','Position',[10 30 1350 750],'Toolbar','none','Resize','off');
            
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [152 660 120 30],'HorizontalAlignment','left','String',VH(check(1)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 550 80 80],'HorizontalAlignment','left','String',VH(check(1)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [310 660 120 30],'HorizontalAlignment','left','String',VH(check(2)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 455 80 80],'HorizontalAlignment','left','String',VH(check(2)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [510 660 120 30],'HorizontalAlignment','left','String',VH(check(3)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 360 80 80],'HorizontalAlignment','left','String',VH(check(3)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [650 660 120 30],'HorizontalAlignment','left','String',VH(check(4)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 270 80 80],'HorizontalAlignment','left','String',VH(check(4)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [810 660 120 30],'HorizontalAlignment','left','String',VH(check(5)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 180 80 80],'HorizontalAlignment','left','String',VH(check(5)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [985 660 120 30],'HorizontalAlignment','left','String',VH(check(6)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 90 80 80],'HorizontalAlignment','left','String',VH(check(6)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [1140 660 120 30],'HorizontalAlignment','left','String',VH(check(7)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 -10 80 80],'HorizontalAlignment','left','String',VH(check(7)),'FontSize',8,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            
            XPOS = [0.1 0.22 0.34 0.46 0.58 0.7 0.82];
            YPOS = [0.81 0.68 0.55 0.42 0.29 0.16 0.03];
            
            for i = 1:7
                
                for j = 1:7
                    
                    subplot('Position',[XPOS(i) YPOS(j) 0.1 0.1]);
                    scatter(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i)),SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(j)),1,'filled');
                    axis([Min(check(i)) Max(check(i)) Min(check(j)) Max(check(j))]);
                    
                end
            end
            
            clear H YPOS XPOS;
            
        end
        
        function Sel(~,~)
            dc_obj = datacursormode(SpikeAnalyseWindow);
            set(dc_obj,'DisplayStyle','datatip',...
                'SnapToDataVertex','on','Enable','on','UpdateFcn',@LineT);
        end
        
        function [txt] = LineT (~,~)
            dc_obj = datacursormode(SpikeAnalyseWindow);
            c_inf = getCursorInfo(dc_obj);
            Spike1 = find(SPIKES3D(:,Elektrode,Variable1+1)==c_inf(1).Position(1));
            Spike2 = find(SPIKES3D(:,Elektrode,Variable2+1)==c_inf(1).Position(2));
            for i=1:size(Spike1,1)
                Spike = find(Spike1(i) == Spike2);
                if Spike > 0
                    break;
                end
            end
            Spike = Spike2(Spike);
            txt = [{num2str(Spike)} {SPIKES3D(Spike,Elektrode,Variable1+1)} {SPIKES3D(Spike,Elektrode,Variable2+1)}];
            datacursormode off;
        end
        
        function ShowSpike (~,~)
            if first == 1
                XX=[];
                first = false;
            end
            size(XX,1);
            XX(size(XX,1)+1,:)=Shapes(Spike,Elektrode,:);
            Spikeplot = subplot('Position',[0.545 0.615 0.445 0.375]);
            Spikeplot = plot(ST,XX);
            axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
            xlabel ('time / ms');
            ylabel({'Voltage / uV'});
        end
        
        function ShowClass (~,~)
            
            XX=[];
            if size(Class,1)==0
                Class(1:size(nonzeros(SPIKES(:,Elektrode)),1),1)= zeros;
            end
            XX(:,:)=Shapes((Class==Class(Spike)),Elektrode,:);
            Spikeplot = subplot('Position',[0.545 0.615 0.445 0.375]);
            Spikeplot = plot(ST,XX);
            axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
            xlabel ('time / ms');
            ylabel({'Voltage / uV'});
            
            XX=[]; % to ensure that ShowSpike works without complications
        end
        
        function K_Means_choice(~,~) % Selection K-Means Button
            
            Method = 0;
            k_mean([],[],Method);
        end
        
        function EM_choice(~,~) % Selection EM Button
            
            Method = 1;
            k_mean([],[],Method);
        end
        
        function k_mean(~,~,Method)
            
            tic
            
            if (get(findobj(gcf,'Tag','Variables'),'value')==1) || (get(findobj(gcf,'Tag','Histogram'),'value') == (get(findobj(gcf,'Tag','Variables'),'value')))
                
                if isnan(str2double(get(findobj(gcf,'Tag','Variables'),'String')))
                    X(:,1:2)=SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,[Variable1+1 Variable2+1]);
                    discrete = 0;
                else
                    X(:,1:2)= SPIKES_Discrete(:,:);
                    discrete = 1;
                end
            else
                discrete = 0;
                if counter < 9 % if more than one feature is activated
                    counter = 1;
                    for i=1:size(check,2)
                        if check(i)~=1
                            X(:,counter) = SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i));
                            counter = counter +1;
                        end
                    end
                    counter = 0;
                else
                    X(:,1:2)=SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,[Variable1+1 Variable2+1]);
                end
            end
            
            XX_N(1:size(nonzeros(SPIKES(:,Elektrode)),1),1:size(X,2))=zeros;
            
            
            if discrete == 0;
                for i=1:size(X,2)
                    XX_N(:,i) = (X(:,i)-min(X(:,i)))/(max(X(:,i))-min(X(:,i)));
                end
            else
                XX_N = X;
            end
            
            X(:,1:2)=SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,[Variable1+1 Variable2+1]); % to ensure consistency of scatterplot
            
            k=get(findobj(gcf,'Tag','K_Nr'),'String');
            k=str2double(k)
            if k== 0
                Y = pdist(XX_N,'mahalanobis');
                Z = linkage(Y,'weighted');
                Temp = cluster(Z,'cutoff',1.1);
                k = max(Temp);
                clear Temp
                set(findobj(gcf,'Tag','K_Nr'),'String',k);
            end
            
            if Method == 0
                [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(XX_N(:,:),k,[],[],1,[]);
                
                [Class,~] = kmeans(XX_N,k,'start',M_EM','emptyaction','singleton');
                Probability(size(XX_N)) = 1;
                
                
                
                
            elseif Method == 1
                
                BIC_old = 0;
                for i = 1:k
                    
                    [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(XX_N(:,:),i,[],[],1,[]);
                    BIC = abs((-2*L_EM)+(2*i*log(size(XX_N,1)*size(XX_N,2))));
                    if BIC < BIC_old % abs to consider sign
                        break;
                    end
                    BIC_old = abs(BIC);
                end
                
                obj = gmdistribution(M_EM',V_EM,W_EM');
                
                [Class,~,Probability]  = cluster(obj,XX_N);
            end
            scatterplot = subplot('Position',[0.545 0.06 0.445 0.41]);
            
            for i=1:k
                scatter(X(Class==i,1),X(Class==i,2),18,'filled');
                hold on
            end
            axis([Min(Variable1+1) Max(Variable1+1) Min(Variable2+1) Max(Variable2+1)]);
            xlabel (char(units(Variable1)));
            ylabel(char(units(Variable2)));
            hold off
            toc
        end
        
        function Diskretize(~,~)
            
            SPIKES_temp(:,:) = SPIKES3D(:,Elektrode,[check(1) check(2)]);
            GRID_Resolution(1,1) = str2double(get(findobj(gcf,'Tag','Bin_Nr'),'String'));
            GRID_Resolution(1,2) = str2double(get(findobj(gcf,'Tag','Bin_Nr'),'String'));
            
            [N(1:GRID_Resolution(1,1),1:GRID_Resolution(1,2)),C]=hist3(SPIKES_temp,GRID_Resolution(1,:));
            
            C= cell2mat(C); %Conversion of returned cell C to matrix
            CC(1,:) = C(1,1:GRID_Resolution(1,1)); % rearrangement of C into different rows
            CC(2,:) = C(1,GRID_Resolution(1,1)+1:(2*GRID_Resolution(1,1)));
            
            
            SPIKES_Discrete(1:sum(sum(N(:,1))),1) = CC(1,1); % necessary to ensure that subsequent loop works without problems
            SPIKES_Discrete(1:sum(sum(N(:,1))),2)= CC(2,1);
            for i=2:GRID_Resolution(1,1)
                if (sum(sum(N(:,1:i-1)))> 0)
                    SPIKES_Discrete(sum(sum(N(:,1:i-1))):sum(sum((N(:,1:i)))),1) = CC(1,i);
                end
                if (sum(sum(N(1:i-1,:)))> 0)
                    SPIKES_Discrete(sum(sum(N(1:i-1,:))):sum(sum((N(1:i,:)))),2) = CC(2,i);
                end
                
            end
            
            figure(27)
            pcolor((N(1:GRID_Resolution(1,1),1:GRID_Resolution(1,2),1)'));
            colormap(jet);
            
            clear GRID_Resolution SPIKES_temp C CC;
        end
    end


% -------------------- Detektion Refinement (RB)---------------------------
    function Detektion_Refinement (~,~)
        
        Var = [{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
            {'Wavelet Energy 2'};{'Wavelet Energy 3'}];
        
        Var_var_ =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
            {'Wavelet Energy 2'};{'Wavelet Energy 3'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};
            {'Right Spk. Angle(Neg./var.)'}];
        
        Var_neither =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            ];
        
        Var_no_wave =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};{'Right Spk. Angle(Neg./var.)'}];
        
        units = [{'Voltage / uV'};{'Voltage / uV'};{'Scalar'};{'Energy / V ^2 / s'};{'Energy / V ^2 / s'};{'Time / ms'};{'Scalar'};{'Scalar'};
            {'Scalar'};{'Scalar'};{'Gradient uV / s'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};
            {'Voltage / uV'};{'Time / ms'};{'Scalar'};{'Scalar'};];
        
        if varTdata~=1
            V = Var;
        else
            V =  Var_var;
        end
        
        data = 0;
        Feature_Nr = 2; % default value
        Spike = 0;
        Elektrode=[];
        ST = 1;
        Min(1:(size(SPIKES,1))) = zeros;
        Max(1:(size(SPIKES,1))) = zeros;
        XX=[];
        Class(1:size(SPIKES,1)) = zeros;
        check = [];
        cln = [];
        k = 2;
        pretime = 0.5;
        posttime = 0.5;
        SPIKES3D_discard = [];
        
        preti = (0.5:1000/SaRa:2);
        postti = (0.5:1000/SaRa:2);
        
        %Main Window
        DetektionRefinementWindow = figure('Name','Detektion_Refinement','NumberTitle','off','Position',[45 100 1200 600],'Toolbar','none','Resize','off');
        
        
        %Main Window header
        uicontrol('Parent', DetektionRefinementWindow,'Style', 'text','Position', [180 460 250 20],'HorizontalAlignment','center','String','Identified Clusters','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent', DetektionRefinementWindow,'Style', 'text','Position', [800 460 250 20],'HorizontalAlignment','center','String','Refined Spikes','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent', DetektionRefinementWindow,'Style', 'text','Position', [800 235 250 20],'HorizontalAlignment','center','String','Detected Noise Events','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Button-Area
        RefinementPanel=uipanel('Parent',DetektionRefinementWindow,'Units','pixels','Position',[10 500 590 100],'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [15 75 100 20],'HorizontalAlignment','left','String', 'General:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Start Calculation
        uicontrol('Parent',RefinementPanel,'Position',[455 30 80 20],'String','Start','FontSize',11,'FontWeight','bold','callback',@Start_SR);
        
        %Submit data to Dr_Cell
        uicontrol('Parent',RefinementPanel,'Position',[415 5 160 20],'String','Submit to Dr.Cell','FontSize',11,'FontWeight','bold','callback',@Submit);
        
        %Electrode Selection
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[15 52 100 20],'HorizontalAlignment','left','String','Electrode: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[98 25 50 50],'Tag','Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Value',1,'Style','popupmenu','callback',@recalculate);
        
        %Apply Expectation Maximation Algorithm
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[15 23 20 20],'HorizontalAlignment','left','FontSize',10,'Tag','EM_GM','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[40 25 150 14],'HorizontalAlignment','left','String','Expectation Maximation','FontSize',8,'BackgroundColor', GUI_Color_BG);
        
        %Apply EM k-means Algorithm
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[15 4 20 20],'HorizontalAlignment','left','FontSize',10,'Tag','EM_k-means','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[40 6 150 14],'HorizontalAlignment','left','String','EM k-means','FontSize',8,'BackgroundColor', GUI_Color_BG);
        
        %FPCA Features
        uicontrol ('Parent',RefinementPanel,'Units','Pixels','Position',[190 61 20 15],'HorizontalAlignment','left','FontSize',8,'Tag','FPCA','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RefinementPanel,'Style','text','Position',[215 63 150 14],'HorizontalAlignment','left','String','FPCA Features','FontSize',8,'BackgroundColor', GUI_Color_BG);
        
        %Wavelets on/off
        uicontrol ('Parent',RefinementPanel,'Units','Pixels','Position',[190 42 20 15],'HorizontalAlignment','left','FontSize',8,'Tag','Wavelet','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[215 44 150 14],'HorizontalAlignment','left','String','Wavelet Packet Analysis','FontSize',8,'BackgroundColor', GUI_Color_BG);
        
        %Manual or automatic Features
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[190 23 20 20],'HorizontalAlignment','left','FontSize',10,'Tag','manual','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[215 25 150 14],'HorizontalAlignment','left','String','Manual Features','FontSize',8,'BackgroundColor', GUI_Color_BG);
        
        % Shapes Window Dimension
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [392 55 80 20],'HorizontalAlignment','left','String', 'Spike Time: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[472 48 50 30],'Tag','SR_pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','callback',@recalculate);
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[527 48 50 30],'Tag','SR_posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','callback',@recalculate);
        
        %Refine discarded Events
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[190 4 20 20],'HorizontalAlignment','left','FontSize',10,'Tag','discard','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[215 6 150 14],'HorizontalAlignment','left','String','Refine discarded Signals','FontSize',8,'BackgroundColor', GUI_Color_BG);
        
        %Feature-Area
        FeaturePanel=uipanel('Parent',DetektionRefinementWindow,'Units','pixels','Position',[600 500 590 100],'BackgroundColor', GUI_Color_BG,'Tag','FeaturePanel','Visible','on');
        uicontrol('Parent',FeaturePanel,'Style', 'text','Position', [15 75 100 20],'HorizontalAlignment','left','String', 'Features:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        FeaturePanel2=uipanel('Parent',DetektionRefinementWindow,'Units','pixels','Position',[600 500 590 100],'BackgroundColor', GUI_Color_BG,'Tag','FeaturePanel2','Visible','off');
        uicontrol('Parent',FeaturePanel2,'Style', 'text','Position', [15 75 100 20],'HorizontalAlignment','left','String', 'Features:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',FeaturePanel2,'Style', 'text','Position', [200 10 200 50],'HorizontalAlignment','left','String', 'FPCA Features','FontSize',18,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Automated Feature Selection
        uicontrol('Parent',FeaturePanel,'Units','Pixels','Position', [15 50 150 20],'HorizontalAlignment','left','Tag','F1','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
        
        uicontrol('Parent',FeaturePanel,'Units', 'Pixels','Position', [15 15 150 20],'HorizontalAlignment','left','Tag','F2','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
        
        uicontrol('Parent',FeaturePanel,'Units','Pixels','Position', [190 50 150 20],'HorizontalAlignment','left','Tag','F3','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
        
        uicontrol('Parent',FeaturePanel,'Units','Pixels','Position', [190 15 150 20],'HorizontalAlignment','left','Tag','F4','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
        
        uicontrol('Parent',FeaturePanel,'Units','Pixels','Position', [365 50 150 20],'HorizontalAlignment','left','Tag','F5','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
        
        uicontrol('Parent',FeaturePanel,'Units','Pixels','Position', [365 15 150 20],'HorizontalAlignment','left','Tag','F6','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
        
        %Shapes Graph of Refined Spikes
        Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28]);
        axis([0 2 -100 50]);
        
        %Shapes Graph of Filtered Events
        Filtered = subplot('Position',[0.55 0.09 0.44 0.28]);
        axis([0 2 -100 50]);
        
        
        %Scatterplot
        scatterplot = subplot('Position',[0.05 0.09 0.44 0.66]);
        
        function Start_SR (~,~)
            
            tic
            w = waitbar(.1,'Please wait - Spikes Refinment in progress...');
            F = [{'F1'} {'F2'} {'F3'} {'F4'} {'F5'} {'F6'}];
            
            SPIKES3D_temp = [];
            Shapes_temp = [];
            Class(:,:) = [];
            Sorting = 0; % Variable to discriminate between calls from Sorting and Refinement tool
            
            if get(findobj('Tag','manual'),'value') == 1
                for i = 1:6
                    if get(findobj('Tag',char(F(i))),'value') ~=1
                        check(i) = get(findobj('Tag',char(F(i))),'value');
                    else
                        check(i) = 0;
                    end
                end
                check = nonzeros(check);
                check = check';
            end
            
            Elektrode = get(findobj('Tag','Elektrodenauswahl','parent',RefinementPanel),'value');
            
            Shapes=[];
            XX=[];
            
            pretime = preti(get(findobj('Tag','SR_pretime'),'value'));
            posttime = postti(get(findobj('Tag','SR_posttime'),'value'));
            
            if get(findobj('Tag','discard'),'value') == 1 &&  size(SPIKES3D_discard,1) ~= 0
                Shapes(1:size(SPIKES3D_discard,1),1:size(SPIKES3D_discard,2),1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))=zeros;
                
            else
                Shapes(1:size(SPIKES,1),1:size(SPIKES,2),1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))=zeros;
            end
            
            Shape(pretime,posttime);
            waitbar(.15,w,'Please wait - Features being calculated...')
            if data == false %check if data has already been calculated
                
                if get(findobj('Tag','Wavelet'),'value')==1
                    V = Var;
                else
                    V = Var_neither;
                end
                
                calculate(V,pretime,posttime); %claculate basic Features (Amplitude, NEO, PCA, Spike Angles, Min-Max-Ratio, Spike Duration)
                calculate_area; %calculate Areas of Spikes
            end
            
            if SubmitRefinement ~= 0 || size(nonzeros(SPIKES3D(:,Elektrode,14)),1) == 0
                calculate_PCA; %calculate principal components
                waitbar(.3,w,'Please wait - Wavelet Features being calculated...')
                if get(findobj('Tag','Wavelet'),'value')==1
                    calculate_Wave_Coeff; %calculate Wavelet Coefficients (Energy and Variance Criteria)
                end
                SubmitRefinement = 0;
            end
            
            if get(findobj('Tag','FPCA'),'value')== 0
                set(findobj('Tag','FeaturePanel'),'Visible','on');
                set(findobj('Tag','FeaturePanel2'),'Visible','off');
            else
                set(findobj('Tag','FeaturePanel'),'Visible','off');
                set(findobj('Tag','FeaturePanel2'),'Visible','on');
            end
            
            waitbar(.6,w,'Please wait - Clustering...')
            Class = Clusterfunction;
            waitbar(.9,w,'Please wait - Clustering complete')
            %Shapes Graph
            ST = (-pretime:1000/SaRa:posttime);
            MAX1D = max(Shapes(:,Elektrode,:));
            Max(1) = max(MAX1D);
            MIN1D = min(Shapes(:,Elektrode,:));
            Min(1) = min(MIN1D);
            
            if get(findobj('Tag','FPCA'),'value') == 0
                if get(findobj('Tag','discard'),'value') == 1 &&  size(SPIKES3D_discard,1) ~= 0
                    SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
                else
                    SPIKES3D_temp = SPIKES3D(1:size(nonzeros(SPIKES3D(:,Elektrode,1)),1),Elektrode,:);
                end
            else
                SPIKES3D_temp(:,1,:) = SPIKES_FPCA;
            end
            
            Shapes_temp = Shapes(:,Elektrode,:);
            
            for i=2:(size(SPIKES3D_temp,3))
                
                MIN1D = min(nonzeros(SPIKES3D_temp(:,1,i)));
                MAX1D = max(nonzeros(SPIKES3D_temp(:,1,i)));
                if size(MIN1D) ~= 0
                    Min(i) = min(MIN1D);
                else
                    Min(i)=0;
                end
                if size(MAX1D) ~= 0
                    Max(i) = max(MAX1D);
                else
                    Max(i)=0;
                end
            end
            clear MAX1D MIN1D;
            
            XX1=[];
            XX2=[];
            
            %Plot Refined Spikes and Noise Events
            XX1(:,:) = Shapes_temp(Class~=1,1,:); % 3D Shapes array down to temporary 2D array
            XX2(:,:) = Shapes_temp(Class==1,1,:);
            Spike_Cluster =mean(SPIKES3D_temp(Class~=1,1,2))<= mean(SPIKES3D_temp(Class==1,1,2));
            
            uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [100 75 130 18],'HorizontalAlignment','left','String','Original Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','r','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [210 75 50 18],'HorizontalAlignment','left','String',size(nonzeros(SPIKES3D_temp(:,1,1))),'FontSize',10,'FontWeight','bold','ForegroundColor','r','BackgroundColor', GUI_Color_BG);
            waitbar(1,w,'Done');
            close(w);
            
            if size(XX1,1)== 0
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX2);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / uV'});
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / uV'});
                
            elseif size(XX2,1)== 0
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX1);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / uV'});
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / uV'});
                
                
            elseif Spike_Cluster == 1
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX1);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / uV'});
                
                subplot('Position',[0.55 0.09 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX2);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                xlabel ('time / ms');
                ylabel({'Voltage / uV'});
                
                uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [290 75 130 20],'HorizontalAlignment','left','String','Refined Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','b','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [395 75 50 20],'HorizontalAlignment','left','String',size(XX1,1),'FontSize',10,'FontWeight','bold','ForegroundColor','b','BackgroundColor', GUI_Color_BG);
                
                
                XX1=[];
                XX2=[];
                
            elseif Spike_Cluster == 0
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX2);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / uV'});
                
                subplot('Position',[0.55 0.09 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX1);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                xlabel ('time / ms');
                ylabel({'Voltage / uV'});
                
                uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [290 75 130 20],'HorizontalAlignment','left','String','Refined Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','b','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [395 75 50 20],'HorizontalAlignment','left','String',size(XX2,1),'FontSize',10,'FontWeight','bold','ForegroundColor','b','BackgroundColor', GUI_Color_BG);
                
                XX1=[];
                XX2=[];
                
            else
                Spikeplot = plot(zeros);
                XX1=[];
                XX2=[];
            end
            
            %Scatterplot
            X(:,1:2)=SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1)),1),1,[(check(1)) (check(2))]);
            
            scatterplot = subplot('Position',[0.05 0.09 0.44 0.66],'parent',DetektionRefinementWindow);
            for i=1:max(Class)
                scatter(X(Class==i,1),X(Class==i,2),18,'filled');
                hold on
            end
            
            axis([Min(check(1)) Max(check(1)) Min(check(2)) Max(check(2))]); % has to be done that way as +1 and -1 due to Max(i) and F(i) cancel each other out
            if get(findobj('Tag','FPCA'),'value') == 0
                axis(gca,[Min(check(1)) Max(check(1)) Min(check(2)) Max(check(2))]); % has to be done that way as +1 and -1 due to Max(i) and F(i) cancel each other out
                xlabel (gca,char(units(check(1)-1)));
                ylabel(gca,char(units(check(2)-1)));
            else
                axis(gca,[min(SPIKES3D_temp(:,1)) max(SPIKES3D_temp(:,1)) min(SPIKES3D_temp(:,2)) max(SPIKES3D_temp(:,2))]);
                xlabel (gca,'Scalar');
                ylabel(gca,'Scalar');
            end
            
            hold off
            toc
        end
        
    end


% -------------------- recalculate (RB)-------------------------------
    function recalculate(~,~) % set data to false if Window is (re-)opened
        SPIKES3D_discard = [];
        data = false;
        cln = [];
        Sorting = 0;
        Elektrode = get(findobj(gcf,'Tag','Elektrodenauswahl'),'value');
        SubmitSorting(Elektrode) = 0;
        Shapes = [];
        if isnan(get(findobj('Tag','Sort_pretime'),'value')) == 0
            set(findobj('Tag','S_pretime'),'value',get(findobj('Tag','Sort_pretime'),'value'));
            set(findobj('Tag','S_posttime'),'value',get(findobj('Tag','Sort_posttime'),'value'));
        else
            Window = 0;
        end
    end


% -------------------- Shape (RB)-------------------------------

    function Shape(pretime,posttime,~)
        
        SPI = [];
        SPI1 =[];
        
        n = Elektrode; % if only 1 electrode is calculated
        
        if isempty(get(findobj('Tag','discard'),'value')) == 1 % Test if checkbox discard exists for first Spike Sorting cycle
            discard = 0;
        else
            discard = get(findobj('Tag','discard'),'value');
        end
        
        if discard == 1 &&  size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1
            SPI(:,n) = SPIKES3D_discard(:,1,1)*SaRa;
            if SubmitSorting(Elektrode) >= 1
                M_temp(:,n) = M_old;
            else
                M_temp(:,n) = RAW.M(:,n);
            end
        else
            SPI =SPIKES*SaRa;
            M_temp(:,n) = RAW.M(:,n);
        end
        
        SPI1=nonzeros(SPI(:,n));
        
        for i=1:size(SPI1,1)
            if ((SPI1(i)+1+floor(SaRa*posttime/1000))>size(M_temp,1))||((SPI1(i)+1-ceil(SaRa*pretime/1000)) <=0) % Spikes with length of 2*0.5 msec!!!
                S_orig(i,n,1:1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))= zeros;
            else
                S_orig(i,n,:)=M_temp(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n); % Shapes with variable window length
                S_old = S_orig;
            end
            Shapes(i,n,:) = S_orig(i,n,:);
        end
    end


% -------------------- Calculate (RB)-------------------------------

    function calculate(V,pretime,posttime,~) %Amplitude, Neo, Shapes
        
        %     SPIKES3D:      % Sheet 1: Timestamp of the Spikes; Sheet 2: Negative Amplitude of the Spikes;
        % Sheet 3: Positive Amplitude of the Spikes; Sheet 4: Result of NEO;
        % Sheet 5: Negative signal energy of the Spikes; % Sheet 6: Positive signal energy of the Spikes;
        % Sheet 7: Spike duration; Sheet 8: Spike angle left;
        % Sheet 9: Spike angle right; Sheet 10: 1. PC; Sheet 11: 2. PC;
        % Sheet 12: 3. PC; Sheet 13: 4. PC; Sheet
        % Sheet 14-16: Wavelet Coefficients (variance); Sheet 17-19: Wavelet Coefficients (energy variance);
        % Sheet 20: varAmplitude; Sheet 21: varSpike duration;
        % Sheet 22: varSpike angle left; Sheet 23: varSpike angle right;
        
        Shapesvar = [];
        SPIKES3D=SPIKES;
        SPI =SPIKES3D(:,:,1)*SaRa;
        SPIKES3D(:,size(SPIKES,2),2:size(V,1))=zeros;
        n = Elektrode; %if only 1 Elektrode is calculated
        Neo(1:size(RAW.M,1),size(RAW.M,2))=zeros;
        
        for m=1:size(RAW.M,2)
            for i=2:1:(size(RAW.M,1)-1)
                Neo(i,m)= RAW.M(i,m)^2-(RAW.M(i-1,m)*RAW.M(i+1,m));
            end
        end
        
        SPI1=nonzeros(SPI(:,n));
        
        for i=1:size(SPI1,1)
            if ((SPI1(i)+1+floor(SaRa*posttime/1000))<=size(RAW.M,1))&&((SPI1(i)+1-ceil(SaRa*pretime/1000)) >0)
                
                Neo_Shapes(i,n,:)=Neo(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n);
                
                %Amplitude: consider offset of variable threshold
                if varTdata~=1
                    SPIKES3D(i,n,2)=(Shapes(i,n,ceil((size(Shapes,3))/2)));
                else
                    clear temp_datal temp_datar temp_pl temp_pr
                    Shapesvar(i,n,:)=varT(SPI1(i)+1-SaRa*pretime/1000:SPI1(i)+1+SaRa*posttime/1000,n); % Shapes with length 2ms
                    Shapesvar(i,n,:)=Shapesvar(i,n,:)-varoffset(1,n);
                    Shapesvar(i,n,:)=Shapes(i,n,:)-Shapesvar(i,n,:);
                    SPIKES3D(i,n,2)=(Shapesvar(i,n,SaRa/1000+1));
                end
                
                SPIKES3D(i,n,2)=(Shapes(i,n,ceil((size(Shapes,3))/2)));
                SPIKES3D(i,n,3)=max(Shapes(i,n,ceil(0.25*SaRa/1000):(size(Shapes,3)-ceil(0.25*SaRa/1000))));
                SPIKES3D(i,n,4)=(Neo_Shapes(i,n,ceil((size(Shapes,3))/2)));
                [C(1),I(1)]= max(Shapes(i,n,1:ceil((size(Shapes,3))/2)));
                [C(2),I(2)]= max(Shapes(i,n,floor(0.25*SaRa/1000):size(Shapes,3)-ceil(0.25*SaRa/1000)));
                
                templeft = [];
                tempright = [];
                
                % Berechnung des Oeffnungswinkels (Andy)/(Robert)
                % 1. left
                for j = ceil((size(Shapes,3))/2):-1:1
                    if Shapes(i,n,j)>=(0.5*Shapes(i,n,ceil((size(Shapes,3))/2)))
                        templeft =  abs((Shapes(i,n,j)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(j-ceil((size(Shapes,3))/2))); % slope of Min to 50% to Min
                        SPIKES3D(i,n,8) = atand(templeft); % calculate in degrees
                        templeft = j/SaRa*1000; % save index;
                        break
                    end
                end
                % 2. right
                for j = ceil((size(Shapes,3))/2):1:size(Shapes,3)
                    if Shapes(i,n,j)>=(0.5*Shapes(i,n,ceil((size(Shapes,3))/2)))
                        tempright =  abs((Shapes(i,n,j)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(j-ceil((size(Shapes,3))/2))); % slope of Min to 50% to Min
                        SPIKES3D(i,n,9) = atand(tempright); % calculate in degrees
                        tempright = j/SaRa*1000;
                        break
                    end
                end
                if size(templeft) == 0
                    templeft = tand(89);
                    SPIKES3D(i,n,8) = 90;
                end
                if size(tempright) == 0
                    tempright = tand(89);
                    SPIKES3D(i,n,9) = 90;
                end
                
                SPIKES3D(i,n,7) = tempright-templeft;
                
                % in case of variable threshold
                if varTdata==1
                    clear temp_datal temp_datar temp_pl temp_pr;
                    Shapesvar(i,n,:)=varT(SPI1(i)+1-SaRa*pretime/1000:SPI1(i)+1+SaRa*posttime/1000,n);  % Shapes with length 2ms
                    Shapesvar(i,n,:)=Shapesvar(i,n,:)-varoffset(1,n);
                    Shapesvar(i,n,:)=Shapes(i,n,:)-Shapesvar(i,n,:);
                    
                    if Shapesvar(i,n,SaRa/1000+1)< 0
                        j=0;
                        while Shapesvar(i,n,SaRa/1000+1-j) <= 0.5*(Shapesvar(i,n,SaRa/1000+1)) && (SaRa/1000+1-j)>1;   %  50% of amplitude
                            
                            temp_datal(j+1,1)=-1000*j*(1/SaRa);
                            temp_datal(j+1,2)=Shapesvar(i,n,SaRa/1000+1-j);
                            j=j+1;  % left
                        end
                        temp_datal(j+1,1)=-1000*j*(1/SaRa);
                        temp_datal(j+1,2)=Shapesvar(i,n,SaRa/1000+1-j);
                        
                        j=0;
                        while Shapesvar(i,n,SaRa/1000+1+j) <= 0.5*(Shapesvar(i,n,SaRa/1000+1)) && (SaRa/1000+1+j)<(size(Shapesvar,3)-1);  %  50% of amplitude
                            
                            temp_datar(j+1,1)=1000*j*(1/SaRa);
                            temp_datar(j+1,2)=Shapesvar(i,n,SaRa/1000+1+j);
                            j=j+1;  % right
                        end
                        temp_datar(j+1,1)=1000*j*(1/SaRa);
                        temp_datar(j+1,2)=Shapesvar(i,n,SaRa/1000+1+j);
                        
                        temp_pl = polyfit(temp_datal(:,1),temp_datal(:,2),1);
                        temp_pr = polyfit(temp_datar(:,1),temp_datar(:,2),1);
                        
                        SPIKES3D(i,n,20)=(Shapesvar(i,n,SaRa/1000+1));
                        
                        SPIKES3D(i,n,21)= roots(temp_pl)*(-1) + roots(temp_pr);
                        
                        SPIKES3D(i,n,22)=atan((roots(temp_pl)*(-1))/(Shapesvar(i,n,SaRa/1000+1)*(-1)));
                        
                        SPIKES3D(i,n,23)=atan((roots(temp_pr))/(Shapesvar(i,n,SaRa/1000+1)*(-1)));
                    end
                end
                SPIKES3D(SPIKES3D(:,n,8)== 90,n,8) = mean(SPIKES3D(SPIKES3D(:,n,8)~= 90,n,8));
                SPIKES3D(SPIKES3D(:,n,9)== 90,n,9) = mean(SPIKES3D(SPIKES3D(:,n,9)~= 90,n,9));
                SPIKES3D(SPIKES3D(:,n,7)== 0,n,7) = mean(SPIKES3D(SPIKES3D(:,n,7)~= 0,n,7));
                clear temp_datal temp_datar temp_pl temp_pr templeft tempright;
            end
        end
    end


% -------------------- calculate_PCA (RB)-------------------------------

    function calculate_PCA(~,~) %calculate principal components
        
        n = Elektrode;
        XX(1:size(Shapes,1),1:size(Shapes,3))=Shapes(:,n,:); % 3D Shapes array down to temporary 2D array
        [~,Score]=pca(XX);
        
        if isempty(get(findobj('Tag','discard'),'value')) == 1 % Test if checkbox discard exists for first Spike Sorting cycle
            discard = 0;
        else
            discard = get(findobj('Tag','discard'),'value');
        end
        
        if discard == 1 &&  size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1 % calculation an recalculation of PCA
            SPIKES3D_discard(:,n,10:13)=Score(:,1:4); %PC 1:4
        else
            SPIKES3D(:,n,10:13)=Score(:,1:4); %PC 1:4
        end
        
        clear Score I;
    end


% -------------------- calculate_area (RB)-------------------------------

    function calculate_area(~,~) % calculate positive und negative Areas
        k=1;
        Temp=0;
        clear MU S i n ZPOS ZNEG POS NEG;
        MU(1:size(Shapes,1),1:size(Shapes,2),1:size(Shapes,3))=zeros;
        n = Elektrode; %if only 1 electrode is calculated
        
        for i=1:size(Shapes,1)% find sign changes in the shapes data
            for j=1:size(Shapes,3)%for all spikes
                if Shapes(i,n,j)~=0
                    if sign(Shapes(i,n,j))~= sign(Temp(1,1))
                        if Temp~=0
                            MU(i,n,k)=j-1;
                            k=k+1;
                        else
                        end
                        Temp=Shapes(i,n,j);
                    else
                    end
                else
                end
            end
            Temp=0;
            k=1;
        end
        i=1;
        
        for i=1:size(Shapes,1)
            for j=1:size(Shapes,3)
                S(i,n,j)=sign(Shapes(i,n,j))*(Shapes(i,n,j))^2;
            end
        end
        
        POS=0;  % test if ZPOS or ZNEG has been used already
        NEG=0;
        ZPOS(1:size(MU,3),1:size(MU,1))=zeros;
        ZNEG(1:size(MU,3),1:size(MU,1))=zeros;
        for i=1:size(S,1) % calculate POS and NEG areas
            for j=1:size(MU,3)
                if (MU(i,n,j)<= 0) && (j>1) % omit zero lines of MU array
                    TMP=((1/SaRa)*(trapz(S(i,n,MU(i,n,j-1)+1:size(S,3)))));
                    if(TMP>=0)
                        if(POS~=0)
                            POS=POS+1;
                            ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                        else
                            POS=1;
                            ZPOS(POS,i)=TMP;
                        end
                        break
                    else
                        if(NEG~=0)
                            NEG=NEG+1;
                            ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                        else
                            NEG=1;
                            ZNEG(NEG,i)=TMP;
                        end
                    end
                    break
                elseif(MU(i,n,j)<=0) && (j<=1) % in case of no sign change
                    TMP=(1/SaRa)*((trapz(S(i,n,1:size(S,3)))));
                    if(TMP>=0)
                        POS=1;
                        ZPOS(POS,i)=TMP;
                    else
                        NEG=1;
                        ZNEG(NEG,i)=TMP;
                    end
                    break
                else
                    if j==1
                        TMP=(1/SaRa)*((trapz(S(i,n,1:MU(i,n,j))))+(0.5*(-S(i,n,MU(i,n,j))/(S(i,n,MU(i,n,j)+1)-S(i,n,MU(i,n,j))))*S(i,n,MU(i,n,j)))); % die Zwischenflaeche beim Vorzeichenwechsel!
                        if(TMP>=0)
                            if(POS~=0)
                                POS=POS+1;
                                ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                            else
                                POS=1;
                                ZPOS(POS,i)=TMP;
                            end
                        else
                            if(NEG~=0)
                                NEG=NEG+1;
                                ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                            else
                                NEG=1;
                                ZNEG(NEG,i)=TMP;
                            end
                        end
                    elseif j>=size(MU,3)
                        TMP=(1/SaRa)*(trapz(S(i,n,MU(i,n,j)+1:size(S,3)))); %consider rest area of shape (necessary as there is one more area part than sign chnage)
                        if(TMP>=0)
                            if(POS~=0)
                                POS=POS+1;
                                ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                            else
                                POS=1;
                                ZPOS(POS,i)=TMP;
                            end
                        else
                            if(NEG~=0)
                                NEG=NEG+1;
                                ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                            else
                                NEG=1;
                                ZNEG(NEG,i)=TMP;
                            end
                        end
                    else
                        TMP=(1/SaRa)*((trapz(S(i,n,MU(i,n,j-1)+1:MU(i,n,j))))+(0.5*(-S(i,n,MU(i,n,j))/(S(i,n,MU(i,n,j)+1)-S(i,n,MU(i,n,j))))*S(i,n,MU(i,n,j)))+(0.5*(1-(-S(i,n,MU(i,n,j-1))/(S(i,n,MU(i,n,j-1)+1)-S(i,n,MU(i,n,j-1)))))*S(i,n,MU(i,n,j-1)+1)));
                        if(TMP>=0)
                            if(POS~=0)
                                POS=POS+1;
                                ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                            else
                                POS=1;
                                ZPOS(POS,i)=TMP;
                            end
                        else
                            if(NEG~=0)
                                NEG=NEG+1;
                                ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                            else
                                NEG=1;
                                ZNEG(NEG,i)=TMP;
                            end
                        end
                    end
                end
            end
            POS=0;
            NEG=0;
        end
        if size(ZPOS,1)~=i
            ZPOS(1,i)=0;
        end
        if size(ZNEG,1)~=i
            ZNEG(1,i)=0;
        end
        
        for i=1:size(Shapes,1) % result of area calculation for every spike of every electrode
            SPIKES3D(i,n,6)=max(ZPOS(:,i));
            SPIKES3D(i,n,5)=min(ZNEG(:,i));
        end
        i=1;
        data= true;
    end


% -------------------- calculate_Wave_Coeff (RB)-------------------------------


    function calculate_Wave_Coeff(~,~)
        
        Coeff =[];
        Entropy = [];
        MX = [];
        SPIKES3D_t = [];
        n = Elektrode; %if only 1 Elektrode is calculated
        
        if isempty(get(findobj('Tag','discard'),'value')) == 1 % Test if checkbox discard exists for first Spike Sorting cycle
            discard = 0;
        else
            discard = get(findobj('Tag','discard'),'value');
        end
        
        if discard == 1 &&  size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1
            SPIKES3D_t(:,1,1:6) = SPIKES3D_discard(:,n,13:18);
        else
            SPIKES3D_t(:,1,1:6) = SPIKES3D(:,n,13:18);
        end
        
        for Nr=1:1
            
            if Nr==1
                for i=1:1:size(nonzeros(Shapes(:,n,1)),1)
                    
                    MX(:,:)=(Shapes(i,n,:));
                    TREE1 = wpdec(MX,3,'db1');
                    Coeff(i,:)=read(TREE1,'data');
                    Entropy(1:size(Coeff,1),15)=zeros; % 15 because of 15 nodes in the wavelet packet tree
                    Entropy(i,:) = read(TREE1,'ent');
                    if isnan(Entropy(i))==1
                        Entropy(i)=0;
                    end
                    
                end
            else
                for i=1:1:size(nonzeros(Shapes(:,n,1)),1)
                    
                    Coeff(i,I1)=zeros; % delete found Coefficients from Signal and repeat WPT
                    TREE = write(TREE1,'data',Coeff(i,:));
                    MX(:,:)=wprec(TREE);
                    TREE = wpdec(MX,3,'db1');
                    Coeff(i,:)=read(TREE,'data');
                    Entropy(i,:) = read(TREE,'ent');
                    if isnan(Entropy(i,:))
                        Entropy(i,:)=0;
                    end
                    
                end
            end
            
            for i=1:size(Coeff,2)
                
                if i<= size(Entropy,2) % Entropy node feature extraction
                    Entropy_Norm(:,i) = (Entropy(1:size(Entropy(:,1),1),i)-min(Entropy(1:size(Entropy(:,1),1),i)))/(max(Entropy(1:size(Entropy(:,1),1),i))-min(Entropy(1:size(Entropy(:,1),1),i)));
                    if min(Entropy_Norm(:,i))~=0
                        Entropy_Norm(:,i) = Entropy_Norm(:,i)*(-1);
                    end
                    
                    if isnan(Entropy_Norm(:,i)) % if all Coeffs are 0 Coeff_Norm becomes NaN, therefore correction term is needed
                        Entropy_Norm(:,i) = zeros;
                        Entropy(:,i) = zeros; % just in case that already Entropy itself is problematic
                    end
                    
                    [y_E,z] = hist(Entropy_Norm(:,i),100); % histogram plot
                    
                    y_E = y_E-min(y_E); % Norm the plots in x and y
                    z = z-min(z);
                    y_E = y_E/max(y_E);
                    z = z/max(z);
                    
                    for nn=1:10 %smoothing iterations
                        y_E = smooth(y_E);    % plot smoothing
                    end
                    [~,I_E(1)]=max(y_E);              % 1. Extremum global maximum of distribution
                    k=2;
                    
                    
                    ERG_E = 0;
                    for j=1:size(y_E)-1
                        dy_E(j,1)= (y_E(j+1,1)-y_E(j,1))/(z(1,j+1)-z(1,j)); % 1.derivative to find extremum
                        if j>1
                            if (dy_E(j,1)<0 && dy_E(j-1,1)>=0)
                                if j~=I_E(1)
                                    I_E(k) = j;  % X-component of maximum via slope
                                    k = k+1;
                                end
                            end
                        end
                    end
                    Mean1_E = I_E./100;
                    k = k-1;
                    for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just in case
                        [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(Entropy_Norm(:,i),k,[],[],1,Mean1_E);
                        if ~isnan(L_EM)
                            break
                        end
                    end
                    Mean1_E = [];
                    Mean1_E_new = [];
                    I_E_new=[];
                    ERG_E = [];
                    I_E=[];
                    y_E = [];
                    
                    if min(min(min(V_EM)))~= 0 && min(W_EM) ~= 0;
                        
                        ob = gmdistribution(M_EM',V_EM,W_EM');
                        Gauss = pdf(ob,z');
                        Gauss = Gauss/max(Gauss); % normalize for better comparing
                        
                        [~,I_E_new(1)]=max(Gauss);
                        k_new = 1;
                        
                        for j=1:size(Gauss)-1
                            dGauss(j,1)= (Gauss(j+1,1)-Gauss(j,1))/(z(1,j+1)-z(1,j)); % 1.derivative to find extremum
                            if j>1
                                if (dGauss(j,1)<0 && dGauss(j-1,1)>=0)
                                    if j~=I_E_new(1)
                                        I_E_new(k_new+1) = j;  % X-component of maximum via slope
                                        k_new = k_new+1;
                                    end
                                end
                            end
                        end
                        Mean1_E_new = [];
                        Mean1_E_new = I_E_new./100;
                        k_new = size(Mean1_E_new,2);
                        
                        if k_new ~= k;
                            for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just in case
                                k = k_new;
                                Mean1_E = [];
                                Mean1_E = Mean1_E_new;
                                [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(Entropy_Norm(:,i),k,[],[],1,Mean1_E);
                                if ~isnan(L_EM)
                                    break
                                end
                            end
                        end
                        
                        if isnan(M_EM(1))
                            M_EM(1) = 1e-10; % if EM fails and is nan change to low value in order to continue process but exclude feature
                        end
                        
                        for j = 1:k_new
                            
                            if j == 1
                                ERG_E(j) = abs((1/V_EM(1,1,j)) / Gauss(ceil(M_EM(1)*100)));
                            elseif abs(L_EM) > 1e5
                                ERG_E(j) = 1e9;
                            else
                                if M_EM(1) < M_EM(j)
                                    Min = min(Gauss(ceil(M_EM(1)*100):ceil(M_EM(j)*100)));
                                else
                                    Min = min(Gauss(ceil(M_EM(j)*100):ceil(M_EM(1)*100)));
                                end
                                ERG_E(j) = abs(sum(V_EM(1,1,:)) / (M_EM(1)-M_EM(j)) / W_EM(j) * exp(Min));
                            end
                        end
                        RES_E(i) = min(ERG_E);
                        
                    else
                        RES_E(i) = 1e9;
                    end
                    Max_Nr(i) = size(ERG_E,2)+1;
                    
                end
                
                Coeff_Norm(:,i) = (Coeff(1:size(Coeff(:,1),1),i)-min(Coeff(1:size(Coeff(:,1),1),i)))/(max(Coeff(1:size(Coeff(:,1),1),i))-min(Coeff(1:size(Coeff(:,1),1),i)));
                if min(Coeff_Norm(:,i))~=0
                    Coeff_Norm(:,i) = Coeff_Norm(:,i)*(-1);
                end
                
                if isnan(Coeff_Norm(:,i)) % if all Coeffs are 0 Coeff_Norm becomes NaN, therefore correction term is needed
                    Coeff_Norm(:,i) = zeros;
                end
                
                [y,z] = hist(Coeff_Norm(:,i),100); % histogram plot
                
                y = y-min(y); % Norm the plots in x and y
                z = z-min(z);
                y = y/max(y);
                z = z/max(z);
                
                for nn=1:10 %smoothing iterations
                    y = smooth(y);    % plot smoothing
                end
                [~,I(1)]=max(y);              % 1. Extremum global maximum of distribution
                k=2;
                
                ERG = 0;
                for j=1:size(y)-1
                    dy(j,1)= (y(j+1,1)-y(j,1))/(z(1,j+1)-z(1,j)); % 1.derivative to find extremum
                    if j>1
                        if (dy(j,1)<0 && dy(j-1,1)>=0)
                            if j~=I(1)
                                I(k) = j;   % X-component of maximum via slope
                                k = k+1;
                            end
                        end
                    end
                end
                Mean1 = I./100;
                k = k-1;
                for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just  in case
                    [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(Coeff_Norm(:,i),k,[],[],1,Mean1);
                    if ~isnan(L_EM)
                        break
                    end
                end
                Mean1 = [];
                Mean1_new = [];
                I_new=[];
                ERG = [];
                I=[];
                y = [];
                
                if k >= 2 % Speeding up the process by ignoring monopolar distributions
                    if min(min(min(V_EM)))~= 0 && min(W_EM) ~= 0;
                        
                        ob = gmdistribution(M_EM',V_EM,W_EM');
                        Gauss = pdf(ob,z');
                        Gauss = Gauss/max(Gauss); % normalize for better comparing
                        
                        [~,I_new(1)]=max(Gauss);
                        k_new = 1;
                        
                        for j=1:size(Gauss)-1
                            dGauss(j,1)= (Gauss(j+1,1)-Gauss(j,1))/(z(1,j+1)-z(1,j)); % 1.derivative to find extremum
                            if j>1
                                if (dGauss(j,1)<0 && dGauss(j-1,1)>=0)
                                    if j~=I_new(1)
                                        I_new(k_new+1) = j;  % X-component of maximum via slope
                                        k_new = k_new+1;
                                    end
                                end
                            end
                        end
                        Mean1_new = [];
                        Mean1_new = I_new./100;
                        k_new = size(Mean1_new,2);
                        
                        if k_new ~= k;
                            for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just  in case
                                k = k_new;
                                Mean1 = [];
                                Mean1 = Mean1_new;
                                [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(Coeff_Norm(:,i),k,[],[],1,Mean1);
                                if ~isnan(L_EM)
                                    break
                                end
                            end
                        end
                        
                        if isnan(M_EM(1))
                            M_EM(1) = 1e-10; % if EM fails and is nan change to low value in order to continue process but exclude feature
                        end
                        
                        for j = 1:k_new
                            
                            if j == 1
                                ERG(j) = abs((1/V_EM(1,1,j)) / Gauss(ceil(M_EM(1)*100)));
                            elseif abs(L_EM) > 1e5
                                ERG(j) = 1e9;
                            else
                                if M_EM(1) < M_EM(j)
                                    Min = min(Gauss(ceil(M_EM(1)*100):ceil(M_EM(j)*100)));
                                else
                                    Min = min(Gauss(ceil(M_EM(j)*100):ceil(M_EM(1)*100)));
                                end
                                ERG(j) = abs(sum(V_EM(1,1,:)) / (M_EM(1)-M_EM(j)) / W_EM(j));
                            end
                        end
                        RES(i) = min(ERG);
                        
                    else
                        RES(i) = 1e9;
                    end
                    
                else
                    RES(i) = 1e9;
                end
                Max_Nr(i) = size(ERG,2)+1;
            end
        end
        
        for Nr=1:3
            
            for m=1:size(RES_E,2)
                [~,I1_E]=min(RES_E); % best entropy coefficient
                for mm=1:Nr-1
                    R = corrcoef(Entropy(:,I1_E),(SPIKES3D_t(1:size(Entropy,1),1,mm)));
                    if (abs(R(1,2)) > 0.2) % analysis of correlation between feature distributions
                        RES_E(I1_E) = 1e9;
                        break
                    end
                end
                if RES_E(I_E)<1e9;
                    break
                end
            end
            
            SPIKES3D_t(1:size(Coeff,1),1,3+Nr) = Entropy(:,I1_E);
            Entropy(:,I1_E) = 0;
            RES_E(I1_E) = max(RES_E)*2;
            Mean1_E = [];
            Mean1_E_new = [];
            I_E_new=[];
            ERG_E = [];
            I_E=[];
            I1_E=[];
            y_E = [];
            
            for m=1:size(RES,2)
                [~,I1]=min(RES); % best distribution coefficient
                for mm=1:Nr-1
                    R = corrcoef(Coeff(:,I1),(SPIKES3D_t(1:size(Coeff,1),1,mm)));
                    if (abs(R(1,2)) > 0.2) % analysis of correlation between feature distributions
                        RES(I1) = 1e9;
                        break
                    end
                end
                if RES(I)<1e9;
                    break
                end
            end
            SPIKES3D_t(1:size(Coeff,1),1,Nr) = Coeff(:,I1);
            RES(I1) = max(RES)*2;
            R = [];
            
            if discard == 1 && size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1 %
                SPIKES3D_discard(1:size(Coeff,1),n,13+Nr) = SPIKES3D_t(1:size(Coeff,1),1,Nr);
                SPIKES3D_discard(1:size(Coeff(:,I),1),n,16+Nr)= SPIKES3D_t(1:size(Coeff,1),1,3+Nr);
            else
                SPIKES3D(1:size(Coeff,1),n,13+Nr) = SPIKES3D_t(1:size(Coeff,1),1,Nr);
                SPIKES3D(1:size(Coeff(:,I),1),n,16+Nr)= SPIKES3D_t(1:size(Coeff,1),1,3+Nr);
            end
        end
        
        
        clear Mean Variance Entropy MX RES RESV TREE k I I1 Nr ERG Coeff R;
    end


% -------------------- Feature_choice (RB)-------------------------------



    function  cln = Feature_choice(~,~) %choose Features to Refine Spikes (select the best 6 Features based on their distribution)
        
        if Sorting == 0
            manual = get(findobj('Tag','manual'),'value');
            F = [{'F1'} {'F2'} {'F3'} {'F4'} {'F5'} {'F6'}];
        else
            if isempty(get(findobj('Tag','SortingPanel'),'value')) == 1 % Test if checkbox discard exists for first Spike Sorting cycle
                manual = 0;
            else
                manual = get(findobj('Tag','S2_manual'),'value');
            end
            F = [{'S_F1'} {'S_F2'} {'S_F3'} {'S_F4'} {'S_F5'} {'S_F6'}];
        end
        discard = 0;
        
        
        check = [];
        
        
        mean_Max_Nr = 0;
        SPIKES3D_Norm=[];
        Max_Nr = [];
        Max_Nr_sort =[];
        check_sort = [];
        RES = [];
        ERG = [];
        I = [];
        I1 = [];
        active = 0;
        SPIKES3D_temp = []; % temporary array added to enable re-refinement of discarded Spike events
        SPIKES3D_Norm = [];
        
        
        if (discard == 1 && size(SPIKES3D_discard,1) ~= 0)||SubmitSorting(Elektrode) >= 1
            SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
        else
            SPIKES3D_temp = SPIKES3D(1:size(nonzeros(SPIKES3D(:,Elektrode,1)),1),Elektrode,:);
        end
        
        for i=2:size(SPIKES3D_temp,3)
            %Norm the different features to secure comparability
            SPIKES3D_Norm(:,i) = (SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i)-min(SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i)))/(max(SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i))-min(SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i)));
            if min(SPIKES3D_Norm(:,i))~=0
                SPIKES3D_Norm(:,i) = SPIKES3D_Norm(:,i)*(-1);
            end
            
            if max(isnan(SPIKES3D_Norm(:,i))) >= 1 % if all Coeffs are 0 Coeff_Norm becomes NaN, therefore correction term is needed
                SPIKES3D_Norm(:,i) = zeros;
                SPIKES3D_temp(:,Elektrode,i) = zeros;
            end
            
            [y,z] = hist(SPIKES3D_Norm(:,i),100); % histogram plot
            y = y-min(y); % Norm the plots in x and y
            z = z-min(z);
            y = y/max(y);
            z = z/max(z);
            
            for nn=1:10 %smoothing iterations
                y = smooth(y);    % plot smoothing
            end
            
            [~,I(1)]=max(y);              % 1. Extremum global maximum of distribution
            k=2;
            
            ERG = 0;
            for j=1:size(y)-1
                dy(j,1)= (y(j+1,1)-y(j,1))/(z(1,j+1)-z(1,j)); % 1.derivative to find extremum
                if j>1
                    if (dy(j,1)<0 && dy(j-1,1)>=0)
                        if j~=I(1)
                            I(k) = j;   % X-component of maximum via slope
                            k = k+1;
                        end
                    end
                end
            end
            Mean1 = I./100;
            k = k-1;
            for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just  in case
                
                if i == 15
                    xxx = 1;
                end
                [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(SPIKES3D_Norm(:,i),k,[],[],1,Mean1);
                if ~isnan(L_EM)
                    break
                end
            end
            Mean1 = [];
            Mean1_new = [];
            I_new=[];
            ERG = [];
            I=[];
            y = [];
            
            if (min(min(min(V_EM)))~= 0 && min(W_EM) ~= 0);
                
                ob = gmdistribution(M_EM',V_EM,W_EM');
                Gauss = pdf(ob,z');
                Gauss = Gauss/max(Gauss); % normalize for better comparing
                
                [~,I_new(1)]=max(Gauss);
                k_new = 1;
                
                for j=1:size(Gauss)-1
                    dGauss(j,1)= (Gauss(j+1,1)-Gauss(j,1))/(z(1,j+1)-z(1,j)); % 1.derivative to find extremum
                    if j>1
                        if (dGauss(j,1)<0 && dGauss(j-1,1)>=0)
                            if j~=I_new(1)
                                I_new(k_new+1) = j;   % X-component of maximum via slope
                                k_new = k_new+1;
                            end
                        end
                    end
                end
                Mean1_new = [];
                Mean1_new = I_new./100;
                
                k_new = size(Mean1_new,2);
                
                if k_new ~= k;
                    for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just in case
                        k = k_new;
                        Mean1 = [];
                        Mean1 = Mean1_new;
                        [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(SPIKES3D_Norm(:,i),k,[],[],1,Mean1);
                        if ~isnan(L_EM)
                            break
                        end
                    end
                end
                
                if isnan(M_EM(1))
                    M_EM(1) = 1e-10; % if EM fails and is nan change to low value in order to continue process but exclude feature
                end
                
                for j = 1:k_new
                    
                    if abs(L_EM) > 1e5 || isnan(L_EM)
                        ERG(j) = 1e9;
                    else
                        if j == 1
                            ERG(j) = abs((1/V_EM(1,1,j)) / Gauss(ceil(M_EM(1)*100)));
                        else
                            if M_EM(1) < M_EM(j)
                                Min = min(Gauss(ceil(M_EM(1)*100):ceil(M_EM(j)*100)));
                            else
                                Min = min(Gauss(ceil(M_EM(j)*100):ceil(M_EM(1)*100)));
                            end
                            ERG(j) = abs(sum(V_EM(1,1,:)) / (M_EM(1)-M_EM(j)) / W_EM(j));
                        end
                    end
                end
                RES(i-1) = min(ERG);
                
            else
                RES(i-1) = 1e9;
            end
            Max_Nr(i-1) = size(ERG,2)+1;
        end
        for i=1:6 % best Features %min(((get(findobj(gcf,'Tag','Feature_Nr'),'value'))+1),size(check,2))
            if min(RES)< 1e9
                for m=1:size(RES,2)
                    [~,I1]=min(RES); % best distribution coefficient
                    for mm=1:i-1
                        R = corrcoef(SPIKES3D_temp(:,1,I1+1),SPIKES3D_temp(:,1,check(mm)));
                        if (abs(R(1,2)) > 0.5) % analysis of correlation between feature distributions
                            RES(I1) = 1e9;
                            break
                        end
                    end
                    if RES(I1) < 1e9
                        break
                    end
                end
                if min(RES) >= 1e9
                    break
                end
                check(i) = I1+1;
            else
                break
            end
            RES(I1) = max(RES)*2;
            set(findobj('Tag',char(F(i))),'value',1);
            if i <= size(check,2)
                set(findobj('Tag',char(F(i))),'value',check(i));
                mean_Max_Nr = (mean_Max_Nr + Max_Nr(check(i)-1));
                active = active +1;
            end
        end
        
        mean_Max_Nr = mean_Max_Nr/active;
        cln = floor(mean_Max_Nr);
        Mean1 = [];
        Mean1_new = [];
        I_new=[];
        ERG = [];
        I=[];
        y = [];
    end


% -------------------- Clusterfunction (RB)-------------------------------

    function Class = Clusterfunction(~,~)
        
        class = [];   % necessary temporary variable
        k_means = 0;
        
        if Sorting == 0
            k_means = get(findobj('Tag','EM_k-means'),'value');
            discard = get(findobj('Tag','discard'),'value');
            manual = get(findobj('Tag','manual'),'value');
            FPCA = get(findobj('Tag','FPCA'),'value');
            F = [{'F1'} {'F2'} {'F3'} {'F4'} {'F5'} {'F6'}];
        else
            if Window == 0
                k_means  = get(findobj('Tag','S_EM_k-means'),'value');
                discard = 0;
                manual = 0;
                FPCA = get(findobj('Tag','S_FPCA'),'value');
                
            else
                manual = get(findobj('Tag','S2_manual'),'value');
                k_means  = get(findobj('Tag','S2_EM_k-means'),'value');
                discard = 0;
                FPCA = get(findobj('Tag','S2_FPCA'),'value');
            end
            F = [{'S_F1'} {'S_F2'} {'S_F3'} {'S_F4'} {'S_F5'} {'S_F6'}];
        end
        if FPCA == 0
            if manual == 0 || size(cln,1)== 0
                cln = Feature_choice;
            end
        else
            cln = 2; % as real number can not be approximated by EM algorithm CLusternukmber is simply set to 2
            SPIKES_FPCA = []; % reset size of SPIKES_FPCA
            if discard == 1 &&  size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1
                XX(1:size(SPIKES3D_discard,1),1:size(SPIKES3D_discard,3)) = SPIKES3D_discard(:,1,:); % 3D Shapes array down to temporary 2D array
            else
                XX(1:size(SPIKES3D,1),1:size(SPIKES3D,3)) = SPIKES3D(:,Elektrode,:); % 3D Shapes array down to temporary 2D array
            end
            
            [~,Score,latent] = pca(XX);
            clear XX;
            sum_latent = sum(latent);
            for i=1:size(Score,2)
                if (latent(i)/sum_latent) >= 0.1 || i < 3 % Evaluation of explained variance
                    SPIKES_FPCA(:,i) = Score(:,i); %PC 1:n
                end
            end
        end
        
        if Sorting == 0
            k = cln;
        else
            if Window == 0
                if str2double(get(findobj('Tag','S_K_Nr','parent',t6),'string')) ~= 0
                    k = str2double(get(findobj('Tag','S_K_Nr','parent',t6),'string'));
                else
                    k = cln;
                end
            else
                if str2double(get(findobj('Tag','S2_K_Nr'),'string')) ~= 0
                    k = str2double(get(findobj('Tag','S2_K_Nr'),'string'));
                else
                    k = cln;
                end
            end
        end
        
        clear W_EM M_EM V_EM L_EM;
        W_EM = [];
        M_EM = [];
        V_EM = [];
        L_EM = [];
        SPIKES3D_temp = [];
        
        if FPCA == 0
            if discard == 1 &&  size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1
                SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
            else
                SPIKES3D_temp = SPIKES3D(1:size(nonzeros(SPIKES3D(:,Elektrode,1)),1),Elektrode,:);
            end
        else
            SPIKES3D_temp(:,1,:) = SPIKES_FPCA(:,1:size(SPIKES_FPCA,2));
            check = 1:size(SPIKES_FPCA,2); % convert check, so that the algorithm also works for FPCA
        end
        
        
        if isempty(get(findobj('Tag','F(1)'),'value')) == 1
            
            for i=1:size(check,2)
                X(:,i) = SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1, check(i));
                XX_N(:,i) = (X(:,i)-min(X(:,i)))/(max(X(:,i))-min(X(:,i)));
            end
            X(:,1:2)=SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,[check(1) check(2)]); % necessary to keep scatterplot consistent
        else
            
            for i=1:6
                
                if (get(findobj('Tag',char(F(i))),'value'))~= 1
                    X(:,i) = SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1, get(findobj('Tag',char(F(i))),'value'));
                    XX_N(:,i) = (X(:,i)-min(X(:,i)))/(max(X(:,i))-min(X(:,i)));
                end
            end
            X(:,1:2)=SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,[(get(findobj('Tag','F1'),'value')) (get(findobj('Tag','F2'),'value'))]); % necessary to keep scatterplot consistent
        end
        
        
        if k_means == 1
            [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(XX_N(:,:),k,[],[],1,[]);
            
            [Class,~] = kmeans(XX_N,k,'start',M_EM','emptyaction','singleton');
            Probability(size(XX_N)) = 1;
            
        else
            
            BIC_old = 0;
            C_EM = 0;
            
            for i = 1:5 % iterative loop as bad Features can be present in first loops
                [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(XX_N(:,:),k,[],[],1,[]);
                obj = gmdistribution(M_EM',V_EM,W_EM');
                sig = obj.Sigma;
                e(:,:) =abs(mean(sig,1));
                
                if min(min(e))==0
                    [~,I] = min(min(e,[],2));
                    if I == 1
                        XX_temp = XX_N(:,I+1:size(XX_N,2));
                    elseif I == size(XX_N,2)
                        XX_temp = XX_N(:,1:I-1);
                    else
                        XX_temp = XX_N(:,1:I-1);
                        XX_temp(:,I:size(XX_N,2)-1) = XX_N(:,I+1:size(XX_N,2));
                    end
                    
                    XX_N = [];
                    XX_N = XX_temp;
                    clear XX_temp;
                    
                    check_temp = check(check ~= check(I));
                    check = [];
                    check = check_temp;
                    e = [];
                    
                    for i = 1:6     % correct Feature selection
                        set(findobj('Tag',char(F(i))),'value',1);
                        if i <= size(check,2)
                            set(findobj('Tag',char(F(i))),'value',check(i));
                        end
                    end
                    
                else
                    if ~isnan(L_EM)
                        break;
                    end
                end
            end
            
            if Window == 0
                p = 0;
            else
                p = str2double(get(findobj('Tag','confidence'),'string'))/100;
            end
            
            [class,~,~,ln]  = cluster(obj,XX_N);
            Class = [];
            Class =class;
            if p >= 0
                Class(exp(ln)<=p) = max(Class)+1;
            end
        end
        
        if Sorting == 0
            
            Cl = k;
            
            while (Cl>2)
                
                for i=1:k-1
                    for n=1:k-i
                        DIST(i,n) = sum(abs(M_EM(:,i)-M_EM(:,i+n)));
                    end
                end
                DIST(DIST==0)=max(max(DIST))*10;
                C = min(min(DIST));
                [I(1),I(2)] =find(DIST==C);
                Class(Class==I(2)+I(1),1)=I(1);
                M_EM(:,I(2)+I(1)) = max(max(DIST))*10;
                Cl = Cl-1;
            end
            Class(Class == min(Class))= 1;
            Class(Class~=1) = 2; % Setting Clusternumbers to 1 and 2
        end
        
    end


% -------------------- Submit (RB)-------------------------------

    function Submit(~,~)
        
        if isempty(get(findobj('Tag','discard'),'value')) == 1 % Test if checkbox discard exists for first Spike Sorting cycle
            discard = 0;
        else
            discard = get(findobj('Tag','discard'),'value');
        end
        
        if discard == 0 || size(SPIKES3D_discard,1) == 0
            
            n = Elektrode;
            I = (mean(SPIKES3D(Class~=1,n,2))<= mean(SPIKES3D(Class==1,n,2))); % determining the Spike Cluster based on mean neg. Amplitude
            spikes = I+1;
            SPIKES3D_OLD = SPIKES3D;
            SPIKES_OLD = SPIKES;
            SPIKES3D_NEW(:,n,:) = SPIKES3D((Class == spikes),n,:);
            SPIKES_NEW(:,n) = SPIKES((Class == spikes),n);
            SPIKES3D_discard(1:size(SPIKES3D(Class ~= spikes),1),1,:) = SPIKES3D((Class ~= spikes),n,:);
            SPIKES3D = [];
            SPIKES = [];
            s = size(SPIKES3D_OLD,1);
            
            if  s > size(SPIKES3D_OLD(:,n,:),1)
                SPIKES3D = SPIKES3D_OLD(1:s,:,:);
                SPIKES = SPIKES_OLD(1:s,:);
            else
                for i=1:size(SPIKES3D_OLD,2)
                    New_Size(i) = size(nonzeros(SPIKES3D_OLD(:,i,1)),1);
                    if i == n
                        New_Size(i) = 0;
                    end
                end
                New_Size(1) = max(New_Size);
                if size(SPIKES3D_NEW,1)> New_Size(1)
                    SPIKES3D = SPIKES3D_OLD(1:size(SPIKES3D_NEW,1),:,:);
                    SPIKES = SPIKES_OLD(1:size(SPIKES_NEW,1),:);
                else
                    SPIKES3D = SPIKES3D_OLD(1:New_Size(1),:,:);
                    SPIKES = SPIKES_OLD(1:New_Size(1),:);
                end
            end
            SPIKES3D(:,n,:) = zeros;
            SPIKES3D(1:size(SPIKES3D_NEW,1),n,:) = SPIKES3D_NEW(:,n,:);
            SPIKES3D_NEW = [];
            SPIKES3D_OLD = [];
            
            SPIKES(:,n) = zeros;
            SPIKES(1:size(SPIKES_NEW,1),n) = SPIKES_NEW(:,n);
            SPIKES_NEW = [];
            SPIKES_OLD = [];
            NR_SPIKES(n) = size(nonzeros(SPIKES(:,n)),1);
            clear SPIKES3D_NEW SPIKES3D_OLD s spikes SPIKES_NEW SPIKES_OLD;
            Class = [];
            Class(1:size(nonzeros(SPIKES(:,n)),1),1) = 1;
        else
            n = Elektrode;
            I = (mean(SPIKES3D_discard(Class~=1,n,2))<= mean(SPIKES3D_discard(Class==1,n,2))); % determining the Spike Cluster based on mean neg. Amplitude
            spikes = I+1;
            SPIKES3D_NEW(:,n,:) = SPIKES3D_discard((Class == spikes),1,:);
            SPIKES_NEW(:,n) = SPIKES3D_discard((Class == spikes),1,1);
            SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = zeros;
            SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = zeros;
            SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = SPIKES3D_NEW(:,n,:);
            SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = SPIKES_NEW(:,n);
            
            X_temp(:,:) = SPIKES3D(1:size(nonzeros(SPIKES3D(:,n,1)),1),n,:);
            X_temp = sortrows(X_temp,1);
            SPIKES3D(1:size(nonzeros(SPIKES3D(:,n,1)),1),n,:)= X_temp;
            SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n)= sortrows(SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n),1);
            
            NR_SPIKES(n) = size(nonzeros(SPIKES(:,n)),1);
            SPIKES3D_discard = [];
            clear SPIKES3D_NEW SPIKES3D_OLD s spikes SPIKES_NEW SPIKES_OLD X_temp;
        end
        scale = get(scalehandle,'value');   % set Y-scale
        switch scale
            case 1, scale = 50;
            case 2, scale = 100;
            case 3, scale = 200;
            case 4, scale = 500;
            case 5, scale = 1000;
        end
        
        BURSTS.BEG(:,n) = zeros;
        BURSTS.BRn(n) = 0;
        if Viewselect == 0
            
            scroll_bar = (size(EL_NAMES,1)-Elektrode);
            
            if size(EL_NAMES,1)<=4
                
                delete (SubMEA_vier(Elektrode));
                SubMEA_vier(Elektrode)=subplot(4,1,Elektrode,'Parent',mainWindow);
                set(SubMEA_vier(Elektrode),'Parent',bottomPanel);
                plot(T,RAW.M(:,Elektrode),'Parent',SubMEA_vier(Elektrode));
                hold all;
                axis(SubMEA_vier(Elektrode),[0 T(size(T,2)) -1*scale scale]);
                set(SubMEA_vier(Elektrode),'XGRID','on');
                set(SubMEA_vier(Elektrode),'YGRID','on');
                Plot_type = SubMEA_vier(Elektrode);
                
                Graph =Elektrode;
                
            elseif scroll_bar < 3 % special case if selected Electrode can't be set as top graph
                
                set(findobj('Tag','CELL_slider'),'value',size(RAW.M,2)-Elektrode - scroll_bar);   % Position of Scrollbar
                for v = 1:4
                    uicontrol('style', 'text',...
                        'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 12,'units', 'pixels', 'position', [25 450-(v-1)*120 50 25],...
                        'Parent', bottomPanel, 'Tag', 'ShowElNames','String', EL_NAMES(Elektrode+v-1-(3-scroll_bar)));
                    delete (SubMEA_vier(v));
                    SubMEA_vier(v)=subplot(4,1,v,'Parent',mainWindow);
                    set(SubMEA_vier(v),'Parent',bottomPanel);
                    plot(T,RAW.M(:,Elektrode+v-1-(3-scroll_bar)),'Parent',SubMEA_vier(v));
                    hold on;
                    axis(SubMEA_vier(v),[0 T(size(T,2)) -1*scale scale]);
                    set(SubMEA_vier(v),'XGRID','on');
                    set(SubMEA_vier(v),'YGRID','on');
                    hold off;
                    Plot_type = SubMEA_vier(v);
                    Graph = scroll_bar;
                    
                    if varTdata==1
                        line ('Xdata',T,'Ydata',varT(:,Elektrode+v-1),...
                            'LineStyle','--','Color','red','Parent',Plot_type);
                        % draw variable threshold (AD)
                    end
                    if thresholddata
                        if varTdata==0;                                                     % test if variable thresholdis selected
                            if get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t6),'value');   % Thresholds
                                line ('Xdata',[0 T(length(T))],...
                                    'Ydata',[THRESHOLDS(Elektrode+v-1-(3-scroll_bar)) THRESHOLDS(Elektrode+v-1-(3-scroll_bar))],...
                                    'LineStyle','--','Color','red','Parent',Plot_type);
                            end
                        end
                    end
                    
                    if spikedata==1
                        set(findobj('Tag','ShowSpikesBurstsperEL','Parent',t5),'Visible','on');
                        
                        %show Nr. of Spikes (AD)
                        uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 462-(v-1)*120 30 20],...
                            'Parent', bottomPanel, 'Tag', 'ShowSpikesBurstsperEL','String', NR_SPIKES(Elektrode+v-1-(3-scroll_bar)));
                        
                        %Show Nr. of Bursts
                        uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 432-(v-1)*120 30 20],...
                            'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', 0);
                        
                        if get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t6),'value');       % Spikes
                            SP = nonzeros(SPIKES(:,Elektrode+v-1-(3-scroll_bar)));                            % (green triangles)
                            if isempty(SP)==0
                                y_axis = ones(length(SP),1).*scale.*.9;
                                line ('Xdata',SP,'Ydata', y_axis,...
                                    'LineStyle','none','Marker','v',...
                                    'MarkerFaceColor','green','MarkerSize',9,'Parent',Plot_type);
                            end
                        end
                    end
                    if stimulidata==1
                        if get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t6),'value');  % Stimuli
                            for k=1:length(BEGEND)                                       % (red lines)
                                line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                                    'Color','red', 'LineWidth',1,'Parent',Plot_type);
                            end
                        end
                    end
                end
                
            else
                
                set(findobj('Tag','CELL_slider'),'value',size(RAW.M,2)-Elektrode - 3);   % Position of Scrollbar
                for v = 1:4
                    uicontrol('style', 'text',...
                        'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 12,'units', 'pixels', 'position', [25 450-(v-1)*120 50 25],...
                        'Parent', bottomPanel, 'Tag', 'ShowElNames','String', EL_NAMES(Elektrode+v-1));
                    delete (SubMEA_vier(v));
                    SubMEA_vier(v)=subplot(4,1,v,'Parent',mainWindow);
                    set(SubMEA_vier(v),'Parent',bottomPanel);
                    plot(T,RAW.M(:,Elektrode+v-1),'Parent',SubMEA_vier(v));
                    hold on;
                    axis(SubMEA_vier(v),[0 T(size(T,2)) -1*scale scale]);
                    set(SubMEA_vier(v),'XGRID','on');
                    set(SubMEA_vier(v),'YGRID','on');
                    hold off;
                    Plot_type = SubMEA_vier(v);
                    Graph = 1;
                    
                    if varTdata==1
                        line ('Xdata',T,'Ydata',varT(:,Elektrode+v-1),...
                            'LineStyle','--','Color','red','Parent',Plot_type);
                        % draw variable threshold (AD)
                    end
                    if thresholddata
                        if varTdata==0;                                                     % test if variable thresholdis selected
                            if get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t6),'value');   % Thresholds
                                line ('Xdata',[0 T(length(T))],...
                                    'Ydata',[THRESHOLDS(Elektrode+v-1) THRESHOLDS(Elektrode+v-1)],...
                                    'LineStyle','--','Color','red','Parent',Plot_type);
                            end
                        end
                    end
                    
                    if spikedata==1
                        set(findobj('Tag','ShowSpikesBurstsperEL','Parent',t5),'Visible','on');
                        
                        %show Nr. of Spikes (AD)
                        uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 462-(v-1)*120 30 20],...
                            'Parent', bottomPanel, 'Tag', 'ShowSpikesBurstsperEL','String', NR_SPIKES(Elektrode+v-1));
                        
                        %show Nr. of Bursts (AD)
                        uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 432-(v-1)*120 30 20],...
                            'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', 0);
                        
                        if get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t6),'value');       % Spikes
                            SP = nonzeros(SPIKES(:,Elektrode+v-1));                            % (green triangles)
                            if isempty(SP)==0
                                y_axis = ones(length(SP),1).*scale.*.9;
                                line ('Xdata',SP,'Ydata', y_axis,...
                                    'LineStyle','none','Marker','v',...
                                    'MarkerFaceColor','green','MarkerSize',9,'Parent',Plot_type);
                            end
                        end
                    end
                    if stimulidata==1
                        if get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t6),'value');  % Stimuli
                            for k=1:length(BEGEND)                                       % (red lines)
                                line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                                    'Color','red', 'LineWidth',1,'Parent',Plot_type);
                            end
                        end
                    end
                end
                
            end
            
        elseif Viewselect == 1;
            
            set(findobj('Tag','CELL_BottomPanel'),'Visible','off');
            set(findobj('Tag','CELL_BottomPanel_zwei'),'Visible','on');
            MEAslider_pos = double(int8(get(findobj('Tag','MEA_slider'),'value')));
            
            ALL_CHANNELS = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
            ZUORDNUNG2= [9 17 25 33 41 49 2 10 18 26 34 42 50 58 3 11 19 27 35 43 51 59 4 12 20 28 36 44 52 60 5 13 21 29 37 45 53 61 6 14 22 30 38 46 54 62 7 15 23 31 39 47 55 63 16 24 32 40 48 56];
            
            subplotposition = ZUORDNUNG2(find(ALL_CHANNELS==EL_NUMS(Elektrode)));
            delete(SubMEA(subplotposition));
            showend = MEAslider_pos*SaRa + 1;
            showstart = showend - SaRa;
            
            if Elektrode == 49
                set(gca,'xlim',([T(showstart) T(showend)]),'XTickLabel',T(showstart):0.5:T(showend+1),'YTickLabel',[-1*scale 0 scale], 'FontSize',6);
            end
            
            SubMEA(Elektrode) = subplot(8,8,subplotposition,'Parent',mainWindow);
            set(SubMEA(Elektrode),'Parent',bottomPanel_zwei);
            %address correct Subplots
            plot(T(showstart:showend),RAW.M(showstart:showend,Elektrode),'Parent',SubMEA(Elektrode))                   %draw in this Subplot
            hold all;
            axis(SubMEA(Elektrode),[T(showstart) T(showend) -1*scale scale])
            set(SubMEA(Elektrode),'XTickLabel',[],'YTickLabel',[]);
            hold off;
            if (EL_NUMS(Elektrode) == 17)
                set(SubMEA(Elektrode),'xlim',([T(showstart) T(showend)]),'XTickLabel',T(showstart):0.5:T(showend+1),'YTickLabel',[-1*scale 0 scale], 'FontSize',6);
            end
            
            if Elektrode <= 8
                Elzeile = strcat('El X ',num2str(Elektrode));
                uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'FontSize', 11,'units', 'pixels', 'position', [30 525-Elektrode*57 60 25],...
                    'Parent', bottomPanel_zwei, 'String', Elzeile);
            end
            
            if Elektrode <= 8
                Elspalte = strcat({'El '}, num2str(Elektrode),{'X'});
                uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'FontSize', 11,'units', 'pixels', 'position', [54+Elektrode*121 520 60 25],...
                    'Parent', bottomPanel_zwei, 'String', Elspalte);
            end
            
            Plot_type = SubMEA(Elektrode);
            
            Graph = Elektrode;
        end
        if varTdata==1
            line ('Xdata',T,'Ydata',varT(:,Elektrode),...
                'LineStyle','--','Color','red','Parent',Plot_type);
            % draw variable threshold (AD)
        end
        if thresholddata
            if varTdata==0;                                                     % test if variable thresholdis selected
                if get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t6),'value');   % Thresholds
                    line ('Xdata',[0 T(length(T))],...
                        'Ydata',[THRESHOLDS(Elektrode) THRESHOLDS(Elektrode)],...
                        'LineStyle','--','Color','red','Parent',Plot_type);
                end
            end
        end
        
        if spikedata==1
            set(findobj('Tag','ShowSpikesBurstsperEL','Parent',t5),'Visible','on');
            
            %show Nr. of Spikes (AD)
            uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 462-(Graph-1)*120 30 20],...
                'Parent', bottomPanel, 'Tag', 'ShowSpikesBurstsperEL','String', NR_SPIKES(Elektrode));
            
            %show Nr. of Bursts (AD)
            uicontrol('style', 'text', 'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 432-(Graph-1)*120 30 20],...
                'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', 0);
            
            if get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t6),'value');       % Spikes
                SP = nonzeros(SPIKES(:,Elektrode));                            % (green triangles)
                if isempty(SP)==0
                    y_axis = ones(length(SP),1).*scale.*.9;
                    line ('Xdata',SP,'Ydata', y_axis,...
                        'LineStyle','none','Marker','v',...
                        'MarkerFaceColor','green','MarkerSize',9,'Parent',Plot_type);
                end
            end
        end
        if stimulidata==1
            if get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t6),'value');  % Stimuli
                for k=1:length(BEGEND)                                       % (red lines)
                    line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                        'Color','red', 'LineWidth',1,'Parent',Plot_type);
                end
            end
        end
        SubmitRefinement = 1;
    end


% -------------------- Expectation Maximation(RB)--------------------------

% Written by
%   Patrick P. C. Tsui,
%   PAMI research group
%   Department of Electrical and Computer Engineering
%   University of Waterloo,
%   March, 2006
%  Original Code edited by (RB)

    function [W,M,V,L] = EM_GM_Dr_cell(XX_N,k,ltol,maxiter,pflag,Mean1)
        % [W,M,V,L] = EM_GM(X,k,ltol,maxiter,pflag,Init)
        
        if nargin <= 1,
            return
        elseif nargin == 2,
            ltol = 1e-12; maxiter = 1000; pflag = 0; Init = [];
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            if err_X || err_k, return; end
        elseif nargin == 3,
            maxiter = 1000; pflag = 0; Init = [];
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            [ltol,err_ltol] = Verify_ltol(ltol);
            if err_X || err_k || err_ltol, return; end
        elseif nargin == 4,
            pflag = 0;  Init = [];
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            [ltol,err_ltol] = Verify_ltol(ltol);
            [maxiter,err_maxiter] = Verify_maxiter(maxiter);
            if err_X || err_k || err_ltol || err_maxiter, return; end
        elseif nargin == 5
            Init = [];
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            [ltol,err_ltol] = Verify_ltol(ltol);
            [maxiter,err_maxiter] = Verify_maxiter(maxiter);
            [pflag,err_pflag] = Verify_pflag(pflag);
            if err_X || err_k || err_ltol || err_maxiter || err_pflag, return; end
        elseif nargin == 6
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            [ltol,err_ltol] = Verify_ltol(ltol);
            [maxiter,err_maxiter] = Verify_maxiter(maxiter);
            [pflag,err_pflag] = Verify_pflag(pflag);
            err_Init = 0;
            Init = [];
            if err_X || err_k || err_ltol || err_maxiter || err_pflag ||err_Init , return; end %  extracted
        else
            return
        end
        
        %%%% Initialize W, M, V,L %%%%
        t = cputime;
        
        if isempty(Init)
            Mean1 = Mean1;  % ??
            [W,M,V] = Init_EM(XX_N,k,Mean1);
            L = 0;
        else
            W = Init.W;
            M = Init.M;
            V = Init.V;
            Mean1 = Mean1; %% ??
        end
        Ln = Likelihood(XX_N,k,W,M,V); % Initialize log likelihood
        Lo = 2*Ln;
        
        %%%% EM algorithm %%%%
        niter = 0;
        
        while (abs(100*(Ln-Lo)/Lo)>ltol) && (niter<=maxiter)
            E = Expectation(XX_N,k,W,M,V); % E-step
            [W,M,V] = Maximization(XX_N,k,E);  % M-step
            Lo = Ln;
            Ln = Likelihood(XX_N,k,W,M,V);
            niter = niter + 1;
        end
        L = Ln;
    end
%%%% End of EM_GM %%%%

    function E = Expectation(XX_N,k,W,M,V)
        [n,d] = size(XX_N);
        a = (2*pi)^(0.5*d);
        S = zeros(1,k);
        iV = zeros(d,d,k);
        for j=1:k
            if V(:,:,j)==zeros(d,d), V(:,:,j)=ones(d,d)*eps; end
            S(j) = sqrt(det(V(:,:,j)));
            iV(:,:,j) = inv(V(:,:,j));
        end
        E = zeros(n,k);
        for i=1:n
            for j=1:k
                dXM = XX_N(i,:)'-M(:,j);
                pl = exp(-0.5*dXM'*iV(:,:,j)*dXM)/(a*S(j));
                E(i,j) = W(j)*pl;
            end
            E(i,:) = E(i,:)/sum(E(i,:));
        end
    end

%%%% End of Expectation %%%%

    function [W,M,V] = Maximization(XX_N,k,E)
        [n,d] = size(XX_N);
        W = zeros(1,k); M = zeros(d,k);
        V = zeros(d,d,k);
        for i=1:k,  % Compute weights
            for j=1:n,
                W(i) = W(i) + E(j,i);
                M(:,i) = M(:,i) + E(j,i)*XX_N(j,:)';
            end
            M(:,i) = M(:,i)/W(i);
        end
        for i=1:k,
            for j=1:n,
                dXM = XX_N(j,:)'-M(:,i);
                V(:,:,i) = V(:,:,i) + E(j,i)*dXM*dXM';
            end
            V(:,:,i) = V(:,:,i)/W(i);
        end
        W = W/n;
    end
%%%% End of Maximization %%%%

    function L = Likelihood(XX_N,k,W,M,V)
        
        % Compute L based on K. V. Mardia, "Multivariate Analysis", Academic Press, 1979, PP. 96-97
        % to enchance computational speed
        [n,d] = size(XX_N);
        U = mean(XX_N)';
        S = cov(XX_N);
        L = 0;
        for i=1:k,
            iV = inv(V(:,:,i));
            L = L + W(i)*(-0.5*n*log(det(2*pi*V(:,:,i))) ...
                -0.5*(n-1)*(trace(iV*S)+(U-M(:,i))'*iV*(U-M(:,i))));
        end
    end

%%%% End of Likelihood %%%%


    function err_X = Verify_X(XX_N)
        err_X = 1;
        [n,d] = size(XX_N);
        if n<d,
            return
        end
        err_X = 0;
    end

%%%% End of Verify_X %%%%


    function err_k = Verify_k(k)
        err_k = 1;
        if ~isnumeric(k) || ~isreal(k) || k<1,
            return
        end
        err_k = 0;
    end

%%%% End of Verify_k %%%%

    function [ltol,err_ltol] = Verify_ltol(ltol)
        err_ltol = 1;
        if isempty(ltol),
            ltol = 0.1;
        elseif ~isreal(ltol) || ltol<=0
            return
        end
        err_ltol = 0;
    end

%%%% End of Verify_ltol %%%%

    function [maxiter,err_maxiter] = Verify_maxiter(maxiter)
        err_maxiter = 1;
        if isempty(maxiter),
            maxiter = 1000;
        elseif ~isreal(maxiter) || maxiter<=0,
            return
        end
        err_maxiter = 0;
    end

%%%% End of Verify_maxiter %%%%

    function [pflag,err_pflag] = Verify_pflag(pflag)
        err_pflag = 1;
        if isempty(pflag),
            pflag = 0;
        elseif pflag~=0 & pflag~=1,
            return
        end
        err_pflag = 0;
    end

%%%% End of Verify_pflag %%%%

    function [Init,err_Init] = Verify_Init(Init)
        err_Init = 1;
        if isempty(Init)
        elseif isstruct(Init)
            [Wd,Wk] = size(Init.W);
            [Md,Mk] = size(Init.M);
            [Vd1,Vd2,Vk] = size(Init.V);
            if Wk~=Mk || Wk~=Vk || Mk~=Vk
                return
            end
            if Md~=Vd1 || Md~=Vd2 || Vd1~=Vd2
                return
            end
        else
            return
        end
        err_Init = 0;
    end

%%%% End of Verify_Init %%%%

    function [W,M,V] = Init_EM(XX_N,k,Mean1)
        [n,d] = size(XX_N);
        if size(Mean1) == 0
            [Ci,C] = kmeans(XX_N,k,'Start','cluster', ...
                'Maxiter',100, ...
                'EmptyAction','drop', ...
                'Display','off');
        else
            [Ci,C] = kmeans(XX_N,k,'Start',Mean1', ...
                'Maxiter',100, ...
                'EmptyAction','drop', ...
                'Display','off'); % Ci(nx1) - cluster indeices; C(k,d) - cluster centroid (i.e. mean)
            
            while sum(isnan(C))>0,
                [Ci,C] = kmeans(XX_N,k,'Start',Mean1', ...
                    'Maxiter',100, ...
                    'EmptyAction','drop', ...
                    'Display','off');
            end
        end
        M = C';
        Vp = repmat(struct('count',0,'X',zeros(n,d)),1,k);
        for i=1:n, % Separate cluster points
            Vp(Ci(i)).count = Vp(Ci(i)).count + 1;
            Vp(Ci(i)).XX_N(Vp(Ci(i)).count,:) = XX_N(i,:);
        end
        V = zeros(d,d,k);
        for i=1:k,
            W(i) = Vp(i).count/n;
            V(:,:,i) = cov(Vp(i).XX_N(1:Vp(i).count,:));
        end
    end

%%%% End of Init_EM %%%%


% -------------------- Spike Sorting (RB)-------------------------------

    function Spike_Sorting(~,~)
        
        Var = [{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
            {'Wavelet Energy 2'};{'Wavelet Energy 3'}];
        
        Var_var =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
            {'Wavelet Energy 2'};{'Wavelet Energy 3'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};
            {'Right Spk. Angle(Neg./var.)'}];
        
        Var_neither =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            ];
        
        Var_no_wave =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
            {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
            {'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};{'Right Spk. Angle(Neg./var.)'}];
        
        units = [{'Voltage / uV'};{'Voltage / uV'};{'Scalar'};{'Energy / V ^2 / s'};{'Energy / V ^2 / s'};{'Time / ms'};{'Scalar'};{'Scalar'};
            {'Scalar'};{'Scalar'};{'Gradient uV / s'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};
            {'Voltage / uV'};{'Time / ms'};{'Scalar'};{'Scalar'};];
        
        if varTdata~=1
            V = Var;
        else
            V =  Var_var;
        end
        
        F = [{'S_F1'} {'S_F2'} {'S_F3'} {'S_F4'} {'S_F5'} {'S_F6'}];
        
        data = 0;
        Spike = 0;
        Elektrode = [];
        ST = 1;
        Min(1:(size(SPIKES,1))) = zeros;
        Max(1:(size(SPIKES,1))) = zeros;
        XX=[];
        Class(1:size(SPIKES,1)) = zeros;
        check = [];
        cln = [];
        k = 2;
        pretime = 0.5;
        posttime = 0.5;
        SPIKES3D_discard = [];
        Window = 0;
        Spkplot1 = [];
        Spkplot2 = [];
        spikes = [];
        SPIKES3D_temp = [];
        M_old = [];
        all = 0;
        
        preti = (0.5:1000/SaRa:2);
        postti = (0.5:1000/SaRa:2);
        
        start_sorting;
        
        function start_sorting(~,~)
            
            tic
            w = waitbar(.1,'Please wait - Spike Sorting in progress...');
            F = [{'S_F1'} {'S_F2'} {'S_F3'} {'S_F4'} {'S_F5'} {'S_F6'}];
            
            SPIKES3D_temp = [];
            Shapes_temp = [];
            Class(:,:) = [];
            
            Elektrode = get(findobj('Tag','S_Elektrodenauswahl'),'value');
            Sorting = 1; % Variable to discriminate between calls from Sorting and Refinement tool
            
            if size(SPIKES3D_discard,1) == 0
                SubmitSorting(Elektrode) = 0;
            end
            
            pretime = preti(get(findobj('Tag','S_pretime'),'value'));
            posttime = postti(get(findobj('Tag','S_posttime'),'value'));
            
            Shapes=[];
            if SubmitSorting(Elektrode) >= 1
                Shapes(1:size(SPIKES3D_discard,1),1:size(SPIKES3D_discard,2),1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))=zeros;
                SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
            else
                Shapes(1:size(SPIKES,1),1:size(SPIKES,2),1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))=zeros;
            end
            
            Shape(pretime,posttime);
            waitbar(.15,w,'Please wait - Features being calculated...')
            if data == false % check if data has already been calculated
                
                
                if varTdata~=1 % selection of right set of Feature Strings
                    if get(findobj('Tag','S_Wavelet'),'value')==1
                        V = Var;
                    else
                        V = Var_neither;
                    end
                else
                    if get(findobj('Tag','S_Wavelet'),'value')==1
                        V =  Var_var;
                    else
                        V = Var_no_wave;
                    end
                end
                
                calculate(V,pretime,posttime); %claculate basic Features (Amplitude, NEO, PCA, Spike Angles, Min-Max-Ratio, Spike Duration)
                calculate_area; %calculate Areas of Spikes
            end
            % calculate PCA and Wavelet for each sorting stage
            if submit_data == 1 || Window == 0
                calculate_PCA; %calculate principal components
                waitbar(.3,w,'Please wait - Wavelet Features being calculated...')
                if get(findobj('Tag','S_Wavelet'),'value')==1
                    calculate_Wave_Coeff; %calculate Wavelet Coefficients (Energy and Variance Criteria)
                end
                submit_data = 0;
            end
            
            waitbar(.6,w,'Please wait - Clustering...')
            
            if Window == 1
                for i = 1:6
                    if get(findobj('Tag',char(F(i))),'value') ~=1
                        check(i) = get(findobj('Tag',char(F(i))),'value');
                    else
                        check(i) = 0;
                    end
                end
                check = nonzeros(check);
                check = check';
            end
            
            Class = Clusterfunction;
            k =max(Class);
            
            if  Window == 0
                
                %Main Window
                SpikeSortingWindow = figure('Name','Spike Sorting','NumberTitle','off','Position',[45 100 1200 600],'Toolbar','none','Resize','off','Tag','SpikeSortingWindow');
                
                
                %Main Window header
                uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [180 455 250 20],'HorizontalAlignment','center','String','Identified Clusters','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [600 455 250 20],'HorizontalAlignment','center','String','Cluster 1','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [600 230 250 20],'HorizontalAlignment','center','String','Cluster 2','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',SpikeSortingWindow,'Position', [1120 460 70 20],'String','Submit','FontSize',11,'FontWeight','bold','callback',@ S_Submitbutton_top);
                uicontrol('Parent',SpikeSortingWindow,'Position', [1120 235 70 20],'String','Submit','FontSize',11,'FontWeight','bold','callback',@ S_Submitbutton_bottom);
                
                %Button-Area
                SortingPanel=uipanel('Parent',SpikeSortingWindow,'Units','pixels','Position',[10 500 590 100],'BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',SortingPanel,'Style', 'text','Position', [15 73 100 20],'HorizontalAlignment','left','String', 'General:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                
                %Start Calculation
                uicontrol('Parent',SortingPanel,'Position',[490 5 80 20],'String','Start','FontSize',11,'FontWeight','bold','callback',@start_sorting);
                
                %Submit all Button
                uicontrol('Parent',SortingPanel,'Position',[490 25 80 20],'String','Submit all','FontSize',11,'FontWeight','bold','callback',@S_Submitbutton_all);
                
                %Apply Expectation Maximation Algorithm
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[270 70 170 20],'HorizontalAlignment','left','String','Expectation Maximation','FontSize',9,'Tag','S2_EM_GM','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG);
                
                %Apply EM k-means Algorithm
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[270 50 150 20],'HorizontalAlignment','left','String','EM k-means','FontSize',9,'Tag','S2_EM_k-means','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG);
                
                
                %Shapes Window Dimension
                uicontrol('Parent',SortingPanel,'Style', 'text','Position', [385 45 80 20],'HorizontalAlignment','left','String', 'Window: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[465 38 50 30],'Tag','Sort_pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','callback',@recalculate);
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[520 38 50 30],'Tag','Sort_posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','callback',@recalculate);
                
                %Manual or automatic Features
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[270 30 150 20],'HorizontalAlignment','left','String','Manual Features','FontSize',9,'Tag','S2_manual','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG);
                
                %FPCA Features
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[270 10 150 20],'HorizontalAlignment','left','String','FPCA Features','FontSize',9,'Tag','S2_FPCA','Value',get(findobj('Tag','S_FPCA'),'value'),'Style','checkbox','BackgroundColor', GUI_Color_BG);
                
                %Feature-Area
                SortingFeaturePanel=uipanel('Parent',SpikeSortingWindow,'Units','pixels','Position',[600 500 590 100],'BackgroundColor', GUI_Color_BG,'Tag','SortingFeaturePanel');
                uicontrol('Parent',SortingFeaturePanel,'Style', 'text','Position', [15 75 100 20],'HorizontalAlignment','left','String', 'Features:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                
                SortingFeaturePanel2=uipanel('Parent',SpikeSortingWindow,'Units','pixels','Position',[600 500 590 100],'BackgroundColor', GUI_Color_BG,'Tag','SortingFeaturePanel2');
                uicontrol('Parent',SortingFeaturePanel2,'Style', 'text','Position', [15 75 100 20],'HorizontalAlignment','left','String', 'Features:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',SortingFeaturePanel2,'Style', 'text','Position', [200 10 200 50],'HorizontalAlignment','left','String', 'FPCA Features','FontSize',18,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                
                %Cluster Number Selection
                uicontrol('Parent',SortingPanel,'Style', 'text','Position', [140 68 70 20],'HorizontalAlignment','left','String', 'Cluster Nr.:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                uicontrol ('Parent',SortingPanel,'Units','Pixels','Position', [220 71 30 20],'Tag','S2_K_Nr','HorizontalAlignment','right','FontSize',9,'Value',1,'String',0,'Style','edit');
                
                %Confidence in %
                uicontrol('Parent',SortingPanel,'Style', 'text','Position', [430 68 105 20],'HorizontalAlignment','left','String', 'Confidence in %','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                uicontrol ('Parent',SortingPanel,'Units','Pixels','Position', [540 71 30 20],'Tag','confidence','HorizontalAlignment','right','FontSize',9,'Value',1,'String',0,'Style','edit');
                
                %Select-Button-Area
                S_SelectPanel = uipanel('Parent',SortingPanel,'Units','pixels','Position',[1 1 250 65],'BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',S_SelectPanel,'Style','text','Position', [13 40 150 20],'HorizontalAlignment','left','String','Select Cluster:','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                
                uicontrol('Parent',S_SelectPanel,'Position', [15 13 80 20],'String','Select','FontSize',11,'FontWeight','bold','callback',@S_Sel);
                uicontrol('Parent',S_SelectPanel,'Position', [155 13 80 20],'String','Show','FontSize',11,'FontWeight','bold','callback',@S_ShowClass);
                
                %Electrode Selection
                uicontrol('Parent',S_SelectPanel,'Style', 'text','Position',[135 38 50 20],'HorizontalAlignment','left','String','Graph: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',S_SelectPanel,'Units','Pixels','Position',[185 10 50 50],'Tag','S_Graph_choice','FontSize',8,'String',[{'Top'} {'Bottom'}],'Value',1,'Style','popupmenu','callback',@recalculate);
                
                
                %Automated Feature Selection
                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [15 50 150 20],'HorizontalAlignment','left','Tag','S_F1','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
                
                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [15 15 150 20],'HorizontalAlignment','left','Tag','S_F2','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
                
                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [190 50 150 20],'HorizontalAlignment','left','Tag','S_F3','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
                
                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [190 15 150 20],'HorizontalAlignment','left','Tag','S_F4','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
                
                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [365 50 150 20],'HorizontalAlignment','left','Tag','S_F5','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
                
                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [365 15 150 20],'HorizontalAlignment','left','Tag','S_F6','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
                
                %Shapes Graph of Cluster 1
                Spikeplot1 = subplot('Position',[0.55 0.47 0.44 0.28],'Parent',SpikeSortingWindow);
                axis([0 2 -100 50]);
                
                %Shapes Graph of Cluster 2
                Spikeplot2 = subplot('Position',[0.55 0.09 0.44 0.28],'Parent',SpikeSortingWindow);
                axis([0 2 -100 50]);
                
                %Scatterplot
                Scatterplot = subplot('Position',[0.05 0.09 0.44 0.66],'Parent',SpikeSortingWindow);
                Window = 1;
                
                set(findobj('Tag','Sort_pretime'),'value',(get(findobj('Tag','S_pretime'),'value')));
                set(findobj('Tag','Sort_posttime'),'value',(get(findobj('Tag','S_posttime'),'value')));
            else
                SpikeSortingWindow = findobj('Tag','SpikeSortingWindow');
            end
            
            if get(findobj('Tag','S2_FPCA'),'value')== 0
                set(findobj('Tag','SortingFeaturePanel'),'Visible','on');
                set(findobj('Tag','SortingFeaturePanel2'),'Visible','off');
            else
                set(findobj('Tag','SortingFeaturePanel'),'Visible','off');
                set(findobj('Tag','SortingFeaturePanel2'),'Visible','on');
            end
            
            set(findobj('Tag','S2_K_Nr'),'String',k);
            set(findobj('Tag','S_K_Nr','parent',t6),'string',k);
            
            %Shapes Graphs
            ST = (-pretime:1000/SaRa:posttime);
            MAX1D = max(Shapes(:,Elektrode,:));
            Max(1) = max(MAX1D);
            MIN1D = min(Shapes(:,Elektrode,:));
            Min(1) = min(MIN1D);
            
            if get(findobj('Tag','S2_FPCA'),'value') == 0
                if SubmitSorting(Elektrode) >= 1
                    SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
                else
                    SPIKES3D_temp = SPIKES3D(1:size(nonzeros(SPIKES3D(:,Elektrode,1)),1),Elektrode,:);
                end
            else
                SPIKES3D_temp = [];
                SPIKES3D_temp(:,1,:) = SPIKES_FPCA;
            end
            
            Shapes_temp = Shapes(:,Elektrode,:);
            
            for i=2:(size(SPIKES3D_temp,3))
                
                MIN1D = min(SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i));
                MAX1D = max(SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i));
                if size(MIN1D) ~= 0
                    Min(i) = min(MIN1D);
                else
                    Min(i)=0;
                end
                if size(MAX1D) ~= 0
                    Max(i) = max(MAX1D);
                else
                    Max(i)=0;
                end
            end
            clear MAX1D MIN1D;
            
            XX1=[];
            XX2=[];
            
            %Plot Spike Clusters
            XX1(:,:) = Shapes_temp(Class == 1,1,:); % 3D Shapes array down to 2D temporary array
            XX2(:,:) = Shapes_temp(Class == 2,1,:);
            Spike_Cluster = (mean(min(XX1,[],2))<= (mean(min(XX2,[],2))));
            
            uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [850 455 70 20],'HorizontalAlignment','left','String','Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [925 455 70 20],'HorizontalAlignment','left','String',size(XX1,1),'FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor', GUI_Color_BG);
            
            uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [850 230 70 20],'HorizontalAlignment','left','String','Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [925 230 70 20],'HorizontalAlignment','left','String',size(XX2,1),'FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor', GUI_Color_BG);
            
            waitbar(1,w,'Done');
            close(w);
            
            figure(SpikeSortingWindow); % sets current figure
            
            Spikeplot1 = subplot('Position',[0.55 0.47 0.44 0.28],'Parent',SpikeSortingWindow,'replace');
            
            Spikeplot1 = plot(ST,XX1,'Parent',Spikeplot1);
            axis(gca,[ST(1) ST(size(ST,2)) Min(1) Max(1)]);
            ylabel({'Voltage / uV'});
            Spkplot1 = 1; % storage of displayed Cluster Number
            
            
            Spikeplot2 = subplot('Position',[0.55 0.09 0.44 0.28],'Parent',SpikeSortingWindow,'replace');
            
            Spikeplot2 = plot(ST,XX2,'Parent',Spikeplot2);
            axis(gca,[ST(1) ST(size(ST,2)) Min(1) Max(1)]);
            xlabel (gca,'time / ms');
            ylabel(gca,{'Voltage / uV'});
            Spkplot2 = 2; % storage of displayed Cluster Number
            
            
            XX1=[];
            XX2=[];
            
            if get(findobj('Tag','S2_FPCA'),'value') == 0
                for i = 1:6     % correct Feature selection
                    set(findobj('Tag',char(F(i))),'value',1);
                    if i <= size(check,2)
                        set(findobj('Tag',char(F(i))),'value',check(i));
                    end
                end
            end
            
            %Scatterplot
            X(:,1:2)=SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1)),1),1,[(check(1)) (check(2))]);
            
            Scatterplot = subplot('Position',[0.05 0.09 0.44 0.66],'Parent',SpikeSortingWindow,'replace');
            
            for i=1:max(Class)
                Scatterplot = scatter(X(Class==i,1),X(Class==i,2),18,'filled');
                hold on
            end
            if get(findobj('Tag','S2_FPCA'),'value') == 0
                axis(gca,[Min(check(1)) Max(check(1)) Min(check(2)) Max(check(2))]); % richtig so, da +1 und -1 durch Max(i) und F(i) sich aufheben
                xlabel (gca,char(units(check(1)-1)));
                ylabel(gca,char(units(check(2)-1)));
            else
                axis(gca,[min(SPIKES3D_temp(:,1)) max(SPIKES3D_temp(:,1)) min(SPIKES3D_temp(:,2)) max(SPIKES3D_temp(:,2))]);
                xlabel (gca,'Scalar');
                ylabel(gca,'Scalar');
            end
            hold off
            toc
        end
        
        function S_Sel(~,~)
            dc_obj = datacursormode(findobj('Tag','SpikeSortingWindow'));
            set(dc_obj,'DisplayStyle','datatip',...
                'SnapToDataVertex','on','Enable','on','UpdateFcn',@LineT);
        end
        
        function [txt] = LineT (~,~)
            dc_obj = datacursormode(findobj('Tag','SpikeSortingWindow'));
            c_inf = getCursorInfo(dc_obj);
            Spike1 = find(SPIKES3D_temp(:,1,check(1))==c_inf(1).Position(1));
            Spike2 = find(SPIKES3D_temp(:,1,check(2))==c_inf(1).Position(2));
            for i=1:size(Spike1,1)
                Spike = find(Spike1(i) == Spike2);
                if Spike > 0
                    break;
                end
            end
            Spike = Spike2(Spike);
            txt = [{num2str(Spike)} {SPIKES3D_temp(Spike,1,check(1))} {SPIKES3D_temp(Spike,1,check(2))}];
            datacursormode off;
        end
        
        function S_ShowClass (~,~)
            
            Elektrode = get(findobj('Tag','S_Elektrodenauswahl'),'value');
            SpikeSortingWindow = findobj('Tag','SpikeSortingWindow');
            XX=[];
            if size(Class,1)==0
                Class(1:size(nonzeros(SPIKES(:,Elektrode)),1),1)= zeros;
            end
            XX(:,:)=Shapes((Class==Class(Spike)),Elektrode,:);
            if get(findobj('Tag','S_Graph_choice'),'value') == 1
                Spikeplot1 = subplot('Position',[0.55 0.47 0.44 0.28]);
                uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [925 455 70 20],'HorizontalAlignment','left','String',size(XX,1),'FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor', GUI_Color_BG);
                Spkplot1 = Class(Spike); % storage of displayed Cluster Number
            else
                Spikeplot2 = subplot('Position',[0.55 0.09 0.44 0.28]);
                uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [925 230 70 20],'HorizontalAlignment','left','String',size(XX,1),'FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor', GUI_Color_BG);
                Spkplot2 = Class(Spike); % storage of displayed Cluster Number
                xlabel ('time / ms');
            end
            Spikeplot = plot(ST,XX);
            axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
            ylabel({'Voltage / uV'});
            
            if get(findobj('Tag','S_Graph_choice'),'value') == 2
                xlabel ('time / ms');
            end
            
            XX=[];
            
        end
        
        function S_Submitbutton_top(~,~) % detector function for top Submit button
            
            all = 0;
            spikes = Spkplot1;
            S_Submit;
        end
        
        function S_Submitbutton_bottom(~,~)  % detector function for bottom Submit button
            
            all = 0;
            spikes = Spkplot2;
            S_Submit;
        end
        
        function S_Submitbutton_all(~,~)
            
            all = 1;
            S_Submit;
        end
        
        function S_Submit(~,~) % extra Submit function for Sorting to reduce complexity
            
            set(findobj('Tag','S_K_Nr','parent',t6),'String',0);
            set(findobj('Tag','S2_K_Nr'),'String',0);
            n = Elektrode;
            submit_data = 1;
            
            
            if SubmitSorting(Elektrode) >= 1 && size(SPIKES3D_discard,1) >= 1 % overwrite SPIKES3D_temp to initialize Submit function correctly
                SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
            else
                SPIKES3D_temp = SPIKES3D(1:size(nonzeros(SPIKES3D(:,Elektrode,1)),1),Elektrode,:);
            end
            
            if SubmitSorting(Elektrode) == 0
                NR_SPIKES_temp = 0;
            else
                NR_SPIKES_temp = NR_SPIKES_Sorted(1,n);
            end
            
            NR_SPIKES_Sorted(1,1:size(SPIKES,2)) = NR_SPIKES;
            NR_BURSTS_Sorted(1,1:size(SPIKES,2)) = BURSTS.BRn;
            NR_SPIKES_Sorted(1,n)=  NR_SPIKES_temp;
            clear  NR_SPIKES_temp;
            
            if all
                if SubmitSorting(Elektrode) == 0
                    
                    if size(SPIKES_Class,1)~= 0 && size(SPIKES_Class,2)>= n
                        SPIKES_Class = []; % reset the data Array if sorted Elektrode is sorted again
                    end
                    
                    SPIKES_Class(:,n,1) = SPIKES(:,n);
                    SPIKES_Class(1:size(Class,1),n,2) = Class(:);
                    SPIKES_NEW = SPIKES(:,n);
                    NR_SPIKES(n) = size(nonzeros(SPIKES(:,n)),1);
                    
                    SPIKES3D_discard = [];
                    SPIKES3D_OLD = [];
                    SPIKES_OLD = [];
                    
                    M_old(:,1) =RAW.M(:,Elektrode); % clear original Signal of the Electrode at the first Submission
                    RAW.M(:,Elektrode) = zeros;
                    
                else
                    SPIKES3D_NEW(:,n,:) = SPIKES3D_temp(:,1,:);
                    SPIKES_NEW(:,1) = SPIKES3D_temp(:,1,1);
                    SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = zeros;
                    SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = zeros;
                    SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = SPIKES3D_NEW(:,n,:);
                    SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = SPIKES_NEW(:,1);
                    
                    X_temp(:,:) = SPIKES3D(1:size(nonzeros(SPIKES3D(:,n,1)),1),n,:);
                    SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n)= sortrows(SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n),1);
                    Size = size(SPIKES_Class,1);
                    SPIKES_Class(Size+1:(Size+size(SPIKES3D_NEW(:,n,1),1)),n,1) = SPIKES3D_NEW(:,n,1);
                    SPIKES_Class(Size+1:(Size+size(SPIKES3D_NEW(:,n,1),1)),n,2) =SubmitSorting(Elektrode)+Class(1:size(SPIKES3D_NEW(:,n,1),1));
                    clear Size;
                    
                end
                
                for i= 1:max(Class)
                    NR_SPIKES_Sorted(SubmitSorting(Elektrode)+i,n) = size(SPIKES_NEW(Class==i),1);
                    NR_BURSTS_Sorted(SubmitSorting(Elektrode)+i,n) = 0;
                end
                
                SubmitSorting(Elektrode) = max(Class)+SubmitSorting(Elektrode);
                
                Class = [];
                Class(1:size(nonzeros(SPIKES(:,n)),1),1) = 1;
                
            else
                if SubmitSorting(Elektrode) == 0
                    SPIKES3D_discard = [];
                    SPIKES3D_OLD = [];
                    SPIKES_OLD = [];
                    SPIKES3D_OLD = SPIKES3D;
                    SPIKES_OLD = SPIKES3D(:,:,1);
                    SPIKES3D_NEW(:,n,:) = SPIKES3D_temp((Class == spikes),1,:);
                    SPIKES_NEW(:,1) = SPIKES3D_temp((Class == spikes),1,1);
                    SPIKES3D_discard(1:size(SPIKES3D_temp(Class ~= spikes),1),1,:) = SPIKES3D_temp((Class ~= spikes),1,:);
                    SPIKES3D = [];
                    SPIKES = [];
                    
                    if size(SPIKES_Class,1)~= 0 && size(SPIKES_Class,2)>= n
                        SPIKES_Class(:,n,:)= zeros; % reset the data Array if sorted Elektrode is sorted again
                    end
                    
                    s = size(SPIKES3D_OLD,1);
                    
                    if s > size(SPIKES3D_OLD(:,n,:),1)
                        SPIKES3D = SPIKES3D_OLD(1:s,:,:);
                        SPIKES = SPIKES_OLD(1:s,:);
                    else
                        for i=1:size(SPIKES3D_OLD,2)
                            I(i) = size(nonzeros(SPIKES3D_OLD(:,i,1)),1);
                            if i == n
                                I(i) = 0;
                            end
                        end
                        I(1) = max(I);
                        if size(SPIKES3D_NEW,1)> I(1)
                            SPIKES3D = SPIKES3D_OLD(1:size(SPIKES3D_NEW,1),:,:);
                            SPIKES = SPIKES_OLD(1:size(SPIKES_NEW,1),:);
                        else
                            SPIKES3D = SPIKES3D_OLD(1:I(1),:,:);
                            SPIKES = SPIKES_OLD(1:I(1),:);
                        end
                    end
                    
                    SPIKES3D(:,n,:) = zeros;
                    SPIKES3D(1:size(SPIKES3D_NEW,1),n,:) = SPIKES3D_NEW(:,n,:);
                    SPIKES_NEW = SPIKES3D_NEW(:,n,1);
                    SPIKES_Class(1:size(SPIKES3D_NEW(:,n,1),1),n,1) = SPIKES3D_NEW(:,n,1);
                    SPIKES_Class(1:size(SPIKES3D_NEW(:,n,1),1),n,2) = SubmitSorting(Elektrode)+1;
                    SPIKES3D_NEW = [];
                    SPIKES3D_OLD = [];
                    
                    SPIKES(:,n) = zeros;
                    SPIKES(1:size(SPIKES_NEW,1),n) = SPIKES_NEW(:,1);
                    NR_SPIKES(n) = size(nonzeros(SPIKES(:,n)),1);
                    Class = [];
                    Class(1:size(nonzeros(SPIKES(:,n)),1),1) = 1;
                    
                    M_old(:,1) =RAW.M(:,Elektrode); % clear original Signal of the Electrode at the first Submission
                    RAW.M(:,Elektrode) = zeros;
                    
                else
                    
                    SPIKES3D_discard = [];
                    SPIKES3D_discard(1:size(SPIKES3D_temp(Class ~= spikes),1),1,:) = SPIKES3D_temp((Class ~= spikes),1,:);
                    SPIKES3D_NEW(:,n,:) = SPIKES3D_temp((Class == spikes),1,:);
                    SPIKES_NEW(:,1) = SPIKES3D_temp((Class == spikes),1,1);
                    SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = zeros;
                    SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = zeros;
                    SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = SPIKES3D_NEW(:,n,:);
                    SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = SPIKES_NEW(:,1);
                    
                    X_temp(:,:) = SPIKES3D(1:size(nonzeros(SPIKES3D(:,n,1)),1),n,:);
                    X_temp = sortrows(X_temp,1);
                    SPIKES3D(1:size(nonzeros(SPIKES3D(:,n,1)),1),n,:)= X_temp;
                    SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n)= sortrows(SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n),1);
                    Size = size(SPIKES_Class,1);
                    SPIKES_Class(Size+1:(Size+size(SPIKES3D_NEW(:,n,1),1)),n,1) = SPIKES3D_NEW(:,n,1);
                    SPIKES_Class(Size+1:(Size+size(SPIKES3D_NEW(:,n,1),1)),n,2) = SubmitSorting(Elektrode)+1;
                    clear Size;
                    
                end
                
                NR_SPIKES(n) = size(nonzeros(SPIKES(:,n)),1);
                NR_SPIKES_Sorted(SubmitSorting(Elektrode)+1,n) = size(SPIKES_NEW(:,1),1);
                NR_BURSTS_Sorted(SubmitSorting(Elektrode)+1,n) = 0;
                SubmitSorting(Elektrode) = SubmitSorting(Elektrode) + 1; % Parameter to show how many Clusters have already been submitted
                
            end
            
            set(findobj('Tag','radio_allinone'),'value',0)
            set(findobj('Tag','radio_fouralltime'),'value',1)
            Viewselect = 0;
            n = Elektrode;
            pretime = 0.5;
            posttime = 0.5;
            SPI =SPIKES_NEW*SaRa;
            SPI1=nonzeros(SPI(:,1));
            
            for i=1:size(SPI1,1)
                if ((SPI1(i)+1+floor(SaRa*posttime/1000))<= size(RAW.M,1))&& ((SPI1(i)+1-ceil(SaRa*pretime/1000)) >= 0) % test if
                    RAW.M(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n) = M_old(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),1); % Shapes variabler Laenge
                end
            end
            
            BURSTS.BEG(:,n) = zeros;
            BURSTS.BRn(n) = 0;
            
            clear SPIKES3D_NEW SPIKES3D_OLD s spikes SPIKES_NEW SPIKES_OLD X_temp;
            SPIKES3D_temp = [];
            redrawdecide;
            
            if all
                SpikeSortingWindow = findobj('Tag','SpikeSortingWindow');
                close(SpikeSortingWindow);
            else
                start_sorting;
            end
        end
    end

    function DB_SCAN(~,~) % Density Based Cluster Algorithmus (Written by Michal Daszykowski)
        
        tic
        k=get(findobj(gcf,'Tag','K_Quantity'),'String');
        k=str2double(k);
        
        if (strcmp(get(findobj(gcf,'Tag','Max_Dist'),'String'),'')== 1) || first2 == false
            k_old=-1;
            first2 = true;
        end
        
        if (get(findobj(gcf,'Tag','Variables'),'value')==1) || (get(findobj(gcf,'Tag','Histogram'),'value') == (get(findobj(gcf,'Tag','Variables'),'value')))
            X(:,1:2)=SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,[Variable1+1 Variable2+1]);
        else
            if counter < 9 % if more than one feature is activated
                counter = 1;
                for i=1:size(check,2)
                    if check(i)~=1
                        X(:,counter) = SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i));
                        counter = counter +1;
                    end
                end
                counter = 0;
            else
                X(:,1:2)=SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,[Variable1+1 Variable2+1]);
            end
        end
        
        XX_N(1:size(nonzeros(SPIKES(:,Elektrode)),1),1:size(X,2))=zeros;
        
        for i=1:size(X,2)
            XX_N(:,i) = (X(:,i)-min(X(:,i)))/(max(X(:,i))-min(X(:,i)));
        end
        
        X(:,1:2)=SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,[Variable1+1 Variable2+1]); % necessary to ensure consistency of scatterplot
        
        if (strcmp(get(findobj(gcf,'Tag','Max_Dist'),'String'),'')== 1) || (size(get(findobj(gcf,'Tag','Max_Dist'),'String'),2)==0) || (k~=k_old)
            [Eps]=epsilon(XX_N,k);
            set(findobj(gcf,'Tag','Max_Dist'),'String',Eps);
            k_old=k;
        else
            Eps=get(findobj(gcf,'Tag','Max_Dist'),'String');
            Eps = str2double(Eps);
        end
        
        [m,~]=size(XX_N);
        XX_N=[(1:m)' XX_N];
        [m,n]=size(XX_N);
        type=zeros(1,m);
        no=1;
        touched=zeros(m,1);
        Class(1:m)=zeros;
        
        for i=1:m
            
            if touched(i)==0;
                ob=XX_N(i,:);
                D=Dist(ob(2:n),XX_N(:,2:n));
                ind=find(D<=Eps);
                
                if length(ind)>1 && length(ind)<k+1
                    type(i)=0;
                    Class(i)=0;
                    
                end
                if length(ind)==1
                    type(i)=-1;
                    Class(i)=-1;
                    touched(i)=1;
                end
                
                if length(ind)>=k+1;
                    type(i)=1;
                    Class(ind)=ones(length(ind),1)*max(no);
                    
                    while ~isempty(ind)
                        ob=XX_N(ind(1),:);
                        touched(ind(1))=1;
                        ind(1)=[];
                        D=Dist(ob(2:n),XX_N(:,2:n));
                        i1=find(D<=Eps);
                        
                        if length(i1)>1
                            Class(i1)=no;
                            
                            if length(i1)>=k+1;
                                type(ob(1))=1;
                            else
                                type(ob(1))=0;
                            end
                            
                            for ii=1:length(i1)
                                if touched(i1(ii))==0
                                    touched(i1(ii))=1;
                                    ind=[ind i1(ii)];
                                    Class(i1(ii))=no;
                                end
                            end
                        end
                    end
                    no=no+1;
                end
            end
        end
        
        i1=find(Class==0);
        Class(i1)=-1;
        type(i1)=-1;
        
        % Show result in scatterplot
        scatterplot = subplot('Position',[0.545 0.06 0.445 0.41]);
        for i=-1:no-1
            scatter(X(Class==i,1),X(Class==i,2),18,'filled');
            hold on
        end
        axis([Min(Variable1+1) Max(Variable1+1) Min(Variable2+1) Max(Variable2+1)]);
        xlabel (char(units(Variable1)));
        ylabel(char(units(Variable2)));
        hold off
        toc
    end

    function [Eps]=epsilon(XX_N,k) %calculate minimum distance between 2 seperate classes
        
        [m,n]=size(XX_N);
        Eps=((prod(max(XX_N)-min(XX_N))*k*gamma(.5*n+1))/(m*sqrt(pi.^n))).^(1/n);
    end

    function [D]=Dist(i,XX_N) % calclulate euclidean distance
        
        [m,n]=size(XX_N);
        
        D=sqrt(sum((((ones(m,1)*i)-XX_N).^2),2));
        D=D';
        
        if n==1
            D=abs((ones(m,1)*i-XX_N))';
        end
    end


%functions - Tab Export
%----------------------------------------------------------------------

% --- Export xls-Button (CN,SDB,MC)-------------------------------------------
    function safexlsButtonCallback(source,event)  %#ok<INUSD>
        
        %title = [full_path(1:(length(full_path)-4)),'.xls'];  % Name and path for the xls-Export-file
        
        % mean & std amplitude for each electrode
        if ~isempty(AMPLITUDES)
            for n=1:size(SPIKES,2)
                if size(nonzeros(AMPLITUDES(:,n)))~=0
                    AMPLITUDE_mean(n)=mean(abs(nonzeros(AMPLITUDES(:,n))));
                    AMPLITUDE_std(n)=std(abs(nonzeros(AMPLITUDES(:,n))));
                else
                    AMPLITUDE_mean(n)=0;
                    AMPLITUDE_std(n)=0;
                end
            end
        end
        
        
        % number of active electrodes
        %NumOfActEl=length(nonzeros(SPIKES(1,:)>0));
        
        
        %Export
        if (get(findobj(gcf,'Tag','CELL_exportAllCheckbox'),'value'))
            i = 16;
        else i = 12;
        end
        
        [~,filenameWoExt,~] = fileparts(file);
        cd(myPath)
        [filename, pathname] = uiputfile ('*.xls','save as...',[myPath filesep filenameWoExt]);
        if filename==0, return,end
        tic
        h = waitbar(0,'please wait, save data...');
        waitbar(0.2/i)
        
        % automatically save _TS.mat files as they are needed for automatic analysis
        saveSpikes([myPath filesep filenameWoExt '_TS.mat'],SPIKEZ)
        
        excle_cells=cell(1,1);
        
        
        excle_cells{2,1}=full_path;
        %xlswrite([pathname filename], {full_path}, 'Tabelle1','A2');
        if ~isempty(fileinfo)
            if iscell(fileinfo); excle_cells{3,1}=fileinfo{1}; end
        end
        %xlswrite([pathname filename], fileinfo{1}, 'Tabelle1','A3');
        
        waitbar(0.5/i);
        % parameter for all chips:
        excle_cells{6,1}='Duration of recording [s]';
        excle_cells{6,4}=rec_dur;
        excle_cells{7,1}='Number of act. el.';
        excle_cells{7,4}=SPIKEZ.aeFRn;
        
        % spikes:
        excle_cells{8,1}='mean spikerate/ 1/min:';
        excle_cells{8,4}=SPIKEZ.aeFRmean;
        excle_cells{9,1}='std spikerate/ 1/min:';
        excle_cells{9,4}=SPIKEZ.aeFRstd;
        excle_cells{10,1}='Sum of all spikes:';
        excle_cells{10,4}=SPIKEZ.aeN;
        
        % bursts:
        % BR:
        excle_cells{11,1}='mean burstrate/ 1/min:';
        excle_cells{11,4}=BURSTS.aeBRmean;
        excle_cells{12,1}='std burstrate/ 1/min:';
        excle_cells{12,4}=BURSTS.aeBRstd;
        excle_cells{13,1}='number of burst electrodes:';
        excle_cells{13,4}=BURSTS.aeBRn;
        
        % BD:
        excle_cells{14,1}='mean burst duration/ s:';
        excle_cells{14,4}=BURSTS.aeBDmean;
        excle_cells{15,1}='std burst duration/ s:';
        excle_cells{15,4}=BURSTS.aeBDstd;
        excle_cells{16,1}='N_BD:';
        excle_cells{16,4}=BURSTS.aeBDn;
        
        % SIB:
        excle_cells{17,1}='mean spikes/burst:';
        excle_cells{17,4}=BURSTS.aeSIBmean;
        excle_cells{18,1}='std spikes/burst:';
        excle_cells{18,4}=BURSTS.aeSIBstd;
        excle_cells{19,1}='N_SIB:';
        excle_cells{19,4}=BURSTS.aeSIBn;
        
        
        % IBI:
        excle_cells{20,1}='mean interburstinterval:';
        excle_cells{20,4}=BURSTS.aeIBImean;
        excle_cells{21,1}='std interburstinterval:';
        excle_cells{21,4}=BURSTS.aeIBIstd;
        excle_cells{22,1}='N_IBI:';
        excle_cells{22,4}=BURSTS.aeIBIn;
        
        
        % SBE:
        excle_cells{23,1}='number of SBE:';
        excle_cells{23,4}=Nr_SI_EVENTS;
        
        
        % SNR:
        excle_cells{24,1}='mean SNR /dB:';
        excle_cells{24,4}=Mean_SNR_dB;
        
        % AMP:
        excle_cells{25,1}='mean AMP /uV:';
        excle_cells{25,4}=SPIKEZ.aeAMPmean;
        excle_cells{26,1}='std AMP /uV:';
        excle_cells{26,4}=SPIKEZ.aeAMPstd;
        excle_cells{27,1}='N_AMP:';
        excle_cells{27,4}=SPIKEZ.aeAMPn;
        
        
        % Parameter per electrode:
        excle_cells{29,1} = 'Electrode';
        excle_cells{30,1} = 'Threshold [uV]';
        excle_cells{31,1} = 'Number of Spikes';
        excle_cells{32,1} = 'Number of Bursts';
        excle_cells{33,1} = 'Burstrate [burst per second]';
        excle_cells{34,1} = 'Mean spikes per burst';
        excle_cells{35,1} = 'STD spikes per burst';
        excle_cells{36,1} = 'Mean burst-duration [s]';
        excle_cells{37,1} = 'STD burst-duration';
        excle_cells{38,1} = 'Mean IBI [s]';
        excle_cells{39,1} = 'STD IBI';
        excle_cells{40,1} = 'Signal-to-Noise Ratio';
        excle_cells{41,1} = 'Signal-to-Noise Ratio [dB]';
        excle_cells{42,1} = 'Mean abs(Amplitude) /uV';
        excle_cells{43,1} = 'STD abs(Amplitude) /uV';
        excle_cells{44,1} = '';
        excle_cells{45,1} = '';
        
        
        waitbar(1/i);
        
        if length(SNR)==1
            if isempty(SNR) || isnan(SNR)
                SNR=zeros(1,size(SPIKEZ.neg.THRESHOLDS.Th,2));
            end
            if isempty(SNR_dB) || isnan(SNR_dB)
                SNR_dB=zeros(1,size(SPIKEZ.neg.THRESHOLDS.Th,2));
            end
        end
        
        % in case old version of TS.mat is used, no Thresholds are
        % available:
        if ~isfield(SPIKEZ.neg,'THRESHOLDS')
            SPIKEZ.neg.THRESHOLDS.Th = zeros(1,size(SPIKEZ.TS,2));
        end
        
        
        % Burstdetection-Info:
        excle_cells{5,9}='Burstdetection:';
        excle_cells{5,10}=BURSTS.name;
        excle_cells{6,9}='ISI_max /s:';
        excle_cells{6,10}=BURSTS.PREF.ISI_max;
        excle_cells{7,9}='IBI_min /s:';
        excle_cells{7,10}=BURSTS.PREF.IBI_min;
        excle_cells{8,9}='SIB_min /s:';
        excle_cells{8,10}=BURSTS.PREF.SIB_min;
        
        
        % Synchronization Measure:
        STRUCT.S=SpikeContrast(SPIKEZ.TS,rec_dur);
        SYNC.SC=STRUCT.S; % spike-contrast is calculated
        excle_cells{10,9}='Synchrony:';
        excle_cells{11,9}='Spike-Contrast:';
        if isfield(SYNC,'SC'); excle_cells{11,10}=SYNC.SC; end
        excle_cells{12,9}='CC (Selinger):';
        if isfield(SYNC,'CCselinger'); excle_cells{12,10}=SYNC.CCselinger; end
        excle_cells{13,9}='CC:';
        if isfield(SYNC,'CC'); excle_cells{13,10}=SYNC.CC; end
        excle_cells{14,9}='MI1:';
        if isfield(SYNC,'MI1'); excle_cells{14,10}=SYNC.MI1; end
        excle_cells{15,9}='MI2:';
        if isfield(SYNC,'MI2'); excle_cells{15,10}=SYNC.MI2; end
        excle_cells{16,9}='PS:';
        if isfield(SYNC,'PS'); excle_cells{16,10}=SYNC.PS; end
        
        
        waitbar(3/i);
        %xlswrite([pathname filename], {'to...'}, 'Tabelle1','E8');
        waitbar(4/i);
        %xlswrite([pathname filename], dev95_limits(2), 'Tabelle1','F8');
        waitbar(5/i);
        
        
        
        
        waitbar(6/i);
        if SPIKEZ.PREF.nr_channel >1
            for n=1:numel(EL_NAMES)
                excle_cells{29,3+n}=EL_NAMES{n};
            end
            DATAarray = cat(1,SPIKEZ.neg.THRESHOLDS.Th(1,:),NR_SPIKES,BURSTS.BRn,BURSTS.BRn./rec_dur,BURSTS.SIBmean,BURSTS.SIBstd,BURSTS.BDmean,BURSTS.BDstd,BURSTS.IBImean,BURSTS.IBIstd,SNR,SNR_dB,SPIKEZ.AMPmean,SPIKEZ.AMPstd);
            for n=1:numel(DATAarray(:,1))
                for m=1:numel(DATAarray(1,:))
                    excle_cells{29+n,3+m}=DATAarray(n,m);
                end
            end
        end
        
        
        waitbar(7/i);
        excle_cells{50,1}='SBE Timestamps /s:';
        for n=1:numel(SI_EVENTS)
            excle_cells{49+n,4}=SI_EVENTS(n);
        end
        
        waitbar(10/i);
        
        if i==16
            %             d1=size(BURSTS.BEG,1);
            %             counter=38+d1;
            %             rowUEBER2 = num2str(counter);
            %             rowUEBER2_1 = num2str(counter+1);
            
            %             xlswrite([pathname filename], {'Bursts (Timestamps)'}, 'Tabelle1','A36');
            %             xlswrite([pathname filename], (EL_NAMES'), 'Tabelle1','D36');
            %             xlswrite([pathname filename], BURSTS.BEG, 'Tabelle1','D37');
            waitbar(12/i);
            
            % Spikes per Burst
            %             AfterBurst_A=strcat('A',rowUEBER2);
            %             AfterBurst_D=strcat('D',rowUEBER2);
            %             AfterBurst_D_1=strcat('D',rowUEBER2_1);
            %             xlswrite([pathname filename], {'Number of spikes per burst'}, 'Tabelle1',AfterBurst_A); % MC
            %             xlswrite([pathname filename], (EL_NAMES'), 'Tabelle1',AfterBurst_D); % MC
            %             xlswrite([pathname filename], BURSTS.SIB, 'Tabelle1',AfterBurst_D_1); % MC
            
            
            
            % Amplitude of each Spike
            % Spikes timestamps
            excle_cells3=cell(1,1);
            excle_cells2=cell(1,1);
            excle_cells3{1,1}='Amplitude of each Spike';
            excle_cells2{1,1}='Spikes (Timestamps)';
            for n=1:numel(EL_NAMES)
                excle_cells3{1,3+n}=EL_NAMES{n};
                excle_cells2{1,3+n}=EL_NAMES{n};
            end
            for n=1:numel(AMPLITUDES(:,1))
                for m=1:numel(AMPLITUDES(1,:))
                    excle_cells3{1+n,3+m}=AMPLITUDES(n,m);
                    excle_cells2{1+n,3+m}=SPIKES(n,m);
                end
            end
            if(ismac || isunix) % OS = Linux, Mac
                xlwrite([pathname filename], excle_cells3, 'Tabelle3','A1');
                xlwrite([pathname filename], excle_cells2, 'Tabelle2','A1');
            else % OS = Win
                xlswrite([pathname filename], excle_cells3, 'Tabelle3','A1');
                xlswrite([pathname filename], excle_cells2, 'Tabelle2','A1');
            end
            
            
            
            
            waitbar(14/i);
        end
        
        excle_cells{1,1}='Summary of analysis';
        if(ismac || isunix) % OS = Linux, Mac
            xlwrite([pathname filename], excle_cells', 'Tabelle1','A1');
        else % OS = Win
            xlswrite([pathname filename], excle_cells', 'Tabelle1','A1');
        end
        
        
        waitbar(i/i);
        close(h);
        
        if (get(findobj(gcf,'Tag','CELL_showExportCheckbox'),'value'))
            winopen([pathname filename]);
        end
        
        %cd(path_Neuro)
    end

% --- Export Time-Amplitude txt-file (CN)-------------------------------
    function ExportTimeAmpCallback(source,event)
        Time_Amp = export_Time_amplitude(EL_NUMS,RAW.M,SPIKES,SaRa);
        
        title = [full_path(1:(length(full_path)-4)),'-TimeAmp.txt'];  % Name and path for the Export-file
        [filename, pathname] = uiputfile ('*.txt','save as...',title);
        if filename==0, return,end
        path_file=fullfile(pathname,filename);
        fid = fopen(path_file, 'wt');
        fprintf(fid,'%2d \t',Time_Amp(1,:));
        fprintf(fid,'\n');
        
        for ii = 2:size(Time_Amp,1)
            fprintf(fid,'%5.4f \t',Time_Amp(ii,:));
            fprintf(fid,'\n');
        end
        fclose(fid);
        clear Time_Amp;
        %cd(path_Neuro)
    end

% --- Export Time-shape txt-file (CN)-------------------------------
    function ExportTimeShapeCallback(source,event)
        Time_Shape = export_Time_Shape(EL_NUMS,RAW.M,SPIKES,SaRa);
        
        %cd(path)
        title = [full_path(1:(length(full_path)-4)),'-TimeShape.txt'];  % Name and path for the Export-file
        [filename, pathname] = uiputfile ('*.txt','save as...',title);
        if filename==0, return,end
        path_file=fullfile(pathname,filename);
        fid = fopen(path_file, 'wt');
        fprintf(fid,'%2d \t',Time_Shape(1,:));
        fprintf(fid,'\n');
        
        for ii = 2:size(Time_Shape,1)
            fprintf(fid,'%5.4f \t',Time_Shape(ii,:));
            fprintf(fid,'\n');
        end
        fclose(fid);
        clear Time_Shape;
        %cd(path_Neuro)
    end

% --- Save Spikes as mat-file (MC) -----------------------------
    function SaveSpikesCallback(~,~)
        [~,filename,~] = fileparts(file);
        FILENAME=[myPath filesep filename '_TS.mat'];
        [filename, filepath] = uiputfile ('*.mat','save as...',FILENAME);
        if filename==0, return,end
        
        
        saveSpikes([filepath filesep filename],SPIKEZ);
        
    end




%Funktionen - Tab About
%----------------------------------------------------------------------
% --- HelpLicense Button - License (CN)-----
    function HelpLicenseFunction(source,event) %#ok
        License = figure('color',[1 1 1],'Position',[150 75 700 600],'NumberTitle','off','toolbar','none','Name','License');
        uicontrol('Parent', License,'style','text','units','Pixels','position', [5 5 690 590],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Disclaimer');
        uicontrol('Parent',License,'style','text','units','Pixels','position', [5 5 690 570],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','This programm is designed to process signals recorded with microelectrode arrays. Neural and Cardiac signals can be processed.');
        uicontrol('Parent',License,'style','text','units','Pixels','position', [5 5 690 530],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','Copyright (C) 2009-2012  Christoph Nick, Michael Goldhammer, Robert Bestel, Andreas Daus, Christiane Thielemann.');
        uicontrol('Parent',License,'style','text','units','Pixels','position', [5 5 690 490],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.');
        uicontrol('Parent',License,'style','text','units','Pixels','position', [5 5 690 420],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.');
        uicontrol('Parent',License,'style','text','units','Pixels','position', [5 5 690 350],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.');
    end

%functions - Tab Tools
%----------------------------------------------------------------------
% --- Automated Analysis
    function AutomatedAnalysis_Callback(~,~)
        close(mainWindow)
        GUI_AutomatedAnalysis
    end









end
