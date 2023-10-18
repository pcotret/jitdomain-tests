#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 1
# Should:      fail
# 
# Executing a duplicated load RIGHT AFTER a domain return should
# fail, implying the flush for the current domain was performed
#


.section .text.dom0_code

test_start:
    /* Jump to domain 1 */
    addi sp, sp, -8
    sd ra, 8(sp)
    la t1, test_start_dom1
    auipc ra, 0
    addi  ra, ra, 12
    chdom
    lb1 t2, 40(t3)
    ld ra, 8(sp)
    addi sp, sp, 8
    ret

.section .text.dom1_code

test_start_dom1:
    addi t1, t1, 1         # Pass time for curdom pipeline propagation
    addi t1, t1, -1        # (in case of)
    la t3, data_region1    # Preload address for lb1
    retdom
