#include "test_setup.S"

.section .text


# Test Description :
# \__________________
# 
# This test is a disassembly test to check the sanity of the toolchain.
# It should not be actually ran!

test_start:
    
    lb1  a0, 8(s2)
    lbu1 a0, 8(s2)
    lh1  a0, 8(s2)
    lhu1 a0, 8(s2)
    lw1  a0, 8(s2)
    lwu1 a0, 8(s2)
    ld1  a0, 8(s2)
    lst  a0, 8(s2)
    
    sb1 a0, 8(s2)
    sh1 a0, 8(s2)
    sw1 a0, 8(s2)
    sd1 a0, 8(s2)
    sst a0, 8(s2)

    chdom
    retdom
