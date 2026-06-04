`timescale 1ns/1ps

module tb_mod_p_ed25519_seq;

reg clk;
reg rst;
reg start;
reg [511:0] X;

wire [254:0] Z;
wire done;

mod_p_ed25519_seq dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .X(X),
    .Z(Z),
    .done(done)
);

localparam [254:0] P =
255'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED;

always #5 clk = ~clk;

task run_test;
    input [511:0] xin;
    input [254:0] expected;
begin

    X = xin;

    @(posedge clk);
    start = 1'b1;

    @(posedge clk);
    start = 1'b0;

    wait(done);

    $display("------------------------------------");
    $display("X        = %h", xin);
    $display("RESULT   = %h", Z);
    $display("EXPECTED = %h", expected);

    if(Z === expected)
        $display("PASS");
    else
        $display("FAIL");

    @(posedge clk);

end
endtask

initial begin

    clk = 0;
    rst = 1;
    start = 0;
    X = 0;

    #20;
    rst = 0;

    //--------------------------------
    // TEST 1
    //--------------------------------
    run_test(
        512'd0,
        255'd0
    );

    //--------------------------------
    // TEST 2
    //--------------------------------
    run_test(
        512'd1,
        255'd1
    );

    //--------------------------------
    // TEST 3
    //--------------------------------
    run_test(
        {257'd0, P},
        255'd0
    );

    //--------------------------------
    // TEST 4
    //--------------------------------
    run_test(
        {257'd0, P} + 512'd1,
        255'd1
    );

    //--------------------------------
    // TEST 5
    //--------------------------------
    run_test(
        ({257'd0, P} << 1) + 512'd5,
        255'd5
    );

    #100;
    $finish;

end

endmodule