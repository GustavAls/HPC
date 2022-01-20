import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

sns.set(style="ticks", context="notebook")

FIGURE_FOLDER = "figures/"
DATA_FOLDER = "experiments/"

def load_data(filename):
    iterations = 10000
    data = pd.read_csv(filename ,delim_whitespace=True, header=None, names=["N", "wall"])
    data["iter_per_sec"] = iterations / data["wall"]
    data["flops"] = 12*data["N"]**3 * data["iter_per_sec"] 
    data["Gflops"] = data["flops"]*1e-9
    # data["speedup"] = [data.query(f"threads == 1 and N == {row.N}")["wall"].item()/row["wall"] for i, row in data.iterrows()]
    return data

def plot_part6():
    data_1gpu = load_data("poisson_v1/" + DATA_FOLDER + "1gpu.txt")
    data_cpu = load_data("cpu/" + DATA_FOLDER + "cpu.txt")
    data_1gpu["speedup"] = data_cpu["wall"] / data_1gpu["wall"]
    data_cpu["speedup"] = 1

    data = pd.concat((data_1gpu, data_cpu))

    print(data)

    # fig, axs = plt.subplots(ncols=2, figsize=(8, 3), sharey=True)

    # ax = axs[0]
    # ax = sns.lineplot(data=data, x="threads", y=to_plot, hue="N", ax=ax, marker="o")
    # ax.set(
    #     ylabel=ylabel,
    #     xlabel="Number of threads",
    #     title="Unoptimized",
    # )
    # ax.legend(fontsize="small", frameon=False)
    # sns.despine()

    # ax = axs[1]
    # ax = sns.lineplot(data=data_opt, x="threads", y=to_plot, hue="N", ax=ax, marker="o")
    # ax.set(
    #     ylabel=ylabel,
    #     xlabel="Number of threads",
    #     title="Optimized with -O3",
    # )
    # ax.get_legend().remove()
    # sns.despine()

    # fig.tight_layout()
    # plt.show()
    # fig.savefig(FIGURE_FOLDER + plot_file, dpi=500)

if __name__ == "__main__":
    plot_part6()
    # plot_part4("part4_wallclock.pdf", "gauss_omp.txt", "gauss_omp_O3.txt", "wall", "Wallclock time [s]")
    # plot_part4("part4_flops.pdf", "gauss_omp.txt", "gauss_omp_O3.txt", "Gflops", "Gflops")
    