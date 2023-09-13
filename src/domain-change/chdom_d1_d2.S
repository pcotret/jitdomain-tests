#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 1
# Accesses:    domain 2
# Should:      fail
# 
# chdom should NOT be used between domain 1
# and domain 2 (code error)
#


test_start:
    /* Jump to domain 1 */
    la t1, test_start_dom1
    chdom
    ret

test_start_dom1:
    /* Load the address of the domain 2 code (non existent so data */
    la  t1, data_region2
    chdom
    retdom
