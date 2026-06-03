`timescale 1ns / 1ps

module CPA (
    input  wire [255:0] sum_in,
    input  wire [255:0]   carry_in,
    output wire [255:0] result,
    output wire             cout
);
    wire [256:0] temp_sum;
    assign temp_sum = {1'b0, sum_in} + carry_in;
    assign result   = temp_sum[255:0];
    assign cout     = temp_sum[256];
endmodule

