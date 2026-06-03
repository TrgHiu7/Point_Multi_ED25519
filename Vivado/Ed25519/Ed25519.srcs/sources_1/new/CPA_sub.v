`timescale 1ns / 1ps


module CPA_sub #(parameter WIDTH = 256)(
    input  wire [WIDTH-1:0] sum_in,
    input  wire [WIDTH-1:0] carry_in,
    input  wire [WIDTH-1:0] C_in,
    output wire [WIDTH-1:0] result,
    output wire             cout
);
    wire [WIDTH:0] temp_sum;
    assign temp_sum = {1'b0, sum_in} + carry_in + C_in;
    assign result   = temp_sum[WIDTH-1:0];
    assign cout     = temp_sum[WIDTH];
endmodule
