`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/05/2025 11:34:35 AM
// Design Name: 
// Module Name: tb_modular_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_modular_adder();
parameter WIDTH = 256;

    // Đếm số test
    integer num_passed = 0;
    integer num_total  = 0;

    // Inputs
    reg  [WIDTH-1:0] A, B, P;

    // Output từ DUT
    wire [WIDTH-1:0] result;

    // Reference result từ mô hình hành vi (behavioral)
    reg  [WIDTH-1:0] ref_result;

    // Instantiate DUT
    modular_adder #(WIDTH) dut (
        .A(A),
        .B(B),
        .P(P),
        .result(result)
    );

    // Mô hình hành vi tham chiếu
    function [WIDTH-1:0] mod_add_ref;
        input [WIDTH-1:0] a, b, p;
        reg [WIDTH:0] sum;
        begin
            sum = a + b;
            if (sum >= p)
                mod_add_ref = sum - p;
            else
                mod_add_ref = sum[WIDTH-1:0];
        end
    endfunction

    // Một testcase đơn
    task run_case;
        input [WIDTH-1:0] a, b, p;
        begin
            A = a;
            B = b;
            P = p;
            ref_result = mod_add_ref(a, b, p);
            #10;
            num_total = num_total + 1;

            $display("==== Testcase %0d ====", num_total);
            $display("A         = %h", A);
            $display("B         = %h", B);
            $display("P         = %h", P);
            $display("Result    = %h", result);
            $display("Expected  = %h", ref_result);

            if (result === ref_result) begin
                $display("✅ PASS\n");
                num_passed = num_passed + 1;
            end else begin
                $display("❌ FAIL\n");
            end
        end
    endtask

    initial begin
        $display("=== Modular Adder Self-Checking Testbench ===");

        // Prime: 2^255 - 19
        P = 256'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED;

        // Testcases
        run_case(256'd10, 256'd20, P); // Expect: 30
        run_case(P - 1, 256'd1, P);    // Expect: 0
        run_case(P - 10, 256'd5, P);   // Expect: P - 5
        run_case(P - 5, 256'd10, P);   // Expect: 5
        run_case(256'd0, 256'd0, P);   // Expect: 0

        // Overflow test
        run_case({256{1'b1}}, {256{1'b1}}, P); // Expect: (A + B) % P

        // Summary
        $display("============================================");
        $display("Total tests: %0d, Passed: %0d, Failed: %0d", 
                 num_total, num_passed, num_total - num_passed);
        $display("============================================");

        $finish;
    end

endmodule