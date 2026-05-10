`timescale 1ns / 1ps
module alu_32bit(
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUControl,
    output [31:0] ALUResult,
    output        Zero
);

    // --- Control Decoder ---
    // Translates standard RISC-V ALUControl into the internal lines for the 1-bit slices
    reg a_inv, b_inv, c_in;
    reg [1:0] op;
    reg is_shift, is_srl;

    always @(*) begin
        // Default values
        a_inv = 0; b_inv = 0; c_in = 0; op = 2'b00; 
        is_shift = 0; is_srl = 0;

        case (ALUControl)
            4'b0000: begin op = 2'b00; end // AND
            4'b0001: begin op = 2'b01; end // OR
            4'b0010: begin op = 2'b10; end // ADD
            4'b0110: begin b_inv = 1; c_in = 1; op = 2'b10; end // SUB (Invert B, Add 1)
            4'b0100: begin op = 2'b11; end // XOR
            4'b1000: begin is_shift = 1; is_srl = 0; end // SLL
            4'b1001: begin is_shift = 1; is_srl = 1; end // SRL
            default: begin op = 2'b00; end
        endcase
    end

    // --- The Ripple Carry ALU Chain (From your picture) ---
    wire [31:0] ripple_result;
    wire [31:0] carry;
    wire set_wire;

    // ALU 0
    alu_1bit alu0(
        .a(A[0]), .b(B[0]), .a_invert(a_inv), .b_invert(b_inv), .cin(c_in), 
        .less(set_wire), .operation(op), .res(ripple_result[0]), .cout(carry[0]), .set()
    );

    // ALUs 1 through 30
    genvar i;
    generate
        for (i = 1; i < 31; i = i + 1) begin : alu_chain
            alu_1bit alu_inst(
                .a(A[i]), .b(B[i]), .a_invert(a_inv), .b_invert(b_inv), .cin(carry[i-1]), 
                .less(1'b0), .operation(op), .res(ripple_result[i]), .cout(carry[i]), .set()
            );
        end
    endgenerate

    // ALU 31
    alu_1bit alu31(
        .a(A[31]), .b(B[31]), .a_invert(a_inv), .b_invert(b_inv), .cin(carry[30]), 
        .less(1'b0), .operation(op), .res(ripple_result[31]), .cout(carry[31]), .set(set_wire)
    );

    // --- The Shifter ---
    wire [31:0] shift_result;
    shifter_32bit shift_inst(
        .in(A), .shamt(B[4:0]), .is_srl(is_srl), .out(shift_result)
    );

    // --- Final Output Mux & Zero Flag ---
    assign ALUResult = is_shift ? shift_result : ripple_result;
    assign Zero = (ALUResult == 32'd0) ? 1'b1 : 1'b0;

endmodule