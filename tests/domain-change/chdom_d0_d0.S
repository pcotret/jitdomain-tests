#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 0
# Should:      fail
# 
# chdom should NOT be used between domain 0
# and domain 0 (data error)
#


.section .text.dom0_code

test_start:
    /* Load the address of the test in dom0 */
    addi sp, sp, -8
    sd ra, 8(sp)
    la t1, test_landing_dom0
    chdom
    ld ra, 8(sp)
    addi sp, sp, 8
    ret

test_landing_dom0:
    retdom