`timescale 1ns / 1ps

// alu_control.v
//
// Translates {ALUOp, funct3, funct7[5]} into the 4-bit ALUControl code
// that alu_32bit.v understands.
//
// ALUControl encoding (must match alu_32bit.v exactly):
//   4'b0000  AND
//   4'b0001  OR
//   4'b0010  ADD
//   4'b0100  XOR
//   4'b0110  SUB  (b_inv + c_in = two's complement)
//   4'b1000  SLL  (shift left logical)
//   4'b1001  SRL  (shift right logical)
//
// ALUOp encoding (from main_control.v):
//   2'b00  Load / Store  -> always ADD
//   2'b01  Branch        -> always SUB
//   2'b10  R-type        -> decode funct3 + funct7[5]
//   2'b11  I-type ALU    -> decode funct3 only

module alu_control (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);

    always @(*) begin
        case (ALUOp)

            2'b00: ALUControl = 4'b0010; // Load / Store: ADD

            2'b01: ALUControl = 4'b0110; // Branch: SUB

            2'b10: begin // R-type
                case (funct3)
                    3'b000: ALUControl = funct7[5] ? 4'b0110 : 4'b0010; // SUB : ADD
                    3'b001: ALUControl = 4'b1000; // SLL
                    3'b100: ALUControl = 4'b0100; // XOR
                    3'b101: ALUControl = 4'b1001; // SRL (ignore SRAI for now)
                    3'b110: ALUControl = 4'b0001; // OR
                    3'b111: ALUControl = 4'b0000; // AND
                    default: ALUControl = 4'b0010;
                endcase
            end

            2'b11: begin // I-type ALU (ADDI, XORI, ORI, ANDI, SLLI, SRLI)
                case (funct3)
                    3'b000: ALUControl = 4'b0010; // ADDI
                    3'b001: ALUControl = 4'b1000; // SLLI
                    3'b100: ALUControl = 4'b0100; // XORI
                    3'b101: ALUControl = 4'b1001; // SRLI
                    3'b110: ALUControl = 4'b0001; // ORI
                    3'b111: ALUControl = 4'b0000; // ANDI
                    default: ALUControl = 4'b0010;
                endcase
            end

            default: ALUControl = 4'b0010;
        endcase
    end

endmodule
