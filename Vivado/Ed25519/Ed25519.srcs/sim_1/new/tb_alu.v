`timescale 1ns / 1ps

module tb_alu;

    parameter WID = 256;
    reg clk, rst, start;
    reg [1:0] op;
    reg [WID-1:0] a, b;
    wire [WID-1:0] result;
    wire done;

    // Instantiate the ALU
    alu #(.WID(WID)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .op(op),
        .a(a),
        .b(b),
        .result(result),
        .done(done)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Constants (Ed25519: p = 2^255 - 19)
    localparam [WID-1:0] P_ED25519 = 256'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED;

    task do_op(input [1:0] opcode, input [WID-1:0] in_a, input [WID-1:0] in_b);
        begin
            @(posedge clk);
            a     <= in_a;
            b     <= in_b;
            op    <= opcode;
            start <= 1;
            @(posedge clk);
            start <= 0;

            // Wait for done
            wait (done == 1);
            $display("OP = %0d | A = %h | B = %h | RESULT = %h", opcode, in_a, in_b, result);
        end
    endtask

    initial begin
        // Initialize
        rst = 1;
        start = 0;
        a = 0;
        b = 0;
        op = 0;

        #20 rst = 0;

        // Test ADD
        do_op(2'b00, 256'h05, 256'h03);  // 5 + 3 = 8

        // Test SUB
        do_op(2'b01, 256'h05, 256'h07);  // 5 - 7 mod P

        // Test MUL (with wait cycles)
        do_op(2'b10, 256'h02, 256'h09);  // 2 * 9 = 18
        
        // Test SUB
        do_op(2'b01, 256'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED, 256'h07);  // P - 7 mod P
        
        // Test MUL (with wait cycles)
        do_op(2'b10, 256'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEC, 256'h09);  // (P-1) * 9 
        
        // Test ADD
        do_op(2'b00, 256'h05, 256'h03);  // 5 + 3 = 8

        // Finish
        #50 $finish;
    end

endmodule
