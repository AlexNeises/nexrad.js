import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import matplotlib
import pyart
import numpy as np
import multiprocessing as mp
import os

XS = 2.
SM = 5.
MD = 10.
LG = 20.
rad = 'NSW'
radarFile = 'KOUN_SDUS64_NSWTLX_201305202016'
siz = XS
rng = 230.

def neighborhood(iterable):
    iterator = iter(iterable)
    prev_item = None
    current_item = next(iterator)
    for next_item in iterator:
        yield (prev_item, current_item, next_item)
        prev_item = current_item
        current_item = next_item
    yield (prev_item, current_item, None)

def process(i, j, item1, next1, item2, next2):
    if next1 != None and next2 != None:
        NSW.set_limits(xlim=(item1, next1), ylim=(item2, next2), ax=ax)
        fig.set_size_inches(siz, siz)
        if not os.path.exists(rad + '/' + str(siz)):
            os.makedirs(rad + '/' + str(siz))
        fig.savefig(rad + '/' + str(siz) + '/' + str(i) + '_' + str(j) + '.png', transparent=True)
        print('Saved ' + str(i) + '_' + str(j) + '.png')
    return

if __name__ == '__main__':
    radarNSW = pyart.io.read_nexrad_level3(radarFile)
    NSW = pyart.graph.RadarDisplay(radarNSW)

    fig = plt.figure(figsize=(siz, siz))

    ax = fig.add_subplot(111)
    ax.set_facecolor('black')
    NSW.plot('spectrum_width', ax=ax, title_flag=False, colorbar_flag=False, axislabels_flag=False, cmap='pyart_NWS_SPW')
    xmax = np.arange(0, rng, 44.5)
    ymax = np.arange(0, rng, 55.5)
    xmin = -xmax
    ymin = -ymax
    xtotran = np.concatenate([xmin, xmax])
    ytotran = np.concatenate([ymin, ymax])
    xnew = np.unique(np.sort(xtotran))
    ynew = np.unique(np.sort(ytotran))

    jobs = []
    lims = []
    i = 0
    for prev1, item1, next1 in neighborhood(xnew):
        i += 1
        j = 0
        for prev2, item2, next2 in neighborhood(ynew):
            j += 1
            lims.append((i, j, item1, next1, item2, next2))
    for z, y, a, b, c, d in lims:
        p = mp.Process(target=process, args=(z, y, a, b, c, d))
        jobs.append(p)
        p.start()