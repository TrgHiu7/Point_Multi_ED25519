`timescale 1ns / 1ps

module tb_regbank;

    // Parameters
    localparam WID   = 256;
    localparam DEPTH = 32;
    localparam REG_BANK = 5;

    // Inputs
    reg clk;
    reg rst;
    reg we;
    reg [REG_BANK-1:0] dst_sel;
    reg [WID-1:0] din;
    reg [REG_BANK-1:0] src1_sel;
    reg [REG_BANK-1:0] src2_sel;
    reg [WID-1:0] px, py, pz;

    // Outputs
    wire [WID-1:0] src1_out;
    wire [WID-1:0] src2_out;
    wire [WID-1:0] qx, qy, qz;

    // Instantiate the Unit Under Test (UUT)
    regbank #(WID, DEPTH, REG_BANK) uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .dst_sel(dst_sel),
        .din(din),
        .src1_sel(src1_sel),
        .src2_sel(src2_sel),
        .px(px), .py(py), .pz(pz),
        .src1_out(src1_out),
        .src2_out(src2_out),
        .qx(qx), .qy(qy), .qz(qz)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Starting testbench for regbank...");
        clk = 0;
        rst = 1;
        we = 0;
        din = 0;
        dst_sel = 0;
        src1_sel = 0;
        src2_sel = 0;

        // Set input point P(X, Y, Z)
        px = 256'h1111;
        py = 256'h2222;
        pz = 256'h3333;

        // Hold reset to load constants and P
        #12;
        rst = 0;

        // Wait one cycle after reset
        #10;

        // Check that P(X,Y,Z) loaded to reg[0:2]
        src1_sel = 0;  #10; $display("reg[0] (px): %h", src1_out);
        src1_sel = 2;  #10; $display("reg[1] (py): %h", src1_out);
        src1_sel = 4;  #10; $display("reg[2] (pz): %h", src1_out);

        // Check that Q(X,Y,Z) is initially 0
        $display("QX: %h", qx);
        $display("QY: %h", qy);
        $display("QZ: %h", qz);

        // Check that reg[24] is P and reg[23] is d
        src1_sel = 24;
        src2_sel = 23;
        #10;
        $display("reg[24] (P): %h", src1_out);
        $display("reg[23] (d): %h", src2_out);

        // Write new value to reg[22] (Z of Q)
        we = 1;
        dst_sel = 22;
        din = 256'hAAAA;
        #10;
        we = 0;

        // Check new qz
        $display("After write QZ = %h", qz);

        $display("Testbench complete.");
        $finish;
    end

endmodule
