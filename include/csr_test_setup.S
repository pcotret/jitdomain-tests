# PMP Region 0: No rights Domain 2 (TOR)
.equiv PMP_ADDR0, 0x80004000
# > PMPCFG0: 0x88 or 0b1_00_01_0_0_0
#   Locked TOR --  - | L 00 A  X W R |
# > DMPCFG0: 0xa or 0b1_0_10
#   Locked Domain2 -| L 0 DOM | 

# PMP Region 1: No rights Domain 0 (TOR)
.equiv PMP_ADDR1, 0x80005000
# > PMPCFG1: 0x88 or 0b1_00_01_0_0_0
#   Locked TOR --  - | L 00 A  X W R |
# > DMPCFG0: 0x8 or 0b1_0_00
#   Locked Domain0 -| L 0 DOM | 

# PMP Region 2: All rights Domain 2 (TOR)
.equiv PMP_ADDR2, 0x80006000
# > PMPCFG2: 0x8f or 0b1_00_01_1_1_1
#   Locked TOR --  - | L 00 A  X W R |
# > DMPCFG0: 0xa or 0b1_0_10
#   Locked Domain2 -| L 0 DOM | 

# PMP Region 3: All rights Domain 0 (TOR)
.equiv PMP_ADDR2, 0x80007000
# > PMPCFG2: 0x8f or 0b1_00_01_1_1_1
#   Locked TOR --  - | L 00 A  X W R |
# > DMPCFG0: 0x8 or 0b1_0_00
#   Locked Domain0 -| L 0 DOM | 

# Concatenation of the pmpcfg:
.equiv PMP_CONFIG, 0x000000008f8f8888
.equiv DMP_CONFIG, 0x0000000000008a8a

.equiv MASK_MPP_USER_MODE, 0xffffe7ff

.section .text

# Note: pmp_setup expects to jump to a user-defined function named
#       test_start once it switched to user-mode!

pmp_setup:
    /* Machine mode setup
    _____________________ */

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

    /* PMP CSR setup
    _____________________ */

    # Setup PMP Region 0: Domain 2 TOR no rights
    li t0, PMP_ADDR0
    srli t0, t0, 2     # Note: addr should be shifted by 2
    csrw pmpaddr0, t0

    # Setup PMP Region 1: Domain 0 TOR no rights
    li t0, PMP_ADDR1
    srli t0, t0, 2     # Note: addr should be shifted by 2
    csrw pmpaddr1, t0

    # Setup PMP Region 2: Domain 2 TOR all rights
    li t0, PMP_ADDR2
    srli t0, t0, 2     # Note: addr should be shifted by 2
    csrw pmpaddr2, t0

    # Setup PMP Region 3: Domain 0 TOR all rights
    li t0, PMP_ADDR3
    srli t0, t0, 2     # Note: addr should be shifted by 2
    csrw pmpaddr3, t0

    # Setup PMP config 
    li t0, PMP_CONFIG
    csrw pmpcfg0, t0

    /* DMP CSR setup
    _____________________ */

    # Setup DMP config 
    li t0, DMP_CONFIG
    csrw dmpcfg0, t0

    /* Setup exit
    _____________________ */

    # Jump to the mepc address (test_start)
    mret

main:
    call pmp_setup         # Call the generated binary
    li a0, 0               # Pass 0 to the exit function
    call exit           