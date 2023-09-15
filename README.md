## Unit tests for JITDomain

Small ASM test suite for the JITDomain instruction-level domain isolation


### Installation

#### Custom toolchain

The `riscv-gnu-toolchain` needs to be patched with our custom instructions. A patching script is given and runs the following steps:
- Clone the [`riscv-gnu-toolchain`](https://github.com/riscv-collab/riscv-gnu-toolchain) repository 
- Patch `binutils`
- Patch `gdb`
- Clean up the repository

**Warning: Cloning and building the whole toolchain takes around 6.65Gb of disk and download space!!!** 

#### Tests

To build and run the different tests, a RISC-V toolchain installation is needed as well as a core Verilator emulator ([Rocket](https://github.com/chipsalliance/rocket-chip) or [CVA6](https://github.com/openhwgroup/cva6) for example):
```bash
export RISCV=/path/to/the/toolchain
export EMULATOR=/path/to/compiled/emulator
```

You can then build the `elf`/`dump`/`core log / vcd` using:

```bash
make bin/<test_name>.elf|dump|corelog|vcd
```

For `mmode_tor2` for example:

```bash
make bin/mmode_tor2.corelog
```

> Note (from [pmpoke](https://github.com/QDucasse/pmpoke)): Intermediate files are deleted by make as the makefile does not explicitely state them..... I'd rather not expand the makefile and specify the needed intermediate file through make directly if needed, (*e.g.* `make bin/mmode_tor2.elf` to access the `elf` file, etc.). If you want to keep all intermediate files, I found that replacing `%` in the following snippets with the actual name will keep them (needs to be duplicated for each new test though 🥱)

> ```make
> bin/%.elf: $(COMS_O) $(bin_dir)/%.o
> 	$(RISCV_GCC) $(RISCV_LINK_OPTS) $^ -o $@
> ```

### Test memory layout

The tests workflow is the following:
- `main`: that stores the `data_region0` address in `s2` and `data_region1` in `s3`
- `pmp_setup`: that fills the `pmpaddri` and `pmpcfgi` registers in M-mode then switches to U-mode for `test_start`.
- `test_start`: the actual tested instructions!

The different `data_regioni` contain the same `data.bin`, a 256-word iteration (0x00000000, 0x00000001, ...). They are `0x100` aligned and usually end up at `0x80000d00`, `0x0x80000e00`, etc. (this can be checked in the dumps!)


### Test recap

Base loads/stores:
```
╔═════════════╦═════════════╦═════════════╦═══════════════╗
║ Instruction ║ Code Domain ║ Data Domain ║    Should     ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣ 
║    l*/s*    ║      0      ║      0      ║     PASS      ║ 
║    l*/s*    ║      1      ║      0      ║     PASS      ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║    l*/s*    ║      0      ║      1      ║  FAIL (data)  ║
║    l*/s*    ║      0      ║      2      ║  FAIL (data)  ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║    l*/s*    ║      1      ║      1      ║  FAIL (data)  ║
║    l*/s*    ║      1      ║      2      ║  FAIL (data)  ║
╚═════════════╩═════════════╩═════════════╩═══════════════╝
```

Duplicated loads/stores:
```
╔═════════════╦═════════════╦═════════════╦═══════════════╗
║ Instruction ║ Code Domain ║ Data Domain ║    Should     ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║   l*1/s*1   ║      1      ║      1      ║     PASS      ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║   l*1/s*1   ║      0      ║      0      ║  FAIL (code)  ║
║   l*1/s*1   ║      0      ║      1      ║  FAIL (code)  ║
║   l*1/s*1   ║      0      ║      2      ║  FAIL (code)  ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║   l*1/s*1   ║      1      ║      0      ║  FAIL (data)  ║
║   l*1/s*1   ║      1      ║      2      ║  FAIL (data)  ║
╚═════════════╩═════════════╩═════════════╩═══════════════╝
```

Shadow-stack loads/stores:
```
╔═════════════╦═════════════╦═════════════╦═══════════════╗
║ Instruction ║ Code Domain ║ Data Domain ║    Should     ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║   lst/sst   ║      1      ║      2      ║     PASS      ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║   lst/sst   ║      0      ║      0      ║  FAIL (code)  ║
║   lst/sst   ║      0      ║      1      ║  FAIL (code)  ║
║   lst/sst   ║      0      ║      2      ║  FAIL (code)  ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║   lst/sst   ║      1      ║      0      ║  FAIL (data)  ║
║   lst/sst   ║      1      ║      1      ║  FAIL (data)  ║
╚═════════════╩═════════════╩═════════════╩═══════════════╝
```

Domain change:
```
╔═════════════╦═════════════╦═════════════╦═══════════════╗
║ Instruction ║ Code Domain ║ Data Domain ║    Should     ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║    chdom    ║      0      ║      1      ║ PASS (+flush) ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║    chdom    ║      0      ║      0      ║  FAIL (data)  ║
║    chdom    ║      0      ║      2      ║  FAIL (data)  ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║    chdom    ║      1      ║      0      ║  FAIL (code)  ║
║    chdom    ║      1      ║      1      ║  FAIL (code)  ║
║    chdom    ║      1      ║      2      ║  FAIL (code)  ║
╚═════════════╩═════════════╩═════════════╩═══════════════╝
```

Domain return:
```
╔═════════════╦═════════════╦═════════════╦═══════════════╗
║ Instruction ║ Code Domain ║ Data Domain ║    Should     ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║   retdom    ║      1      ║      0      ║ PASS (+flush) ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║   retdom    ║      1      ║      1      ║  FAIL (data)  ║
║   retdom    ║      1      ║      2      ║  FAIL (data)  ║
╠═════════════╬═════════════╬═════════════╬═══════════════╣
║   retdom    ║      0      ║      0      ║  FAIL (code)  ║
║   retdom    ║      0      ║      1      ║  FAIL (code)  ║
║   retdom    ║      0      ║      2      ║  FAIL (code)  ║
╚═════════════╩═════════════╩═════════════╩═══════════════╝
```

Config CSR:
```
╔═════════════╦═════════════╦═════════════╗
║   PMPCFG    ║   DMPCFG    ║     EXC     ║
╠═════════════╬═════════════╬═════════════╣
║    FAIL     ║    FAIL     ║ RAISE (PMP) ║
║    FAIL     ║    PASS     ║ RAISE (PMP) ║
║    PASS     ║    FAIL     ║ RAISE (DMP) ║
║    PASS     ║    PASS     ║    PASS     ║
╚═════════════╩═════════════╩═════════════╝
```
