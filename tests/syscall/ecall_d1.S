#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 1
# Should:      fail
# 
# ebreak is prohibited in domain1
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
    ecall
    ret
