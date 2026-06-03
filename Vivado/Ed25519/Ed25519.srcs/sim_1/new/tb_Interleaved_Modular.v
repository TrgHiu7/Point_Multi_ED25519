`timescale 1ns / 1ps

module tb_Interleaved_Modular;

    parameter WIDTH = 256;
    parameter CLK_PERIOD = 10;

    reg                  clk;
    reg                  reset;
    reg                  start;
    reg  [WIDTH-1:0]     X;
    reg  [WIDTH-1:0]     Y;
    wire [WIDTH-1:0]     Z;
    wire                 done;

    // DUT
    Interleaved_Modular_Multi #(WIDTH) dut (
        .clk   (clk),
        .reset (reset),
        .start (start),
        .X     (X),
        .Y     (Y),
        .Z     (Z),
        .done  (done)
    );

    // Clock
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Task reset
    task apply_reset;
    begin
        reset = 1'b1;
        start = 1'b0;
        X     = 0;
        Y     = 0;

        repeat (5) @(posedge clk);
        reset = 1'b0;
        repeat (2) @(posedge clk);
    end
    endtask

    // Task start 1 pulse
    task start_once;
    begin
        @(negedge clk);
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;
    end
    endtask

    // Task chạy 1 test
    task run_case;
        input [255:0] x_in;
        input [255:0] y_in;
        integer cycle_count;
    begin
        X = x_in;
        Y = y_in;

        $display("--------------------------------------------------");
        $display("Start test at time = %0t", $time);
        $display("X = 0x%064h", X);
        $display("Y = 0x%064h", Y);

        start_once;

        cycle_count = 0;
        while (done == 1'b0 && cycle_count < 3000) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
        end

        if (done) begin
            $display("DONE after %0d cycles", cycle_count);
            $display("Z = 0x%064h", Z);
        end else begin
            $display("TIMEOUT after %0d cycles", cycle_count);
        end

        repeat (5) @(posedge clk);
    end
    endtask

    // Theo dõi nhanh
    initial begin
        $monitor("time=%0t reset=%b start=%b done=%b state=%d counter=%d Z=%h",
                 $time, reset, start, done, dut.state, dut.counter, Z);
    end

    // Main test
    initial begin
        apply_reset;

        // Test 1
        run_case(256'd0, 256'd0);

        // Test 2
        run_case(256'd1, 256'd1);

        // Test 3
        run_case(256'd7, 256'd9);

        // Test 4
        run_case(256'h123456789ABCDEF00112233445566778899AABBCCDDEEFF0011223344556677,
                 256'h111122223333444455556666777788889999AAAABBBBCCCCDDDDEEEEFFFF0001);

        // Test 5
        run_case(256'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEC,
                 256'h0000000000000000000000000000000000000000000000000000000000000002);

        #100;
        $finish;
    end

endmodule