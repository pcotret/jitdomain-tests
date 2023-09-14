#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 1
# Accesses:    domain 1
# Should:      fail
# 
# Base loads/stores should NOT access domain 1
# data from domain 1
#


.section .text.dom0_code

test_start:
    /* Jump to domain 1 */
    la t1, test_start_dom1
    chdom
    ret

.section .text.dom1_code

test_start_dom1:
    /* Load the address of the domain 1 data */
    la  t1, data_region1
    sw  t2, 40(t1)
    retdom
