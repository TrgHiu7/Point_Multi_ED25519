`timescale 1ns / 1ps

module tb_scalar_multi_sm;

    parameter WID = 256;

    // Clock and reset
    reg clk;
    reg rst;

    // Inputs to FSM
    reg start;
    reg [WID-1:0] k;
    reg [WID-1:0] px, py;

    // Outputs from FSM
    wire done;
    wire [WID-1:0] result_x, result_y, result_z, result_t;

    // ALU interface wires
    wire rst_alu;
    wire start_alu;
    wire alu_done;
    wire op_alu;
    wire [WID-1:0] qx_alu, qy_alu, qz_alu, qt_alu;
    wire [WID-1:0] px_alu, py_alu, pz_alu, pt_alu;

    // Instantiate Scalar Multiplication FSM
    Scalar_multi_SM uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .k(k),
        .px(px),
        .py(py),
        .done(done),
        .rst_alu(rst_alu),
        .start_alu(start_alu),
        .alu_done(alu_done),
        .op_alu(op_alu),
        .qx_alu(qx_alu),
        .qy_alu(qy_alu),
        .qz_alu(qz_alu),
        .qt_alu(qt_alu),
        .px_alu(px_alu),
        .py_alu(py_alu),
        .pz_alu(pz_alu),
        .pt_alu(pt_alu),
        .result_x(result_x),
        .result_y(result_y),
        .result_z(result_z),
        .result_t(result_t)
    );

    // Instantiate Real ALU Unit
    ALU_UNIT #(
        .WID(WID),
        .DEPTH(32),
        .REG_BANK(5)
    ) alu_unit_inst (
        .clk(clk),
        .rst(rst_alu),
        .start(start_alu),
        .op(op_alu),
        .px(px_alu),
        .py(py_alu),
        .pz(pz_alu),
        .pt(pt_alu),
        .qx(qx_alu),
        .qy(qy_alu),
        .qz(qz_alu),
        .qt(qt_alu),
        .done(alu_done)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz

    // Test process
    initial begin
        $display("[TB] Starting Scalar Multiplication Test...");

        // Initialize inputs
        clk = 0;
        rst = 1;
        start = 0;
        k = 256'd105;
        px = 256'h216936d3cd6e53fec0a4e231fdd6dc5c692cc7609525a7b2c9562d608f25d51a;
        py = 256'h6666666666666666666666666666666666666666666666666666666666666658;

        #20;
        rst = 0;
        #10;

        // Start scalar multiplication
        @(posedge clk); start = 1;
        @(posedge clk); start = 0;

        // Wait for computation to finish
        wait(done);
        @(posedge clk);

        $display("[TB] Scalar multiplication done.");
        $display("[TB] Result Qx = %h", result_x);
        $display("[TB] Result Qy = %h", result_y);
        $display("[TB] Result Qz = %h", result_z);
        $display("[TB] Result Qt = %h", result_t);

        #50;
        $finish;
    end

endmodule
