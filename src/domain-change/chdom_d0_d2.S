#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 2
# Should:      fail
# 
# chdom can not be used between domain 0
# and domain 2 (data error)
#


test_start:
    /* Jump to domain 0 */
    la t1, test_start_dom2
    chdom
    ret

test_start_dom2:
    retdom
