# Check for RISCV toolchain env variable
ifndef RISCV
$(error Please set environment variable RISCV to your installed toolchain location (i.e. /opt/riscv-newlib))
endif


# Directories
src_dir = src
com_dir = common
inc_dir = include
bin_dir = bin

# Specify flags
XLEN ?= 64
RISCV_PREFIX ?= $(RISCV)/bin/riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -march=rv64g  -mabi=lp64d -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lgcc -T test.ld
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble --full-contents --disassemble-zeroes --section=.text --section=.text.dom0_code --section=.text.dom1_code --section=.text.startup --section=.text.init --section=.data --section=.data.dom1_data --section=.data.dom2_data --section=.data.dom0_data

MAX_CYCLES ?= 100000000

# Define sources
COMS_C=$(wildcard $(com_dir)/*.c) 
COMS_S=$(wildcard $(com_dir)/*.S)
COMS_O=$(patsubst $(com_dir)/%.c,$(bin_dir)/%.o,$(COMS_C)) $(patsubst $(com_dir)/%.S,$(bin_dir)/%.o,$(COMS_S))

# Check info
# $(info COMS_O is $(COMS_O))

default: bin/template.dump

# Headers!
incs  += -I$(com_dir) -I$(inc_dir)

# the objcopy way, the issue with this method is that the labels are auto generated!
# $(bin_dir)/out.o: $(bin_dir)/out.bin
# 	$(RISCV_PREFIX)objcopy -I binary -O elf64-littleriscv -B riscv --rename-section .data=.text $^ $@

csr_dir = $(src_dir)/csr
dom_chg_dir = $(src_dir)/domain-change
base_mem_dir = $(src_dir)/mem-access/base
dup_mem_dir = $(src_dir)/mem-access/duplicated
ss_mem_dir = $(src_dir)/mem-access/shadow-stack
helper_dir = $(src_dir)/helpers

test_dirs = $(csr_dir) $(dom_chg_dir) $(mem_acc_dir) $(helper_dir)

define rv-gcc
$(RISCV_GCC) $(incs) $(RISCV_GCC_OPTS) $< -c -o $@ 
endef

# Generate the object files
bin/%.o: $(com_dir)/%.c
	$(rv-gcc)

bin/%.o: $(com_dir)/%.S
	$(rv-gcc)

bin/%.o: $(csr_dir)/%.S
	$(rv-gcc)

bin/%.o: $(dom_chg_dir)/%.S
	$(rv-gcc)

bin/%.o: $(base_mem_dir)/%.S
	$(rv-gcc)

bin/%.o: $(dup_mem_dir)/%.S
	$(rv-gcc)

bin/%.o: $(ss_mem_dir)/%.S
	$(rv-gcc)

bin/%.o: $(helper_dir)/%.S
	$(rv-gcc)

# Link all the object files, add the corresponding line for 
# everything otherwise it removes intermediate files......................
bin/%.elf: $(COMS_O) $(bin_dir)/%.o
	$(RISCV_GCC) $(RISCV_LINK_OPTS) $^ -o $@


# Dumps
bin/%.dump: $(bin_dir)/%.elf
	$(RISCV_OBJDUMP) $< > $@

# Check for EMULATOR toolchain env variable
emudef: 
ifndef EMULATOR
	$(error Please set environment variable EMULATOR to the emulator (verilator) of your core)
endif

# Core execution
bin/%.corelog: $(bin_dir)/%.elf emudef
	$(EMULATOR) +max-cycles=$(MAX_CYCLES) +verbose $< 2>&1| \
	$(RISCV)/bin/spike-dasm > $@

# Execution and waveform
bin/%.vcd: $(bin_dir)/%.elf emudef
	$(EMULATOR) +max-cycles=$(MAX_CYCLES) +verbose -v $@ $< 2>&1 | \
	$(RISCV)/bin/spike-dasm > bin/out.corelog
	gtkwave $@ -S $(src_dir)/gtkwave_config/config.tcl -r $(src_dir)/gtkwave_config/.gtkwaverc

DUMPS=$(wildcard $(bin_dir)/*.dump)
BINS=$(wildcard $(bin_dir)/*.bin)
ELFS=$(wildcard $(bin_dir)/*.elf)
CORE_LOGS=$(wildcard $(bin_dir)/*.corelog)

.PHONY: clean

clean:
	rm -rf $(wildcard $(bin_dir)/*)