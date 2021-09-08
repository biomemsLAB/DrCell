from __future__ import (print_function, division,
                        absolute_import, unicode_literals)


import numpy as np


def get_phase_spikes(spikes, tfinal):
    """
    calculate spike phase as defined in Patel 2012
    """
    phase = 2 * np.pi * np.random.rand(tfinal)  # np.zeros(tfinal)
    k = 0
    numspikes = len(spikes)
    for t in range(1, tfinal+1):
        while (k < numspikes) and (t >= spikes[k]):
            k += 1

        if k == 0:
            phase[t-1] = 2 * np.pi * (t - spikes[0])/spikes[0]
        elif k == numspikes:
            # phase[t-1] = 0
            pass
        else:
            phase[t-1] = (2 * np.pi * (t - spikes[k-1]) /
                          (spikes[k] - spikes[k-1])) + (2 * np.pi * k)

    return phase