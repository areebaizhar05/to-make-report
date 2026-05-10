`timescale 1ns / 1ps

module seven_seg_controller (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] data,  // 16-bit input (4 hex digits)
    output reg  [6:0]  seg,   // 7-segment display segments (active low)
    output reg  [3:0]  an     // Anode signals (active low)
);

    // Refresh counter for multiplexing
    reg [19:0] refresh_counter;
    wire [1:0] led_activating_counter; 

    always @(posedge clk or posedge rst) begin
        if(rst == 1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    
    // The top 2 bits of the 20-bit counter determine which digit is active
    assign led_activating_counter = refresh_counter[19:18];

    reg [3:0] hex_digit;

    // Multiplexer to select active digit
    always @(*) begin
        case(led_activating_counter)
        2'b00: begin
            an = 4'b0111; 
            hex_digit = data[15:12];
        end
        2'b01: begin
            an = 4'b1011; 
            hex_digit = data[11:8];
        end
        2'b10: begin
            an = 4'b1101; 
            hex_digit = data[7:4];
        end
        2'b11: begin
            an = 4'b1110; 
            hex_digit = data[3:0];
        end
        endcase
    end

    // Hex to 7-segment decoder (active low)
    always @(*) begin
        case(hex_digit)
        4'h0: seg = 7'b1000000; // 0
        4'h1: seg = 7'b1111001; // 1
        4'h2: seg = 7'b0100100; // 2
        4'h3: seg = 7'b0110000; // 3
        4'h4: seg = 7'b0011001; // 4
        4'h5: seg = 7'b0010010; // 5
        4'h6: seg = 7'b0000010; // 6
        4'h7: seg = 7'b1111000; // 7
        4'h8: seg = 7'b0000000; // 8
        4'h9: seg = 7'b0010000; // 9
        4'hA: seg = 7'b0001000; // A
        4'hB: seg = 7'b0000011; // b
        4'hC: seg = 7'b1000110; // C
        4'hD: seg = 7'b0100001; // d
        4'hE: seg = 7'b0000110; // E
        4'hF: seg = 7'b0001110; // F
        default: seg = 7'b1111111; // Off
        endcase
    end

endmodule
