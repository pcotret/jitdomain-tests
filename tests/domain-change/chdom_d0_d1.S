#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 1
# Should:      pass
# 
# chdom SHOULD be used between domain 0
# and domain 1!
#


.section .text.dom0_code

test_start:
    /* Load the address of the test in dom1 */
    addi sp, sp, -8
    sd ra, 8(sp)
    la t1, test_start_dom1
    chdom
    ld ra, 8(sp)
    addi sp, sp, 8
    ret

.section .text.dom1_code

test_start_dom1:
    retdom
