`timescale 1ns / 1ps

// Full adder primitive.
// Used by alu_1bit inside the 32-bit ripple-carry chain.
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule
