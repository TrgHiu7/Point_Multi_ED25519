//`timescale 1ns / 1ps

////==============================================================
//// Testbench for point_multi_core
//// Uses simple behavioral stubs for submodules
////==============================================================
//module tb_point_multi_core;

//    parameter WID = 256;
//    parameter CLK_PERIOD = 10;

//    reg              clk;
//    reg              rst;
//    reg              start;
//    reg  [WID-1:0]   k;
//    reg  [WID-1:0]   px, py;
//    wire [WID-1:0]   qx, qy;
//    wire             done;

//    reg [WID-1:0] expected_qx;
//    reg [WID-1:0] expected_qy;

//    integer cycle_count;

//    // DUT
//    point_multi_core #(
//        .WID(WID)
//    ) dut (
//        .clk(clk),
//        .rst(rst),
//        .start(start),
//        .k(k),
//        .px(px),
//        .py(py),
//        .qx(qx),
//        .qy(qy),
//        .done(done)
//    );

//    //==========================================================
//    // Clock
//    //==========================================================
//    initial begin
//        clk = 1'b0;
//        forever #(CLK_PERIOD/2) clk = ~clk;
//    end

//    //==========================================================
//    // Reset
//    //==========================================================
//    task apply_reset;
//    begin
//        rst   = 1'b1;
//        start = 1'b0;
//        k     = 0;
//        px    = 0;
//        py    = 0;

//        repeat (5) @(posedge clk);
//        rst = 1'b0;
//        repeat (2) @(posedge clk);
//    end
//    endtask

//    //==========================================================
//    // Start pulse
//    //==========================================================
//    task start_once;
//    begin
//        @(negedge clk);
//        start = 1'b1;
//        @(negedge clk);
//        start = 1'b0;
//    end
//    endtask

//    //==========================================================
//    // Compute expected according to stub behavior
//    //==========================================================
//    task calc_expected;
//        input [255:0] k_in;
//        input [255:0] px_in;
//        input [255:0] py_in;
//        reg   [255:0] pt_tmp;
//        reg   [255:0] result_x_tmp;
//        reg   [255:0] result_y_tmp;
//        reg   [255:0] result_z_tmp;
//        reg   [255:0] a_inv_tmp;
//    begin
//        pt_tmp       = px_in * py_in;     // stub mul for CALC_P
//        result_x_tmp = px_in + k_in;      // stub Scalar_multi_SM
//        result_y_tmp = py_in + k_in;
//        result_z_tmp = pt_tmp + 5;
//        a_inv_tmp    = result_z_tmp + 1;  // stub invert

//        expected_qx  = result_x_tmp * a_inv_tmp;
//        expected_qy  = result_y_tmp * a_inv_tmp;
//    end
//    endtask

//    //==========================================================
//    // Run one test
//    //==========================================================
//    task run_case;
//        input [255:0] k_in;
//        input [255:0] px_in;
//        input [255:0] py_in;
//    begin
//        calc_expected(k_in, px_in, py_in);

//        @(negedge clk);
//        k  = k_in;
//        px = px_in;
//        py = py_in;

//        $display("==================================================");
//        $display("Start test at time = %0t", $time);
//        $display("k  = 0x%064h", k_in);
//        $display("px = 0x%064h", px_in);
//        $display("py = 0x%064h", py_in);
//        $display("expected_qx = 0x%064h", expected_qx);
//        $display("expected_qy = 0x%064h", expected_qy);

//        start_once;

//        cycle_count = 0;
//        while (done == 1'b0 && cycle_count < 500) begin
//            @(posedge clk);
//            cycle_count = cycle_count + 1;
//        end

//        if (done) begin
//            $display("DONE after %0d cycles", cycle_count);
//            $display("qx = 0x%064h", qx);
//            $display("qy = 0x%064h", qy);

//            if ((qx === expected_qx) && (qy === expected_qy))
//                $display("[PASS]");
//            else
//                $display("[FAIL]");
//        end else begin
//            $display("[FAIL] TIMEOUT");
//        end

//        repeat (5) @(posedge clk);
//    end
//    endtask

//    //==========================================================
//    // Monitor
//    //==========================================================
//    initial begin
//        $monitor("time=%0t rst=%b start=%b done=%b state=%0d qx=%h qy=%h",
//                 $time, rst, start, done, dut.state, qx, qy);
//    end

//    //==========================================================
//    // Main
//    //==========================================================
//    initial begin
//        apply_reset;

//        run_case(256'd3,  256'd5,  256'd7);
//        run_case(256'd1,  256'd10, 256'd20);
//        run_case(256'd9,  256'd12, 256'd15);
//        run_case(256'h11, 256'h22, 256'h33);

//        #100;
//        $finish;
//    end

//endmodule


////==============================================================
//// STUB: Scalar_multi_SM
//// Behavior:
////   result_x = px + k
////   result_y = py + k
////   result_z = pt + 5
////==============================================================
//module Scalar_multi_SM (
//    input  wire         clk,
//    input  wire         rst,
//    input  wire         start,
//    input  wire [255:0] k,
//    input  wire [255:0] px,
//    input  wire [255:0] py,
//    input  wire [255:0] pz,
//    input  wire [255:0] pt,
//    output reg          done,
//    output wire         rst_alu,
//    output wire         start_alu,
//    input  wire         alu_done,
//    output wire         op_alu,
//    output wire [255:0] qx_alu,
//    output wire [255:0] qy_alu,
//    output wire [255:0] qz_alu,
//    output wire [255:0] qt_alu,
//    output wire [255:0] px_alu,
//    output wire [255:0] py_alu,
//    output wire [255:0] pz_alu,
//    output wire [255:0] pt_alu,
//    output reg  [255:0] result_x,
//    output reg  [255:0] result_y,
//    output reg  [255:0] result_z,
//    output reg  [255:0] result_t
//);
//    reg [1:0] cnt;

//    assign rst_alu   = 1'b0;
//    assign start_alu = 1'b0;
//    assign op_alu    = 1'b0;
//    assign qx_alu    = 256'd0;
//    assign qy_alu    = 256'd0;
//    assign qz_alu    = 256'd0;
//    assign qt_alu    = 256'd0;
//    assign px_alu    = 256'd0;
//    assign py_alu    = 256'd0;
//    assign pz_alu    = 256'd0;
//    assign pt_alu    = 256'd0;

//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            cnt      <= 0;
//            done     <= 0;
//            result_x <= 0;
//            result_y <= 0;
//            result_z <= 0;
//            result_t <= 0;
//        end else begin
//            done <= 0;

//            if (start) begin
//                cnt      <= 2;
//                result_x <= px + k;
//                result_y <= py + k;
//                result_z <= pt + 5;
//                result_t <= 256'd0;
//            end else if (cnt != 0) begin
//                cnt <= cnt - 1;
//                if (cnt == 1)
//                    done <= 1;
//            end
//        end
//    end
//endmodule


////==============================================================
//// STUB: ALU_UNIT
//// Not really used here, keep minimal
////==============================================================
//module ALU_UNIT #(
//    parameter WID = 256,
//    parameter DEPTH = 32,
//    parameter REG_BANK = 5
//)(
//    input  wire         clk,
//    input  wire         rst,
//    input  wire         start,
//    input  wire         op,
//    input  wire [WID-1:0] px,
//    input  wire [WID-1:0] py,
//    input  wire [WID-1:0] pz,
//    input  wire [WID-1:0] pt,
//    input  wire [WID-1:0] qx,
//    input  wire [WID-1:0] qy,
//    input  wire [WID-1:0] qz,
//    input  wire [WID-1:0] qt,
//    output wire         done
//);
//    assign done = 1'b0;
//endmodule


////==============================================================
//// STUB: Interleaved_Modular_Multi
//// Behavior: Z = X * Y, done after 2 cycles
////==============================================================
//module Interleaved_Modular_Multi (
//    input  wire         clk,
//    input  wire         reset,
//    input  wire         start,
//    input  wire [255:0] X,
//    input  wire [255:0] Y,
//    output reg  [255:0] Z,
//    output reg          done
//);
//    reg [1:0] cnt;
//    reg [255:0] X_reg, Y_reg;

//    always @(posedge clk or posedge reset) begin
//        if (reset) begin
//            cnt   <= 0;
//            done  <= 0;
//            Z     <= 0;
//            X_reg <= 0;
//            Y_reg <= 0;
//        end else begin
//            done <= 0;

//            if (start) begin
//                X_reg <= X;
//                Y_reg <= Y;
//                cnt   <= 2;
//            end else if (cnt != 0) begin
//                cnt <= cnt - 1;
//                if (cnt == 1) begin
//                    Z    <= X_reg * Y_reg;
//                    done <= 1;
//                end
//            end
//        end
//    end
//endmodule


////==============================================================
//// STUB: invert
//// Behavior: result = a + 1, done after 2 cycles
////==============================================================
//module invert #(parameter WID = 256)(
//    input  wire         clk,
//    input  wire         rst,
//    input  wire         start,
//    input  wire [WID-1:0] a,
//    output reg          done,
//    output reg  [WID-1:0] result
//);
//    reg [1:0] cnt;
//    reg [WID-1:0] a_reg;

//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            cnt    <= 0;
//            done   <= 0;
//            result <= 0;
//            a_reg  <= 0;
//        end else begin
//            done <= 0;

//            if (start) begin
//                a_reg <= a;
//                cnt   <= 2;
//            end else if (cnt != 0) begin
//                cnt <= cnt - 1;
//                if (cnt == 1) begin
//                    result <= a_reg + 1;
//                    done   <= 1;
//                end
//            end
//        end
//    end
//endmodule
`timescale 1ns / 1ps

//==============================================================
// Testbench for point_multi_core
// Uses simple behavioral stubs for submodules
//==============================================================
module tb_point_multi_core;

    parameter WID = 256;
    parameter CLK_PERIOD = 10;

    reg              clk;
    reg              rst;
    reg              start;
    reg              valid;
    reg  [WID-1:0]   k;
    reg  [WID-1:0]   px, py;
    wire [WID-1:0]   qx, qy;
    wire             done;
    wire             ready;

    reg [WID-1:0] expected_qx;
    reg [WID-1:0] expected_qy;

    integer cycle_count;

    // DUT
    point_multi_core #(
        .WID(WID)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .valid(valid),
        .k(k),
        .px(px),
        .py(py),
        .qx(qx),
        .qy(qy),
        .done(done),
        .ready(ready)
    );

    //==========================================================
    // Clock
    //==========================================================
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    //==========================================================
    // Reset
    //==========================================================
    task apply_reset;
    begin
        rst   = 1'b1;
        start = 1'b0;
        valid = 1'b0;
        k     = 0;
        px    = 0;
        py    = 0;

        repeat (5) @(posedge clk);
        rst = 1'b0;
        repeat (2) @(posedge clk);
    end
    endtask

    //==========================================================
    // Handshake start-valid-ready
    // Chỉ nhận lệnh khi start=1, valid=1 và ready=1 cùng lúc
    //==========================================================
    task start_once;
    begin
        // đưa tín hiệu điều khiển lên trước cạnh clock
        @(negedge clk);
        start = 1'b1;
        valid = 1'b1;

        // chờ đến khi DUT sẵn sàng
        while (ready !== 1'b1)
            @(negedge clk);

        // tại cạnh lên kế tiếp sẽ xảy ra handshake
        @(posedge clk);

        // hạ tín hiệu sau khi đã handshake xong
        @(negedge clk);
        start = 1'b0;
        valid = 1'b0;
    end
    endtask

    //==========================================================
    // Compute expected according to stub behavior
    //==========================================================
    task calc_expected;
        input [255:0] k_in;
        input [255:0] px_in;
        input [255:0] py_in;
        reg   [255:0] pt_tmp;
        reg   [255:0] result_x_tmp;
        reg   [255:0] result_y_tmp;
        reg   [255:0] result_z_tmp;
        reg   [255:0] a_inv_tmp;
    begin
        pt_tmp       = px_in * py_in;     // stub mul for CALC_P
        result_x_tmp = px_in + k_in;      // stub Scalar_multi_SM
        result_y_tmp = py_in + k_in;
        result_z_tmp = pt_tmp + 5;
        a_inv_tmp    = result_z_tmp + 1;  // stub invert

        expected_qx  = result_x_tmp * a_inv_tmp;
        expected_qy  = result_y_tmp * a_inv_tmp;
    end
    endtask

    //==========================================================
    // Run one test
    //==========================================================
    task run_case;
        input [255:0] k_in;
        input [255:0] px_in;
        input [255:0] py_in;
    begin
        calc_expected(k_in, px_in, py_in);

        // chờ DUT rảnh rồi mới nạp dữ liệu
        wait(ready == 1'b1);

        @(negedge clk);
        k  = k_in;
        px = px_in;
        py = py_in;

        $display("==================================================");
        $display("Start test at time = %0t", $time);
        $display("k  = 0x%064h", k_in);
        $display("px = 0x%064h", px_in);
        $display("py = 0x%064h", py_in);
        $display("expected_qx = 0x%064h", expected_qx);
        $display("expected_qy = 0x%064h", expected_qy);

        start_once;

        cycle_count = 0;
        while (done == 1'b0 && cycle_count < 500) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
        end

        if (done) begin
            $display("DONE after %0d cycles", cycle_count);
            $display("qx = 0x%064h", qx);
            $display("qy = 0x%064h", qy);

            if ((qx === expected_qx) && (qy === expected_qy))
                $display("[PASS]");
            else
                $display("[FAIL]");
        end else begin
            $display("[FAIL] TIMEOUT");
        end

        repeat (5) @(posedge clk);
    end
    endtask

    //==========================================================
    // Monitor
    //==========================================================
    initial begin
        $monitor("time=%0t rst=%b start=%b valid=%b ready=%b done=%b state=%0d qx=%h qy=%h",
                 $time, rst, start, valid, ready, done, dut.state, qx, qy);
    end

    //==========================================================
    // Main
    //==========================================================
    initial begin
        apply_reset;

        run_case(256'd3,  256'd5,  256'd7);
        run_case(256'd1,  256'd10, 256'd20);
        run_case(256'd9,  256'd12, 256'd15);
        run_case(256'h11, 256'h22, 256'h33);

        #100;
        $finish;
    end

endmodule


//==============================================================
// STUB: Scalar_multi_SM
// Behavior:
//   result_x = px + k
//   result_y = py + k
//   result_z = pt + 5
//==============================================================
module Scalar_multi_SM (
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [255:0] k,
    input  wire [255:0] px,
    input  wire [255:0] py,
    input  wire [255:0] pz,
    input  wire [255:0] pt,
    output reg          done,
    output wire         rst_alu,
    output wire         start_alu,
    input  wire         alu_done,
    output wire         op_alu,
    output wire [255:0] qx_alu,
    output wire [255:0] qy_alu,
    output wire [255:0] qz_alu,
    output wire [255:0] qt_alu,
    output wire [255:0] px_alu,
    output wire [255:0] py_alu,
    output wire [255:0] pz_alu,
    output wire [255:0] pt_alu,
    output reg  [255:0] result_x,
    output reg  [255:0] result_y,
    output reg  [255:0] result_z,
    output reg  [255:0] result_t
);
    reg [1:0] cnt;

    assign rst_alu   = 1'b0;
    assign start_alu = 1'b0;
    assign op_alu    = 1'b0;
    assign qx_alu    = 256'd0;
    assign qy_alu    = 256'd0;
    assign qz_alu    = 256'd0;
    assign qt_alu    = 256'd0;
    assign px_alu    = 256'd0;
    assign py_alu    = 256'd0;
    assign pz_alu    = 256'd0;
    assign pt_alu    = 256'd0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt      <= 0;
            done     <= 0;
            result_x <= 0;
            result_y <= 0;
            result_z <= 0;
            result_t <= 0;
        end else begin
            done <= 0;

            if (start) begin
                cnt      <= 2;
                result_x <= px + k;
                result_y <= py + k;
                result_z <= pt + 5;
                result_t <= 256'd0;
            end else if (cnt != 0) begin
                cnt <= cnt - 1;
                if (cnt == 1)
                    done <= 1;
            end
        end
    end
endmodule


//==============================================================
// STUB: ALU_UNIT
// Not really used here, keep minimal
//==============================================================
module ALU_UNIT #(
    parameter WID = 256,
    parameter DEPTH = 32,
    parameter REG_BANK = 5
)(
    input  wire           clk,
    input  wire           rst,
    input  wire           start,
    input  wire           op,
    input  wire [WID-1:0] px,
    input  wire [WID-1:0] py,
    input  wire [WID-1:0] pz,
    input  wire [WID-1:0] pt,
    input  wire [WID-1:0] qx,
    input  wire [WID-1:0] qy,
    input  wire [WID-1:0] qz,
    input  wire [WID-1:0] qt,
    output wire           done
);
    assign done = 1'b0;
endmodule


//==============================================================
// STUB: Interleaved_Modular_Multi
// Behavior: Z = X * Y, done after 2 cycles
//==============================================================
module Interleaved_Modular_Multi (
    input  wire         clk,
    input  wire         reset,
    input  wire         start,
    input  wire [255:0] X,
    input  wire [255:0] Y,
    output reg  [255:0] Z,
    output reg          done
);
    reg [1:0] cnt;
    reg [255:0] X_reg, Y_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt   <= 0;
            done  <= 0;
            Z     <= 0;
            X_reg <= 0;
            Y_reg <= 0;
        end else begin
            done <= 0;

            if (start) begin
                X_reg <= X;
                Y_reg <= Y;
                cnt   <= 2;
            end else if (cnt != 0) begin
                cnt <= cnt - 1;
                if (cnt == 1) begin
                    Z    <= X_reg * Y_reg;
                    done <= 1;
                end
            end
        end
    end
endmodule


//==============================================================
// STUB: invert
// Behavior: result = a + 1, done after 2 cycles
//==============================================================
module invert #(parameter WID = 256)(
    input  wire           clk,
    input  wire           rst,
    input  wire           start,
    input  wire [WID-1:0] a,
    output reg            done,
    output reg  [WID-1:0] result
);
    reg [1:0] cnt;
    reg [WID-1:0] a_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt    <= 0;
            done   <= 0;
            result <= 0;
            a_reg  <= 0;
        end else begin
            done <= 0;

            if (start) begin
                a_reg <= a;
                cnt   <= 2;
            end else if (cnt != 0) begin
                cnt <= cnt - 1;
                if (cnt == 1) begin
                    result <= a_reg + 1;
                    done   <= 1;
                end
            end
        end
    end
endmodule