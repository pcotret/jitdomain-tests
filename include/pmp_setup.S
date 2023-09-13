.equiv PMP_ADDR0, 0x80002d00  # Should be equal to the beginning of data_region0

.equiv PMP_ADDR1, 0x80002e00  # Should be equal to top range of data_region0

.equiv PMP_ADDR2, 0x80002f00  # Should be equal to top range of data_region1

.equiv PMP_CONFIG, 0x00070707

.equiv MASK_MPP_USER_MODE, 0xFFFFE7FF

.section .text

# Note: pmp_setup expects to jump to a user-defined function named
#       test_start once it switched to user-mode!

pmp_setup:
    # Read the mode
    csrr t0, mstatus

    # Setup user mode
    li t1, MASK_MPP_USER_MODE
    and t0, t0, t1             # Set MPP to user mode
    or t0, t0, 8               # Set MIE
    csrw mstatus, t0           # Write the value back to the CSR

    # Setup user mode entry address
    la t0, test_start
    csrw mepc, t0

    # Setup first PMP region
    li t0, PMP_ADDR0
    srli t0, t0, 2    # Note: addr should be shifted by 2
    csrw pmpaddr0, t0

    # Setup second PMP region
    li t0, PMP_ADDR1
    srli t0, t0, 2    # Note: addr should be shifted by 2
    csrw pmpaddr1, t0

    # Setup third PMP region
    li t0, PMP_ADDR2
    srli t0, t0, 2    # Note: addr should be shifted by 2
    csrw pmpaddr2, t0

    # Setup PMP config 
    li t0, PMP_CONFIG
    csrw pmpcfg0, t0

    # Jump to the mepc address (test_start)
    mret