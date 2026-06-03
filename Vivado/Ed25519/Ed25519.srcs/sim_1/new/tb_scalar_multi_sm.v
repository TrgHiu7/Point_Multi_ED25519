`timescale 1ns/1ps

module tb_scalar_multi_sm;

reg clk;
reg rst;
reg start;

reg [255:0] k;

reg [255:0] px;
reg [255:0] py;
reg [255:0] pz;
reg [255:0] pt;

wire done;

//------------------------------------
// ALU interface
//------------------------------------

wire rst_alu;
wire start_alu;
wire op_alu;

reg alu_done;

reg [255:0] qx_alu;
reg [255:0] qy_alu;
reg [255:0] qz_alu;
reg [255:0] qt_alu;

wire [255:0] px_alu;
wire [255:0] py_alu;
wire [255:0] pz_alu;
wire [255:0] pt_alu;

//------------------------------------

wire [255:0] result_x;
wire [255:0] result_y;
wire [255:0] result_z;
wire [255:0] result_t;

//------------------------------------
// DUT
//------------------------------------

Scalar_multi_SM dut(
    .clk(clk),
    .rst(rst),
    .start(start),

    .k(k),

    .px(px),
    .py(py),
    .pz(pz),
    .pt(pt),

    .done(done),

    .rst_alu(rst_alu),
    .start_alu(start_alu),
    .op_alu(op_alu),

    .alu_done(alu_done),

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

//------------------------------------
// Clock
//------------------------------------

always #5 clk = ~clk;

//------------------------------------
// Fake ALU
//------------------------------------

always @(posedge clk) begin

    alu_done <= 0;

    if(start_alu) begin

        if(op_alu) begin
            // DOUBLE
            qx_alu <= px_alu + 10;
        end
        else begin
            // ADD
            qx_alu <= px_alu + 1;
        end

        qy_alu <= 0;
        qz_alu <= 0;
        qt_alu <= 0;

        alu_done <= 1;
    end
end

//------------------------------------
// Expected model
//------------------------------------

integer i;
reg [255:0] expected;

initial begin

    expected = 0;

    // ví dụ scalar = 13 = 1101b
    k = 256'd13;

    for(i=255;i>=0;i=i-1) begin

        // Double
        expected = expected + 10;

        // Add
        if(k[i])
            expected = expected + 1;
    end
end

//------------------------------------
// Stimulus
//------------------------------------

initial begin

    clk = 0;
    rst = 1;
    start = 0;

    alu_done = 0;

    qx_alu = 0;
    qy_alu = 0;
    qz_alu = 0;
    qt_alu = 0;

    px = 256'd5;
    py = 256'd6;
    pz = 256'd7;
    pt = 256'd8;

    #20;
    rst = 0;

    #20;
    start = 1;

    #10;
    start = 0;

end

//------------------------------------
// Check result
//------------------------------------

initial begin

    wait(done);

    #10;

    $display("==================================");
    $display("EXPECTED = %0d", expected);
    $display("ACTUAL   = %0d", result_x);

    if(result_x === expected)
        $display("PASS");
    else
        $display("FAIL");

    $display("==================================");

    #20;
    $finish;
end

endmodule