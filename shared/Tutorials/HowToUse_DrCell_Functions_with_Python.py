# This Script shows how to run MATLAB functions (e.g. DrCell) from python
# also see: https://de.mathworks.com/help/matlab/matlab_external/call-matlab-functions-from-python.html
#
# Author: Manuel Ciba
# Date: 30.10.2023
#
#
# Installation:
#
# 1)
# MATLAB and Python needs to be installed. IMPORTANT: The versions have to be compatible:
# https://de.mathworks.com/support/requirements/python-compatibility.html
#
# 2)
# Install the python package "matlabengine"
# Install the python package "numpy"
#
# How to use:
#
# 1) Change all paths in this script marked with "ToDo"
#
# 2) Run this script
#
#
# Possible improvements for the future:
#
# 1) Use MATLAB Arrays instead of numpy
# see https://de.mathworks.com/help/matlab/matlab_external/use-matlab-arrays-in-python.html


import matlab.engine
import numpy as np


###################################
# Call MATLAB functions from Python
# also see https://de.mathworks.com/help/matlab/matlab_external/call-matlab-functions-from-python.html
###################################

# start MATLAB
eng = matlab.engine.start_matlab()

# test if a normal Matlab function works (e.g. sqrt())
print(eng.sqrt(4.0))
print("Matlab works :)")

# Define DrCell.m paths
drcell_path = r'/home/manuel/FAUbox/Work/git/_git/DrCell'  # ToDo
drcell_python_engine_path = drcell_path + '/shared/Engines/Python'
eng.cd(drcell_python_engine_path, nargout=0)
# Run init_drcell.m in order to load the paths of all DrCell-Subfolder, so we can call all DrCell functions
eng.init_drcell(drcell_path, nargout=0)


###################################
# Perform Spike Detection
###################################

# open a raw MEA recording
file = "000 Messung04.06.2014_10-48-33.dat"  # on your computer you need a raw MEA file (.dat, _RAW.mat) ToDo
path = "/home/manuel/Documents"  # path of the file ToDo
flag_waitbar = 0  # 0: don't show the waitbar
RAW, SPIKEZ = eng.readFileFunctionCaller(file, path, flag_waitbar, nargout=2)
# RAW contains the raw data:
# RAW["M"]: matrix containing the voltage data, each column is an electrode, each row a time point, voltage in µV
# RAW["T"]: array containing the time points in seconds
# RAW["SaRa"]: sample rate in Hz
# RAW["rec_dur"]: recording duration in seconds

# perform filtering and spike detection
f_edge = 50.0  # high pass filter at 50 Hz
HDrawdata = 0  # we down't use the HD MEA data from 3brains, so we set this flag to 0
thresholdFactor = 5.0  # in DrCell we normally use factor 5, but many other groups use 6 (standard deviation of noise x thresholdFactor = treshold)
baseFactor = 5.0  # should be around standard deviation of the noise (in µV)
flag_pos = 1  # 1: detect positive spikes, 0: ignore positive spikes
flag_neg = 1  # 1: detect negative spikes, 0: ignore negative spikes
idleTime = 0  #  idleTime in seconds: after a spike, all spikes within idle time are ignored (0: don't ignore spikes, 0.001: ignore all spikes that occur after a spike within 1 ms)
RAW_filtered, SPIKEZ = eng.python_apply_filter_and_spikedetection(RAW,f_edge,thresholdFactor,baseFactor,HDrawdata,flag_pos,flag_neg,idleTime, nargout=2)
# SPIKEZ contains the detected spikes:
# SPIKEZ["TS"]: Time stamps in seconds
# SPIKEZ["AMP"]: Amplitudes in µV


###################################
# Perform Feature Calculation
###################################

# here, functions from elephant can be called or more DrCell functions,
# e.g. now we call the feature calculation of DrCell:

# Convert time stamps to python numpy array:
TS = np.array(SPIKEZ["TS"])
AMP = np.array(SPIKEZ["AMP"])
rec_dur = RAW["rec_dur"]
SaRa = RAW["SaRa"]
time_win = rec_dur
FR_min = 5  # Firing rate = Spike rate, electrode will be deleted if less than FR_min spikes
N = 0  # N is number of electrodes - will be set automatically if set to 0
binSize = 0  # will be set automatically if set to 0
flag_norm = 0  # 0: no normalization is applied
flag_waitbar = 0  # 0: don't show waitbar
Selection = 'Sync_Contrast' # As an example, here we select the feature "Sync_Contrast". See comment at the end of the script for all possible options

# Call DrCell function
#parameter = eng.adapter_python(drcell_path, TS, AMP, rec_dur, SaRa ,Selection, time_win, FR_min, N, binSize, flag_norm, flag_waitbar)
parameter = eng.python_calculate_features(TS, AMP, rec_dur, SaRa, Selection, time_win, FR_min)

print(parameter)
print("Finished :)")



# List of features:
# 'Spikerate',
# 'Number of spikes',
# 'Amplitude',
# 'ActiveElectrodes',
# 'BR_baker100',
# 'BD_baker100',
# 'SIB_baker100',
# 'IBI_baker100',
# 'BR_baker200',
# 'BD_baker200',
# 'SIB_baker200',
# 'IBI_baker200',
# 'BR_selinger',
# 'BD_selinger',
# 'SIB_selinger',
# 'IBI_selinger',
# 'NBR_chiappalone',
# 'NBD_chiappalone',
# 'SINB_chiappalone',
# 'INBI_chiappalone',
# # jimbo missing
# 'NBR_MC',
# 'NBD_MC',
# 'SINB_MC',
# 'INBI_MC',
# #'Sync_CC_selinger',
# 'Sync_STTC',
# # 'Sync_MI1',
# # 'Sync_MI2',
# 'Sync_PS',
# 'Sync_PS_M',
# 'Sync_Contrast',
# 'Sync_Contrast_fixed',
# 'Sync_ISIDistance',
# 'Sync_SpikeDistance',
# 'Sync_SpikeSynchronization',
# 'Sync_ASpikeSynchronization',
# 'Sync_AISIDistance',
# 'Sync_ASpikeDistance',
# 'Sync_RISpikeDistance',
# 'Sync_RIASpikeDistance',
# 'Sync_EarthMoversDistance',
# 'Connectivity_TSPE',
# 'Entropy_bin100',
# 'Entropy_capurro'