#
# PMP config registers contains 4 8-bit configs that consist of:
#   7  6  5 4   3  2   1   0
# | L | 00 |  A  | X | W | R
# with: 
# L (lock), X (execute), W (write), R (read) 
# A matching mode (0-OFF, 1-TOR, 2-NA4, 3-NAPOT)

# Note:
# - TOR means Top-of-range, will match an address A between 
#   pmpaddr(i-1) <= A < pmpaddr(i) 
# - NAPOT means Naturally aligned power-of-two, will match an address A  
#   using a base address and a size embedded in the address
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
# ║ //////////////// ║                   ║
# ║ // DOM 0 CODE // ║ PMP3 - RX - TOR   ║═══╗
# ║ //////////////// ║                   ║   ║ TOR points here
# ╠══════════════════╬═══════════════════╣<══╝ 
# ╠══════════════════╬═══════════════════╣
# ║ //////////////// ║                   ║
# ║ //(DOM 0 DATA)// ║ PMP4 - RW - TOR   ║═══╗
# ║ //////////////// ║                   ║   ║ TOR points here
# ╠══════════════════╬═══════════════════╣<══╝ 
# ║    DOM 2 DATA    ║ PMP5 - RW - NAPOT ║
# ╠══════════════════╬═══════════════════╣
# ║ //////////////// ║                   ║
# ║ // DOM 0 DATA // ║ PMP6 - RW - TOR   ║═══╗
# ║ //////////////// ║                   ║   ║ TOR points here
# ╠══════════════════╬═══════════════════╣<══╝ 
# ╚══════════════════╩═══════════════════╝  high address
#
# From linker script:
# _dom0_code_start = 0x80000000;
# _dom1_code_start = 0x80004000;
# _dom1_data_start = 0x80005000;
# _dom0_data_start = 0x80006000;
# _dom2_data_start = 0x80007000;

# PMP Region 0: Domain 0 Code pt1 (TOR)
#define PMP_ADDR0 0x80004000
# > PMPCFG0: 0x8d or 0b1_00_01_1_1_1
#   Locked TOR RWX - | L 00 A  X W R |
# > DMPCFG0: 0x8 or 0b1_0_00
#   Locked Domain0 -| L 0 DOM | 
# Note: needs RWX because tohost is at address 080001000
# Note2: not properly working when moving it into data0

# PMP Region 1: Domain 1 Code (NAPOT)
#define PMP_ADDR1 0x80004000
# > PMPCFG1:  0x9d or 0b1_00_11_1_0_1 
#   Locked NAPOT RX - | L 00 A  X W R |
# > DMPCFG1: 0x9 or 0b1_0_01
#   Locked Domain1 -| L 0 DOM | 

# PMP Region 2: Domain 1 Data (NAPOT)
#define PMP_ADDR2 0x80005000
# > PMPCFG2: 0x9b or 0b1_00_11_0_1_1
#   Locked NAPOT RW -| L 00 A  X W R |
# > DMPCFG2: 0x9 or 0b1_0_01
#   Locked Domain1 -| L 0 DOM | 

# PMP Region 3: Domain 0 Code pt2 (TOR)
#define PMP_ADDR3 0x80006000
# > PMPCFG3: 0x8d or 0b1_00_01_1_0_1 
#   Locked TOR RX  - | L 00 A  X W R |
# > DMPCFG4: 0x8 or 0b1_0_00
#   Locked Domain0 -| L 0 DOM | 

# PMP Region 4: Domain 0 Data pt1 (TOR)
#define PMP_ADDR4 0x80007000
# > PMPCFG4: 0x8b or 0b1_00_01_0_1_1
#   Locked TOR RW  - | L 00 A  X W R |
# > DMPCFG4: 0x8 or 0b1_0_00
#   Locked Domain0 -| L 0 DOM | 

# PMP Region 5: Domain 2 Data (NAPOT)
#define PMP_ADDR5 0x80007000
# > PMPCFG5:  0x9b or 0b1_00_11_0_1_1
#   Locked NAPOT RW - | L 00 A  X W R |
# > DMPCFG5: 0xa or 0b1_0_10
#   Locked Domain2 -| L 0 DOM | 

# PMP Region 6: Domain 0 Data pt2 (TOR)
#define PMP_ADDR6 0xc0000000
# > PMPCFG6: 0x8b or 0b1_00_01_0_1_1
#   Locked TOR RW  - | L 00 A  X W R |
# > DMPCFG6: 0x8 or 0b1_0_00
#   Locked Domain0 -| L 0 DOM | 

# Concatenation of the pmpcfg/dmpcfg:
#define PMP_CONFIG 0x008b9b8b8d9b9d8f
#define DMP_CONFIG 0x0000000008a88998

# All inclusive, no locks
# | L 00 A  X W R | PMPCFG
# | 0 00 01 1 1 1 | 0x0f  <- TOR all inclusive
# | 0 00 11 1 1 1 | 0x1f  <- NAPOT all inclusive
# | L 0 DOM |       DMPCFG
# | 0 0  11 |       0x3
# #define PMP_CONFIG 0x000f1f0f0f1f1f0f
# #define DMP_CONFIG 0x0000000003333333

# Small test
# #define PMP_CONFIG 0x000000000000000f
# #define DMP_CONFIG 0x0000000000000000

#define MASK_MPP_USER_MODE 0xffffe7ff

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

    # Setup PMP Region 0: Domain 0 Code pt1 (TOR)
    li t0, PMP_ADDR0
    srli t0, t0, 2     # Note: addr should be shifted by 2
    csrw pmpaddr0, t0

    # Setup PMP Region 1: Domain 1 Code (NAPOT)
    li t0, PMP_ADDR1
    srli t0, t0, 2     # Note: addr should be shifted by 2
    ori  t0, t0, 0x3f  # Note: napot range corresponds 0x3f=6 1s meaning 2**(6+3) bytes (512)
    csrw pmpaddr1, t0

    # Setup PMP Region 2: Domain 1 Data (NAPOT)
    li t0, PMP_ADDR2
    srli t0, t0, 2     # Note: addr should be shifted by 2
    ori  t0, t0, 0x3f  # Note: napot range corresponds 0x3f=6 1s meaning 2**(6+3) bytes (512)
    csrw pmpaddr2, t0

    # Setup PMP Region 3: Domain 0 Code pt2 (TOR)
    li t0, PMP_ADDR3
    srli t0, t0, 2     # Note: addr should be shifted by 2
    csrw pmpaddr3, t0

    # Setup PMP Region 4: Domain 0 Data pt1 (TOR)
    li t0, PMP_ADDR4
    srli t0, t0, 2     # Note: addr should be shifted by 2
    csrw pmpaddr4, t0

    # Setup PMP Region 5: Domain 2 Data (NAPOT)
    li t0, PMP_ADDR5
    srli t0, t0, 2     # Note: addr should be shifted by 2
    ori  t0, t0, 0x3f  # Note: napot range corresponds 0x3f=6 1s meaning 2**(6+3) bytes (512)
    csrw pmpaddr5, t0

    # Setup PMP Region 6: Domain 0 Data pt2 (TOR)
    li t0, PMP_ADDR6
    srli t0, t0, 2     # Note: addr should be shifted by 2
    csrw pmpaddr6, t0

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