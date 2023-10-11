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


.section .text.dom0_code

test_start:
    /* Jump to domain 0 */
    la t1, test_start_dom1
    chdom
    ret

.section .text.dom1_code

test_start_dom1:
    retdom
