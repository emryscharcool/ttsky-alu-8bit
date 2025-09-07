//=========================================================
// Author   : Emrys Leowhel Oling
// Date     : 2025-09-07
// Design   : 4-bit ALU with Flags
// Purpose  : For TTsky25a ALU (Tiny Tapeout project)
// License  : APACHE-2.0
//=========================================================

`default_nettype none
`timescale 1ns/1ns

module alu_4bit (
    input  [3:0] A,          // First operand
    input  [3:0] B,          // Second operand
    input  [3:0] ALU_Sel,    // Operation select
    output reg [3:0] ALU_Out,// ALU result

    // Status flags
    output reg Carry,       
    output reg Zero,        
    output reg Negative,    
    output reg Overflow     
);

    reg [4:0] tmp;
    
    always @(*) begin
        // default values to avoid latches
        ALU_Out  = 4'h0;
        Carry    = 1'b0;
        Zero     = 1'b0;
        Negative = 1'b0;
        Overflow = 1'b0;

        case (ALU_Sel)
            // Arithmetic operations
            4'b0000: begin // Addition
                tmp      = A + B;
                ALU_Out  = tmp[3:0];
                Carry    = tmp[4];
                Overflow = (A[3] == B[3]) && (ALU_Out[3] != A[3]);
            end
            4'b0001: begin // Subtraction
                tmp      = A - B;
                ALU_Out  = tmp[3:0];
                Carry    = tmp[4];
                Overflow = (A[3] != B[3]) && (ALU_Out[3] != A[3]);
            end
            4'b0010: ALU_Out = A * B;                      // Multiply
            4'b0011: ALU_Out = (B != 0) ? (A / B) : 4'hF;  // Safe divide

            // Shift/rotate
            4'b0100: begin
                ALU_Out = A << 1; 
                Carry   = A[3];
            end
            4'b0101: begin
                ALU_Out = A >> 1; 
                Carry   = A[0];
            end
            4'b0110: ALU_Out = {A[2:0], A[3]}; // Rotate left
            4'b0111: ALU_Out = {A[0], A[3:1]}; // Rotate right

            // Logical ops
            4'b1000: ALU_Out = A & B;    // AND
            4'b1001: ALU_Out = A | B;    // OR
            4'b1010: ALU_Out = A ^ B;    // XOR
            4'b1011: ALU_Out = ~(A | B); // NOR
            4'b1100: ALU_Out = ~(A & B); // NAND
            4'b1101: ALU_Out = ~(A ^ B); // XNOR

            // Comparison ops
            4'b1110: ALU_Out = (A > B)  ? 4'd1 : 4'd0; 
            4'b1111: ALU_Out = (A == B) ? 4'd1 : 4'd0; 

            default: ALU_Out = 4'h0;
        endcase

        // Common flags
        Zero     = (ALU_Out == 4'h0);
        Negative = ALU_Out[3];
    end

endmodule
