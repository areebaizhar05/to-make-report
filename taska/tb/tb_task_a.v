`timescale 1ns / 1ps

module tb_task_a;
    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] led;

    // Task A: Countdown FSM
    TopLevelProcessor #(
        .INIT_FILE("instruction.mem")
    ) dut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        sw = 16'h0004; // Provide switch input 4
        #20 rst = 0;
        
        // Wait enough time for countdown to finish
        #800;
        
        $finish;
    end
endmodule
