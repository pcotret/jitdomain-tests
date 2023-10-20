#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 1
# Accesses:    domain 0
# Should:      fail
# 
# Base ret should not be used to change domain
#


.section .text.dom0_code

test_start:
    /* Load the address of the test in dom1 */
    addi sp, sp, -8
    sd ra, 8(sp)
    la t1, test_start_dom1
    auipc ra, 0
    addi  ra, ra, 12
    chdom
    la t3, data_region1
    lb1 t2, 40(t3)
    ld ra, 8(sp)
    addi sp, sp, 8
    ret

.section .text.dom1_code

test_start_dom1:
    ret
