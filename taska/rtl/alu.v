`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 10:20:36 AM
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_1bit(
    input a,
    input b,
    input a_invert,
    input b_invert,
    input cin,
    input less,
    input [1:0] operation, // 00: AND, 01: OR, 10: ADD/SUB, 11: XOR/LESS
    output res,
    output cout,
    output set
);

    wire actual_a, actual_b;
    wire out_and, out_or, out_xor, out_add;

    // Invert inputs if requested
    assign actual_a = a_invert ? ~a : a;
    assign actual_b = b_invert ? ~b : b;

    // Call the Level 1 Primitives
    and_gate  u_and (.a(actual_a), .b(actual_b), .out(out_and));
    or_gate   u_or  (.a(actual_a), .b(actual_b), .out(out_or));
    xor_gate  u_xor (.a(actual_a), .b(actual_b), .out(out_xor));
    full_adder u_fa (.a(actual_a), .b(actual_b), .cin(cin), .sum(out_add), .cout(cout));

    // The 'Set' output is just the sum of the adder, used by ALU31
    assign set = out_add;

    // Output Multiplexer based on 'operation'
    reg out_mux;
    always @(*) begin
        case (operation)
            2'b00: out_mux = out_and;
            2'b01: out_mux = out_or;
            2'b10: out_mux = out_add;
            2'b11: out_mux = out_xor; // We can use this slot for XOR
            default: out_mux = 1'b0;
        endcase
    end

    assign res = out_mux;

endmodule