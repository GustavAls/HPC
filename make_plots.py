import matplotlib.pyplot as plt
import re

def make_plot(input_file
            #, output_dir
            , file_name: str):

    file_name = file_name.split('_')[0]
    output_file = []
    text = open(input_file, 'rt').read()
    output_file = text.split('\n\n',1)[0]
    output_file = output_file.split('\n')
    # Remove first number from "openblas version"
    output_file = output_file[1:]
    perms = ['kmn', 'knm', 'mkn', 'mnk', 'nkm', 'nmk', 'lib']

    # Make index for each permutation
    idx = dict.fromkeys(perms)
    for p in perms:
        idx[p] = [i for i in range(len(output_file)) if output_file[i].find(p) != -1]

    for i in range(len(output_file)):
        output_file[i] = re.findall("\d+\.\d+", output_file[i])

    # Plot setup
    COLORS = ["tab:red", "tab:blue", "slategrey", "tab:green", "black", "tab:pink", "tab:orange"]
    L0 = 64.0
    L1 = 256.0
    L2 = 30720.0

    # Plot
    plt.figure(figsize=(20,15))
    for i, key in enumerate(idx.keys()):
        plt.plot([float(output_file[i][0]) for i in idx[key]],
                 [float(output_file[i][1]) for i in idx[key]],
                 color = COLORS[i],
                 label = key,
                 lw = 3,
                 marker = "o")
        plt.yscale('log', base=2)
        plt.xscale('log', base=2)
    
    plt.axvline(L0, ls = '--')
    plt.axvline(L1, ls = '--')
    plt.axvline(L2, ls = '--')
    plt.xlabel("Mem usage in kbytes")
    plt.ylabel("Mflop/s")
    plt.legend()
    plt.title("Performance with " + file_name + " compiler")
    plt.savefig(file_name +'.png')


if __name__ == "__main__":
    make_plot("OFast_11988608.out", "OFast_11988608.out")
    make_plot("O3_11980494.out", "O3_11980494.out")
    make_plot("O3Fun_11980527.out", "O3Fun_11980527.out")
    make_plot("Default_11980485.out", "Default_11980485.out")