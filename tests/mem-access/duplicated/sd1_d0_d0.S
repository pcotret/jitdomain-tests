#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 0
# Should:      fail
# 
# Base loads/stores should NOT access domain 0
# data from domain 0 (code error)
#


.section .text.dom0_code

test_start:
    /* Load the address of the domain 0 data */
    la  t1, data_region0
    sd1 t2, 40(t1)
    ret
