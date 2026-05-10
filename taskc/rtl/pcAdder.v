`timescale 1ns / 1ps

// pcAdder.v
// Computes PC + 4 (sequential instruction address).

module pcAdder (
    input  wire [31:0] PC,
    output wire [31:0] PCPlus4
);
    assign PCPlus4 = PC + 4; 
endmodule