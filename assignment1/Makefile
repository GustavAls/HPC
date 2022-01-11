TARGET	= libmatmult.so
LIBSRCS	= matmult_lib.c matmult_nat.c \
		  matmult_kmn.c matmult_knm.c matmult_mkn.c \
		  matmult_mnk.c matmult_nkm.c matmult_nmk.c \
		  matmult_blk.c
LIBOBJS	= $(LIBSRCS:.c=.o)

OPT	= -g -Ofast -funroll-loops -flto -std=gnu99 
PIC	= -fPIC

CC	= gcc
CFLAGS= $(OPT) $(PIC) $(XOPTS)

SOFLAGS = -shared 
XLIBS	= -L/usr/lib64/atlas -lsatlas

$(TARGET): $(LIBOBJS)
	$(CC) -o $@ $(CFLAGS) $(SOFLAGS) $(LIBOBJS) $(XLIBS)

clean:
	@/bin/rm -f core core.* $(LIBOBJS) 
