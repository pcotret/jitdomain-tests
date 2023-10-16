#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 2
# Should:      fail
# 
# chdom should NOT be used between domain 0
# and domain 2 (data error)
#


.section .text.dom0_code

test_start:
    /* Jump to domain 0 */
    addi sp, sp, -8
    sd ra, 8(sp)
    la t1, test_start_dom2
    chdom
    ld ra, 8(sp)
    addi sp, sp, 8
    ret

test_start_dom2:
    retdom
