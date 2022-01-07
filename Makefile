TARGET	= libmatmult.so
LIBSRCS	= matmult_lib.c matmult_nat.c cblast.h \
		  matmult_kmn.c matmult_knm.c matmult_mkn.c \
		  matmult_mnk.c matmult_nkm.c matmult_nmk.c \
		  matmult_blk.c
LIBOBJS	= $(LIBSRCS:.c=.o)

OPT	= -g 
PIC	= -fPIC

CC	= gcc -std=gnu99
CFLAGS= $(OPT) $(PIC) $(XOPTS)

SOFLAGS = -shared 
XLIBS	= -L/usr/lib64/atlas -lsatlas

$(TARGET): $(LIBOBJS)
	$(CC) -o $@ $(SOFLAGS) $(LIBOBJS) $(XLIBS)

clean:
	@/bin/rm -f core core.* $(LIBOBJS) 
