#include "test_setup.S"

.section .text

# Test Description :
# \__________________
#
# Executes in: domain 0
# Should:      pass
# 
# ebreak is authorized in domain0
#

.section .text.dom0_code

test_start:
    ecall
    ret
