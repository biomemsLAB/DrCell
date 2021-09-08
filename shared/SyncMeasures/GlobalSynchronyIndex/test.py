# -*- coding: utf-8 -*-
"""
Created on Fri Jun 15 12:36:26 2018

@author: ciba
"""

import spike_train_correlation as sync
import numpy as np


# create test spike train data: 
# - each column contains a spike train, shorter spike trains are filled with zeros ("zero-padding"))
# - each value is the spike time in seconds    
# - in this example three spike trains are generated 
# - spike train 1 contains 4 spikes
# - spike train 2 contains 4 spikes
# - spike train 3 contains 3 spikes (last array position is filled with zero)
st1 = np.array([1, 2 ,3]) 
st2 = np.array([1, 2 ,3])
T = 4
dt = 0.1

STTC = sync.spike_time_tiling_coefficient(st1,st2,T,dt)
print(STTC)