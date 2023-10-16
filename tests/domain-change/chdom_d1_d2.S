#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 1
# Accesses:    domain 2
# Should:      fail
# 
# chdom should NOT be used between domain 1
# and domain 2 (code error)
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
    /* Load the address of the domain 2 code (non existent so data) */
    addi sp, sp, -8
    sd ra, 8(sp)
    la  t1, data_region2
    chdom
    ld ra, 8(sp)
    addi sp, sp, 8
    retdom
