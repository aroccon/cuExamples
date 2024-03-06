! Copyright (C) HPC WORLD (Prometech Software, Inc. and GDEP Solutions, Inc.) All rights reserved.
!
! module with all the definitons required by cusolverSP
!
module cuSOLVER_SP_QR
  use cudafor
  use cusparse

  enum, bind(C) ! cusolverStatus_t
    enumerator :: CUSOLVER_STATUS_SUCCESS=0
    enumerator :: CUSOLVER_STATUS_NOT_INITIALIZED=1
    enumerator :: CUSOLVER_STATUS_ALLOC_FAILED=2
    enumerator :: CUSOLVER_STATUS_INVALID_VALUE=3
    enumerator :: CUSOLVER_STATUS_ARCH_MISMATCH=4
    enumerator :: CUSOLVER_STATUS_MAPPING_ERROR=5
    enumerator :: CUSOLVER_STATUS_EXECUTION_FAILED=6
    enumerator :: CUSOLVER_STATUS_INTERNAL_ERROR=7
    enumerator :: CUSOLVER_STATUS_MATRIX_TYPE_NOT_SUPPORTED=8
    enumerator::CUSOLVER_STATUS_NOT_SUPPORTED = 9
    enumerator :: CUSOLVER_STATUS_ZERO_PIVOT=10
    enumerator :: CUSOLVER_STATUS_INVALID_LICENSE=11
  end enum

  enum, bind(C) ! cusolverEigType_t
    enumerator :: CUSOLVER_EIG_TYPE_1=1
    enumerator :: CUSOLVER_EIG_TYPE_2=2
    enumerator :: CUSOLVER_EIG_TYPE_3=3
  end enum

  type cusolverSpContext
        type(c_ptr) :: cusolverSpHandle
  end type cusolverSpContext
  type csrqrInfo
    type(c_ptr) :: Info
  end type csrqrInfo
  type cusolverSpHandle
    type(c_ptr) :: SpHandle
  end type cusolverSpHandle

! cusolverSpCreate
  interface
     integer(c_int) function cusolverSpCreate(handle) bind(C,name='cusolverSpCreate')
       import cusolverSpHandle
       type(cusolverSpHandle) :: handle
     end function cusolverSpCreate
  end interface
! cusolverSpDestroy
  interface
     integer(c_int) function cusolverSpDestroy(handle) bind(C,name='cusolverSpDestroy')
       import cusolverSpHandle
       type(cusolverSpHandle), value :: handle
     end function cusolverSpDestroy
  end interface

! cusolverSpCreateCsrqrInfo
  interface
     integer(c_int) function cusolverSpCreateCsrqrInfo(info) bind(C,name='cusolverSpCreateCsrqrInfo')
       import csrqrInfo
       type(csrqrInfo) :: info
     end function cusolverSpCreateCsrqrInfo
  end interface
! cusolverSpDestroyCsrqrInfo
  interface
     integer(c_int) function cusolverSpDestroyCsrqrInfo(info) bind(C,name='cusolverSpDestroyCsrqrInfo')
       import csrqrInfo
       type(csrqrInfo) :: info
     end function cusolverSpDestroyCsrqrInfo
  end interface

!cusolverSpDcsrqrBufferInfoBatched
interface cusolverSpDcsrqrBufferInfoBatched
  integer(c_int) function cusolverSpDcsrqrBufferInfoBatched( cusolver_Hndl, m, n, nnzA, &
     descrA, csrValA, csrRowPtrA, csrColIndA, BatchSize, info, internalDataInBytes, workspaceInBytes ) &
     bind(C,name="cusolverSpDcsrqrBufferInfoBatched")
  use iso_c_binding
  import cusolverSpHandle, cusparseMatDescr, csrqrInfo
  type(cusolverSpHandle), value :: cusolver_Hndl
  type(cusparseMatDescr), value :: descrA
  type(csrqrInfo), value :: info
  integer(c_int), value :: m, n, nnzA, batchSize
  real(c_double), device :: csrValA(*)
!! !pgi$ ignore_tkr (d) csrRowPtrA, (d) csrColIndA
  integer(c_int), device :: csrRowPtrA(*), csrColIndA(*)
!! !pgi$ ignore_tkr (k) internalDataInBytes, (k) workspaceInBytes
  integer(8) :: internalDataInBytes, workspaceInBytes
  end function cusolverSpDcsrqrBufferInfoBatched
end interface cusolverSpDcsrqrBufferInfoBatched


! cusolverSpXcsrqrAnalysis
!interface cusolverSpXcsrqrAnalysis
! integer(c_int) function cusolverSpXcsrqrAnalysis( cusolver_Hndl, m, n, nnzA, &
! descrA, csrRowPtrA, csrColIndA, info ) &
! bind(C,name="cusolverSpXcsrqrAnalysis")
! use iso_c_binding
! import cusolverSpHandle, cusparseMatDescr, csrqrInfo
! type(cusolverSpHandle), value :: cusolver_Hndl
! type(cusparseMatDescr), value :: descrA
! type(csrqrInfo), value :: info
! integer(c_int), value :: m, n, nnzA
!!pgi$ ignore_tkr (d) csrRowPtrA, (d) csrColIndA
! integer(c_int), device :: csrRowPtrA(*), csrColIndA(*)
! end function cusolverSpXcsrqrAnalysis
!end interface cusolverSpXcsrqrAnalysis

! cusolverSpXcsrqrAnalysisBatched
interface cusolverSpXcsrqrAnalysisBatched
  integer(c_int) function cusolverSpXcsrqrAnalysisBatched( cusolver_Hndl, m, n, nnzA, &
                 descrA, csrRowPtrA, csrColIndA, info ) &
                 bind(C,name="cusolverSpXcsrqrAnalysisBatched")
  use iso_c_binding
  import cusolverSpHandle, cusparseMatDescr, csrqrInfo
  type(cusolverSpHandle), value :: cusolver_Hndl
  type(cusparseMatDescr), value :: descrA
  type(csrqrInfo), value :: info
  integer(c_int), value :: m, n, nnzA
!! !pgi$ ignore_tkr (d) csrRowPtrA, (d) csrColIndA
  integer(c_int), device :: csrRowPtrA(*), csrColIndA(*)
  end function cusolverSpXcsrqrAnalysisBatched
end interface cusolverSpXcsrqrAnalysisBatched

! cusolverSpDcsrqrsvBatched
interface cusolverSpDcsrqrsvBatched
  integer(c_int) function cusolverSpDcsrqrsvBatched( cusolver_Hndl, m, n, nnzA, &
                 descrA, csrValA, csrRowPtrA, csrColIndA, b, x, BatchSize, info, pBuffer ) &
                 bind(C,name="cusolverSpDcsrqrsvBatched")
  use iso_c_binding
  import cusolverSpHandle, cusparseMatDescr, csrqrInfo
  type(cusolverSpHandle), value :: cusolver_Hndl
  type(cusparseMatDescr), value :: descrA
  type(csrqrInfo), value :: info
  integer(c_int), value :: m, n, nnzA, Batchsize
  real(c_double), device :: csrValA(*)
!! !pgi$ ignore_tkr (d) csrRowPtrA, (d) csrColIndA
  integer(c_int), device :: csrRowPtrA(*), csrColIndA(*)
  real(c_double), device :: b(*), x(*)
!! !pgi$ ignore_tkr pBuffer
  character(c_char), device :: pBuffer(*)

  end function cusolverSpDcsrqrsvBatched
end interface cusolverSpDcsrqrsvBatched

end module cuSOLVER_SP_QR