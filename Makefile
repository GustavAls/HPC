TARGET	= libmatmult.so
LIBSRCS	= 
LIBOBJS	= matmult_lib.o matmult_nat.o 

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
