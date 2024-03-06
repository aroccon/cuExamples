! Copyright (C) HPC WORLD (Prometech Software, Inc. and GDEP Solutions, Inc.) All rights reserved.
!
!
program main
  use cusparse
  use cusolver_SP_QR
  implicit none

  integer, parameter :: idbg = 2 ! debug write enable
  integer, parameter :: m = 4, nnzA = 7
  integer, parameter :: batchsize = 4
  integer :: cusolver_status
  integer :: status1, status2, status3, status4, status5
  type(cusolverSpHandle) :: cusolver_Hndl
  type(cusparseMatDescr) :: descrA
  type(csrqrInfo) :: info
  integer :: csrRowPtrA(m+1), csrColIndA(nnzA)
  double precision :: csrValA(nnzA), b(m)
  double precision :: csrValABatch(nnzA*batchsize), bBatch(m*batchsize), xbatch(m*batchsize)
  integer(8) :: size_internal, size_qr
  character(c_char), allocatable :: pBuffer(:)
  !locals
  integer :: i, j, colidx, batchId
  integer::ierr_code
  double precision :: eps, Areg, breg, xreg
  !Result
  integer :: row, baseA, start, end, col
  double precision :: csrValAj
  double precision :: sup_res, r, Ax

  !Random Number
  double precision :: rnd

  ! | 1 |
  ! A = | 2 |
  ! | 3 |
  ! | 0.1 0.1 0.1 4 |
  !
  ! CSR of A is based 1 indexing <==== caution (CUSPARSE_INDEX_BASE_ONE)
  !
  ! b = [1 1 1 1]

! step 1: data setting (Matrix in CRS format)
    csrRowPtrA(1:m+1) = (/1, 2, 3, 4, 8/)
    csrColIndA(1:nnzA) = (/1, 2, 3, 1, 2, 3, 4/)
    csrValA(1:nnzA) = (/1.0d0, 2.0d0, 3.0d0, 0.1d0, 0.1d0, 0.1d0, 4.0d0/)
    b(1:m) = (/1.0d0, 1.0d0, 1.0d0, 1.0d0/)

    print *, "sizeof(csrRowPtrA, csrRowPtrA, csrColIndA, csrColIndA)", &
              sizeof(csrRowPtrA(1)), sizeof(csrRowPtrA(1)), sizeof(csrColIndA(1)), sizeof(csrColIndA(1))

!!call RANDOM_SEED()
! prepare Aj and bj on host
   do colidx = 1, nnzA
        Areg = csrValA(colidx)
        do batchId = 1, batchSize
           call random_number(rnd)
           eps = dble( mod(rnd,100.d0) + 1.0d0 ) * 1.0D-4
           csrValABatch((batchId-1)*nnzA + colidx) = Areg + eps
        enddo
   enddo

   do j = 1, m
        breg = b(j)
        do batchId = 1, batchSize
           call random_number(rnd)
           eps = dble( mod(rnd,100.d0) + 1.0d0 ) * 1.0D-4
           bBatch((batchId-1)*m + j) = breg + eps;
        enddo
   enddo

   xbatch = 0.d0 ! initilize

    if (idbg == 2) print *,"csrValABatch", csrValABatch
    if (idbg == 2) print *,"bBatch", bBatch

! step 2: create cusolver handle, qr info and matrix descriptor

    status1 = cusolverSpCreate(cusolver_Hndl)
          if (idbg == 1) print *, "status1 = ", status1
    status2 = cusparseCreateMatDescr(descrA)
          if (idbg == 1) print *, "status2 = ", status2
    status3 = cusparseSetMatType(descrA, CUSPARSE_MATRIX_TYPE_GENERAL)
          if (idbg == 1) print *, "status3 = ", status3
    status4 = cusparseSetMatIndexBase(descrA, CUSPARSE_INDEX_BASE_ONE) ! base=1
          if (idbg == 1) print *, "status4 = ", status4
    status5 = cusolverSpCreateCsrqrInfo(info)
          if (idbg == 1) print *, "status5 = ", status5

! step 3: copy Aj and bj to device
! Automatic in gpu=managed (openACC)


! step 4: symbolic analysis

!$acc data copyin(csrValABatch, csrColIndA, csrRowPtrA) copyin(bBatch) copyout(xbatch)
!$acc host_data use_device(csrRowPtrA, csrColIndA)
    cusolver_status = cusolverSpXcsrqrAnalysisBatched( &
                      cusolver_Hndl, m, m, nnzA, descrA, csrRowPtrA, csrColIndA, info )
!$acc end host_data

    if (idbg == 1) then
      if (cusolver_status /= CUSOLVER_STATUS_SUCCESS) print *, "step4 cusolver_status = ", cusolver_status
    end if

! step 5: prepare working space

!$acc host_data use_device(csrValABatch, csrRowPtrA, csrColIndA)
    cusolver_status = cusolverSpDcsrqrBufferInfoBatched( &
                      cusolver_Hndl, m, m, nnzA, descrA, csrValABatch, csrRowPtrA, csrColIndA, &
                      batchsize, info, size_internal, size_qr)
!$acc end host_data

    if (idbg == 1) then
      if (cusolver_status /= CUSOLVER_STATUS_SUCCESS) print *, "step5 cusolver_status = ", cusolver_status
    end if

    print *, "numerical factorization needs internal data (bytes) =", size_internal
    print *, "numerical factorization needs working space (bytes) =", size_qr

    allocate(pBuffer(size_qr), stat=ierr_code) ! Bytes
      if (idbg == 1) print *, "step5: alloc ierr_code = ", ierr_code

!$acc enter data copyin(pBuffer)

! step 6: numerical factorization

!$acc host_data use_device(csrValABatch, csrRowPtrA, csrColIndA, bBatch, xbatch, pBuffer)
    cusolver_status = cusolverSpDcsrqrsvBatched( &
                      cusolver_Hndl, m, m, nnzA, &
                      descrA, csrValABatch, csrRowPtrA, csrColIndA, &
                      bBatch, xbatch, &
                      batchSize, &
                      info, &
                      pBuffer)
!$acc end host_data
!$acc exit data delete(pBuffer)
!$acc end data

    if (idbg == 1) then
      if (cusolver_status /= CUSOLVER_STATUS_SUCCESS) print *, "step6 cusolver_status = ", cusolver_status
    end if


! step 7: check residual
!xBatch = [x0, x1, x2, ...]

!copy into CPU mem

    if (idbg == 2) print *, "xbatch=",xbatch

    print *, "******* Fortran Index Base is adjusted : BaseA = 0 ********************* "
    baseA = 0

    print *, " ============ Residual CHECK ==============="
    do batchId = 1 , batchsize
     ! measure |bj - Aj*Xj|
      sup_res = 0.d0
      do row = 1, m
        start = csrRowPtrA(row ) - baseA
        end = csrRowPtrA(row+1) - baseA
        Ax = 0.d0

        do colidx = start, end-1
          col = csrColIndA(colidx) - baseA
          Areg = csrValAbatch((batchId-1)*nnzA + colidx) ! Areg = csrValAj(colidx)
          Xreg = xBatch((batchId-1)*m + col) ! Xreg = xj(col)
          Ax = Ax + Areg * Xreg
        end do

        r = bBatch((batchID-1)*m + row) - Ax ! r = bj(row) -Ax
        ! sup_res = (sup_res > fabs(r))? sup_res : fabs(r);
        sup_res = max( abs(r), sup_res )

      end do
      print *, "batchId =", batchId," sup|bj - Aj*xj| =", sup_res
    end do


    print *, " ============ Result X ==============="
    do batchId = 1 , batchsize
       do row = 1, m
          print *, "x(", batchId, ")= [", row,"]", xBatch((batchId-1)*m + row)
       end do
       print *, ""
    end do
end