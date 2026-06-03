`timescale 1ns / 1ps

module tb_ALU_UNIT;

    // Parameters
    localparam WID = 256;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg op;  // 0 = ECPA, 1 = ECPD
    reg [WID-1:0] px, py, pz, pt;

    // Outputs
    wire [WID-1:0] qx, qy, qz, qt;
    wire done;

    // Instantiate the ALU_UNIT
    ALU_UNIT #(.WID(WID)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .op(op),
        .px(px),
        .py(py),
        .pz(pz),
        .pt(pt),
        .qx(qx),
        .qy(qy),
        .qz(qz),
        .qt(qt),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to run a single test case
    task run_test(
        input [WID-1:0] in_px,
        input [WID-1:0] in_py,
        input [WID-1:0] in_pz,
        input [WID-1:0] in_pt,
        input           in_op
    );
    begin
        $display("\n--- Test %s ---", (in_op == 0) ? "ECPA (Point Addition)" : "ECPD (Point Doubling)");
        px    = in_px;
        py    = in_py;
        pz    = in_pz;
        pt    = in_pt;
        op    = in_op;

        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait for done signal
        wait (done == 1);
        @(posedge clk);
        $display("QX: %h", qx);
        $display("QY: %h", qy);
        $display("QZ: %h", qz);
        $display("QT: %h", qt);
    end
    endtask

    // Stimulus
    initial begin
        $display("Starting ALU_UNIT testbench...");

        clk = 0;
        rst = 1;
        start = 0;
        px = 256'h216936d3cd6e53fec0a4e231fdd6dc5c692cc7609525a7b2c9562d608f25d51a; 
        py = 256'h6666666666666666666666666666666666666666666666666666666666666658; 
        pz = 256'h01;
        pt = 256'h67875f0fd78b766566ea4e8e64abe37d20f09f80775152f56dde8ab3a5b7dda3;
        op = 0;

        // Apply reset
        #20;
        rst = 0;
        #10;

        // Test case 1: Point Addition (ECPA)
        run_test(
            256'h216936D3CD6E53FEC0A4E231FDD6DC5C692CC7609525A7B2C9562D608F25D51A,
            256'h6666666666666666666666666666666666666666666666666666666666666658,
            256'h01,
            256'h67875f0fd78b766566ea4e8e64abe37d20f09f80775152f56dde8ab3a5b7dda3,
            1'b0 // ECPA
        );

        // Test case 2: Point Doubling (ECPD)
        run_test(
            256'h216936D3CD6E53FEC0A4E231FDD6DC5C692CC7609525A7B2C9562D608F25D,
            256'h6666666666666666666666666666666666666666666666666666666666666658,
            256'h01,
            256'h6668120f8a971250fff0083e827fe457d16ba8a391a10eaec8f0778244d3f508,
            1'b1 // ECPD
        );

        $display("All tests finished.");
        $finish;
    end

endmodule
