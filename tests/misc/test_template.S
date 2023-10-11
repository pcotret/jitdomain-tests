#include "test_setup.S"

.section .text

# Memory Layout :
# \_______________
#
# The memory layout of all tests is the following:
# 
# ╔══════════════════╦═══════════════════╗  low address
# ║ //////////////// ║                   ║
# ║ //(DOM 0 CODE)// ║ (defined in PMP2) ║
# ║ //////////////// ║                   ║
# ╠══════════════════╬═══════════════════╣
# ║    DOM 1 CODE    ║ PMP0 - RX - NAPOT ║
# ╠══════════════════╬═══════════════════╣
# ║    DOM 1 DATA    ║ PMP1 - RW - NAPOT ║
# ╠══════════════════╬═══════════════════╣
# ║ //////////////// ║                   ║
# ║ // DOM 0 CODE // ║ PMP2 - RX - TOR   ║═══╗
# ║ //////////////// ║                   ║   ║ TOR points here
# ╠══════════════════╬═══════════════════╣<══╝ 
# ╠══════════════════╬═══════════════════╣
# ║ //////////////// ║                   ║
# ║ //(DOM 0 DATA)// ║ (defined in PMP4) ║
# ║ //////////////// ║                   ║
# ╠══════════════════╬═══════════════════╣
# ║    DOM 2 DATA    ║ PMP3 - RW - NAPOT ║
# ╠══════════════════╬═══════════════════╣
# ║ //////////////// ║                   ║
# ║ // DOM 0 DATA // ║ PMP4 - RW - TOR   ║═══╗
# ║ //////////////// ║                   ║   ║ TOR points here
# ╠══════════════════╬═══════════════════╣<══╝ 
# ╚══════════════════╩═══════════════════╝  high address
#
# Note: see include/pmp_dmp_setup.S for more details!
# 
# Test Description :
# \__________________
# 
# Describe the objective of the test
#
# Important notes:
# \________________
#
# The base test_start lies in the code of the domain0, a test
# starting in this domain can directly be written in test_start.
# If instead it should start from domain1, use the following
# example to jump to domain1!
#
# Important registers:
# \____________________
#
# ╔══════════╦═══════════════╗ 
# ║ s4 (x20) ║ Domain 0 data ║
# ╠══════════╬═══════════════╣
# ║ s5 (x21) ║ Domain 1 data ║
# ╠══════════╬═══════════════╣
# ║ s6 (x22) ║ Domain 2 data ║
# ╚══════════╩═══════════════╝
#
# Note: see include/test_setup.S for more details!


# in Domain 0

.section .text.dom0_code

test_start:
    la t1, test_start_dom1
    chdom
    ret

# in Domain 1

.section .text.dom1_code

test_start_dom1:
    nop
    ret