`timescale 1ns / 1ps

module ALU_UNIT #(
    parameter WID = 256,
    parameter DEPTH = 32,
    parameter REG_BANK = 5
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             start,
    input  wire             op,           // 00: ECPA, 01: ECPD
    input  wire [WID-1:0]   px, py, pz, pt,   // P1(X, Y, Z. T)
    output wire [WID-1:0]   qx, qy, qz, qt,  // Q1(X, Y, Z, T)
    output wire             done
);

    // Wires for register bank
    wire [REG_BANK-1:0]             reg_sel_a, reg_sel_b, reg_sel_w;
    wire [WID-1:0]         data_a, data_b;
    reg  [WID-1:0]         data_w;
    wire                   we_reg;
    wire [2:0]             din_sel;

    // ALU control
    wire                   alu_start;
    wire [1:0]             alu_op;
    wire [WID-1:0]         alu_result;
    wire                   alu_done;

    // FSM done signals
    wire                   done_ecpa, done_ecpd;
    wire [REG_BANK -1 :0] ecpa_sel_a, ecpa_sel_b, ecpa_sel_w;
    wire       ecpa_we;
    wire [2:0] ecpa_din_sel;
    wire       ecpa_alu_start;
    wire [1:0] ecpa_alu_op;
    
    wire [REG_BANK -1:0] ecpd_sel_a, ecpd_sel_b, ecpd_sel_w;
    wire       ecpd_we;
    wire [2:0] ecpd_din_sel;
    wire       ecpd_alu_start;
    wire [1:0] ecpd_alu_op;
    
    assign reg_sel_a    = (op == 1'b0) ? ecpa_sel_a    : ecpd_sel_a;
    assign reg_sel_b    = (op == 1'b0) ? ecpa_sel_b    : ecpd_sel_b;
    assign reg_sel_w    = (op == 1'b0) ? ecpa_sel_w    : ecpd_sel_w;
    assign we_reg       = (op == 1'b0) ? ecpa_we       : ecpd_we;
    assign din_sel      = (op == 1'b0) ? ecpa_din_sel  : ecpd_din_sel;
    assign alu_start    = (op == 1'b0) ? ecpa_alu_start: ecpd_alu_start;
    assign alu_op       = (op == 1'b0) ? ecpa_alu_op   : ecpd_alu_op;


    // Result selector based on FSM
    assign done = (op == 1'b0) ? done_ecpa : done_ecpd;

    // FSM instantiation
    ECPA_SM #(REG_BANK) ecpa_sm (
        .clk(clk),
        .rst(rst),
        .start(start & ~op),  // Only start if op == 0
        .src1_sel(ecpa_sel_a),
        .src2_sel(ecpa_sel_b),
        .dst_sel(ecpa_sel_w),
        .we(ecpa_we),
        .din_sel(ecpa_din_sel),
        .alu_start(ecpa_alu_start),
        .alu_op(ecpa_alu_op),
        .alu_done(alu_done),
        .done(done_ecpa)
    );

    ECPD_SM #(REG_BANK) ecpd_sm (
        .clk(clk),
        .rst(rst),
        .start(start & op),   // Only start if op == 1
        .src1_sel(ecpd_sel_a),
        .src2_sel(ecpd_sel_b),
        .dst_sel(ecpd_sel_w),
        .we(ecpd_we),
        .din_sel(ecpd_din_sel),
        .alu_start(ecpd_alu_start),
        .alu_op(ecpd_alu_op),
        .alu_done(alu_done),
        .done(done_ecpd)
    );

    // ALU module
    alu #(.WID(WID)) alu_core (
        .clk(clk),
        .rst(rst),
        .start(alu_start),
        .op(alu_op),
        .a(data_a),
        .b(data_b),
        .result(alu_result),
        .done(alu_done)
    );

    // Register bank
    regbank #(.WID(WID), .DEPTH(DEPTH), .REG_BANK(REG_BANK)) regfile (
        .clk(clk),
        .rst(rst),
        .we(we_reg),
        .src1_sel(reg_sel_a),
        .src2_sel(reg_sel_b),
        .dst_sel(reg_sel_w),
        .din(data_w),
        .Px(px),
        .Py(py),
        .Pz(pz),
        .Pt(pt),
        .src1_out(data_a),
        .src2_out(data_b),
        .qx(qx),
        .qy(qy),
        .qz(qz),
        .qt(qt)
    );
    
    // Write data to regfile
    always @(*) begin
    case (din_sel)
        3'b000: data_w = alu_result;
        3'b001: data_w = px;
        3'b010: data_w = py;
        3'b011: data_w = pz;
        3'b100: data_w = pt;
        default: data_w = 256'd0;
    endcase
end

endmodule
