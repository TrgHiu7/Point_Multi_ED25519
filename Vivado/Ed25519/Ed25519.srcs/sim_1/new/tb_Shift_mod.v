`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2025 09:33:06 PM
// Design Name: 
// Module Name: tb_Shift_mod
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


module tb_Shift_mod();
    parameter N = 256;

    // Inputs
    reg [N-1:0] in;

    // Output
    wire [N-1:0] out;

    // Expected output
    reg [N-1:0] expected;

    // Instantiate DUT
    Shift_mod #(N) dut (
        .in(in),
        .out(out)
    );

    // Task for testing
    task run_test;
        input [N-1:0] t_in;
        input [N-1:0] t_expected;
        begin
            in = t_in;
            expected = t_expected;
            #10;
            if (out === expected)
                $display("PASS: in=%h => out=%h", in, out);
            else
                $display("FAIL: in=%h => out=%h (expected %h)", in, out, expected);
        end
    endtask

    // Main test sequence
    initial begin
        $display("Starting Shift_mod tests (fixed shift by 3 bits)");

        // Test 1: 1 << 3 = 8
        run_test(256'h1, 256'h8);

        // Test 2: Max value, expect wrap (all F's << 3 and truncated to 256 bits)
        run_test(256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                 256'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8);

        // Test 3: 1 at MSB → shift causes overflow → result = 0
        run_test(256'h8000000000000000000000000000000000000000000000000000000000000000,
                 256'h0000000000000000000000000000000000000000000000000000000000000000);

        // Test 4: Random value
        run_test(256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0,
                 256'h11a2b3c4d5e6f78091a2b3c4d5e6f78091a2b3c4d5e6f78091a2b3c4d5e6f780);

        // Test 5: Zero
        run_test(256'h0, 256'h0);

        $display("All Shift_mod tests completed.");
        $finish;
    end
endmodule
