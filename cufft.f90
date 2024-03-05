program test

use openacc
use cuFFT
use iso_c_binding
implicit none
integer :: t,nx,gerr
integer :: cudaplan_fwd,cudaplan_bwd
integer(kind=int_ptr_kind()) :: workSize(1)
real(c_double), allocatable :: p(:,:,:)
complex(c_double_complex), allocatable :: pc(:,:,:)

nx=64

allocate(p(nx,nx,nx))
allocate(pc(nx/2+1,nx,nx))

! Step to use cuFFT
! 1 generate plan handel (create)
! 2 setup plan (make plan)
! 3 exectute plan (perform the FFT)
! 4 destroy plan

p(:,:,:)=2
write(*,*) "p before",p(2,2,2)
!plan is created and destroyed at every iteration, can be optimized saving the plan
!Plan forward
gerr=0
gerr=gerr+cufftCreate(cudaplan_fwd)
gerr=gerr+cufftMakePlan3d(cudaplan_fwd,nx,nx,nx,CUFFT_D2Z,workSize)
if (gerr.ne.0) write(*,*) "Error in cuFFT plan FWD:", gerr


!Plan backward
gerr=0
gerr=gerr+cufftCreate(cudaplan_bwd)
gerr=gerr+cufftMakePlan3d(cudaplan_bwd,nx,nx,nx,CUFFT_Z2D,workSize)
if (gerr.ne.0) write(*,*) "Error in cuFFT plan BWD:", gerr

!$acc data copy(p,pc)
!$acc host_data use_device(p,pc)
gerr = gerr + cufftExecD2Z(cudaplan_fwd,p,pc)
gerr = gerr + cufftExecZ2D(cudaplan_bwd,pc,p)
!$acc end host_data
!$acc end data

! scale c
!$acc kernels
p = p/(nx*nx*nx)
!$acc end kernels

write(*,*) "p after",p(2,2,2)


end program