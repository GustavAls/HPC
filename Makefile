TARGET	= libmatmult.so
LIBSRCS	= matmult_lib.c matmult_nat.c
LIBOBJS	= $(LIBSRCS:.c=.o)

OPT	= -g 
PIC	= -fPIC

CC	= gcc
CFLAGS= $(OPT) $(PIC) $(XOPTS)

SOFLAGS = -shared 
XLIBS	= -L/usr/lib64/gsl -lcblas # Not sure about this one, maybe -L/usr/lib64/atlas?

$(TARGET): $(LIBOBJS)
	$(CC) -o $@ $(SOFLAGS) $(LIBOBJS) $(XLIBS)

clean:
	@/bin/rm -f core core.* $(LIBOBJS) 
