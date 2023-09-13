#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Accesses:    domain 1
# Should:      pass
# 
# chdom SHOULD be used between domain 0
# and domain 1!
#


test_start:
    /* Jump to domain 0 */
    la t1, test_start_dom1
    chdom
    ret

test_start_dom1:
    retdom
