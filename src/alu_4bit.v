//=========================================================
// Author   : Emrys Leowhel Oling
// Date     : 2025-09-07
// Design   : 4-bit ALU with Flags (no always @ block)
// Purpose  : For TTsky25a ALU (Tiny Tapeout project)
// License  : APACHE-2.0
//=========================================================

`default_nettype none
`timescale 1ns/1ns

module alu_4bit (
    input  [3:0] A,          // First operand
    input  [3:0] B,          // Second operand
    input  [3:0] ALU_Sel,    // Operation select
    output [3:0] ALU_Out,    // ALU result

    // Status flags
    output Carry,       
    output Zero,        
    output Negative,    
    output Overflow     
);

    wire [4:0] add_tmp  = A + B;
    wire [4:0] sub_tmp  = A - B;
    wire [7:0] mul_tmp  = A * B;  // widen to avoid truncation
    wire [3:0] div_tmp  = (B != 0) ? (A / B) : 4'hF;

    // ALU result (muxed)
    assign ALU_Out =
        (ALU_Sel == 4'b0000) ? add_tmp[3:0] :
        (ALU_Sel == 4'b0001) ? sub_tmp[3:0] :
        (ALU_Sel == 4'b0010) ? mul_tmp[3:0] :
        (ALU_Sel == 4'b0011) ? div_tmp :
        (ALU_Sel == 4'b0100) ? (A << 1) :
        (ALU_Sel == 4'b0101) ? (A >> 1) :
        (ALU_Sel == 4'b0110) ? {A[2:0], A[3]} : 
        (ALU_Sel == 4'b0111) ? {A[0], A[3:1]} : 
        (ALU_Sel == 4'b1000) ? (A & B) :
        (ALU_Sel == 4'b1001) ? (A | B) :
        (ALU_Sel == 4'b1010) ? (A ^ B) :
        (ALU_Sel == 4'b1011) ? ~(A | B) :
        (ALU_Sel == 4'b1100) ? ~(A & B) :
        (ALU_Sel == 4'b1101) ? ~(A ^ B) :
        (ALU_Sel == 4'b1110) ? ((A > B)  ? 4'd1 : 4'd0) :
        (ALU_Sel == 4'b1111) ? ((A == B) ? 4'd1 : 4'd0) :
        4'h0;

    // Flags
    assign Carry =
        (ALU_Sel == 4'b0000) ? add_tmp[4] :
        (ALU_Sel == 4'b0001) ? sub_tmp[4] :
        (ALU_Sel == 4'b0100) ? A[3] : // shift left
        (ALU_Sel == 4'b0101) ? A[0] : // shift right
        1'b0;

    assign Overflow =
        (ALU_Sel == 4'b0000) ? ((A[3] == B[3]) && (ALU_Out[3] != A[3])) :
        (ALU_Sel == 4'b0001) ? ((A[3] != B[3]) && (ALU_Out[3] != A[3])) :
        1'b0;

    assign Zero     = (ALU_Out == 4'h0);
    assign Negative = ALU_Out[3];

endmodule
