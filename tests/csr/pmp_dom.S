#include "csr_test_setup.S"

.section .text

# Test Description :
# \__________________
#
# PMP:     Passing > Correct permissions
# DMP:     Passing > Correct data domain
# Should:  Pass
# 

.section .text.dom0_code

test_start:
    /* Jump to domain 1 */
    addi sp, sp, -8
    sd ra, 8(sp)
    la t1, test_start_dom1
    chdom
    ld ra, 8(sp)
    addi sp, sp, 8
    ret

.section .text.dom1_code

test_start_dom1:
    /* Load the address of the domain 1 data */
    la  t1, data_region1
    lb1 t2, 40(t1)  # Correct data domain and correct pmp rights
    retdom
