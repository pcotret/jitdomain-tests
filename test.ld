/*======================================================================*/
/* Proxy kernel linker script                                           */
/*======================================================================*/
/* This is the linker script used when building the proxy kernel. */

/*----------------------------------------------------------------------*/
/* Setup                                                                */
/*----------------------------------------------------------------------*/

/* The OUTPUT_ARCH command specifies the machine architecture where the
   argument is one of the names used in the BFD library. More
   specifically one of the entires in bfd/cpu-mips.c */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

/*----------------------------------------------------------------------*/
/* Sections                                                             */
/*----------------------------------------------------------------------*/

/* The memory layout of all tests is the following:                     */
/*                                                                      */
/* ╔══════════════════╦═══════════════════╗  low address                */
/* ║ //////////////// ║                   ║                             */
/* ║ // DOM 0 CODE // ║ PMP0 - RX - TOR   ║═══╗                         */
/* ║ //////////////// ║                   ║   ║ TOR points here         */
/* ╠══════════════════╬═══════════════════╣<══╝                         */
/* ║    DOM 1 CODE    ║ PMP1 - RX - NAPOT ║                             */
/* ╠══════════════════╬═══════════════════╣                             */
/* ║    DOM 1 DATA    ║ PMP2 - RW - NAPOT ║                             */
/* ╠══════════════════╬═══════════════════╣                             */
/* ║ //////////////// ║                   ║                             */
/* ║ // DOM 0 CODE // ║ PMP3 - RX - TOR   ║═══╗                         */
/* ║ //////////////// ║                   ║   ║ TOR points here         */
/* ╠══════════════════╬═══════════════════╣<══╝                         */
/* ╠══════════════════╬═══════════════════╣                             */
/* ║ //////////////// ║                   ║                             */
/* ║ //(DOM 0 DATA)// ║ PMP4 - RW - TOR   ║═══╗                         */
/* ║ //////////////// ║                   ║   ║ TOR points here         */
/* ╠══════════════════╬═══════════════════╣<══╝                         */
/* ║    DOM 2 DATA    ║ PMP5 - RW - NAPOT ║                             */
/* ╠══════════════════╬═══════════════════╣                             */
/* ║ //////////////// ║                   ║                             */
/* ║ // DOM 0 DATA // ║ PMP6 - RW - TOR   ║═══╗                         */
/* ║ //////////////// ║                   ║   ║ TOR points here         */
/* ╠══════════════════╬═══════════════════╣<══╝                         */
/* ╚══════════════════╩═══════════════════╝  high address               */


_dom0_code_start = 0x80003000;
_dom1_code_start = 0x80004000;
_dom1_data_start = 0x80005000;
_dom0_data_start = 0x80006000;
_dom2_data_start = 0x80007000;


SECTIONS
{

  /* text: test code section */
  . = 0x80000000;
  .text.init : { *(.text.init) }

  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }

  . = ALIGN(0x1000);
  .text : { *(.text) }

  /* domain code start */
  . = _dom0_code_start;
  .text.dom0_code : { *(.text.dom0_code) }

  . = _dom1_code_start;
  .text.dom1_code : { *(.text.dom1_code) }

  /* data segment */
  . = ALIGN(0x100);
  .data : { *(.data) }

  /* domain data start */
  . = _dom1_data_start;
  .data.dom1_data : { *(.data.dom1_data) }

  . = _dom0_data_start;
  .data.dom0_data : { *(.data.dom0_data) }

  . = _dom2_data_start;
  .data.dom2_data : { *(.data.dom2_data) }


  .sdata : {
    __global_pointer$ = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  }

  /* bss segment */
  .sbss : {
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  }
  .bss : { *(.bss) }

  /* thread-local data segment */
  .tdata :
  {
    _tdata_begin = .;
    *(.tdata)
    _tdata_end = .;
  }
  .tbss :
  {
    *(.tbss)
    _tbss_end = .;
  }

  /* End of uninitalized data segment */
  _end = .;
}

