#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 0
# Should:      pass
# 
# Base loads/stores SHOULD access domain 0 data
# from domain 0!
#


.section .text.dom0_code

test_start:
    /* Load the address of the domain 0 data */
    la  t1, data_region0
    lb  t2, 40(t1)
    lbu t2, 40(t1)
    lh  t2, 40(t1)
    lhu t2, 40(t1)
    lw  t2, 40(t1)
    lwu t2, 40(t1)
    ld  t2, 40(t1)
    ret
