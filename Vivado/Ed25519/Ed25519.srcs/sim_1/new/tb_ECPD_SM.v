`timescale 1ns / 1ps

module tb_ECPD_SM;

    // Parameters
    parameter REG_BANK = 5;

    // Testbench Signals
    reg clk, rst, start;
    wire done;
    reg alu_done;
    wire [1:0] alu_op;
    wire alu_start;
    wire [REG_BANK-1:0] src1_sel, src2_sel, dst_sel;

    // Instantiate the DUT
    ECPD_SM #(REG_BANK) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .alu_op(alu_op),
        .alu_start(alu_start),
        .alu_done(alu_done),
        .src1_sel(src1_sel),
        .src2_sel(src2_sel),
        .dst_sel(dst_sel)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Starting ECPD_SM Testbench...");
        clk = 0;
        rst = 1;
        start = 0;
        alu_done = 0;

        // Reset pulse
        #20;
        rst = 0;

        // Start signal
        #10;
        start = 1;
        #10;
        start = 0;

        // Simulate ALU done after some delay per operation
        repeat (20) begin
            wait (alu_start == 1);
            #10;
            alu_done = 1;
            #10;
            alu_done = 0;
        end

        // Wait for completion
        wait (done == 1);
        #20;

        $display("ECPD_SM Test Completed.");
        $stop;
    end

endmodule
