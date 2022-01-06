import sys
from numpy import loadtxt


def make_plot(input_file
            #, output_dir
            ):

    output_file = []

    with input_file as file:
        for l in file:
            output_file.append(l)

    indx_kmn = [i for i in range(len(output_file)) if output_file[i].find('kmn') != -1]


if __name__ == "__main__":
    make_plot("Nothing_11977092.out")