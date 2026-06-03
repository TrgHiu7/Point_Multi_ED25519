`timescale 1ns / 1ps

module tb_invert;

    parameter WID = 256;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [WID-1:0] a;

    // Outputs
    wire done;
    wire [WID-1:0] a_inv;

    // Clock generation
    always #5 clk = ~clk;

    // Instantiate the invert module
    invert #(.WID(WID)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .done(done),
        .result(a_inv)
    );

    // Test logic
    initial begin
        $display("Starting invert testbench...");

        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        a = 0;

        // Apply reset
        #20;
        rst = 0;
        #10;

        // Test case: a = 5 (can replace with random value)
        a = 256'd5;

        // Start inversion
        @(posedge clk); start = 1;
        @(posedge clk); start = 0;

        // Wait for done signal
        wait (done == 1);
        @(posedge clk);

        $display("a      = %h", a);
        $display("a_inv  = %h", a_inv);

        $finish;
    end

endmodule
