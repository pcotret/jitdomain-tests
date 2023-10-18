# Simpler PMP config: dom0 code/data & dom1 code/data
#
# The memory layout of all tests is the following:
# 
# ╔══════════════════╦═══════════════════╗  low address
# ║ //////////////// ║                   ║
# ║ // DOM 0 CODE // ║ PMP0 - RX - TOR   ║═══╗
# ║ //////////////// ║                   ║   ║ TOR points here
# ╠══════════════════╬═══════════════════╣<══╝ 
# ║    DOM 1 CODE    ║ PMP1 - RX - NAPOT ║
# ╠══════════════════╬═══════════════════╣
# ║    DOM 1 DATA    ║ PMP2 - RW - NAPOT ║
# ╠══════════════════╬═══════════════════╣
# ╠══════════════════╬═══════════════════╣
# ║ //////////////// ║                   ║
# ║ //(DOM 0 DATA)// ║ PMP4 - RW - TOR   ║═══╗
# ║ //////////////// ║                   ║   ║ TOR points here
# ╠══════════════════╬═══════════════════╣<══╝ 
# ╚══════════════════╩═══════════════════╝  high address
#
# From linker script:
# _dom0_code_start = 0x80000000;
# _dom1_code_start = 0x80004000;
# _dom1_data_start = 0x80005000;
# _dom0_data_start = 0x80006000;


# PMP Region 0: Domain 0 Code (TOR)
#define PMP_ADDR0 0x80004000
# > PMPCFG0: 0x8f or 0b1_00_01_1_1_1
#   Locked TOR RWX - | L 00 A  X W R |
# > DMPCFG0: 0x8 or 0b1_0_00
#   Locked Domain0 -| L 0 DOM | 
# Note: needs RWX because tohost is at address 080001000
# Note2: not properly working when moving it into data0

# PMP Region 1: Domain 1 Code (NAPOT)
#define PMP_ADDR1 0x80004000
# > PMPCFG1:  0x9c or 0b1_00_11_1_0_0 
#   Locked NAPOT XO - | L 00 A  X W R |
# > DMPCFG1: 0x9 or 0b1_0_01
#   Locked Domain1 -| L 0 DOM | 

# PMP Region 2: Domain 1 Data (NAPOT)
#define PMP_ADDR2 0x80005000
# > PMPCFG2: 0x99 or 0b1_00_11_0_0_1
#   Locked NAPOT RW -| L 00 A  X W R |
# > DMPCFG2: 0x9 or 0b1_0_01
#   Locked Domain1 -| L 0 DOM | 

# PMP Region 3: Domain 0 Data (pt1) (NAPOT)
#define PMP_ADDR3 0x80006000
# > PMPCFG3: 0x99 or 0b1_00_11_0_0_1
#   Locked NAPOT RO -| L 00 A  X W R |
# > DMPCFG3: 0x8 or 0b1_0_00
#   Locked Domain1 -| L 0 DOM | 

# PMP Region 4: Domain 0 Data (TOR)
#define PMP_ADDR4 0xc0000000
# > PMPCFG0: 0x8b or 0b1_00_01_0_1_1
#   Locked TOR RWX - | L 00 A  X W R |
# > DMPCFG0: 0x8 or 0b1_0_00
#   Locked Domain0 -| L 0 DOM | 

# Concatenation of the pmpcfg:
#define PMP_CONFIG 0x0000008b99999c8f
#define DMP_CONFIG 0x0000000000088998

#define MASK_MPP_USER_MODE 0xffffe7ff

.global main

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

    # Setup PMP Region 0: Domain 0 Code (TOR)
    li t0, PMP_ADDR0
    srli t0, t0, 2     # Note: addr should be shifted by 2
    csrw pmpaddr0, t0

    # Setup PMP Region 1: Domain 1 Code (NAPOT)
    li t0, PMP_ADDR1
    srli t0, t0, 2     # Note: addr should be shifted by 2
    ori  t0, t0, 0x3f  # Note: napot range corresponds 0x3f=6 1s meaning 2**(6+3) bytes (512)
    csrw pmpaddr1, t0

    # Setup PMP Region 2: Domain 1 Data (RO) (NAPOT)
    li t0, PMP_ADDR2
    srli t0, t0, 2     # Note: addr should be shifted by 2
    ori  t0, t0, 0x3f  # Note: napot range corresponds 0x3f=6 1s meaning 2**(6+3) bytes (512)
    csrw pmpaddr2, t0

    # Setup PMP Region 3: Domain 0 Data (RO) (NAPOT)
    li t0, PMP_ADDR3
    srli t0, t0, 2     # Note: addr should be shifted by 2
    ori  t0, t0, 0x3f  # Note: napot range corresponds 0x3f=6 1s meaning 2**(6+3) bytes (512)
    csrw pmpaddr3, t0

    # Setup PMP Region 4: Domain 0 Data (RW) (TOR)
    li t0, PMP_ADDR4
    srli t0, t0, 2     # Note: addr should be shifted by 2
    csrw pmpaddr4, t0

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
    la s2, data_region0    # Load the data region 0 address in s2
    la s3, data_region1    #       -              1      -     s3
    call pmp_setup         # Call the generated binary
    li a0, 0               # Pass 0 to the exit function
    call exit              # 

.section .data

.section .data.dom1_data

data_region1:
    .incbin "data/data.bin"

.section .data.dom0_data

data_region0:
    .incbin "data/data.bin"
