#update according to the nvhpc release available
NVARCH=Linux_x86_64; export NVARCH
NVCOMPILERS=/opt/nvidia/hpc_sdk; export NVCOMPILERS
MANPATH=$MANPATH:$NVCOMPILERS/$NVARCH/23.7/compilers/man; export MANPATH
PATH=$NVCOMPILERS/$NVARCH/23.7/compilers/bin:$PATH; export PATH
export PATH=$NVCOMPILERS/$NVARCH/23.7/comm_libs/mpi/bin:$PATH
export MANPATH=$MANPATH:$NVCOMPILERS/$NVARCH/23.7/comm_libs/mpi/man
nvfortran -Minfo=accel -fast -gpu=managed -acc -cudalib  poissonfast.f90 -L/usr/local/cuda/lib64 -lcufft


