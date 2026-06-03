`timescale 1ns / 1ps

module tb_ECPA_SM;

    // Parameters
    parameter REG_BANK = 5;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg alu_done;

    // Outputs
    wire done;
    wire [1:0] alu_op;
    wire alu_start;
    wire [REG_BANK-1:0] src1_sel, src2_sel, dst_sel;

    // Instantiate the ECPA_SM module
    ECPA_SM #(.REG_BANK(REG_BANK)) uut (
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

    // Simulation
    initial begin
        $display("Starting ECPA_SM testbench...");
        $dumpfile("ecpa_sm_tb.vcd");  // Optional: for GTKWave
        $dumpvars(0, tb_ECPA_SM);

        // Initial values
        clk = 0;
        rst = 1;
        start = 0;
        alu_done = 0;

        // Reset pulse
        #20 rst = 0;

        // Start signal pulse
        #10 start = 1;

        // FSM should now begin; simulate ALU_DONE at intervals
        repeat (30) begin
            #10 alu_done = 1;
            #10 alu_done = 0;
        end

        // Wait until FSM done
        wait (done == 1);

        // Stop simulation
        #20 $display("ECPA_SM simulation done.");
        $finish;
    end

endmodule
