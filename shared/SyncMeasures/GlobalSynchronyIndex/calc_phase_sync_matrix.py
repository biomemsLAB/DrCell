from __future__ import (print_function, division,
                        absolute_import, unicode_literals)


import numpy as np

def calc_phase_sync_matrix(spike_list, tfinal):
    """
    calculate the correlation matrix using spike phase
    """
    phase_list = list()
    for spikes in spike_list:
        phase = get_phase_spikes(spikes, tfinal)
        phase_list.append(phase)

    M = len(spike_list)
    C = np.zeros((M, M))
    for i in range(M):
        for j in range(i, M):
            if not ((len(spike_list[i]) == 0) or (len(spike_list[j]) == 0)):
                delta_phi = np.mod(phase_list[i] - phase_list[j], 2*np.pi)
                C[i, j] = np.sqrt(np.square(np.mean(np.cos(delta_phi))) +
                                  np.square(np.mean(np.sin(delta_phi))))
                C[j, i] = C[i, j]

    return C, phase_list