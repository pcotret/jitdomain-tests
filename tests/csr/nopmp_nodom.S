#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# PMP:     Failing
# DMP:     Failing
# Should:  Fail
# 

.section .text.dom0_code

test_start:
    /* Load the address of the domain 1 data */
    li  t1, 0x80004000
    lb  t2, 40(t1)
    ret
