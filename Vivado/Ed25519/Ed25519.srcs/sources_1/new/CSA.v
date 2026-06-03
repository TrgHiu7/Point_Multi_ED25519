`timescale 1ns / 1ps


module CSA #(parameter WIDTH = 256)(
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    output wire [WIDTH-1:0] sum,
    output wire [WIDTH-1:0] carry
);
    wire [WIDTH-1:0] majority = (in1 & in2) | (in2 & in3) | (in1 & in3);
    assign sum   = in1 ^ in2 ^ in3;
    assign carry = majority << 1;
endmodule
