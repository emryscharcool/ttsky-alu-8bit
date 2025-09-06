#=========================================================
# Author   : Emrys Leowhel Oling
# Date     : 2025-09-07
# Design   : Cocotb ADD-only testbench for 4-bit ALU wrapper
# License  : MIT
# DUT      : tt_um_wrapper
# Mapping  : ui_in[3:0]=A, ui_in[7:4]=B, uio_in[3:0]=ALU_Sel
#            uo_out[7]=C, [6]=Z, [5]=N, [4]=O, [3:0]=ALU_Out
#=========================================================

import cocotb
from cocotb.triggers import Timer
import random

ADD_SEL = 0b0000  # opcode for ADD

def add4(a: int, b: int):
    a &= 0xF
    b &= 0xF
    full = a + b            # up to 5 bits
    res  = full & 0xF
    carry = (full >> 4) & 1

    # Flags
    zero = 1 if res == 0 else 0
    negative = (res >> 3) & 1

    # Signed overflow (two's complement)
    # overflow = (~(a ^ b) & (a ^ res)) MSB
    overflow = ((~(a ^ b) & (a ^ res)) >> 3) & 1

    return res, carry, zero, negative, overflow

