`timescale 1ns / 1ps

// =============================================================================
// tb_task_c.v  -  Task C: Recursive Summation Test Bench
//
// What this tests:
//   For every n from 1 to 7, the assembly computes sum = 1+2+...+n recursively
//   using the stack, then writes the result to MMIO:
//     led      = sum(n)         (lower 16 bits)
//     seg_data = 0xABCD         (upper 16 bits, proof LUI worked)
//
//   n | expected sum | led (hex) | seg_data
//   --+-------------+-----------+---------
//   1 |     1        |  0x0001   | 0xABCD
//   2 |     3        |  0x0003   | 0xABCD
//   3 |     6        |  0x0006   | 0xABCD
//   4 |    10        |  0x000A   | 0xABCD
//   5 |    15        |  0x000F   | 0xABCD
//   6 |    21        |  0x0015   | 0xABCD
//   7 |    28        |  0x001C   | 0xABCD
//
// After computing, the assembly hits "jal x0, HALT" (infinite loop).
// To run the next test we assert rst=1 to restart the processor, then
// release rst=0 with the new switch value.
//
// Clock: 10 ns period.
// The recursive call depth is at most 7; each level is a handful of
// instructions, so 200 cycles is more than enough after rst is released.
// =============================================================================

module tb_task_c;

    // -------------------------------------------------------------------------
    // DUT signals
    // -------------------------------------------------------------------------
    reg         clk;
    reg         rst;
    reg  [15:0] sw;
    wire [15:0] led;
    wire [15:0] seg_data;

    // -------------------------------------------------------------------------
    // Instantiate DUT
    // -------------------------------------------------------------------------
    TopLevelProcessor #(
        .INIT_FILE("taskc.mem")
    ) dut (
        .clk     (clk),
        .rst     (rst),
        .sw      (sw),
        .led     (led),
        .seg_data(seg_data)
    );

    // -------------------------------------------------------------------------
    // 10 ns clock
    // -------------------------------------------------------------------------
    initial clk = 0;
    always  #5 clk = ~clk;

    // -------------------------------------------------------------------------
    // Helper task: reset & run with given n, then check outputs
    // -------------------------------------------------------------------------
    integer pass_count;
    integer fail_count;

    task run_test;
        input [15:0] n;            // sw[2:0] = n
        input [15:0] exp_led;      // expected LED value
        input [15:0] exp_seg;      // expected 7-seg value (always 0xABCD)
        integer i;
        begin
            // Hard-reset the processor so it starts from PC=0 fresh
            rst = 1;
            sw  = n;               // switches set BEFORE releasing reset so
            repeat(4) @(posedge clk); //  they are ready when POLL executes
            rst = 0;

            // Wait 300 cycles - plenty for recursion depth 7
            repeat(300) @(posedge clk);
            #1; // settle

            $display("--- n=%0d | led=0x%04X seg=0x%04X | exp led=0x%04X seg=0x%04X | %s",
                     n, led, seg_data,
                     exp_led, exp_seg,
                     (led===exp_led && seg_data===exp_seg) ? "PASS" : "FAIL");

            if (led === exp_led && seg_data === exp_seg)
                pass_count = pass_count + 1;
            else
                fail_count = fail_count + 1;
        end
    endtask

    // -------------------------------------------------------------------------
    // Stimulus
    // -------------------------------------------------------------------------
    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("=========================================");
        $display("Task C: Recursive Summation Tests");
        $display("=========================================");

        //         n          exp_led    exp_seg
        run_test(16'h0001, 16'h0001, 16'hABCD);  // sum(1) = 1
        run_test(16'h0002, 16'h0003, 16'hABCD);  // sum(2) = 3
        run_test(16'h0003, 16'h0006, 16'hABCD);  // sum(3) = 6
        run_test(16'h0004, 16'h000A, 16'hABCD);  // sum(4) = 10
        run_test(16'h0005, 16'h000F, 16'hABCD);  // sum(5) = 15
        run_test(16'h0006, 16'h0015, 16'hABCD);  // sum(6) = 21
        run_test(16'h0007, 16'h001C, 16'hABCD);  // sum(7) = 28

        $display("=========================================");
        $display("Task C Results:  %0d PASSED,  %0d FAILED", pass_count, fail_count);
        $display("=========================================");
        $finish;
    end

endmodule
