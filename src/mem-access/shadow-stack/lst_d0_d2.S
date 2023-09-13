#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 2
# Should:      fail
# 
# Shadow stack loads/stores should NOT access
# domain 2 data from domain 0 (code domain error)
#


test_start:
    /* Load the address of the domain 2 data */
    la  t1, data_region2
    lst t2, 40(t1)
    ret
