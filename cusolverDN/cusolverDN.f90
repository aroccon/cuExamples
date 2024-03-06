program test

use cudafor
use cusolverdn
use iso_c_binding
implicit none
integer, parameter :: n = 3
integer :: gerr,i,j
integer :: lwork
real(c_double), allocatable :: work(:)
type(cusolverDnHandle) :: cusolver_handle
real(c_double), allocatable :: a(:,:), b(:), x(:)
integer, parameter :: lda=n
integer :: ipiv(n)
integer :: devinfo(1)

gerr=0

gerr = gerr + cusolverDnCreate(cusolver_handle)
if(gerr .ne. 0) print *, "cusolverDnCreate error:", gerr

! Allocate memory for matrices and vectors
  allocate(A(n,n), b(n), x(n))

!General steps
! 1. create handle
! 2. create buffer (work)
! 3. Compute LU factorization
! 4. Solve the system
! 5 remove handle

! Initialize A and B (just for example, you should fill them with appropriate values)

!do i = 1,n
!   b(i) = real(i, kind=c_double)
!   do j = 1, n
!      A(i,j) = real(i + j, kind=c_double)
!   end do
!end do

!           [A]         [x]  =    [B]
!    | 1.0  2.0  3.0 | |x1|    | 1.0|
!    | 4.0  5.0  6.0 | |x2| =  | 2.0|
!    | 7.0  8.0 10.0 | |x3|    | 3.0|

a(1,1) = 1.0d0
a(1,2) = 2.0d0
a(1,3) = 3.0d0
a(2,1) = 4.0d0
a(2,2) = 5.0d0
a(2,3) = 6.0d0
a(3,1) = 7.0d0
a(3,2) = 8.0d0
a(3,3) = 10.0d0

b(1) = 1.0d0
b(2) = 2.0d0
b(3) = 3.0d0

!This function calculates the buffer sizes needed for the device workspace passed into cusolverDnDgetrf
!$acc data copy(A)
!$acc host_data use_device(A)
gerr = gerr + cusolverDnDgetrf_bufferSize(cusolver_handle, n, n, A, lda, lwork)
if(gerr .ne. 0) write(*,*)  "Buffer error", gerr
!$acc end host_data 
!$acc end data 

allocate(work(lwork))

ipiv(1)=3
ipiv(2)=3
ipiv(3)=3

!This function computes the LU factorization of a general mxn matrix
!$acc data copy(A,work,ipiv,devinfo)
!$acc host_data use_device(A,ipiv,work,devinfo)
gerr = gerr + cusolverDnDgetrf(cusolver_handle, n, n, A, lda, work, ipiv, devinfo(1))
!$acc end host_data 
!$acc end data

write(*,*) "GETRF status", gerr

!This function solves the system of linear equations resulting from the LU factorization of a matrix using cusolverDnDgetrf (step before)
!$acc data copy(A,b,ipiv,devinfo)
!$acc host_data use_device(A,b,ipiv,devinfo)
gerr = gerr + cusolverDnDgetrs(cusolver_handle, CUBLAS_OP_N, n, 1, A, lda, ipiv, b, n, devinfo(1))
!$acc end host_data 
!$acc end data

write(*,*) "GETRS status", gerr

!Copy solution back to X (is stored in b instead of the rhs)
!$acc kernels
x=b
!$acc end kernels  

write(*,*) "Solution is x", x

! clean memory
deallocate(a,b,x,work)

 gerr = gerr + cusolverDnDestroy(cusolver_handle)
 if(gerr .ne. 0) print *, "cusolverDnDestroy error:", gerr

end program