#=========================================================
# Author   : Emrys Leowhel Oling
# Date     : 2025-09-07
# Design   : Cocotb Testbench for 4-bit ALU with Flags
# License  : Apache License 2.0
#=========================================================

import cocotb
from cocotb.triggers import Timer


def compute_flags(A, B, sel, result):
    """Compute expected ALU flags for 4-bit operations"""
    carry = 0
    overflow = 0
    zero = 1 if result == 0 else 0
    negative = (result >> 3) & 1  # MSB of result

    if sel == 0b0000:  # ADD
        full = A + B
        carry = 1 if full > 0b1111 else 0
        overflow = 1 if (((A ^ result) & (B ^ result)) & 0b1000) else 0

    elif sel == 0b0001:  # SUB
        full = (A - B) & 0x1F  # 5 bits to catch borrow
        carry = 1 if (A < B) else 0
        overflow = 1 if (((A ^ B) & (A ^ result)) & 0b1000) else 0

    return carry, zero, negative, overflow


# Define test vectors: (A, B, ALU_Sel, expected_result)
TEST_VECTORS = [
    (0b0011, 0b0001, 0b0000, 0b0100),  # ADD: 3+1=4
    (0b1000, 0b1000, 0b0000, 0b0000),  # ADD: 8+8=16 => result=0, carry=1, overflow=1
    (0b0100, 0b0010, 0b0001, 0b0010),  # SUB: 4-2=2
    (0b0010, 0b0100, 0b0001, 0b1110),  # SUB: 2-4=-2 (two's comp = 14)
    (0b0100, 0b1000, 0b0001, 0b1100),  # SUB: 4-8=-4 (two's comp = 14)
    (0b0011, 0b0010, 0b1000, 0b0010),  # AND: 3&2=2
    (0b0101, 0b0011, 0b1001, 0b0111),  # OR: 5|3=7
    (0b0101, 0b0011, 0b1010, 0b0110),  # XOR: 5^3=6
    (0b0111, 0b0111, 0b1111, 0b0001),  # EQ: 7==7 → 1
]


@cocotb.test()
async def alu_vector_test(dut):
    """Run test vectors on the ALU and check outputs + flags"""

    for A, B, sel, expected in TEST_VECTORS:

        # Apply inputs
        dut.ui_in.value = (B << 4) | A  # [7:4]=B, [3:0]=A
        dut.uio_in.value = sel          # ALU_Sel

        await Timer(2, units="ns")

        uo_val = dut.uo_out.value.integer
        alu_out = uo_val & 0xF        # [3:0] = ALU result
        carry   = (uo_val >> 7) & 1   # bit 7
        zero    = (uo_val >> 6) & 1   # bit 6
        negative= (uo_val >> 5) & 1   # bit 5
        overflow= (uo_val >> 4) & 1   # bit 4

        # Compute expected flags
        exp_carry, exp_zero, exp_negative, exp_overflow = compute_flags(A, B, sel, expected)

        # Check result
        assert alu_out == expected, \
            f"[FAIL] A={A}, B={B}, Sel={sel:04b}: Got Out={alu_out:04b}, Exp={expected:04b}"

        # Check flags
        assert carry == exp_carry, f"Carry mismatch: got {carry}, expected {exp_carry}"
        assert zero == exp_zero, f"Zero mismatch: got {zero}, expected {exp_zero}"
        assert negative == exp_negative, f"Negative mismatch: got {negative}, expected {exp_negative}"
        assert overflow == exp_overflow, f"Overflow mismatch: got {overflow}, expected {exp_overflow}"

        dut._log.info(
            f"[PASS] A={A:04b}, B={B:04b}, Sel={sel:04b} "
            f"=> Out={alu_out:04b}, Flags CZN0={carry}{zero}{negative}{overflow}"
        )

