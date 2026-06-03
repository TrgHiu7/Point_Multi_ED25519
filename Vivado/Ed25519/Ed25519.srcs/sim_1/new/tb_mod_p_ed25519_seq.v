`timescale 1ns / 1ps

module tb_mod_p_ed25519_seq;

    logic clk;
    logic rst;
    logic start;
    logic [511:0] X;
    logic [255:0] Z;
    logic done;

    // Ed25519 prime
    localparam [255:0] P =
    256'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed;

    // Instantiate DUT
    mod_p_ed25519_seq dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .X(X),
        .Z(Z),
        .done(done)
    );

    //------------------------------------------------
    // Clock generator (100MHz)
    //------------------------------------------------
    always #5 clk = ~clk;

    //------------------------------------------------
    // Expected result
    //------------------------------------------------
    logic [255:0] expected;

    //------------------------------------------------
    // Test process
    //------------------------------------------------
    initial begin

        $display("===== TEST: mod_p_ed25519_seq =====");

        clk = 0;
        rst = 1;
        start = 0;
        X = 0;

        //------------------------------------------------
        // Reset
        //------------------------------------------------
        #20;
        rst = 0;

        //------------------------------------------------
        // Test vector
        //------------------------------------------------

        X = (512'd1 << 500) + 123456789;

        expected = X % P;

        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;

        //------------------------------------------------
        // Wait for done
        //------------------------------------------------
        wait(done);

        @(posedge clk);

        //------------------------------------------------
        // Display result
        //------------------------------------------------
        $display("Input  X      = %h", X);
        $display("Output Z      = %h", Z);
        $display("Expected      = %h", expected);

        if (Z == expected)
            $display("TEST RESULT : PASS");
        else
            $display("TEST RESULT : FAIL");

        //------------------------------------------------
        $stop;
    end

endmodule