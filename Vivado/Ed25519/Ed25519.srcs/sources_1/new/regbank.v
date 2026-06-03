`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: regbank
//////////////////////////////////////////////////////////////////////////////////

module regbank #(
    parameter DEPTH = 32,
    parameter REG_BANK = 5
)(
    input  wire                 clk,
    input  wire                 rst,         // Reset để tải P, d, px, py, pz
    input  wire                 we,          // Ghi dữ liệu vào dst_sel
    input  wire [REG_BANK-1:0] dst_sel,      // Chỉ số ghi
    input  wire [255:0]        din,          // Dữ liệu ghi
    input  wire [REG_BANK-1:0] src1_sel,     // Chỉ số đọc operand 1
    input  wire [REG_BANK-1:0] src2_sel,     // Chỉ số đọc operand 2
    input  wire [255:0]        Px, Py, Pz, Pt,   // P1(X, Y, Z, T)
    output wire [255:0]        src1_out,     // Dữ liệu operand 1
    output wire [255:0]        src2_out,     // Dữ liệu operand 2
    output wire [255:0]        qx, qy, qz, qt   // Điểm đầu ra Q(X, Y, Z, T)
);
    // Bộ nhớ thanh ghi
    reg [255:0] reg_array [0:DEPTH-1];

    // Hằng số Ed25519
    localparam [255:0] d_2 = 256'h2406d9dc56dffce7198e80f2eef3d13000e0149a8283b156ebd69b9426b2f159;

    // Reset hoặc nạp dữ liệu đầu vào
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < DEPTH; i = i + 1)
                reg_array[i] <= 0;
                reg_array[3] <= Px;
                reg_array[4] <= Py;
                reg_array[5] <= Pz;
                reg_array[15] <= Pt;
                reg_array[25] <= d_2;
                reg_array[26] <= 256'd2;
            end 
        else if (we) begin
            reg_array[dst_sel] <= din;
        end
    end

    // Đọc song song
    assign src1_out = reg_array[src1_sel];
    assign src2_out = reg_array[src2_sel];

    // Đầu ra Q(X, Y, Z) được giả định ở vị trí cố định
    assign qx = reg_array[22];
    assign qy = reg_array[23];
    assign qz = reg_array[24];
    assign qt = reg_array[27];

endmodule
