`timescale 1ns / 1ps

// main_control.v
//
// Decodes the 7-bit opcode and drives all datapath control signals.
//
// ImmSrc encoding (feeds sign_extend.v):
//   3'b000  I-type  (load, JALR, I-ALU)
//   3'b001  S-type  (store)
//   3'b010  B-type  (branch)
//   3'b011  U-type  (LUI)
//   3'b100  J-type  (JAL)
//
// ALUOp encoding (feeds alu_control.v):
//   2'b00   always ADD  (load/store/LUI address)
//   2'b01   always SUB  (branch compare)
//   2'b10   R-type      (alu_control looks at funct3+funct7)
//   2'b11   I-type ALU  (alu_control looks at funct3 only)

module main_control (
    input  wire [6:0] opcode,
    output reg        RegWrite,
    output reg  [1:0] ALUOp,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        MemtoReg,
    output reg        Branch,
    output reg        Jump,
    output reg        JumpR,
    output reg        LUI,
    output reg        AUIPC,
    output reg        WritePC,
    output reg  [2:0] ImmSrc,
    output reg        InstrValid
);

    always @(*) begin
        // Safe defaults: do nothing
        RegWrite   = 0;
        ALUSrc     = 0;
        MemRead    = 0;
        MemWrite   = 0;
        MemtoReg   = 0;
        Branch     = 0;
        Jump       = 0;
        JumpR      = 0;
        LUI        = 0;
        AUIPC      = 0;
        WritePC    = 0;
        ImmSrc     = 3'b000;
        ALUOp      = 2'b00;
        InstrValid = 0;

        case (opcode)

            7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR, SLL, SRL)
                RegWrite   = 1;
                ALUOp      = 2'b10;
                InstrValid = 1;
                // ImmSrc: don't care (ALUSrc=0, immediate not used)
            end

            7'b0010011: begin // I-type ALU (ADDI, XORI, ORI, ANDI, SLLI, SRLI)
                RegWrite   = 1;
                ALUSrc     = 1;
                ALUOp      = 2'b11;
                ImmSrc     = 3'b000; // I-type immediate
                InstrValid = 1;
            end

            7'b0000011: begin // Load (LW, LH, LB)
                RegWrite   = 1;
                ALUSrc     = 1;
                MemRead    = 1;
                MemtoReg   = 1;
                ALUOp      = 2'b00;
                ImmSrc     = 3'b000; // I-type immediate
                InstrValid = 1;
            end

            7'b0100011: begin // Store (SW, SH, SB)
                ALUSrc     = 1;
                MemWrite   = 1;
                ALUOp      = 2'b00;
                ImmSrc     = 3'b001; // S-type immediate
                InstrValid = 1;
            end

            7'b1100011: begin // Branch (BEQ, BNE)
                Branch     = 1;
                ALUOp      = 2'b01;
                ImmSrc     = 3'b010; // B-type immediate
                InstrValid = 1;
            end

            7'b1101111: begin // JAL
                RegWrite   = 1;
                Jump       = 1;
                WritePC    = 1;      // rd = PC+4 (return address)
                ImmSrc     = 3'b100; // J-type immediate
                InstrValid = 1;
            end

            7'b1100111: begin // JALR
                RegWrite   = 1;
                ALUSrc     = 1;
                ALUOp      = 2'b00;  // ADD: target = rs1 + imm
                JumpR      = 1;      // jump to ALU result
                WritePC    = 1;      // rd = PC+4
                ImmSrc     = 3'b000; // I-type immediate
                InstrValid = 1;
            end

            7'b0110111: begin // LUI
                RegWrite   = 1;
                ALUSrc     = 1;
                ALUOp      = 2'b00;  // ADD: 0 + imm = imm (LUI forces A=0)
                LUI        = 1;
                ImmSrc     = 3'b011; // U-type immediate
                InstrValid = 1;
            end

            7'b0010111: begin // AUIPC
                RegWrite   = 1;
                ALUSrc     = 1;
                ALUOp      = 2'b00;  // ADD: PC + imm (AUIPC forces A=PC)
                AUIPC      = 1;
                ImmSrc     = 3'b011; // U-type immediate
                InstrValid = 1;
            end

            default: begin
                // All signals already set to 0 in defaults above
                InstrValid = 0;
            end

        endcase
    end

endmodule
