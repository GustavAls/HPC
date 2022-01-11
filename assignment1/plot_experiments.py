from matplotlib import rcParams
rcParams['font.sans-serif'] = ['Fira Sans Condensed']
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import pandas as pd
import numpy as np
import seaborn as sns

cmap = plt.get_cmap("tab10")

# Load data
# experiments_folder = "experiments/"

perms = ["kmn", "knm", "mkn", "mnk", "nkm", "nmk", "lib"]
colors = [cmap(i) for i in range(len(perms)-1)] + ["black"]
sizes = [7, 9, 13, 19, 26, 37, 52, 74, 105, 148, 209, 296, 418, 591, 836, 1182, 1672, 2365, 3344]
mems = [2**i for i in range(len(sizes))]

def load_data(experiments_folder, perms, sizes):
    cols = ["excl_cpu", "incl_cpu", "l1_hits", "l1_misses", "l2_hits", "l2_misses", "name", "memory", "size", "perm"]
    df = pd.DataFrame(columns=cols)

    for i, s in enumerate(sizes):
        for p in perms:
            df2 = pd.read_csv(
                experiments_folder + f"{p}{s}.1.txt", 
                delim_whitespace=True, 
                skiprows=5,
                header=None,
                names=["excl_cpu", "incl_cpu", "l1_hits", "l1_misses", "l2_hits", "l2_misses", "name"],
            )
            df2["memory"] = 2**i
            df2["size"] = s
            df2["perm"] = p
            df = df.append([df2.query("name == '<Total>'")])

    df["l1_ratio"] = 100*df["l1_hits"]/(df["l1_hits"]+df["l1_misses"]+1)
    df["l2_ratio"] = 100*df["l2_hits"]/(df["l2_hits"]+df["l2_misses"]+1)

    df = df.sort_values("memory")
    return df

# Plot setup
ALMOST_BLACK = 'slategrey'

L0_cache = 6 # Register file
L1d_cache = 32 # Instruction cache
L1i_cache = 32 # Data cache
L1_cache = L1d_cache + L1i_cache
L2_cache = 256
L3_cache = 30720

caches = np.array([L0_cache, L1_cache, L2_cache, L3_cache])
caches = np.cumsum(caches)

def plot_experiments(df, title, caches):
    # # Plot
    fig, axs = plt.subplots(nrows=2, sharex=True, figsize=(7, 4))

    ax = axs[0]

    for p, c in zip(perms, colors):
        df2 = df.query(f"perm == '{p}'")
        ax.plot(df2["memory"], df2["l1_ratio"], color=c, label=p)
        ax.scatter(df2["memory"], df2["l1_ratio"], color=c, s=10)

    ax.vlines(caches[1:], ymin=0, ymax=100, linestyle="--", color=ALMOST_BLACK)
    ax.annotate(text="L1 cache", xy=(caches[1], 0), color=ALMOST_BLACK, ha="right", rotation="90")
    ax.annotate(text="L2 cache", xy=(caches[2], 0), color=ALMOST_BLACK, ha="right", rotation="90")
    ax.annotate(text="L3 cache", xy=(caches[3], 0), color=ALMOST_BLACK, ha="right", rotation="90")

    ax.set_xscale('symlog', base=2) 
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.set_xticks([])
    ax.set(
        title=title,
        ylabel="L1 hit percentage",
    )
    ax.yaxis.set_major_formatter(mtick.PercentFormatter())

    ax = axs[1]

    for p, c in zip(perms, colors):
        df2 = df.query(f"perm == '{p}' and memory >= 2**6")
        ax.plot(df2["memory"], df2["l2_ratio"], color=c, label=p)
        ax.scatter(df2["memory"], df2["l2_ratio"], color=c, s=10)

    ax.vlines(caches[1:], ymin=0, ymax=100, linestyle="--", color=ALMOST_BLACK)

    ax.set_xscale('symlog', base=2)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.legend(
        fontsize="small",
        framealpha=1,
        edgecolor="white",
        loc="center left",
    )
    ax.set(
        xlim=[2**5, max(mems)],
        ylabel="L2 hit percentage",
        xlabel="Memory footprint [kB]",
    )
    ax.yaxis.set_major_formatter(mtick.PercentFormatter())

    fig.tight_layout()
    return fig

# df_opt = load_data("experiments/")
# fig = plot_experiments(df_opt, "Optimized hit percentages", caches)
# fig.savefig("optimized.pdf")

df_opt = load_data("experiments_opt/", perms, sizes)
fig = plot_experiments(df_opt, "Optimized hit percentages", caches)
fig.savefig("optimized.pdf")

# sizes = [7, 9, 13, 19, 26, 37, 52, 74, 105, 148, 209, 296, 418, 591, 836, 1182, 1672, 2365]
df_unopt = load_data("experiments/", perms, sizes)
fig = plot_experiments(df_unopt, "Un-optimized hit percentages", caches)
fig.savefig("unoptimized.pdf")
