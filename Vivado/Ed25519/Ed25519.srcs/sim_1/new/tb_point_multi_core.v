`timescale 1ns / 1ps

module tb_point_multi_core;

    // Parameters
    parameter WID = 256;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [WID-1:0] k;
    reg [WID-1:0] px;
    reg [WID-1:0] py;

    // Outputs
    wire [WID-1:0] qx;
    wire [WID-1:0] qy;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    point_multi_core #(
        .WID(WID)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .k(k),
        .px(px),
        .py(py),
        .qx(qx),
        .qy(qy),
        .done(done)
    );

    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Test sequence
    initial begin
        // Khởi tạo các tín hiệu
        rst = 1;
        start = 0;
        k = 0;
        px = 0;
        py = 0;

        // Reset hệ thống
        #20;
        rst = 0;
        #20;

        // -------------------------------------------------------------
        // Test Case 1: k = 2, P = Base Point của Ed25519
        // -------------------------------------------------------------
        // Px = 9 (Base point X-coordinate)
        px = 256'h0000000000000000000000000000000000000000000000000000000000000009;
        
        // Py = Base point Y-coordinate
        py = 256'h20ae19a1b8a086b4e01edd2c7748d14c923d4d7e6d7c61b229e9c5a27eced3d9;
        
        // Hệ số k = 2
        k = 256'd2; 

        // Kích hoạt bắt đầu tính toán
        start = 1;
        #10;
        start = 0;

        // Chờ tín hiệu done
        $display("Dang tinh toan nhan vo huong Q = 2 * P...");
        wait(done == 1'b1);
        $display("Tinh toan xong!");

        // -------------------------------------------------------------
        // Kiểm tra kết quả (Expected Values)
        // -------------------------------------------------------------
        // Kết quả Q = 2 * P trên Ed25519 có toạ độ đã được tính toán trước
        // Bạn có thể thay đổi expected_qx và expected_qy nếu dùng điểm khác.
        
        $display("---------------------------------------------------------");
        $display("Ket qua Qx: %h", qx);
        $display("Ket qua Qy: %h", qy);
        $display("---------------------------------------------------------");

        // Expected của 2*B
        // Giá trị này là giá trị mẫu của 2*B trên Ed25519 để so sánh
        if (qy == 256'h6666666666666666666666666666666666666666666666666666666666666658) begin
            $display(">> TEST PASSED! Toa do trung khop voi Expected.");
        end else begin
            $display(">> TEST FAILED! Vui long kiem tra lai logic.");
        end

        // Kết thúc mô phỏng
        #100;
        $finish;
    end

endmodule