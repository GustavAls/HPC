# Makefile
#
TARGET_J  = poisson_j		# Jacobi
TARGET_GS = poisson_gs		# Gauss-Seidel

SOURCES	= main.c print.c alloc3d.c
OBJECTS	= print.o alloc3d.o initialize_data.o calculate_f.o
MAIN_J	= main_j.o
MAIN_GS = main_gs.o
OBJS_J	= $(MAIN_J) jacobi.o jacobi_reduce.o jacobi_collapse.o
OBJS_GS	= $(MAIN_GS) gauss_seidel.o gauss_seidel_omp.o

# options and settings for the GCC compilers
#
CC	    = gcc
DEFS	= 
OPT    	= -g -Ofast -funroll-loops -std=c99 -fopenmp
IPO		= 
ISA		= 
CHIP	= 
ARCH	= 
PARA	= 
CFLAGS	= $(DEFS) $(ARCH) $(OPT) $(ISA) $(CHIP) $(IPO) $(PARA) $(XOPTS)
LDFLAGS = -lm 

all: $(TARGET_J) $(TARGET_GS) 

$(TARGET_J): $(OBJECTS) $(OBJS_J)
	$(CC) -o $@ $(CFLAGS) $(OBJS_J) $(OBJECTS) $(LDFLAGS)

$(TARGET_GS): $(OBJECTS) $(OBJS_GS)
	$(CC) -o $@ $(CFLAGS) $(OBJS_GS) $(OBJECTS) $(LDFLAGS)

$(MAIN_J):
	$(CC) -o $@ -D_JACOBI $(CFLAGS) -c main.c 

$(MAIN_GS):
	$(CC) -o $@ -D_GAUSS_SEIDEL $(CFLAGS) -c main.c 

clean:
	@/bin/rm -f core *.o *~

realclean: clean
	@/bin/rm -f $(TARGET_J)  $(TARGET_GS)

# DO NOT DELETE

main_j.o: main.c print.h jacobi.h jacobi_reduce.h jacobi_collapse.h
main_gs.o: main.c print.h gauss_seidel.h gauss_seidel_omp.h
print.o: print.h
initialize_data.o: initialize_data.h calculate_f.h
calculate_f.o: calculate_f.h
