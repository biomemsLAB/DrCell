% ++++++++++++++++++++++++++++++++++
% ++++++++++ Dr.Cell +++++++++++++++
% ++++++++++++++++++++++++++++++++++


%This programm is designed to process signals recorded with microelectrode arrays.
%Neural and Cardiac signals can be processed.
%Copyright (C) 2009-2015 Christoph Nick, Michael Goldhammer, Robert
%Bestel, Frederik Steger, Manuel Ciba, Johannes Forster, Andreas W. Daus, Christiane Thielemann

%This program is free software: you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation, either version 3 of the License, or
%(at your option) any later version.

%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.

%The GNU General Public License can be found at http://www.gnu.org/licenses/



function DrCell() 

close all;
clear all;
clc

DrCellVersion = '20250626';

disp (['--- Dr.Cell ' DrCellVersion ' ---']);

global Window
global GUI_Color_BG GUI_Color_NeuroButton GUI_Color_CardioButton

% --- Set GUI Color ---
GUI_Color_BG = [1 1 1]; % white 
GUI_Color_NeuroButton = ([0 204 187]+50)/255; % green
GUI_Color_CardioButton = ([89 189 207]+40)/255; % blue
set(0,'DefaultUicontrolBackgroundColor',GUI_Color_BG);
set(0,'DefaultFigureColor',GUI_Color_BG);

% ---------------------------------------------------------------------
% --- GUI -------------------------------------------------------------
% ---------------------------------------------------------------------

% Window
set(0,'units','pixels')  
screenSize = get(0,'screensize'); %Obtains this pixel information
Window = figure('Position',[800 screenSize(4)/2 400 100],'Tag','Dr.CELL','Name',['Dr.Cell ' DrCellVersion],'NumberTitle','off','Toolbar','none','Resize','off','Color',GUI_Color_BG);

% Buttons:
% "Neuro" - Button
uicontrol('Units','pixels','Position',[8 66 180 24],'Tag','CELL_openFileButton','String','NEURO','FontSize',8,'fontweight', 'bold','TooltipString','Open Neuro-Modul to analyse neuronal signals.','BackgroundColor',GUI_Color_NeuroButton,'Callback',@NeuroButtonCallback);

% Buttons:
% "Cardio" - Button
uicontrol('Units','pixels','Position',[200 66 180 24],'Tag','CELL_openFileButton','String','CARDIO','FontSize',8,'fontweight', 'bold','TooltipString','Open Cardio-Modul to analyse cardio-signals.','BackgroundColor',GUI_Color_CardioButton,'Callback',@CardioButtonCallback);


setPaths % include all needed files into MATLAB search path




% DrCell logo
panax2 = axes('Parent', Window, 'Units','normalized', 'Position', [0.25 0 0.5 0.5]);
[img] = imread('biomems.tif');
imshow(img,'Parent',panax2,'InitialMagnification','fit');

%% Functions
%----------------------------------------------------------------------
    function NeuroButtonCallback(~,~) % MC
       close(Window)
       if exist('Neuro.m','file')
            Neuro % open Neuro.m
       else
            errordlg('Neuro.m is not in path (Set Path -> Add with Subfolders... -> select DrCell-Folder)')
       end
    end

    function CardioButtonCallback(~,~) % MC
       close(Window)
       if exist('Cardio.m','file')
            Cardio % open Cardio.m
       else
           errordlg('Cardio.m is not in path (Set Path -> Add with Subfolders... -> select DrCell-Folder)')
       end
    end

    function setPaths(~,~) % MC
        % remove old DrCell/Neuro/Cardio folder from search path
        PathCell = textscan(path, '%s', 'Delimiter', pathsep);
        PathCell = PathCell{1,1}; % unpack cell (as textscan was used)
        for i=1:size(PathCell,1)
            if any(strfind(PathCell{i},'DrCell')) % remove all entries that contain string "DrCell"
              rmpath(PathCell{i});
            end
        end
        
        % Add all DrCell folder to matlab search path
        path_full = mfilename('fullpath'); % get path of this m-file (.../path/DrCell.m)
        [path_drcell,~] = fileparts(path_full); % separate path and m-file-name
        
        p=genpath(path_drcell); % get path of all subfolders        
        addpath(p); % add to matlab search path
        
    end
end



%% ------------- ToDo ------------------------------------------------------
%               - Cardio: Zoom-Button3, error if no spike detection has
%               been conducted yet (MC)
%               - Cardio, line 5305, error: index is not an integer (MC)
%               - Bugfix: getSpikePositions (fast version by Sh.Kh
%               generated error for 60 MEA data) (MC)
%               - Modify waitbar of "Filter" and "Threshold" to show
%               progress of every electrode (MC)
%               - Error: HDMEA raw signal loaded, then using Zoom button
%               (MC)
%               - Add "Sum of Bursts" to excel document (MM)
%               - Add button after threshold tab that calculates all
%               parameter (spike/burst/synchrony ect.) (MC)
%               - when switching from 4 electrode view to all electrode
%               view, the buttons (zoom, invert ect.) of the 4th plot are still visible (MC)

%% ------------- Update History --------------------------------------------
% see Github for an up to date update history:
% https://github.com/biomemsLAB/DrCell
%
% Date          Description             (Signature)                        
% 24.06.2014:   - Show Spikes&Bursts in zoom window (MC)
%               - Excel-export: Amplitudes, SIB for every burst (MC)
% 28.07.2014:   - open Threshold file: manual selection (MC)
% 18.11.2014:   - ISI-Histogram (MC)
% 26.11.2014:   - Button: "Six-Well-MEA" (MC)
%               - Burstdetection: "Selinger" added, "Jungblut" removed (MC)
%               - Spikedetection: refractory time calculation changed (MC)
%               - Networkburst-detection according to Chiappalone (MC)
%               - SBEdetection: faster algorithm (MC)
%               - show Burst-begin and Burst-end in Zoom-window (MC)
%               - Analyze: checkbox for spike- burst-SBE-detection (MC)
%               - Button: "Merge TimeAmp files" (MC)
%               - Button: "Calc per Electrode" (MC)
% 11.12.2014:   - Networkburst-detection, modification: th = 9 or 1/4 * max
%                 value (MC)
%               - positive Threshold and Spikedetection (MC)
% 16.12.2014	- bugfix: positive Threshold, redraw (MC)
% 22.12.2014    - now DrCell-folder has to be added to the Matlab-path (MC)
% 02.03.2015    - convert .dat to .mat (MC) Button
%               - Mutual Information + Eventsynchronisation (RB)
% 20.04.2015    - new Rasterplot displays: SPIKES, BURSTS, SBE,
%                 NETWORKBURSTS (MC)
%               - Mutual Information uses this normalization: MI=2*I/(H(X)+H(Y))
% 18.05.2015    - Bugfix Zoombutton (SPIKES=[], BURSTS.BEG=[]) (MC)
%               - Bugfix xls-export (MC)
% 20.05.2015    - Button: xl-export (MC)
% 02.06.2015    - structure: SPIKEZ (MC)
% 29.06.2015    - Analysis: SBE_old, SBE, Rasterplot: improved (MC)
%               - Automated Analysis v1 (MC)
% 20.09.2015	- Burstdetection: Kapucu (MC,MP)
% 23.09.2015	- Bugfix: set Threshold per click in main-window (not zoom-window) (MC)
% 23.10.2015    - Dynamic Thresholds (MC)
% 02.11.2015    - Bugfix: Button Show/Save Threshold (MC)
% 04.11.2015    - global variable THRESHOLDS is not used any more - instead
%                 use SPIKEZ.neg.THREHOLDS.Th (MC)
% 05.11.2015    - Bugfix: positive Spikedetection (min->max) (MC)
%               - Rasterplot: #NB, #SBE, #SBE-old (MC)
% 06.11.2015    - Button: "Split Raw Data", TimeAmp+Merge removed (MC)
% 11.11.2015    - Bugfix: xlwrite (MC)
% 11.01.2016    - Excel-Export: Burstdetection-Info (MC)
% 09.02.2016    - BurstParameterCalculation: std: derived, mean: arithmetic
%               - Button: "Measuring Sync", xls-export: CC,MI1+2,PS (MC)
% 11.02.2016    - Excel-Export: global parameter: Spikes, Amps, Bursts (MC)
%               - BurstParameterCalculation/SpikeParameterCalculation: aeN
% 15.02.2016    - Measuring Sync: EventSynchronization (MC)
% 26.02.2016    - Bugfix: Burst/Spike-ParameterCalculation, avoid zeros in global mean parameter (MC)
% 01.03.2016    - new spikedetection (F.Lieb) added (MC)
% 03.05.2016    - new networkburstdetection (beta version - only for testing) (MC)
% 04.05.2016    - Button: Cross-correlation: Networkplot using cross-correlation (MC)
% 07.09.2016    - cd(path) in openRawFile (MC)
% 13.02.2017    - xls-export: compatibility with old TS.mat files (MC)
% 21.03.2017    - open mat files: support for TS files with NaN-Padding (MC)
% 18.05.2017    - Export .xls: improving performance (SDB)
% 18.07.2017:   - rename variable "count" -> compatibility 2017a (SDB) 
% 26.07.2017    - New button added: Postprocessing Tab: "Stationarity" [Eggermont et al.] (MC)
%               - Spikedetection added [Lieb et al.] (MC)
%               - Button "Sync Measure" modified (MC)
% 27.07.2017    - Bugfix in function
%                "SyncMeasure_Crosscorrelation_Selinger" (MC)
%               - Data conversion functions shifted to new folder: Neuro ->
%               shared/DataConversion (MC)
% 01.08.2017    - Update: "Stationarity" and "Min. Spikerate" (Amplitudes are now modified as well)(MC)
% 04.08.2017    - Button: "Import .mat-file": Compatibility for larger data (MC)
% 03.11.2017    - Bugfix: Spikedetection SWTEO (MC)
% 12.12.2017    - function "idle_time" that is used by "spikedetection" now
%                   needs the time in seconds, not in milliseconds! (MC)
% 09.02.2018    - Excel-Export: some more synchrony values are added (SC,
%                   and CCselinger), SC is calculated by default (MC)
% 06.04.2018    - Tab "Tools": Automated Analysis extended with
%                   spikedetection SWTEO (MC)
% 07.05.2018    - SNR bugfix (SNR = AMP/STD^2) -> (SNR = AMP^2/STD^2) (RB)
% 08.05.2018    - Bugfix Excel-Export, TS -> SPIKES.TS (MC)
% 24.05.2018    - Tab "Tools": Automated Analysis: Parameter selection (MC)
%               - Spike-Contrast function: "minBin" added as optional argument (MC)
% 29.05.2018    - Spikedetection.m updated with faster version (ShKh)
% 01.06.2018    - Synchrony measures added (AISIDistance, ASpikeDistance)
%               - bugfix: folder "DataConversion" was not in Matlab path (MC)
% 04.06.2018    - GUI_AutomatedAnalysis: improved effeciency for large
%               spike train data (MC)
% 05.06.2018    - bugfix: Spikedetection offset of one sample corrected (ShKh)
%               - new folder "Burstdetection", "SBEdetection",
%               "Networkburstdetection" (MC)
%               - SBEdetection replaced by faster "SBEdetection_Sh" (ShKh)
% 18.06.2018    - Synchrony measures added: ASpikeSynchronization,
%               RIA-SPIKEdistance (not in GUI yet) (MC)
% 29.06.2018    - SyncMeasure_Phasesynchronization replaced by faster
%               version (ShKh)
%               - renamed function "reduceSpikes" to
%               "deleteLowFiringRateSpiketrains" (MC)
% 10.08.2018    - export threshold file: noise level for each electrode
%               will be also exported => so it is possible to redo
%               spikedetection with different threshold factors (MC)
% 20.08.2018    - bugfix: Automated Analysis Tool, Rootpath was not used
%               (MC)
% 05.09.2018    - Update History moved from Neuro.m to DrCell.m (MC)
% 11.09.2018    - Added functions to load and convert data (MC):
%               "load_dat.m": loads raw ".dat" data recorded with Labview and outputs M, T, SaRa ect.
%               "createStructure_RAW.m": creates structure RAW from M, T, SaRa ect.
%               "saveRAW.m": saves the structure as "filename_RAW.mat"
%               "MCS_hd5_2_RAW.m": Converts HDF5 (MCS) files to RAW (DrCell)
%               - Added waitbars to button "Import .mat-File" (MC)
%               - replaced parts of code from button "Import .mat-File" and "Convert
%               .dat to .mat" by new functions (MC).
% 26.11.2018    - Added Variable to DrCell.m "DrCellVersion"
% 19.02.2019    - Improved "Import File" Button (data format filter) (MC)
%               - Delete buttons: "Import ASCII...","Next File","Previous File" (MC)
%               - Bugfix: positive Thresholds for HDMEA-Data (MC)
%               - Bugfix: plotting thresholds (MC)
%               - Spikedetection: positive spikes now compatible with
%               HDMEA-Mode (MC)
% 22.02.2019    - Bugfix: Neuro+Cardio: import of non-HDMEA-data possible again (MC)
% 28.02.2019    - Added Networkburstdetection according to Jimbo's lab (no GUI yet) (MC)
% 06.03.2019    - Bugfix: importing 60-El-MEA .dat data (MC)
%               - Bugfix: calc. threshold for 60-El-MEA data (MC)
%               - Added function: Import ".rhd" raw files possible (MC)
% 14.03.2019    - Bugfix: Excel Export, 'fileinfo' not a cell for 3brain data (MC)
% 22.03.2019    - Replaced global variable "path" with "myPath" as "path"
%               is also a matlab function => conflict with 2018 matlab version (MC)
% 02.04.2019    - support for Fileformat .h5 (= HDF5 format of Multichannel Systems) (MC)
%               - Note: matlab addon "McsMatlabDataTools" has to be installed: Home -> Add-Ons -> Get Add-Ons -> search for "McsMatlabDataTools"
%               Note: if .mcs file should be opened, then download "Multichannel DataManager" to convert .mcd to .h5
%               - Added Button "Clear Artefacts" (MC)
% 04.04.2019    - Bugfix: positive spikedetection for HDMEA data
%               (digital2analog(M) was performed for negative and then for positive spikes again) (MC)
%               - keep electrode selection when HDMEA mode is used (MC)
% 05.04.2019    - Bugfix: opening .rhd files (MC)
% 09.04.2019    - Bugfix: Amplitude values of HDMEA-data converted to digital values after spike detection (MC)
%               - Bugfix: filename is updated in GUI in HDMEA mode (MC)
%               - New Button: Postprocessing: "Connectivity" to estimate
%               connectivity using TSPE by Stefano De Blasi et al., bug: currently does not find any connections (MC)
%               - New Button: Postprocessing: "Spike-contrast" to visualize
%               the process of calculating Spike-contrast. (MC)
% 25.04.2019    - Reorganization of data import functions (MC)
%               - Bufix: Load .dat data (MC)
%               - Bugfix: redraw after spikedetection in HDMEA mode (MC)
%               - Bugfix: Spike-contrast is calculated during excel export
%               for all files (MC)
% 26.04.2019    - Bugfix: time stamps detected by SWTEO had +1 sample offset so
%               amplitude values were not correct (MC)
%               - Connectivity estimation for 60 ch MEA works (with or without
%               threshold) (MC)
%               - New GUI style (white background) (MC)
% 03.05.2019    - Graph theory added (small worldness ect.), not completely tested (MC)
% 07.05.2019    - AutomatedAnalysisTool (TAB1) compatible with HDMEA-Data (MC)
%               - Bugfix: Burstdetection (last burst not present) (MC)
%               - some reorganization of file/folder names and orders (MC)
% 09.05.2019    - Connectivity: Circular Graphs added (MC)
% 13.05.2019    - AutomatedAnalysisTool: Compatibility with all file
%               formats that are also supported by DrCell (MC)
% 23.07.2019    - AutomatedAnalysisTool: Connectivity calculation added (not tested yet) (MC)
% 19.08.2019    - AutomatedAnalysisTool: Threshold factor of loaded
%               threshold file is used if GUI field is emtpy (now default value is 'empty') (MC)
% 26.08.2019    - Added Button "Part. clear Signal" (Tab 2) to delete parts of the
%               raw signal (MC) 
%               - Added Button "Export File" (Tab 1) to save manipulated
%               raw files (MC)
% 14.10.2019    - Bugfix: CalcParameter_function -> ConnectivityTSPE ->
%               .meanS.r3 changed to .mean = S.r3
% 23.11.2019    - New Version of cSPIKE added (used to calculate
%               SPIKEsynchro ect.). Compiled for win and linux (MC)
% 26.11.2019    - Bugfix in SpikeTrainSet of cSPIKE (MC)
% 06.02.2020    - better description of the function burstdetection.m (MC)    
% 03.03.2020    - Bugfix in read_mat: Variable "Data" and "Time" not assigned (MC)
% 04.03.2020    - Added Button "Quick Analysis" (MC)
% 24.03.2020    - Bugfix Syncmeasure_PhaseSync: error when spike at first or at last position (MC)
% 06.04.2020    - Update function "plotISI_Histogram": binMethod option added (MC)
% 19.10.2020    - Postprocessing/Connectivity: only CM values > 2*std(CM) are plotted (MC)
% 22.10.2020    - If Signal Processing Toolbox is not installed, load predefined filter (only highpass 50 Hz) (MC)
% 28.10.2020    - If Statistics Toolbox is not installed, unse sdt() instead of normfit() 
%               - Connectivity Button: new function: applyEasyThresholdToCM() (MC)
% 28.10.2020    - Extention of function applyEasyThresholdToCM() (MC)
% 06.11.2020    - Bugfix Spikedetection: one spike was detected on non-valid electrodes (threshold values of 10000) (MC)
%               - Fixed layout for MCS data (.h5) (MC)
%               - exclusion of old functions in post-processing tab which are not used anymore (MC)
%               - Bugfix redraw_allinone: scrolling was not possible for SaRa of 25000 Hz -> changed int16 to int32 (MC)
% 24.11.2020    - cleaning up some comments (MC)
% 01.12.2020    - Inclusion of SyncMeasure_EarthMoversDistance (MC)
% 26.02.2021    - change in function "TSPE.m", line 160: replace all NaNs to zeros (MC)
% 12.03.2021    - change in function "CalcParameter_function.m": TSPE
%               surrogate Threshold now calculates same graph theory measures such as TSPE without threshold (MC)
% 16.03.2021    - Cardio Analysis Button (only for test purpose) (MC)
%               - SpikeParameterCalculation.m: forced zero padding (MC)
% 18.03.2021    - Added Cardio Analysis Button to the Cardio.m module (MC)
%               - changed SpikeContrast_figure.m to calculate smaller bin sizes of 1 ms (MC)
% 23.03.2021    - Bugfix in Cardio/Postprocessing/Signalprocessing (MC) 
% 13.04.2021    - Cardio Quick Analysis Button: added velocity calculation and automatically delete assynchonous electrodes (MC)
% 22.04.2021    - Cardio: Tab 10 "Tools" added, AutomatedAnalysisTool extended with a Cardio-spikedetection mode (MC)
% 30.04.2021    - Cardio: AutomatedAnalysisTool extended with CardioFeatureCalculation (till now, only Velocity is usable) (MC)
%               - The term "parameter" has been changed to "features" in all functions (MC)
% 01.05.2021    - Neuro: CardioAnalysisButton added. Cardio-Signalprocessing button added (MC)
%               - AutomatedAnalysisTool: extended CardioFeatureCalculation (Beatrate, ISI, Amp) (MC)
% 13.07.2021    - Cardio: Major Bugfixes in CardioAnalysisTool. Spike amplitudes fixed (MC)
% 14.07.2021    - Bugfix: AutomatedAnalysisTool, too many input arguments in functino "applyRefractoryAndGetAmplitudes()" (MC)
% 15.07.2021    - Bugfix: AutomatedAnalysisTool, loading threshold files without error message (MC)
%               - AutomatedAnalysisTool: one threshold file per folder was required. Now also a tresholdfile for each file is working and automatically detected (MC)
%               - Bufix: CardioAnalysis: correct empty spike train handling (MC)
% 31.08.2021    - getAllGraphParameter: replaced nanmax to max (MC)
% 21.09.2021    - added Folder "Tutorial" and a script which show how to use DrCell functions in a script (MC)
% 08.10.2021    - add function cardioDeleteSameTime.m and fix bug in zeroPadding.m (MC)
% 26.10.2021    - remove function call cardioDeleteSameTime.m from Cardio analysis (MC)
%               - Add button 'Export csv' to tab 4 of Automated Analysis Tool
% 28.10.2021    - Extend 'Export csv' in tab 4 of Automated Analysis Tool to support more than one file
% 02.11.2021    - Fix compatiblity issues with Win vs. Linux (filesep do not works with cells) and older Matlab versions (double quotes are not supported) 
% 02.12.2021    - Add applyThreshold_DDT.m and rename TSPE_DDT.m to DDT.m (MC)
% 20.12.2021    - Fix error in GUI_AutomatedAnalysis.m when using SixWell-MEA mode (MC)
% 21.12.2021    - Add SixWell-MEA mode for conduction velocity (airline) calculation (MC) 
% 15.02.2022    - Fix error when analyzing cardio data with one active electrode
%               - Support HDMEA files shorter than 1 second
% 28.02.2022    - Replace normfit with std in calc_snr.m
% 22.03.2022    - Add new MEA layout (60HDMEA) for cardio velocity (airline) calculation (tab 2 of Automated Analysis Tool) (MC)
% 04.04.2022    - Fix error in positive spike detection (MC)
% 19.04.2022    - Fix bug in quick cardio analysis (MC)
% 29.04.2022    - Add textfield to GUI_AutomatedAnalysis to enter basenoise factor for threshold calculation (MC)
% 19.05.2022    - Add support for old _TS.mat files ("sixwell-error") (MC)
%
