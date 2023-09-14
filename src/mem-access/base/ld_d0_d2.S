#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 2
# Should:      fail
# 
# Base loads/stores should NOT access domain 2
# data from domain 0 (data error)
#


.section .text.dom0_code

test_start:
    /* Load the address of the domain 2 data */
    la  t1, data_region2
    ld  t2, 40(t1)
    ret
