`timescale 1ns / 1ps

module tb_invert;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [255:0] a;

    // Outputs
    wire [255:0] result;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    invert uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .result(result),
        .done(done)
    );

    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        rst = 1;
        start = 0;
        a = 0;

        // Reset hệ thống
        #20;
        rst = 0;
        #20;

        // =============================================================
        // TEST CASE 1: a = 1
        // Expected = 1
        // =============================================================
        $display("---------------------------------------------------------");
        $display("[TEST 1] Tinh nghich dao Modulo P cho a = 1...");
        a = 256'd1;
        
        start = 1;
        #10;
        start = 0;

        wait(done == 1'b1);
        
        $display(">> Ket qua Test 1: %h", result);
        if (result == 256'd1) begin
            $display(">> TEST 1 PASSED!");
        end else begin
            $display(">> TEST 1 FAILED! Expected: 1");
        end
        
        #50; // Chờ 1 chút giữa 2 test case

        // =============================================================
        // TEST CASE 2: a = 2
        // Expected = (P+1)/2 = 2^254 - 9 
        // Hex = 3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7
        // =============================================================
        $display("---------------------------------------------------------");
        $display("[TEST 2] Tinh nghich dao Modulo P cho a = 2...");
        $display(">> Vui long doi... (Thuat toan se chay hang nghin cycle)");
        a = 256'd2;
        
        start = 1;
        #10;
        start = 0;

        wait(done == 1'b1);
        
        $display(">> Ket qua Test 2: %h", result);
        if (result == 256'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7) begin
            $display(">> TEST 2 PASSED! Ket qua chinh xac tuyet doi!");
        end else begin
            $display(">> TEST 2 FAILED!");
            $display(">> Expected      : 3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7");
        end
        $display("---------------------------------------------------------");

        // Hoàn thành mô phỏng
        #100;
        $finish;
    end

endmodule