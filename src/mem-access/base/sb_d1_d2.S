#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 1
# Accesses:    domain 2
# Should:      fail
# 
# Base loads/stores should NOT access domain 2
# data from domain 1
#


test_start:
    /* Jump to domain 1 */
    la t1, test_start_dom1
    chdom
    ret

test_start:
    /* Load the address of the domain 2 data */
    la  t1, data_region2
    sb  t2, 40(t1)
    ret
