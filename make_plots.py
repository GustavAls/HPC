import matplotlib.pyplot as plt
import re

def make_plot(input_file
            #, output_dir
            ):

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
    AOS_COLOR = "tab:red"
    SOA_COLOR = "tab:blue"
    COLORS = ["tab:red", "tab:blue", "slategrey", "tab:green", "black", "tab:pink", "tab:purple"]
    L0 = 64.0
    L1 = 256.0
    L2 = 30720.0

    # Plot
    plt.figure(figsize=(20,15))
    for i, key in enumerate(idx.keys()):
        plt.plot([float(output_file[i][0]) for i in idx[key]],
                 [float(output_file[i][1]) for i in idx[key]],
                 color = COLORS[i],
                 label = key)
        plt.yscale('log', base=2)
        plt.xscale('log', base=2)
    
    plt.axvline(L0, ls = '--')
    plt.axvline(L1, ls = '--')
    plt.axvline(L2, ls = '--')
    plt.xlabel("Mem usage in kbytes")
    plt.ylabel("Mflop/s")
    plt.legend()
    plt.title("Performance with Ofast compiler")
    plt.savefig('Ofast.png')


if __name__ == "__main__":
    make_plot("O3_11980494.out")