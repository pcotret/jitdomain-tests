#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 1
# Accesses:    domain 0
# Should:      pass
# 
# Base loads/stores SHOULD access domain 0 data
# from domain 1
#

test_start:
    la t1, test_start_dom1
    chdom
    ret

test_start_dom1:
    /* Load the address of the domain 0 data */
    la  t1, data_region0
    sb  t2, 40(t1)
    sh  t2, 40(t1)
    sw  t2, 40(t1)
    sd  t2, 40(t1)
    retdom
