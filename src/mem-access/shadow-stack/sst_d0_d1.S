#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 1
# Should:      fail
# 
# Shadow stack loads/stores should NOT access
# domain 1 data from domain 0 (code domain error)
#


.section .text.dom0_code

test_start:
    /* Load the address of the domain 1 data */
    la  t1, data_region1
    sst t2, 40(t1)
    ret
