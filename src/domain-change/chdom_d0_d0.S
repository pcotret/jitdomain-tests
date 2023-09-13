#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 0
# Should:      fail
# 
# chdom should NOT be used between domain 0
# and domain 0 (data error)
#


test_start:
    /* Jump to domain 0 */
    la t1, test_landing_dom0
    chdom
    ret

test_landing_dom0:
    retdom