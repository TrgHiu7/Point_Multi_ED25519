`timescale 1ns / 1ps

module tb_top;
    reg clk = 0;
    reg rst;
    reg start;
    wire done;
    
    top dut(
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done)
    );
    
    always #5 clk = ~clk;

    initial begin
        rst = 1;
        start = 0;

        // giữ reset một vài chu kỳ
        #20;
        rst = 0;

        // đợi 1 chu kỳ rồi mới start
        #10;
        start = 1;
        #10;
        start = 0;

        // chờ done
        wait(done == 1);

        #20;
        $finish;
    end
endmodule