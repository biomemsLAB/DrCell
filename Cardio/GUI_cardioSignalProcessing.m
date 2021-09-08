function GUI_cardioSignalProcessing(RAW,SPIKEZ,GLOB)

% extract structures
M = RAW.M;
SPIKES = SPIKEZ.TS;
file = GLOB.file;
GUI_Color_BG = GLOB.GUI_Color_BG;
EL_NAMES = SPIKEZ.PREF.EL_NAMES;
%EL_NUM = RAW.EL_NUM;
SaRa = SPIKEZ.PREF.SaRa;
rec_dur = SPIKEZ.PREF.rec_dur;

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