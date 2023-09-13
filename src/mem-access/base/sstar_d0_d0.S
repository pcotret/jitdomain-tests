#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 0
# Should:      pass
# 
# Base loads/stores should access domain 0 data
# from domain 0
#


test_start:
    /* Load the address of the domain 0 data */
    la  t1, data_region0
    sb  t2, 40(t1)
    sh  t2, 40(t1)
    sw  t2, 40(t1)
    sd  t2, 40(t1)
    ret
