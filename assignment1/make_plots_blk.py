from matplotlib import rcParams
rcParams['font.sans-serif'] = ['Fira Sans Condensed']
import matplotlib.pyplot as plt
import re
import numpy as np

def make_plot(input_file
            #, output_dir
            , file_name: str):

    folder = "plots/"
    file_name = file_name.split('_')[0]
    output_file = []
    text = open(input_file, 'rt').read()
    output_file = text.split('\n\n',1)[0]
    output_file = output_file.split('\n')
    # Remove first number from "openblas version"
    output_file = output_file[1:]
    # perms = ['kmn', 'knm', 'mkn', 'mnk', 'nkm', 'nmk', 'lib']
    # For BLK
    perms = ['blk']
    block_size = [8, 10, 15, 20, 25, 30, 35, 40, 50, 100, 150, 200, 250, 300, 350, 400]
    cmap = plt.get_cmap("tab10")
    COLORS = [cmap(i) for i in range(len(perms)-1)] + ["black"]

    # Make index for each permutation
    idx = dict.fromkeys(perms)
    for p in perms:
        idx[p] = [i for i in range(len(output_file)) if output_file[i].find(p) != -1]

    for i in range(len(output_file)):
        output_file[i] = re.findall("\d+\.\d+", output_file[i])

    # Plot setup
    # COLORS = ["tab:red", "tab:blue", "slategrey", "tab:green", "black", "tab:pink", "tab:orange"]
    ALMOST_BLACK = 'slategrey'

    # L0_cache = 6 # Register file
    # L1d_cache = 32 # Instruction cache
    # L1i_cache = 32 # Data cache
    # L1_cache = L1d_cache + L1i_cache
    # L2_cache = 256
    # L3_cache = 30720

    # caches = np.array([L0_cache, L1_cache, L2_cache, L3_cache])
    # caches = np.cumsum(caches)
    caches = [36, 103]
    # Plot
    fig, ax = plt.subplots(figsize=(7, 4))
    for i, key in enumerate(idx.keys()):
        # plt.plot([float(output_file[i][0]) for i in idx[key]],
        #          [float(output_file[i][1]) for i in idx[key]],
        #          color = COLORS[i],
        #          label = key,
        #          lw = 3,
        #          marker = "o")
        # ax.plot([float(output_file[i][0]) for i in idx[key]], 
        #         [float(output_file[i][1]) for i in idx[key]], 
        #         color=COLORS[i], 
        #         label=key)
        # ax.scatter([float(output_file[i][0]) for i in idx[key]], 
        #         [float(output_file[i][1]) for i in idx[key]], 
        #         color=COLORS[i], 
        #         s=10)
        ax.plot(block_size,
                [float(output_file[i][1]) for i in idx[key]],
                color = "blue")
    # ax.set_yscale('log', base=10)
    # ax.set_xscale('log', base=2)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.set(
        title=f"{file_name} compiler",
        ylabel="Performance [MFLOPS]",
        xlabel="Block size"
    )
    ax.legend(
        fontsize="small",
        framealpha=1,
        edgecolor="white",
        # loc="center left",
    )

    ax.vlines(caches, ymin=0, ymax=2300, linestyle="--", color=ALMOST_BLACK)
    # ax.aunnotate(text="L1 cache", xy=(caches[1], 10**4), color=ALMOST_BLACK, ha="right", rotation="90")
    # ax.annotate(text="L2 cache", xy=(caches[2], 10**4), color=ALMOST_BLACK, ha="right", rotation="90")
    # ax.annotate(text="L3 cache", xy=(caches[3], 10**4), color=ALMOST_BLACK, ha="right", rotation="90")
    
    fig.tight_layout()
    fig.savefig(folder + file_name +'.png')


if __name__ == "__main__":
    # make_plot("./NewRun/OFast_11989103.out", "OFast_11989103.out")
    # make_plot("./NewRun/O3_11989083.out", "O3_11989083.out")
    # make_plot("./NewRun/O3Fun_11989099.out", "O3Fun_11989099.out")
    # make_plot("./NewRun/DefaultBLK_11989114.out", "DefaultBLK_11989114.out")
    # make_plot("./NewRun/OFastFunroll_11989079.out", "OFastFunroll_11989079.out")
    # make_plot("./NewRun/OFastFunrollBLK_11989078.out", "OFastFunrollBLK_11989078.out")
    make_plot("./BLK/NothingBLK_11989927.out","DefaultBLK_11989927.out")
    make_plot("./BLK/OfastFunBLK_11989929.out","OfastFunBLK_11989929.out")