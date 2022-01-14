import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

sns.set(style="ticks", context="notebook")

FIGURE_FOLDER = "figures/"
DATA_FOLDER = "results/"

def load_data(filename):
    iterations = 10000
    data = pd.read_csv(filename ,delim_whitespace=True, header=None, names=["threads", "N", "wall"])
    data["iter_per_sec"] = iterations / data["wall"]
    data["flops"] = 12*data["N"]**3 * data["iter_per_sec"] 
    data["Gflops"] = data["flops"]*1e-9
    data["speedup"] = [data.query(f"threads == 1 and N == {row.N}")["wall"].item()/row["wall"] for i, row in data.iterrows()]
    return data

def plot_part4(plot_file, data_file, data_opt_file, to_plot, ylabel):
    data = load_data(DATA_FOLDER + data_file)
    data_opt = load_data(DATA_FOLDER + data_opt_file)

    fig, axs = plt.subplots(ncols=2, figsize=(8, 3), sharey=True)

    ax = axs[0]
    ax = sns.lineplot(data=data, x="threads", y=to_plot, hue="N", ax=ax, marker="o")
    ax.set(
        ylabel=ylabel,
        xlabel="Number of threads",
        title="Unoptimized",
    )
    ax.legend(fontsize="small", frameon=False)
    sns.despine()

    ax = axs[1]
    ax = sns.lineplot(data=data_opt, x="threads", y=to_plot, hue="N", ax=ax, marker="o")
    ax.set(
        ylabel=ylabel,
        xlabel="Number of threads",
        title="Optimized with -O3",
    )
    ax.get_legend().remove()
    sns.despine()

    fig.tight_layout()
    fig.savefig(FIGURE_FOLDER + plot_file, dpi=500)

if __name__ == "__main__":
    plot_part4("part4_speedup.pdf", "gauss_omp.txt", "gauss_omp_O3.txt", "speedup", "Speedup")
    plot_part4("part4_wallclock.pdf", "gauss_omp.txt", "gauss_omp_O3.txt", "wall", "Wallclock time [s]")
    plot_part4("part4_flops.pdf", "gauss_omp.txt", "gauss_omp_O3.txt", "Gflops", "Gflops")
    