`timescale 1ns/1ps

module tb_ramY_2;

reg clk;
reg rst;
reg init_en;
reg [255:0] Y;
reg [2:0] addr;

wire [255:0] data_out;
wire done;

ramY_2 dut(
    .clk(clk),
    .rst(rst),
    .init_en(init_en),
    .Y(Y),
    .addr(addr),
    .data_out(data_out),
    .done(done)
);

always #5 clk = ~clk;

task check_addr;
    input [2:0] a;
    input [255:0] expected;
begin
    addr = a;
    #20;

    $display("--------------------------------");
    $display("ADDR     = %0d", a);
    $display("RESULT   = %h", data_out);
    $display("EXPECTED = %h", expected);

    if(data_out === expected)
        $display("PASS");
    else
        $display("FAIL");
end
endtask

initial begin

    clk = 0;
    rst = 1;
    init_en = 0;
    addr = 0;
    Y = 0;

    #20;
    rst = 0;

    //-----------------------------------
    // Load Y = 2
    //-----------------------------------

    Y = 256'd2;

    #10;
    init_en = 1;

    #10;
    init_en = 0;

    wait(done);

    $display("RAM INITIALIZATION DONE");

    //-----------------------------------
    // Verify contents
    //-----------------------------------

    check_addr(3'd0, 256'd0);
    check_addr(3'd1, 256'd2);
    check_addr(3'd2, 256'd4);
    check_addr(3'd3, 256'd6);
    check_addr(3'd4, 256'd8);
    check_addr(3'd5, 256'd10);
    check_addr(3'd6, 256'd12);
    check_addr(3'd7, 256'd14);

    #100;
    $finish;

end

endmodule