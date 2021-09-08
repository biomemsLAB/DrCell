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

%% ------------- ToDo ------------------------------------------------------
%               - Merging Neuro and Cardio version, so functions like data
%               import are common (MC)
%               - Implement TSPE to estimate functional connections (MC)

%% ------------- Update History --------------------------------------------
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


           


function DrCell() 

DrCellVersion = '20190222';

disp (['--- Dr.Cell ' DrCellVersion ' ---']);

global Window
% ---------------------------------------------------------------------
% --- GUI -------------------------------------------------------------
% ---------------------------------------------------------------------

% Window
Window = figure('Position',[300 500 400 100],'Tag','Dr.CELL','Name',['Dr.Cell ' DrCellVersion],'NumberTitle','off','Toolbar','none','Resize','off','Color',[0.89 0.89 0.99]);

% Buttons:
% "Neuro" - Button
uicontrol('Units','pixels','Position',[8 66 180 24],'Tag','CELL_openFileButton','String','NEURO','FontSize',9,'TooltipString','Open Neuro-Modul to analyse neuronal signals.','Callback',@NeuroButtonCallback);

% Buttons:
% "Cardio" - Button
uicontrol('Units','pixels','Position',[200 66 180 24],'Tag','CELL_openFileButton','String','CARDIO','FontSize',9,'TooltipString','Open Cardio-Modul to analyse cardio-signals.','Callback',@CardioButtonCallback);

setPaths % include all needed files into MATLAB search path


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