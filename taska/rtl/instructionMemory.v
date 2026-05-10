`timescale 1ns / 1ps

module instructionMemory#(
    parameter INIT_FILE = "instruction.mem",
    parameter OPERAND_LENGTH = 31
)(
    input  wire [OPERAND_LENGTH:0] instAddress,
    output reg  [31:0]             instruction
);
    // 32-bit wide memory array, holds 64 instructions
    reg [31:0] memory [0:63];

    // Loads the file automatically 
    initial begin
        $readmemh(INIT_FILE, memory);
    end

    // Fetches the instruction. 
    // Since PC counts by 4 (0, 4, 8...), shifting right by 2 divides it by 4
    // to get the correct array index (0, 1, 2...).
    always @(*) begin
        instruction = memory[instAddress >> 2]; 
    end
endmodule