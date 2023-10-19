#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

msg() {
  echo >&2 -e "${1-}"
}

setup_colors

# Cloning submodules (toolchain)
msg "${GREEN}> Updating submodules${NOFORMAT}"
git submodule update --init --recursive
# Patching the two necessary files to add:
# - match/masks
# - CSR info
# - instruction declaration
# - actual instr info
msg "${ORANGE}> Patching binutils${NOFORMAT}"
sed -i  '/#define RISCV_ENCODING_H/ r patch/opch-match-mask.patch' riscv-gnu-toolchain/binutils/include/opcode/riscv-opc.h
sed -i '/#define CSR_PMPADDR63 0x3ef/ r patch/opch-csr.patch' riscv-gnu-toolchain/binutils/include/opcode/riscv-opc.h
sed -i '/#ifdef DECLARE_INSN/ r patch/opch-insn.patch' riscv-gnu-toolchain/binutils/include/opcode/riscv-opc.h
sed -i '/DECLARE_CSR(pmpaddr63, CSR_PMPADDR63, CSR_CLASS_I, PRIV_SPEC_CLASS_1P12, PRIV_SPEC_CLASS_DRAFT)/ r patch/opch-declare-csr.patch' riscv-gnu-toolchain/binutils/include/opcode/riscv-opc.h
sed -i '/MATCH_SUBW, MASK_SUBW, match_opcode, 0 \},/ r patch/opcc.patch' riscv-gnu-toolchain/binutils/opcodes/riscv-opc.c
# Duplicated for gdb
msg "${ORANGE}> Patching gdb${NOFORMAT}"
sed -i  '/#define RISCV_ENCODING_H/ r patch/opch-match-mask.patch' riscv-gnu-toolchain/gdb/include/opcode/riscv-opc.h
sed -i '/#define CSR_PMPADDR63 0x3ef/ r patch/opch-csr.patch' riscv-gnu-toolchain/gdb/include/opcode/riscv-opc.h
sed -i '/#ifdef DECLARE_INSN/ r patch/opch-insn.patch' riscv-gnu-toolchain/gdb/include/opcode/riscv-opc.h
sed -i '/DECLARE_CSR(pmpaddr63, CSR_PMPADDR63, CSR_CLASS_I, PRIV_SPEC_CLASS_1P12, PRIV_SPEC_CLASS_DRAFT)/ r patch/opch-declare-csr.patch' riscv-gnu-toolchain/gdb/include/opcode/riscv-opc.h
sed -i '/MATCH_SUBW, MASK_SUBW, match_opcode, 0 \},/ r patch/opcc.patch' riscv-gnu-toolchain/gdb/opcodes/riscv-opc.c
# Modified toolchain building
msg "${GREEN}> Compiling toolchain${NOFORMAT}"
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv-newlib-jitdomain-test --enable-multilib
sudo make
# Removing the submodule
msg "${RED}> Cleaning toolchain${NOFORMAT}"
cd ..
sudo rm -rf riscv-gnu-toolchain/*
git submodule deinit -f riscv-gnu-toolchain

msg "${GREEN}> Toolchain patched!!${NOFORMAT}"
