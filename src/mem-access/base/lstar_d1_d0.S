#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 1
# Accesses:    domain 0
# Should:      pass
# 
# Base loads/stores should access domain 0 data
# from domain 1
#


.section .text.dom0_code

test_start:
    /* Jump to domain 1 */
    la t1, test_start_dom1
    chdom
    ret

.section .text.dom1_code

test_start_dom1:
    /* Load the address of the domain 0 data */
    la  t1, data_region0
    lb  t2, 40(t1)
    lbu t2, 40(t1)
    lh  t2, 40(t1)
    lhu t2, 40(t1)
    lw  t2, 40(t1)
    lwu t2, 40(t1)
    ld  t2, 40(t1)
    retdom
