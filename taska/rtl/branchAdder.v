`timescale 1ns / 1ps

// Computes PC + imm

module branchAdder (
    input  wire [31:0] PC,
    input  wire [31:0] imm,
    output wire [31:0] BranchTarget
);
    assign BranchTarget = PC + imm;
endmodule
