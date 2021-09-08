% ++++++++++++++++++++++++++++++++++
% ++++++++++ Cardio ++++++++++++++++
% ++++++++++++++++++++++++++++++++++


function dr_cell %#ok<FNDEF>

warning off all;

global filedetails nr_channel nr_channel_old M T M_OR SaRa NR_SPIKES EL_NAMES THRESHOLDS SPIKES SPIKES3D SPIKES_OR SPIKES_IN_BURSTS SI_EVENTS waitbaradd waitbar_counter h_wait ACTIVITY END BEG EL_NUMS PREF rec_dur rec_dur_string ACTIVE_EL %BURSTS
global allorone threshrmsdecide ELEC_CHECK CALC COL_SDT COL_RMS SNR SNR_dB Nr_SI_EVENTS Mean_SIB Mean_SNR_dB EL_Auswahl ELEKTRODEN BURSTDUR meanburstduration MBDae STDburst STDburstae IBImean IBIstd aeIBImean aeIBIstd cellselect signal_draw signalCorr_draw timePr kappa_mean
global MinRise MaxRise MinFall MaxFall MinDuration MaxDuration Meanrise stdMeanRise Meanfall stdMeanFall MeanDuration stdMeanDuration ORDER BURSTTIME numberfiles file filearray
global SubMEA SubMEA_vier
global ST_EL_Auswahl ST_ELEKTRODEN spiketrainWindow INV_ELEKTRODEN EL_invert_Auswahl varT varTdata varoffset Shapesvar
global is_open CORRBIN TESTcorr CurElec S
global Shapes data ti Coeff TEST MX y
global SPIKES3D_Norm Min Max check Elektrode SPIKES_Discrete Class cln SPIKES3D_discard Sorting Window SubmitSorting SubmitRefinement M_old SPIKES_Class NR_SPIKES_Sorted  NR_BURSTS_Sorted SPIKES_FPCA;
global Time_Amp Time_Shape PlotHandler backup_M CLEL Invert_M
global MaxValNAllEl MinValNAllEl BeatRateMeanAllEl BeatRateStdAllEl BeatRateMedianAllEl ISIMeanAllEl  ISIStdAllEl ISIMedianAllEl
global MaxValMeanAllEl MaxValStdAllEl MaxValMedianAllEl MinValMeanAllEl MinValStdAllEl MinValMedianAllEl MeanDistance MeanTime MeanVelocity
global StdDistance StdTime StdVelocity MedianDistance MedianTime MedianVelocity
global path
global RAW SPIKEZ Date Time
global HDrawdata HDmode HDspikedata HDrowdata NCh NETWORKBURSTS AMPLITUDES THRESHOLDS_pos el_no  
global BURSTS
% GUI Color
global GUI_Color_BG GUI_Color_Buttons % Vectors containing R G B

% --- Initializing ---
full_path       = 0;    % File path
fileinfo        = 0;    % File info
%M               = 0;    % Data
M_OR            = 0;    % Copy of the data
T               = 0;    % Timestamps
EL_NAMES        = 0;    % Electrode names
EL_NUMS         = 0;
backup_M        = [];
HDrawdata = false; % true: 4069 El Data ("HDMEAs"), false: 60 El Data ("MEAs")
HDmode = false;

% --- set GUI Color -----
GUI_Color_BG = [1 1 1]; % old: [0.89 0.89 0.99]
GUI_Color_Buttons = [1 1 1];
set(0,'DefaultUicontrolBackgroundColor',GUI_Color_Buttons);
set(0,'DefaultFigureColor',GUI_Color_BG);

PREF            = zeros(1,16);    % Preferences for analysis [1:facotr RMS for Threshold; 2:Beginning of threshold calculation; 3: Endtime to (2);
% 4: Refractory time between 2 Spikes; 5: Min. number Spikes per Burst; 6: time between 1st and 2nd Spike in a Burst; 7: time between other Spikes;
% 8: Refractory time between Bursts; 9: Elektrode for ZeroOut Calculation; 10: Threshold for ZeroOut; 11: time to set to zero after stimulation interference,
% 12: Highpassfilter, 13: Lowpassfilter, 14: ZeroOut, 15: factor for STD to discover noise, 16: Windowsize for Basenoise]
PREF(PREF==0)=NaN; % set all values to NaN values in case threshold file is loaded and contains missing (=unknown) values (MC)

SPIKES3D        = [];   % 3D-Matrix: Zeile: Betreffender Spike; Spalte:Betreffende Elektrode;
% Blatt 1: Timestamp des Spikes; Blatt 2: Negative Amplitude des Spikes;
% Blatt 3: Positive Amplitude des Spikes; Blatt 4: Ergebnis des NEO des Spikes;
% Blatt 5: Negative Signalenergie des Spikes; % Blatt 6: Positive Signalenergie des Spikes
% Blatt 7: Spikedauer; Blatt 8: ï¿½ffnungswinkel nach links;
% Blatt 9: ï¿½ffnungswinkel nach rechts; Blatt 10: varAmplitude;
% Blatt 11: varSpikedauer; Blatt 12: varï¿½ffnungswinkel nach links; Blatt 13: varï¿½ffnungswinkel nach rechts
Viewselect      = true;
waitbar_counter = 0;
THRESHOLDS      = 0;    % Thresholds of all electrodes
spikedata       = false;    % 1, if Spikedaten exists
thresholddata   = false;    % 1, if thresholds were calculated
SPIKES          = 0;    % Spike-Timestamps
BURSTS.BEG      = [];    % Burst-Timestamps
% BURSTS          = [];    % Burst-Timestamps
SI_EVENTS       = 0;    % SBE-Timestamps
NR_SPIKES       = 0;    % number of Spikes on each electrode
NR_BURSTS       = 0;    % number of bursts on each electrode.
SIB             = 0;    % Average number Spikes/Burst on each electrode
auto            = true;    % Automatic Threshold calculation (true) oder manuell (false)
cellselect      = 1;    % 1  or 2 if Neurons, 0 if MCC
Mean_SIB        = 0;    % Average Spikes per Burst over all Electrodes
Mean_SNR_dB     = 0;    % Average SNR in dB
MBDae           = 0;    % Average Burstduration over all electrodes
STDburstae      = 0;    % STD Burstduration over all electrodes
aeIBImean       = 0;    % Average Interburstinterval over all electrodes
aeIBIstd        = 0;    % STD Interburstinterval over all electrodes
spiketraincheck = false;    % 1, if a spiketrain was opend
rawcheck        = false;    % 1, if raw-data was opend
first_open      = false;
first_open4     = false;
drawnbefore4    = false;
drawnbeforeall  = false;
is_open         = false;

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
ti = 0;         % Berechnet die mï¿½glichen Spike-Shape Betrachtungsintervalle
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
Invert_M = [];

% ---------------------------------------------------------------------
% --- GUI -------------------------------------------------------------
% ---------------------------------------------------------------------

% Main window
mainWindow = figure('Position',[20 40 1224 700],'Tag','Dr.CELL','Name','Dr.Cell - Cardio','NumberTitle','off','Toolbar','none','Resize','off','Color',GUI_Color_BG);

% Infopanel (top left)
leftPanel = uipanel('Parent',mainWindow,'Units','pixels','Position',[5 560 370 140],'BackgroundColor',GUI_Color_BG);

% space for logo
panax2 = axes('Parent', leftPanel, 'Units','pixels', 'Position', [75 80 218 50]);
I = imread('biomems.tif');
imshow(I,'Parent',panax2,'InitialMagnification','fit');


%Selection view - 4 or all at once

%-----old Codes
% uicontrol('Parent',leftPanel,'Units','pixels','Position',[8 60 110 20],'style','text','HorizontalAlignment','left','FontWeight','bold','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','String','View','Enable','off','tag','VIEWtext');
% radiogroupview = uibuttongroup('Parent',leftPanel,'Visible','on','Units','Pixels','Position',[8 5 210 40],'BackgroundColor', GUI_Color_BG,'BorderType','none','SelectionChangeFcn',@viewhandler);
% uicontrol('Parent',radiogroupview,'Units','pixels','Position',[1 32 210 20],'Style','radio','HorizontalAlignment','left','Tag','radio_allinone','Enable','off','String','All electrodes for 1 sec.','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','Shows 1 sec of all 60 Electrodes at the same time');
% uicontrol('Parent',radiogroupview,'Units','pixels','Position',[1 12 210 20],'Style','radio','HorizontalAlignment','left','Tag','radio_fouralltime','Enable','off','String','4 electrodes for the recorded time','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','Shows 4 Electrodes for the full recorded time.');

%-----new Codes (Sh.Kh)
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



% Tab 1 (Data):
% "Import Data File..." - Button
uicontrol('Parent',t1,'Units','pixels','Position',[8 66 180 24],'Tag','CELL_openFileButton','String','Import ASCII from LabView','FontSize',9,'TooltipString','Load a recorded .dat or .txt raw-file or a spiketrain-file.','Callback',@openFileButtonCallback);

% Import McRack-Datei
uicontrol('Parent',t1,'Units','pixels','Position',[8 37 180 24],'Tag','CELL_openMcRackButton','String','Import ASCII from McRack','FontSize',9,'TooltipString','Load a recorded McRack file(.txt)','Callback',@openMcRackButtonCallback);

% "Import xls Files zur Netzwerkbursanalyse..." - Button
uicontrol('Parent',t1,'Units','pixels','Position',[200 66 180 24],'Tag','CELL_BurstanalysexlsButton','String','Analyse Network-Bursts (xls)','FontSize',9,'TooltipString','Load one or more .xls-files to analyse the network bursts.','Callback',@AnalyseNetworkburstxls);

% "Next File" und "Previous File" - Buttons
uicontrol('Parent',t1,'Units','pixels','Position',[8 8 85 24],'Tag','CELL_previousfile','String','Previous File','FontSize',9,'TooltipString','Load previous file of selected list','enable','off','Callback',@openFileButtonCallback);
uicontrol('Parent',t1,'Units','pixels','Position',[95 8 85 24],'Tag','CELL_nextfile','String','Next File','FontSize',9,'TooltipString','Load next file of selected list','enable','off','Callback',@openFileButtonCallback);

% Fix Electrode position - Button
uicontrol('Parent',t1,'Units','pixels','Position',[200 37 180 24],'Tag','CELL_SwitchElectrode','String','Switch Electrode Positions','FontSize',9,'TooltipString','Exchange electrode position -> only for files recorded with wrong Labview configuration.','Callback',@SwitchElectrodesCallback);

% "Import File" - Button 
uicontrol('Parent',t1,'Units','pixels','Position',[392 66 180 24],'Tag','CELL_splitRawFileButton','String','Import HDMEA File','FontSize',9,'TooltipString','Load a raw-file or spiketrain-file','Callback',@openButtonCallback);

% "Quick Analysis" - Button
uicontrol('Parent',t1,'Units','pixels','Position',[392+200 37 180/2+50 66-37+24],'Tag','CELL_quickCardioAnalysisButton','String','Quick Analysis','FontSize',9,'fontweight','bold','TooltipString','Perform complete cardio analysis.','Enable','on','Callback',@quickCardioAnalysisButtonCallback);


% Tab 2 (Preprocessing):

% Filter
uicontrol('Parent',t2,'Units','pixels','Position',[27 85 40 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Filter');
uicontrol('Parent',t2,'Units','pixels','Position',[8 89 20 15],'Style','checkbox','Tag','CELL_filterCheckbox','FontSize',9,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','apply digital filter.', 'CallBack',@onofilter);

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
uicontrol('Parent',t2,'Units','pixels','Position',[705 8 110 24],'Tag','CELL_applyButton','String','Apply...','FontSize',10,'Enable','off','TooltipString','Automated Spike/Burst-Analysis.','fontweight','bold','Callback',@Applyfilter);

% "empty" - Button
uicontrol('Parent',t2,'Units','pixels','Position',[705 66 110 24],'Tag','CELL_preprocessingempty1Button','String','empty','FontSize',10,'Enable','off','TooltipString','empty.','Callback',@preprocessingempty1Callback);

% "Smoothing" - Button
uicontrol('Parent',t2,'Units','pixels','Position',[580 8 110 24],'Tag','CELL_smoothButton','String','Smooth Signal','FontSize',10,'Enable','off','TooltipString','smooth single electrodes.','Callback',@smoothButtonCallback);


%Tab3 (Threshold)
% Factor sigma to find spike-free windows
uicontrol('Parent',t3,'Units','pixels','Position',[8 65 110 40],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Find Basenoise');
uicontrol('Parent',t3,'Units','pixels','Position',[8 60 100 22],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Basefactor Noise');
uicontrol('Parent',t3,'Units','pixels','Position',[120 62 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','5','Tag','STD_noisewindow');
uicontrol('Parent',t3,'Units','pixels','Position',[8 31 112 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Windowsize in ms');
uicontrol('Parent',t3,'Units','pixels','Position',[120 33 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','50','Tag','Size_noisewindow');
uicontrol('Parent',t3,'Units','pixels','Position',[8 5 100 20],'Tag','CELL_HelpThreshold','String','Help?...','FontSize',10,'Enable','off','TooltipString','Explanations Threshold Calculation.','fontweight','bold','Callback',@HelpThresholdFunction);


% "Save TH for all EL" - Button
uicontrol('Parent',t3,'Units','pixels','Position',[690 5.5 130 24],'Tag','CELL_calculateButton','String','Save TH for all EL','FontSize',10,'Enable','off','TooltipString','Threshold. ','fontweight','bold','Callback',@Thresholdforall);

% Thresholds-selection
uicontrol('Parent',t3,'Units','pixels','Position',[208 85 220 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Threshold Calculation Standard');
uicontrol('Parent',t3,'Units','pixels','Position',[280 31 50 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Factor');
%uicontrol('Parent',t3,'Units','pixels','Position',[330 33 40 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','6','Tag','CELL_sensitivityBox');
uicontrol('Parent',t3,'Units','pixels','Position',[330 33 18 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','5','Tag','CELL_sensitivityBox');

% THRESHOLDS_pos (for positve thresholds to detect positve spikes)
uicontrol('Parent',t3,'Units','Pixels','Position', [390 10 110 25],'Tag','posThCheckbox','String','Pos. Spikes','Enable','off','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','set threshold also for positive spikes to consider them in further analysis','Callback',@activatePosTh); % checkbox to activate positive threshold
uicontrol('Parent',t3,'Units','pixels','Position',[350 33 18 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','5','Tag','CELL_sensitivityBox_pos'); % factor for positive threshold

% Thresholds Auto or Manuell
radiogroup2 = uibuttongroup('Parent',t3,'visible','on','Units','Pixels','Position',[150 10 100 40],'BackgroundColor', GUI_Color_BG,'BorderType','none','SelectionChangeFcn',@handler2);
uicontrol('Parent',radiogroup2,'Units','normalized','Position',[0 0.5 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','thresh_auto','String','Auto','Enable','off','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','find threshold in thermal noise');
uicontrol('Parent',radiogroup2,'Units','normalized','Position',[0 0 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','thresh_manu','String','Manual','Enable','off','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','find threshold in given interval');

radiogroup3 = uibuttongroup('Parent',t3,'visible','on','Units','Pixels','Position',[150 50 100 40],'BackgroundColor', GUI_Color_BG,'BorderType','none','SelectionChangeFcn',@handler3);
uicontrol('Parent',radiogroup3,'Units','normalized','Position',[0 0.5 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','thresh_rms','String','rms','Enable','off','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','find threshold in thermal noise');
uicontrol('Parent',radiogroup3,'Units','normalized','Position',[0 0 .9 .4],'Style','radio','HorizontalAlignment','left','Tag','thresh_sigma','String','sigma','Enable','off','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','find threshold in given interval');

uicontrol('Parent',t3,'Units','pixels','Position',[280 62 40 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','time_start','String','-','enable','off');
uicontrol('Parent',t3,'Units','pixels','Position',[322 60 10 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','-','Tag','text_2','enable','off');
uicontrol('Parent',t3,'Units','pixels','Position',[330 62 40 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','time_end','String','-','enable','off');
uicontrol('Parent',t3,'Units','pixels','Position',[370 60 15 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','s','Tag','text_3','enable','off');

% "Calculate" - Button
uicontrol('Parent',t3,'Units','pixels','Position',[280 5 100 24],'Tag','CELL_calculateButton','String','Calculate...','FontSize',11,'Enable','off','TooltipString','Threshold. ','fontweight','bold','Callback',@CalculateThreshold);

%Set Thresholds manually

uicontrol('Parent',t3,'Units','Pixels','Position', [430 60 110 25],'Tag','Manual_threshold','String','All after','Enable','off','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Setting all thresholds after the selected one');

uicontrol('Parent',t3,'Units','pixels','Position',[430 85 180 20],'style','text','HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Enter Threshold');
uicontrol('Parent',t3,'Units','pixels','Position',[500 58 60 22],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Electrode');
uicontrol('Parent',t3,'Units','pixels','Position',[620 60 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','Elsel_Thresh');
uicontrol('Parent',t3,'Units','pixels','Position',[500 31 150 22],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Current Threshold');
uicontrol('Parent',t3,'Units','pixels','Position',[620 33 120 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','CELL_ShowcurrentThresh');

uicontrol('Parent',t3,'Units','pixels','Position',[590 60 20 20],'Tag','CELL_safeButton','String','-','FontSize',10,'Enable','off','TooltipString','Safe Threshold. ','fontweight','bold','Callback',@Elminus);
uicontrol('Parent',t3,'Units','pixels','Position',[660 60 20 20],'Tag','CELL_safeButton','String','+','FontSize',10,'Enable','off','TooltipString','Safe Threshold. ','fontweight','bold','Callback',@Elplus);



% "Show" - Button
uicontrol('Parent',t3,'Units','pixels','Position',[760 60 60 24],'Tag','CELL_safeButton','String','Show...','FontSize',10,'Enable','off','TooltipString','Safe Threshold. ','fontweight','bold','Callback',@ElgetThresholdfunction);

% "Safe" - Button
uicontrol('Parent',t3,'Units','pixels','Position',[760 35 60 24],'Tag','CELL_safeButton','String','Save...','FontSize',10,'Enable','off','TooltipString','Safe Threshold. ','fontweight','bold','Callback',@ELsaveThresholdfunction);

% "Open TH-File" and "Save TH-File" (FS)
uicontrol('Parent',t3,'Units','pixels','Position',[500 5 80 24],'Tag','THFile_openButton','String','Open TH-File','FontSize',10,'Enable','off','TooltipString','Open Threshold from external File in current folder','fontweight','bold','Callback',@ELgetThresholdFile);
uicontrol('Parent',t3,'Units','pixels','Position',[600 5 80 24],'Tag','THFile_saveButton','String','Save TH-File','FontSize',10,'Enable','off','TooltipString','Safe Threshold in external File in current folder','fontweight','bold','Callback',@ELsaveThresholdFile);




% Tab 4 (Analysis):

% Preferences Drop Down
uicontrol('Parent',t4,'Units','pixels','Position',[8 85 130 20],'style','text','HorizontalAlignment','left','FontWeight','bold','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','String','Default Settings','Enable','off');
defaulthandle = uicontrol('Parent',t4,'Units','pixels','Position',[8 66 130 20],'Tag','CELL_DefaultBox','String',['Neuron [Tam]      ';'Neuron [Baker]    ';'Neuron [Wagenaar4]';'Neuron [Wagenaar3]';'Cardiac 200ms     ';'Cardiac 100ms     '],'Enable','off','Tooltipstring','Default settings for Spike and Burstdetection','Value',5,'Style','popupmenu','callback',@handler);

%Help - Info about burstdetection
uicontrol('Parent',t4,'Units','pixels','Position',[8 37 100 20],'Tag','CELL_HelpBurst','String','Help?...','FontSize',10,'Enable','off','TooltipString','Explanations for different Burstdefinitions.','fontweight','bold','Callback',@HelpBurstFunction);

%SBE Analyse activate
uicontrol('Parent',t4,'Units','pixels','Position',[8 14 100 20],'Style','checkbox','Tag','Burst_Box','String','Burst Analysis','FontSize',9,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','En/Disables SBE Analysis');


% Spike/Burst-preferences
uicontrol('Parent',t4,'Units','pixels','Position',[160 85 180 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','pixels','FontWeight','bold','String','Spike & Burst Criteria');
uicontrol('Parent',t4,'Units','pixels','Position',[160 58 120 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Spike Idle Time in ms','TooltipString','time, where no other spike is detected after having detected one before.');
uicontrol('Parent',t4,'Units','pixels','Position',[290 60 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','1','Tag','t_spike');
uicontrol('Parent',t4,'Units','pixels','Position',[160 36 120 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Min. Spikes per Burst');
uicontrol('Parent',t4,'Units','pixels','Position',[290 38 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','3','Tag','spike_no');
uicontrol('Parent',t4,'Units','pixels','Position',[160 14 120 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Burst Idle Time in ms');
uicontrol('Parent',t4,'Units','pixels','Position',[290 16 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','500','Tag','t_dead');
uicontrol('Parent',t4,'Units','pixels','Position',[340 58 150 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Max. Time 2 first SiBs in ms');
uicontrol('Parent',t4,'Units','pixels','Position',[500 60 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','10','Tag','t_12');
uicontrol('Parent',t4,'Units','pixels','Position',[340 36 150 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor', GUI_Color_BG,'FontSize',9,'units','pixels','String','Max. Time other SiBs in ms');
uicontrol('Parent',t4,'Units','pixels','Position',[500 38 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','20','Tag','t_nn');

% "Analyse" - Button
uicontrol('Parent',t4,'Units','pixels','Position',[550 7 105 25],'Tag','CELL_analyzeButton','String','Analyze...','FontSize',11,'Enable','off','TooltipString','Automated Spike/Burst-Analysis.','fontweight','bold','Callback',@Analysedecide);



% Tab 5 (Postprocessing):

%"Checkboxen forr Spike/Burst/Stimuli/Threshold-Marks"
uicontrol('Parent',t5,'style','text','position',[10 85 40 20],'BackgroundColor', GUI_Color_BG,'FontSize',9,'Enable','off','Tag','CELL_showMarksCheckbox','units','pixels','String','Show...');
uicontrol('Parent',t5,'Units','pixels','Position',[10 65 100 27],'Style','checkbox','Tag','CELL_showThresholdsCheckbox','String','Thresholds','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the used tresholds.','Callback',@redrawdecide);
uicontrol('Parent',t5,'Units','pixels','Position',[10 45 100 27],'Style','checkbox','Tag','CELL_showSpikesCheckbox','String','Spikes (green)','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the detected spikes.','Callback',@redrawdecide);
uicontrol('Parent',t5,'Units','pixels','Position',[10 25 100 27],'Style','checkbox','Tag','CELL_showBurstsCheckbox','String','Bursts (yellow)','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the detected bursts.','Callback',@redrawdecide);
uicontrol('Parent',t5,'Units','pixels','Position',[10 5 100 27],'Style','checkbox','Tag','CELL_showStimuliCheckbox','String','Stimuli (red)','FontSize',9,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the detected stimuli.','Callback',@redrawdecide);

% "Rasterplot" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[130 66 110 24],'String','Raster Plot','Tag','t4_buttons','FontSize',9,'Enable','off','TooltipString','Spike Sorting Function.','Callback',@rasterplotButtonCallback);

%"Spiketrain" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[130 37 110 24],'Tag','CELL_frequenzanalyseButton','String','Spike Train','FontSize',9,'Enable','off','TooltipString','Spike train for individual electrodes.','Callback',@spiketrainButtonCallback);  %ANDY

% "Networkburst" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[130 8 110 24],'Tag','CELL_Networkbursts','String','Networkbursts','FontSize',9,'Enable','off','TooltipString','Analyse network bursts','Callback',@AnalyseNetworkburst);

% "Timing Analysis" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[245 66 110 24],'String','Eventtracing','Tag','t4_buttons','FontSize',9,'Enable','off','TooltipString','Timing Function.','Callback',@timingButtonCallback);

% "Frequencyanalysis" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[245 37 110 24],'Tag','CELL_frequenzanalyseButton','String','Beating Rate','FontSize',9,'Enable','off','TooltipString','Analyse HMZ.','Callback',@frequenzanalyseButtonCallback);

% "Zero-Out Example" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[245 8 110 24],'Tag','CELL_ShowZeroOutExample','String','Example ZeroOut','FontSize',9,'Enable','off','TooltipString','Shows an Example of ZeroOut algorithm','Callback',@ZeroOutExampleButtonCallback);

% "SpikeOverlay " - Button
uicontrol('Parent',t5,'Units','pixels','Position',[360 66 110 24],'String','SpikeOverlay','Tag','CELL_SpkOverlay','FontSize',9,'Enable','off','TooltipString','Spike-Overlay.','Callback',@SpkOverlay);

% "Autocorrelation" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[360 37 110 24],'String','Autocorrelation','Tag','CELL_Autocorrelation','FontSize',9,'Enable','off','TooltipString','Autocorrelation Function.','Callback',@correlationButtonCallback);

% "Crosscorrelation" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[360 8 110 24],'String','Crosscorrelation','Tag','CELL_Crosscorrelation','FontSize',9,'Enable','off','TooltipString','Autocorrelation Function.','Callback',@crosscorrelationButtonCallback);

% "Spike Analysis" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[475 37 110 24],'String','Spike Analyse','Tag','CELL_Spike Analyse','FontSize',9,'Enable','off','TooltipString','Spike Analyse','Callback',@Spike_Analyse);

% "Detektion Refinement" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[475 8 110 24],'String','Detection Refinement','Tag','CELL_Detektion Refinement','FontSize',8,'Enable','off','TooltipString','Detektion Refinement','Callback',@Detektion_Refinement);

% "BURST/SBE Analysis " - Button
uicontrol('Parent',t5,'Units','pixels','Position',[475 66 110 24],'String','Burst/SBE','Tag','Burst_SBE','FontSize',9,'Enable','off','TooltipString','Burst and SBE Analysis','Callback',@Re_Burst);

% "BURST/SBE Analysis " - Button
uicontrol('Parent',t5,'Units','pixels','Position',[590 66 110 24],'String','???','Tag','CELL_test5','FontSize',9,'Enable','off','TooltipString','unknown Function','Callback',@unknwonButtonCallback);

%%%%%Empty BOTTONS%%%%%
% "Signalprocessing" "3D" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[590 37 110 24],'String','Signalprocessing','Tag','Cell_3D','FontSize',9,'Enable','off','TooltipString','Eventprocessing','Callback',@Eventprocessing);

% "Spike-contrast" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[590 8 110 24],'String','Spike-contrast','Tag','CELL_test3','FontSize',9,'Enable','off','TooltipString','Calculate Spike-contrast.','Callback',@SpikeContrastButtonCallback);

% "Connectivity" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[705 66 110 24],'String','Connectivity','Tag','CELL_test1','FontSize',9,'Enable','off','TooltipString','Calculate Connectivity "TSPE".','Callback',@EstimateConnectivityButtonCallback);

% "??" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[705 37 110 24],'String','Histogram','Tag','CELL_test2','FontSize',9,'Enable','off','TooltipString','unknown Function.','Callback',@histogramBeatingRate);

% "??" - Button
uicontrol('Parent',t5,'Units','pixels','Position',[705 8 110 24],'String','???','Tag','CELL_test3','FontSize',9,'Enable','off','TooltipString','unknown Function.','Callback',@unknwonButtonCallback);


% Tab 6 (Spike Sorting):

%"Checkboxes for Spike/Burst/Stimuli/Threshold-Marks"
uicontrol('Parent',t6,'style','text','position',[10 85 40 20],'BackgroundColor', GUI_Color_BG,'FontSize',9,'Enable','off','Tag','CELL_showMarksCheckbox','units','pixels','String','Show...');
uicontrol('Parent',t6,'Units','pixels','Position',[10 65 100 27],'Style','checkbox','Tag','CELL_showThresholdsCheckbox','String','Thresholds','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the used tresholds.','Callback',@redrawdecide);
uicontrol('Parent',t6,'Units','pixels','Position',[10 45 100 27],'Style','checkbox','Tag','CELL_showSpikesCheckbox','String','Spikes (green)','FontSize',9,'Value',1,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the detected spikes.','Callback',@redrawdecide);
uicontrol('Parent',t6,'Units','pixels','Position',[10 25 100 27],'Style','checkbox','Tag','CELL_showBurstsCheckbox','String','Bursts (yellow)','FontSize',9,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the detected bursts.','Callback',@redrawdecide);
uicontrol('Parent',t6,'Units','pixels','Position',[10 5 100 27],'Style','checkbox','Tag','CELL_showStimuliCheckbox','String','Stimuli (red)','FontSize',9,'Value',0,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Shows the detected stimuli.','Callback',@redrawdecide);

%"Rasterplot" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[130 66 110 24],'String','Raster Plot','Tag','t4_buttons','FontSize',9,'Enable','off','TooltipString','Spike Sorting Function.','Callback',@rasterplotButtonCallback);

%"Spiketrain" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[130 37 110 24],'Tag','CELL_frequenzanalyseButton','String','Spike Train','FontSize',9,'Enable','off','TooltipString','Spike train for individual electrodes.','Callback',@spiketrainButtonCallback);  %ANDY

% "Networkburst" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[130 8 110 24],'Tag','CELL_Networkbursts','String','Networkbursts','FontSize',9,'Enable','off','TooltipString','Analyse network bursts','Callback',@AnalyseNetworkburst);

% "Timing Analysis" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[245 66 110 24],'String','Eventtracing','Tag','t4_buttons','FontSize',9,'Enable','off','TooltipString','Timing Function.','Callback',@timingButtonCallback);

% "Frequenzanalyse" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[245 37 110 24],'Tag','CELL_frequenzanalyseButton','String','Beating Rate','FontSize',9,'Enable','off','TooltipString','Analyse HMZ.','Callback',@frequenzanalyseButtonCallback);

% "Zero-Out Example" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[245 8 110 24],'Tag','CELL_ShowZeroOutExample','String','Example ZeroOut','FontSize',9,'Enable','off','TooltipString','Shows an Example of ZeroOut algorithm','Callback',@ZeroOutExampleButtonCallback);

% "Spike Overlay " - Button
uicontrol('Parent',t6,'Units','pixels','Position',[360 66 110 24],'String','SpikeOverlay','Tag','CELL_SpkOverlay','FontSize',9,'Enable','off','TooltipString','Spike-Overlay & QT-Intervallbestimmung','Callback',@SpkOverlay);

% "Autocorrelation" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[360 37 110 24],'String','Autocorrelation','Tag','CELL_Autocorrelation','FontSize',9,'Enable','off','TooltipString','Autocorrelation Function.','Callback',@correlationButtonCallback);

% "Crosscorrelation" - Button
uicontrol('Parent',t6,'Units','pixels','Position',[360 8 110 24],'String','Crosscorrelation','Tag','CELL_Crosscorrelation','FontSize',9,'Enable','off','TooltipString','Autocorrelation Function.','Callback',@crosscorrelationButtonCallback);

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

% Tab 7 (Export):

% "Export Summary" - Preferences checkboxes
uicontrol('Parent',t7,'Units','pixels','Position',[8 66 180 24],'Tag','CELL_exportButton','String','Export Summary to .xls','FontSize',9,'Enable','off','TooltipString','Speichert eine Auswertedatei als .xls','Callback',@safexlsButtonCallback);
uicontrol('Parent',t7,'Units','pixels','Position',[15 28 120 27],'Style','checkbox','Tag','CELL_exportAllCheckbox','String','with Timestamps','FontSize',9,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Write timestamps to file?');
uicontrol('Parent',t7,'Units','pixels','Position',[15 8 120 27],'Style','checkbox','Tag','CELL_showExportCheckbox','String','open File now','FontSize',9,'Enable','off','BackgroundColor', GUI_Color_BG,'TooltipString','Should the file be opened after exporting?');

% "Save Spikes"
uicontrol('Parent',t7,'Units','pixels','Position',[584 66 180 24],'Tag','CELL_exportTimeAmpButton','String','Save Spikes as mat','FontSize',9,'Enable','on','TooltipString','Saves SPIKEZ (timestamps, amplitudes of spikes and fileinfos) as .mat-file','Callback',@SaveSpikesCallback);

% "Export Networkburst"
%uicontrol('Parent',t7,'Units','pixels','Position',[200 66 180 24],'Tag','CELL_exportNWBButton','String','Export Networkburst to .xls','FontSize',9,'Enable','off','TooltipString','Saves Networkburstanalysis into a .xls-file','Callback',@ExportNWBCallback);

% "Export Cleared Matrix"
%uicontrol('Parent',t7,'Units','pixels','Position',[392 66 180 24],'Tag','CELL_exportClearedMButton','String','Export Cleared File','FontSize',9,'Enable','on','TooltipString','Saves txt file without cleared electrodes','Callback',@ExportclearedBCallback);

% "Export Time_Amplitude Matrix"
%uicontrol('Parent',t7,'Units','pixels','Position',[584 66 180 24],'Tag','CELL_exportTimeAmpButton','String','Export Time Amp','FontSize',9,'Enable','on','TooltipString','Saves txt file without cleared electrodes','Callback',@ExportTimeAmpCallback);

% "Export Time_Shape Matrix"
%uicontrol('Parent',t7,'Units','pixels','Position',[584 36 180 24],'Tag','CELL_exportTimeShapeButton','String','Export Time Shape','FontSize',9,'Enable','on','TooltipString','Saves txt file without cleared electrodes','Callback',@ExportTimeShapeCallback);

% Tab 8 (Fileinfo):
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



% Tab 9 (About):
%uicontrol('Parent',t9,'style','text','position', [5 75 600 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','This software is property of the biomems lab of the University of Applied Sciences Aschaffenburg, Germany.','Enable','on');
uicontrol('Parent',t9,'style','text','position', [5 46 600 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Contact us: www.h-ab.de\biomems or christiane.thielemann@h-ab.de .','Enable','on');
uicontrol('Parent',t9,'style','text','position', [5 25 600 20],'BackgroundColor', GUI_Color_BG,'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Postal: University of Applied Sciences - BioMEMS, Wï¿½rzburger Str 45, 63743 Aschaffenburg, Germany','Enable','on');

uicontrol('Parent',t9,'Units','pixels','Position',[5 75 150 20],'Tag','CELL_License','String','License Disclaimer','FontSize',10,'Enable','on','TooltipString','GNU GPL 2007','fontweight','bold','Callback',@HelpLicenseFunction);


panax1 = axes('Parent', t9, 'Units','pixels', 'Position', [630 5 201 100]);
I1 = imread('hablogo.tif');
imshow(I1,'Parent',panax1,'InitialMagnification','fit');



%% Tab 10 (Tools):
uicontrol('Parent',t10,'Units','pixels','Position',[10 66 200 24],'String','Automated Analysis','FontSize',9,'Enable','on','TooltipString','Open tool for automated  in new window.','Callback',@AutomatedAnalysis_Callback);



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
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 470 45 20],'Tag','CELL_invertButton1','String','Invert','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton1Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 470-dist 45 20],'Tag','CELL_invertButton2','String','Invert','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton2Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 470-2*dist 45 20],'Tag','CELL_invertButton3','String','Invert','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton3Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 470-3*dist 45 20],'Tag','CELL_invertButton4','String','Invert','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton4Callback);

% 'Zero'-Buttons
dist = 120;
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 445 45 20],'Tag','CELL_zeroButton1','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton1Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 445-dist 45 20],'Tag','CELL_zeroButton2','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton2Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 445-2*dist 45 20],'Tag','CELL_zeroButton3','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton3Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 445-3*dist 45 20],'Tag','CELL_zeroButton4','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton4Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 375-3*dist 80 20],'Tag','CELL_zeroButton4','String','Clear all visible','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButtonallCallback);

% 'Undo'-Buttons
dist = 120;
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 420 45 20],'Tag','CELL_zeroButton1','String','Undo','Visible','off','TooltipString','clear signal of this electrode.','Callback',@undoButton1Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 420-dist 45 20],'Tag','CELL_zeroButton2','String','Undo','Visible','off','TooltipString','clear signal of this electrode.','Callback',@undoButton2Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 420-2*dist 45 20],'Tag','CELL_zeroButton3','String','Undo','Visible','off','TooltipString','clear signal of this electrode.','Callback',@undoButton3Callback);
uicontrol('Parent',bottomPanel,'Units','pixels','Position',[1105 420-3*dist 45 20],'Tag','CELL_zeroButton4','String','Undo','Visible','off','TooltipString','clear signal of this electrode.','Callback',@undoButton4Callback);

% 'Edit'-Windows

%uicontrol('Parent',bottomPanel,'Units','pixels','BackgroundColor','w','Position',[30 50 50 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','xlimit');

% Bottom Panel 2
bottomPanel_zwei = uipanel('Parent',mainWindow,'Units','pixels','Position',[5 5 1214 553],'Tag','CELL_BottomPanel_zwei','BackgroundColor', GUI_Color_BG);

% Scrollbar horizontal
uicontrol('Parent', bottomPanel_zwei,'style', 'slider','Tag','MEA_slider','units', 'pixels', 'position', [5 5 1204 20],'Enable','off','callback',@redrawdecide);


% Bottom Panel HD (Sh.Kh)
bottomPanel_HD = uipanel('Parent',mainWindow,'Units','pixels','Position',[5 5 1214 553],'Tag','CELL_BottomPanel_HD','BackgroundColor', GUI_Color_BG);

% "Zoom"-Buttons (Sh.Kh)
uicontrol('Parent',bottomPanel_HD,'Units','pixels','Position',[1105 135 45 20],'Tag','CELL_zoomGraphButton4','String','Zoom','Visible','off','TooltipString','zoom into this Graph.','Callback',@zoomButton4Callback);

% 'Invert'-Buttons (Sh.Kh)
uicontrol('Parent',bottomPanel_HD,'Units','pixels','Position',[1105 110 45 20],'Tag','CELL_invertButton4','String','Invert.','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton4Callback);

% 'Zero'-Buttons (Sh.Kh)
uicontrol('Parent',bottomPanel_HD,'Units','pixels','Position',[1105 15 60 20],'Tag','CELL_zeroButton4','String','Clear all','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButtonallCallback);

% 'Undo'-Buttons (Sh.Kh)
uicontrol('Parent',bottomPanel_HD,'Units','pixels','Position',[1105 60 45 20],'Tag','CELL_zeroButton4','String','Undo','Visible','off','TooltipString','clear signal of this electrode.','Callback',@undoButton4Callback);





% ---------------------------------------------------------------------
% --- Functions ------------------------------------------------------
% ---------------------------------------------------------------------


% --- Quick Cardio Analysis (MC) -----------------------------------------
    function quickCardioAnalysisButtonCallback(~,~)
        
        disp('------ QUICK CARDIO ANALYIS ---------')
        HDrawdata = false;
        
        %Applyfilter(); % same function call as pressing button "Apply..." (tab 2)
        
        % Calculate Threshold
        thresholddata = false;
        factor=5;
        [THRESHOLDS,THRESHOLDS_pos,ELEC_CHECK,SPIKEZ,COL_RMS,COL_SDT]=cardioThreshold(RAW,SPIKEZ,factor);
        redrawdecide;
        thresholddata = true;
        set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Value',1,'Enable','on')
        set(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'String','');
        set(findobj(gcf,'Tag','Elsel_Thresh'),'String','');
        
        % Spikedetection
        SPIKEZ = cardioSpikedetection(RAW,SPIKEZ,COL_RMS, COL_SDT, HDrawdata);
        spikedata = true;
        set(findobj(gcf,'Parent',t5),'Enable','on');
        set(findobj(gcf,'Parent',t6),'Enable','on');
        set(findobj(gcf,'Parent',t7),'Enable','on');
        disp('Spikedetection finished')
        
        % Delte low FR
        minFR=3;
        [SPIKEZ,SPIKES,AMPLITUDES,NR_SPIKES] = cardioDeleteLowFR(SPIKEZ,minFR);

        % Delete non-median electrodes
        [SPIKEZ,numSpikes] = cardioDeleteNonMedianElectrodes(SPIKEZ);
        
        % Delete non-synchronous electrodes
        synchrony_matrix=cardioPairwiseSynchrony(SPIKEZ,rec_dur);
        %cardioDetectCluster(synchrony_matrix)
        [SPIKEZ,SPIKES,AMPLITUDES,NR_SPIKES] = cardioDeleteNonSynchronousElectrodes(SPIKEZ,synchrony_matrix);
        
        % Check if spiketrain is clear (S=1)
        [S,PREF] = SpikeContrast(SPIKEZ.TS,rec_dur, 0.1);
        disp(['Spike-contrast:' num2str(S)])
        cardioShowNumberOfActiveElectrodes()
        redrawdecide()
        
        % calculate signal speed
        [velocity_airline,velocity_min_mean,velocity_max_mean] = cardioCalculateSpeed(SPIKEZ,numSpikes);
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

        
        % old parameter:
        SPIKES=SPIKEZ.TS;
        AMPLITUDES=SPIKEZ.AMP;
        NR_SPIKES=SPIKEZ.N;
        FR=SPIKEZ.FR;
        N_FR=SPIKEZ.aeN_FR; % number of active electrodes
        aeFRmean=SPIKEZ.aeFRmean;
        aeFRstd=SPIKEZ.aeFRstd;
        SNR=SPIKEZ.neg.SNR.SNR;
        SNR_dB = SPIKEZ.neg.SNR.SNR_dB;
        Mean_SNR_dB = SPIKEZ.neg.SNR.Mean_SNR_dB;
    end

function cardioShowNumberOfActiveElectrodes()

             disp(['Number of active electrodes: ' num2str(SPIKEZ.aeFRn)]) 
 
    end
    

    

    

    

    

    

    

    

   

    



    

% --- Empty Function (CN)-----------------------------------------
    function unknwonButtonCallback(source,event) %#ok
        
        msgbox('You can write your own algorithm and use this button to call it','Dr.CELLï¿½s hint','help');
        uiwait;
        
    end

% --- ScaleRedraw-Selection (CN)-----------------------------------------
    function redrawdecide(source,event) %#ok
        
       set(0, 'currentfigure', mainWindow); % set main window as current figure so "gcf" works correctly
       
       if HDspikedata==1 || HDrowdata==1  
           HDredraw;
       elseif Viewselect == 1
           redraw_allinone; 
       elseif Viewselect == 0
            redraw;
       end
    end

% --- View-Selection (CN)------------------------------------------------
    function viewhandler(source,event) %#ok<INUSL>
        set(0, 'currentfigure', mainWindow); % set main window as current figure so "gcf" works correctly
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
                        'Min', 0, 'Max', size(RAW.M,2)-4, 'Value', size(RAW.M,2)-4,...
                        'SliderStep', [1/(size(RAW.M,2)-4) 4/(size(RAW.M,2)-4)]);
                end
                set(findobj(gcf,'Parent',bottomPanel,'Visible','off'),'Visible','on');
                redraw;
        end
    end

% --- Redraw 1 graphs-view whit HDMEA(.brw)Data(Sh.Kh)-------------------
    function HDredraw(~,~) 
        
          set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...
         'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[1/rec_dur 1/rec_dur])
          bottomPanel_HD= uipanel('Parent',mainWindow,'Units','pixels','Position',[5 5 1214 553],'Tag','CELL_BottomPanel_HD','BackgroundColor', GUI_Color_BG);

%         if  HDrowdata == true
            
            set(findobj(gcf,'Tag','CELL_BottomPanel_zwei'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_BottomPanel'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_BottomPanel_HD'),'Visible','on');
            %---single analysis
            
            set(0,'CurrentFigure',mainWindow) % changes current figure so that gcf and sliderpos works
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
            
            View_Signal;
%         end
    end
    function View_Signal(~,~) 
            set(0, 'currentfigure', mainWindow); % set main window as current figure so "gcf" works correctly
            set(findobj(gcf,'Tag','CELL_BottomPanel_zwei'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_BottomPanel'),'Visible','off');
            set(findobj(gcf,'Tag','CELL_BottomPanel_HD'),'Visible','on');
            SubMEA_vier(4)=0;
            SubMEA_vier(4)=subplot(4,1,4,'Parent',bottomPanel_HD);
            %el_no=0;
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
               if HDrowdata==1
                   mm=RAW.M(:,el_no(1));
                   mm=double(mm);
                   if RAW.MaxVolt==-RAW.MinVolt
                       RAW.BitDepth= double(RAW.BitDepth); 
                       mm=(mm-(2^RAW.BitDepth)/2)*(RAW.MaxVolt*2/2^RAW.BitDepth);
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
%                 if  max(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value'))>=1 && size(BURSTS.BEG,1)>1
%                    SP = nonzeros(BURSTS.BEG(:,el_no));                            % (yellow triangle)
%                    if isempty(SP)==0
%                         y_axis = ones(length(SP),1).*scale.*.9;
%                         line ('Xdata',SP,'Ydata', y_axis,...
%                             'LineStyle','none','Marker','v',...
%                             'MarkerFaceColor','yellow','MarkerSize',9);
%                    end
%                 end


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
        %graph_no = size(M,2)-slider_pos-3;
        graph_no = nr_channel-slider_pos-3; %Sh.Kh
        
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
                hold on;
                if varTdata==1
                    plot (T,varT(:,graph_no+n),...
                        'LineStyle','--','Color','red');
                end
                hold off;
                
                if thresholddata
                    if varTdata==0
                        if  get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','parent',t6),'value')
                            line ('Xdata',[0 T(length(T))],...
                                'Ydata',[THRESHOLDS(graph_no+n) THRESHOLDS(graph_no+n)],...
                                'LineStyle','--','Color','red');
                        end
                    end
                end
                
                if spikedata==1
                    
                    if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t6),'value')       % Spikes
                        
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
                            
                            %Write #Spikes und #Bursts fï¿½r jede El.
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
                                'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', NR_BURSTS(graph_no+n));
                            end
                            
                            if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','parent',t6),'value')
                                SP = nonzeros(SPIKES(:,graph_no+n));                            % (green triangles)
                                if isempty(SP)==0
                                    y_axis = ones(length(SP),1).*scale.*.9;
                                    line ('Xdata',SP,'Ydata', y_axis,...
                                        'LineStyle','none','Marker','v',...
                                        'MarkerFaceColor','green','MarkerSize',9);
                                end
                            end
                        end
                        if  max(cell2mat(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value')))>=1 && size(BURSTS.BEG,2)==size(SPIKES,2)
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
                    if get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','parent',t6),'value')
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
                        if get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','parent',t6),'value')
                            line ('Xdata',[0 T(length(T))],...
                                'Ydata',[THRESHOLDS(n) THRESHOLDS(n)],...
                                'LineStyle','--','Color','red');
%                              if size(THRESHOLDS_pos,2)==size(RAW.M,2)
%                                line ('Xdata',[0 T(length(T))],...
%                                 'Ydata',[THRESHOLDS_pos(graph_no+n) THRESHOLDS_pos(graph_no+n)],...
%                                 'LineStyle','--','Color','red'); 
%                             end
                        end
                    end
                end
                
                if spikedata==1
                    
                    if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t6),'value')       % Spikes
                        
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
                                'Parent',bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String',NR_BURSTS(n));
                        end
                        
                        if  max(cell2mat(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value')))>=1
                            SP = nonzeros(BURSTS(:,n));
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
                    if get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','parent',t6),'value')
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

% Manuelles setzen des Thresholds
    %function click(hObj,tmp)
    function click(~,~)
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
        
        if strcmp((get(gcbf, 'SelectionType')),'normal')
            THRESHOLDS(Zoom_Electrode) = ab(1,2);
        else
            for n = Zoom_Electrode:1:size(THRESHOLDS,2)
                THRESHOLDS(n) = ab(1,2);
            end
        end
        
        
        redrawdecide
        %redraw();
    end

% --- Redraw in overview (CN) ------------------------
    function redraw_allinone(source,event) %#ok<INUSD>
        
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
        
        showend = MEAslider_pos*SaRa + 1;
        showstart = showend - SaRa;
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
                if get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','parent',t6),'value')
                    line ('Xdata',[0 T(length(T))],...                              % (lines)
                        'Ydata',[THRESHOLDS(n) THRESHOLDS(n)],'LineStyle','--','Color','red');
                end
            end
            
            if spikedata==1
                if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','parent',t6),'value')
                    SP = nonzeros(SPIKES(:,n));                            % (green triangles)
                    if isempty(SP)==0
                        y_axis = ones(length(SP),1).*scale.*.9;
                        line ('Xdata',SP,'Ydata', y_axis,...
                            'LineStyle','none','Marker','v','MarkerFaceColor','green','MarkerSize',9);
                    end
                end
                if  max(cell2mat(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value')))>=1
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
                if get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','parent',t6),'value')
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

% --- functions of zoom-buttoms (MG)-------------------------------

    function zoomButton1Callback(source,event) %#ok<INUSD>
       if rawcheck == 1
          % ylimit = str2num(get(findobj(gcf,'Tag','xlimit'),'string'));
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
%                     if ~isempty(ylimit)
%                     axis([0 60 -ylimit ylimit])
%                     end
                    if thresholddata
                        line ('Xdata',[0 T(length(T))],...
                            'Ydata',[THRESHOLDS(Zoom_Electrode) THRESHOLDS(Zoom_Electrode)],...
                            'LineStyle','--','Color','red');
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
%         if  get(findobj('Tag','CELL_showBurstsCheckbox','Parent',t5),'value')==1
%             if ~isempty(BURSTS.BEG)    % display burstbegin
%                 SP = nonzeros(BURSTS.BEG(:,Zoom_Electrode));
%                 Scale=0;
%                 if isempty(SP)==0
%                     y_axis = ones(length(SP),1).*Scale.*.92;
%                     line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
%                         'LineStyle','none','Marker','>',...
%                         'MarkerFaceColor','yellow','MarkerSize',9);
%                 end
%             end
%             if ~isempty(BURSTS.END)   % display burstend
%                 SP = nonzeros(BURSTS.END(:,Zoom_Electrode));
%                 Scale=0;
%                 if isempty(SP)==0
%                     y_axis = ones(length(SP),1).*Scale.*.92;
%                     line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
%                         'LineStyle','none','Marker','<',...
%                         'MarkerFaceColor','yellow','MarkerSize',9);
%                 end
%             end
%         end
        mea = Zoom_Electrode;
        iu = 1;
        set(gca,'ButtonDownFcn',{@clicks,mea,iu})
    end
    function zoomButton2Callback(source,event) %#ok<INUSD>
        if rawcheck == 1
%            ylimit = str2num(get(findobj(gcf,'Tag','xlimit'),'string'));
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
%                     if ~isempty(ylimit)
%                     axis([0 60 -ylimit ylimit])
%                     end
                    if thresholddata
                        line ('Xdata',[0 T(length(T))],...
                            'Ydata',[THRESHOLDS(Zoom_Electrode) THRESHOLDS(Zoom_Electrode)],...
                            'LineStyle','--','Color','red');
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
    end
    function zoomButton3Callback(source,event) %#ok<INUSD>
        if rawcheck == 1
%            ylimit = str2num(get(findobj(gcf,'Tag','xlimit'),'string'));
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
%                     if ~isempty(ylimit)
%                     axis([0 60 -ylimit ylimit])
%                     end
                    if thresholddata
                        line ('Xdata',[0 T(length(T))],...
                            'Ydata',[THRESHOLDS(Zoom_Electrode) THRESHOLDS(Zoom_Electrode)],...
                            'LineStyle','--','Color','red');
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
                    plot(T,M(:,Zoom_Electrode)); grid on;
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
%             ylimit = str2num(get(findobj(gcf,'Tag','xlimit'),'string'));
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Zoom_Electrode = nr_channel-slider_pos;
                if HDrowdata == true || HDspikedata==true
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
                        if HDrowdata==true
                            m = digital2analog_sh(RAW.M(:,Zoom_Electrode),RAW);
                            plot(T,m); grid on;
                        else
                            plot(T,RAW.M(:,Zoom_Electrode)); grid on;
                        end
                end
                    if thresholddata
                        line ('Xdata',[0 T(length(T))],...
                            'Ydata',[THRESHOLDS(Zoom_Electrode) THRESHOLDS(Zoom_Electrode)],...
                            'LineStyle','--','Color','red');
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
            if ~isempty(SPIKES)     % display spikes
                SP = nonzeros(SPIKES(:,Zoom_Electrode));
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
            if ~isempty(BURSTS.BEG)     % display burstbegin
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
    function clicks(~,~,mea,iu)
        ab = get(gca,'CurrentPoint');
        [~,~,BUTTON]=ginput(1);
        close('Zoom');     
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
         
        if HDrowdata == true || HDspikedata==true
            HDredraw();            
        else
            redraw();
        end  
%         THRESHOLDS(mea) = ab(1,2);
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
    function clearButton1Callback(source,event)  %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos-3;
        else
            Clear_Elektrode = 1;
            
        end
        backup_M(:,Clear_Elektrode) = RAW.M(:,Clear_Elektrode);
        RAW.M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS(:,Clear_Elektrode)=0;
        end
        redraw;
    end
    function clearButton2Callback(source,event)  %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos-2;
        else
            Clear_Elektrode = 2;
        end
        
        backup_M(:,Clear_Elektrode) = RAW.M(:,Clear_Elektrode);
        RAW.M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS(:,Clear_Elektrode)=0;
        end
        redraw;
    end
    function clearButton3Callback(source,event)  %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos-1;
        else
            Clear_Elektrode = 3;
        end
        
        backup_M(:,Clear_Elektrode) = RAW.M(:,Clear_Elektrode);
        RAW.M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS(:,Clear_Elektrode)=0;
        end
        redraw;
    end
    function clearButton4Callback(source,event)  %#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            Clear_Elektrode=nr_channel-slider_pos;
        else
            Clear_Elektrode = 4;
        end
        
        backup_M(:,Clear_Elektrode) = RAW.M(:,Clear_Elektrode);
        RAW.M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS(:,Clear_Elektrode)=0;
        end
        redraw;
    end
    function clearButtonallCallback(source,event)%#ok
        if nr_channel>4
            slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
            tb=nr_channel-slider_pos;
            tr = tb - 3;
        else
            tb= nr_channel;
            tr = 1;
        end
        for Clear_Elektrode = tr:tb
            backup_M = RAW.M(:,Clear_Elektrode);
            RAW.M(:,Clear_Elektrode)=0;
            if spiketraincheck == 1
                SPIKES(:,Clear_Elektrode)=0;
                BURSTS(:,Clear_Elektrode)=0;
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
        backup_M(:,Clear_Elektrode) = [];
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
        backup_M(:,Clear_Elektrode) = [];
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
        backup_M(:,Clear_Elektrode) = [];
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
        backup_M(:,Clear_Elektrode) = [];
        redraw;
    end

%Functions - Tab Data
%----------------------------------------------------------------------

% --- Open file (Raw or Spiketrain) (MG&CN)-----------------------
    function openFileButtonCallback(source,event) %#ok<INUSD>
        
        clear Energy Variance;
        SPIKES3D = [];
        SPIKES = [];
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
        handler;
        Nr_SI_EVENTS    = 0;
        Mean_SIB        = 0;
        Mean_SNR_dB     = 0;
        MBDae           = 0;
        STDburstae      = 0;
        aeIBImean       = 0;
        aeIBIstd        = 0;
        SPIKES          = 0;
        BURSTS          = 0;
        SI_EVENTS       = 0;
        spikedata       = false;
       % M               = 0;
        EL_NUMS         = 0;
        first_open      = false;
        first_open4     = false;
        spiketraincheck = false;
        rawcheck        = false;
        NR_SPIKES       = 0;
        NR_BURSTS       = 0;
        THRESHOLDS      = 0;
        kappa_mean      = 0;
        threshrmsdecide = 1; %As Default setting use rms for threshold calculation
        
        varT            = 0;
        varTdata        = 0;
        
        HDrowdata       = false;
        HDspikedata     = false;
        NCh             = 0 ;
        
        % use path of last loaded file if exist
        if path ~= 0
            cd(path)
        end
        
        % 'Open file' - Window
        i = 1;
        if strcmp(get(source,'Tag'),'CELL_nextfile')
            while i <= size(filearray,2) && not(strcmp(file ,filearray(i)))
                i = i+1;
            end
            i = i+1;
            set(findobj('Tag','CELL_previousfile'),'enable','on');
            if i == size(filearray,2)
                set(source,'enable','off');
            end
            path = full_path(1:max(strfind(full_path,'\')));
            file = filearray{i};
        elseif strcmp(get(source,'Tag'),'CELL_previousfile')
            while i <= size(filearray,2) && not(strcmp(file ,filearray(i)))
                i = i+1;
            end
            i = i-1;
            set(findobj('Tag','CELL_nextfile'),'enable','on');
            if i == 1
                set(source,'enable','off');
            end
            path = full_path(1:max(strfind(full_path,'\')));
            file = filearray{i};
        else
            if full_path ~= 0
                path = full_path(1:max(strfind(full_path,'\')));
                [file,path] = uigetfile({'*.txt;*.dat','Data file (*.txt,*.dat)'},'Open data file...',path,'MultiSelect','on');
            else
                [file,path] = uigetfile({'*.txt;*.dat','Data file (*.txt,*.dat)'},'Open data file...','MultiSelect','on');
            end
            
            if not(iscell(file)) && not(ischar(file)) % if canceled - dont do anything
                return
            end
            
            if iscell(file) %if multiple files are selected
                filearray = file;
                file = filearray{i};
                full_path = [path,file];
                set(findobj('Tag','CELL_previousfile'),'enable','off');
                set(findobj('Tag','CELL_nextfile'),'enable','on');
            else
                filearray = [];
                full_path = [path,file];
                set(findobj('Tag','CELL_previousfile'),'enable','off');
                set(findobj('Tag','CELL_nextfile'),'enable','off');
            end
        end
        
        
        disp ('Importing data file:'); tic
        h = waitbar(0,'Please wait - importing data file...');
        fid = fopen([path file]);                                   % open file
        
        fseek(fid,0,'eof');
        filesize = ftell(fid);                                      % safes file size,
        fseek(fid,0,'bof');
        fileinfo = textscan(fid,'%s',1,'delimiter','\n');
        
        filedetails = textscan(fid,'%s',1,'delimiter','\n');
        filedetailscell = strread(char([filedetails{1}]),'%s','delimiter',',');
        
        Date = char([filedetailscell{1}]);
        Time = char([filedetailscell{2}]);
        Sample = char([filedetailscell{3}]);
        Sample = Sample(1:(size(Sample,2)-3));
        SaRa = str2double(Sample);
        FileType = [];
        if size(filedetailscell,1)==4
            FileType = char([filedetailscell{4}]);
        end
        
        
        if isempty(Date)
            waitbar(1,h,'Complete.'); close(h);
            msgbox('Maybe you try to open a McRack-file with the wrong button?!','Dr.CELLï¿½s hint','help');
            uiwait;
            return
        end
        fseek(fid,0,'bof');
        
        %---if there is no information in the header---
        if isempty(FileType)
            
            textscan(fid,'%s',1,'whitespace','\b\t','headerlines',2);
            elresult = textscan(fid,'%5s',61*1,'whitespace','\b\t');    % read electrode names
            EL_NAMES = [elresult{:}];
            
            if is_open==1
                nr_channel_old = nr_channel;
            end
            
            nr_channel = find(ismember(EL_NAMES, '[ms]')==1)-1;
            if isempty(nr_channel)
                nr_channel = find(ismember(EL_NAMES, '[ms] ')==1)-1;
            end
            
            
            EL_NAMES = EL_NAMES(1:nr_channel);
            EL_CHAR = char(EL_NAMES);                                   % put electrode names in char..
            
            for n=1:size(EL_CHAR,1)                                     % ...convert into double.
                EL_NUMS(n) = str2double(EL_CHAR(n,4:5));
            end
            
            fseek(fid,0,'bof');
            
            if file(length(file)-2)=='t'
                mresult = textscan(fid,'',1,'headerlines',4);
                RAW.M = [mresult{2:length(mresult)-1}];                     % signal data
            else
                
                %---if data is separated by comma---
                %for separation by dot see ifelse FileType == 'R'!
                
                mresult = textscan(fid,'%n,%n',(nr_channel+1)*1,'headerlines',4);   % ...if .dat-file:
                RAW.M = mresult{1}+mresult{2}.*(.1-.2*(mresult{1}<0));
                RAW.M = reshape(RAW.M,(nr_channel+1),1);
                RAW.M = RAW.M';
                
                RAW.M = RAW.M(:,2:(nr_channel+1));
            end
            
            clear M_temp;
            
            
            while ftell(fid)<filesize
                if file(length(file)-2)=='t'
                    mresult = textscan(fid,'',ceil(filesize/10000));
                    RAW.M = cat(1,RAW.M,[mresult{2:length(mresult)-1}]);
                    waitbar(ftell(fid)*.98/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
                else
                    %---if data is separated by comma---
                    mresult = textscan(fid,'%n,%n',(nr_channel+1)*30000);
                    M_temp = mresult{1}+mresult{2}.*(.1-.2*(mresult{1}<0));
                    M_temp = reshape(M_temp,(nr_channel+1),[]);
                    M_temp = M_temp';
                    
                    RAW.M = cat(1,RAW.M,M_temp(:,2:(nr_channel+1)));
                    waitbar(ftell(fid)*.98/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
                end
            end
            
            
            clear M_temp;
            clear mresult;
            
            
            
            T2=(0:1/SaRa:(size(RAW.M,1)/SaRa));
            T=T2(1:(length(T2)-1));
            clear T2
            
            RAW.M = cat(2,EL_NUMS',RAW.M');
            RAW.M = sortrows(RAW.M);
            RAW.M = RAW.M(:,2:size(RAW.M,2));
            RAW.M = RAW.M';
            EL_NAMES = sortrows(EL_NAMES);
            EL_NUMS = sort(EL_NUMS);
            rec_dur = ceil(T(length(T)));
            rec_dur_string = num2str(rec_dur);
            
            %if needed delete %
            %M_OR = M;                           % Copy of M
            
            fclose(fid);                        % Close file
            waitbar(1,h,'Complete.'); close(h);
            toc
            
            
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
            is_open = true;
            rawcheck = true;
            
            
            %---if rawdata---
        elseif FileType(1) == 'R'
            textscan(fid,'%s',1,'whitespace','\b\t','headerlines',2);
            elresult = textscan(fid,'%5s',61*1,'whitespace','\b\t');
            EL_NAMES = [elresult{:}];
            
            if is_open==1
                nr_channel_old = nr_channel;
            end
            
            nr_channel = find(ismember(EL_NAMES, '[ms]')==1)-1;
            if isempty(nr_channel)
                nr_channel = find(ismember(EL_NAMES, '[ms] ')==1)-1;
            end
            EL_NAMES = EL_NAMES(1:nr_channel);
            EL_CHAR = char(EL_NAMES);
            
            for n=1:size(EL_CHAR,1)
                EL_NUMS(n) = str2double(EL_CHAR(n,4:5));
            end
            
            fseek(fid,0,'bof');
            if file(length(file)-2)=='t'
                mresult = textscan(fid,'',1,'headerlines',4);
                RAW.M = [mresult{2:length(mresult)}];
                %RAW.M = [mresult{2:length(mresult)-1}]; original changed 2013-04-04
            else
                %---separation by dot---
                mresult = textscan(fid,'',1,'headerlines',4);
                RAW.M = [mresult{2:length(mresult)}];
            end
            
            clear M_temp;
            
            while ftell(fid)<filesize-2
                if file(length(file)-2)=='t'
                    mresult = textscan(fid,'',ceil(filesize/10000));
                    RAW.M = cat(1,RAW.M,[mresult{2:length(mresult)}]);
                    %RAW.M = [mresult{2:length(mresult)-1}]; original changed 2013-04-04
                    waitbar(ftell(fid)*.98/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
                else
                    
                    %---separation by dot---
                    %- separation by comma see elseif isempty(FileType)
                    
                    mresult = textscan(fid,'',ceil(filesize/10000));
                    RAW.M = cat(1,RAW.M,[mresult{2:length(mresult)}]);
                    waitbar(ftell(fid)*.98/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
                end
            end
            
            clear M_temp;
            clear mresult;
            T2=(0:1/SaRa:(size(RAW.M,1)/SaRa));
            T=T2(1:(length(T2)-1));
            clear T2
            
            RAW.M = cat(2,EL_NUMS',RAW.M');
            RAW.M = sortrows(RAW.M);
            RAW.M = RAW.M(:,2:size(RAW.M,2));
            RAW.M = RAW.M';
            EL_NAMES = sortrows(EL_NAMES);
            EL_NUMS = sort(EL_NUMS);
            rec_dur = ceil(T(length(T)));
            rec_dur_string = num2str(rec_dur);
            
            
            fclose(fid);                        % close file
            waitbar(1,h,'Complete.'); close(h);
            toc
            
            
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
            is_open = true;
            rawcheck = true;
            
            
            
            %---if file is a spiketrain---
        elseif FileType(1) == 'S'
            
            elresult = textscan(fid,'%5s',61,'whitespace','\b\t','headerlines',2);
            EL_NAMES = [elresult{:}];
            EL_CHAR = char(EL_NAMES);
            if is_open==1
                nr_channel_old = nr_channel;
            end
            nr_channel = size(find(EL_CHAR(:,1)=='E'),1);
            EL_NAMES = EL_NAMES(1:nr_channel);
            EL_CHAR = char(EL_NAMES);
            EL_NUMS=zeros(1,nr_channel);
            
            for n=1:nr_channel
                EL_NUMS(n) = str2double(EL_CHAR(n,4:5));
            end
            fseek(fid,0,'bof');
            
            if file(length(file)-2)=='t'
                mresult = textscan(fid,'',1,'headerlines',4);
                RAW.M = [mresult{1:length(mresult)}];
                %M = [mresult{1:length(mresult)-1}]; original changed
                %2013-04-04
            else
                %---separation by dot---
                mresult = textscan(fid,'',1,'headerlines',4);
                RAW.M = [mresult{1:length(mresult)}];
            end
            
            clear M_temp;
            
            if filesize<10000
                divisor = 1000;
            else
                divisor = 10000;
            end
            
            
            while ftell(fid)<filesize
                if file(length(file)-2)=='t'                                    %txt-file
                    mresult = textscan(fid,'',ceil(filesize/divisor));
                    RAW.M = cat(1,RAW.M,[mresult{1:length(mresult)}]);
                    %M = [mresult{1:length(mresult)-1}]; original changed
                    %2013-04-04
                    waitbar(ftell(fid)*.7/filesize,h,['Please wait - analyzing Spiketrain file...(' int2str(ftell(fid)/1024) ' of ' int2str(filesize/1024),' kByte)']);
                else                                                             %dat-file
                    mresult = textscan(fid,'',ceil(filesize/divisor));
                    RAW.M = cat(1,RAW.M,[mresult{1:length(mresult)}]);
                    waitbar(ftell(fid)*.7/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1024) ' of ' int2str(filesize/1024),' kByte)']);
                end
            end
            
            RAW.M = cat(2,EL_NUMS',RAW.M');
            RAW.M = sortrows(RAW.M);
            RAW.M = RAW.M(:,2:size(RAW.M,2));
            RAW.M = RAW.M';
            EL_NAMES = sortrows(EL_NAMES);
            EL_NUMS = sort(EL_NUMS);
            
            SPIKES_temp=RAW.M/1000;
            SPIKESIZES = zeros(1,nr_channel);
            
            for n = 1:nr_channel                                         %Calculate Spikes per Elektrode
                SPIKESIZES(n) = length(nonzeros(SPIKES_temp(:,n)));
            end
            MaxSpikes = max(SPIKESIZES);
            SPIKES = zeros(MaxSpikes,nr_channel);
            
            for n = 1:size(SPIKES_temp,2)                                          %Calculate Spikes per Elektrode
                if SPIKESIZES(n) ~= 0
                    SPIKES(1:SPIKESIZES(n),n) = nonzeros(SPIKES_temp(:,n));
                end
            end
            
            clear M_temp;
            clear mresult;
            fclose(fid);                        % close file
            T=0:1/SaRa:(ceil(max(SPIKES(:)))-1/SaRa);
            
            
            RAW.M=zeros(size(T,2),nr_channel);
            SP_TWO = round(SPIKES*SaRa);  %round to get integer
            
            for c = 1:nr_channel
                bin = nonzeros(SP_TWO(:,c));
                bin = bin+1;
                RAW.M(bin,c) = -100;
            end
            
            clear bin SP_TWO
            
            rec_dur = ceil(T(length(T)));
            rec_dur_string = num2str(rec_dur);
            
            waitbar(1,h,'Complete.'); close(h);
            spikedata = true;
            SPIKES_OR=SPIKES;
            
            for n = 1:(nr_channel)
                NR_SPIKES(n) = length(find(SPIKES(:,n)));
            end
            
            THRESHOLDS = zeros(1,nr_channel);
            SNR = zeros(1,nr_channel);
            SNR_dB = zeros(1,nr_channel);
            
            
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
            is_open = true;
            spiketraincheck = true;
            
        else
            waitbar(1,h,'Complete.'); close(h);
            msgbox('Unknown fileformat!','Dr.CELLï¿½s hint','help');
            uiwait;
            return
        end
        
        set(findobj(gcf,'Tag','CELL_dataFile'),'String',file);
        set(findobj(gcf,'Tag','CELL_fileInfo'),'String',fileinfo{1});
        
        set(findobj(gcf,'Tag','CELL_dataSaRa'),'String',SaRa);
        set(findobj(gcf,'Tag','CELL_dataNrEl'),'String',nr_channel);
        set(findobj(gcf,'Tag','CELL_dataDate'),'String',Date);
        set(findobj(gcf,'Tag','CELL_dataTime'),'String',Time);
        set(findobj(gcf,'Tag','CELL_dataDur'),'String',rec_dur_string);
        
        delete(findobj(0,'Tag','ShowSpikesBurstsperEL'));
        delete(findobj(0,'Tag','ShowSpikesBurstsperCell'));
        
        if nr_channel>1
            set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
        end
        
        if spiketraincheck == 1
            
            set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
            set(findobj(gcf,'Parent',t3,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t2,'Enable','on'),'Enable','off');
            
            %refresh
            set(findobj(gcf,'Tag','CELL_restoreButton'),'Enable','on')
            set(findobj(gcf,'Tag','CELL_ElnullenButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_invertButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_smoothButton'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_scaleBox'),'value',2,'Enable','off');
            set(findobj(gcf,'Tag','CELL_scaleBoxLabel'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_DefaultBox'),'Enable','on');
            set(findobj(gcf,'Parent',radiogroup2),'Enable','off');
            set(findobj(gcf,'Parent',radiogroup3),'Enable','off');
            set(findobj(gcf,'Tag','Manual_threshold'),'Enable','off')
            set(findobj(gcf,'Tag','time_start'),'Enable','off');
            set(findobj(gcf,'Tag','time_end'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_sensitivityBox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_sensitivityBoxtext'),'Enable','off');
            set(findobj(gcf,'Parent',t5,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t6,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t7,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t8,'Enable','off'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_Autocorrelation'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showSpikesCheckbox'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Value',0,'Enable','off');
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');
            set(findobj(gcf,'Tag','radio_allinone'),'Enable','on');
            set(findobj(gcf,'Tag','radio_fouralltime'),'Enable','on');
            set(findobj(gcf,'Tag','HDredraw'),'Enable','off');
            set(findobj(gcf,'Tag','VIEWtext'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_exportClearedMButton'),'enable','on');
            
            if nr_channel>1
                set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
            end
            
        else
            set(findobj(gcf,'Parent',t3,'Enable','off'),'Enable','on');
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
            set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Value',0,'Enable','off');
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');
            set(findobj(gcf,'Tag','CELL_exportButton'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_exportAllCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showExportCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','radio_allinone'),'Enable','on');
            set(findobj(gcf,'Tag','radio_fouralltime'),'Enable','on');
            set(findobj(gcf,'Tag','HDredraw'),'Enable','off');
            set(findobj(gcf,'Tag','VIEWtext'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_sensitivityBoxtext'),'enable','on');
            set(findobj(gcf,'Tag','headlines'),'enable','on');
            set(findobj(gcf,'Tag','CELL_exportClearedMButton'),'enable','on');
            
            
            if nr_channel>1
                set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
            end
        end
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
        
        % Save Data in RAW structure
        %RAW.M=M;  
        RAW.T=T;
        RAW.rec_dur=rec_dur;
        RAW.SaRa=SaRa;
        RAW.EL_NAMES=EL_NAMES;
        RAW.EL_NUMS=EL_NUMS;
        RAW.nr_channel=nr_channel;
        RAW.Date=Date;
        RAW.Time=Time;
        RAW.fileinfo=fileinfo;
        
    end

% --- Open McRack-file (exported into ASCII) (CN)------------------
    function openMcRackButtonCallback(source,event) %#ok<INUSD>
        
        
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
        Nr_SI_EVENTS    = 0;
        Mean_SIB        = 0;
        Mean_SNR_dB     = 0;
        MBDae           = 0;
        STDburstae      = 0;
        aeIBImean       = 0;
        aeIBIstd        = 0;
        SPIKES          = 0;
        BURSTS          = 0;
        SI_EVENTS       = 0;
        spikedata       = false;
        %M               = 0;
        EL_NUMS         = 0;
        first_open      = false;
        first_open4     = false;
        spiketraincheck = false;
        rawcheck        = false;
        NR_SPIKES       = 0;
        NR_BURSTS       = 0;
        THRESHOLDS      = 0;
        kappa_mean      = 0;
        threshrmsdecide = 1; %As Default setting use rms for threshold calculation
        
        HDrowdata       = false;
        HDspikedata     = false;
        
        % 'Open McRack-File' - Menu
        [file,path] = uigetfile({'*.txt','Data file (*.txt)'},'Open McRack file...');
        if file==0,return,end
        full_path = [path,file];
        disp ('Importing McRack file:'); tic
        h = waitbar(0,'Please wait - importing McRack file...');
        fid = fopen([path file]);
        
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
        %M_OR = RAW.M;                           % Copy of RAW.M
        
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
        set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Value',0,'Enable','off');
        set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');
        set(findobj(gcf,'Tag','CELL_exportButton'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_exportAllCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_showExportCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','radio_allinone'),'Enable','on');
        set(findobj(gcf,'Tag','radio_fouralltime'),'Enable','on');
        set(findobj(gcf,'Tag','HDredraw'),'Enable','off');
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

% --- Analysis of network bursts from xls.-Dateien (CN)-----------------
    function AnalyseNetworkburstxls(source,event) %#ok<INUSD>
        [file,path] = uigetfile({'*.xls','DR_CELL Reportdatei (*.xls)'},...
            'Reportdateien auswï¿½hlen...','MultiSelect','on');
        if file==0,return,end
        h_bar=waitbar(0.05,'Please wait - importing data file...');
        
        if iscell(file)==0
            numberfiles = 1;
        else
            numberfiles = length(file);
        end
        
        MinDuration(1:numberfiles) = 0;
        MaxDuration(1:numberfiles) = 0;
        MeanDuration(1:numberfiles) = 0;
        stdMeanDuration(1:numberfiles) = 0;
        MinRise(1:numberfiles) = 0;
        MaxRise(1:numberfiles) = 0;
        Meanrise(1:numberfiles) = 0;
        stdMeanRise(1:numberfiles) = 0;
        MinFall(1:numberfiles) = 0;
        MaxFall(1:numberfiles) = 0;
        Meanfall(1:numberfiles) = 0;
        stdMeanFall(1:numberfiles) = 0;
        waitbarcounter = 0.05;
        ORDER = 0;
        
        waitbar(0.05,h_bar,'Please wait - networkbursts are analysed...');
        %read duration
        for h=1:numberfiles
            if iscell(file)==0
                DUR_REC = xlsread([path file], 'Tabelle1','D6');
                T = 0:0.0002:(DUR_REC-0.0002);
                BIG = DUR_REC/0.0002;
                
                WORKSPACE = xlsread([path file], 'Tabelle1');
                BURSTS=WORKSPACE(30:size(WORKSPACE,1),:);
                clear WORKSPACE;
                [nums, txt] = xlsread([path file], 'Tabelle2'); %read file
                SPIKES = nums;
                EL_NAMES = txt(:,4:length(txt));
            else
                DUR_REC = xlsread([path file{h}],'Tabelle1','D6');
                T = 0:0.0002:(DUR_REC-0.0002);
                BIG = DUR_REC/0.0002;
                
                WORKSPACE = xlsread([path file{h}], 'Tabelle1');
                BURSTS=WORKSPACE(30:size(WORKSPACE,1),:);
                clear WORKSPACE;
                SPIKES = xlsread([path file{h}],'Tabelle2');
            end
            
            waitbarcounter= waitbarcounter + 0.9/(8*numberfiles);
            waitbar(waitbarcounter)
            
            sync_time = int32(.04*SaRa);                    % timeperiod in which events are considered symultanous:
            max_time = int32(.4*SaRa);                      % interval in which the maximum is checked:
            wait_time = int32(.5*SaRa);                     % minimum time between to events:
            
            ELECTRODE_ACTIVITY = zeros(BIG,60);
            ACTIVITY = zeros(1,BIG);
            
            for i = 1:size(BURSTS,2)                        % for each burst...
                for j = 1:length(nonzeros(BURSTS(:,i)))
                    pos = int32(BURSTS(j,i)*SaRa);
                    
                    if (pos>sync_time && pos<length(ACTIVITY)-sync_time)         % neglect first and last 100 Samples
                        ELECTRODE_ACTIVITY(pos-sync_time:pos+sync_time,i) = 1;
                    end
                end
            end
            
            ACTIVITY = sum(ELECTRODE_ACTIVITY,2);
            clear ELECTRODE_ACTIVITY;
            
            waitbarcounter= waitbarcounter + 0.9/(8*numberfiles);
            waitbar(waitbarcounter)
            
            %Calculate the propagation of networkburst
            i = 1; k = 1;
            while i <= length(ACTIVITY)
                if i+max_time < length(ACTIVITY)
                    imax = i+max_time;
                else
                    imax = length(ACTIVITY);
                end
                
                if ACTIVITY(i)>=5
                    [~,I] = max(ACTIVITY(i:imax));
                    maxlength = 0;
                    while ACTIVITY(i+I)==ACTIVITY(i+I+1)
                        maxlength = maxlength+1;
                        I = I+1;
                    end
                    I = I-int32(maxlength/2);
                    SI_EVENTS(k) = T(i+I);
                    k = k+1;
                    i = i+I+wait_time;
                end
                i = i+1;
            end
            Nr_SI_EVENTS = size(SI_EVENTS,2);
            if (Nr_SI_EVENTS == 1) && (SI_EVENTS(1)==0)
                Nr_SI_EVENTS =0;
            end
            
            waitbarcounter= waitbarcounter + 0.9/(8*numberfiles);
            waitbar(waitbarcounter)
            %Smooth the histogram
            [b,a] = butter(3,400*2/SaRa,'low');
            ACTIVITY = filter(b,a,ACTIVITY);
            
            waitbarcounter= waitbarcounter + 0.9/(8*numberfiles);
            waitbar(waitbarcounter)
            %Calculate slopes and duration
            for k=1:Nr_SI_EVENTS
                MAX(k) = ACTIVITY(int32(SI_EVENTS(k)*SaRa));
                UG(k) = 0.2*MAX(k);
                OG(k)= 0.8*MAX(k);
                
                countlimit(k)=0;
                for q=1:(10*wait_time)
                    if ACTIVITY(int32(SI_EVENTS(k)*SaRa-q))<0.5
                        countlimit(k)=int32(SI_EVENTS(k)*SaRa-q);
                        if countlimit(k)<= 0
                            countlimit(k) = 1;
                        end
                        break
                    end
                end
                
                for p=1:int32(SI_EVENTS(k)*SaRa-countlimit(k))
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
                
                Duration(k)= time20_nach(k)-time20_vor(k);
                Rise(k) = time80_vor(k)-time20_vor(k);
                Fall(k) = time20_nach(k)-time80_nach(k);
            end
            
            waitbarcounter= waitbarcounter + 0.9/(8*numberfiles);
            waitbar(waitbarcounter)
            
            if SI_EVENTS ~= 0
                MinDuration(h) = min(Duration);
                MaxDuration(h) = max(Duration);
                MeanDuration(h) = mean(Duration);
                stdMeanDuration(h) = std(Duration);
                MinRise(h) = min(Rise);
                MaxRise(h) = max(Rise);
                Meanrise(h) = mean(Rise);
                stdMeanRise(h) = std(Rise);
                MinFall(h) = min(Fall);
                MaxFall(h) = max(Fall);
                Meanfall(h) = mean(Fall);
                stdMeanFall(h) = std(Fall);
                
                clear Duration;
                clear Rise;
                clear Fall;
            end
        end
        
        %Calculate signal propagation time
        if numberfiles == 1
            ORDER = cell(size(BURSTS,2),size(SI_EVENTS,2));
            BURSTTIME = zeros(size(BURSTS,2),size(SI_EVENTS,2));
            if SI_EVENTS ~= 0
                for n=1:size(SI_EVENTS,2)           %for each SBE
                    eventpos = int32(SI_EVENTS(n)*SaRa);
                    eventbeg=double(eventpos);
                    
                    while ACTIVITY(eventbeg) >= 1           %find beginning of SI_Events
                        eventbeg = eventbeg-1;
                    end
                    
                    eventtime = eventbeg/SaRa;
                    xy = 0;
                    yz = 1;
                    t=1;
                    tol=1/(SaRa*2);
                    
                    while(xy<=0.4)
                        zz=1;
                        [row,col] = find((BURSTS<(eventtime+xy+tol))&(BURSTS>(eventtime+xy-tol)));
                        
                        if isempty(col)
                        else
                            while zz<=length(col)                                  %in case two bursts happen at the same time
                                ORDER(yz,n) = EL_NAMES(col(zz));
                                BURSTTIME(yz,n) = BURSTS(row(zz),col(zz));
                                yz = yz+1;                                             %next Burst
                                zz=zz+1;
                            end
                        end
                        t=t+1;
                        xy = xy+1/SaRa;
                    end
                end
            end
        end
        
        waitbar(1,h_bar,'Complete.'); close(h_bar);
        set(findobj(gcf,'Tag','CELL_exportNWBButton'),'Enable','on');
        
        if ((iscell(file)==0) && (SI_EVENTS(1)~=0))
            mainNWB = figure('Position',[150 100 1000 500],'Name','Networkbursts','NumberTitle','off','Resize','off');
            subplot(2,1,1);
            plot(T,ACTIVITY)
            axis([0 T(size(T,2)) -10 60])
            xlabel ('Zeit / s');
            ylabel({'number of active electrodes (blue)';'Maximum/Peak (green)'});
            title('Networkactivity','fontweight','b')
            
            for n=1:length(SI_EVENTS)   %draws the maxima into a figure
                line ('Xdata',[SI_EVENTS(n) SI_EVENTS(n)],'YData',[-10 60],'Color','green');
            end
            
            %rising slope
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
            
            %falling slope
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
            
            %Duration
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

% --- Switch Electrode positions (needed for files recorded with wrong Labview configuration) (MC)---------
    function SwitchElectrodesCallback(~,~)
        RAW.M = switchElectrodes(RAW.M);
    end

% --- Import File - load a raw-file or spiketrain-file ( .brw .bxr ) (Sh.Kh) --------
    function openButtonCallback (~,~)
        clear Energy Variance;
        SPIKES3D = [];
        SPIKES   = [];
        SPIKEZ   = [];
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
        handler;
        Nr_SI_EVENTS    = 0;
        Mean_SIB        = 0;
        Mean_SNR_dB     = 0;
        MBDae           = 0;
        STDburstae      = 0;
        aeIBImean       = 0;
        aeIBIstd        = 0;
        SPIKES          = 0;
        BURSTS          = [];
        SI_EVENTS       = 0;
        spikedata       = false;
      %  M               = 0;
        EL_NUMS         = 0;
        first_open      = false;
        first_open4     = false;
        spiketraincheck = false;
        rawcheck        = false;
        NR_SPIKES       = 0;
        NR_BURSTS       = 0;
        THRESHOLDS      = 0;
        kappa_mean      = 0;
        threshrmsdecide = 1; %As Default setting use rms for threshold calculation
        varT            = 0;
        varTdata        = 0;
        
        cellselect      = 1; %???
        
        % use path of last loaded file if exist
        if path ~= 0
            cd(path)
        end
        
        % 'Open file' - Window
       % openfiles
               % 'Open file' - Window
        [file,path] = uigetfile({%'*.mat','RAW or ST file (*.mat)'; ...
%                                 '*_RAW.mat','Raw data file (*_RAW.mat)'; ...
%                                 '*_ST.mat','Spiketrain file (*_ST.mat)'; ...
                                '*.bxr','ST file (*.bxr)'; ...
                                '*.brw','Raw data file (*.brw)'; ...
                                '*.*',  'All Files (*.*)'},'Select one File with raw data or spiketrains.','MultiSelect','off');
        if not(iscell(file)) && not(ischar(file)) % if canceled - dont do anything
            return
        end
        
        % get file extension 
        [~,~,ext] = fileparts(file); 
        
        % if .mat file is selected, load it directly
%         if strcmp(ext,'.mat')
%             openMatButtonCallback
%         end
        % if .brw (HD-Raw) file is selected, load it directly
        if strcmp(ext,'.brw')
            ImportbrwFileCallback            
        end
        % if .bxr (HD-Spike) file is selected, load it directly
        if strcmp(ext,'.bxr')
            ImportbxrFileCallback  
        end
    end

% --- Import HDMEA Raw Data (Sh.Kh) ------------------------------------------
    function ImportbrwFileCallback(~,~)
    clear Energy Variance;
    SPIKES3D = [];
    SPIKES = [];
    SPIKEZ = [];
    M_OR = []; % used in function: SixWellButtonCallback
    BURSTS.BEG = [];
    BURSTS.END = [];
    SubmitSorting = 0; % Sorting Variable is reset
    SPIKES_Class = [];
    ELEC_CHECK = [];
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
    nr_channel      =0;
    first_open      = false;
    first_open4     = false;
    spiketraincheck = false;
    rawcheck        = false;
    NR_SPIKES       = 0;
    BURSTS.BRn      = 0;
    THRESHOLDS      = 0;
    kappa_mean      = 0;
    threshrmsdecide = 1; %As Default setting use rms for threshold calculation
    varT            = 0;
    varTdata        = 0;  
    RAW             = 0;  
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
    HDrowdata       = true;       
    if path ~= 0
        cd(path)
    end     
% % 'Open file' - Window
%     [file,path] = uigetfile({'*.brw','Raw data file (*.brw)'; ...
%                            },'Select one .brw-file with raw data.','MultiSelect','off');
%     if not(iscell(file)) && not(ischar(file)) % if canceled - dont do anything
%         return
%     end 
% Import Data   
    MaxVolt = h5read(file,'/3BRecInfo/3BRecVars/MaxVolt');
    f=msgbox('  Importing raw file ...');
    set(0, 'currentfigure', mainWindow);  % set main window as current figure
    
    data2 = h5read(file,'/3BData/Raw');   
    NRecFrames = h5read(file,'/3BRecInfo/3BRecVars/NRecFrames');
    BitDepth = h5read(file,'/3BRecInfo/3BRecVars/BitDepth');
    MinVolt = h5read(file,'/3BRecInfo/3BRecVars/MinVolt');
    SamplingRate = h5read(file,'/3BRecInfo/3BRecVars/SamplingRate');
    NCols = h5read(file,'/3BRecInfo/3BMeaChip/NCols');
    NRows = h5read(file,'/3BRecInfo/3BMeaChip/NRows');
    SignalInversion = h5read(file,'/3BRecInfo/3BRecVars/SignalInversion');
    NCols=double(NCols);
    NCh=double(NCols*NRows);
    %NRecFrames = h5read (file,'/3BRecInfo/3BRecVars/NRecFrames');
    Chs = h5read (file,'/3BRecInfo/3BMeaStreams/Raw/Chs');
    m=zeros(NRecFrames,NCh); 
    m= reshape(data2,[NCh,NRecFrames]);
    m=m';
    clear data2;
    BitDepth= double(BitDepth);

%      %Convert Analog Values to Microvolt
%       m=double(m);
%       if MaxVolt==-MinVolt
%          m=SignalInversion*(m-(2^BitDepth)/2)*(MaxVolt*2/2^BitDepth);
%       end      

    NRecFrames=double(NRecFrames);
    rec_dur =double(NRecFrames/SamplingRate);
    SaRa = fix(SamplingRate);
    NRecFrames=double(NRecFrames);
    T = 0:(1/SamplingRate):((NRecFrames-1)/SamplingRate);
    j=0;
    for i=1:NRows
        Ch(1,(j+1):(j+NCols))=i;
        j=j+NCols;
    end
    j=0;
    for i=1:NRows
        Ch(2,(j+1):(j+NCols))=1:NCols;
        j=j+NCols;
    end
    for i=1:NCh
        Ch(3,i)= ((Ch(1,i)-1)*64)+Ch(2,i); 
    end
    ROW=Ch(1,:);
    COL=Ch(2,:);
    for i=1:NCh
        s=strcat('El: ', num2str(ROW(i)), ',', num2str(COL(i)));
        ss{i}=s;
    end
    %Ch=Ch'; % Ch(:,1)=ROW , Ch(:,2)=COL , Ch(:,3)=ChID 
    EL_NUMS=Ch(3,:);
    EL_NAMES=ss;
    temp.M= struct([]); 
    RAW=temp;
    RAW.M=m; 
    RAW.T=T;
    RAW.rec_dur=rec_dur;
    RAW.SaRa=SaRa;
    RAW.nr_channel=size(RAW.M,2);
    RAW.EL_NAMES=EL_NAMES;
    RAW.EL_NUMS=EL_NUMS;
    RAW.Date=0;
    RAW.Time=0;
    RAW.fileinfo=' ';
    fileinfo  =RAW.fileinfo;
    nr_channel=NCh;
    RAW.nr_channel=nr_channel;
    RAW.MaxVolt=MaxVolt;
    RAW.MinVolt=MinVolt;
    RAW.BitDepth=BitDepth;
    RAW.SignalInversion=SignalInversion;

    %Settings:   
    set(findobj(gcf,'Tag','CELL_dataFile'),'String',file);
    set(findobj(gcf,'Tag','CELL_dataSaRa'),'String',SaRa);
    set(findobj(gcf,'Tag','CELL_dataDate'),'String',Date);
    set(findobj(gcf,'Tag','CELL_dataTime'),'String',Time);
    set(findobj(gcf,'Tag','CELL_dataDur'),'String',rec_dur_string); 
    delete(findobj(0,'Tag','ShowSpikesBurstsperEL'));
    delete(findobj(0,'Tag','ShowSpikesBurstsperCell'));

    if nr_channel>1
        set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
    end  
    set(findobj(gcf,'Parent',t3,'Enable','off'),'Enable','on');
    uicontrol('Parent',t3,'Units','pixels','Position',[120 62 30 20],'style','edit','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','9999','Tag','STD_noisewindow');
    set(findobj(gcf,'Parent',t3,'Tag','CELL_sensitivityBox_pos'),'Enable','off');
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
    set(findobj(gcf,'Tag','radio_allinone'),'Value',0,'Enable','off');
    set(findobj(gcf,'Tag','radio_fouralltime'),'Value',0,'Enable','off');
    set(findobj(gcf,'Tag','HDredraw'),'Value',1,'Enable','on');
    set(findobj(gcf,'Tag','VIEWtext'),'Enable','on');
    set(findobj(gcf,'Tag','CELL_sensitivityBoxtext'),'enable','on');
    set(findobj(gcf,'Tag','headlines'),'enable','on');
    set(findobj(gcf,'Tag','CELL_exportClearedMButton'),'enable','on');    
    if nr_channel>1
        set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
    end
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

  %redraw:
    HDredraw
    is_open = true;
    rawcheck = true;
    delete(f)
    msgbox('Your Data has been imported successfully','Success');
end
        
% --- Import HDMEA Spike Data (Sh.Kh) ------------------------------------------
    function ImportbxrFileCallback(~,~)

        SPIKEZ = [];
        M_OR = []; % used in function: SixWellButtonCallback
        BURSTS.BEG = [];
        BURSTS.END = [];
        BURSTS = [];
        nr_channel      = 0;
        rawcheck        = false;   
        BURSTS.BRn      = 0;
        RAW             = 0;  
        rec_dur         = 0;  
        SaRa            = 0;  
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
        HDspikedata     = true;
        HDrowdata       = 0;
        spiketraincheck = true;
        if path ~= 0
            cd(path)
        end
               
    % Import Spike Data     
        %MaxVolt = h5read(file,'/3BRecInfo/3BRecVars/MaxVolt');
        %MinVolt = h5read(file,'/3BRecInfo/3BRecVars/MinVolt');
        SpikeChIDs=h5read(file,'/3BResults/3BChEvents/SpikeChIDs');
        f=msgbox('  Importing Spiketrain file ...');
        set(0, 'currentfigure', mainWindow);  % set main window as current figure
        SpikeChIDs=h5read(file,'/3BResults/3BChEvents/SpikeChIDs'); 
        SpikeTimes=h5read(file,'/3BResults/3BChEvents/SpikeTimes');
        MeaChs2ChIDsMatrix=h5read(file,'/3BResults/3BInfo/MeaChs2ChIDsMatrix');
        %ChIDs2Labels=h5read(file,'/3BResults/3BInfo/ChIDs2Labels');
        ChIDs2NSpikes=h5read(file,'/3BResults/3BInfo/3BSpikes/ChIDs2NSpikes');
        NRecFrames=h5read(file,'/3BRecInfo/3BRecVars/NRecFrames');
        SamplingRate=h5read(file,'/3BRecInfo/3BRecVars/SamplingRate');
        %BitDepth = h5read(file,'/3BRecInfo/3BRecVars/BitDepth');
        NCols = h5read(file,'/3BRecInfo/3BMeaChip/NCols');
        NRows = h5read(file,'/3BRecInfo/3BMeaChip/NRows');
        NCols=double(NCols);
        NCh=double(NCols*NRows);   % EL#
        
    % Create El_NUMS and EL_NAMES     
        j=0;
        for i=1:NRows %
            Ch(1,(j+1):(j+NCols))=i;
            j=j+NCols;
        end
        j=0;
        for i=1:NRows
            Ch(2,(j+1):(j+NCols))=1:NCols;
            j=j+NCols;
        end
        for i=1:NCh
            Ch(3,i)= ((Ch(1,i)-1)*64)+Ch(2,i); 
        end
        ROW=Ch(1,:);
        COL=Ch(2,:);
        for i=1:NCh
            s=strcat('El: ', num2str(ROW(i)), ',', num2str(COL(i)));
            ss{i}=s;
        end
         
        EL_NUMS=Ch(3,:);
        EL_NAMES=ss;
%        Ch=Ch'; % Ch(:,1)=ROW , Ch(:,2)=COL , Ch(:,3)=ChID 
    
    % Create Cell Array 
        TSC={};
        for i=1:NCh 
            a=find(SpikeChIDs==i-1);%  CH nummer ( 0 bis 4095 ) ist
            for ii=1:size(a,1)
              b(ii,1)=SpikeTimes(a(ii,1)); 
            end
            if size(a,1)>0
                b=double(b);  
                b= (b/SamplingRate);
                TSC(1,i)={b};
            end
            a=0;
            b=0;
        end 
        
   % Create TS for Spikes Sh.Kh
        %MeaChs2ChIDsMatrix2=MeaChs2ChIDsMatrix';    
        %SPIKESHD=zeros(max(ChIDs2NSpikes),NCh);
        for i=1:NCh 
            a=find(SpikeChIDs==i-1); %  CH nummer ( 0 bis 4095 ) ist
            for ii=1:size(a,1)
              TS(ii,i)=SpikeTimes(a(ii,1)); 
            end
        end
        TS= double(TS/SamplingRate);
         temp.M= struct([]); 
         RAW=temp;
         NRecFrames=double(NRecFrames);
         T = 0:(1/SamplingRate):((NRecFrames-1)/SamplingRate);
         RAW.T=T;
         rec_dur=double(NRecFrames/SamplingRate);
         SaRa=fix(SamplingRate);
         SPIKEZ.TS=TS;
         SPIKEZ.TSC=TSC;
         SPIKEZ.N=ChIDs2NSpikes;
         SPIKEZ.PREF.rec_dur=rec_dur;
         SPIKEZ.PREF.nr_channel = NCh;
         nr_channel = SPIKEZ.PREF.nr_channel;
         SPIKEZ.PREF.fileinfo='';
         fileinfo = SPIKEZ.PREF.fileinfo;
         SPIKEZ.AMP = [];
         SPIKEZ.neg.flag=1;
         SPIKEZ.pos.flag=0;
         SPIKEZ.neg.TS=TS;
         SPIKEZ.neg.AMP=SPIKEZ.AMP;
         SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);         
      % old_parameter
         temp.M= struct([]); 
         SPIKES=temp;
         SPIKES=SPIKEZ.TS; % SPIKES, AMPLITUDES, rec_dur, SaRa, EL_NUMS, optional: fileinfo, Time, Date
         NR_SPIKES=SPIKEZ.N;
          
      % Settings:
    
        set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Parent',t3,'Enable','on'),'Enable','off');
        set(findobj(gcf,'Parent',t2,'Enable','on'),'Enable','off');
        set(findobj(gcf,'Parent',t5),'Enable','on');
        set(findobj(gcf,'Parent',t6),'Enable','on');
        set(findobj(gcf,'Parent',t7),'Enable','on');
        set(findobj(gcf,'Tag','Spike_Box'),'value',0,'Enable','off');
        set(findobj(gcf,'Tag','Spike2_Box'),'value',0,'Enable','off');
        set(findobj(gcf,'Tag','CELL_restoreButton'),'Enable','on')
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
        set(findobj(gcf,'Tag','radio_allinone'),'Value',0,'Enable','off');
        set(findobj(gcf,'Tag','radio_fouralltime'),'Value',0,'Enable','off');
        set(findobj(gcf,'Tag','HDredraw'),'Value',1,'Enable','on');
        set(findobj(gcf,'Tag','VIEWtext'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_exportClearedMButton'),'enable','on');

        if nr_channel>1
            set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
        end

     % Electrode Selection
        delete(findobj('Tag','S_Elektrodenauswahl'));
        uicontrol('Parent',t6,'Units','Pixels','Position',[700 12 50 51],'Tag','S_Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Enable','off','Value',1,'Style','popupmenu','callback',@recalculate);
        SubmitSorting(1:nr_channel) = zeros;
        
        preti = (0.5:1000/SaRa:2);
        postti = (0.5:1000/SaRa:2);
        
        delete(findobj('Tag','S_pretime'));
        delete(findobj('Tag','S_posttime'));
        uicontrol('Parent',t6,'Units','Pixels','Position',[700 65 50 30],'Tag','S_pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','Enable','off','callback',@recalculate);
        uicontrol('Parent',t6,'Units','Pixels','Position',[760 65 50 30],'Tag','S_posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','Enable','off','callback',@recalculate);

        HDredraw
        is_open = true;
        rawcheck = true;
        delete(f)
        msgbox('Your Data has been imported successfully','Success');   
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
        
        %M = filter(Hd,M);
        
        if size(MM,2)<=60  %for .mat Data
            MM = filter(Hd,MM);
        else
            j=1;  % bei kleinem Arbeitsspeicher muss j kleiner werden
            if HDrowdata ==1     % for .brw Data
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
                        m=(m/(RAW.MaxVolt*2/2^RAW.BitDepth))+((2^RAW.BitDepth)/2);
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

% --- bandstop filter (Sh.Kh)----------------------------------------------
    function bandstop(~)
        
        MM=RAW.M;
        waitbar_counter = waitbar_counter + waitbaradd;
        waitbar(waitbar_counter);
        
        if str2double(get(findobj('Tag','CELL_low_edit'),'string'))== 0 % in case that lower boundary equals zero use highpass instead of bandstop
            [z,p,k] = cheby2(3,20,str2double(get(findobj('Tag','CELL_high_edit'),'string'))*2/SaRa,'high');
            [sos,g] = zp2sos(z,p,k);			% Convert to SOS form
            Hd = dfilt.df2tsos(sos,g);
        else
            [z,p,k] = cheby2(3,20,[str2double(get(findobj('Tag','CELL_low_edit'),'string'))*2/SaRa str2double(get(findobj('Tag','CELL_high_edit'),'string'))*2/SaRa],'stop');
            [sos,g] = zp2sos(z,p,k);			% Convert to SOS form
            Hd = dfilt.df2tsos(sos,g);
        end
        
       % M = filter(Hd,M);
       
       if size(MM,2)<=60    %for .mat Data
            MM = filter(Hd,MM);
        else
            [~,systemview] = memory;
            if systemview.PhysicalMemory.Total>=((3/4)*systemview.PhysicalMemory.Available)% When enough memory is available
                j=1200;
            else
                j=1;
            end% bei kleinem Arbeitsspeicher muss j kleiner werden
            if HDrowdata ==1   || size(MM,2)>60  % for .brw Data
                for i=0:+j:(floor(numel(MM(1,:))/j)-1)*j
                    if HDrowdata ==1
                        m=digital2analog_sh(MM(:,i+1:i+j),RAW);         
                        m(m<-4000)=0;
                        m(m>4000)=0;
                        m=(filter(Hd,m));
                        m=RAW.SignalInversion*(m/(RAW.MaxVolt*2/2^RAW.BitDepth))+((2^RAW.BitDepth)/2); % %convert analog values to digital sample Values 
                        MM(:,i+1:i+j)=m;
                    else %for .mat Data mit  El > 60
                        m = MM(:,i+1:i+j);
                        m = filter(Hd,m);
                        MM(:,i+1:i+j) = single(m);
                    end
                end
                i=i+j; 
                if i<size(MM,2)
                    clear m;
                    if HDrowdata ==1
                        m=(MM(:,i+1:size(MM,2)));
                        m=digital2analog_sh(m,RAW);
                        m(m<-4000)=0;
                        m(m>4000)=0;
                        m=(filter(Hd,m));
                        m=(m/(RAW.MaxVolt*2/2^RAW.BitDepth))+((2^RAW.BitDepth)/2); % %convert analog values to digital sample Values 
                        MM(:,i+1:size(MM,2))=m;
                    else %for .mat Data mit  El > 60
                        m=(MM(:,i+1:size(MM,2)));
                        m = filter(Hd,m);
                        MM(:,i+1:size(MM,2))=m;
                    end
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

d  = fdesign.notch('N,F0,Q,Ap',6,0.5,10,1);

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
            if ((max(BEGTEST)>PREF(10) )||(min(BEGTEST)<-(PREF(10))))
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
        
        if str2double(get(findobj('Tag','CELL_low_edit'),'string')) == str2double(get(findobj('Tag','CELL_high_edit'),'string')) % use notch filter if upper and lower boundary have the same value
            notchfilter;
            SPIKEZ.FILTER.Name='notchfilter';
        else
            if PREF(12)
               %RAW= bandstop(RAW);
               bandstop;
               SPIKEZ.FILTER.Name='bandstop';
            end
            
            if PREF(13)
%                RAW= bandpass(RAW);
                bandpass;
                SPIKEZ.FILTER.Name='bandpass';
            end
        end
        waitbar(1); close(h_wait);
        waitbar_counter=0;
        
        if stimulidata
            figure (mainWindow);
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_ShowZeroOutExample'),'Enable','on');
        else
            BEG = 0;
            END = 0;
        end
        redrawdecide;
    end

% --- Zero Els - Popup-Menu (CN)---------------------------------------
    function ELnullenCallback(source,event) %#ok<INUSD>
        allorone = 0;
        fh = figure('Units','Pixels','Position',[350 400 300 280],'Name','select electrodes','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 155 265 100],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'String','the signal of the selected electrodes is clear for the entire recording time. More than one electrode have to be separated be space.');
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 120 80 20],'HorizontalAlignment','left','BackgroundColor', GUI_Color_BG,'FontSize',9,'Tag','CELL_electrodeLabel','String','electrode');
        uicontrol('Parent',fh,'style','edit','units','Pixels','position', [20 100 260 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','CELL_electrode','string','');
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[175 20 110 50],'String','apply','ToolTipString','clears the signals of selected electrodes now','CallBack',@ELnullencallfunction);
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[20 20 110 50],'String','all or none','ToolTipString','clears the signals of selected electrodes now','CallBack',@Allornonecallfunction);
    end

% --- Read Zero Els (CN)-----------------------------------------------
    function ELnullencallfunction(source,event) %#ok<INUSD>
        correctcheck = 1;
        EL_Auswahl = get(findobj(gcf,'Tag','CELL_electrode'),'string');
        ELEKTRODEN = textscan(EL_Auswahl) ;
        for n = 1:length(ELEKTRODEN)
            i = find(EL_NUMS==ELEKTRODEN(n)); %#ok
            if isempty(i)
                correctcheck = 0; %#ok
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELLï¿½s hint','help');
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
                BURSTS(:,i)=0;
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
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELLï¿½s hint','help');
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
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELLï¿½s hint','help');
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
    function preprocessingempty1Callback(~,~)
        
        msgbox('coming soon ;)','Out of order');
        
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
        BURSTS          = 0;
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
            msgbox('This Dr. Cell Version does not have a copy of the orignial Signal to speed up the process. If this function is necesarry please uncomment "M_OR" in sourcecode','Dr.CELLï¿½s hint','help');
            uiwait;
        elseif spiketraincheck == 1
            SPIKES = SPIKES_OR;
            set(findobj(gcf,'Parent',t3,'Enable','off'),'Enable','on');
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
            set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Value',0,'Enable','off');
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
            'String','The spike detection algorithm works in four steps, which are summarized here and the first steps explained in detail below: i. A time frame of two seconds on each electrode containing only pure noise is detected. ii.	From this frame the root mean square (rms) value and the standard deviation are calculated. iii.	These values are then multiplied with a negative factor. As a default value a multiple of the rms is used as a threshold, alternatively a multiple of the standard deviation can be chosen instead. iv.	The absolute minimum of every voltage peak that is lower than the threshold is saved as the respective spikeï¿½s timestamp.');
        
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

    function activatePosTh(~,~)
        if get(findobj(gcf,'Tag','posThCheckbox'),'Value')==1
            set(findobj(gcf,'Tag','CELL_sensitivityBox_pos'),'enable','on');
        else
            set(findobj(gcf,'Tag','CELL_sensitivityBox_pos'),'enable','off');
        end
    end

% --- Calculate Button - Calculate Threshold (CN)----------------------
    function CalculateThreshold(~,~)
        THRESHOLDS = 0;
        ELEC_CHECK = 0;
        waitbar_counter2 = 0.05;
        PREF(1) = str2double(get(findobj(gcf,'Tag','CELL_sensitivityBox'),'string'));            % Threshold
        ST=str2double(get(findobj(gcf,'Tag','STD_noisewindow'),'string'));
        PREF(15) =ST(1);                 %get value for STD to find spike-free windows
        PREF(16) = str2double(get(findobj(gcf,'Tag','Size_noisewindow'),'string'))/1000;       %get windowsize to find spike-free windows
        PREF(17) = str2double(get(findobj(gcf,'Tag','CELL_sensitivityBox_pos'),'string'));       %get factor for positive threshold
                
        % save parameter in spiketrain file:
        SPIKEZ.neg.THRESHOLDS.Multiplier=PREF(1);
        SPIKEZ.neg.THRESHOLDS.Std_noisewindow=PREF(15);
        SPIKEZ.neg.THRESHOLDS.Size_noisewindow=PREF(16);
        
        SPIKEZ.pos.THRESHOLDS.Multiplier=PREF(17);
        SPIKEZ.pos.THRESHOLDS.Std_noisewindow=PREF(15);
        SPIKEZ.pos.THRESHOLDS.Size_noisewindow=PREF(16);
        
        % init
        SPIKEZ.neg.THRESHOLDS.Th=[];
        SPIKEZ.pos.THRESHOLDS.Th=[];
        
        h_wait = waitbar(.05,'Please wait - Thresholds are calculated...');
        multiplier = PREF(1);
        disp ('Analysing...');
        
        window_beg = 0.01*SaRa+1;
        window_end = (0.01+PREF(16))*SaRa;
        nr_win = 0;
        calc_beg = 1;
        calc_end = PREF(16)*SaRa;
        
        CALC = zeros((2*SaRa),(size(RAW.M,2)));
        SNR = zeros(1,size(RAW.M,2));
        SNR_dB = zeros(1,size(RAW.M,2));

        if auto
            for n=1:size(RAW.M,2)
                if  HDrowdata==1 %Sh_Kh for .brw Data
                    m = digital2analog_sh(RAW.M(:,n),RAW);
                else
                    m=RAW.M;
                end  
                while nr_win < (2/PREF(16))             % use two secondes of the signal
                    
                    %calculate STD in windows
                    if  HDrowdata==1 %Sh.Kh for .brw Data
                        [~,sigma] = normfit(m(window_beg:window_end)); %if you have the Statistics-Toolbox you can use "normfit" as well
                    else
                        [~,sigma] = normfit(m(window_beg:window_end,n)); %if you have the Statistics-Toolbox you can use "normfit" as well
                    end
                    
                    if((sigma < PREF(15)) && (sigma > 0))
                        if  HDrowdata==1 %Sh.Kh for .brw Data
                            CALC(calc_beg:calc_end,n) = m(window_beg:window_end);
                        else
                            CALC(calc_beg:calc_end,n) = m(window_beg:window_end,n);
                        end
                        calc_beg = calc_beg + PREF(16)*SaRa;
                        calc_end = calc_end + PREF(16)*SaRa;
                        window_beg = window_beg + PREF(16)*SaRa;
                        window_end = window_end + PREF(16)*SaRa;
                        
                        if window_end>size(T,2) break; end %#ok
                        
                        ELEC_CHECK(n) = 1;
                        nr_win = nr_win + 1;
                        
                    else
                        window_beg = window_beg + PREF(16)/2*SaRa;
                        window_end = window_end + PREF(16)/2*SaRa;
                        
                        if window_end>size(T,2) break; end %#ok
                        
                        if ((window_beg > 0.5*size(T,2)) && (nr_win == 0))
                            ELEC_CHECK(n) = 0; %noisy
                            break
                        end
                    end
                end
                
                nr_win = 0;
                window_beg = 0.01*SaRa+1;
                window_end = (0.01+PREF(16))*SaRa;
                calc_beg = 1;
                calc_end = PREF(16)*SaRa;
                if HDrowdata ==1 || size(RAW.M,2)>60
                    if n==1000 || n==2000 || n==3000 || n==4000
                        waitbar_counter2 = waitbar_counter2+n*(0.7/nr_channel);
                        waitbar(waitbar_counter2,h_wait);
                    end
                else
                    waitbar_counter2 = waitbar_counter2+(0.7/nr_channel);
                    waitbar(waitbar_counter2,h_wait);
                end

            end
            COL_RMS = sqrt(mean(CALC.^2));
            COL_SDT = std(CALC);

        elseif auto == 0                    %Manu
            waitbar(.6,h_wait,'Please wait - Thresholds are calculated...');
            for n=1:size(RAW.M,2)
                if  HDrowdata==1 %Sh.Kh for .brw Data
                    m = digital2analog_sh(RAW.M(:,n),raw);
                else
                    m=RAW.M;
                end             
                if (PREF(3)-rec_dur<1) && (PREF(2) == 0)
                    COL_RMS = sqrt(mean(m.^2));                 % RMS
                    COL_SDT = std(m);

                else
                    start = PREF(2)*SaRa+1;
                    finish = PREF(3)*SaRa;
                    COL_RMS = sqrt(mean(m(start:finish,:).^2)); % RMS
                    COL_SDT = std(m(start:finish,:));
                end
                if HDrowdata==0; break; end
            end
        end
        
        if threshrmsdecide
            THRESHOLDS = -multiplier.*COL_RMS;
        else
            THRESHOLDS = -multiplier.*COL_SDT;
        end
        
        %new   vectorize Sh.Kh
        ECH=find(ELEC_CHECK==0);
        for n=1:size(ECH,2)
            THRESHOLDS(ECH(n))=10000;
        end
        %alt codes
% %         for n=1:size(THRESHOLDS,2)
% %             if ELEC_CHECK(n)== 0
% %                 THRESHOLDS(n) = 10000;
% %             end
% %         end
       % MC: calculate positive thresholds 
        flag_positive = get(findobj(Window,'Tag','posThCheckbox'),'Value');
        if flag_positive == 1

            waitbar_counter2 = 0.05;
            waitbar(.05,h_wait,'Please wait - positive thresholds are calculated...');
            multiplier = PREF(17);

            window_beg = 0.01*SaRa+1;
            window_end = (0.01+PREF(16))*SaRa;
            nr_win = 0;
            calc_beg = 1;
            calc_end = PREF(16)*SaRa;

            CALC = zeros((2*SaRa),(size(RAW.M,2)));
            SNR = zeros(1,size(RAW.M,2));
            SNR_dB = zeros(1,size(RAW.M,2));

            if auto
                for n=1:size(RAW.M,2)
                    if  HDrowdata==1 %Sh.Kh for HDMEA
                        m = digital2analog_sh(RAW.M(:,n),RAW);
                    else
                        m=RAW.M;
                    end    
                    
                    while nr_win < (2/PREF(16))% use two secondes of the signal

                        %calculate STD in windows
                        if  HDrowdata==1 %Sh.Kh for .brw Data
                           [~,sigma] = normfit(m(window_beg:window_end)); %if you have the Statistics-Toolbox you can use "normfit" as well
                        else
                           [~,sigma] = normfit(m(window_beg:window_end,n)); %if you have the Statistics-Toolbox you can use "normfit" as well
                        end
                       
                        if((sigma < PREF(15)) && (sigma > 0))
                            if  HDrowdata==1 %Sh.Kh for .brw Data
                                CALC(calc_beg:calc_end,n) = m(window_beg:window_end);
                            else
                                CALC(calc_beg:calc_end,n) = m(window_beg:window_end,n);
                            end
                            calc_beg = calc_beg + PREF(16)*SaRa;
                            calc_end = calc_end + PREF(16)*SaRa;
                            window_beg = window_beg + PREF(16)*SaRa;
                            window_end = window_end + PREF(16)*SaRa;

                            if window_end>size(T,2) break; end %#ok

                            ELEC_CHECK(n) = 1;
                            nr_win = nr_win + 1;

                        else
                            window_beg = window_beg + PREF(16)/2*SaRa;
                            window_end = window_end + PREF(16)/2*SaRa;

                            if window_end>size(T,2) break; end %#ok

                            if ((window_beg > 0.5*size(T,2)) && (nr_win == 0))
                                ELEC_CHECK(n) = 0; %noisy
                                break
                            end
                        end
                    end

                    nr_win = 0;
                    window_beg = 0.01*SaRa+1;
                    window_end = (0.01+PREF(16))*SaRa;
                    calc_beg = 1;
                    calc_end = PREF(16)*SaRa;
                    if HDrowdata ==1
                        if n==1000 || n==2000 || n==3000 || n==4000
                            waitbar_counter2 = waitbar_counter2+n*(0.7/nr_channel);
                            waitbar(waitbar_counter2,h_wait);
                        end
                    else
                        waitbar_counter2 = waitbar_counter2+(0.7/nr_channel);
                        waitbar(waitbar_counter2,h_wait);
                    end  
                end
                COL_RMS = sqrt(mean(CALC.^2));
                COL_SDT = std(CALC);

            elseif auto == 0                    %Manu
                waitbar(.6,h_wait,'Please wait - positive thresholds are calculated...');
                if (PREF(3)-rec_dur<1) && (PREF(2) == 0) 
                    COL_RMS = sqrt(mean(RAW.M.^2));                 % RMS
                    COL_SDT = std(RAW.M);
                else
                    start = PREF(2)*SaRa+1;
                    finish = PREF(3)*SaRa;
                    COL_RMS = sqrt(mean(m(start:finish,:).^2)); % RMS
                    COL_SDT = std(m(start:finish,:));
                end
            end

            if threshrmsdecide
                THRESHOLDS_pos = multiplier.*COL_RMS;
            else
                THRESHOLDS_pos = multiplier.*COL_SDT;
            end
            
           %new vectorize Sh.Kh
            ECH=find(ELEC_CHECK==0);
            for n=1:size(ECH,2)
                THRESHOLDS(ECH(n))=10000;
            end
            %alt codes
    %         for n=1:size(THRESHOLDS,2)
    %             if ELEC_CHECK(n)== 0
    %                 THRESHOLDS(n) = 10000;
    %             end
    %         end

        else
            THRESHOLDS_pos=0;
        end % end THRESHOLDS_pos
        
        % save thresholds in spiketrain-file
%         for n=1:size(THRESHOLDS,2)
%             SPIKEZ.neg.THRESHOLDS.Th(1,n)=THRESHOLDS(n); 
%         end
        SPIKEZ.neg.THRESHOLDS.Th=THRESHOLDS; % Sh.Kh
%         for n=1:size(THRESHOLDS_pos,2)
%             SPIKEZ.pos.THRESHOLDS.Th(1,n)=THRESHOLDS_pos(n);
%         end
         SPIKEZ.pos.THRESHOLDS.Th=THRESHOLDS_pos;% Sh.Kh
         
        waitbar(1,h_wait,'Done.'), close(h_wait);
        set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Value',1,'Enable','on')
        set(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'String','');
        set(findobj(gcf,'Tag','Elsel_Thresh'),'String','');
        
        thresholddata = true;
        
        % Call function to calculate a dynamic threshold if checkbox is
        % active
        if get(findobj(Window,'Tag','dynThCheckbox'),'Value')
            DynamicThreshold; % calculate dynamic threshold
        else
            SPIKEZ.PREF.dyn_TH=0;
        end
        redrawdecide;        
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
                msgbox('This is not a recorded electrode!','Dr.CELLï¿½s hint','help');
                uiwait;
                return
            end
            set(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'String',THRESHOLDS(i));
            
        elseif spiketraincheck == 1
            msgbox('Error','Dr.CELLï¿½s hint','help');
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
                THRESHOLDS(n) = str2num(get(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'string'));%#ok
            end
        else
            THRESHOLDS(i) = str2num(get(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'string'));
        end
        
        redrawdecide;
    end

% --- read Thresholds from a file (FS)---------
%     function ELgetThresholdFile(~,~)
%         aktDat = strcat(full_path(1:max(strfind(full_path,'\'))),file);
%         if exist(strcat(aktDat(1:length(aktDat)-4),'.mat'),'file')
%             XXX = load(strcat(aktDat(1:length(aktDat)-4),'.mat'));
%             THRESHOLDS = XXX.THRESHOLDS;
%             CLEL = XXX.CLEL;
%             Invert_M = XXX.Invert_M;
%             clear XXX;
%             
%             set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
%             set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Value',1,'Enable','on')
%             set(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'String','');
%             set(findobj(gcf,'Tag','Elsel_Thresh'),'String','');
%             
%             thresholddata = true;
%             
%             if CLEL ~= 0
%                 for i = 1:size(CLEL,2)
%                     M(:,CLEL(i))=0;
%                     if spiketraincheck == 1
%                         SPIKES(:,CLEL(i))=0;
%                         BURSTS(:,CLEL(i))=0;
%                     end
%                 end
%             end
%             size(Invert_M)
%             size(M)
%             for i = 1:size(Invert_M,2)
%                 M(:,Invert_M(i))=M(:,Invert_M(i)).*(-1);
%             end
%             
%             redrawdecide;
%         else
%             msgbox('Threshold file does not exist','Error','error')
%         end
%     end
% --- read Thresholds from a file (FS,MC)---------
    function ELgetThresholdFile(~,~)
       
        SPIKEZ.THRESHOLDS=[];
        SPIKEZ.pos.THRESHOLDS=[];
        SPIKEZ.neg.THRESHOLDS=[];
        
        % go to path of loaded file
        cd(path)
        
        [THfile,THpath] = uigetfile({'*.mat','MAT-files (*.mat)'},file); % MC: manual TH-File selection
        threshold_path = [THpath, THfile];
        if exist(threshold_path,'file')
            temp = load(threshold_path);
            
            % compatible with old threshold files:
            if isfield(temp, 'THRESHOLDS')
                THRESHOLDS = temp.THRESHOLDS;
                SPIKEZ.THRESHOLDS.Th=THRESHOLDS;
                SPIKEZ.neg.THRESHOLDS.Th=THRESHOLDS;
            end
            if isfield(temp, 'CLEL')
                CLEL = temp.CLEL;
                SPIKEZ.THRESHOLDS.CLEL=CLEL;
            end
            if isfield(temp, 'Invert_M')
                Invert_M = temp.Invert_M;
                SPIKEZ.THRESHOLDS.Invert_M=Invert_M;
            end
            if isfield(temp,'THRESHOLDS_pos')
                THRESHOLDS_pos = temp.THRESHOLDS_pos;
                SPIKEZ.pos.THRESHOLDS.Th=THRESHOLDS_pos;
            end
            if isfield(temp,'PREF')
                PREF=temp.PREF;
                SPIKEZ.THRESHOLDS.Multiplier=PREF(1);
                SPIKEZ.THRESHOLDS.Std_noisewindow=PREF(15);
                SPIKEZ.THRESHOLDS.Size_noisewindow=PREF(16);
            end
            if isfield(temp,'COL_SDT')
               COL_SDT = temp.COL_SDT; 
            end
            
           
            
            % loading threshold from spiketrain-file (new) (MC):
            if isfield(temp, 'temp')
                clear temp
                load(threshold_path)
                
                THRESHOLDS = temp.SPIKEZ.THRESHOLDS.Th;
                CLEL = temp.SPIKEZ.THRESHOLDS.CLEL;
                Invert_M = temp.SPIKEZ.THRESHOLDS.Invert_M;
                THRESHOLDS_pos = temp.SPIKEZ.pos.THRESHOLDS.Th;
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
                        %BURSTS.BEG(:,CLEL(i))=0;
                    end
                end
            end
        
            for i = 1:size(Invert_M,2)
                RAW.M(:,Invert_M(i))=RAW.M(:,Invert_M(i))*(-1);
            end
            
            %RAW.M=M;
            
            redrawdecide;
        else
            msgbox('Threshold file does not exist','Error','error')
        end
    end


% --- safe Thresholds in a file (FS)-------
    function ELsaveThresholdFile(~,~)
        aktDat = strcat(full_path(1:max(strfind(full_path,'\'))),file);
        if exist(strcat(aktDat(1:length(aktDat)-4),'.mat'),'file')
            
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
                    
                    save(strcat(aktDat(1:length(aktDat)-4),'.mat'), 'THRESHOLDS','CLEL','Invert_M','COL_SDT');
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
            
            save(strcat(aktDat(1:length(aktDat)-4),'.mat'), 'THRESHOLDS','CLEL','Invert_M','COL_SDT');
        end
    end


% --- Threshold ALLER Elektroden per Hand einstellen (Andy)---------------
    function Thresholdforall(source,event) %#ok<INUSD>
        i = size(THRESHOLDS);
        THRESHOLDS(1,1:i(1,2)) = str2num(get(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'string'))%#ok
        redrawdecide;
    end


%functions - Tab Analysis
%----------------------------------------------------------------------

% --- Default-values of analysis (CN&MG)------------------------
    function handler(source,event) %#ok
        defaultset = get(defaulthandle,'value');   % set y scale
        switch defaultset
            case 1 %Burstdefinition Tam -
                set(findobj(gcf,'Tag','t_spike'),'String','1');
                set(findobj(gcf,'Tag','spike_no'),'String','3','enable','on');
                set(findobj(gcf,'Tag','t_12'),'String','10','enable','on');
                set(findobj(gcf,'Tag','t_nn'),'String','20','enable','on');
                set(findobj(gcf,'Tag','t_dead'),'String','500','enable','on');
                cellselect = 1;
                
            case 2 %Burstdefinition Baker - >= 3 Spikes max 100ms apart
                set(findobj(gcf,'Tag','t_spike'),'String','0');
                set(findobj(gcf,'Tag','spike_no'),'String','3','enable','on');
                set(findobj(gcf,'Tag','t_12'),'String','100','enable','on');
                set(findobj(gcf,'Tag','t_nn'),'String','100','enable','on');
                set(findobj(gcf,'Tag','t_dead'),'String','0','enable','on');
                cellselect = 1;
                
            case 3 %Burstdefinition Wagenaar 1
                set(findobj(gcf,'Tag','t_spike'),'String','0');
                set(findobj(gcf,'Tag','spike_no'),'String','4','enable','on');
                set(findobj(gcf,'Tag','t_12'),'String','0','enable','on');
                set(findobj(gcf,'Tag','t_nn'),'String','0','enable','on');
                set(findobj(gcf,'Tag','t_dead'),'String','0','enable','on');
                cellselect = 2;
                
            case 4 %Burstdefinition Wagenaar 2
                set(findobj(gcf,'Tag','t_spike'),'String','0');
                set(findobj(gcf,'Tag','spike_no'),'String','3','enable','on');
                set(findobj(gcf,'Tag','t_12'),'String','0','enable','on');
                set(findobj(gcf,'Tag','t_nn'),'String','0','enable','on');
                set(findobj(gcf,'Tag','t_dead'),'String','0','enable','on');
                cellselect = 3;
                
            case 5 %Cardiac - 200ms refractory time
                set(findobj(gcf,'Tag','t_spike'),'String','200');
                set(findobj(gcf,'Tag','spike_no'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_12'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_nn'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_dead'),'String','-','enable','off');
                cellselect = 0;
                
            case 6 %Cardiac - 100ms refractory time
                set(findobj(gcf,'Tag','t_spike'),'String','100');
                set(findobj(gcf,'Tag','spike_no'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_12'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_nn'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_dead'),'String','-','enable','off');
                cellselect = 0;
        end
    end

% --- HelpBurst Button - Information about Burstdefinitionens (CN)-----
    function HelpBurstFunction(source,event) %#ok
        Burstinfo = figure('color',[1 1 1],'Position',[150 75 700 600],'NumberTitle','off','toolbar','none','Name','Burst definition');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 590],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Tam et al.');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 570],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as at least 3 Spikes with a maximum idle time between Spike 1 and 2 of 10 ms and the other following spikes of 20 ms. The idle time between two spikes is set to 1 ms and that between two bursts to 500 ms.');
        
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 520],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Baker et al.');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 500],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as at least 3 Spikes with a maximum idle time between all the Spikes of 100 ms. There is no idle time between two bursts.');
        
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 450],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Wagenaar et al. [3]');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 430],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as a core of at least 3 Spikes with a maximum idle time between those Spikes of 100 ms or 1/(4*f), which ever is smaller (f is the mean spike frequency). After a core is found, Spikes with a maximum time difference of 1/(3*f) or 200 ms (which ever is smaller) before or after the core are added to the burst. There is no idle time between two bursts.');
        
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 350],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Wagenaar et al. [4]');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 330],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as a core of at least 4 Spikes with a maximum idle time between those Spikes of 100 ms or 1/(4*f), which ever is smaller (f is the mean spike frequency). After a core is found, Spikes with a maximum time difference of 1/(3*f) or 200 ms (which ever is smaller) before or after the core are added to the burst. There is no idle time between two bursts.');
        
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 250],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Cardiac spike definition [100 ms]');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 230],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','The idle time between two Spikes os set to 100 ms. There are no bursts in cardiac cells.');
        
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 200],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Cardiac spike definition [200 ms]');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 180],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','The idle time between two Spikes os set to 200 ms. There are no bursts in cardiac cells.');
        
    end

% --- Analyse - Button (CN&MG)-----------------------------------------
    function Analysedecide(source,event) %#ok<INUSD>
        PREF(2)= str2double(get(findobj(gcf,'Tag','time_start'),'string'));
        PREF(3) = str2double(get(findobj(gcf,'Tag','time_end'),'string'));
        PREF(4) = str2double(get(findobj(gcf,'Tag','t_spike'),'string'));           % refractory time Spike
        PREF(10) = str2double(get(findobj(gcf,'Tag','th_stim'),'string'));          % Zero Out-Threshold
        PREF(11) = str2double(get(findobj(gcf,'Tag','aftertime'),'string'));
        
        if(get(findobj(gcf,'Tag','spike_no'),'string'))=='-'
            PREF(5) = 0;
            PREF(6) = 0;
            PREF(7) = 0;
            PREF(8) = 0;
        else
            PREF(5) = str2double(get(findobj(gcf,'Tag','spike_no'),'string'));     % min. nr Spikes per Burst
            PREF(6) = str2double(get(findobj(gcf,'Tag','t_12'),'string'));         % max. time between Spike 1 and 2 in ms
            PREF(7) = str2double(get(findobj(gcf,'Tag','t_nn'),'string'));         % max. time between other Spikes
            PREF(8) = str2double(get(findobj(gcf,'Tag','t_dead'),'string'));       % min. time between 2 Bursts in ms
            if PREF(5)<3
                msgbox('A burst consists of at least 3 Spikes...','Dr.CELLï¿½s hint','error');
                uiwait;
                PREF(5)=3;
            end
        end
        
        if spiketraincheck == 1
            h_wait = waitbar(.25,'Please wait - data is analyzed...');
            CohenKappa;
            waitbar(.5,h_wait,'Please wait - Burstdetection in progress...')
            
            SIB = zeros(1,nr_channel);
            BURSTS = zeros(1,size(SPIKES,2));
            SPIKES_IN_BURSTS = zeros(1,size(SPIKES,2));
            BURSTDUR = zeros(1,size(SPIKES,2));
            IBIstd = zeros(1,size(SPIKES,2));
            IBImean = zeros(1,size(SPIKES,2));
            NR_BURSTS = zeros(1,size(SPIKES,2));
            meanburstduration = zeros(1,size(SPIKES,2));
            STDburst = zeros(1,size(SPIKES,2));
            
            Burstdetection;
            waitbar(.7,h_wait,'Please wait - SBE analysis in progress...')
            if nr_channel>1
                SBEdetection;
            end
            
            waitbar(1,h_wait,'Done.'), close(h_wait);
            
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

% --- Spikedetection (CN,MG,AD)---------------------------
    function Analyse(source,event) %#ok<INUSD>
        SI_EVENTS = 0; spikedata = false; 
        %waitbar_counter2 = 0.1;
        SPIKES = zeros(1,nr_channel);
       % BURSTS = zeros(1,size(RAW.M,2));
       set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Value',0,'Enable','off');
        
       
        % Old Spikedetection, commented out as spike position is not
        % correct (MC)
%         if varTdata==1
%             h_wait = waitbar(.05,'Please wait - Thresholds are calculated...');            
%             tic
%             M2 = zeros(size(M,1),size(M,2));           
%             for n = 1:size(M2,2)
%                 M2(:,n) = M(:,n)-varT(:,n);
%             end
%             M2 = (M2<0);            
%         else            
%             h_wait = waitbar(.05,'Please wait - Thresholds are calculated...');
%             tic
%             M2 = zeros(size(M,1),size(M,2));
%             for n = 1:size(M2,2)
%                 M2(:,n) = M(:,n)-THRESHOLDS(n);
%             end
%             M2 = (M2<0);
%         end
%         
%         % write Timestamps of Spikes:
%         waitbar(.1,h_wait,'Please wait - spikedetection in progress...')        
%         for n = 1:size(M2,2)                        % n: current collum in M2 and SPIKES
%             k = 0;                                  % k: current row in SPIKES
%             m = 2;                                  % m: current row in M2
%             potspikebeg = 0;
%             potspikeend = 0;
%             
%             while m <= size(M2,1)
%                 %beginning of spikes
%                 if M2(m,n)>M2(m-1,n)
%                     potspikebeg = m;
%                 end
%                 %End of Spikes
%                 if (M2(m,n)<M2(m-1,n) && (potspikebeg ~= 0))
%                     potspikeend = m;
%                 end
%                 % = Peak
%                 if potspikeend ~= 0
%                     SEARCH = M(potspikebeg:potspikeend,n);
%                     k=k+1;
%                     %[SPIKEZ.AMP(k,n),I]= min(SEARCH);
%                     SPIKES(k,n) = T((m-size(SEARCH,1)+I));
%                     potspikebeg = 0;
%                     potspikeend = 0;
%                 end
%                 m = m + 1;
%             end
%             waitbar_counter2 = waitbar_counter2+(0.45/nr_channel);
%             waitbar(waitbar_counter2);
%         end
%         
%         % --- Timestamps with refractory time
%         
%         clear SPIKES_NEW;
%         if PREF(4)~= 0
%             waitbar(.6,h_wait,'Please wait - spikedetection in progress...')
%             n = 1;
%             SPIKES(size(SPIKES,1)+1,:)= 0;
%             while (n <= size(SPIKES,2))
%                 k = 1;
%                 h = 1;
%                 i = 1;
%                 if (size(nonzeros(SPIKES(:,n)),1))==1;
%                     SPIKES_NEW(h,n) = SPIKES(k,n);
%                 else
%                     while (k <=(size(nonzeros(SPIKES(:,n)),1)))
%                         if ((SPIKES(k+i,n) - SPIKES(k,n)) <= (PREF(4)/1000 - 1/(SaRa*4))) && ((SPIKES(k+i,n)~= 0) &&  (SPIKES(k,n) ~= 0))
%                             [~,I] = min(M(round(SPIKES(k,n)*SaRa)+1:(round(SPIKES(k+i,n)*SaRa)+1),n));
%                             if I==1
%                                 i = i + 1;
%                             else
%                                 k = k + i;
%                                 i = 1;
%                             end
%                             
%                         else
%                             SPIKES_NEW(h,n) = SPIKES(k,n);
%                             k = k + i;
%                             h = h + 1;
%                             i = 1;
%                         end
%                     end
%                 end
%                 n = n + 1;
%             end
%             SPIKES=[];
%             
%             if size(SPIKES_NEW,2) == size(THRESHOLDS,2)
%                 SPIKES = SPIKES_NEW;
%             else
%                 SPIKES_NEW(:,size(THRESHOLDS,2))= 0;
%                 SPIKES = SPIKES_NEW;
%             end
%         end
        
        

        % Perform spikedetection (MC)
        h_wait = waitbar(.05,'Please wait - spikedetection in progress...');
        init_RAW_and_SPIKEZ(); % structures RAW and SPIKEZ are initialized
        SPIKEZ.TS = SPIKES;                     % prepare structure "SPIKEZ" that function "spikedetection" needs as input
        SPIKEZ.PREF.idleTime = PREF(4)/1000;    % idle time from milliseconds to seconds
        SPIKEZ.pos.flag=0;                      % don't detect positive spikes
        SPIKEZ.neg.flag=1;                      % only detect negative spikes  
        SPIKEZ.PREF.flag_isHDMEAmode = false;
        waitbar(.2,h_wait,'Please wait - spikedetection in progress...')
        SPIKEZ = spikedetection(RAW,SPIKEZ); % SPIKEDETECTION call
        SPIKES = SPIKEZ.TS; % unpack structure in order to use old variable "SPIKES"
%         NR_SPIKES = SPIKEZ.NR; 
        for n = 1:(nr_channel)
            NR_SPIKES(n) = length(find(SPIKES(:,n)));        % number of spikes per electrode
        end
        waitbar(.65,h_wait,'Please wait - spikedetection in progress...')
        clear M2;
        
        SIB = zeros(1,nr_channel);
        BURSTS = zeros(1,size(SPIKES,2));                                   % create empty arrays...
        SPIKES_IN_BURSTS = zeros(1,size(SPIKES,2));
        BURSTDUR = zeros(1,size(SPIKES,2));
        IBIstd = zeros(1,size(SPIKES,2));
        IBImean = zeros(1,size(SPIKES,2));
        NR_BURSTS = zeros(1,size(SPIKES,2));
        meanburstduration = zeros(1,size(SPIKES,2));
        STDburst = zeros(1,size(SPIKES,2));

        if (get(findobj('Tag','Burst_Box'),'value')) == 1
            CohenKappa;
            waitbar(.75,h_wait,'Please wait - Burstdetection in progress...')
            
            if cellselect ~= 0  %only for neurons
                Burstdetection;
            end
            
            waitbar(.9,h_wait,'Please wait - SBE analysis in progress...')
            if nr_channel>1
                SBEdetection;
            end
        end
        spikedata = true;
        
        
        waitbar(1,h_wait,'Done.'), close(h_wait);
        
        set(findobj(gcf,'Parent',t5),'Enable','on');
        set(findobj(gcf,'Parent',t6),'Enable','on');
        set(findobj(gcf,'Parent',t7),'Enable','on');
        
        set(findobj(gcf,'Tag','CELL_exportNWBButton'),'Enable','off');
        
        if stimulidata ==0
            set(findobj(gcf,'Tag','CELL_ShowZeroOutExample'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Enable','off');
        end
        
        %Calculate Signal-to-Noise Ratio
        
        for i=1:size(RAW.M,2) %for all electrodes
            
            if NR_SPIKES(i) > 0
                for k=1:NR_SPIKES(i) %for i-th electrode
                    amptemp(k) = - RAW.M((ceil(SPIKES(k,i)*SaRa)),i);
                end

                SNR(i) = (mean(amptemp)/COL_SDT(i))^2;
                
                amptemp=[];
            else
                SNR(i) = 1;
            end
        end
        
        for n = 1:size(SNR,2)  %In some cases the RMS value is 0.99xx. the value is then set to 1
            if (SNR(n)<1 || THRESHOLDS(n) == 10000)
                SNR(n)=1;
            end
        end
        
        SNR_dB = 20*log(SNR);
        Mean_SNR_dB = mean(SNR_dB);
        
        % redrawn
        redrawdecide
        
%         if Viewselect == 0
%             redraw;
%         elseif Viewselect == 1
%             redraw_allinone;
%         end
%         
                
        
    end

% --- InitSPIKEZ_call (MC) ------------------
    function init_RAW_and_SPIKEZ()
       % Save Data in RAW structure
       if M~=0
        RAW.M=M;
       end
        RAW.T=T;
        RAW.rec_dur=rec_dur;
        RAW.SaRa=SaRa;
        RAW.EL_NAMES=EL_NAMES;
        RAW.EL_NUMS=EL_NUMS;
        RAW.nr_channel=nr_channel;
        RAW.Date=Date;
        RAW.Time=Time;
        RAW.fileinfo=fileinfo;
        
        % Save Data in SPIKEZ structure
        SPIKEZ = initSPIKEZ(SPIKEZ,RAW);
        SPIKEZ.neg.THRESHOLDS.Th = THRESHOLDS;
        SPIKEZ.neg.THRESHOLDS.Multiplier = PREF(1);
        SPIKEZ.neg.THRESHOLDS.Std_noizewindow = PREF(15);
        SPIKEZ.neg.THRESHOLDS.Size_noizewindow = PREF(16); 
    end

% --- Burstdetektion (MG&CN)-----------------
    function Burstdetection(source,event) %#ok
         if HDspikedata==1 || HDrowdata ==1
             msgbox('only for MEA Data!','Error','error')
         else
            if cellselect == 1 %for neurons
                for n = 1:size(SPIKES,2)                                            % n: current collum = electrode
                    k = 1; m = 1;                                                   % k: row in BURSTS, m: row in SPIKES
                    while m <= size(nonzeros(SPIKES(:,n)),1)-2                      % ...skip last two spikes:
                        if ((SPIKES(m+1,n)-SPIKES(m,n) <= (PREF(6)/1000)) && (SPIKES(m+2,n)-SPIKES(m+1,n) <= (PREF(7)/1000))) % check the first 3 spikes
                            candidate = SPIKES(m,n);   % safe postential Timestampfor a burst
                            m = m+2;
                            o = 3;                     % o: current number of Spikes in that Burst
                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            while SPIKES(m+1,n)-SPIKES(m,n) <= (PREF(7)/1000)
                                m = m+1;
                                o = o+1;
                                if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            end

                            if o >= PREF(5)
                                BURSTS(k,n)= candidate;

                                %calculate burstduration
                                BURSTDUR(k,n) = SPIKES(m,n)-SPIKES(m-o+1,n);
                                k = k+1;
                                SPIKES_IN_BURSTS(n) = SPIKES_IN_BURSTS(n)+o;

                                while SPIKES(m,n)-BURSTS(k-1,n)<=(PREF(8)/1000)
                                    m = m+1;
                                    if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                                end
                            end
                        else
                            m = m+1;
                        end
                    end
                end

                %calculate mean burstduration per electrode
                for countval=1:size(BURSTS,2)
                    if BURSTDUR(1,countval) ~= 0
                        meanburstduration(countval) = mean(nonzeros(BURSTDUR(:,countval)));
                        STDburst(countval) = std(nonzeros(BURSTDUR(:,countval)));
                    end
                end

                MBDae =  mean(nonzeros(meanburstduration)); %Mean Burst Duration all electrodes
                STDburstae = mean(nonzeros(STDburst));
                if isnan(MBDae)
                    MBDae = 0;
                end
                if isnan(STDburstae)
                    STDburstae =0;
                end

                %---Burstalgorithm as in MEA-Bench by Wagenaar with 4 Spikes in the core---
            elseif cellselect == 2
                Spikerate = NR_SPIKES.*(1/rec_dur);
                tau1 = zeros(1,size(SPIKES,2));            % empty arrays...
                tau2 = zeros(1,size(SPIKES,2));
                Spikedelay1 = zeros(1,size(SPIKES,2));     % Delay in the core
                Spikedelay2 = zeros(1,size(SPIKES,2));     % Delay around the

                for n = 1:nr_channel
                    tau1(n) = 1/(4*Spikerate(n));
                    tau2(n) = 1/(3*Spikerate(n));

                    if tau1(n) > 1/10
                        Spikedelay1(n) = 1/10;
                    else
                        Spikedelay1(n) = tau1(n);
                    end

                    if tau2(n) > 2/10
                        Spikedelay2(n) = 2/10;
                    else
                        Spikedelay2(n) = tau2(n);
                    end


                    k = 1; m = 1;                                                   % k: row in BURSTS, m: row in SPIKES
                    while m <= size(nonzeros(SPIKES(:,n)),1)-2                      % -2 at 4 Spikes in the core...until third last spike in SPIKES:
                        if ((SPIKES(m+1,n)-SPIKES(m,n)<=Spikedelay1(n)) && (SPIKES(m+2,n)-SPIKES(m+1,n)<=Spikedelay1(n)) && (SPIKES(m+2,n)-SPIKES(m+1,n)<=Spikedelay1(n)))
                            candidate = SPIKES(m,n);
                            FirstSpike = m;
                            m = m+3;
                            o = 4;

                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            while SPIKES(m+1,n)-SPIKES(m,n) <= Spikedelay2(n)
                                m = m+1;
                                o = o+1;
                                if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            end

                            if FirstSpike > 1
                                while SPIKES(FirstSpike,n) - SPIKES(FirstSpike-1,n) <= Spikedelay2(n)
                                    FirstSpike = FirstSpike - 1;
                                    o=o+1;
                                    if FirstSpike <= 1, break, end
                                end
                            end

                            if o >= PREF(5)
                                BURSTS(k,n)= candidate;

                                %calculate burstduration
                                BURSTDUR(k,n) = SPIKES(m,n)-SPIKES(m-o+1,n);
                                SPIKES_IN_BURSTS(n) = SPIKES_IN_BURSTS(n)+o;
                                k = k+1;

                                while SPIKES(m,n)-BURSTS(k-1,n)<=(PREF(10)/1000)
                                    m = m+1;
                                    if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                                end
                            end
                        else
                            m = m+1;
                        end
                    end
                end

                %calculate mean burst duration per eklectrode
                for countval=1:size(BURSTS,2)
                    if BURSTDUR(1,countval) ~= 0
                        meanburstduration(countval) = mean(nonzeros(BURSTDUR(:,countval)));
                        STDburst(countval) = std(nonzeros(BURSTDUR(:,countval)));
                    end
                end

                MBDae =  mean(nonzeros(meanburstduration)); %Mean Burst Duration all electrodes
                STDburstae = mean(nonzeros(STDburst));
                if isnan(MBDae)
                    MBDae = 0;
                end
                if isnan(STDburstae)
                    STDburstae =0;
                end
                cellselect = 1;


                %---Burstalgorithm as in MEA-Bench by Wagenaar mit 3 Spikes in a core---
            elseif cellselect == 3
                Spikerate = NR_SPIKES.*(1/rec_dur);
                tau1 = zeros(1,size(SPIKES,2));
                tau2 = zeros(1,size(SPIKES,2));
                Spikedelay1 = zeros(1,size(SPIKES,2));
                Spikedelay2 = zeros(1,size(SPIKES,2));

                for n = 1:nr_channel
                    tau1(n) = 1/(4*Spikerate(n));
                    tau2(n) = 1/(3*Spikerate(n));

                    if tau1(n) > 1/10
                        Spikedelay1(n) = 1/10;
                    else
                        Spikedelay1(n) = tau1(n);
                    end

                    if tau2(n) > 2/10
                        Spikedelay2(n) = 2/10;
                    else
                        Spikedelay2(n) = tau2(n);
                    end


                    k = 1; m = 1;
                    while m <= size(nonzeros(SPIKES(:,n)),1)-1
                        if ((SPIKES(m+1,n)-SPIKES(m,n)<=Spikedelay1(n)) && (SPIKES(m+2,n)-SPIKES(m+1,n)<=Spikedelay1(n)))
                            candidate = SPIKES(m,n);
                            FirstSpike = m;
                            m = m+2;
                            o = 3;
                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            while SPIKES(m+1,n)-SPIKES(m,n) <= Spikedelay2(n)
                                m = m+1;
                                o = o+1;
                                if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            end
                            if FirstSpike > 1
                                while SPIKES(FirstSpike,n) - SPIKES(FirstSpike-1,n) <= Spikedelay2(n)
                                    FirstSpike = FirstSpike - 1;
                                    o=o+1;
                                    if FirstSpike <= 1, break, end
                                end
                            end

                            if o >= PREF(5)
                                BURSTS(k,n)= candidate;

                                BURSTDUR(k,n) = SPIKES(m,n)-SPIKES(m-o+1,n);
                                SPIKES_IN_BURSTS(n) = SPIKES_IN_BURSTS(n)+o;
                                k = k+1;

                                while SPIKES(m,n)-BURSTS(k-1,n)<=(PREF(10)/1000)
                                    m = m+1;
                                    if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                                end
                            end
                        else
                            m = m+1;
                        end
                    end
                end


                %calculate mean burst duration
                for countval=1:size(BURSTS,2)
                    if BURSTDUR(1,countval) ~= 0
                        meanburstduration(countval) = mean(nonzeros(BURSTDUR(:,countval)));
                        STDburst(countval) = std(nonzeros(BURSTDUR(:,countval)));
                    end
                end

                MBDae =  mean(nonzeros(meanburstduration)); %Mean Burst Duration all electrodes
                STDburstae = mean(nonzeros(STDburst));
                if isnan(MBDae)
                    MBDae = 0;
                end
                if isnan(STDburstae)
                    STDburstae =0;
                end
                cellselect = 1;
            else
            end

            for n = 1:(nr_channel)
                NR_BURSTS(n) = length(find(BURSTS(:,n)));        % - number of bursts per electrode

                if(NR_BURSTS(n)>0)
                    SIB(n) = SPIKES_IN_BURSTS(n)/NR_BURSTS(n);       % - mean number of spikes per burst
                end
            end

            if isempty(nonzeros(SIB))
                Mean_SIB = 0;
            else
                Mean_SIB = mean(nonzeros(SIB));     %mean number of spikes per burst over all electrodest
            end

            %Calculate interburstintervals for each electrode incl. mean and STD
            if (size(BURSTS,1) > 1)
                for z=1:size(BURSTS,2)
                    if (BURSTS(1,z) == 0) || (BURSTS(2,z) == 0)
                        IBImean(z) = 0;
                    else
                        for i = 1:size(nonzeros(BURSTS(:,z)),1)-1
                            IBI(i,z) = BURSTS(i+1,z)-(BURSTS(i,z)+BURSTDUR(i,z));
                        end
                        IBImean(z) = mean(nonzeros(IBI(:,z)));
                        IBIstd(z) = std(nonzeros(IBI(:,z)));
                    end
                end
            end

            %For all electrodes incl mean and std
            if isempty(nonzeros(IBImean))
                aeIBImean =0;
            else
                aeIBImean = mean(nonzeros(IBImean));
            end

            if isempty(nonzeros(IBIstd))
                aeIBIstd =0;
            else
                aeIBIstd =  mean(nonzeros(IBIstd));
            end
            spikedata = true;
        end
    end

% --- SBE-detection (MG&CN)--------------------------------------------
    function SBEdetection(source,event)     %#ok
        
        if cellselect == 1  %Neuron
            BASE = BURSTS;
        else                %Cardiac
            BASE = SPIKES;
        end
        
        sync_time = int32(.04*SaRa);                    % tim in which 2 spikes are concidered parallel
        max_time = int32(.4*SaRa);
        wait_time = int32(.5*SaRa);
        
        ELECTRODE_ACTIVITY = zeros(size(T,2),nr_channel);
        ACTIVITY = zeros(1,length(T));
        
        for i = 1:size(BASE,2)                        % for each electrode...
            for j = 1:length(nonzeros(BASE(:,i)))     % fï¿½r every Spike or Burst...
                pos = int32(BASE(j,i)*SaRa);
                
                if (pos>sync_time && pos<length(ACTIVITY)-sync_time)
                    ELECTRODE_ACTIVITY(pos-sync_time:pos+sync_time,i) = 1;
                end
            end
        end
        
        ACTIVITY = sum(ELECTRODE_ACTIVITY,2);
        
        clear ELECTRODE_ACTIVITY;
        
        i = 1; k = 1;
        while i <= length(ACTIVITY)
            if i+max_time < length(ACTIVITY)
                imax = i+max_time;
            else
                imax = length(ACTIVITY);
            end
            
            if ACTIVITY(i)>=5
                [~,I] = max(ACTIVITY(i:imax));
                maxlength = 0;
                while ACTIVITY(i+I)==ACTIVITY(i+I+1)
                    maxlength = maxlength+1;
                    I = I+1;
                end
                I = I-int32(maxlength/2);
                SI_EVENTS(k) = T(i+I);              % ...safe in SI_EVENTS
                k = k+1;
                i = i+I+wait_time;
            end
            i = i+1;
        end
        
        Nr_SI_EVENTS = size(SI_EVENTS,2);
        if (Nr_SI_EVENTS == 1) && (SI_EVENTS(1)==0)
            Nr_SI_EVENTS =0;
        end
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

% --- Rasterplot Zeichnen (MG)-----------------------------------------
%     function rasterplotButtonCallback(source,event) %#ok
%         rasterplot = figure('Position',[150 50 700 660],'Name','Rasterplot Spikes',...
%             'NumberTitle','off','Resize','off');
%         axes('Units','pixels','Position',[20 40 660 600],'YDir','reverse',...
%             'YLim',[0 size(SPIKES,2)+1],'YColor',[.8 .8 .8],'YMinorGrid','on');
%         
%         for n=1:length(SI_EVENTS)
%             line ('Xdata',[SI_EVENTS(n) SI_EVENTS(n)],'YData',[0 nr_channel],...
%                 'Color','green');
%         end
%         for n=1:size(BURSTS,2)
%             line ('Xdata',nonzeros(SPIKES(:,n)),...
%                 'Ydata', n.*ones(1,length(nonzeros(SPIKES(:,n)))),...
%                 'LineStyle','none','Marker','*',...
%                 'MarkerFaceColor','green','MarkerSize',3);
%             text(0,n,EL_NAMES(n),'HorizontalAlignment','right','FontSize',6);
%         end
%         xlabel ('time / s');
%         figure (rasterplot);
%     end

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

% --- Rasterplot (MC - Sh.Kh)  ------------------------------------------------------
function rasterplotButtonCallback(~,~) 
        
        % GUI
        h_main = figure('Position',[150 50 700 660],'Name','Rasterplot');
        
        h_p1=uipanel('Parent',h_main,'Position',[0.01 0.01 0.99 0.9]);
            axes('Parent',h_p1,'Units','Normalized','Position',[.1 .1 0.8 .8],'Tag','axes_rasterplot'); 
        
        h_p2=uipanel('Parent',h_main,'Position',[0.01 0.9 0.99 0.1]);
            uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_spikes','String','Spikes','units','Normalized','position', [.1 .75 .2 .2],'value',1,'TooltipString','Shows spikes.','Callback',@rasterplot);
           % uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_bursts','String','Bursts','units','Normalized','position', [.1 .5 .2 .2],'value',0,'TooltipString','Shows bursts.','Callback',@rasterplot);
           % uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_nb','String','Networkbursts (NB)','units','Normalized','position', [.1 .25 .2 .2],'value',0,'TooltipString','Shows networkbursts.','Callback',@rasterplot);
           % uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_sbe','String','Synchronous Burst Events (SBE)','units','Normalized','position', [.35 .75 .2 .2],'value',0,'TooltipString','Shows synchronous burst events.','Callback',@rasterplot);
          %  uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_sbe_old','String','SBE_old','units','Normalized','position', [.35 .5 .2 .2],'value',0,'TooltipString','Shows synchronous burst events.','Callback',@rasterplot);
          %  uicontrol('Parent',h_p2,'style','checkbox','Tag','checkbox_show_num','String','show #Events','units','Normalized','position', [.35 .25 .2 .2],'value',0,'TooltipString','Shows number of bursts per event.','Callback',@rasterplot);

        % draw rasterplot
        rasterplot();
    
    end
    function rasterplot(~,~)
       
        handle=gca; 
        cla(handle) % clear axis
        
        % draw text
%         a=0; e=rec_dur; % display from a to e seconds
            if HDrowdata==1 || HDspikedata==1  % HDMEA Data
                 ROW=NCh;
                 for n=1:NCh
                    if ~isempty(nonzeros(SPIKES(:,n)))
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
            if HDspikedata==1 || HDrowdata==1 % HDMEA Data        
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
              for n=1:NCh
                  R=NCh;
            if ~isempty(nonzeros(BURSTS.BEG(:,n)))
              Names(n)= EL_NAMES(n);
            else
              Names(n)= {['' ]};
            end
        end
        set(gca,'YDir','reverse', 'ytick', [1.25:1:R+1], 'TickLength',[0 0], 'YTickLabel',Names','YLim',[0 R+1],'FontSize',6);
        xlabel('t /s')
        height=R+1;
            
            COLOR=[0 1 0.4]; % 0 0.8 0.4
             ROW=1;o=1.5;l=1; 
            for n=1:size(SPIKEZ.TS,2)
                 %if ~isempty(nonzeros(BURSTS.BEG(:,n)))
                     if size(BURSTS.BEG,2)>1
                         for k=1:length(nonzeros(BURSTS.BEG(:,n)))
                             line([BURSTS.BEG(k,n) BURSTS.BEG(k,n) BURSTS.END(k,n) BURSTS.END(k,n)],[ o l l o],'Color',COLOR)
                         end
                     end
                     o=o+ROW;
                     l=l+ROW;
                 %end
             end 
%              for n=1:size(SPIKES,2)
%                  if ~isempty(nonzeros(SPIKES(:,n)))
%                      if size(BURSTS.BEG,2)>1
%                          for k=1:length(nonzeros(BURSTS.BEG(:,n)))
%                              line([BURSTS.BEG(k,n) BURSTS.BEG(k,n) BURSTS.END(k,n) BURSTS.END(k,n)],[ o l l o],'Color',COLOR)
%                          end
%                      end
%                      o=o+ROW;
%                      l=l+ROW;
%                  end
%              end  
        end 
        
        % draw SBE
        if get(findobj(gcf,'Tag','checkbox_sbe'),'Value')==1
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
            msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELLï¿½s hint','help');
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
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELLï¿½s hint','help');
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
                    msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELLï¿½s hint','help');
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
            axis([1 length(textscan(get(findobj(gcf,'Tag','CELL_Selectautocorr_electrode'),'string'))) -Lagboarder Lagboarder 0 1]);
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
        uicontrol('Parent',crosspaneltop,'style','text','units','Pixels','position', [370 35 150 35],'BackgroundColor', GUI_Color_BG,'FontSize',10, 'HorizontalAlignment','left','String','Mean (all electrodes) Cohenï¿½s Kappa');
        uicontrol('Parent',crosspaneltop,'style','edit','units','Pixels','position', [370 10 100 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_cokap','string',kappa_mean);
        
        CORRBIN = 0;
        CC_EL_Select1 = textscan(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode1'),'string'));
        CC_EL_Select2 = textscan(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode2'),'string'));
        
        if length(CC_EL_Select1)==1 && length(CC_EL_Select2)==1
            CrossCorr1 = find(EL_NUMS==CC_EL_Select1);
            CrossCorr2 = find(EL_NUMS==CC_EL_Select2);

            subplot(1,1,1,'parent',crosspanelbot)
            xlabel('lags')
            ylabel('Probability Crosscorrelation')
            
            if isempty(CrossCorr1) || isempty(CrossCorr2)
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELLï¿½s hint','help');
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
        CC_EL_Select1 = textscan(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode1'),'string'));
        CC_EL_Select2 = textscan(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode2'),'string'));
        
        if length(CC_EL_Select1)==1 && length(CC_EL_Select2)==1
            CrossCorr1 = find(EL_NUMS==CC_EL_Select1);
            CrossCorr2 = find(EL_NUMS==CC_EL_Select2);
            
            if isempty(CrossCorr1) || isempty(CrossCorr2)
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELLï¿½s hint','help');
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

% --- Timing-Function Cardiac Pop-Up (FS)----------------------------
    function timingButtonCallback(~,~)
        
        fh = figure('Units','Pixels','Position',[300 360 400 200],'Name','Spike auswï¿½hlen','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');
        uicontrol('Parent',fh,'style','text','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','Pixels', 'position', [20 80 300 100],'String','Analyse fï¿½r einen bestimmten Spike, oder eine ï¿½bersicht ï¿½ber die ersten zwanzig auftretenden Spikes');
        uicontrol('Parent',fh,'Units','Pixels','Position',[200 64 60 20],'Tag','SpikeChoice','FontSize',8,'String','','Style','popupmenu');
        radiogroup = uibuttongroup('visible','on','Units','Pixels','Position',[18 32 140 20],'BackgroundColor', GUI_Color_BG,'BorderType','none','SelectionChangeFcn',@timinghandler);
        uicontrol('Parent',radiogroup,'Units','pixels','Position',[18 32 140 20],'Style','radio','HorizontalAlignment','left','Tag','CELL_singleSpike','String','Bestimmter Spike','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','Bitte wï¿½hlen Sie den zu analysierenden Spike aus');
        uicontrol('Parent',radiogroup,'Units','pixels','Position',[18 0 140 20],'Style','radio','HorizontalAlignment','left','Tag','CELL_multiSpikes','String','Ersten 20 Spikes','FontSize',9,'BackgroundColor', GUI_Color_BG,'TooltipString','Es werden automatisch die ersten 20 Spikes angezeigt');
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[280 30 110 50],'String','Auswahl bestï¿½tigen','CallBack',@delaycallfunction);
        uicontrol('Parent',fh,'Units','pixels','Position',[345 180 55 20],'Style','Checkbox','Tag','Expert','String','Expert','BackgroundColor', GUI_Color_BG,'CallBack',@TimingButtonExpert);
        uipanel('Parent',fh,'Units','pixels','Position',[405 5 5 190],'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',fh,'Style', 'text','Position', [415 170 160 25],'String', 'Number of Networks: 0','Tag','GroupNr','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',fh,'Units','pixels','Position',[415 150 140 20],'Style','Checkbox','Tag','Separate','String','Separate Networks','BackgroundColor', GUI_Color_BG,'CallBack',@Separation);
        uicontrol('Parent',fh,'Style','text','Units','pixels','Position',[440 120 90 20],'String','Chosen Network:','FontSize',8,'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',fh,'Style','popupmenu','Units','Pixels','Position',[442 107 65 15],'String','','Tag','ChosenNW','FontSize',8,'Enable','off');
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[415 30 110 30],'String','Rasterplot','CallBack',@Rasterplotprivate);
        
        i = 1;
        while i <= size(SPIKES,1) && i <= 99
            if fix(i/10) == 0
                t(i,:) = [' ' num2str(i)];
            else
                t(i,:) = num2str(i);
            end
            i = i+1;
        end
        set(findobj(gcf,'Tag','SpikeChoice'),'String',t);
        
        Scan = false;
        Frequenzen = zeros(size(SPIKES,2),2);
        
        function timinghandler(~,event)
            t = get(event.NewValue,'Tag');
            switch(t)
                case 'CELL_singleSpike'
                    set(findobj(gcf,'Tag','SpikeChoice'),'enable','on');
                case 'CELL_multiSpikes'                                          % Cardiac
                    set(findobj(gcf,'Tag','SpikeChoice'),'enable','off');
            end
        end
        
        function Separation(~,~)
            t = get(findobj(gcf,'Tag','Separate'),'value');
            if t == 1
                set(findobj(gcf,'Tag','ChosenNW'),'enable','on');
            elseif t == 0
                set(findobj(gcf,'Tag','ChosenNW'),'enable','off');
            end
        end
        
        function TimingButtonExpert (~,~)
            t = get(findobj(gcf,'Tag','Expert'),'value');
            if t == 1
                set(fh,'Position',[300 360 600 200]);
                if Scan == false
                    Scan = true;
                    
                    Frequenzscanner;
                    
                    t = '';
                    i = 1;
                    j = 0;
                    NrNetworks = max(Frequenzen(:,2));
                    while i <= NrNetworks && i<=99
                        if not(isempty(find(Frequenzen(:,2)==i,1)))
                            if fix((i)/10) == 0
                                t(i-j,:) = ['   ' num2str(i)];
                            else
                                t(i-j,:) = ['  ' num2str(i)];
                            end
                        else
                            j = j+1;
                        end
                        i = i+1;
                    end
                    set(findobj(gcf,'Tag','ChosenNW'),'String',t);
                    clear i NrNetworks t j;
                end
            elseif t  == 0
                set(fh,'Position',[300 360 400 200]);
            end
            
            function Frequenzscanner (~,~)
                %FrequencyTolerance
                FToleranz = 0.05;  %Percentage of how frequencies are allowd to vary to still be considered as one network (0.1 = 10%)
                %Timetolerance
                ZToleranz = 0.200; %deviation in sec
                
                %Calculate freq on all electrodes
                Einzelfrequenzen = zeros(size(SPIKES,2),size(SPIKES,1)-1,1);
                n = 1;
                m = 1;
                
                while m <= size(SPIKES,2)
                    while n+1<=(size(SPIKES,1)) && SPIKES(n+1,m)>0
                        Einzelfrequenzen(m,n) = 1 / (SPIKES(n+1,m)-SPIKES(n,m));
                        n=n+1;
                    end
                    Frequenzen(m,1:2)= median(nonzeros(Einzelfrequenzen(m,:)));
                    m=m+1;
                    n=1;
                end
                Frequenzen(:,3) = 0;
                clear m n Einzelfrequenzen;
                
                %Sort in groups by frequencies (size(Group,1) = number of networks)
                %No Check, if at least one spike was not detected
                Gnr = 1; %Number of groups
                
                %definition group 1
                [Group(1,1),Group(1,2)] = max(Frequenzen(:,2));
                Frequenzen(Group(1,2),2) = 0;
                Frequenzen(Group(1,2),3) = 1;
                
                %find next frequency maximum
                while 1
                    %C = max Frequency
                    %I = Index electrode of current min frequency
                    [C,I] = max(Frequenzen(:,2));
                    
                    if C == 0
                        break;                     %If Max = 0 cancel
                    else
                        
                        GI = 0;
                        while Gnr-GI > 0
                            
                            if abs(C-Group(Gnr-GI,1)) <= Group(Gnr-GI,1)*FToleranz && abs(SPIKES(1,I)-SPIKES(1,Group(Gnr-GI,2))) <= ZToleranz
                                Frequenzen(I,3) = Gnr-GI;
                                Frequenzen(I,2) = 0;
                                break;
                            else
                                SpI = 1;
                                Match = true;
                                
                                while SpI <= size(nonzeros(SPIKES(:,I)),1)
                                    if isempty(nonzeros(abs(SPIKES(:,Gnr-GI)-SPIKES(SpI,I)) <= ZToleranz))
                                        Match = false;
                                        break;
                                    else
                                        SpI = SpI +1;
                                    end
                                end
                                if Match
                                    Frequenzen(I,3) = Gnr-GI;
                                    Frequenzen(I,2) = 0;
                                    break;
                                else
                                    GI = GI+1;
                                end
                            end
                        end
                        if Frequenzen(I,2) ~= 0
                            Gnr = Gnr+1;
                            Frequenzen(I,3) = Gnr;
                            Frequenzen(I,2) = 0;
                            Group(Gnr,1) = C;
                            Group(Gnr,2) = I;
                        end
                    end
                end
                Frequenzen(:,2) = [];
                set(findobj(gcf,'Tag','GroupNr'),'String',['Number of Networks: ',num2str(Gnr)]);
            end
        end
        
        
        function Rasterplotprivate(source,event) %#ok
            Eventrasterplot = figure('Position',[150 50 840 660],'Name','Rasterplot Spikes',...
                'NumberTitle','off','Resize','off');
            
            uicontrol('Parent',Eventrasterplot,'Style','Text','Units','Pixels','Position',[92 638 44 15],'String','Network:','FontSize',8,'HorizontalAlignment','right','BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',Eventrasterplot,'Units','Pixels','Position',[60 40 50 25],'String','Apply','FontSize',8,'CallBack',@SetNetworks);
            uicontrol('Parent',Eventrasterplot,'Units','Pixels','Position',[5 40 50 25],'String','Undo','FontSize',8,'CallBack','');
            
            uicontrol('Parent',Eventrasterplot,'Style','Text','Units','Pixels','Position',[3 580 90 15],'String','Show Network:','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
            uicontrol('Parent',Eventrasterplot,'Style','popupmenu','Units','Pixels','Position',[25 560 65 15],'String','','Tag','Network','FontSize',8,'CallBack',@DrawLines);
            
            
            Popupfiller;
            
            %create Editmenu
            i = 1;
            NrEl = size(SPIKES,2);
            while i <= NrEl
                uicontrol('Parent',Eventrasterplot,'Units','Pixels','Position', [120 35+591/NrEl*i 20 591/NrEl],'String',Frequenzen(61-i,2),'Tag',['EL' num2str(61-i)],'HorizontalAlignment','right','FontSize',6,'Value',1,'Style','edit');
                
                i = i+1;
            end
            clear i NrEl;
            
            %create Rasterplot
            axes('Units','pixels','Position',[160 40 660 600],'YDir','reverse',...
                'YLim',[0 size(SPIKES,2)+1],'YColor',[.8 .8 .8],'YMinorGrid','on');
            for n=1:size(BURSTS,2) %#ok<FXUP>
                line ('Xdata',nonzeros(SPIKES(:,n)),...
                    'Ydata', n.*ones(1,length(nonzeros(SPIKES(:,n)))),...
                    'LineStyle','none','Marker','*',...
                    'MarkerFaceColor','green','MarkerSize',3);
                text(0,n,EL_NAMES(n),'HorizontalAlignment','right','FontSize',6);
            end
            xlabel ('time / s');
            figure (Eventrasterplot);
            
            DrawLines;
            
            function Popupfiller
                t = 'None';
                i = 2;
                j = 0;
                NrNetworks = max(Frequenzen(:,2));
                while i-1 <= NrNetworks && i-1<=99
                    if not(isempty(find(Frequenzen(:,2)==i-1,1)))
                        if fix((i-1)/10) == 0
                            t(i-j,:) = ['   ' num2str(i-1)];
                        else
                            t(i-j,:) = ['  ' num2str(i-1)];
                        end
                    else
                        j = j+1;
                    end
                    i = i+1;
                end
                set(findobj(gcf,'Tag','Network'),'String',t)
                if get(findobj(gcf,'Tag','Network'),'value') > size(t,1)
                    set(findobj(gcf,'Tag','Network'),'value',1)
                    DrawLines;
                end
                set(findobj(fh,'Tag','ChosenNW'),'String',t(2:end,:))
                if get(findobj(fh,'Tag','ChosenNW'),'value') > size(t,1)-1
                    set(findobj(fh,'Tag','ChosenNW'),'value',1)
                    DrawLines;
                end
                
                clear i NrNetworks t j;
            end
            
            
            function DrawLines(~,~)
                delete(findobj(0,'Tag','Spikeline'));   %delete all spikelines
                
                %find electrode of this group, which has the max. number of spikes
                Buttoninhalt = get(findobj(gcf,'Tag','Network'),'string');
                Auswahl = str2double(Buttoninhalt(get(findobj(gcf,'Tag','Network'),'value'),:));
                
                GroupI = find(Frequenzen(:,2)==Auswahl);
                [~,X] = max(Frequenzen(GroupI,1));
                Nr = GroupI(X);
                
                clear Buttoninhalt GroupI X;
                
                if Nr > 0
                    for n=1:size(nonzeros(SPIKES(:,Nr))) %#ok<FXUP>
                        line ('XData',[SPIKES(n,Nr) SPIKES(n,Nr)],'YData',[0 nr_channel],'Color','green','Tag','Spikeline');
                    end
                end
                
                i = 1;
                NrEl = size(SPIKES,2);
                while i <= NrEl
                    Group = get(findobj(gcf,'Tag',['EL' num2str(i)]),'String');
                    Group = str2double(Group);
                    if Group == Auswahl
                        set(findobj(gcf,'Tag',['EL' num2str(i)]),'BackgroundColor',[1,1,1]);
                    else
                        set(findobj(gcf,'Tag',['EL' num2str(i)]),'BackgroundColor',[0.8,0.8,0.8])
                    end
                    i = i+1;
                end
                clear i NrEl Auswahl;
            end
            
            function SetNetworks(~,~)
                i = 1;
                NrEl = size(SPIKES,2);
                while i <= NrEl
                    Group = get(findobj(gcf,'Tag',['EL' num2str(i)]),'String');
                    Group = str2double(Group);
                    if not(isempty(Group)) && mod(Group,1) == 0 && fix(Group/10) < 10
                        Frequenzen(i,2) = Group;
                    else
                        set(findobj(gcf,'Tag',['EL' num2str(i)]),'String','0')
                        Frequenzen(i,2) = 0;
                    end
                    i = i+1;
                end
                clear i NrEl;
                Popupfiller;
            end
        end
        
        
        % --- Timing-Function for Cardiac(FS)------------------------------------
        function delaycallfunction (source,event) %#ok
            SPACING = 0.2; %Distance of electrodes in mm
            
            en = get(findobj(gcf,'Tag','SpikeChoice'),'enable');
            TF = strcmp(en, 'on');
            ELS=char(EL_NAMES);                   % read Elektrode-names
            ELS=ELS(:,4:5);
            ELS = str2num(ELS); %#ok<ST2NM>
            RANK(1,:)= ELS';
            clear en;
            
            if get(findobj(gcf,'Tag','Separate'),'value') == 1
                Buttoninhalt = get(findobj(gcf,'Tag','ChosenNW'),'string');
                Auswahl = str2double(Buttoninhalt(get(findobj(gcf,'Tag','ChosenNW'),'value'),:));
                GroupI = find(Frequenzen(:,2)==Auswahl);
            else
                GroupI = linspace(1,60,60);
            end
            
            SPIKESCOPY = SPIKES(:,GroupI);
            
            Max = 0.2; %Max deviation of spikes from EVENTS in sec
            
            i = 1;
            while not(isempty(nonzeros(SPIKESCOPY)))
                Events(i) = min(nonzeros(SPIKESCOPY));
                SPIKESCOPY(SPIKESCOPY <= Events(i) + Max) = 0;
                i = i+1;
            end
            clear i;
            
            if get(findobj(gcf,'Tag','Separate'),'value') == 1
                SPIKESCOPY = SPIKES(:,GroupI);
            else
                SPIKESCOPY  = SPIKES;
            end
            x=1;
            y=1;
            while x < size(SPIKESCOPY,1)
                while y <= size(SPIKESCOPY,2)
                    if x < size(Events,2) && abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x,y)-Events(x+1))
                        SPIKESCOPY(end+1,y) = SPIKESCOPY(end,y);
                        SPIKESCOPY(x+1:end-1,y) = SPIKESCOPY(x:end-2,y);
                        SPIKESCOPY(x,y) = 0;
                    elseif abs(SPIKESCOPY(x,y)-Events(x)) > Max || x < size(Events,2) && ...
                            abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x+1,y)-Events(x))
                        
                        SPIKESCOPY(x:end-1,y) = SPIKESCOPY(x+1:end,y);
                        SPIKESCOPY(end,y) = 0;
                        if SPIKESCOPY(x,y) ~= 0
                            y = y-1;
                        end
                    end
                    while isempty(nonzeros(SPIKESCOPY(end,:)))
                        SPIKESCOPY(end,:) = [];
                    end
                    y = y+1;
                end
                x = x+1;
                y = 1;
            end
            clear x y;
            
            if TF==1
                
                spikenr = get(findobj(gcf,'Tag','SpikeChoice'),'value');
                if get(findobj(gcf,'Tag','Expert'),'value') == 0
                    close(gcbf);
                end
                RANK(2,GroupI) = SPIKESCOPY(spikenr,:);
                
                
                %Fill RANK
                ELSALL = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
                for n=1:size(ELSALL,2)
                    if isempty(find(RANK(1,:) == ELSALL(n), 1))
                        RANK(:,n+1:end+1) = RANK(:,n:end);
                        RANK(1,n) = ELSALL(n);
                        RANK(2,n) = 0;
                    end
                end
                clear n;
                Min = min(nonzeros(RANK(2,:)));
                RANK(3,:) = RANK(2,:)-Min;
                clear Min;
                
                %cellplot
                RANK(3,:)=RANK(3,:)*1000; % timedifference
                RANKCOPY = RANK(1:2,:);
                R(1:8,1:8) = -999;
                
                figure('Name','Ausbreitungsrichtung eines Spikes','Color',[1 1 1])
                
                for n=1:size(RANK,2)
                    EL = RANK(1,n);
                    if RANK(3,n) < 0
                        %Check which neighbors are presentand safes in Left,Right,Up,Down
                        if EL > 30 || EL > 20 && mod(EL,10) > 1 && mod(EL,10) < 8
                            Left = true;
                        else
                            Left = false;
                        end
                        if EL < 70 || EL < 80 && mod(EL,10) > 1 && mod(EL,10) < 8
                            Right = true;
                        else
                            Right = false;
                        end
                        if mod(EL,10) > 2 || mod(EL,10) > 1 && EL > 20 && EL < 80
                            Up = true;
                        else
                            Up = false;
                        end
                        if mod(EL,10) < 6 || mod(EL,10) < 8 && EL > 10 && EL < 80
                            Down = true;
                        else
                            Down = false;
                        end
                        
                        Summe = 0;
                        m = 0;
                        if Left
                            x = find(RANK(1,:) == EL-10);
                            if isempty(x) == 0 && RANK(3,x) >= 0 && RANK(4,x) == 0
                                Summe = Summe + RANK(3,x);
                                m = m+1;
                            else
                                Left = false;
                            end
                        end
                        if Right
                            x = find(RANK(1,:) == EL+10);
                            if isempty(x) == 0 && RANK(3,x) >= 0
                                Summe = Summe + RANK(3,x);
                                m = m+1;
                            else
                                Right = false;
                            end
                        end
                        if Up
                            x = find(RANK(1,:) == EL-1);
                            if isempty(x) == 0 && RANK(3,x) >= 0 && RANK(4,x) == 0
                                Summe = Summe + RANK(3,x);
                                m = m+1;
                            else
                                Up = false;
                            end
                        end
                        if Down
                            x = find(RANK(1,:) == EL+1);
                            if isempty(x) == 0 && RANK(3,x) >= 0
                                Summe = Summe + RANK(3,x);
                                m = m+1;
                            else
                                Down = false;
                            end
                        end
                        if Left && Right || Up && Down
                            RANK(3,n) = Summe/m;
                        else
                            RANK(3,n) = -999;
                        end
                        RANK(4,n) = 1; %safes if electrode was inactive
                        
                    else
                        RANK(4,n) = 0;
                    end
                    R(mod(EL,10),fix(EL/10)) = RANK(3,n);
                    
                end
                
                RI=interp2(R,5); %Interpolate
                
                %Delete corners
                for x=1:8
                    for y=1:8
                        if R(y,x) == -999
                            if y > 1
                                Up = true;
                            else
                                Up = false;
                            end
                            if y < 8
                                Down = true;
                            else
                                Down = false;
                            end
                            if x > 1
                                Left = true;
                            else
                                Left = false;
                            end
                            if x < 8
                                Right = true;
                            else
                                Right = false;
                            end
                            RI(y*32-31-Up*31:y*32-31+Down*31,x*32-31-Left*31:x*32-31+Right*31) = NaN;
                        end
                    end
                end
                
                pcolor(RI);shading('flat'); colormap('jet');
                
                %Test
                R(R==-999) = NaN;
                [X,Y] = meshgrid(33:32:193);
                [DX,DY] = gradient(R,1,1);
                hold on;
                quiver(X,Y,DX(2:end-1,2:end-1),DY(2:end-1,2:end-1),'Color',[0,0,0]);
                hold off;
                
                Grad = DY./DX;
                Velocity = zeros(size(R));
                
                for i=2:size(R,1)-1
                    for j=2:size(R,2)-1
                        if isnan(Grad(i,j)) == 0
                            if abs(Grad(i,j))<1
                                Velocity(i,j) = sqrt(1+Grad(i,j)^2)*SPACING*1000/(RI(round(i*32-31+abs(Grad(i,j))*sign(DY(i,j))*32),(j+sign(DX(i,j)))*32-31)-R(i,j));
                            else
                                Velocity(i,j) = sqrt(1+Grad(i,j)^(-2))*SPACING*1000/(RI((i+sign(DY(i,j)))*32-31,round(j*32-31+sign(DX(i,j))*abs(Grad(i,j))^-1*32))-R(i,j));
                            end
                        end
                    end
                end
                clear i j Grad;
                
                axis ij;
                axis off;
                title(['Spike ',num2str(spikenr)]);
                colorbar('location','EastOutside')
                
                for n=1:size(RANK,2)
                    EL = RANK(1,n);
                    if RANK(4,n) == 0
                        line ('Xdata',fix(EL/10)*32-31,'Ydata', mod(EL,10)*32-31,'Tag','',...
                            'LineStyle','none','Marker','o',...
                            'MarkerSize',9);
                    else
                        line ('Xdata',fix(EL/10)*32-31,'Ydata', mod(EL,10)*32-31,'Tag','',...
                            'LineStyle','none','Marker','o',...
                            'MarkerFaceColor',[0 0 0],'MarkerSize',9);
                    end
                end
                
                dcm_obj = datacursormode(gcf);
                set(dcm_obj,'DisplayStyle','datatip',...
                    'SnapToDataVertex','on','Enable','on','UpdateFcn',@DelayTag)
            end
            
            
            if TF==0
                
                if get(findobj(gcf,'Tag','Expert'),'value') == 0
                    close(gcbf);
                end
                figure('Name','Ausbreitungsrichtung der ersten 20. Spikes');
                ELSALL = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
                spikenr = 1;
                while spikenr <= size(SPIKESCOPY,1) && spikenr <= 20
                    
                    RANK(2,GroupI) = SPIKESCOPY(spikenr,:);
                    
                    for n=1:size(ELSALL,2)
                        if isempty(find(RANK(1,:) == ELSALL(n), 1))
                            RANK(:,n+1:end+1) = RANK(:,n:end);
                            RANK(1,n) = ELSALL(n);
                            RANK(2,n) = 0;
                        end
                    end
                    clear n;
                    Min = min(nonzeros(RANK(2,:)));
                    RANK(3,:) = RANK(2,:)-Min;
                    
                    %cellplot
                    RANK(3,:) = RANK(3,:)*1000;
                    R(1:8,1:8) = -999;
                    
                    for n=1:size(RANK,2)
                        EL = RANK(1,n);
                        if RANK(3,n) < 0
                            if EL > 30 || EL > 20 && mod(EL,10) > 1 && mod(EL,10) < 8
                                Left = true;
                            else
                                Left = false;
                            end
                            if EL < 70 || EL < 80 && mod(EL,10) > 1 && mod(EL,10) < 8
                                Right = true;
                            else
                                Right = false;
                            end
                            if mod(EL,10) > 2 || mod(EL,10) > 1 && EL > 20 && EL < 80
                                Up = true;
                            else
                                Up = false;
                            end
                            if mod(EL,10) < 6 || mod(EL,10) < 8 && EL > 10 && EL < 80
                                Down = true;
                            else
                                Down = false;
                            end
                            
                            Summe = 0;
                            m = 0;
                            if Left
                                x = find(RANK(1,:) == EL-10);
                                if isempty(x) == 0 && RANK(3,x) >= 0 && RANK(4,x) == 0
                                    Summe = Summe + RANK(3,x);
                                    m = m+1;
                                else
                                    Left = false;
                                end
                            end
                            if Right
                                x = find(RANK(1,:) == EL+10);
                                if isempty(x) == 0 && RANK(3,x) >= 0
                                    Summe = Summe + RANK(3,x);
                                    m = m+1;
                                else
                                    Right = false;
                                end
                            end
                            if Up
                                x = find(RANK(1,:) == EL-1);
                                if isempty(x) == 0 && RANK(3,x) >= 0 && RANK(4,x) == 0
                                    Summe = Summe + RANK(3,x);
                                    m = m+1;
                                else
                                    Up = false;
                                end
                            end
                            if Down
                                x = find(RANK(1,:) == EL+1);
                                if isempty(x) == 0 && RANK(3,x) >= 0
                                    Summe = Summe + RANK(3,x);
                                    m = m+1;
                                else
                                    Down = false;
                                end
                            end
                            if Left && Right || Up && Down
                                RANK(3,n) = Summe/m;
                            else
                                RANK(3,n) = -999;
                            end
                            RANK(4,n) = 1;
                            
                        else
                            RANK(4,n) = 0;
                            
                        end
                        R(mod(EL,10),fix(EL/10)) = RANK(3,n);
                        
                    end
                    RI=interp2(R,5);
                    
                    for x=1:8
                        for y=1:8
                            if R(y,x) == -999
                                if y > 1
                                    Up = true;
                                else
                                    Up = false;
                                end
                                if y < 8
                                    Down = true;
                                else
                                    Down = false;
                                end
                                if x > 1
                                    Left = true;
                                else
                                    Left = false;
                                end
                                if x < 8
                                    Right = true;
                                else
                                    Right = false;
                                end
                                RI(y*32-31-Up*31:y*32-31+Down*31,x*32-31-Left*31:x*32-31+Right*31) = NaN;
                            end
                        end
                    end
                    
                    % Plot
                    subplot (4,5,spikenr);
                    pcolor(RI);shading flat; colormap(jet);
                    axis ij;
                    axis off;
                    title(['Spike Nr:',num2str(spikenr)]);
                    
                    spikenr = spikenr+1;
                end
                clear SPIKESCOPY Min;
                
            end
            
            clear RANK;
            clear m n Summe;
            clear Up Down Left Right;
            
            
            %Option to show timedifference if marked
            function txt = DelayTag (~,event_obj)
                
                dcm_obj = datacursormode(gcf);
                pos = get(event_obj,'Position');
                txt = {RI(pos(2),pos(1))};
                
                
            end
            
        end
        
    end


% --- 3D Darstelung ---------------------------

    function Eventprocessing(source,event)
        
        %  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        %  ~~ Variables & Initialisation ~~
        %  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        SP_All = [];
        MinMaxOverlay = 0;
        SelectWindow = 0;
        counter = 0;
        time_start =0 ;
        SPIKESCOP = SPIKES;
        Num_Spikes = 3:20;
        PlotHandler = 0;
        CurrentMatrix = 0;
        SingleSpikePlot = 0;
        CurGcf = 0;
        EventIndexArray = 0;
        EventArray = cell(1,1);
        EventArrayBackup = cell(1,1);
        EventIndexBackupArray = 0;
        Num_dense = 1:5;
        MinMax = [];
        Laenge = 0.5; %lenght of window
        Vorlauf = 0.1; %start window in Overlaygraph
        SPIKESCUT = zeros(size(SPIKES,1),1); %spikes that cant be shown due to the timewindow
        SPIKESDEL = zeros(size(SPIKES));
        SpkInfo = 0;
        FigureVid = 0;
        CheckboxArray = 0;
        DrawLineArray = {};
        DrawLineCounter = 0;
        LineArray = 0;
        dcm_obj = 0;
        
        ISI=[];
        ISIStdAll=0;
        MaxValElArray=[];
        MaxValStdAll=0;
        MinValElArray=[];
        MinValStdAll=0;
        QTElArray=[];
        QTStdAll=0;
        BeatRate=[];
        ISITemp = 0;
        MaxValTemp=0;
        MinValTemp=0;
        QTTemp=0;
        
        Export_CV = [];
        %  ~~~~~~~~~~~~~~~~~~
        %  ~~ GUI-Framwork ~~
        %  ~~~~~~~~~~~~~~~~~~
        
        
        %Mainwindow Signal Propagation
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        SpkDisplay = figure('Name','Signal Propagation','NumberTitle','off','Position',[60 80 560 800],'Toolbar','none','Resize','off','Color',[0.89 0.89 0.99]);
        
        %Mainwindow - Velocity Checkbox
        uicontrol('Parent',SpkDisplay,'Units','Pixels','Position', [230 385 110 25],'Tag','Velocity Vectors','String','Velocity Vectors','Enable','off','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Shows or hides velocity vectors','callback',@DrawEvent);
        uicontrol('Parent',SpkDisplay,'Units','Pixels','Position', [380 385 110 25],'Tag','Contour Lines','String','Contour Lines','Enable','off','Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Shows or hides contour lines','callback',@DrawEvent);
        
        uicontrol('Parent',SpkDisplay,'Style', 'text','Position', [361 350 100 25],'String', 'Line density ','FontSize',8,'BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpkDisplay,'Units','Pixels','Position', [445 353 40 25],'Tag','contour_density','FontSize',8,'String',Num_dense,'Value',1,'Style','popupmenu','callback',@DrawEvent);
        
        %Mainwindow - Choosing a spike
        uicontrol('Parent',SpkDisplay,'Style', 'text','Position', [30 380 100 25],'String', 'Event ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpkDisplay,'Units','Pixels','Position', [140 383 50 25],'Tag','Spikeauswahl','FontSize',8,'Value',1,'Style','popupmenu','callback',@DrawEvent);
        
        uicontrol('Parent',SpkDisplay,'Style', 'text','Position', [29 340 100 25],'String', 'Signal path','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpkDisplay,'Units','Pixels','Position', [140 342 50 25],'Tag','start_line','FontSize',8,'String','Start','Style','PushButton','callback',@drawLine);
        uicontrol('Parent',SpkDisplay,'Units','Pixels','Position', [200 342 50 25],'Tag','end_line','FontSize',8,'String','Stop','Enable','off','Style','PushButton','callback',@drawLineEnd);
        
        %Result Window
        RsltWindow = uipanel('Parent',SpkDisplay,'Units','pixels','Position',[25 25 520 230],'BackgroundColor', GUI_Color_BG);
        
        %Result Window - Current spike text
        CurSpike = uicontrol('Parent',RsltWindow,'Style', 'text','Position', [5 190 100 25],'String', 'Spike:  ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [200 190 100 25],'String', 'Mean ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [270 190 100 25],'String', 'Std ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [340 190 100 25],'String', 'Median ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Result Window - Image values
        
        %Distance
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [5 155 100 25],'String', 'Distance: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        RsltDistance = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [95 158 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [155 155 40 25],'String', 'mm ','FontSize',9,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Time
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [5 120 100 25],'String', 'Time: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        RsltTime = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [95 123 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [155 120 34 25],'String', 'ms','FontSize',9,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Velocity
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [5 85 100 25],'String', 'Velocity: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        RsltVelocity = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [95 88 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [155 85 50 25],'String', 'mm/s','FontSize',9,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Result Window - Mean and std values
        
        %Distance
        MeanDistance = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [220 158 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        StdDistance = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [290 158 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        MedianDistance = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [360 158 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [425 155 35 25],'String', 'mm ','FontSize',9,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Time
        MeanTime = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [220 123 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        StdTime = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [290 123 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        MedianTime = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [360 123 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [425 120 30 25],'String', 'ms','FontSize',9,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Velocity
        MeanVelocity = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [220 88 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        StdVelocity = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [290 88 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        MedianVelocity = uicontrol ('Parent',RsltWindow,'Units','Pixels','Position', [360 88 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',RsltWindow,'Style', 'text','Position', [422 85 50 25],'String', 'mm/s','FontSize',9,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',RsltWindow,'Position', [15 10 80 25],'String','Raster Plot','FontSize',8,'TooltipString','Rasterplot','callback',@gridPlot);
        uicontrol('Parent',RsltWindow,'Position', [100 10 80 25],'Tag','3D','String','3D','Enable','off','FontSize',8,'TooltipString','3D View','callback',@threeDimension);
        uicontrol('Parent',RsltWindow,'Position', [185 10 80 25],'Tag','Event','String','Select Events','FontSize',8,'TooltipString','Chosing which Events will be used for mean and std values','callback',@drawSelection);
        uicontrol('Parent',RsltWindow,'Position', [270 10 80 25],'Tag','Video','Enable','off','String','Video','FontSize',8,'TooltipString','Video','callback',@video)
        uicontrol('Parent',RsltWindow,'Position', [355 10 80 25],'String','Help','FontSize',8,'TooltipString','Help','callback',@HelpPropagation);
        
        %Main Window Spike Analyses
        %~~~~~~~~~~~~~~~~~~~~~~~~~~
        SingleSpk = figure('Name','Spike Analysis','NumberTitle','off','Position',[635 80 720 800],'Toolbar','none','Resize','off','Color',[0.89 0.89 0.99]);
        
        uicontrol('Parent',SingleSpk,'Position', [200 374 80 25],'String','Select','FontSize',8,'TooltipString','Video','callback',@Select)
        Skala = uicontrol('Parent',SingleSpk,'Units','Pixels','Position', [110 372 75 25],'Tag','Skala','FontSize',8,'String',['  50 uV';' 100 uV';' 200 uV';' 500 uV';'1000 uV'],'Value',1,'Style','popupmenu','callback',@drawSingleSpike); %get(findobj(leftPanel,'Tag','CELL_scaleBox'),'value')
        uicontrol('Parent',SingleSpk,'Style', 'text','Position', [40 370 60 25],'String', 'Scale','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',SingleSpk,'Style', 'text','Position', [300 372 75 25],'String', 'Range: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SingleSpk,'Units','Pixels','Position', [367 375 50 25],'String',900,'Tag','Laenge','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit','callback',@drawSingleSpike);
        uicontrol('Parent',SingleSpk,'Style', 'text','Position', [425 372 25 25],'String', 'ms','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SingleSpk,'Style', 'text','Position', [455 372 75 25],'String', 'Buffer:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SingleSpk,'Units','Pixels','Position', [522 375 50 25],'String',100,'Tag','Vorlauf','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit','callback',@drawSingleSpike);
        uicontrol('Parent',SingleSpk,'Style', 'text','Position', [580 372 25 25],'String', 'ms','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Value Window - Values from the Spike Analyses
        
        ValWindow = uipanel('Parent',SingleSpk,'Units','pixels','Position',[10 10 700 330],'BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [10 10 135 25],'String', 'Active Elektrodes: 0','Tag','ActiveEL','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [120 290 50 25],'String', 'Spike','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Units','Pixels','Position', [175 293 50 25],'Tag','Single_Spike','FontSize',8,'String','bla','Value',1,'Style','popupmenu','callback',@drawSingleSpike);
        
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [290 290 30 25],'String', 'EL','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Units','Pixels','Position', [330 293 50 25],'Tag','EL_Num','FontSize',8,'String',EL_NAMES,'Value',1,'Style','popupmenu','callback',@spikeNum);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [259 260 50 25],'String', 'Mean','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [319 260 50 25],'String', 'Std','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [384 260 50 25],'String', 'Median','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [520 290 100 25],'String', 'All EL','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [485 260 50 25],'String', 'Mean','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [545 260 50 25],'String', 'Std','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [610 260 50 25],'String', 'Median','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Value Window - Beat Rate
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [5 240 100 25],'String', 'Beat Rate','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Units','Pixels','Position', [147 240 50 25],'String','-','Tag','BR_Spike','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [203 237 20 25],'String', 'Hz','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        BeatRateMeanEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [260 240 50 25],'String','','Tag','BeatRateMeanEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        BeatRateStdEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [322 240 50 25],'String','-','Tag','BeatRateStdEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        BeatRateMedianEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [386 240 50 25],'String','-','Tag','BeatRateMedianEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [440 237 20 25],'String', 'Hz','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        BeatRateMeanAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [485 240 50 25],'String','','Tag','BeatRateMeanAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        BeatRateStdAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [547 240 50 25],'String','','Tag','BeatRateStdAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        BeatRateMedianAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [611 240 50 25],'String','','Tag','BeatRateMedianAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [666 237 20 25],'String', 'Hz','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        
        %Value Window - ISI
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [5 205 100 25],'String', 'ISI','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Units','Pixels','Position', [147 205 50 25],'String','-','Tag','ISI_Spike','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [203 202 20 25],'String', 's','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        ISIMeanEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [260 205 50 25],'String','','Tag','ISIMeanEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        ISIStdEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [322 205 50 25],'String','','Tag','ISIStdEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        ISIMedianEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [386 205 50 25],'String','-','Tag','ISIMedianEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [440 202 20 25],'String', 's','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        ISIMeanAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [485 205 50 25],'String','','Tag','ISIMeanAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        ISIStdAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [547 205 50 25],'String','','Tag','ISIStdAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        ISIMedianAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [611 205 50 25],'String','','Tag','ISIMedianAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [666 202 20 25],'String', 's','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        
        %Value Window - QT interval
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [5 170 100 25],'String', 'QT','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [203 167 20 25],'String', 's','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        QTSpike = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [147 170 50 25],'String','','Tag','QTSpike','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        QTMeanEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [260 170 50 25],'String','','Tag','QTMeanEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        QTStdEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [322 170 50 25],'String','','Tag','QTStdEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        QTMedianEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [386 170 50 25],'String','','Tag','QTMedianEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [440 167 20 25],'String', 's','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        QTMeanAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [485 170 50 25],'String','','Tag','QTMeanAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        QTStdAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [547 170 50 25],'String','','Tag','QTStdAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        QTMedianAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [611 170 50 25],'String','','Tag','QTMedianAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [666 167 20 25],'String', 's','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Value Window - Maximum Amplitude
        
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [5 135 100 25],'String', 'Amp Max','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [203 132 20 25],'String', 'µV','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        MaxValSpike = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [147 135 50 25],'String','','Tag','MaxValSpike','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        MaxValMeanEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [260 135 50 25],'String','','Tag','MaxValMeanEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        MaxValStdEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [322 135 50 25],'String','','Tag','MaxValStdEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        MaxValMedianEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [386 135 50 25],'String','','Tag','MaxValMedianEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [440 132 20 25],'String', 'µV','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        MaxValMeanAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [485 135 50 25],'String','','Tag','MaxValMeanAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        MaxValStdAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [547 135 50 25],'String','','Tag','MaxValStdAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        MaxValMedianAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [611 135 50 25],'String','','Tag','MaxValMedianAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [666 132 20 25],'String', 'µV','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Value Window - Minimum Amplitude
        
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [5 100 100 25],'String', 'Amp Min','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [203 97 20 25],'String', 'µV','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        MinValSpike = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [147 100 50 25],'String','','Tag','MinValSpike','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        MinValMeanEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [260 100 50 25],'String','','Tag','MinValMeanEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        MinValStdEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [322 100 50 25],'String','','Tag','MinValStdEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        MinValMedianEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [386 100 50 25],'String','','Tag','MinValMedianEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [440 97 20 25],'String', 'µV','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        MinValMeanAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [485 100 50 25],'String','','Tag','MinValMeanAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        MinValStdAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [547 100 50 25],'String','','Tag','MinValStdAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        MinValMedianAllEl = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [611 100 50 25],'String','','Tag','MinValMedianAllEl','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [666 97 20 25],'String', 'µV','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        
        %Value Window - Export
        
        uicontrol('Parent',ValWindow,'Position', [15 70 80 25],'String','Export to .xls','FontSize',8,'TooltipString','Video','callback',@singleSpikeExport)
        
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [240 10 75 25],'String', 'QT Manuel','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [380 10 20 25],'String', 's','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        QTManual = uicontrol('Parent',ValWindow,'Units','Pixels','Position', [322 13 50 25],'String','','Tag','QTManual','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [420 10 75 25],'String', 'QT Range: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Units','Pixels','Position', [500 13 50 25],'String',0,'Tag','QTR_Start','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit','callback',@QTRange);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [550 10 25 25],'String', '-','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Units','Pixels','Position', [580 13 50 25],'String',0,'Tag','QTR_End','HorizontalAlignment','center','FontSize',8,'Value',1,'Style','edit','callback',@QTRange);
        uicontrol('Parent',ValWindow,'Style', 'text','Position', [635 10 25 25],'String', 'ms','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ValWindow,'Units','Pixels','Position', [420 40 110 25],'Tag','AllEL','String','All Electrodes','Enable','on','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'callback',@QTRange);
        uicontrol('Parent',ValWindow,'Units','Pixels','Position', [625 365 75 25],'Tag','Overlay','String','Overlay','Enable','on','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'callback',@drawSingleSpike);
        %~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        %  ~~~~~~~~~~~~~~~
        %  ~~ Functions ~~
        %  ~~~~~~~~~~~~~~~
        
        %   brief - Counting the active number of electodes
        AktEl = 0;
        for j=1:size(SPIKES,2)
            if isempty(nonzeros(SPIKES(:,j))) == 0
                AktEl = AktEl + 1;
            end
        end
        set(findobj(gcf,'Tag','ActiveEL'),'string',['Active Electrodes: ',num2str(AktEl)]);
        clear j;
  
        %   brief - Preparing the initial set of Spikes
        n = 1;
        while n <= size(SPIKES,1) && n <= 99
            if fix(n/10) == 0
                t(n,:) = [' ' num2str(n)];
            else
                t(n,:) = num2str(n);
            end
            n = n+1;
        end
        set(findobj(SpkDisplay,'Tag','Spikeauswahl'),'String',t);
        
        %   Initialising functions for Eventprocessing
        eventSelection();
        
        FindPoints();
        
        singleSpikeParameters();
        
        spikeNum();
        
        DrawEvent();
        
        QTOverlay();
        
         
        %   brief - Enabling the data cursor mode to be able to
        %           interact with the propagation image to obtain
        %           coordinates and the related image values
        function drawLine(~,~)
            
            if LineArray ~= 0               %Resets the line array to delete previously drawn lines
                delete(LineArray);
                LineArray = 0;
            end
            
            DrawLineCounter = 0;
            DrawLineArray = {};
            
            set(findobj(SpkDisplay,'Tag','start_line'),'Enable','off')
            set(findobj(SpkDisplay,'Tag','end_line'),'Enable','on')
            
            dcm_obj = datacursormode(SpkDisplay);   %Initializes the cursor mode in the SpkDisplay window
            set(dcm_obj,'DisplayStyle','window','SnapToDataVertex','on','Enable','on','UpdateFcn',@Delay);
            
            function txt = Delay (~,event_obj)
                pos = get(event_obj,'Position');
                txt = {CurrentMatrix(pos(2),pos(1))};
                
                pos = pos(1,1:2);
                
                DrawLineCounter = DrawLineCounter +1;
                DrawLineArray{DrawLineCounter} = pos;
            end
        end
        
        %   brief - Disables the data cursor mode and processes the
        %           data points which were obtained during the drawLine runtime
        function drawLineEnd(~,~)
            LineDistance = 0;
            LineTime = 0;
            
            datacursormode off;
            set(dcm_obj,'Enable','off')
            set(findobj(SpkDisplay,'Tag','end_line'),'Enable','off')
            set(findobj(SpkDisplay,'Tag','start_line'),'Enable','on')
            
            
            for n = 1:size(DrawLineArray,2)-1   %Calculating distance and time difference between each point
                
                CoordA = DrawLineArray{n};
                CoordB = DrawLineArray{n+1};
                
                LineArray(n) = line([CoordA(1) CoordB(1)],[CoordA(2) CoordB(2)],'LineWidth',2,'color',[0 0 0]); %Draws a line inside the propagation image and saves the handel inside a array
                
                TempDistance = sqrt((CoordB(1) - CoordA(1))^2+(CoordB(2) - CoordA(2))^2);
                TempTime = CurrentMatrix(CoordB(2),CoordB(1))-CurrentMatrix(CoordA(2),CoordA(1));
                LineDistance = LineDistance + TempDistance;
                LineTime = LineTime + TempTime;
            end
            
            LineDistance = LineDistance*0.2/32; %Converting the distance to millimeter
            LineVelocity = 1000*LineDistance/LineTime;
            
            set(RsltTime,'String',LineTime);
            set(RsltDistance,'String',LineDistance);
            set(RsltVelocity,'String',LineVelocity);
            
            propagationParameter(DrawLineArray);
        end
        
        %   brief - Calculates the mean, std and median of the
        %           propagation parameters over every selected
        %           signal propagation image
        function propagationParameter(DrawLineArray)
            R = 0;
            RI = 0;
            PropagationMeanDist = 0;
            PropagationMeanTime = 0;
            
            ELS=char(EL_NAMES);
            ELS=ELS(:,4:5);
            ELS = str2num(ELS);
            RANK(1,:)= ELS';
            
            GroupI = linspace(1,60,60);
            SPIKESCOPY = SPIKES(:,GroupI);
            
            Max = 0.2;
            
            n = 1;
            while not(isempty(nonzeros(SPIKESCOPY)))
                Events(n) = min(nonzeros(SPIKESCOPY));
                SPIKESCOPY(SPIKESCOPY <= Events(n) + Max) = 0;
                n = n+1;
            end
            clear i;
            
            SPIKESCOPY  = SPIKES;
            
            x=1;
            y=1;
            while x < size(SPIKESCOPY,1)
                while y <= size(SPIKESCOPY,2)
                    if x < size(Events,2) && abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x,y)-Events(x+1))
                        SPIKESCOPY(end+1,y) = SPIKESCOPY(end,y);
                        SPIKESCOPY(x+1:end-1,y) = SPIKESCOPY(x:end-2,y);
                        SPIKESCOPY(x,y) = 0;
                    elseif abs(SPIKESCOPY(x,y)-Events(x)) > Max || x < size(Events,2) && ...
                            abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x+1,y)-Events(x))
                        
                        SPIKESCOPY(x:end-1,y) = SPIKESCOPY(x+1:end,y);
                        SPIKESCOPY(end,y) = 0;
                        if SPIKESCOPY(x,y) ~= 0
                            y = y-1;
                        end
                    end
                    while isempty(nonzeros(SPIKESCOPY(end,:)))
                        SPIKESCOPY(end,:) = [];
                    end
                    y = y+1;
                end
                x = x+1;
                y = 1;
            end
            clear x y;
            
            for i = 1:1:size(EventIndexArray,2)
                BufferDistance = 0;
                BufferTime = 0;
                
                SPIKE = EventIndexArray(i);
                
                RANK(2,GroupI) = SPIKESCOPY(SPIKE,:);
                
                [R,RI,RANK] = eventProcess(RANK);
                
                for j = 1:size(DrawLineArray,2)-1
                    CoordA = DrawLineArray{j};
                    CoordB = DrawLineArray{j+1};
                    
                    TempDistance = sqrt((CoordB(1) - CoordA(1))^2+(CoordB(2) - CoordA(2))^2);
                    TempTime = RI(CoordB(2),CoordB(1))-RI(CoordA(2),CoordA(1));
                    
                    BufferDistance = BufferDistance + TempDistance;
                    BufferTime = BufferTime + TempTime;
                end
                
                if i == 1
                    PropagationMeanDist = BufferDistance;
                    PropagationMeanTime = BufferTime;
                else
                    PropagationMeanDist = [PropagationMeanDist, BufferDistance];
                    PropagationMeanTime = [PropagationMeanTime, BufferTime];
                end
            end
            
            PropagationMeanDist = PropagationMeanDist.*(0.2/32);
            
            set(StdTime,'String',std(PropagationMeanTime));
            set(StdDistance,'String',std(PropagationMeanDist));
            set(StdVelocity,'String',std(1000*PropagationMeanDist./PropagationMeanTime));
            
            set(MeanTime,'String',mean(PropagationMeanTime));
            set(MeanDistance,'String',mean(PropagationMeanDist));
            set(MeanVelocity,'String',mean(1000*PropagationMeanDist./PropagationMeanTime));
            
            set(MedianTime, 'String',median(PropagationMeanTime));
            set(MedianDistance,'String',median(PropagationMeanDist));
            set(MedianVelocity,'String',median(1000*PropagationMeanDist./PropagationMeanTime));
            
            Export_CV = [mean(PropagationMeanDist), mean(PropagationMeanTime), mean(1000*PropagationMeanDist./PropagationMeanTime); std(PropagationMeanDist), std(PropagationMeanTime), std(1000*PropagationMeanDist./PropagationMeanTime); median(PropagationMeanDist), median(PropagationMeanTime), median(1000*PropagationMeanDist./PropagationMeanTime)];
        end
        
        %   brief - Creates a normal and a backup Array of Events for later usage
        function eventSelection(~,~)
            EventIndexArray = [];
            EventIndexBackupArray = [];
            EventArrayBackup = {};
            EventArray = {};
            
            ELS=char(EL_NAMES);
            ELS=ELS(:,4:5);
            ELS = str2num(ELS);
            RANK(1,:)= ELS';
            
            GroupI = linspace(1,60,60);
            SPIKESCOPY = SPIKES(:,GroupI);
            
            Max = 0.2;
            
            n = 1;
            while not(isempty(nonzeros(SPIKESCOPY)))
                Events(n) = min(nonzeros(SPIKESCOPY));
                SPIKESCOPY(SPIKESCOPY <= Events(n) + Max) = 0;
                n = n+1;
            end
            
            SPIKESCOPY  = SPIKES;
            x=1;
            y=1;
            while x < size(SPIKESCOPY,1)
                while y <= size(SPIKESCOPY,2)
                    if x < size(Events,2) && abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x,y)-Events(x+1))
                        SPIKESCOPY(end+1,y) = SPIKESCOPY(end,y);
                        SPIKESCOPY(x+1:end-1,y) = SPIKESCOPY(x:end-2,y);
                        SPIKESCOPY(x,y) = 0;
                    elseif abs(SPIKESCOPY(x,y)-Events(x)) > Max || x < size(Events,2) && abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x+1,y)-Events(x))
                        SPIKESCOPY(x:end-1,y) = SPIKESCOPY(x+1:end,y);
                        SPIKESCOPY(end,y) = 0;
                        if SPIKESCOPY(x,y) ~= 0
                            y = y-1;
                        end
                    end
                    while isempty(nonzeros(SPIKESCOPY(end,:)))
                        SPIKESCOPY(end,:) = []; 
                    end
                    y = y+1;
                end
                x = x+1;
                y = 1;
            end
            clear x y;
            
            i = 1;
            j = size(SPIKES,1);
            for Spike = 1:1:size(SPIKESCOPY,1) % MC: changed SPIKES to SPIKESCOPY
                
                if sum(SPIKESCOPY(Spike,:) == 0) < size(SPIKESCOPY,2)*0.9 %Checks for a minimum number of timestamps during an event
                    
                    %Depending on the numbers of Spikes detected during one
                    %measurement, different cases have to be handled while
                    %filling the options for the drop down menu
                    if j < 10
                        k(i,:) = num2str(Spike);
                        set(findobj(SpkDisplay,'Tag','Spikeauswahl'),'String',k);
                    elseif j >= 10 && j < 100
                        if Spike < 10
                            k(i,:) = [' ' num2str(Spike)];
                        else
                            k(i,:) = num2str(Spike);
                        end
                        set(findobj(SpkDisplay,'Tag','Spikeauswahl'),'String',k);
                    elseif j >= 100
                        if Spike < 10
                            k(i,:) = [' ' ' ' num2str(Spike)];
                        elseif Spike >= 10 && Spike < 100
                            k(i,:) = [' ' num2str(Spike)];
                        else
                            k(i,:) = num2str(Spike);
                        end
                        set(findobj(SpkDisplay,'Tag','Spikeauswahl'),'String',k);
                    end
                    
                    RANK(2,GroupI) = SPIKESCOPY(Spike,:);
                    
                    [R,RI,RANK] = eventProcess(RANK);
                    
                    EventArrayBackup{i} = RI;
                    EventArray{i} = RI;
                    
                    i = i+1;
                    
                    if EventIndexArray == 0
                        EventIndexArray = Spike;
                        EventIndexBackupArray = Spike;
                    else
                        EventIndexArray = [EventIndexArray Spike];
                        EventIndexBackupArray = [EventIndexBackupArray Spike];
                    end
                end
            end
            
        end
        
        %   brief - Allows to select which events will be used for the
        %           calculation of the propagation parameters
        function drawSelection(~,~)
            RemoveUncheckedButton = 0;
            PlotQuantity = 0;
            SliderCon = 1;
            
            SelectWindow = figure('Units','Pixels','Position',[300 360 340 200],'Name','Spike auswï¿½hlen','NumberTitle','off','Toolbar','none','Resize','off','menubar','none','Color',[0.89 0.89 0.99]);
            uicontrol('Parent',SelectWindow,'style','text','BackgroundColor', GUI_Color_BG,'FontSize',10,'units','Pixels', 'position', [20 80 300 100],'String','Selection of all Events that can be removed');
            RemoveUncheckedButton = uicontrol(SelectWindow,'Style','PushButton','Units','Pixels','Position',[95 10 110 35],'Tag','remove','String','Remove Unchecked','Enable','on','CallBack',@removeUnchecked);
            RemoveCheckedButton = uicontrol(SelectWindow,'Style','PushButton','Units','Pixels','Position',[95 50 110 35],'Tag','remove_check','String','Remove Checked','Enable','on','CallBack',@removeChecked);
            uicontrol(SelectWindow,'Style','PushButton','Units','Pixels','Position',[225 50 110 35],'String','Undo','CallBack',@undo);
            uicontrol(SelectWindow,'Style','PushButton','Units','Pixels','Position',[225 10 110 35],'String','Confirm','CallBack',@confirm);
            
            EventFigures = figure;
            
            for i = 1:16
                CoordX = mod(i,4)-1;
                if mod(i,4) == 0
                    CoordX = 3;
                end
                CoordY = floor(mod((i-1)/4,4));
                CheckboxArray(i) = uicontrol('Parent',EventFigures,'Units','Pixels','Position', [55+115*CoordX 400-95*CoordY 15 15],'Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG);
            end
            
            PlotArray = 0;
            
            uicontrol('Parent',EventFigures,'style', 'slider','Min',0,'Max',SliderCon,'SliderStep',[1 1]./SliderCon,'value',SliderCon,'Tag','c_slider','Enable','off','units', 'pixels', 'position', [530 120 20 200],'callback',@redraw);
            
            if size(EventIndexArray,2) > 16
                PlotQuantity = 16;
                set(findobj(EventFigures,'Tag','c_slider'),'Enable','on');
                set(findobj(EventFigures,'Tag','c_slider'),'Max',ceil((size(EventIndexArray,2)-16)/4));
                set(findobj(EventFigures,'Tag','c_slider'),'SliderStep',[1 1]./ceil((size(EventIndexArray,2)-16)/4));
                set(findobj(EventFigures,'Tag','c_slider'),'Value',ceil((size(EventIndexArray,2)-16)/4));
            else
                PlotQuantity = size(EventIndexArray,2);
            end
            
            for n = 1:1:PlotQuantity
                PlotArray(n) = subplot (4,4,n);
                pcolor(cell2mat(EventArray(n)));shading flat; colormap(jet);
                axis ij;
                axis off;
                title(num2str(EventIndexArray(n)));
            end
            
            set(PlotArray,'visible','off');
            
            if isempty(EventIndexArray)
                set(findobj(SelectWindow,'Tag','removeUnchecked'),'Enable','off');
            end
            
            function confirm(~,~)
                close(SelectWindow);
                close(EventFigures);
                
                Correcture = EventIndexArray;
                
                set(findobj(SpkDisplay,'Tag','Spikeauswahl'),'String',Correcture);
                set(findobj(SpkDisplay,'Tag','Spikeauswahl'),'value',1);
            end
            
            function undo(~,~)
                EventArray = EventArrayBackup;
                EventIndexArray = EventIndexBackupArray;
                
                if size(EventIndexArray,2) > 16
                    set(findobj(EventFigures,'Tag','c_slider'),'Max',ceil((size(EventIndexArray,2)-16)/4));
                    set(findobj(EventFigures,'Tag','c_slider'),'SliderStep',[1 1]./ceil((size(EventIndexArray,2)-16)/4));
                    set(findobj(EventFigures,'Tag','c_slider'),'Value',ceil((size(EventIndexArray,2)-16)/4));
                end
                
                redraw();
            end
            
            function removeUnchecked(~,~)
                SliderPos = get(findobj(EventFigures,'Tag','c_slider'),'value');
                SliderMax = get(findobj(EventFigures,'Tag','c_slider'),'Max');
                SliderPos = round(SliderPos);
                
                set(findobj(EventFigures,'Tag','c_slider'),'value',SliderPos);
                
                if SliderMax-SliderPos == SliderMax && mod(size(EventArray,2)-16,4) > 0
                    PlotMod = mod(size(EventArray,2)-16,4);
                else
                    PlotMod = 4;
                end
                
                i = 1;
                j = 0;
                for n = (1+(4*(SliderMax-SliderPos))):(16+(PlotMod+4*(SliderMax-SliderPos-1)))
                    if get(CheckboxArray(i),'value') == 0 && n-j <= size(EventArray,2)
                        DeleteEvent = n;
                        EventIndexArray(DeleteEvent-j) = [];
                        EventArray(DeleteEvent-j) = [];
                        set(CheckboxArray(i),'value',0);
                        j = j+1;
                    end
                    i = i + 1;
                end
                
                if size(EventIndexArray,2) > 16
                    set(findobj(EventFigures,'Tag','c_slider'),'Max',ceil((size(EventIndexArray,2)-16)/4));
                    set(findobj(EventFigures,'Tag','c_slider'),'SliderStep',[1 1]./ceil((size(EventIndexArray,2)-16)/4));
                    set(findobj(EventFigures,'Tag','c_slider'),'Value',ceil((size(EventIndexArray,2)-16)/4));
                end
                
                redraw();
            end
            
            function removeChecked(~,~)
                SliderPos = get(findobj(EventFigures,'Tag','c_slider'),'value');
                SliderMax = get(findobj(EventFigures,'Tag','c_slider'),'Max');
                SliderPos = round(SliderPos);
                
                set(findobj(EventFigures,'Tag','c_slider'),'value',SliderPos);
                
                if SliderMax-SliderPos == SliderMax && mod(size(EventArray,2)-16,4) > 0
                    PlotMod = mod(size(EventArray,2)-16,4);
                else
                    PlotMod = 4;
                end
                
                i = 1;
                j = 0;
                for n = (1+(4*(SliderMax-SliderPos))):(16+(PlotMod+4*(SliderMax-SliderPos-1)))
                    if get(CheckboxArray(i),'value') == 1 && n-j <= size(EventArray,2)
                        DeleteEvent = n;
                        EventIndexArray(DeleteEvent-j) = [];
                        EventArray(DeleteEvent-j) = [];
                        set(CheckboxArray(i),'value',0);
                        j = j+1;
                    end
                    i = i + 1;
                end
                
                if size(EventIndexArray,2) > 16
                    set(findobj(EventFigures,'Tag','c_slider'),'Max',ceil((size(EventIndexArray,2)-16)/4));
                    set(findobj(EventFigures,'Tag','c_slider'),'SliderStep',[1 1]./ceil((size(EventIndexArray,2)-16)/4));
                    set(findobj(EventFigures,'Tag','c_slider'),'Value',ceil((size(EventIndexArray,2)-16)/4));
                end
                
                redraw();
            end
            
            function redraw(~,~)
                for CheckboxCount = 1:size(CheckboxArray,2)
                    set(CheckboxArray(CheckboxCount),'value',0);
                end
                
                if size(EventArray,2) > 16
                    figure(EventFigures);
                    set(findobj(EventFigures,'Tag','c_slider'),'Enable','on');
                    if size(PlotArray,2) > 16
                        for k = 1:16
                            cla(PlotArray(k),'reset');
                        end
                    else
                        for k = 1:size(PlotArray,2)
                            cla(PlotArray(k),'reset');
                        end
                    end
                    
                    SliderPos = get(findobj(EventFigures,'Tag','c_slider'),'value');
                    SliderMax = get(findobj(EventFigures,'Tag','c_slider'),'Max');
                    SliderPos = round(SliderPos);
                    set(findobj(EventFigures,'Tag','c_slider'),'value',SliderPos);
                    
                    if SliderMax-SliderPos == SliderMax && mod(size(EventArray,2)-16,4) > 0
                        PlotMod = mod(size(EventArray,2)-16,4);
                    else
                        PlotMod = 4;
                    end
                    
                    i = 1;
                    for n = (1+(4*(SliderMax-SliderPos))):(16+(PlotMod+4*(SliderMax-SliderPos-1)))
                        
                        PlotArray(n) = subplot(4,4,i);
                        pcolor(cell2mat(EventArray(n)));
                        shading flat;
                        colormap(jet);
                        axis ij;
                        axis off;
                        title(num2str(EventIndexArray(n)));
                        i=i+1;
                    end
                    
                    set(PlotArray,'visible','off');
                    
                else
                    figure(EventFigures);
                    set(findobj(EventFigures,'Tag','c_slider'),'Enable','off');
                    
                    for k = 1:1:16
                        cla(subplot(4,4,k),'reset');
                        set(subplot(4,4,k),'visible','off');
                    end
                    
                    PlotArray = 0;
                    for n = 1:1:size(EventArray,2)
                        PlotArray(n)=subplot(4,4,n);
                        pcolor(cell2mat(EventArray(n)));shading flat; colormap(jet);
                        axis ij;
                        axis off;
                        title(num2str(EventIndexArray(n)));
                    end
                end
            end           
        end
        
        %   brief - Draws the selected event as a propagation image
        function DrawEvent(~,~)
            figure(SpkDisplay);
            SpikeIndex = 0;
            LineArray = 0;
            SPACING = 0.2;
            RI = 0;
            R = 0;
            Max = 0.2; %Max deviation of spikes from EVENTS in sec
            
            %Deleting an existing image to draw a new one
            if PlotHandler == ~0
                delete(PlotHandler)
                PlotHandler = 0;
            end
            
            SpikeString = get(findobj(gcf,'Tag','Spikeauswahl'),'string');
            SpikeNum = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            SpikeIndex = str2num(SpikeString(SpikeNum,:));
            
            set(CurSpike,'String',['Spike ' num2str(SpikeIndex)]);
            
            ELS=char(EL_NAMES); % read Electrode-names
            ELS=ELS(:,4:5);
            ELS = str2num(ELS);
            RANK(1,:)= ELS';
            
            GroupI = linspace(1,60,60);
            SPIKESCOPY = SPIKES(:,GroupI);
            
            n = 1;
            while not(isempty(nonzeros(SPIKESCOPY)))
                Events(n) = min(nonzeros(SPIKESCOPY));
                SPIKESCOPY(SPIKESCOPY <= Events(n) + Max) = 0;
                n = n+1;
            end
            
            SPIKESCOPY = SPIKES;
            
            x=1;
            y=1;
            while x < size(SPIKESCOPY,1)
                while y <= size(SPIKESCOPY,2)
                    if x < size(Events,2) && abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x,y)-Events(x+1))
                        SPIKESCOPY(end+1,y) = SPIKESCOPY(end,y);
                        SPIKESCOPY(x+1:end-1,y) = SPIKESCOPY(x:end-2,y);
                        SPIKESCOPY(x,y) = 0;
                    elseif abs(SPIKESCOPY(x,y)-Events(x)) > Max || x < size(Events,2) && ...
                            abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x+1,y)-Events(x))
                        
                        SPIKESCOPY(x:end-1,y) = SPIKESCOPY(x+1:end,y);
                        SPIKESCOPY(end,y) = 0;
                        if SPIKESCOPY(x,y) ~= 0
                            y = y-1;
                        end
                    end
                    while isempty(nonzeros(SPIKESCOPY(end,:)))
                        SPIKESCOPY(end,:) = [];
                    end
                    y = y+1;
                end
                x = x+1;
                y = 1;
            end
            clear x y;
            
            RANK(2,GroupI) = SPIKESCOPY(SpikeIndex,:);
            
            [R,RI,RANK] = eventProcess(RANK);
            
            PlotHandler = subplot(1,2,1);
            set(PlotHandler,'Position',[0.1 0.55 0.75 0.40]);
            
            pcolor(RI);shading flat; colormap(jet);
            
            CurrentMatrix = RI;
            
            %Optional process which adds propagation vectors into the image
            R(R==-999) = NaN;
            
            if get(findobj(gcf,'Tag','Velocity Vectors'),'value')
                [X,Y] = meshgrid(33:32:193);
                [DX,DY] = gradient(R,1,1);
                
                hold on;
                quiver(X,Y,DX(2:end-1,2:end-1),DY(2:end-1,2:end-1),'Color',[0,0,0]);
                hold off;
                
                Grad = DY./DX;
                Velocity = zeros(size(R));
                
                for n=2:size(R,1)-1
                    for j=2:size(R,2)-1
                        if isnan(Grad(n,j)) == 0
                            if abs(Grad(n,j))<1
                                Velocity(n,j) = sqrt(1+Grad(n,j)^2)*SPACING*1000/(RI(round(n*32-31+abs(Grad(n,j))*sign(DY(n,j))*32),(j+sign(DX(n,j)))*32-31)-R(n,j));
                            else
                                Velocity(n,j) = sqrt(1+Grad(n,j)^(-2))*SPACING*1000/(RI((n+sign(DY(n,j)))*32-31,round(j*32-31+sign(DX(n,j))*abs(Grad(n,j))^-1*32))-R(n,j));
                            end
                        end
                    end
                end
                clear i j Grad;
            end
            
            axis ij;
            axis off;
            
            colorbar('location','EastOutside')
            
            for n = 1:size(RANK,2)
                EL = RANK(1,n);
                if RANK(4,n) == 0
                    line ('Xdata',fix(EL/10)*32-31,'Ydata', mod(EL,10)*32-31,'Tag','',...
                        'LineStyle','none','Marker','o','MarkerSize',9);
                else
                    line ('Xdata',fix(EL/10)*32-31,'Ydata', mod(EL,10)*32-31,'Tag','',...
                        'LineStyle','none','Marker','o','MarkerFaceColor',[0 0 0],'MarkerSize',9);
                end
            end
            
            for n=1:8
                ElRow = strcat('El X ',num2str(n));
                uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'FontSize', 9,'units', 'pixels', 'position', [10 790-n*46 30 25],...
                    'Parent', SpkDisplay, 'String', ElRow);
            end
            
            for n=1:8
                ElColum = strcat({'El '}, num2str(n),{'X'});
                uicontrol('style', 'text','BackgroundColor', GUI_Color_BG,'FontSize', 9,'units', 'pixels', 'position', [n*50-8 770 30 25],...
                    'Parent', SpkDisplay, 'String', ElColum);
            end
            
            if get(findobj(gcf,'Tag','Contour Lines'),'value')
                hold on
                DenseNum = get(findobj(gcf,'Tag','contour_density'),'value');
                [C, H] = contour(RI,'k');
                set(H,'LevelStep',DenseNum);
                hold off
            end
            
            CurGcf = gcf;
            
            set(findobj(gcf,'Tag','Velocity Vectors'),'Enable','on');
            set(findobj(gcf,'Tag','Contour Lines'),'Enable','on');
            set(findobj(RsltWindow,'Tag','3D'),'Enable','on');
            set(findobj(gcf,'Tag','Video'),'Enable','on');
        end
        
        %   brief - Creats a 3D model of the selected Event
        function threeDimension(~,~)
            SPACING = 0.2;              %Distance of electrodes in mm
            Max = 0.2;                  %Max deviation of spikes from EVENTS in sec
            ELS=char(EL_NAMES)
            ELS=ELS(:,4:5);
            ELS = str2num(ELS);
            RANK(1,:)= ELS';
            
            GroupI = linspace(1,60,60);
            
            SPIKESCOPY = SPIKES(:,GroupI);
            SPIKE = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            
            
            n = 1;
            while not(isempty(nonzeros(SPIKESCOPY)))
                Events(n) = min(nonzeros(SPIKESCOPY));
                SPIKESCOPY(SPIKESCOPY <= Events(n) + Max) = 0;
                n = n+1;
            end
            
            SPIKESCOPY = SPIKES;
            
            x=1;
            y=1;
            while x < size(SPIKESCOPY,1)
                while y <= size(SPIKESCOPY,2)
                    if x < size(Events,2) && abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x,y)-Events(x+1))
                        SPIKESCOPY(end+1,y) = SPIKESCOPY(end,y);
                        SPIKESCOPY(x+1:end-1,y) = SPIKESCOPY(x:end-2,y);
                        SPIKESCOPY(x,y) = 0;
                    elseif abs(SPIKESCOPY(x,y)-Events(x)) > Max || x < size(Events,2) && ...
                            abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x+1,y)-Events(x))
                        
                        SPIKESCOPY(x:end-1,y) = SPIKESCOPY(x+1:end,y);
                        SPIKESCOPY(end,y) = 0;
                        if SPIKESCOPY(x,y) ~= 0
                            y = y-1;
                        end
                    end
                    while isempty(nonzeros(SPIKESCOPY(end,:)))
                        SPIKESCOPY(end,:) = [];
                    end
                    y = y+1;
                end
                x = x+1;
                y = 1;
            end
            clear x y;
            
            RANK(2,GroupI) = SPIKESCOPY(SPIKE,:);
            
            [R,RI,RANK] = eventProcess(RANK);
            
            RI = RI.*(-1);
            
            Figure3D = figure;
            
            [X,Y] = meshgrid(1:1:225);
            
            if get(findobj(SpkDisplay,'Tag','Contour Lines'),'value')
                DenseNum = get(findobj(SpkDisplay,'Tag','contour_density'),'value');
                [C, H] = contour3(X,Y,RI);
            end
            
            hold on
            Figure3D = surf(X,Y,RI);
            shading('flat'); colormap(flipud(jet));
            hold off
            
            if get(findobj(SpkDisplay,'Tag','Velocity Vectors'),'value')
                R(R==-999)=NaN;
                
                [DX,DY] = gradient(R,1,1);
                
                DZ = ones(6);
                
                R = R.*(-1);
                
                [X,Y] = meshgrid(33:32:193);
                ddx = DX(2:end-1,2:end-1);
                ddy = DY(2:end-1,2:end-1);
                ddx = ddx./max(max(abs(ddx)));
                ddy = ddy./max(max(abs(ddy)));
                
                for i = 1:6
                    for j = 1:6
                        x = round(32*j+1+32*ddx(i,j));
                        y = round(32*i+1+32*ddy(i,j));
                        
                        if ~isnan(x) && ~isnan(y)
                            DZ(i,j) = RI(y,x)-RI(32*i+1,32*j+1);
                        else
                            DZ(i,j) = NaN;
                        end
                    end
                end
                
                hold on
                Figure3D = quiver3(X,Y,R(2:end-1,2:end-1),DX(2:end-1,2:end-1),DY(2:end-1,2:end-1),DZ.*0.000001,'Color',[0,0,0]);
                view(30,60)
                hold off
            end
            axis ij;
            axis off;
            
            title(['Spike ',num2str(SPIKE)]);
            colorbar('location','EastOutside')
            
            for n=1:size(RANK,2)
                EL = RANK(1,n);
                if RANK(4,n) == 0
                    line ('Xdata',fix(EL/10)*32-31,'Ydata', mod(EL,10)*32-31,'Zdata',RI(mod(EL,10)*32-31,fix(EL/10)*32-31),'Tag','',...
                        'LineStyle','none','Marker','o',...
                        'MarkerSize',9);
                else
                    line ('Xdata',fix(EL/10)*32-31,'Ydata', mod(EL,10)*32-31,'Zdata',RI(mod(EL,10)*32-31,fix(EL/10)*32-31),'Tag','',...
                        'LineStyle','none','Marker','o',...
                        'MarkerFaceColor',[0 0 0],'MarkerSize',9);
                end
            end
        end
        
        %   brief - Creats a GUI-Frame for the Video Function
        function video(~,~)
            FigureVid = figure('Units','Pixels','Position',[400 300 640 480],'Name','Spike auswï¿½hlen','NumberTitle','off','Toolbar','none','Resize','off','menubar','none','Color',[0.89 0.89 0.99]);
            SaveButton = uicontrol(FigureVid,'Style','PushButton','Units','Pixels','Position',[560 25 60 30],'String','save as','CallBack',@save);
            uicontrol('Parent',FigureVid,'Units','Pixels','Position', [445 25 70 25],'Tag','Speed','FontSize',9,'String',{'Fast';'Normal';'Slow'},'Value',1,'Style','popupmenu');
            uicontrol('Parent',FigureVid,'Style', 'text','Position', [390 21 50 25],'String', 'Speed:','FontSize',9,'BackgroundColor', GUI_Color_BG);
            uicontrol('Parent',FigureVid,'Style', 'text','Position', [240 21 50 25],'String', 'FPS:','FontSize',9,'BackgroundColor', GUI_Color_BG);
            uicontrol ('Parent',FigureVid,'Units','Pixels','Position', [295 25 50 25],'String','32','Tag','FPS','HorizontalAlignment','right','FontSize',9,'Value',1,'Style','edit');
        end
        
        %   brief - Creats a video of the signal propagation of the
        %           selected event
        function save(~,~)
            SPIKE = 0;
            SPACING = 0.2;                        %Distance of electrodes in mm
            Max = 0.2;                            %Max deviation of spikes from EVENTS in sec
            ELS=char(EL_NAMES);                   % read Electrode-names
            ELS=ELS(:,4:5);
            ELS = str2num(ELS);
            RANK(1,:)= ELS';
            MovieFrame = [];
            
            [def_path,filename] = uiputfile({'*.avi'},'save as');
            NameVid = fullfile(filename,def_path);
            
            GroupI = linspace(1,60,60);
            
            SPIKESCOPY = SPIKES(:,GroupI);
            
            SpikeString = get(findobj(SpkDisplay,'Tag','Spikeauswahl'),'string');
            SpikeNum = get(findobj(SpkDisplay,'Tag','Spikeauswahl'),'value');
            SpikeIndex = str2num(SpikeString(SpikeNum,:));
            
            n = 1;
            while not(isempty(nonzeros(SPIKESCOPY)))
                Events(n) = min(nonzeros(SPIKESCOPY));
                SPIKESCOPY(SPIKESCOPY <= Events(n) + Max) = 0;
                n = n+1;
            end
            clear i;
            
            SPIKESCOPY = SPIKES;
            
            x=1;
            y=1;
            while x < size(SPIKESCOPY,1)
                while y <= size(SPIKESCOPY,2)
                    if x < size(Events,2) && abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x,y)-Events(x+1))
                        SPIKESCOPY(end+1,y) = SPIKESCOPY(end,y);
                        SPIKESCOPY(x+1:end-1,y) = SPIKESCOPY(x:end-2,y);
                        SPIKESCOPY(x,y) = 0;
                    elseif abs(SPIKESCOPY(x,y)-Events(x)) > Max || x < size(Events,2) && ...
                            abs(SPIKESCOPY(x,y)-Events(x)) > abs(SPIKESCOPY(x+1,y)-Events(x))
                        
                        SPIKESCOPY(x:end-1,y) = SPIKESCOPY(x+1:end,y);
                        SPIKESCOPY(end,y) = 0;
                        if SPIKESCOPY(x,y) ~= 0
                            y = y-1;
                        end
                    end
                    while isempty(nonzeros(SPIKESCOPY(end,:)))
                        SPIKESCOPY(end,:) = [];
                    end
                    y = y+1;
                end
                x = x+1;
                y = 1;
            end
            clear x y;
            
            FigureVid;
            
            VideoPlot = subplot(1,1,1);
            
            set(VideoPlot,'Position',[0.25 0.30 0.5 0.5]);
            set(VideoPlot,'Visible','off');
            
            RANK(2,GroupI) = SPIKESCOPY(SpikeIndex,:);
            
            [R,RI,RANK] = eventProcess(RANK);
            
            MatrixVid = zeros(225);
            MatrixVid(MatrixVid==0)=NaN;
            
            set(VideoPlot,'NextPlot','replaceChildren');
            
            FPS = get(findobj(FigureVid,'Tag','FPS'),'string');
            FPS = str2num(FPS);
            
            Speed = get(findobj(FigureVid,'Tag','Speed'),'value');
            
            switch Speed
                case 1
                    Speed = 800;
                case 2
                    Speed = 400;
                case 3
                    Speed = 200;
            end
            
            [C,I] = max(RI);
            [A,B] = max(max(RI));
            
            MatrixVid(I(B),B) = A;
            
            RI(I(B),B) = NaN;
            
            MinVal = min(min(RI));
            CountVid = 0;
            i = 1;
            while ~isnan(min(min(RI)))
                
                while min(min(RI)) == MinVal
                    [C,I] = min(RI);
                    [A,B] = min(min(RI));
                    MatrixVid(I(B),B) = A;
                    MinVal = A;
                    RI(I(B),B) = NaN;
                end
                
                MinVal = min(min(RI));
                CountVid = CountVid + 1;
                
                if CountVid == Speed
                    pcolor(MatrixVid);
                    shading('flat'); colormap(jet);
                    MovieFrame(i)=getframe;%(VideoPlot);
                    
                    axis ij;
                    axis off;
                    
                    i = i+1;
                    CountVid = 0;
                end
            end
            
            pcolor(MatrixVid);
            shading('flat'); colormap(jet);
            
            MovieFrame(i)=getframe(VideoPlot);
            axis ij;
            axis off;
            
            writerObj = VideoWriter(NameVid);
            open(writerObj);
            writeVideo(writerObj,MovieFrame);
            close(writerObj);
        end
        
        %   brief - $$$
        function [R,RI,RANK] = eventProcess(RANK)
            ELSALL = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
            
            for n=1:size(ELSALL,2)
                if isempty(find(RANK(1,:) == ELSALL(n), 1))
                    RANK(:,n+1:end+1) = RANK(:,n:end);
                    RANK(1,n) = ELSALL(n);
                    RANK(2,n) = 0;
                end
            end
            
            Min = min(nonzeros(RANK(2,:)));
            RANK(3,:) = RANK(2,:)-Min;
            clear Min;
            
            RANK(3,:) = RANK(3,:)*1000;
            R(1:8,1:8) = -999;
            
            %Filling the matrix R for further processing
            for n=1:size(RANK,2)
                EL = RANK(1,n);
                
                if RANK(3,n) < 0
                    %Check which neighbors are presentand safes in Left,Right,Up,Down
                    if EL > 30 || EL > 20 && mod(EL,10) > 1 && mod(EL,10) < 8
                        Left = true;
                    else
                        Left = false;
                    end
                    if EL < 70 || EL < 80 && mod(EL,10) > 1 && mod(EL,10) < 8
                        Right = true;
                    else
                        Right = false;
                    end
                    if mod(EL,10) > 2 || mod(EL,10) > 1 && EL > 20 && EL < 80
                        Up = true;
                    else
                        Up = false;
                    end
                    if mod(EL,10) < 6 || mod(EL,10) < 8 && EL > 10 && EL < 80
                        Down = true;
                    else
                        Down = false;
                    end
                    
                    Summe = 0;
                    m = 0;
                    
                    if Left
                        x = find(RANK(1,:) == EL-10);
                        if isempty(x) == 0 && RANK(3,x) >= 0 && RANK(4,x) == 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        else
                            Left = false;
                        end
                    end
                    
                    if Right
                        x = find(RANK(1,:) == EL+10);
                        if isempty(x) == 0 && RANK(3,x) >= 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        else
                            Right = false;
                        end
                    end
                    
                    if Up
                        x = find(RANK(1,:) == EL-1);
                        if isempty(x) == 0 && RANK(3,x) >= 0 && RANK(4,x) == 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        else
                            Up = false;
                        end
                    end
                    
                    if Down
                        x = find(RANK(1,:) == EL+1);
                        if isempty(x) == 0 && RANK(3,x) >= 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        else
                            Down = false;
                        end
                    end
                    
                    if Left && Right || Up && Down
                        RANK(3,n) = Summe/m;
                    else
                        RANK(3,n) = -999;
                    end
                    RANK(4,n) = 1; %safes if electrode was inactive
                    
                else
                    RANK(4,n) = 0;
                end
                
                R(mod(EL,10),fix(EL/10)) = RANK(3,n);
            end
            
            RI=interp2(R,5); %Interpolate
            
            %Delete corners
            for x=1:8
                for y=1:8
                    if R(y,x) == -999
                        if y > 1
                            Up = true;
                        else
                            Up = false;
                        end
                        
                        if y < 8
                            Down = true;
                        else
                            Down = false;
                        end
                        
                        if x > 1
                            Left = true;
                        else
                            Left = false;
                        end
                        
                        if x < 8
                            Right = true;
                        else
                            Right = false;
                        end
                        
                        RI(y*32-31-Up*31:y*32-31+Down*31,x*32-31-Left*31:x*32-31+Right*31) = NaN;
                    end
                end
            end
        end
        
        %   brief - Creats a grid plot
        function gridPlot(~,~)
            GridPlot = figure('Position',[150 50 700 660],'Name','Rasterplot Spikes',...
                'NumberTitle','off','Resize','off');
            
            axes('Units','pixels','Position',[20 40 660 600],'YDir','reverse',...
                'YLim',[0 size(SPIKES,2)+1],'YColor',[.8 .8 .8],'YMinorGrid','on');
            
            for n=1:length(SI_EVENTS)
                line ('Xdata',[SI_EVENTS(n) SI_EVENTS(n)],'YData',[0 nr_channel],...
                    'Color','green');
            end
            
            for n=1:size(BURSTS,2)
                line ('Xdata',nonzeros(SPIKES(:,n)),...
                    'Ydata', n.*ones(1,length(nonzeros(SPIKES(:,n)))),...
                    'LineStyle','none','Marker','*',...
                    'MarkerFaceColor','green','MarkerSize',3);
                text(0,n,EL_NAMES(n),'HorizontalAlignment','right','FontSize',6);
            end
            
            xlabel ('time / s');
            figure (GridPlot);
        end%~~
        
        %   brief - $$$
        function spikeNum(~,~)
            k = 1;
            SpkString = '';
            Electrode = get(findobj(ValWindow,'Tag','EL_Num'),'value');
            
            while k <= size(SPIKES,1) && SPIKES(k,Electrode) > 0
                SpkString(k,:) = ([num2str(k) blanks(  length(num2str(size(SPIKES,1))) - length(num2str(k))   )]);
                k = k+1;
            end
            
            set (findobj(ValWindow,'Tag','Single_Spike'),'String',SpkString);
            
            if SpkInfo ~= 0 && SpkInfo <= size(SpkString,1)
                set(findobj(ValWindow,'Tag','Single_Spike'),'Value',SpkInfo);
            else
                set(findobj(ValWindow,'Tag','Single_Spike'),'Value',1);
            end
            
            drawSingleSpike;
        end
        
        %   brief - $$$
        function drawSingleSpike (~,~)
            Laenge = str2double(get(findobj(SingleSpk,'Tag','Laenge'),'string'))/1000; %window length
            Vorlauf = str2double(get(findobj(SingleSpk,'Tag','Vorlauf'),'string'))/1000; %start window
            
            QTOver();
            
            figure(SingleSpk);
            
            SingleSpikePlot = subplot(1,1,1);
            set(SingleSpikePlot,'Position',[0.1 0.55 0.8 0.4]);
            delete(findobj(0,'Tag','Yellow'));
            
            Scale = get(Skala,'value');
            
            switch Scale
                case 1, Scale = 50;
                case 2, Scale = 100;
                case 3, Scale = 200;
                case 4, Scale = 500;
                case 5, Scale = 1000;
            end
            
            Electrode = get(findobj(ValWindow,'Tag','EL_Num'),'value');
            Spike = get(findobj(ValWindow,'Tag','Single_Spike'),'value');
            SpikeCount = get(findobj(ValWindow,'Tag','Single_Spike'),'string');
            
            if sum(SPIKES(:,Electrode)) > 0
                SpkInfo = Spike;
            end
            
            Temp = [];
            
            SPIKESCUT = zeros(size(SPIKES,1),1);
            
            for k=1:size(SPIKESCOP,1)
                if SPIKES(k,Electrode)*SaRa+1-(Vorlauf)*SaRa > 0 && ...
                        SPIKES(k,Electrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(RAW.M,1)
                    if SPIKESCOP(k,Electrode) > 0
                        Temp(:,k) = RAW.M(SPIKESCOP(k,Electrode)*SaRa+1-(Vorlauf)*SaRa:SPIKESCOP(k,Electrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Electrode);
                    else
                        Temp(1:SaRa*Laenge,k) = 0;
                    end
                else
                    if SPIKESCOP(k,Electrode) ~= 0
                        SPIKESCUT(k) = SPIKESCOP(k,Electrode);
                    else
                        SPIKESCUT(k) = SPIKESDEL(k,Electrode);
                    end
                end
            end
            
            %Check, if there are spikes at all
            if isempty(get(findobj(ValWindow,'Tag','Single_Spike'),'string'))
                plot(linspace(-Vorlauf,Laenge-Vorlauf,5),linspace(-Vorlauf,Laenge-Vorlauf,5)*0,'-');
                xlabel ('time / s');
                ylabel ('voltage / ï¿½V');
                axis([-Vorlauf Laenge-Vorlauf -Scale-50 Scale]);
                %  set(LockViewSingle,'Enable','off');
                ZeroSingle = true;
            else
                Spike = get(findobj(ValWindow,'Tag','Single_Spike'),'Value');
                
                if SPIKESCUT(Spike) > 0
                    plot(linspace(-Vorlauf,Laenge-Vorlauf,5),linspace(-Vorlauf,Laenge-Vorlauf,5)*0,'-','Tag','Single');
                    xlabel ('time / s');
                    ylabel ('voltage / ï¿½V');
                    axis([-Vorlauf Laenge-Vorlauf -Scale-50 Scale]);
                    set(SingleSpikePlot,'Position',[0.1 0.81 0.87 0.14]);
                    SP = SPIKES(Spike,Electrode);
                    
                    y_axis = ones(length(SP),1).*(-Scale).*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','^',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                    
                    msgbox ('Spike kann nicht angezeigt werden, da Betrachtungsfenster ï¿½ber Messzeitraum reicht.','Error','error');
                    %set(LockViewSingle,'Enable','off');
                    ZeroSingle = true;
                else
                    %LockSingle;
                    if get(findobj(ValWindow,'Tag','Overlay'),'value') == 0
                        SP = RAW.M(SPIKES(Spike,Electrode)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,Electrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Electrode);
                    else
                        %ZUSATZ
                        SP = zeros(Laenge*SaRa,1);
                        SpikeCounter = 0;
                        for i = 1:1:size(SpikeCount,1)
                            
                            if SPIKESCUT(i) > 0
                            elseif SPIKES(i,Electrode)*SaRa+1-(Vorlauf)*SaRa > 0 && SPIKES(i,Electrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(RAW.M,1)
                                SP = SP + RAW.M(SPIKES(i,Electrode)*SaRa+1-(Vorlauf)*SaRa:SPIKES(i,Electrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Electrode);
                                SpikeCounter = SpikeCounter + 1;
                            end
                        end
                        
                        SP = SP./SpikeCounter;
                        %ZUSATZ ENDE
                        %                     size(SP)
                        %                     for n = 11:size(SP,1)-10
                        %                         SP(n) = mean(SP(n-10:n+10));
                        %                     end
                        %                     for n = 1:10
                        %                         SP(n) = mean(SP(n:n+10));
                        %                         SP(size(SP,1)-n+1) = mean(SP(size(SP,1)-n-9):SP(size(SP,1)-n+1));
                        %                     end
                    end
                    
                    Single = plot(linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge),SP,'Tag','Single');
                    ZeroSingle = false;
                    OldSpike = get(findobj(ValWindow,'Tag','Single_Spike'),'value');
                    
                    xlabel ('time / s');
                    ylabel ('voltage / ï¿½V');
                    
                    axis([-Vorlauf Laenge-Vorlauf -Scale-50 Scale]);
                    
                    if get(findobj(ValWindow,'Tag','Overlay'),'value') == 0
                        line ('Xdata',MinMax(Electrode,Spike,1,1),'Ydata', MinMax(Electrode,Spike,1,2),'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',MinMax(Electrode,Spike,2,1),'Ydata', MinMax(Electrode,Spike,2,2),'Tag','Single',...
                            'LineStyle','none','Marker','^',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',MinMax(Electrode,Spike,3,1),'Ydata', MinMax(Electrode,Spike,3,2),'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',MinMax(Electrode,Spike,4,1),'Ydata', MinMax(Electrode,Spike,4,2),'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                    else
                        line ('Xdata',MinMaxOverlay(Electrode,2,2),'Ydata', MinMaxOverlay(Electrode,2,1),'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',MinMaxOverlay(Electrode,1,2),'Ydata', MinMaxOverlay(Electrode,1,1),'Tag','Single',...
                            'LineStyle','none','Marker','^',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',MinMaxOverlay(Electrode,3,2),'Ydata', MinMaxOverlay(Electrode,3,1),'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',MinMaxOverlay(Electrode,4,2),'Ydata', MinMax(Electrode,4,1),'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                    end
                end
            end
            
            UpdateSpikeAnalysis();
        end
        
        %   brief - $$$
        function singleSpikeParameters(~,~)
            
            for FreqColumn = 1:size(SPIKES,2)
                TimeDiff = [];
                k = 1;
                if sum(SPIKES(:,FreqColumn) ~= 0) > 1
                    n = 1;
                    while(n < size(SPIKES,1) && SPIKES(n+1,FreqColumn) > 0)
                        TimeDiff(k) = SPIKES(n+1,FreqColumn) - SPIKES(n,FreqColumn);
                        
                        k=k+1;
                        n=n+1;
                    end
                end
                ISI(FreqColumn,1) = mean(TimeDiff);
                ISI(FreqColumn,2) = std(TimeDiff);
                ISI(FreqColumn,3) = length(TimeDiff);
                
                BeatRate(FreqColumn) = sum(SPIKES(:,FreqColumn) ~= 0)/rec_dur;
            end
            
            for El = 1:size(SPIKES,2)
                MaxValElArray(El,1) = mean(MinMax(El,:,1,2)); %Min/Max (Dimensions: 1.Electrode,2.Spike,3.Values(Max1,Min,Max2),4.Values(1.X-Wert,2.Y-Wert))
                MaxValElArray(El,2) = std(MinMax(El,:,1,2));
                MaxValElArray(El,3) = median(MinMax(El,:,1,2));
                MaxValElArray(El,4) = length(nonzeros(MinMax(El,:,1,2)));
                
                MinValElArray(El,1) = mean(MinMax(El,:,2,2));
                MinValElArray(El,2) = std(MinMax(El,:,2,2));
                MinValElArray(El,3) = median(MinMax(El,:,2,2));
                MinValElArray(El,4) = length(nonzeros(MinMax(El,:,2,2)));
                
                QTElArray(El,1) = mean(MinMax(El,:,3,1)-MinMax(El,:,1,1));
                QTElArray(El,2) = std(MinMax(El,:,3,1)-MinMax(El,:,1,1));
                QTElArray(El,3) =median(MinMax(El,:,3,2)-MinMax(El,:,4,2));
            end
            
            
            
            %Class Variance Interspike Interval
            
            ISITemp = ISI(~isnan(ISI(:,2)),:);
            
            ISIClassVariance = [];
            
            for i = 1:size(ISITemp,1)
                ISIClassVariance(i) = (abs(mean(ISITemp(:,1))-ISITemp(i,1))^2/(size(ISITemp,1)-1));
            end
            
            ISIMeanVariance = sum(ISITemp(:,2).^2)/(size(ISITemp,1)-1);
            
            ISIStdAll = sqrt(mean(ISIClassVariance) + ISIMeanVariance);
            
            %Class Variance Amp Max
            
            MaxValTemp = MaxValElArray(~any(MaxValElArray==0,2),:);
            
            MaxValClassVariance = [];
            
            for i = 1:size(MaxValTemp,1)
                MaxValClassVariance(i) = (abs(mean(MaxValTemp(:,1))-MaxValTemp(i,1))^2/(size(MaxValTemp,1)-1));
            end
            
            MaxValMeanVariance = sum(MaxValTemp(:,2).^2)/(size(MaxValTemp,1)-1);
            
            MaxValStdAll = sqrt(mean(MaxValClassVariance) + MaxValMeanVariance);
            
            %Class Variance Amp Min
            
            MinValTemp = MinValElArray(~any(MinValElArray==0,2),:);
            
            MinValClassVariance = [];
            
            for i = 1:size(MinValTemp,1)
                MinValClassVariance(i) = (abs(mean(MinValTemp(:,1))-MinValTemp(i,1))^2/(size(MinValTemp,1)-1));
            end
            
            MinValMeanVariance = sum(MinValTemp(:,2).^2)/(size(MinValTemp,1)-1);
            
            MinValStdAll = sqrt(mean(MinValClassVariance) + MinValMeanVariance);
            
            %Class Variance QT
            
            QTTemp = QTElArray(~any(QTElArray==0,2),:);
            
            QTClassVariance = [];
            
            for i = 1:size(QTTemp,1)
                QTClassVariance(i) = (abs(mean(QTTemp(:,1))-QTTemp(i,1))^2/(size(QTTemp,1)-1));
            end
            
            QTMeanVariance = sum(QTTemp(:,2).^2)/(size(QTTemp,1)-1);
            
            QTStdAll = sqrt(mean(QTClassVariance) + QTMeanVariance);
            
        end
        
        %   brief - $$$
        function UpdateSpikeAnalysis(~,~)
            
            CurEl = get(findobj(ValWindow,'Tag','EL_Num'),'value');
            CurSpk = get(findobj(ValWindow,'Tag','Single_Spike'),'value');
            
            if get(findobj(ValWindow,'Tag','Overlay'),'value') == 0
                
                set(BeatRateMeanEl,'String',sprintf('%.3f',BeatRate(CurEl)));
                set(BeatRateStdEl,'String','-');
                set(BeatRateMedianEl,'String','-');
                
                set(BeatRateMeanAllEl,'String',sprintf('%.3f',(mean(BeatRate(BeatRate>0)))));
                set(BeatRateStdAllEl,'String',sprintf('%.3f',(std(BeatRate(BeatRate>0)))));
                set(BeatRateMedianAllEl,'String',sprintf('%.3f',(median(BeatRate(BeatRate>0)))));
                
                set(ISIMeanEl,'String',sprintf('%.3f',ISI(CurEl,1)));
                set(ISIStdEl,'String',sprintf('%.3f',ISI(CurEl,2)));
                set(ISIMedianEl,'String','-');
                
                % "Fehlerfortpflanzung"
                ISITemp = ISI(~isnan(ISI(:,2)),:);
                xj = ISITemp(:,1);
                sj = ISITemp(:,2);
                nj = ISITemp(:,3);
                [x,stdges,~]=CollectiveVariance_TK(xj,sj,nj); 
                
                set(ISIMeanAllEl,'String',sprintf('%.3f',x));
                set(ISIStdAllEl,'String',sprintf('%.3f',stdges));
                set(ISIMedianAllEl,'String','-');
                
                % old:
%                 set(ISIMeanAllEl,'String',sprintf('%.3f',mean(ISITemp(:,1))));
%                 set(ISIStdAllEl,'String',sprintf('%.3f',ISIStdAll));
%                 set(ISIMedianAllEl,'String','-');

                
                set(QTMeanEl,'String',sprintf('%.3f',QTElArray(CurEl,1)));
                set(QTStdEl,'String',sprintf('%.3f',QTElArray(CurEl,2)));
                set(QTMedianEl,'String',sprintf('%.3f',QTElArray(CurEl,3)));
                
                set(QTMeanAllEl,'String',sprintf('%.3f',(mean(QTElArray(:,1)))));
                set(QTStdAllEl,'String',sprintf('%.3f',QTStdAll));
                set(QTMedianAllEl,'String',sprintf('%.3f',(median(QTElArray(:,1)))));
                
                if CurEl <= size(MinMax,1)
                    set(MaxValSpike,'String',sprintf('%.3f',(MinMax(CurEl,CurSpk,1,2))));
                    set(MinValSpike,'String',sprintf('%.3f',(MinMax(CurEl,CurSpk,2,2))));
                    set(QTSpike,'String',sprintf('%.3f',(MinMax(CurEl,CurSpk,3,1)-MinMax(CurEl,CurSpk,4,1))));
                else
                    set(MaxValSpike,'String','-');
                    set(MinValSpike,'String','-');
                    set(QTSpike,'String','-');
                end
                
                set(MaxValMeanEl,'String',sprintf('%.3f',MaxValElArray(CurEl,1)));
                set(MinValMeanEl,'String',sprintf('%.3f',MinValElArray(CurEl,1)));
                set(MaxValStdEl,'String',sprintf('%.3f',MaxValElArray(CurEl,2)));
                set(MinValStdEl,'String',sprintf('%.3f',MinValElArray(CurEl,2)));
                set(MaxValMedianEl,'String',sprintf('%.3f',MaxValElArray(CurEl,3)));
                set(MinValMedianEl,'String',sprintf('%.3f',MinValElArray(CurEl,3)));
                
                % "Fehlerfortpflanzung" Max Amplituden
                xj = MaxValTemp(:,1);
                sj = MaxValTemp(:,2);
                nj = MaxValTemp(:,4);
                [x,stdges,N]=CollectiveVariance_TK(xj,sj,nj);
                MaxValNAllEl = N;
                
                set(MaxValMeanAllEl,'String',sprintf('%.3f',x));
                set(MaxValStdAllEl,'String',sprintf('%.3f',stdges));
                set(MaxValMedianAllEl,'String',sprintf('%.3f',(median(MaxValTemp(:,1)))));
                
                % "Fehlerfortpflanzung" Min Amplituden
                xj = MinValTemp(:,1);
                sj = MinValTemp(:,2);
                nj = MinValTemp(:,4);
                [x,stdges,N]=CollectiveVariance_TK(xj,sj,nj);
                MinValNAllEl = N;
                
                set(MinValMeanAllEl,'String',sprintf('%.3f',x));
                set(MinValStdAllEl,'String',sprintf('%.3f',stdges));
                set(MinValMedianAllEl,'String',sprintf('%.3f',(median(MinValTemp(:,1)))));
                
                % old:
%                 set(MaxValMeanAllEl,'String',sprintf('%.3f',(mean(MaxValTemp(:,1)))));
%                 set(MinValMeanAllEl,'String',sprintf('%.3f',(mean(MinValTemp(:,1)))));
%                 set(MaxValStdAllEl,'String',sprintf('%.3f',MaxValStdAll));
%                 set(MinValStdAllEl,'String',sprintf('%.3f',MinValStdAll));
%                 set(MaxValMedianAllEl,'String',sprintf('%.3f',(median(MaxValTemp(:,1)))));
%                 set(MinValMedianAllEl,'String',sprintf('%.3f',(median(MinValTemp(:,1)))));
                
                
                
            else
                QTElArray = [];
                MaxValElArray = [];
                MinValElArray = [];
                
                for i = 1:size(MinMaxOverlay,1)
                    if i ==1
                        QTElArray = MinMaxOverlay(i,3,2)-MinMaxOverlay(i,4,2);
                        MaxValElArray = MinMaxOverlay(i,2,1);
                        MinValElArray =MinMaxOverlay(i,1,1);
                    else
                        QTElArray = [QTElArray MinMaxOverlay(i,3,2)-MinMaxOverlay(i,4,2)];
                        MaxValElArray = [MaxValElArray MinMaxOverlay(i,2,1)];
                        MinValElArray = [MinValElArray MinMaxOverlay(i,1,1)];
                    end
                    QTElArray(QTElArray == 0) = [];
                    MaxValElArray(MaxValElArray == 0) = [];
                    MinValElArray(MinValElArray == 0) = [];
                end
                
                set(BeatRateMeanEl,'String','-');
                set(BeatRateStdEl,'String','-');
                set(BeatRateMedianEl,'String','-');
                
                set(BeatRateMeanAllEl,'String','-');
                set(BeatRateStdAllEl,'String','-');
                set(BeatRateMedianAllEl,'String','-');
                
                set(ISIMeanEl,'String','-');
                set(ISIStdEl,'String','-');
                set(ISIMedianEl,'String','-');
                
                set(ISIMeanAllEl,'String','-');
                set(ISIStdAllEl,'String','-');
                set(ISIMedianAllEl,'String','-');
                
                set(QTMeanEl,'String',sprintf('%.3f',MinMaxOverlay(CurEl,3,2)-MinMaxOverlay(CurEl,4,2)));
                set(QTStdEl,'String','-');
                set(QTMedianEl,'String','-');
                
                set(QTMeanAllEl,'String',sprintf('%.3f',(mean(QTElArray))));
                set(QTStdAllEl,'String',sprintf('%.3f',std(QTElArray)));
                set(QTMedianAllEl,'String',sprintf('%.3f',(median(QTElArray))));
                
                set(MaxValSpike,'String','-');
                set(MinValSpike,'String','-');
                set(QTSpike,'String','-');
                
                set(MaxValMeanEl,'String',sprintf('%.3f',MinMaxOverlay(CurEl,2,1)));
                set(MinValMeanEl,'String',sprintf('%.3f',MinMaxOverlay(CurEl,1,1)));
                set(MaxValStdEl,'String','-');
                set(MinValStdEl,'String','-');
                set(MaxValMedianEl,'String','-');
                set(MinValMedianEl,'String','-');
                
                % "Fehlerfortpflanzung"
                ISITemp = ISI(~isnan(ISI(:,2)),:);
                xj = ISITemp(:,1);
                sj = ISITemp(:,2);
                nj = ISITemp(:,3);
                [x,stdges,~]=CollectiveVariance_TK(xj,sj,nj); 
                
                set(MaxValMeanAllEl,'String',sprintf('%.3f',(mean(MaxValElArray))));
                set(MinValMeanAllEl,'String',sprintf('%.3f',(mean(MinValElArray))));
                set(MaxValStdAllEl,'String',sprintf('%.3f',std(MaxValElArray)));
                set(MinValStdAllEl,'String',sprintf('%.3f',std(MinValElArray)));
                set(MaxValMedianAllEl,'String',sprintf('%.3f',(median(MaxValElArray))));
                set(MinValMedianAllEl,'String',sprintf('%.3f',(median(MinValElArray))));
            end
            
        end
        
        %   brief - $$$
        function singleSpikeExport(~,~)
            format
            DefaultName = file(1:end-4);
            [def_path,filename] = uiputfile('*.xls','save as',DefaultName);
            xlsName = fullfile(filename,def_path);
            Names = {'Beat Rate','Mean ISI','Std ISI','Mean Amp Max','Std Amp Max','Mean Amp Min','Std Amp Min'};
            Names_SheetAllEl = {'Mean Beat Rate','Std Beat Rate','Mean ISI','Std Isi','Mean Amp Max','Std Amp Max','Mean Amp Min','Std Amp Min'};
            Names_CV = {'Mean','Std','Median'};
            El = EL_NAMES;
            wait = waitbar(0,'Exporting data');
            xlswrite(xlsName,Names,'B1:H1');
            xlswrite(xlsName,Names_SheetAllEl,'All Electrodes');
            xlswrite(xlsName,El,'A2:A61');
            xlswrite(xlsName,Names_CV,'Conduction Velocity','B1')
            xlswrite(xlsName,{'Distance (mm)';'Time (ms)';'Velocity (mm/ms)'},'Conduction Velocity','A2')
            waitbar(0.25,wait,'Exporting data');
            xlswrite(xlsName,BeatRate','B2:B61');
            xlswrite(xlsName,ISI(:,1),'C2:C61');
            xlswrite(xlsName,ISI(:,2),'D2:D61');
            xlswrite(xlsName,MaxValElArray(:,1),'E2:E61');
            xlswrite(xlsName,MaxValElArray(:,2),'F2:F61');
            xlswrite(xlsName,MinValElArray(:,1),'G2:G61');
            xlswrite(xlsName,MinValElArray(:,2),'H2:H61');
            waitbar(0.5,wait,'Exporting data');
            xlswrite(xlsName,mean(BeatRate(BeatRate>0)),'All Electrodes','A2');
            xlswrite(xlsName,std(BeatRate(BeatRate>0)),'All Electrodes','B2');
            xlswrite(xlsName,mean(ISITemp(:,1)),'All Electrodes','C2');
            xlswrite(xlsName,ISIStdAll,'All Electrodes','D2');
            xlswrite(xlsName,mean(MaxValTemp(:,1)),'All Electrodes','E2');
            xlswrite(xlsName,MaxValStdAll,'All Electrodes','F2');
            xlswrite(xlsName,mean(MinValTemp(:,1)),'All Electrodes','G2');
            xlswrite(xlsName,MinValStdAll,'All Electrodes','H2');
            waitbar(0.75,wait,'Exporting data');
            
            if ~isempty(Export_CV)
            xlswrite(xlsName, Export_CV', 'Conduction Velocity','B2');
            end
            
            waitbar(1,wait,'Exporting data');
            close(wait);
        end
        
        %   brief - $$$
        function QTOver(~,~)
            SP_All = [];
            ElCount = 1;
            
            SP = zeros(Laenge*SaRa,1);
            for Ele = 1:size(SPIKES,2)
                if isempty(nonzeros(SPIKES(:,Ele))) == 0
                    SpikeCount = 0;
                    for Spike = 1:size(nonzeros(SPIKES(:,Ele)),1)
                        if SPIKES(Spike,Ele)*SaRa+1-(Vorlauf)*SaRa > 0 && SPIKES(Spike,Ele)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(RAW.M,1)
                            SP = SP + RAW.M(SPIKES(Spike,Ele)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,Ele)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Ele);
                            SpikeCount = SpikeCount + 1;
                        end
                    end
                    
                    if SpikeCount > 0
                        SP = SP./SpikeCount;
                        SP_All(ElCount,:) = SP;
                    end
                else
                    MinMaxOverlay(ElCount,:,:) = 0;
                end
                ElCount = ElCount + 1;
            end
        end
        
        %   brief - $$$
        function QTOverlay(~,~)
            SP_All = [];
            ElCount = 1;
            InitialFlag = 0;
            for Ele = 1:size(SPIKES,2)
                if isempty(nonzeros(SPIKES(:,Ele))) == 0
                    InitialFlag = 0;
                    for Spike=1:size(nonzeros(SPIKES(:,Ele)),1)
                        if SPIKES(Spike,Ele)*SaRa+1-(Vorlauf)*SaRa > 0 && ...
                                SPIKES(Spike,Ele)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(RAW.M,1)
                            if InitialFlag == 0
                                SP = RAW.M(SPIKES(Spike,Ele)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,Ele)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Ele);
                                Spike = Spike + 1;
                                InitialFlag = 1;
                            end
                            SP = SP + RAW.M(SPIKES(Spike,Ele)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,Ele)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Ele);
                        end
                    end
                    SP = SP./size(nonzeros(SPIKES(:,Ele)),1);
                    
                    SP_All(ElCount,:) = SP;
                    
                    [MinMaxOverlay(ElCount,1,1),MinMaxOverlay(ElCount,1,2)] = min(SP_All(ElCount,:));
                    [MinMaxOverlay(ElCount,2,1),MinMaxOverlay(ElCount,2,2)] = max(SP_All(ElCount,:));
                    [MinMaxOverlay(ElCount,3,1),MinMaxOverlay(ElCount,3,2)] = max(SP(MinMaxOverlay(ElCount,1,2):end));
                    n = MinMaxOverlay(ElCount,2,2)-1;
                    for n = n:-1:1
                        MinMaxOverlay(ElCount,4,2) = 1;
                        MinMaxOverlay(ElCount,4,1) = 0;
                        if SP(n) <= 0
                            MinMaxOverlay(ElCount,4,2) = n;
                            MinMaxOverlay(ElCount,4,1) = SP(n);
                            break;
                        end
                    end
                    
                    a = linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge);
                    if MinMaxOverlay(ElCount,3,2)+MinMaxOverlay(ElCount,2,2)-1 < size(a,2)
                        MinMaxOverlay(ElCount,3,2) = a(MinMaxOverlay(ElCount,3,2)+MinMaxOverlay(ElCount,2,2)-1);
                    end
                    MinMaxOverlay(ElCount,1,2) = a(MinMaxOverlay(ElCount,1,2));
                    MinMaxOverlay(ElCount,2,2) = a(MinMaxOverlay(ElCount,2,2));
                    MinMaxOverlay(ElCount,4,2) = a(MinMaxOverlay(ElCount,4,2));
                    clear a;
                else
                    MinMaxOverlay(ElCount,:,:) = 0;
                end
                ElCount = ElCount + 1;
            end
        end
        
        %   brief - $$$
        function FindPoints(~,~)

            for EL=1:size(SPIKES,2)
                
                for Spike=1:size(nonzeros(SPIKES(:,EL)),1)
                    
                    if SPIKES(Spike,EL)*SaRa+1-(Vorlauf)*SaRa > 0 && ...
                            SPIKES(Spike,EL)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(RAW.M,1)
                        
                        SP = RAW.M(SPIKES(Spike,EL)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,EL)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,EL);
                        
                        [MinMax(EL,Spike,2,2),MinMax(EL,Spike,2,1)] = min(SP); %Minimum
                        %1. Maximum
                        if MinMax(EL,Spike,2,1)-SaRa*0.075 > 0
                            [MinMax(EL,Spike,1,2),MinMax(EL,Spike,1,1)] = max(SP(MinMax(EL,Spike,2,1)-SaRa*0.075:MinMax(EL,Spike,2,1))); %1.Maximum
                            MinMax(EL,Spike,1,1) = MinMax(EL,Spike,1,1) + MinMax(EL,Spike,2,1)-SaRa*0.075;
                        else
                            [MinMax(EL,Spike,1,2),MinMax(EL,Spike,1,1)] = max(SP(1:MinMax(EL,Spike,2,1))); %1.Maximum
                        end
                        %2. Maximum
                        if MinMax(EL,Spike,2,1)+SaRa*0.15 <= size(SP,1)
                            [MinMax(EL,Spike,3,2),MinMax(EL,Spike,3,1)] = max(SP(MinMax(EL,Spike,2,1):end));%MinMax(EL,Spike,2,1)+SaRa*0.15)); %2.Maximum
                        else
                            [MinMax(EL,Spike,3,2),MinMax(EL,Spike,3,1)] = max(SP(MinMax(EL,Spike,2,1):end)); %2.Maximum
                        end
                        
                        n = MinMax(EL,Spike,1,1)-1;
                        for n = n:-1:1
                            MinMax(EL,Spike,4,1) = 1;
                            MinMax(EL,Spike,4,2) = 0;
                            if SP(n) <= 0
                                MinMax(EL,Spike,4,1) = n;
                                MinMax(EL,Spike,4,2) = SP(n);
                                break;
                            end
                        end
                        
                        a = linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge);
                        MinMax(EL,Spike,3,1) = a(MinMax(EL,Spike,3,1)+MinMax(EL,Spike,2,1)-1);
                        MinMax(EL,Spike,1,1) = a(MinMax(EL,Spike,1,1));
                        MinMax(EL,Spike,2,1) = a(MinMax(EL,Spike,2,1));
                        MinMax(EL,Spike,4,1) = a(MinMax(EL,Spike,4,1));
                        clear a;
                    else
                        MinMax(EL,Spike,:,:) = 0;
                        
                    end
                end
                if size(nonzeros(SPIKES(:,EL)),1) == 0
                    MinMax(EL,:,:,:) = 0;
                end
            end
            
        end
        
        %   brief - $$$
        function QTRange(~,~)
            
            start1 = 0;
            stop1 = 0;
            stop2 = 0;
            
            Range_Status = get(findobj(ValWindow,'Tag','AllEL'),'value');
            EL = get(findobj(ValWindow,'Tag','EL_Num'),'value');
            Spike = get(findobj(ValWindow,'Tag','Single_Spike'),'value');
            
            Range = str2double(get(findobj(SingleSpk,'Tag','Laenge'),'string'));
            Buffer = str2double(get(findobj(SingleSpk,'Tag','Vorlauf'),'string'));
            
            start1 = (str2num(get(findobj(SingleSpk,'Tag','QTR_Start'),'string')));
            stop1 = (str2num(get(findobj(SingleSpk,'Tag','QTR_End'),'string')));
            
            a = linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge);
            b = linspace(-0.1,0.4,SaRa*0.5);
            
            
            if start1 < 0 || stop1 <= 0 || start1 >= Range*5 || stop1 >= Range*5
                
            else
                if get(findobj(ValWindow,'Tag','Overlay'),'value') == 0
                    if Range_Status == 0
                        
                        if start1 < stop1
                            
                            SP = RAW.M(SPIKES(Spike,EL)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,EL)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,EL);
                            start = size(SP,1)*(start1+Buffer)/Range;
                            stop2 = size(SP,1)*(stop1+Buffer)/Range;
                            if start >= find(b == MinMax(EL,Spike,2,1))
                                
                                [MinMax(EL,Spike,3,2),MinMax(EL,Spike,3,1)] = max(SP(start:stop2));
                                
                                MinMax(EL,Spike,3,1) = a(MinMax(EL,Spike,3,1)+start-1);
                            elseif stop2 > find(b == MinMax(EL,Spike,2,1))
                                
                                
                                [MinMax(EL,Spike,3,2),MinMax(EL,Spike,3,1)] = max(SP(find(a == MinMax(EL,Spike,2,1)):stop2));
                                
                                MinMax(EL,Spike,3,1) = a(MinMax(EL,Spike,3,1)+find(a == MinMax(EL,Spike,2,1))-1);
                                
                            end
                        end
                    else
                        if start1 < stop1
                            
                            for ELn=1:size(SPIKES,2)
                                
                                for Spiken=1:size(nonzeros(SPIKES(:,ELn)),1)
                                    if SPIKES(Spiken,ELn)*SaRa+1-(Vorlauf)*SaRa > 0 && ...
                                            SPIKES(Spiken,ELn)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(RAW.M,1)
                                        
                                        SP = RAW.M(SPIKES(Spiken,ELn)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spiken,ELn)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,ELn);
                                        start = size(SP,1)*(start1+Buffer)/Range;
                                        stop2 = size(SP,1)*(stop1+Buffer)/Range;
                                        
                                        if start > find(b == MinMax(ELn,Spiken,2,1))
                                            [MinMax(ELn,Spiken,3,2),MinMax(ELn,Spiken,3,1)] = max(SP(start:stop2));
                                            
                                            MinMax(ELn,Spiken,3,1) = a(MinMax(ELn,Spiken,3,1)+start-1);
                                        elseif stop2 > find(b == MinMax(ELn,Spiken,2,1))
                                            
                                            [MinMax(ELn,Spiken,3,2),MinMax(ELn,Spiken,3,1)] = max(SP(find(a == MinMax(ELn,Spiken,2,1)):stop2));
                                            
                                            MinMax(ELn,Spiken,3,1) = a(MinMax(ELn,Spiken,3,1)+find(a == MinMax(ELn,Spiken,2,1))-1);
                                            
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    if Range_Status == 0
                        
                        if start1 < stop1
                            
                            SP = SP_All(EL,:);
                            
                            start = size(SP,2)*(start1+Buffer)/Range;
                            stop2 = size(SP,2)*(stop1+Buffer)/Range;
                            
                            
                            if start >= find(a == MinMaxOverlay(EL,1,2))
                                
                                [MinMaxOverlay(EL,3,1),MinMaxOverlay(EL,3,2)] = max(SP(start:stop2));
                                
                                MinMaxOverlay(EL,3,2) = a(MinMaxOverlay(EL,3,2)+start-1);
                            elseif stop2 > find(a == MinMaxOverlay(EL,2,2))
                                
                                
                                [MinMaxOverlay(EL,3,1),MinMaxOverlay(EL,3,2)] = max(SP(find(a == MinMaxOverlay(EL,2,2)):stop2));
                                
                                MinMaxOverlay(EL,3,2) = a(MinMaxOverlay(EL,3,2)+find(a == MinMaxOverlay(EL,2,2))-1);
                            end
                            
                        end
                    else
                        if start1 < stop1
                            
                            for ELn=1:size(SP_All,1)
                                
                                SP = SP_All(ELn,:);
                                start = size(SP,2)*(start1+Buffer)/Range;
                                stop2 = size(SP,2)*(stop1+Buffer)/Range;
                                
                                if start > find(a == MinMaxOverlay(ELn,2,2))
                                    [MinMaxOverlay(ELn,3,1),MinMaxOverlay(ELn,3,2)] = max(SP(start:stop2));
                                    
                                    MinMaxOverlay(ELn,3,2) = a(MinMaxOverlay(ELn,3,2)+start-1);
                                elseif stop2 > find(a == MinMaxOverlay(ELn,2,2))
                                    
                                    [MinMaxOverlay(ELn,3,1),MinMaxOverlay(ELn,3,2)] = max(SP(find(a == MinMaxOverlay(ELn,2,2)):stop2));
                                    
                                    MinMaxOverlay(ELn,3,2) = a(MinMaxOverlay(ELn,3,2)+find(a == MinMaxOverlay(ELn,2,2))-1);
                                    
                                end
                            end
                            
                            
                        end
                    end
                end
                drawSingleSpike();
            end
            
            
            
        end
        
        %   brief - $$$
        function Select(~,~)
            drawSingleSpike();
            counter = 0;
            time_start = 0;
            
            dcm_obj = datacursormode(SingleSpk);
            set(dcm_obj,'DisplayStyle','datatip',...
                'SnapToDataVertex','on','Enable','on','UpdateFcn',@LineTag)
        end
        
        %   brief - $$$
        function txt = LineTag (~,event_obj)
            
            dcm_obj = datacursormode(SingleSpk);
            c_info = getCursorInfo(dcm_obj);
            Spike = get(c_info(1).Target,'Tag');
            if isempty(Spike) || strncmp(Spike,'Points',6)
                pos = get(event_obj,'Position');
                txt = {['Time: ',sprintf('%.4f',pos(1))],...
                    ['Amplitude: ',num2str(pos(2))]};
            elseif strcmp(Spike,'Single')
                pos = get(event_obj,'Position');
                txt = {['Time: ',sprintf('%.4f',pos(1))],...
                    ['Amplitude: ',num2str(pos(2))]};
            elseif strcmp(Spike,'Green') == 1 || strcmp(Spike,'Red') || strcmp(Spike,'Grey') || strcmp(Spike,'Yellow')
                [Spike,~] = find(SPIKES(:,Electrode)==c_info(1).Position(1));
                txt = {['Spike: ' num2str(Spike)]};
            else
                txt = {['Spike: ' Spike]};
            end
            counter = counter + 1;
            if counter == 2
                
                time_dif = abs(pos(1) - time_start);
                set(QTManual,'String',num2str(time_dif));
                counter = 0;
            else
                time_start = pos(1);
            end
        end
        
        function HelpPropagation(~,~)
            Threshinfo = figure('color',[1 1 1],'Position',[150 75 800 800],'NumberTitle','off','toolbar','none','Name','Information about the module "Signal Propagation"');
            
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 790],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'String','This module serves the purpose of calculating the signal velocity on a manuelly defined path. The whole process consists of the following 3 steps:')
            
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 750],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'String','1. To make sure that the calculation of the signal propagation is done correctly, the Event-Array has to be filtered with "Event-Select".')
            
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 720],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'String','2. To be able to define a signal path in an event, one event has to be choosen in the popupmenu "Event". If an event has been selecte it will be drawn in the module and can be used for further processing.')
            
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 670],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'String','3. The definition of the signal path is done through the buttons "Start"/"Stop". "Start" activates the function which allows to select points within the drawn event from point 2. "Stop" ends the activated function and triggers the algorithm which draws the signal path and calculates the distance and time difference between the defined points. With the knowledge about distance and needed time the velocity can be calculated in a subsequent step.')
            
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 590],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'FontWeight','bold','string','Raster Plot');
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 570],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'String','As an additional tool to analyze the recognized spikes this function will creat a chart which shows the measurement time on the x-axis and the electrode numbers on the y-axis. Occuring spikes will be marked with "|" at the corresponding time as x value and electrode as y value.');
            
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 510],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'FontWeight','bold','string','Event Select');
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 490],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'String','The two panels which will open when this function is activated serve as means to filter the events inside the Event-Matrix. This is achieved through two different ways. The first one allows to address a specific event through a popupmenu which contains the corresponding event numbers. If one number has been selected the associated event can be removed from the matrix via the button "Remove Num". The second way uses the checkboxes in the second overview panel. Events can be removed by checking the appendant boxes and pressing the button "remove check".');
            
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 400],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'FontWeight','bold','string','3D');
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 380],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'String','This function creates an additional figure which shows the three dimenisonal view of the selected Event in the popupmenu "Event".');
            
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 350],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'FontWeight','bold','string','Video');
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 330],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'String','The function "Video" allows to create a .avi movie of an event. By pressing the button "Video" a processing panel with the button "save under" will be created. With the activation of "save under" a browser panel will open up which allows to define the storage location of the movie. If the location is confirmed the function will start to creat and then save the .avi File.');
            
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 270],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'FontWeight','bold','string','Contour Lines');
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 250],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'String','An additional feature of the visualization is the possibility to draw contour lines inside the choosen event. The density of the lines can be changed through the nearby popupmenu');
            
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 210],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'FontWeight','bold','string','Velocity Vector');
            uicontrol('Parent',Threshinfo,'style','text','units','Pixels','position', [5 5 790 190],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
                'String','This function serves as a mean to visualize the propagation course of the signal wave through velocity vectors that. The x- and y-value of the vector describe the dircetion of the signal while the magnitude of the vector describes the velocity of the signal wave.');
        end%~~
        
    end

% --- ZeroOut - Show Exapmle (CN)---------------------------
    function ZeroOutExampleButtonCallback(source,event) %#ok<INUSD>
        figure('Position',[150 50 1000 550],'Name','Example of artefactsupression of the first Stimuli','NumberTitle','off','Resize','off');
        plot(timePr,signal_draw(1,:),'k-')
        hold on
        plot(timePr,signalCorr_draw(1,:))
        title(['Electrode ' num2str(EL_NUMS(PREF(9))) ' - Artefactsupression - Black: original signal, Blue: signal after artefaktsupression']);
    end

% --- Frequency Analysis Cardiac - Popupmenu (AD)-----------
    function frequenzanalyseButtonCallback(source,event) %#ok
        clear ISI
        
        fh = figure('Units','Pixels','Position',[350 400 400 500],'Name','Beating Rate','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 370 360 100],'FontSize',11, 'String','Beating rate analysis for cardiac myocytes. Please select single, multi or complete analysis.');

        %---single analysis
        
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 360 200 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_electrodeLabel','String','Single Electrode Analysis','FontWeight','bold');
        if size(RAW.M,2)==60 % MEA 
            uicontrol('Parent',fh,'Units','Pixels','Position', [20 330 75 25],'Tag','ISIcall1','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',1,'Style','popupmenu');
        else % HDMEA
            uicontrol('Parent',fh,'Units','pixels','Position',[20 330 75 25],'style','edit','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','1','Tag','El_Select');
        end
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[290 320 100 30],'String','Analyze','ToolTipString','Start Analysis','CallBack',@Einzelanalysecallfunction);
        %---Multianalysis for 5 electrodes
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 265 200 30],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_electrodeLabel','String','Multi Electrode Analysis','FontWeight','bold');
        if size(RAW.M,2)<61 % MEA 
            uicontrol('Parent',fh,'Units','Pixels','Position', [20 250 75 25],'Tag','ISIcall2','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',1,'Style','popupmenu');
            uicontrol('Parent',fh,'Units','Pixels','Position', [95 250 75 25],'Tag','ISIcall3','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',1,'Style','popupmenu');
            uicontrol('Parent',fh,'Units','Pixels','Position', [170 250 75 25],'Tag','ISIcall4','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',1,'Style','popupmenu');
            uicontrol('Parent',fh,'Units','Pixels','Position', [245 250 75 25],'Tag','ISIcall5','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',1,'Style','popupmenu');
            uicontrol('Parent',fh,'Units','Pixels','Position', [320 250 75 25],'Tag','ISIcall6','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',1,'Style','popupmenu');
            uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 170 200 50],'HorizontalAlignment','left','FontSize',10, 'String','Select five electrodes.');
            uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[290 190 100 30],'String','Analyze','ToolTipString','Start Analysis','CallBack',@Multianalysecallfunction);
            uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 65 200 50],'HorizontalAlignment','left','FontSize',10, 'String','Analysis of all measured electrodes. Results will be shown tabular and saved as .xls..');

        else 
            uicontrol('Parent',fh,'Units','pixels','Position',[25 225 45 20],'style','text','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','El');
            uicontrol('Parent',fh,'style','edit','units','Pixels','position', [100 225 80 25],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_Select_electrode','string','1 2 3');
            uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[290 225 100 30],'String','Analyze','ToolTipString','Start Analysis','CallBack',@Multianalysecallfunction);
            uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 65 200 50],'HorizontalAlignment','left','FontSize',10, 'String','Analysis of all measured electrodes. Results will be saved as .xls.');


        end
        %---all electrodes
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 140 200 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_electrodeLabel','String','Complete Analysis','FontWeight','bold');
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[290 50 100 30],'String','Analyze','ToolTipString','Start Analysis','CallBack',@Komplettanalysecallfunction);
        
        
    end

% --- Single Electrode (AD)(Sh.Kh)--------------------------------
    function Einzelanalysecallfunction(~,~) 
        
        if size(RAW.M,2)<61 
            ISI_elektrode = get(findobj(gcf,'Tag','ISIcall1'),'value');    %Electrode #
        else
            ISI_elektrode = strread(get(findobj(gcf,'Tag','El_Select'),'string'));  % Electrode #
        end
        
        if ISI_elektrode<1 || ISI_elektrode>size(RAW.M,2)
            msgbox('Electrode Number is incorrect!')
        else
            ISI_bin=0.1;       %Timebin

            close(gcbf)

            % start analysis: -----------------------------------------------
            ISI=zeros(2,3);
            n=1;
            ni=size(SPIKES);
            while(SPIKES(n+1,ISI_elektrode)>0 && n+1<ni(1,1))

                ISI(n,1)=SPIKES(n+1,ISI_elektrode);                                      % "Timestamps"
                ISI(n,2)=(SPIKES(n+1,ISI_elektrode))-(SPIKES(n,ISI_elektrode));          % ISIs
                ISI(n,3)=1/(ISI(n,2));                                                   % Frequency

                n=n+1;
            end
                SPIKES(:,ISI_elektrode);
                size(SPIKES);

            RISI = sum(SPIKES(:,ISI_elektrode)~=0)/T(end);



            %Graph: --------------------------------------------------

            figure('Position',[50 1 850 900]);

            % Information
            subplot(22,2,[1 2]);
            axis off;
            text(0,3,['Beating Rate Analysis (Cardiac Myocytes). Electrode:' num2str(EL_NUMS(ISI_elektrode))],'FontWeight','demi', 'Fontsize',12);
            text(0,2.2,num2str(full_path),'Fontsize',9);
            if   HDspikedata~=1 && HDrowdata~=1  
                text(0,1.5,[fileinfo{1}],'Fontsize',9);
            end

            % Signal
            scale = get(scalehandle,'value');   % Y-Scale
            switch scale
                case 1, scale = 50;
                case 2, scale = 100;
                case 3, scale = 200;
                case 4, scale = 500;
                case 5, scale = 1000;
            end
            subplot(22,2,[3 10]);
            plot(T,RAW.M(:,ISI_elektrode),'color','black');
            xlabel('time / s'); ylabel('voltage / mV');
            axis([0 T(size(T,2)) -1*scale scale]);
            grid on;
            if spikedata==1  
                line ('Xdata',[0 T(length(T))],...
                    'Ydata',[THRESHOLDS(ISI_elektrode) THRESHOLDS(ISI_elektrode)],...
                    'LineStyle',':','Color','blue');
            end

            %  Spiketrain
            subplot(22,2,[13 14]);
            axis off;
            isi_dim=50;
            axis([0 T(size(T,2)) -1*isi_dim isi_dim]);
            SP = nonzeros(SPIKES(:,ISI_elektrode));
            y_axis = ones(length(SP),1).*isi_dim.*.9;
            line ([0 ;T(size(T,2))],[5 ; 5],...
                'LineStyle','-','Linewidth',20,'color','white','Marker','none');
            for n=1:15
                line ('Xdata',SP,'Ydata', y_axis-(4*n+10),...
                    'LineStyle','none','Marker','.',...
                    'MarkerEdgeColor','black','MarkerSize',1);
            end
            text(-3.5,-70,'spike-','rotation',90);
            text(-2.1,-70,'train','rotation',90);

            % Frequency
            subplot(22,2,[15 22]);
            plot(ISI(:,1),ISI(:,3),'-k.')
            axis([0 T(size(T,2)) 0 (0.1+max(ISI(:,3)))*2]);
            xlabel('time / s'); ylabel('frequency / Hz');
            line([0 ;T(size(T,2))],[mean(ISI(:,3)) ; mean(ISI(:,3))],'LineStyle',':')

            % ISIs
            subplot(22,2,[25 32]);
            plot(ISI(:,1),ISI(:,2),'-k.')
            axis([0 T(size(T,2)) 0 (0.1+max(ISI(:,2)))*2]);
            xlabel('time / s'); ylabel('ISI / s');
            line([0 ;T(size(T,2))],[max(ISI(:,2)) ; max(ISI(:,2))],'LineStyle',':')
            line([0 ;T(size(T,2))],[min(ISI(:,2)) ; min(ISI(:,2))],'LineStyle',':')

            % Values
            subplot(22,2,[36 42]);
            axis off;
            text(0,0.9,['frequency (mean): ' num2str(RISI) 'Hz']);
            text(0,0.8,['frequency (sd): ' num2str(std(ISI(:,3)))]);

            %MAD calculation
            n=1; mad_temp=0;
            ni=size(ISI);
            while n+1<ni(1,1)
                mad_temp(n,1)=abs(ISI(n,3)-median(ISI(:,3)));
                n=n+1;
            end
            MAD_Andy=median(mad_temp);
            %end

            %text(0,0.6,['frequency (median): ' num2str(median(ISI(:,3))) 'Hz']);
            text(0,0.7,['frequency (MAD): ' num2str(MAD_Andy)]);
            text(0,0.5,['ISI (mean): ' num2str(mean(ISI(:,2))) 's']);
            text(0,0.4,['ISI (sd): ' num2str(std(ISI(:,2)))]);
            text(0,0.3,['time bin: ' num2str(ISI_bin)]);

            % Histogram
            edges=0:ISI_bin:3;
            answer=histc(ISI(:,2), edges);
            subplot(22,2,[35 41]);
            bar(edges, answer)
            xlabel('ISI / s'); ylabel('counts /bin');


            %clear workspace
            clear ISI;
            clear ISI_bin;
            clear ISI_elektrode;
            clear edges;
            clear answer;
            clear isi_dim;
        end

end

% --- Multi Analysis (5 channels) (AD)--------
    function Multianalysecallfunction(source,event) %#ok<INUSD>
        
        if size(RAW.M,2)<61 %MEA Chip
            ISI_elektrode(1,1)=get(findobj(gcf,'Tag','ISIcall2'),'value');
            ISI_elektrode(2,1)=get(findobj(gcf,'Tag','ISIcall3'),'value');
            ISI_elektrode(3,1)=get(findobj(gcf,'Tag','ISIcall4'),'value');
            ISI_elektrode(4,1)=get(findobj(gcf,'Tag','ISIcall5'),'value');
            ISI_elektrode(5,1)=get(findobj(gcf,'Tag','ISIcall6'),'value');
        else % HDMEA Chip
            ISI_elektrode = strread(get(findobj(gcf,'Tag','CELL_Select_electrode'),'string'));
            ISI_elektrode = ISI_elektrode';
        end
        error=0;
        for n=1:size(ISI_elektrode,1)
            if size(ISI_elektrode,1)>5
                msgbox('please choose only up to 5 Electrode!')
                error=1;
            end
            if ISI_elektrode(n,1)<1 || ISI_elektrode(n,1)>4096
                msgbox('Electrode number is wrong!')
                error=1;
            end
        end
        if error~=1

            close(gcbf)
            RISI = 0;
            % start analysis: -----------------------------------------------
            for i=1:size(ISI_elektrode,1)
                ISI(1,1,i)=0; ISI(1,2,i)=0; ISI(1,3,i)=0;
                ISI(2,1,i)=0; ISI(2,2,i)=0; ISI(2,3,i)=0;

                n=1;
                ni=size(SPIKEZ.TS);
                while(SPIKEZ.TS(n+1,ISI_elektrode(i,1))>0 && n+1<ni(1,1))
                    ISI(n,1,i)=SPIKEZ.TS(n+1,ISI_elektrode(i,1));                                         % "Timestamps"
                    ISI(n,2,i)=(SPIKEZ.TS(n+1,ISI_elektrode(i,1)))-(SPIKEZ.TS(n,ISI_elektrode(i,1)));        % ISIs
                    ISI(n,3,i)=1/(ISI(n,2,i));                                                         % Frequency
                    n=n+1;
                end
                RISI(i) = sum(SPIKEZ.TS(:,ISI_elektrode(i,1))~=0)/T(end);
            end

            % Results
            figure('Position',[60 60 850 900]);

            % Information
            subplot(31,4,[1 4]);
            axis off;
            text(0,3,['Beating Rate Analysis (Cardiac Myocytes). Electrodes:' num2str(EL_NUMS(ISI_elektrode(:,1)))],'FontWeight','demi', 'Fontsize',12);
            text(0,2.2,num2str(full_path),'Fontsize',9);
            if HDspikedata~=0 && HDrowdata~=0 
                text(0,1.5,fileinfo{1},'Fontsize',9);
            end

            %for i=1:5
            for i=1:size(ISI_elektrode,1)
                %  Spiketrain
                subplot(31,4,[(9+(24*(i-1))) (11+(24*(i-1)))]);
                axis off;
                isi_dim=50;
                axis([0 T(size(T,2)) -1*isi_dim isi_dim]);
                SP = nonzeros(SPIKES(:,ISI_elektrode(i,1)));
                y_axis = ones(length(SP),1).*isi_dim.*.9;
                line ([0 ;T(size(T,2))],[5 ; 5],...
                    'LineStyle','-','Linewidth',20,'color','white','Marker','none');
                for n=1:15
                    line ('Xdata',SP,'Ydata', y_axis-(4*n+10),...
                        'LineStyle','none','Marker','.',...
                        'MarkerEdgeColor','black','MarkerSize',1);
                end
                text(-2.5,-50,'spike-','rotation',90,'Fontsize',7);
                text(-1.1,-50,'train','rotation',90,'Fontsize',7);

                % Frequency
                subplot(31,4,[13+24*(i-1) 23+24*(i-1)]);
                ISI_NZ1=nonzeros(ISI(:,1,i));

                ISI_NZ3=nonzeros(ISI(:,3,i));
                plot (ISI_NZ1(:,1),ISI_NZ3(:,1),'-k.')
                axis([0 T(size(T,2)) 0 ((max(ISI(:,3,i)))*2)+0.1]);
                xlabel('time / s'); ylabel('frequency / Hz');
                line([0 ;T(size(T,2))],[mean(ISI_NZ3(:,1)) ; mean(ISI_NZ3(:,1))],'LineStyle',':')

                % Values
                subplot(31,4,[16+24*(i-1) 28+24*(i-1)]);
                axis off;
                text(0,1.2,['Electrode ' num2str(EL_NUMS(ISI_elektrode(i,1)))],'FontWeight','demi');
                text(0,1,['frequency (mean): ' num2str(RISI(i)) 'Hz']);
                text(0,0.8,['frequency (sd): ' num2str(std(ISI_NZ3(:,1)))]);

                % MAD calculation
                mad_temp=0;
                n=1;
                ni=size(ISI_NZ3);
                while n+1<ni(1,1)
                    mad_temp(n,1)=abs(ISI_NZ3(n,1)-median(ISI_NZ3(:,1)));
                    n=n+1;
                end
                MAD_Andy=median(mad_temp);

                %text(0,0.5,['frequency (median): ' num2str(median(ISI_NZ3(:,1))) 'Hz']);
                text(0,0.6,['frequency (MAD): ' num2str(MAD_Andy)]);
                clear MAD_Andy mad_temp
            end
        end
    end

% --- Complete Analysis (AD)--------------------
    function Komplettanalysecallfunction(source,event) %#ok<INUSD>
        close(gcbf)
        gib = 0;
        RISI = 0;
        TXT =zeros(size(SPIKES,2),5);
        txt= {'Electrods Nr.','mean (f)','std 8f)','mad (f)','no of spikes'};
        %beg_el = 1;
        %end_el = 60;
        % Information
        if HDspikedata~=1 || HDrowdata~=1 % MEA Data
            figure('Position',[50 1 750 900]);
            axis off;
            text(-0.1,1.06,'Complete Analysis','FontWeight','demi', 'HorizontalAlignment', 'left');
            text(0.1,1.02,'mean (f)','FontWeight','demi', 'HorizontalAlignment', 'center');
            text(0.3,1.02,'sd (f)','FontWeight','demi', 'HorizontalAlignment', 'center');
            text(0.5,1.02,'mad (f)','FontWeight','demi', 'HorizontalAlignment', 'center');
            text(0.7,1.02,'no of spikes','FontWeight','demi', 'HorizontalAlignment', 'center');
        end
        
        
        for i=1:size(SPIKES,2)
            RISI = sum(SPIKES(:,i)~=0)/T(end);
            n=1;
            ni=size(SPIKES);
            ISI(1,1,i)=0;
            ISI(1,2,i)=0;
            ISI(1,3,i)=0;
           while(n < ni(1,1) && SPIKES(n+1,i)>0)
              ISI(n,1,i)=SPIKES(n+1,i);                                          % "Timestamps" 
              ISI(n,2,i)=(SPIKES(n+1,i))-(SPIKES(n,i));                          % ISIs
              ISI(n,3,i)=1/(ISI(n,2,i));   
                                                            % Frequency
              n=n+1;
              
           end
           gib = ISI(:,3,i);
           gib(gib==0)=[];
%         for i=1:m(1,2)
%             n=1;
%             ni=size(SPIKES)
%             ni(1,1)
%             ISI(1,1,i)=0;
%             ISI(1,2,i)=0;
%             ISI(1,3,i)=0;
%             while(SPIKES(n,i)>0 && n+1<=ni(1,1))
%                 ISI(n,1,i)=SPIKES(n,i);                                          % "Timestamps"
%                 
%                 ISI(n,2,i)=(SPIKES(n+1,i))-(SPIKES(n,i));                          % ISIs
%                 
%                 
%                 ISI(n,3,i)=1/(ISI(n,2,i)); % Frequency
%                 if n+1 == ni(1,1)
%                     ISI(n+1,1,i)=SPIKES(n+1,i);
%                     ISI(n+1,2,i)=(SPIKES(n+1,i));
%                     ISI(n+1,3,i)=1/(ISI(n+1,2,i));
%                 end
%                 n=n+1;
%                 
%             end
            
            
            % MADs:
            mad_temp=0;
            k=1;
            ki=size(nonzeros(ISI(:,1,i)));
            while k+1<ki(1,1)
                mad_temp(k,1)=abs(ISI(k,3,i)-median(ISI(:,3,i)));
                k=k+1;
            end
            MAD_Andy=median(mad_temp);
            % end
            
            % --- Results
%             tmpc=0.2;
%             if mod (i,2)==0  % Different colors...
%                 tmpc=1;
%             end
            
            %---Sh.Kh
            
            TXT(i,1) = EL_NUMS(i);
            TXT(i,2) = RISI;
            TXT(i,3) = std(gib);
            TXT(i,4) = MAD_Andy;
            if ki(1,1) > 0
                l = ki(1,1)+1;
            else
                l = 0;
            end
            TXT(i,5) = l;
            %----
            
      
            
        end
        if HDspikedata~=1 && HDrowdata~=1 % MEA Data
            for i=1:size(SPIKES,2)
                text(-0.1,(1-0.018*i),['El ' num2str(EL_NUMS(i))],'FontWeight','demi', 'HorizontalAlignment', 'left', 'color', [0 0 0]);
                text(0.1,(1-0.018*i),[num2str(TXT(i,2)   ) 'Hz'], 'HorizontalAlignment', 'right', 'color', [0 0 0]);
                text(0.3,(1-0.018*i),num2str(TXT(i,3)), 'HorizontalAlignment', 'right', 'color', [0 0 0]);
                %text(0.5,(1-0.018*i),[num2str(median(gib)) 'Hz'], 'HorizontalAlignment', 'right', 'color', [tmpc tmpc tmpc]);
                text(0.5,(1-0.018*i),num2str(TXT(i,4)), 'HorizontalAlignment', 'right', 'color', [0 0 0]);
                text(0.7,(1-0.018*i),num2str(TXT(i,5)), 'HorizontalAlignment', 'right', 'color', [0 0 0]);    
            end
        end 
        % Exel Export 
        title=['.xls'];
        [filename, pathname] = uiputfile ('*.xls','save as...',title);
        if filename==0, return,end
        h = waitbar(0,'please wait, save data...');
        waitbar(0.2)
        xlswrite( [pathname filename],txt ,'Tabelle1', 'A1');
        waitbar(0.6)
        xlswrite( [pathname filename], TXT, 'Tabelle1','A3');
        waitbar(1);
        close(h);
        clear MAD_Andy mad_temp
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
            if SPIKES(1,i)>0
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

% --- Spike Overlay (FS) ----------------------------------------------
    function SpkOverlay(~,~)
        QTAmpWindow = 0;
        
        Elektrode = 1; %selected electrode
        OverlayZoom = []; %saves zoom for LockView in Overlaygraphen
        SingleZoom = []; %saves zoom for LockView in Overlaygraphen SingleSpikegraphen
        Overlay = []; %Handle Overlayplots (LockView)
        Single = []; %Handle SingleSpikeplots (LockView)
        ZeroSingle = []; %saves, if a nullgraph is shwon (Overlaygraphen)
        ZeroOverlay = []; %saves if a nullgraph is shwon (SingleSpikegraphen)
        
        SPIKESCOPY = SPIKES;
        SPIKESDEL = zeros(size(SPIKES)); %deleted spikes
        SPIKESCUT = zeros(size(SPIKES,1),1); %spikes that cant be shown due to the timewindow
        
        Laenge = 0.5; %lenght of window
        Vorlauf = 0.1; %start window in Overlaygraph
        OldSpike = 1;
        
        CharTime = []; %charakteristic Spiketimeintervals (Dimensions: 1.Electrode,2.Spike,3.Value(1=1.time,2=2.time,3=1.Amplitude,4=2.Amplitude)
        DifTime = []; %Differences der Spiketimes (e.g.T2-T1) (Dimensionen: 1.Electrode,2.Spike,3.values 1-5)
        MinMax = []; %Min/Max (Dimensions: 1.Electrode,2.Spike,3.Values(Max1,Min,Max2),4.Values(1.X-Wert,2.Y-Wert))
        
        %Mainwindow
        SpkOverlayPopup = figure('Name','Spike Overlay','NumberTitle','off','Position',[100 80 1070 800],'Toolbar','none','Resize','off','Color',[0.89 0.89 0.99]);
        
        ControlPanel=uipanel('Parent',SpkOverlayPopup,'Units','pixels','Position',[520 370 520 230],'BackgroundColor', GUI_Color_BG);
        uipanel('Parent',SpkOverlayPopup,'Units','pixels','Position',[20 346 1030 5],'BackgroundColor', GUI_Color_BG);
        SpikePanel=uipanel('Parent',SpkOverlayPopup,'Units','pixels','Position',[520 20 520 310],'BackgroundColor', GUI_Color_BG);
        
        uicontrol(SpkOverlayPopup,'Style', 'text','Position', [60 595 125 25],'String','Overlay-Graph:' ,'FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol(SpkOverlayPopup,'Position', [50 560 15 15],'String', '+','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG,'callback',@Zoom);
        %Electrodeselection-Buttons
        uicontrol('Parent',SpkOverlayPopup,'Style', 'text','Position', [225 595 100 25],'String', 'Electrode: ','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpkOverlayPopup,'Units','Pixels','Position', [325 597 60 25],'Tag','Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Value',1,'Style','popupmenu','callback',@SpkCount);
        LockViewOverlay = uicontrol('Parent',SpkOverlayPopup,'Units','Pixels','Position', [400 598 70 25],'Tag','LockViewSingle','String','Lock view','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Keeps the current Zoom level','callback',@LockOverlay);
        
        %Skale-Button in ControlPanel
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [5 190 100 25],'String', 'y-Axis Scale','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        Skala = uicontrol('Parent',ControlPanel,'Style','popupmenu','Units','Pixels','Position', [105 193 75 25],'String',['  50 uV';' 100 uV';' 200 uV';' 500 uV';'1000 uV'],'Tag','Skala','HorizontalAlignment','right','FontSize',8,'Value',get(scalehandle,'value'),'callback',@DrawBoth);
        %timewindow-Buttons in ControlPanel
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [5 145 75 25],'String', 'Range: ','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [77 149 50 25],'String',500,'Tag','Laenge','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit','callback',@DrawBoth);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [127 145 25 25],'String', 'ms','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [190 145 75 25],'String', 'Buffer:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [262 149 50 25],'String',100,'Tag','Vorlauf','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit','callback',@DrawBoth);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [312 145 25 25],'String', 'ms','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        %Spikeselection-Buttons in ControlPanel
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [5 90 125 25],'String', 'Spike selection:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Position', [15 65 60 25],'String', 'Select','FontSize',8,'TooltipString','Hold ALT for multiple Selections','callback',@Select);
        uicontrol('Parent',ControlPanel,'Position', [100 65 60 25],'String', 'Del','FontSize',8,'TooltipString','SELECT a line, then press DEL to deactivate this Spike','callback',@SpikeDel);
        uicontrol('Parent',ControlPanel,'Position', [165 65 60 25],'String', 'Add','FontSize',8,'TooltipString','SELECT a line, then press ADD to reactivate this Spike','callback',@SpikeAdd);
        
        uicontrol('Parent',ControlPanel,'Units','pixels','Position',[15 20 60 25],'Tag','Reset','String','Reset','FontSize',8,'BackgroundColor', GUI_Color_BG,'TooltipString','Reactivate all manually deactivated Spikes','Callback',@Reset);
        uicontrol('Parent',ControlPanel,'Units','pixels','Position',[132 20 60 25],'Tag','Clear','String','Clear','FontSize',8,'BackgroundColor', GUI_Color_BG,'TooltipString','Clear Selection and Zoom','Callback',@Clear);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [280 90 135 25],'String', 'Active Elektrodes: 0','Tag','ActiveEL','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',ControlPanel,'Position',[440 20 60 25],'Tag','ExportOverlay','String','Export','BackgroundColor', GUI_Color_BG,'TooltipString','Allows to save current Overlaygraph data','Callback',@ExportOverlay);
        %SingleSpike
        uicontrol(SpkOverlayPopup,'Style', 'text','Position', [60 295 150 25],'String','SingleSpike-Graph:' ,'FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol(SpkOverlayPopup,'Position', [50 265 15 15],'String', '+','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG,'callback',@Zoom);
        %Spikeselection
        uicontrol('Parent',SpkOverlayPopup,'Style', 'text','Position', [260 295 65 25],'String', 'Spike: ','FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        Spikeauswahl = uicontrol('Parent',SpkOverlayPopup,'Units','Pixels','Position', [325 297 60 25],'Tag','Spikeauswahl','FontSize',8,'String','bla','Value',1,'Style','popupmenu','callback',@DrawSingleSpike);
        LockViewSingle = uicontrol('Parent',SpkOverlayPopup,'Units','Pixels','Position', [400 298 70 25],'Tag','LockViewSingle','String','Lock view','Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Keeps the current Zoom level','callback',@LockSingle);
        
        %SpikePanel
        uicontrol('Parent',SpikePanel,'Units','Pixels','Position', [10 10 65 15],'String','All ELs','Tag','AllELs','HorizontalAlignment','right','FontSize',8,'Value',0,'Style','checkbox','BackgroundColor', GUI_Color_BG,'TooltipString','Decides whether to use only the selected or all electrodes for mean, std and median determination','callback',@PPFiller);
        
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [10 275 100 25],'String', 'Char points:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [150 285 30 15],'String', 'Show','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [320 285 30 15],'String', 'Mean','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [390 285 30 15],'String', 'Std','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [460 285 35 15],'String', 'Median','BackgroundColor', GUI_Color_BG);
        
        
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [12.5 240 65 25],'Tag','MinMaxAuto','FontSize',8,'String','Autodetect','TooltipString','Automatical sets Extrema for this Spike','callback',@AutoMinMax);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [5 210 80 25],'Tag','MinMaxPeriod','FontSize',8,'String','Set Period 1-3','TooltipString',['Creates 3 time periods using the char. points:' char(10) 'Period 1: Maximum 1 - Minimum' char(10) 'Period 2: Zero - Minimum' char(10) 'Period 3: Minimum - Maximum 2'],'callback',@MaxMinMaxPeriod);
        
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [100 255 60 25],'Tag','Max1','FontSize',8,'String','Max1','TooltipString','SELECT a point, then press MAX1 to set new first Maximum','callback',@Max1Det);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [100 225 60 25],'Tag','Min','FontSize',8,'String','Min','TooltipString','SELECT a point, then press MIN to set new Maximum','callback',@MinDet);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [100 195 60 25],'Tag','Max2','FontSize',8,'String','Max2','TooltipString','SELECT a point, then press MAX2 to set new second Maximum','callback',@Max2Det);
        
        Time1panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [180 255 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Time2panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [180 225 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Time3panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [180 195 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [242 260 15 15],'String', 'ï¿½V','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [242 230 15 15],'String', 'ï¿½V','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [242 200 15 15],'String', 'ï¿½V','BackgroundColor', GUI_Color_BG);
        
        MinMaxShow = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [160 255 15 25],'String','','Tag','MinMaxShow','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG,'callback',@DrawSingleSpike);
        
        Time1Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305 255 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Time2Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305 225 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Time3Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305 195 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        Time1Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375 255 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Time2Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375 225 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Time3Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375 195 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        Time1Median = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [445 255 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Time2Median = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [445 225 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Time3Median = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [445 195 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        
        uicontrol('Parent',SpikePanel,'Style', 'text','Position',  [10 150 90 25],'String', 'Char periods:','FontSize',10,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [140 150 30 25],'String', 'Show','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [320 150 30 25],'String', 'Mean','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [390 150 30 25],'String', 'Std','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [460 150 35 25],'String', 'Median','BackgroundColor', GUI_Color_BG);
        
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [15  70 60 25],'Tag','TimeMeasure','FontSize',8,'String','Select','TooltipString','Hold ALT for multiple Selections','callback',@Select);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [90 130 60 25],'Tag','Period1','FontSize',8,'String','Period 1','TooltipString','SELECT two points, then press Period1 to set new time period','callback',@Period1);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [90 100 60 25],'Tag','Period2','FontSize',8,'String','Period 2','TooltipString','SELECT two points, then press Period2 to set new time period','callback',@Period2);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [90  70 60 25],'Tag','Period3','FontSize',8,'String','Period 3','TooltipString','SELECT two points, then press Period3 to set new time period','callback',@Period3);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [90  40 60 25],'Tag','Period3','FontSize',8,'String','Period 4','TooltipString','SELECT two points, then press Period4 to set new time period','callback',@Period4);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [90  10 60 25],'Tag','Period3','FontSize',8,'String','Period 5','TooltipString','SELECT two points, then press Period5 to set new time period','callback',@Period5);
        
        Period1Show = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150 130 15 25],'String','','Tag','Show1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG,'callback',@Show1);
        Period2Show = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150 100 15 25],'String','','Tag','Show2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG,'callback',@Show2);
        Period3Show = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150  70 15 25],'String','','Tag','Show3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG,'callback',@Show3);
        Period4Show = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150  40 15 25],'String','','Tag','Show4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG,'callback',@Show4);
        Period5Show = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150  10 15 25],'String','','Tag','Show5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor', GUI_Color_BG,'callback',@Show5);
        
        Period1panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [170 130 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period2panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [170 100 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period3panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [170  70 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period4panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [170  40 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period5panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [170  10 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [232 135 15 15],'String', 'ms','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [232 105 15 15],'String', 'ms','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [232  75 15 15],'String', 'ms','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [232  45 15 15],'String', 'ms','BackgroundColor', GUI_Color_BG);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [232  15 15 15],'String', 'ms','BackgroundColor', GUI_Color_BG);
        
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [255 135 14 14],'Tag','ClearPeriod1','String','x','BackgroundColor', GUI_Color_BG,'TooltipString','Clear Period1','callback',@ClearPeriod1);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [255 105 14 14],'Tag','ClearPeriod2','String','x','BackgroundColor', GUI_Color_BG,'TooltipString','Clear Period2','callback',@ClearPeriod2);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [255  75 14 14],'Tag','ClearPeriod3','String','x','BackgroundColor', GUI_Color_BG,'TooltipString','Clear Period3','callback',@ClearPeriod3);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [255  45 14 14],'Tag','ClearPeriod4','String','x','BackgroundColor', GUI_Color_BG,'TooltipString','Clear Period4','callback',@ClearPeriod4);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [255  15 14 14],'Tag','ClearPeriod5','String','x','BackgroundColor', GUI_Color_BG,'TooltipString','Clear Period5','callback',@ClearPeriod5);
        
        
        Period1Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305 130 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period2Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305 100 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period3Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305  70 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period4Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305  40 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period5Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305  10 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        Period1Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375 130 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period2Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375 100 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period3Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375  70 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period4Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375  40 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period5Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375  10 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        Period1Median = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [445 130 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period2Median = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [445 100 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period3Median = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [445  70 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period4Median = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [445  40 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period5Median = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [445  10 60 25],'String','','Tag','','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        
        
        %find number of active electrodes
        AktEl = 0;
        for j=1:size(SPIKES,2)
            if isempty(nonzeros(SPIKES(:,j))) == 0
                AktEl = AktEl + 1;
            end
        end
        set(findobj(gcf,'Tag','ActiveEL'),'string',['Active Electrodes: ',num2str(AktEl)]);
        clear j;
        
        FindPoints;
        SpkCount;
        
        %Draw Overlay Graphs
        function DrawOverlay(~,~)
            Laenge = str2double(get(findobj(gcf,'Tag','Laenge'),'string'))/1000; %window length
            Vorlauf = str2double(get(findobj(gcf,'Tag','Vorlauf'),'string'))/1000; %start window
            Elektrode = get(findobj(gcf,'Tag','Elektrodenauswahl'),'value');    %electrode
            
            temp = [];
            SPIKESCUT = zeros(size(SPIKES,1),1);
            for k=1:size(SPIKESCOPY,1)
                if SPIKES(k,Elektrode)*SaRa+1-(Vorlauf)*SaRa > 0 && ...
                        SPIKES(k,Elektrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(RAW.M,1)
                    if SPIKESCOPY(k,Elektrode) > 0
                        temp(:,k) = RAW.M(SPIKESCOPY(k,Elektrode)*SaRa+1-(Vorlauf)*SaRa:SPIKESCOPY(k,Elektrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Elektrode);
                    else
                        temp(1:SaRa*Laenge,k) = 0;
                    end
                else
                    if SPIKESCOPY(k,Elektrode) ~= 0
                        SPIKESCUT(k) = SPIKESCOPY(k,Elektrode);
                    else
                        SPIKESCUT(k) = SPIKESDEL(k,Elektrode);
                    end
                end
            end
            clear k;
            
            Scale = get(Skala,'value');   % set y-scale
            switch Scale
                case 1, Scale = 50;
                case 2, Scale = 100;
                case 3, Scale = 200;
                case 4, Scale = 500;
                case 5, Scale = 1000;
            end
            
            %Create Graph
            uicontrol(SpkOverlayPopup,'Style', 'text','Position', [60 770 100 25],'String', ['Electrode: ' num2str(EL_NUMS(get(findobj(gcf,'Tag','Elektrodenauswahl'),'value')))],'FontSize',11,'FontWeight','bold','BackgroundColor', GUI_Color_BG);
            subplot('Position',[0.1 0.81 0.87 0.14]);
            plot (linspace(0,size(RAW.M,1)/SaRa,size(RAW.M,1)),RAW.M(:,Elektrode)','Tag','');
            xlabel ('time / s');
            ylabel ('voltage / ï¿½V');
            
            %insert marks
            SP = nonzeros(SPIKESCOPY(:,Elektrode));
            if isempty(SP)==0
                y_axis = ones(length(SP),1).*Scale.*.92;
                line ('Xdata',SP,'Ydata', y_axis,'Tag','Green',...
                    'LineStyle','none','Marker','v',...
                    'MarkerFaceColor','green','MarkerSize',9);
            end
            
            SP = nonzeros(SPIKESDEL(:,Elektrode));
            if isempty(SP)==0
                y_axis = ones(length(SP),1).*Scale.*.92;
                line ('Xdata',SP,'Ydata', y_axis,'Tag','Red',...
                    'LineStyle','none','Marker','v',...
                    'MarkerFaceColor','red','MarkerSize',9);
            end
            
            SP = nonzeros(SPIKESCUT);
            if isempty(SP)==0
                y_axis = ones(length(SP),1).*Scale.*.92;
                line ('Xdata',SP,'Ydata', y_axis,'Tag','Grey',...
                    'LineStyle','none','Marker','v',...
                    'MarkerFaceColor',[0.89 0.89 0.99],'MarkerSize',9);
            end
            
            xlim('auto');
            ylim([-Scale-50 Scale]);
            clear SP;
            
            %Create Overlay-Graph
            subplot('Position',[0.1 0.49 0.34 0.24]);
            
            if isempty(temp)
                plot(linspace(-Vorlauf,Laenge-Vorlauf,5),linspace(-Vorlauf,Laenge-Vorlauf,5)*0,'-');
                axis([-Vorlauf Laenge-Vorlauf -Scale-50 Scale]);
                set(LockViewOverlay,'Enable','off');
                ZeroOverlay = true;
            else
                LockOverlay;
                for k=1:size(temp,2)
                    Overlay = plot(linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge),temp(:,k),'Tag',num2str(k));
                    hold all
                end
                ZeroOverlay = false;
                if isempty(OverlayZoom) == 0
                    SetView(Overlay,OverlayZoom)
                else
                    axis([-Vorlauf Laenge-Vorlauf -Scale-50 Scale]);
                end
            end
            
            hold off
            xlabel ('time / s');
            ylabel ('voltage / ï¿½V');
        end
        
        %Draw Single-Spike-Graph
        function DrawSingleSpike (~,~)
            break_point = 0;
            br = 0;
            subplot('Position',[0.1 0.115 0.34 0.24]);
            delete(findobj(0,'Tag','Yellow'));
            
            Scale = get(Skala,'value');   % set y-scale
            switch Scale
                case 1, Scale = 50;
                case 2, Scale = 100;
                case 3, Scale = 200;
                case 4, Scale = 500;
                case 5, Scale = 1000;
            end
            
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            %Window 1
            if size(CharTime,1) >= Elektrode && size(CharTime,2) >= Spike && size(CharTime,3) >= 4 &&...
                    max(CharTime(Elektrode,Spike,1),CharTime(Elektrode,Spike,2)) > 0
                DifTime(Elektrode,Spike,1)=abs(CharTime(Elektrode,Spike,2)-CharTime(Elektrode,Spike,1));
                set(Period1panel,'string',DifTime(Elektrode,Spike,1)*1000);
            else
                set(Period1panel,'string',[])
                DifTime(Elektrode,Spike,1)=0;
            end
            %Window 2
            if size(CharTime,1) >= Elektrode && size(CharTime,2) >= Spike && size(CharTime,3) >= 8 &&...
                    max(CharTime(Elektrode,Spike,5),CharTime(Elektrode,Spike,6)) > 0
                DifTime(Elektrode,Spike,2)=abs(CharTime(Elektrode,Spike,6)-CharTime(Elektrode,Spike,5));
                set(Period2panel,'string',DifTime(Elektrode,Spike,2)*1000);
            else
                set(Period2panel,'string',[])
                DifTime(Elektrode,Spike,2)=0;
            end
            %Window 3
            if size(CharTime,1) >= Elektrode && size(CharTime,2) >= Spike && size(CharTime,3) >= 12 &&...
                    max(CharTime(Elektrode,Spike,9),CharTime(Elektrode,Spike,10)) > 0
                DifTime(Elektrode,Spike,3)=abs(CharTime(Elektrode,Spike,10)-CharTime(Elektrode,Spike,9));
                set(Period3panel,'string',DifTime(Elektrode,Spike,3)*1000);
            else
                set(Period3panel,'string',[])
                DifTime(Elektrode,Spike,3)=0;
            end
            %Window 4
            if size(CharTime,1) >= Elektrode && size(CharTime,2) >= Spike && size(CharTime,3) >= 16 &&...
                    max(CharTime(Elektrode,Spike,13),CharTime(Elektrode,Spike,14)) > 0
                DifTime(Elektrode,Spike,4) = abs(CharTime(Elektrode,Spike,14)-CharTime(Elektrode,Spike,13));
                set(Period4panel,'string',DifTime(Elektrode,Spike,4)*1000);
            else
                set(Period4panel,'string',[])
                DifTime(Elektrode,Spike,4) = 0;
            end
            %Window 5
            if size(CharTime,1) >= Elektrode && size(CharTime,2) >= Spike && size(CharTime,3) >= 20 &&...
                    max(CharTime(Elektrode,Spike,17),CharTime(Elektrode,Spike,18)) > 0
                DifTime(Elektrode,Spike,5) = abs(CharTime(Elektrode,Spike,18)-CharTime(Elektrode,Spike,17));
                set(Period5panel,'string',DifTime(Elektrode,Spike,5)*1000);
            else
                set(Period5panel,'string',[])
                DifTime(Elektrode,Spike,5) = 0;
            end
            
            %Check, if there are spikes at all
            if isempty(get(findobj(gcf,'Tag','Spikeauswahl'),'string'))
                plot(linspace(-Vorlauf,Laenge-Vorlauf,5),linspace(-Vorlauf,Laenge-Vorlauf,5)*0,'-');
                xlabel ('time / s');
                ylabel ('voltage / ï¿½V');
                axis([-Vorlauf Laenge-Vorlauf -Scale-50 Scale]);
                set(LockViewSingle,'Enable','off');
                ZeroSingle = true;
            else
                Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
                if SPIKESCUT(Spike) > 0
                    plot(linspace(-Vorlauf,Laenge-Vorlauf,5),linspace(-Vorlauf,Laenge-Vorlauf,5)*0,'-','Tag','Single');
                    xlabel ('time / s');
                    ylabel ('voltage / ï¿½V');
                    axis([-Vorlauf Laenge-Vorlauf -Scale-50 Scale]);
                    subplot('Position',[0.1 0.81 0.87 0.14]);
                    SP = SPIKES(Spike,Elektrode);
                    y_axis = ones(length(SP),1).*(-Scale).*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','^',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                    
                    msgbox ('Spike kann nicht angezeigt werden, da Betrachtungsfenster ï¿½ber Messzeitraum reicht.','Error','error');
                    set(LockViewSingle,'Enable','off');
                    ZeroSingle = true;
                else
                    LockSingle;
                    
                    SP = RAW.M(SPIKES(Spike,Elektrode)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,Elektrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Elektrode);
                    Single = plot(linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge),SP,'Tag','Single');
                    ZeroSingle = false;
                    OldSpike = get(Spikeauswahl,'Value');
                    xlabel ('time / s');
                    ylabel ('voltage / ï¿½V');
                    axis([-Vorlauf Laenge-Vorlauf -Scale-50 Scale]);
                    if isempty(SingleZoom) == 0
                        SetView(Single, SingleZoom);
                    end
                    
                    
                    %Find spike timestamp of next maximum
                    if size(MinMax,1) < Elektrode || size(MinMax,2) < Spike || ...
                            MinMax(Elektrode,Spike, 1, 1) == 0 && MinMax(Elektrode,Spike, 2, 1) == 0 && MinMax(Elektrode,Spike, 3, 1) == 0
                        
                        [MinMax(Elektrode,Spike,2,2),MinMax(Elektrode,Spike,2,1)] = min(SP); %Minimum
                        if MinMax(Elektrode,Spike,2,1)-SaRa*0.075 > 0
                            [MinMax(Elektrode,Spike,1,2),MinMax(Elektrode,Spike,1,1)] = max(SP(MinMax(Elektrode,Spike,2,1)-SaRa*0.075:MinMax(Elektrode,Spike,2,1)));
                            MinMax(Elektrode,Spike,1,1) = MinMax(Elektrode,Spike,1,1) + MinMax(Elektrode,Spike,2,1)-SaRa*0.075;
                        else
                            [MinMax(Elektrode,Spike,1,2),MinMax(Elektrode,Spike,1,1)] = max(SP(1:MinMax(Elektrode,Spike,2,1)));
                        end
                        if MinMax(Elektrode,Spike,2,1)+SaRa*0.15 <= size(SP,1)
                            [MinMax(Elektrode,Spike,3,2),MinMax(Elektrode,Spike,3,1)] = max(SP(MinMax(Elektrode,Spike,2,1):MinMax(Elektrode,Spike,2,1)+SaRa*0.15));
                        else
                            [MinMax(Elektrode,Spike,3,2),MinMax(Elektrode,Spike,3,1)] = max(SP(MinMax(Elektrode,Spike,2,1):end)); %2.Maximum
                        end
                        %last positive value before Minimum
                        if not(isempty(find(SP(1:MinMax(Elektrode,Spike,2,1))>0,1,'last'))) %if there is a positive value
                            MinMax(Elektrode,Spike,4,1) = find(SP(1:MinMax(Elektrode,Spike,2,1))>0,1,'last');
                            MinMax(Elektrode,Spike,4,2) = SP(MinMax(Elektrode,Spike,4,1));
                        else
                            MinMax(Elektrode,Spike,4,1:2) = 0;
                        end
                        
                        a = linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge);
                        MinMax(Elektrode,Spike,3,1) = a(MinMax(Elektrode,Spike,3,1)+MinMax(Elektrode,Spike,2,1)-1);
                        MinMax(Elektrode,Spike,1,1) = a(MinMax(Elektrode,Spike,1,1));
                        MinMax(Elektrode,Spike,2,1) = a(MinMax(Elektrode,Spike,2,1));
                        MinMax(Elektrode,Spike,4,1) = a(MinMax(Elektrode,Spike,4,1));
                        
                        clear a;
                    end
                    a = linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge);
                    n = find(a < MinMax(Elektrode,Spike,1,1),1,'last');
                    for i = n:-1:1
                        if SP(i) <= 0
                            break_point = i;
                            br = SP(i);
                            break;
                        end
                    end
                    
                    break_point = a(break_point);
                    
                    if get(MinMaxShow,'Value')
                        line ('Xdata',MinMax(Elektrode,Spike,1,1),'Ydata', MinMax(Elektrode,Spike,1,2),'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',MinMax(Elektrode,Spike,2,1),'Ydata', MinMax(Elektrode,Spike,2,2),'Tag','Single',...
                            'LineStyle','none','Marker','^',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',MinMax(Elektrode,Spike,3,1),'Ydata', MinMax(Elektrode,Spike,3,2),'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',break_point,'Ydata', br,'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                    end
                    
                    Show12345;  %Checks, if certain spiketimes should be marked
                    
                    subplot('Position',[0.1 0.81 0.87 0.14]);
                    SP = SPIKES(Spike,Elektrode);
                    y_axis = ones(length(SP),1).*(-Scale).*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','^',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
            
            set(Time1panel,'String',nonzeros(MinMax(Elektrode,Spike,1,2)));
            set(Time2panel,'String',nonzeros(MinMax(Elektrode,Spike,2,2)));
            set(Time3panel,'String',nonzeros(MinMax(Elektrode,Spike,3,2)));
            PPFiller;

        end
        
        
        %Redraw
        function DrawBoth (~,~)
            DrawOverlay;
            DrawSingleSpike;
        end
        
        function LockOverlay (~,~)
            set(LockViewOverlay,'Enable','on');
            if get(LockViewOverlay,'value') && ZeroOverlay == false
                OverlayZoom = get(get(Overlay,'Parent'));
            elseif ZeroOverlay == false
                OverlayZoom = [];
            end
        end
        function LockSingle (~,~)
            set(LockViewSingle,'Enable','on');
            if get(LockViewSingle,'value') && ZeroSingle == false
                SingleZoom = get(get(Single,'Parent'));
            elseif ZeroSingle == false
                SingleZoom = [];
            end
        end
        
        function SetView (Plot,ZoomMode)
            Plot = get(Plot,'Parent');
            set(Plot,'CameraPosition',ZoomMode.CameraPosition)
            set(Plot,'CameraPositionMode',ZoomMode.CameraPositionMode)
            set(Plot,'CameraTarget',ZoomMode.CameraTarget)
            set(Plot,'CameraTargetMode',ZoomMode.CameraTargetMode)
            set(Plot,'DataAspectRatio',ZoomMode.DataAspectRatio)
            set(Plot,'DataAspectRatioMode',ZoomMode.DataAspectRatioMode)
            set(Plot,'XLim',ZoomMode.XLim)
            set(Plot,'XLimMode',ZoomMode.XLimMode)
            set(Plot,'XTick',ZoomMode.XTick)
            set(Plot,'XTickMode',ZoomMode.XTickMode)
            set(Plot,'YLim',ZoomMode.YLim)
            set(Plot,'YTick',ZoomMode.YTick)
            set(Plot,'YTickMode',ZoomMode.YTickMode)
        end
        
        function AutoMinMax (~,~)
            
            if isempty(get(findobj(gcf,'Tag','Spikeauswahl'),'string'))
            else
                Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
                if SPIKESCUT(Spike) > 0
                else
                    MinMax(Elektrode,Spike,1:3,1) = 0;
                    DrawSingleSpike;
                end
            end
        end
        
        %Manuel setting of Minima and Maxima
        function Max1Det(~,~)
            [XValue,YValue,Spike] = Determination;
            if isempty(XValue) == 0
                MinMax(Elektrode,Spike,1,1) = XValue;
                MinMax(Elektrode,Spike,1,2) = YValue;
                DrawSingleSpike;
            end
        end
        function MinDet(~,~)
            [XValue,YValue,Spike] = Determination;
            if isempty(XValue) == 0
                MinMax(Elektrode,Spike,2,1) = XValue;
                MinMax(Elektrode,Spike,2,2) = YValue;
                DrawSingleSpike;
            end
        end
        function Max2Det(~,~)
            [XValue,YValue,Spike] = Determination;
            if isempty(XValue) == 0
                MinMax(Elektrode,Spike,3,1) = XValue;
                MinMax(Elektrode,Spike,3,2) = YValue;
                DrawSingleSpike;
            end
        end
        
        function [XValue,YValue,Spike] = Determination (~,~)
            XValue = [];
            YValue = [];
            Spike = [];
            
            if isempty(get(findobj(gcf,'Tag','Spikeauswahl'),'string'))
            else
                Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
                if SPIKESCUT(Spike) > 0
                else
                    dcm_obj = datacursormode(SpkOverlayPopup);
                    c_info = getCursorInfo(dcm_obj);
                    if isempty(c_info) == 0  && size(c_info,2) == 1
                        XValue = c_info(1).Position(1);
                        YValue = c_info(1).Position(2);
                    end
                end
            end
        end
        
        function Clear(~,~)
            delete(findall(SpkOverlayPopup,'Type','hggroup','HandleVisibility','off'));
            zoom off;
        end
        
        function Zoom(~,~)
            zoom;
        end
        
        function Select(~,~)
            dcm_obj = datacursormode(SpkOverlayPopup);
            set(dcm_obj,'DisplayStyle','datatip',...
                'SnapToDataVertex','on','Enable','on','UpdateFcn',@LineTag)
        end
        
        function SpikeDel(~,~)
            dcm_obj = datacursormode(SpkOverlayPopup);
            c_info = getCursorInfo(dcm_obj);
            if isempty(c_info) == 0
                for i=1:size(c_info,2)
                    Spike = get(c_info(i).Target,'Tag');
                    if isempty(Spike)== 0 && strcmp(Spike,'Red') == 0  && strcmp(Spike,'Grey') == 0
                        if strcmp(num2str(Spike),'Green') == 1
                            [Spike,~] = find(SPIKES(:,Elektrode)==c_info(i).Position(1));
                        else
                            Spike = str2double(Spike);
                        end
                        if SPIKESCOPY(Spike,Elektrode) ~= 0
                            SPIKESDEL(Spike,Elektrode) = SPIKESCOPY(Spike,Elektrode);
                            SPIKESCOPY(Spike, Elektrode) = 0;
                        end
                    end
                end
                %redraw
                DrawBoth;
                clear Spike;
            end
            datacursormode off;
        end
        
        function SpikeAdd(~,~)
            dcm_obj = datacursormode(SpkOverlayPopup);
            c_info = getCursorInfo(dcm_obj);
            if isempty(c_info) == 0
                for i=1:size(c_info,2)
                    Spike = get(c_info(i).Target,'Tag');
                    if isempty(Spike)== 0 && strcmp(Spike,'Green') == 0  && strcmp(Spike,'Grey') == 0
                        if strcmp(num2str(Spike),'Red') == 1
                            [Spike,~] = find(SPIKES(:,Elektrode)==c_info(i).Position(1));
                        else
                            Spike = str2double(Spike);
                        end
                        if SPIKESDEL(Spike,Elektrode) ~= 0
                            SPIKESDEL(Spike,Elektrode) = 0;
                            SPIKESCOPY(Spike, Elektrode) = SPIKES(Spike,Elektrode);
                        end
                    end
                end
                %redraw
                DrawBoth;
                clear Spike;
            end
            datacursormode off;
        end
        
        function Reset(~,~)
            SPIKESCOPY(:,Elektrode)= SPIKES (:,Elektrode);
            SPIKESDEL(:,Elektrode) = 0;
            DrawBoth;
            datacursormode off;
        end
        
        %Create tags e.g. spike#)
        function txt = LineTag (~,event_obj)
            dcm_obj = datacursormode(SpkOverlayPopup);
            c_info = getCursorInfo(dcm_obj);
            Spike = get(c_info(1).Target,'Tag');
            if isempty(Spike) || strncmp(Spike,'Points',6)
                pos = get(event_obj,'Position');
                txt = {['Time: ',sprintf('%.4f',pos(1))],...
                    ['Amplitude: ',num2str(pos(2))]};
            elseif strcmp(Spike,'Single')
                pos = get(event_obj,'Position');
                txt = {['Time: ',sprintf('%.4f',pos(1))],...
                    ['Amplitude: ',num2str(pos(2))]};
            elseif strcmp(Spike,'Green') == 1 || strcmp(Spike,'Red') || strcmp(Spike,'Grey') || strcmp(Spike,'Yellow')
                [Spike,~] = find(SPIKES(:,Elektrode)==c_info(1).Position(1));
                txt = {['Spike: ' num2str(Spike)]};
            else
                txt = {['Spike: ' Spike]};
            end
        end
        
        %Calculates number of detected spikes for the selected electrode
        function SpkCount (~,~)
            k = 1;
            SpkString='';
            Elektrode=get(findobj(gcf,'Tag','Elektrodenauswahl'),'value');
            while k<=size(SPIKES,1) && SPIKES(k,Elektrode)>0
                SpkString(k,:) = (['Spk ' num2str(k) blanks(  length(num2str(size(SPIKES,1))) - length(num2str(k))   )]);
                k = k+1;
            end
            set (Spikeauswahl,'String',SpkString);
            
            if OldSpike < k
                set (Spikeauswahl,'Value',OldSpike);
            elseif k>1
                set (Spikeauswahl,'Value',1);
                OldSpike = 1;
            end
            DrawBoth;
        end
        
        function Period1(~,~)
            Time = TimeMeasure(0);
            if isempty(Time) == 0
                set(Period1panel,'String',Time*1000)
                PPFiller;
            end
        end
        function Period2(~,~)
            Time = TimeMeasure(4);
            if isempty(Time) == 0
                set(Period2panel,'String',Time*1000)
                PPFiller;
            end
        end
        function Period3(~,~)
            Time = TimeMeasure(8);
            if isempty(Time) == 0
                set(Period3panel,'String',Time*1000)
                PPFiller;
            end
        end
        function Period4(~,~)
            Time = TimeMeasure(12);
            if isempty(Time) == 0
                set(Period4panel,'String',Time*1000)
                PPFiller;
            end
        end
        function Period5(~,~)
            Time = TimeMeasure(16);
            if isempty(Time) == 0
                set(Period5panel,'String',Time*1000)
                PPFiller;
            end
        end
        
        %saves two timestamps that are selected by the user in CharTime
        function TimePeriod = TimeMeasure (Nr,~)
            dcm_obj = datacursormode(SpkOverlayPopup);
            c_info = getCursorInfo(dcm_obj);
            if isempty(c_info) == 0  && ...
                    SPIKESCUT(get(findobj(gcf,'Tag','Spikeauswahl'),'value')) == 0
                if size(c_info,2) == 2
                    TimePeriod = abs(c_info(2).Position(1)-c_info(1).Position(1));
                    DifTime(Elektrode,OldSpike,Nr/4+1) = TimePeriod;
                    CharTime(Elektrode,OldSpike,1+Nr) = c_info(1).Position(1);
                    CharTime(Elektrode,OldSpike,2+Nr) = c_info(2).Position(1);
                    CharTime(Elektrode,OldSpike,3+Nr) = c_info(1).Position(2);
                    CharTime(Elektrode,OldSpike,4+Nr) = c_info(2).Position(2);
                    Show12345;
                else
                    TimePeriod = [];
                end
            else
                TimePeriod = [];
            end
            delete(findall(SpkOverlayPopup,'Type','hggroup','HandleVisibility','off'));
        end
        
        %functions to delete intervals
        function ClearPeriod1 (~,~)
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            ClearCurrentPeriod(0,Spike);
            set(Period1panel,'String','');
            DifTime(Elektrode,Spike,1)=abs(CharTime(Elektrode,Spike,2)-CharTime(Elektrode,Spike,1));
            PPFiller;
        end
        function ClearPeriod2 (~,~)
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            ClearCurrentPeriod(4,Spike);
            set(Period2panel,'String','');
            DifTime(Elektrode,Spike,2)=abs(CharTime(Elektrode,Spike,6)-CharTime(Elektrode,Spike,5));
            PPFiller;
        end
        function ClearPeriod3 (~,~)
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            ClearCurrentPeriod(8,Spike);
            set(Period3panel,'String','');
            DifTime(Elektrode,Spike,2)=abs(CharTime(Elektrode,Spike,10)-CharTime(Elektrode,Spike,9));
            PPFiller;
        end
        function ClearPeriod4 (~,~)
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            ClearCurrentPeriod(12,Spike);
            set(Period4panel,'String','');
            DifTime(Elektrode,Spike,2)=abs(CharTime(Elektrode,Spike,14)-CharTime(Elektrode,Spike,13));
            PPFiller;
        end
        function ClearPeriod5 (~,~)
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            ClearCurrentPeriod(16,Spike);
            set(Period5panel,'String','');
            DifTime(Elektrode,Spike,2)=abs(CharTime(Elektrode,Spike,18)-CharTime(Elektrode,Spike,17));
            PPFiller;
        end
        function ClearCurrentPeriod (Nr,CSpike)
            CharTime(Elektrode,CSpike,1+Nr:4+Nr) = 0;
            Show12345;
        end
        
        function Show1(~,~)
            DrawSpikePoints(0,get(Period1Show,'value'));
        end
        function Show2(~,~)
            DrawSpikePoints(4,get(Period2Show,'value'));
        end
        function Show3(~,~)
            DrawSpikePoints(8,get(Period3Show,'value'));
        end
        function Show4(~,~)
            DrawSpikePoints(12,get(Period4Show,'value'));
        end
        function Show5(~,~)
            DrawSpikePoints(16,get(Period5Show,'value'));
        end
        function Show12345(~,~)
            Show1;
            Show2;
            Show3;
            Show4;
            Show5;
        end
        
        function DrawSpikePoints (Nr,Check)
            %Show prior selected timestamps, if no times were selected when the period button is pressed
            
            delete(findobj(0,'Tag',['Points' Nr]));
            if Check
                
                if size(CharTime,1) >= Elektrode && size(CharTime,2) >= OldSpike && size(CharTime,3) >= 4+Nr &&...
                        max(CharTime(Elektrode,OldSpike,1+Nr),CharTime(Elektrode,OldSpike,2+Nr)) > 0 &&...
                        SPIKESCUT(get(findobj(gcf,'Tag','Spikeauswahl'),'value')) == 0
                    
                    subplot('Position',[0.1 0.115 0.34 0.24]);
                    for i=1:2
                        SP = CharTime(Elektrode,OldSpike,i+Nr);
                        y_axis = CharTime(Elektrode,OldSpike,i+2+Nr);
                        
                        %Draw arrows either top to down or buttom to top
                        if y_axis < 0
                            line ('Xdata',SP,'Ydata', y_axis,'Tag',['Points' Nr],...
                                'LineStyle','none','Marker','^',...
                                'MarkerFaceColor',[round(-Nr^4*7/6144+Nr^3*29/768-Nr^2*149/384+Nr*61/48),round(-Nr^4/6144+Nr^3/256-Nr^2*11/384+Nr/16+1),round(Nr^4/3072-Nr^3*5/384+Nr^2*29/192-Nr*5/12)],'MarkerSize',7);
                        else
                            line ('Xdata',SP,'Ydata', y_axis,'Tag',['Points' Nr],...
                                'LineStyle','none','Marker','v',...
                                'MarkerFaceColor',[round(-Nr^4*7/6144+Nr^3*29/768-Nr^2*149/384+Nr*61/48),round(-Nr^4/6144+Nr^3/256-Nr^2*11/384+Nr/16+1),round(Nr^4/3072-Nr^3*5/384+Nr^2*29/192-Nr*5/12)],'MarkerSize',7);
                        end
                    end
                end
            end
        end
        
        function MaxMinMaxPeriod (~,~)
            for EL=1:size(SPIKES,2)
                for Spike=1:size(nonzeros(SPIKES(:,EL)),1)
                    
                    if size(MinMax,1) < EL || size(MinMax,2) < Spike || ...
                            MinMax(EL,Spike, 1, 1) == 0 && MinMax(EL,Spike, 2, 1) == 0 && MinMax(EL,Spike, 3, 1) == 0
                        
                        if SPIKES(Spike,EL)*SaRa+1-(Vorlauf)*SaRa > 0 && ...
                                SPIKES(Spike,EL)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(RAW.M,1)
                            
                            SP = RAW.M(SPIKES(Spike,EL)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,EL)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,EL);
                            
                            [MinMax(EL,Spike,2,2),MinMax(EL,Spike,2,1)] = min(SP); %Minimum
                            %1. Maximum
                            if MinMax(EL,Spike,2,1)-SaRa*0.075 > 0
                                [MinMax(EL,Spike,1,2),MinMax(EL,Spike,1,1)] = max(SP(MinMax(EL,Spike,2,1)-SaRa*0.075:MinMax(EL,Spike,2,1)));
                                MinMax(EL,Spike,1,1) = MinMax(EL,Spike,1,1) + MinMax(EL,Spike,2,1)-SaRa*0.075;
                            else
                                [MinMax(EL,Spike,1,2),MinMax(EL,Spike,1,1)] = max(SP(1:MinMax(EL,Spike,2,1)));
                            end
                            %2. Maximum
                            if MinMax(EL,Spike,2,1)+SaRa*0.15 <= size(SP,1)
                                [MinMax(EL,Spike,3,2),MinMax(EL,Spike,3,1)] = max(SP(MinMax(EL,Spike,2,1):MinMax(EL,Spike,2,1)+SaRa*0.15)); %2.Maximum
                            else
                                [MinMax(EL,Spike,3,2),MinMax(EL,Spike,3,1)] = max(SP(MinMax(EL,Spike,2,1):end)); %2.Maximum
                            end
                            %last positive value before Minimum
                            if not(isempty(find(SP(1:MinMax(EL,Spike,2,1))>0,1,'last')))
                                MinMax(EL,Spike,4,1) = find(SP(1:MinMax(EL,Spike,2,1))>0,1,'last');
                                MinMax(EL,Spike,4,2) = SP(MinMax(EL,Spike,4,1));
                            else
                                MinMax(EL,Spike,4,1:2) = 0;
                            end
                            
                            a = linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge);
                            MinMax(EL,Spike,3,1) = a(MinMax(EL,Spike,3,1)+MinMax(EL,Spike,2,1)-1);
                            MinMax(EL,Spike,1,1) = a(MinMax(EL,Spike,1,1));
                            MinMax(EL,Spike,2,1) = a(MinMax(EL,Spike,2,1));
                            MinMax(EL,Spike,4,1) = a(MinMax(EL,Spike,4,1));
                            clear a;
                            
                            %Copies values from MinMax in CharTime and DifTime
                            %Period1a
                            CharTime(EL,Spike,1) = MinMax(EL,Spike,1,1);
                            CharTime(EL,Spike,3) = MinMax(EL,Spike,1,2);
                            CharTime(EL,Spike,2) = MinMax(EL,Spike,2,1);
                            CharTime(EL,Spike,4) = MinMax(EL,Spike,2,2);
                            DifTime(EL,Spike,1) = abs(CharTime(EL,Spike,2)-CharTime(EL,Spike,1));
                            
                            %Period1b
                            CharTime(EL,Spike,5) = MinMax(EL,Spike,4,1);
                            CharTime(EL,Spike,7) = MinMax(EL,Spike,4,2);
                            CharTime(EL,Spike,6) = MinMax(EL,Spike,2,1);
                            CharTime(EL,Spike,8) = MinMax(EL,Spike,2,2);
                            DifTime(EL,Spike,2) = abs(CharTime(EL,Spike,6)-CharTime(EL,Spike,5));
                            
                            %Period2
                            CharTime(EL,Spike,9) = MinMax(EL,Spike,2,1);
                            CharTime(EL,Spike,11) = MinMax(EL,Spike,2,2);
                            CharTime(EL,Spike,10) = MinMax(EL,Spike,3,1);
                            CharTime(EL,Spike,12) = MinMax(EL,Spike,3,2);
                            DifTime(EL,Spike,3) = abs(CharTime(EL,Spike,10)-CharTime(EL,Spike,9));
                        end
                    else
                        %Copies values from MinMax in CharTime and DifTime
                        %Period1a
                        CharTime(EL,Spike,1) = MinMax(EL,Spike,1,1);
                        CharTime(EL,Spike,3) = MinMax(EL,Spike,1,2);
                        CharTime(EL,Spike,2) = MinMax(EL,Spike,2,1);
                        CharTime(EL,Spike,4) = MinMax(EL,Spike,2,2);
                        DifTime(EL,Spike,1) = abs(CharTime(EL,Spike,2)-CharTime(EL,Spike,1));
                        
                        %Period1b
                        CharTime(EL,Spike,5) = MinMax(EL,Spike,4,1);
                        CharTime(EL,Spike,7) = MinMax(EL,Spike,4,2);
                        CharTime(EL,Spike,6) = MinMax(EL,Spike,2,1);
                        CharTime(EL,Spike,8) = MinMax(EL,Spike,2,2);
                        DifTime(EL,Spike,2) = abs(CharTime(EL,Spike,6)-CharTime(EL,Spike,5));
                        
                        %Period2
                        CharTime(EL,Spike,9) = MinMax(EL,Spike,2,1);
                        CharTime(EL,Spike,11) = MinMax(EL,Spike,2,2);
                        CharTime(EL,Spike,10) = MinMax(EL,Spike,3,1);
                        CharTime(EL,Spike,12) = MinMax(EL,Spike,3,2);
                        DifTime(EL,Spike,3) = abs(CharTime(EL,Spike,10)-CharTime(EL,Spike,9));
                    end
                end
            end
            
            Elektrode=get(findobj(gcf,'Tag','Elektrodenauswahl'),'value');    %selected electrode
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');   %selected spike
            
            set(Period1panel,'String',DifTime(Elektrode,Spike,1)*1000);
            set(Period2panel,'String',DifTime(Elektrode,Spike,2)*1000);
            set(Period3panel,'String',DifTime(Elektrode,Spike,3)*1000);
            
            PPFiller;
        end
        
        function ExportOverlay (~,~)
            temp = [];
            SPIKESCUT = zeros(size(SPIKES,1),1);
            for k=1:size(SPIKESCOPY,1)
                if SPIKES(k,Elektrode)*SaRa+1-(Vorlauf)*SaRa > 0 && ...
                        SPIKES(k,Elektrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(RAW.M,1)
                    if SPIKESCOPY(k,Elektrode) > 0
                        temp(:,k) = RAW.M(SPIKESCOPY(k,Elektrode)*SaRa+1-(Vorlauf)*SaRa:SPIKESCOPY(k,Elektrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Elektrode);
                    else
                        temp(1:SaRa*Laenge,k) = 0;
                    end
                else
                    if SPIKESCOPY(k,Elektrode) ~= 0
                        SPIKESCUT(k) = SPIKESCOPY(k,Elektrode);
                    else
                        SPIKESCUT(k) = SPIKESDEL(k,Elektrode);
                    end
                end
            end
            clear k;
            
            uisave('temp',[daMaxValr(date,29), '_EL', num2str(EL_NUMS(get(findobj(gcf,'Tag','Elektrodenauswahl'),'value'))), '_']);
            
        end
        
        function FindPoints(~,~)
            for EL=1:size(SPIKES,2)
                for Spike=1:size(nonzeros(SPIKES(:,EL)),1)
                    
                    if SPIKES(Spike,EL)*SaRa+1-(Vorlauf)*SaRa > 0 && ...
                            SPIKES(Spike,EL)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(RAW.M,1)
                        
                        SP = RAW.M(SPIKES(Spike,EL)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,EL)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,EL);
                        
                        [MinMax(EL,Spike,2,2),MinMax(EL,Spike,2,1)] = min(SP); %Minimum
                        %1. Maximum
                        if MinMax(EL,Spike,2,1)-SaRa*0.075 > 0
                            [MinMax(EL,Spike,1,2),MinMax(EL,Spike,1,1)] = max(SP(MinMax(EL,Spike,2,1)-SaRa*0.075:MinMax(EL,Spike,2,1))); %1.Maximum
                            MinMax(EL,Spike,1,1) = MinMax(EL,Spike,1,1) + MinMax(EL,Spike,2,1)-SaRa*0.075;
                        else
                            [MinMax(EL,Spike,1,2),MinMax(EL,Spike,1,1)] = max(SP(1:MinMax(EL,Spike,2,1))); %1.Maximum
                        end
                        %2. Maximum
                        if MinMax(EL,Spike,2,1)+SaRa*0.15 <= size(SP,1)
                            [MinMax(EL,Spike,3,2),MinMax(EL,Spike,3,1)] = max(SP(MinMax(EL,Spike,2,1):end));%MinMax(EL,Spike,2,1)+SaRa*0.15)); %2.Maximum
                        else
                            [MinMax(EL,Spike,3,2),MinMax(EL,Spike,3,1)] = max(SP(MinMax(EL,Spike,2,1):end)); %2.Maximum
                        end
                        
                        %                         if not(isempty(find(SP(1:MinMax(EL,Spike,2,1))>0,1,'last')))
                        %                             MinMax(EL,Spike,4,1) = find(SP(1:MinMax(EL,Spike,2,1))>0,1,'last');
                        %                             MinMax(EL,Spike,4,2) = SP(MinMax(EL,Spike,4,1));
                        %                         else
                        %                             MinMax(EL,Spike,4,1:2) = 0;
                        %                         end;
                        a = linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge);
                        MinMax(EL,Spike,3,1) = a(MinMax(EL,Spike,3,1)+MinMax(EL,Spike,2,1)-1);
                        MinMax(EL,Spike,1,1) = a(MinMax(EL,Spike,1,1));
                        MinMax(EL,Spike,2,1) = a(MinMax(EL,Spike,2,1));
                        %   MinMax(EL,Spike,4,1) = a(MinMax(EL,Spike,4,1));
                        clear a;
                    else
                        MinMax(EL,Spike,:,:) = 0;
                        
                    end
                end
            end
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            set(Time1panel,'String',nonzeros(MinMax(Elektrode,Spike,1,2)));
            set(Time2panel,'String',nonzeros(MinMax(Elektrode,Spike,2,2)));
            set(Time3panel,'String',nonzeros(MinMax(Elektrode,Spike,3,2)));
        end
        
        function PPFiller(~,~) %Points and Periods Filler (Funktion adds values like extrmes or timeintervals
            if get(findobj(gcf,'Tag','AllELs'),'value')
                set(Time1Mid,'String',sprintf('%.2f',mean(nonzeros(MinMax(:,:,1,2))))); %mean
                set(Time1Std,'String',std(nonzeros(MinMax(:,:,1,2)))); %std
                set(Time1Median,'string',median(nonzeros(MinMax(:,:,1,2)))); % Median
                set(Time2Mid,'String',sprintf('%.2f',mean(nonzeros(MinMax(:,:,2,2))))); %meants
                set(Time2Std,'String',std(nonzeros(MinMax(:,:,2,2)))); %std
                set(Time2Median,'string',median(nonzeros(MinMax(:,:,2,2)))); %median
                set(Time3Mid,'String',sprintf('%.2f',mean(nonzeros(MinMax(:,:,3,2))))); %mean
                set(Time3Std,'String',std(nonzeros(MinMax(:,:,3,2)))); %std
                set(Time3Median,'string',median(nonzeros(MinMax(:,:,3,2)))); %median...
                set(Period1Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,1)))));
                set(Period1Std,'String',std(nonzeros(DifTime(:,:,1)))*1000);
                set(Period1Median,'string',median(nonzeros(DifTime(:,:,1)))*1000);
                set(Period2Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,2)))));
                set(Period2Std,'String',std(nonzeros(DifTime(:,:,2)))*1000);
                set(Period2Median,'string',median(nonzeros(DifTime(:,:,2)))*1000);
                set(Period3Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,3)))));
                set(Period3Std,'String',std(nonzeros(DifTime(:,:,3)))*1000);
                set(Period3Median,'string',median(nonzeros(DifTime(:,:,3)))*1000);
                set(Period4Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,4)))));
                set(Period4Std,'String',std(nonzeros(DifTime(:,:,4)))*1000);
                set(Period4Median,'string',median(nonzeros(DifTime(:,:,4)))*1000);
                set(Period5Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,5)))));
                set(Period5Std,'String',std(nonzeros(DifTime(:,:,5)))*1000);
                set(Period5Median,'string',median(nonzeros(DifTime(:,:,5)))*1000);
            else
                EL = get(findobj(gcf,'Tag','Elektrodenauswahl'),'value');    %selected electrode
                
                set(Time1Mid,'String',sprintf('%.2f',mean(nonzeros(MinMax(EL,:,1,2)))));
                set(Time1Std,'String',std(nonzeros(MinMax(EL,:,1,2))));
                set(Time1Median,'string',median(nonzeros(MinMax(EL,:,1,2))));
                set(Time2Mid,'String',sprintf('%.2f',mean(nonzeros(MinMax(EL,:,2,2)))));
                set(Time2Std,'String',std(nonzeros(MinMax(EL,:,2,2))));
                set(Time2Median,'string',median(nonzeros(MinMax(EL,:,2,2))));
                set(Time3Mid,'String',sprintf('%.2f',mean(nonzeros(MinMax(EL,:,3,2)))));
                set(Time3Std,'String',std(nonzeros(MinMax(EL,:,3,2))));
                set(Time3Median,'string',median(nonzeros(MinMax(EL,:,3,2))));
                set(Period1Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(EL,:,1)))));
                set(Period1Std,'String',std(nonzeros(DifTime(EL,:,1)))*1000);
                set(Period1Median,'string',median(nonzeros(DifTime(EL,:,1)))*1000);
                set(Period2Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(EL,:,2)))));
                set(Period2Std,'String',std(nonzeros(DifTime(EL,:,2)))*1000);
                set(Period2Median,'string',median(nonzeros(DifTime(EL,:,2)))*1000);
                set(Period3Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(EL,:,3)))));
                set(Period3Std,'String',std(nonzeros(DifTime(EL,:,3)))*1000);
                set(Period3Median,'string',median(nonzeros(DifTime(EL,:,3)))*1000);
                set(Period4Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(EL,:,4)))));
                set(Period4Std,'String',std(nonzeros(DifTime(EL,:,4)))*1000);
                set(Period4Median,'string',median(nonzeros(DifTime(EL,:,4)))*1000);
                set(Period5Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(EL,:,5)))));
                set(Period5Std,'String',std(nonzeros(DifTime(EL,:,5)))*1000);
                set(Period5Median,'string',median(nonzeros(DifTime(EL,:,5)))*1000);
            end
        end
    end

% --- Aktualisieren Button lï¿½sst individuelle Ansichten zu (AD)--------
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
            
            
            if temp>0
                line([str2double(ST_START);str2double(ST_START)],[-100;100],...
                    'LineStyle',':','Linewidth',1,'color','blue','Marker','none');
                line([str2double(ST_ENDE);str2double(ST_ENDE)],[-100;100],...
                    'LineStyle',':','Linewidth',1,'color','blue','Marker','none');
                
                if SPIKES(1,temp)>0
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
    function AnalyseNetworkburst(source,event) %#ok
        h_bar2=waitbar(0.05,'Please wait - networkbursts are analysed...');
        numberfiles = 1;
        if SI_EVENTS ~= 0
            ORDER = cell(size(BURSTS,2),size(SI_EVENTS,2));
            BURSTTIME = zeros(size(BURSTS,2),size(SI_EVENTS,2));
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
                    [row,col] = find((BURSTS<(eventtime+xy+tol))&(BURSTS>(eventtime+xy-tol)));
                    if isempty(col)
                    else
                        while zz<=length(col)
                            ORDER(yz,n) = EL_NAMES(col(zz));
                            BURSTTIME(yz,n) = BURSTS(row(zz),col(zz));
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
                        if countlimit(k)<= 0
                            countlimit(k) = 1;
                        end
                        break
                    end
                end
                waitbar(0.55)
                for p=1:int32(SI_EVENTS(k)*SaRa-countlimit(k))
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
        
        units = [{'Voltage / ï¿½V'};{'Voltage / ï¿½V'};{'Scalar'};{'Energy / V ^2 / s'};{'Energy / V ^2 / s'};{'Time / ms'};{'Scalar'};{'Scalar'};
            {'Scalar'};{'Scalar'};{'Gradient ï¿½V / s'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};
            {'Voltage / ï¿½V'};{'Time / ms'};{'Scalar'};{'Scalar'};];
        
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
            [~,Score]=princomp(XX);
            
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
                                TMP=(1/SaRa)*((trapz(S(i,n,1:MU(i,n,j))))+(0.5*(-S(i,n,MU(i,n,j))/(S(i,n,MU(i,n,j)+1)-S(i,n,MU(i,n,j))))*S(i,n,MU(i,n,j)))); % die Zwischenflï¿½che beim Vorzeichenwechsel!
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
            ylabel({'Voltage / ï¿½V'});
            
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
            ylabel({'Voltage / ï¿½V'});
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
            ylabel({'Voltage / ï¿½V'});
            
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
            k=str2double(k);
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
        
        units = [{'Voltage / ï¿½V'};{'Voltage / ï¿½V'};{'Scalar'};{'Energy / V ^2 / s'};{'Energy / V ^2 / s'};{'Time / ms'};{'Scalar'};{'Scalar'};
            {'Scalar'};{'Scalar'};{'Gradient ï¿½V / s'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};
            {'Voltage / ï¿½V'};{'Time / ms'};{'Scalar'};{'Scalar'};];
        
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
                ylabel({'Voltage / ï¿½V'});
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / ï¿½V'});
                
            elseif size(XX2,1)== 0
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX1);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / ï¿½V'});
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / ï¿½V'});
                
                
            elseif Spike_Cluster == 1
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX1);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / ï¿½V'});
                
                subplot('Position',[0.55 0.09 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX2);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                xlabel ('time / ms');
                ylabel({'Voltage / ï¿½V'});
                
                uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [290 75 130 20],'HorizontalAlignment','left','String','Refined Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','b','BackgroundColor', GUI_Color_BG);
                uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [395 75 50 20],'HorizontalAlignment','left','String',size(XX1,1),'FontSize',10,'FontWeight','bold','ForegroundColor','b','BackgroundColor', GUI_Color_BG);
                
                
                XX1=[];
                XX2=[];
                
            elseif Spike_Cluster == 0
                
                Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX2);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                ylabel({'Voltage / ï¿½V'});
                
                subplot('Position',[0.55 0.09 0.44 0.28],'parent',DetektionRefinementWindow);
                Spikeplot = plot(ST,XX1);
                axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
                xlabel ('time / ms');
                ylabel({'Voltage / ï¿½V'});
                
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
        
        if isempty(get(findobj('Tag','discard'),'value')) == 1 % MaxVal if checkbox discard exists for first Spike Sorting cycle
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
                
                % Berechnung des ï¿½ffnungswinkels (Andy)/(Robert)
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
        [~,Score]=princomp(XX);
        
        if isempty(get(findobj('Tag','discard'),'value')) == 1 % MaxVal if checkbox discard exists for first Spike Sorting cycle
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
        
        POS=0;  % MaxVal if ZPOS or ZNEG has been used already
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
                        TMP=(1/SaRa)*((trapz(S(i,n,1:MU(i,n,j))))+(0.5*(-S(i,n,MU(i,n,j))/(S(i,n,MU(i,n,j)+1)-S(i,n,MU(i,n,j))))*S(i,n,MU(i,n,j)))); % die Zwischenflï¿½che beim Vorzeichenwechsel!
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
        
        if isempty(get(findobj('Tag','discard'),'value')) == 1 % MaxVal if checkbox discard exists for first Spike Sorting cycle
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
            if isempty(get(findobj('Tag','SortingPanel'),'value')) == 1 % MaxVal if checkbox discard exists for first Spike Sorting cycle
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
            
            [~,Score,latent] = princomp(XX);
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
        
        if isempty(get(findobj('Tag','discard'),'value')) == 1 % MaxVal if checkbox discard exists for first Spike Sorting cycle
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
        
        BURSTS(:,n) = zeros;
        NR_BURSTS(n) = 0;
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
                        if varTdata==0;                                                     % MaxVal if variable thresholdis selected
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
                        if varTdata==0;                                                     % MaxVal if variable thresholdis selected
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
            if varTdata==0;                                                     % MaxVal if variable thresholdis selected
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

%     function [W,RAW.M,V,L] = EM_GM_Dr_cell(XX_N,k,ltol,maxiter,pflag,Mean1)
function  EM_GM_Dr_cell(XX_N,k,ltol,maxiter,pflag,Mean1)
        % [W,RAW.M,V,L] = EM_GM(X,k,ltol,maxiter,pflag,Init)
        
        if nargin <= 1
            return
        elseif nargin == 2
            ltol = 1e-12; maxiter = 1000; pflag = 0; Init = [];
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            if err_X || err_k, return; end
        elseif nargin == 3
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
        elseif nargin == 5,
            Init = [];
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            [ltol,err_ltol] = Verify_ltol(ltol);
            [maxiter,err_maxiter] = Verify_maxiter(maxiter);
            [pflag,err_pflag] = Verify_pflag(pflag);
            if err_X || err_k || err_ltol || err_maxiter || err_pflag, return; end
        elseif nargin == 6,
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
        
        %%%% Initialize W, RAW.M, V,L %%%%
        t = cputime;
        
        if isempty(Init)
            Mean1 = Mean1;
            [W,RAW.M,V] = Init_EM(XX_N,k,Mean1);
            L = 0;
        else
            W = Init.W;
            RAW.M = Init.RAW.M;
            V = Init.V;
            Mean1 = Mean1;
        end
        Ln = Likelihood(XX_N,k,W,RAW.M,V); % Initialize log likelihood
        Lo = 2*Ln;
        
        %%%% EM algorithm %%%%
        niter = 0;
        
        while (abs(100*(Ln-Lo)/Lo)>ltol) && (niter<=maxiter)
            E = Expectation(XX_N,k,W,RAW.M,V); % E-step
            [W,RAW.M,V] = Maximization(XX_N,k,E);  % RAW.M-step
            Lo = Ln;
            Ln = Likelihood(XX_N,k,W,RAW.M,V);
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
                dXM = XX_N(i,:)'-RAW.M(:,j);
                pl = exp(-0.5*dXM'*iV(:,:,j)*dXM)/(a*S(j));
                E(i,j) = W(j)*pl;
            end
            E(i,:) = E(i,:)/sum(E(i,:));
        end
    end

%%%% End of Expectation %%%%

    %function [W,M,V] = Maximization(XX_N,k,E)
    function  Maximization(XX_N,k,E)
        [n,d] = size(XX_N);
        W = zeros(1,k); RAW.M = zeros(d,k);
        V = zeros(d,d,k);
        for i=1:k  % Compute weights
            for j=1:n
                W(i) = W(i) + E(j,i);
                RAW.M(:,i) = RAW.M(:,i) + E(j,i)*XX_N(j,:)';
            end
            RAW.M(:,i) = RAW.M(:,i)/W(i);
        end
        for i=1:k
            for j=1:n
                dXM = XX_N(j,:)'-RAW.M(:,i);
                V(:,:,i) = V(:,:,i) + E(j,i)*dXM*dXM';
            end
            V(:,:,i) = V(:,:,i)/W(i);
        end
        W = W/n;
    end
%%%% End of Maximization %%%%

    %function L = Likelihood(XX_N,k,W,RAW.M,V)
    function Likelihood(XX_N,k,W,M,V)
        
        % Compute L based on K. V. Mardia, "Multivariate Analysis", Academic Press, 1979, PP. 96-97
        % to enchance computational speed
        [n,d] = size(XX_N);
        U = mean(XX_N)';
        S = cov(XX_N);
        L = 0;
        for i=1:k
            iV = inv(V(:,:,i));
            L = L + W(i)*(-0.5*n*log(det(2*pi*V(:,:,i))) ...
                -0.5*(n-1)*(trace(iV*S)+(U-RAW.M(:,i))'*iV*(U-RAW.M(:,i))));
        end
    end

%%%% End of Likelihood %%%%


    function err_X = Verify_X(XX_N)
        err_X = 1;
        [n,d] = size(XX_N);
        if n<d
            return
        end
        err_X = 0;
    end

%%%% End of Verify_X %%%%


    function err_k = Verify_k(k)
        err_k = 1;
        if ~isnumeric(k) || ~isreal(k) || k<1
            return
        end
        err_k = 0;
    end

%%%% End of Verify_k %%%%

    function [ltol,err_ltol] = Verify_ltol(ltol)
        err_ltol = 1;
        if isempty(ltol)
            ltol = 0.1;
        elseif ~isreal(ltol) || ltol<=0
            return
        end
        err_ltol = 0;
    end

%%%% End of Verify_ltol %%%%

    function [maxiter,err_maxiter] = Verify_maxiter(maxiter)
        err_maxiter = 1;
        if isempty(maxiter)
            maxiter = 1000;
        elseif ~isreal(maxiter) || maxiter<=0
            return
        end
        err_maxiter = 0;
    end

%%%% End of Verify_maxiter %%%%

    function [pflag,err_pflag] = Verify_pflag(pflag)
        err_pflag = 1;
        if isempty(pflag)
            pflag = 0;
        elseif pflag~=0 & pflag~=1
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
            [Md,Mk] = size(Init.RAW.M);
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

   % function [W,RAW.M,V] = Init_EM(XX_N,k,Mean1)
    function  Init_EM(XX_N,k,Mean1)
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
            
            while sum(isnan(C))>0
                [Ci,C] = kmeans(XX_N,k,'Start',Mean1', ...
                    'Maxiter',100, ...
                    'EmptyAction','drop', ...
                    'Display','off');
            end
        end
        RAW.M = C';
        Vp = repmat(struct('count',0,'X',zeros(n,d)),1,k);
        for i=1:n % Separate cluster points
            Vp(Ci(i)).count = Vp(Ci(i)).count + 1;
            Vp(Ci(i)).XX_N(Vp(Ci(i)).count,:) = XX_N(i,:);
        end
        V = zeros(d,d,k);
        for i=1:k
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
        
        units = [{'Voltage / ï¿½V'};{'Voltage / ï¿½V'};{'Scalar'};{'Energy / V ^2 / s'};{'Energy / V ^2 / s'};{'Time / ms'};{'Scalar'};{'Scalar'};
            {'Scalar'};{'Scalar'};{'Gradient ï¿½V / s'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};
            {'Voltage / ï¿½V'};{'Time / ms'};{'Scalar'};{'Scalar'};];
        
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
            ylabel({'Voltage / ï¿½V'});
            Spkplot1 = 1; % storage of displayed Cluster Number
            
            
            Spikeplot2 = subplot('Position',[0.55 0.09 0.44 0.28],'Parent',SpikeSortingWindow,'replace');
            
            Spikeplot2 = plot(ST,XX2,'Parent',Spikeplot2);
            axis(gca,[ST(1) ST(size(ST,2)) Min(1) Max(1)]);
            xlabel (gca,'time / ms');
            ylabel(gca,{'Voltage / ï¿½V'});
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
            ylabel({'Voltage / ï¿½V'});
            
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
            NR_BURSTS_Sorted(1,1:size(SPIKES,2)) = NR_BURSTS;
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
                if ((SPI1(i)+1+floor(SaRa*posttime/1000))<= size(RAW.M,1))&& ((SPI1(i)+1-ceil(SaRa*pretime/1000)) >= 0) % MaxVal if
                    RAW.M(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n) = M_old(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),1); % Shapes variabler Lï¿½nge
                end
            end
            
            BURSTS(:,n) = zeros;
            NR_BURSTS(n) = 0;
            
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


% -------------------- Burst and SBE Analysis after Spike Refinement (RB)--

    function Re_Burst(~,~)
        
        h_wait_Burst = waitbar(.05,'Please wait - Burst detection in progress...');
        SIB = zeros(1,nr_channel);
        BURSTS = zeros(1,size(SPIKES,2));                                   % initiate empty vectors
        SPIKES_IN_BURSTS = zeros(1,size(SPIKES,2));
        BURSTDUR = zeros(1,size(SPIKES,2));
        IBIstd = zeros(1,size(SPIKES,2));
        IBImean = zeros(1,size(SPIKES,2));
        NR_BURSTS = zeros(1,size(SPIKES,2));
        meanburstduration = zeros(1,size(SPIKES,2));
        STDburst = zeros(1,size(SPIKES,2));
        
        CohenKappa;
        waitbar(.35,h_wait_Burst,'Please wait - Burst detection in progress...')
        
        if cellselect ~= 0  %only for neurons
            Burstdetection;
        end
        
        waitbar(.65,h_wait_Burst,'Please wait - SBE analysis in progress...')
        if nr_channel>1
            SBEdetection;
        end
        waitbar(.95,h_wait_Burst,'Please wait - SBE analysis in progress...')
                
%         if Viewselect == 0
%             redraw;
%         elseif Viewselect == 1
%             redraw_allinone;
%         end
        redrawdecide
        waitbar(1,h_wait_Burst,'Done.'), close(h_wait_Burst);
        set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Value',0,'Enable','on');
    end


%functions - Tab Export
%----------------------------------------------------------------------

% --- Export xls-Button (CN)-------------------------------------------
    function safexlsButtonCallback(source,event)  %#ok<INUSD>
        
        
        
        title = [full_path(1:(length(full_path)-4)),'.xls'];  % Name and path for the xls-Export-file

        %Export        
        [filename, pathname] = uiputfile ('*.xls','save as...',title);
        if filename==0, return,end
        
        h = waitbar(0,'please wait, save data...');
        waitbar(0.2)
        xlswrite([pathname filename], {full_path}, 'Tabelle1','A2');
        xlswrite([pathname filename], fileinfo{1}, 'Tabelle1','A3');
        
        % CALCULATIONS
        
        %find number of active electrodes
        AktEl = 0;
        for j=1:size(SPIKES,2)
            if isempty(nonzeros(SPIKES(:,j))) == 0
                AktEl = AktEl + 1;
            end
        end
        ACTIVE_EL = AktEl;
        
        waitbar(0.4);
        
        % measure synchrony
        %[matrix,R] = Phase_Sync(SPIKES,rec_dur,SaRa); % Phase_Sync(TS,rec_dur,SaRa)
        %synchrony_phaseSync = R;
        synchrony_spikeContrast = SpikeContrast(SPIKES,rec_dur);
        
        waitbar(0.8);
        COLUMN_A = cell(29,1);
        COLUMN_A(1) = {'Duration of recording [s]'};
        COLUMN_A(2) = {'Active El.'};
        COLUMN_A(3) = {'BeatRateMeanAllEl'};
        COLUMN_A(4) = {'BeatRateStdAllEl'};
        COLUMN_A(5) = {'BeatRateMedianAllEl'};
        COLUMN_A(6) = {'ISIMeanAllEl'};
        COLUMN_A(7) = {'ISIStdAllEl'};
        COLUMN_A(8) = {'ISIMedianAllEl'};
        COLUMN_A(9) = {'MaxValMeanAllEl'};
        COLUMN_A(10) = {'MaxValStdAllEl'};
        COLUMN_A(11) = {'MaxValMedianAllEl'};
        COLUMN_A(12) = {'MaxValNAllEl'};
        COLUMN_A(13) = {'MinValMeanAllEl'};
        COLUMN_A(14) = {'MinValStdAllEl'};
        COLUMN_A(15) = {'MinValMedianAllEl'};
        COLUMN_A(16) = {'MinValNAllEl'};
        COLUMN_A(17) = {'MeanDistance'};
        COLUMN_A(18) = {'MeanTime'};
        COLUMN_A(19) = {'MeanVelocity'};
        COLUMN_A(20) = {'StdDistance'};
        COLUMN_A(21) = {'StdTime'};
        COLUMN_A(22) = {'StdVelocity'};
        COLUMN_A(23) = {'MedianDistance'};
        COLUMN_A(24) = {'MedianTime'};
        COLUMN_A(25) = {'MedianVelocity'};
        COLUMN_A(26) = {''};
        COLUMN_A(27) = {'Synchrony (Spike-Contrast)'};

                
        
        waitbar(0.9);
        
        COLUMN_B = cell(29,1);
        COLUMN_B(1) = {rec_dur};
        COLUMN_B(2) = {ACTIVE_EL};
        COLUMN_B(3) = {str2num(BeatRateMeanAllEl.String)};
        COLUMN_B(4) = {str2num(BeatRateStdAllEl.String)};
        COLUMN_B(5) = {str2num(BeatRateMedianAllEl.String)};
        COLUMN_B(6) = {str2num(ISIMeanAllEl.String)};
        COLUMN_B(7) = {str2num(ISIStdAllEl.String)};
        COLUMN_B(8) = {str2num(ISIMedianAllEl.String)};
        COLUMN_B(9) = {str2num(MaxValMeanAllEl.String)};
        COLUMN_B(10) = {str2num(MaxValStdAllEl.String)};
        COLUMN_B(11) = {str2num(MaxValMedianAllEl.String)};
        COLUMN_B(12) = {MaxValNAllEl};
        COLUMN_B(13) = {str2num(MinValMeanAllEl.String)};
        COLUMN_B(14) = {str2num(MinValStdAllEl.String)};
        COLUMN_B(15) = {str2num(MinValMedianAllEl.String)};
        COLUMN_B(16) = {MinValNAllEl};
        COLUMN_B(17) = {str2num(MeanDistance.String)};
        COLUMN_B(18) = {str2num(MeanTime.String)};
        COLUMN_B(19) = {str2num(MeanVelocity.String)};
        COLUMN_B(20) = {str2num(StdDistance.String)};
        COLUMN_B(21) = {str2num(StdTime.String)};
        COLUMN_B(22) = {str2num(StdVelocity.String)};
        COLUMN_B(23) = {str2num(MedianDistance.String)};
        COLUMN_B(24) = {str2num(MedianTime.String)};
        COLUMN_B(25) = {str2num(MedianVelocity.String)};
        COLUMN_B(26) = {[]};
        COLUMN_B(27) = {synchrony_spikeContrast};
        
        xlswrite([pathname filename], COLUMN_A, 'Tabelle1','A6');
        xlswrite([pathname filename], COLUMN_B, 'Tabelle1','D6');


        waitbar(1);
        close(h);
        
        if (get(findobj(gcf,'Tag','CELL_showExportCheckbox'),'value'))
            winopen([pathname filename]);
        end
    end

% --- Export of Networkburst analysis (CN)-----------------------------
    function ExportNWBCallback(source,event) %#ok
        [filename, pathname] = uiputfile('*.xls','Save as...', 'Results');
        if filename==0, return,end
        
        row_1 = cell(1,numberfiles);
        
        if numberfiles == 1
            row_1(1) = {file};
        else
            for r=1:numberfiles
                row_1(r) = {file{r}};
            end
        end
        h_wait=waitbar(0.05,'exporting data...');
        waitbar(0.15)
        
        line_1 = cell(1,7);
        line_1(1) = {'Messung'};
        line_1(2) = {'Mittelwert steigende Flanke'};
        line_1(3) = {'STD steigende Flanke'};
        line_1(4) = {'Mittelwert fallende Flanke'};
        line_1(5) = {'STD fallende Flanke'};
        line_1(6) = {'Mittelwert Dauer'};
        line_1(7) = {'STD Dauer'};
        waitbar(0.25)
        if numberfiles ==1
            NWBdata = cat(1,row_1',Meanrise',stdMeanRise',Meanfall',stdMeanFall',MeanDuration',stdMeanDuration');
            xlswrite([pathname filename], line_1, 'Tabelle1','A1');
            xlswrite([pathname filename], NWBdata', 'Tabelle1','A2');
        else
            xlswrite([pathname filename], line_1, 'Tabelle1','A1');
            xlswrite([pathname filename], row_1', 'Tabelle1','A2');
            xlswrite([pathname filename], Meanrise', 'Tabelle1','B2');
            xlswrite([pathname filename], stdMeanRise', 'Tabelle1','C2');
            waitbar(0.35)
            xlswrite([pathname filename], Meanfall', 'Tabelle1','D2');
            xlswrite([pathname filename], stdMeanFall', 'Tabelle1','E2');
            xlswrite([pathname filename], MeanDuration', 'Tabelle1','F2');
            xlswrite([pathname filename], stdMeanDuration', 'Tabelle1','G2');
        end
        
        waitbar(0.5)
        waitbaradd = 0.5;
        
        counter = 1;
        
        if iscell(ORDER) == 1
            if isempty(ORDER{1}) ~= 0
            else
                for n=1:size(ORDER,2)
                    El = strcat('A',(num2str(counter)));
                    Time = strcat('A',(num2str(counter+1)));
                    xlswrite([pathname filename], ORDER(:,n)', 'Tabelle2',El);
                    xlswrite([pathname filename], BURSTTIME(:,n)', 'Tabelle2',Time);
                    counter=counter+3;
                    waitbaradd = waitbaradd + (0.45/size(ORDER,2));
                    waitbar(waitbaradd)
                end
            end
        end
        
        waitbar(1,h_wait,'Complete.'); close(h_wait);
    end

% --- Export Cleared txt-file (CN)-------------------------------
    function ExportclearedBCallback(source,event) %#ok
        zeroColls = find(all(RAW.M==0,1));
        RAW.M(:,zeroColls) = [];
        EL_NAMES(zeroColls) = [];
        TM = horzcat(1000*T', RAW.M);
        
        title = [full_path(1:(length(full_path)-4)),'-cleared.txt'];  % Name and path for the Export-file
        
        [filename, pathname] = uiputfile ('*.txt','save as...',title);
        if filename==0, return,end
        path_file=fullfile(pathname,filename);
        
        fid = fopen(path_file, 'wt');
        
        %Output fileinto
        csvFun = @(str)sprintf('%s,',str);
        xchar = cellfun(csvFun, fileinfo{1}, 'UniformOutput', false);
        xchar = strcat(xchar{:});
        xchar = strcat(xchar(1:end-1),'\n');
        fprintf(fid,xchar);
        %Output filedetails
        csvFun = @(str)sprintf('%s,',str);
        xchar2 = cellfun(csvFun, filedetails{:}, 'UniformOutput', false);
        xchar2 = strcat(xchar2{:});
        xchar2 = strcat(xchar2(1:end-1),'\n');
        fprintf(fid,xchar2);
        
        %Output t Elxx Elxx etc
        n=size(EL_NAMES,1);
        Row3(1)={' t'};
        Row3(2:n+1) = EL_NAMES(1:n);
        
        [h i]=size(Row3);
        clear content
        content(1:h,1:2:2*i)=Row3;
        content(1:h,2:2:2*i)={sprintf('\t')};
        content(1:h,end)={sprintf('\n')};
        content=reshape(content',1,[]);
        fprintf(fid, '%s',[content{:}]);
        
        Row4(1)={'[ms]'};
        Row4(2:n+1) = {'[ï¿½V]'};
        [j k]=size(Row4);
        clear content
        content(1:j,1:2:2*k)=Row4;
        content(1:j,2:2:2*k)={sprintf('\t')};
        content(1:j,end)={sprintf('\n')};
        content=reshape(content',1,[]);
        fprintf(fid, '%s',[content{:}]);
        
        for ii = 1:size(TM,1)
            fprintf(fid,'%5.2f \t',TM(ii,:));
            fprintf(fid,'\n');
        end
        
        clear h i j k n TM
        fclose(fid);
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
    end

% --- Export Time-shape txt-file (CN)-------------------------------
    function ExportTimeShapeCallback(source,event)
        Time_Shape = export_Time_Shape(EL_NUMS,RAW.M,SPIKES,SaRa);
        
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
    end

% --- Save Spikes as mat-file (MC) -----------------------------
    function SaveSpikesCallback(~,~)
        [pathstr,filename,ext] = fileparts(file); 
        FILENAME=[filename '_TS.mat'];
        [filename, filepath] = uiputfile ('*.mat','save as...',FILENAME);
        if filename==0, return,end 
        
        cd(filepath)
        

        temp.SPIKEZ=SPIKEZ;
        save(filename, 'temp')
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



% --- Histogram  (Sh.KH)-----------
     function histogramBeatingRate(~,~) 
    
        clear ISI;         
        fh = figure('Units','Pixels','Position',[350 400 400 500],'Name','Histogram','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 370 350 100],'FontSize',11, 'String',' Beatrate analysis for cardiac myocytes. Please select single, multi or complete analysis.');
        %----bin selected
        uicontrol('Parent',fh,'Units','pixels','Position',[165 375 100 20],'style','text','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','s    (min 0,001)');
        uicontrol('Parent',fh,'Units','pixels','Position',[25 375 45 20],'style','text','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','Bin');
        uicontrol('Parent',fh,'Units','pixels','Position',[100 375 60 25],'style','edit','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','10','Tag','BIN_Select');
        %---single analysis
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 340 150 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_electrodeLabel','String','Single Electrode Analysis','FontWeight','bold');
        uicontrol('Parent',fh,'Units','Pixels','Position', [100 300 75 25],'Tag','ISIcall1','FontSize',8,'String',[' 12';' 13';' 14';' 15';' 16';' 17';' 21';' 22';' 23';' 24';' 25';' 26';' 27';' 28';' 31';' 32';' 33';' 34';' 35';' 36';' 37';' 38';' 41';' 42';' 43';' 44';' 45';' 46';' 47';' 48';' 51';' 52';' 53';' 54';' 55';' 56';' 57';' 58';' 61';' 62';' 63';' 64';' 65';' 66';' 67';' 68';' 71';' 72';' 73';' 74';' 75';' 76';' 77';' 78';' 82';' 83';' 84';' 85';' 86';' 87'],'Value',1,'Style','popupmenu');
        uicontrol('Parent',fh,'Units','pixels','Position',[25 300 45 20],'style','text','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','El');
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[290 300 100 30],'String','Analyze','ToolTipString','Start Analysis','CallBack',@BeatingEinzelanalyse);
        %---Multianalysis analysis
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 235 150 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_electrodeLabel','String','Multi Electrode Analysis','FontWeight','bold');
        uicontrol('Parent',fh,'Units','pixels','Position',[25 180 45 20],'style','text','HorizontalAlignment','left','Enable','on','FontSize',9,'units','pixels','String','El');
        uicontrol('Parent',fh,'style','edit','units','Pixels','position', [100 180 80 25],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_Select_electrode','string','12 13 14');
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[290 180 100 30],'String','Analyze','ToolTipString','Start Analysis','CallBack',@BeatingMultianalyse);
        %---all electrodes
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 130 150 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_electrodeLabel','String','Complete Analysis','FontWeight','bold');
        uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 70 250 50],'HorizontalAlignment','left','FontSize',10, 'String','Analysis of all measured electrodes. Results will be shown tabular.');
        uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[290 60 100 30],'String','Analyze','ToolTipString','Start Analysis','CallBack',@BeatingKomplettanalyse);   
     end

% --- Single Electrode Analysis--------------------------------
    function BeatingEinzelanalyse(~,~) 

        ISI_elektrode=get(findobj(gcf,'Tag','ISIcall1'),'value');     % Electrode #
        bi = strread(get(findobj(gcf,'Tag','BIN_Select'),'string'));  % bin value
 
        if bi<0.001 || bi>rec_dur
            msgbox('bin value is incorrect!')
        else 
        close(gcbf)
        a=fix(rec_dur/bi); % Number of Bin
        ISI=zeros(a,2);
        nb=1; % bit #
        for i=0:bi:rec_dur 
            ISI(nb,1)=sum(i<SPIKEZ.TS(:,ISI_elektrode)&SPIKEZ.TS(:,ISI_elektrode)<=(i+bi));
            x=(i<SPIKEZ.TS(:,ISI_elektrode)&SPIKEZ.TS(:,ISI_elektrode)<=(i+bi));
            xd= SPIKEZ.AMP(:,ISI_elektrode); 
            x=reshape(x,1,(numel(x)));
            if (numel(x)>0)&&(ISI(nb,1)>0)
                ISI(nb,2) = (x*xd)/(sum(x));
            else
                ISI(nb,2)=0;
            end
            nb=nb+1;
        end
         %Graph        : ------------------------------------------
        figure('Position',[50 50 900 600]); 

        % Information  : ------------------------------------------
         subplot(22,2,[1 2]);
         axis off;
         text(0,3,[' Single Electrode Analysis (Cardiac Myocytes). '],'FontWeight','demi', 'Fontsize',12);
         text(0.8,3,[ 'Electrode : ' num2str(EL_NUMS(ISI_elektrode))],'FontWeight','demi', 'Fontsize',12);
         text(0.8,1.8,[ 'Time bin(s) : ' num2str(bi)] ,'FontWeight','demi', 'Fontsize',12);
         text(0,2.2,num2str(full_path),'Fontsize',9);
         text(0,1.5,[fileinfo{1}],'Fontsize',9);

        % Beating Rate Graph : ------------------------------------
        subplot(22,1,[3 10]);
        axis off;
        Y = ISI(:,1)/bi;
        Y(end)=Y(end-1);
        X = 0:bi:rec_dur;
        stairs(X,Y)
        axis([0 a*bi 0 max(Y)+(max(Y)/10)]) 
        xlabel('time / s'); ylabel('Beatrate in Hz');
        title('Beating Rate')
        
        
        % mean Amplitude Graph : -----------------------------------
        subplot(22,1,[14 21]);
        axis off;
        Y = ISI(:,2);    
        Y(end)=Y(end-1);
        X = 0:bi:rec_dur;
        stairs(X,Y)
        axis([0 a*bi min(Y)+(min(Y)/10) 0]) 
        xlabel('time / s'); ylabel('Voltage in uV/bin'); 
        title('Mean Amplitude')
        end
    end

% --- Multi Electrode Analysis -----------------------------------------------
    function BeatingMultianalyse(~,~) 
        elselect = strread(get(findobj(gcf,'Tag','CELL_Select_electrode'),'string'));
        bi = strread(get(findobj(gcf,'Tag','BIN_Select'),'string')); %bin value
        
        if bi<0.001 || bi>rec_dur
            msgbox('bin value is incorrect!')
        else 
            if sum(ismember(elselect,EL_NUMS)) ~= numel(elselect)
               msgbox('Electrode number is wrong!')
            else
                for i=1:(numel(elselect))
                     elektrode(1,i) = find(EL_NUMS==elselect(:,i));
                end
                multispike = SPIKEZ.TS(:,elektrode);
                multiamp = SPIKEZ.AMP(:,elektrode);
                close(gcbf)
                a=fix(rec_dur/bi); % Number of Bin
                ISI=zeros(a,2);
                nb=1; % bit #
                for i=0:bi:rec_dur 
                    ISI(nb,1) = sum(sum(i<multispike & multispike <=(i+bi)));
                    x=(i<multispike & multispike<=(i+bi));
                    xa= multiamp; 
                    x=reshape(x,1,(numel(x)));
                    xa=reshape(xa,(numel(x)),1);
                    if (sum(x)>0)
                        ISI(nb,2) = (x*xa)/(sum(x));
                    else
                        ISI(nb,2)=0;
                    end
                    nb=nb+1;
                end 

                 %Graph: --------------------------------------------------
                figure('Position',[50 50 900 600]); 

                % Information
                 subplot(22,2,[1 2]);
                 axis off;
                 text(0,3,[' Multi Electrode Analysis (Cardiac Myocytes). '],'FontWeight','demi', 'Fontsize',12);
                 text(0.6,3,[ 'Electrode : ' num2str(EL_NUMS(elektrode))],'FontWeight','demi', 'Fontsize',12);
                 text(0.6,1.8,[ 'Time bin(s) : ' num2str(bi)] ,'FontWeight','demi', 'Fontsize',12);
                 text(0,2.2,num2str(full_path),'Fontsize',9);
                 text(0,1.5,[fileinfo{1}],'Fontsize',9);


                % Beating Rate Graph : ------------------------------------
                subplot(22,1,[3 10]);
                axis off;
                Y = ISI(:,1)/numel(elselect)/bi;
                Y(end)=Y(end-1);
                X = 0:bi:rec_dur;
                stairs(X,Y)
                axis([0 a*bi 0 max(Y)+(max(Y)/10)]) 
                xlabel('time / s'); ylabel('Mean Beatrate in Hz');
                title('Beating Rate')


                % mean Amplitude Graph : ------------------------------------
                subplot(22,1,[14 21]);
                axis off;
                Y = ISI(:,2);    
                Y(end)=Y(end-1);
                X = 0:bi:rec_dur;
                stairs(X,Y)
                axis([0 a*bi min(Y)+(min(Y)/10) 0])   
                xlabel('time / s'); ylabel('Voltage in uV/bin'); 
                title('Mean Amplitude')

            end
        end
    end
% --- complete Analysis --------------------------------
    function BeatingKomplettanalyse(~,~) 
        bi = strread(get(findobj(gcf,'Tag','BIN_Select'),'string')); %bin value
         if bi<0.001 || bi>rec_dur
            msgbox('bin value is incorrect!')
        else 
            close(gcbf)
            a=fix(rec_dur/bi); % Number of Bin
            ISI=zeros(a,2);
            nb=1; % bit #
            for i=0:bi:rec_dur 
                ISI(nb,1) = sum(sum(i<SPIKEZ.TS & SPIKEZ.TS <=(i+bi)));
                x=(i<SPIKEZ.TS & SPIKEZ.TS<=(i+bi));
                xa= SPIKEZ.AMP(:,:); % shiva : ha ro gozashtam ke daghighan size khodesh bashe matriks jadid 
                x=reshape(x,1,(numel(x)));
                xa=reshape(xa,(numel(x)),1);
                if sum(x)>0 % shiva mishe inja sum(sum(x)) ham nevesht agar reshape nakarde basham
                    ISI(nb,2) = (x*xa)/(sum(x));
                else
                    ISI(nb,2)=0;
                end
                nb=nb+1;
            end   
            %Graph: --------------------------------------------------
            figure('Position',[50 50 900 600]); 

            % Information
             subplot(22,2,[1 2]);
             axis off;
             text(0,3,[' All Electrodes Analysis (Cardiac Myocytes). '],'FontWeight','demi', 'Fontsize',12);
             text(0.8,1.8,[ 'Time bin(s) : ' num2str(bi)] ,'FontWeight','demi', 'Fontsize',12);
             text(0,2.2,num2str(full_path),'Fontsize',9);
             text(0,1.5,[fileinfo{1}],'Fontsize',9);


            % Beating Rate Graph : ------------------------------------
            subplot(22,1,[3 10]);
            axis off;
            Y = ISI(:,1)/numel(EL_NUMS)/bi;
            Y(end)=Y(end-1);
            X = 0:bi:rec_dur;
            stairs(X,Y)
            axis([0 a*bi 0 max(Y)+(max(Y)/10)]) 
            xlabel('time / s'); ylabel('Mean Beatrate in Hz');
            title('Beating Rate')
            SPIKEZ.Histogram.Beatrate = Y; % save beatrate histogram so it can be exported as mat file

            % mean Amplitude Graph : ------------------------------------
            subplot(22,1,[14 21]);
            axis off;
            Y = ISI(:,2);    
            Y(end)=Y(end-1);
            X = 0:bi:rec_dur;
            stairs(X,Y)
            axis([0 a*bi min(Y)+(min(Y)/10) 0]) 
            xlabel('time / s'); ylabel('Voltage in uV/bin'); 
            title('Mean Amplitude')
            SPIKEZ.Histogram.meanAmplitude = Y; % save beatrate histogram so it can be exported as mat file
            SPIKEZ.Histogram.binSize = bi;
        end
    end 


%functions - Tab Tools
%----------------------------------------------------------------------
% --- Automated Analysis
    function AutomatedAnalysis_Callback(~,~)
        close(mainWindow)
        GUI_AutomatedAnalysis
    end

end