#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 2
# Shousd:      fail
# 
# Base loads/stores shousd NOT access domain 2
# data from domain 0
#


test_start:
    /* Load the address of the domain 2 data */
    la  t1, data_region2
    sd  t2, 40(t1)
    ret
