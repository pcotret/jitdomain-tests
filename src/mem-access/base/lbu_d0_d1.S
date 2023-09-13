#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 1
# Should:      fail
# 
# Base loads/stores should NOT access domain 1
# data from domain 0
#


test_start:
    /* Load the address of the domain 1 data */
    la  t1, data_region1
    lbu t2, 40(t1)
    ret
