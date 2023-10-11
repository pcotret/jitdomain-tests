#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Failing PMP and passing DMP should fail
# 

.section .text.dom0_code

test_start:
    /* Load the address of the domain 1 data */
    li  t1, 0x80005000
    lb  t2, 40(t1)
    ret
