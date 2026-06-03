`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2026 01:10:41 AM
// Design Name: 
// Module Name: Modular_Inversion_State_Machine
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

module Modular_Inversion_State_Machine#(parameter WIDTH = 256)(
    input  wire             clk,
    input  wire             reset,
    input  wire             start,
    input  wire [WIDTH-1:0] X,
    input  wire [WIDTH-1:0] Y,
    output reg  [WIDTH-1:0] Z,
    output reg              done
);

    localparam NUM_DIGITS = WIDTH / 3;   // 256/3 = 85  (giữ nguyên hành vi cũ: dùng 255 bit)
    localparam WID        = 260;

    localparam [3:0]
        IDLE          = 4'd0,
        INIT_RAM_PULSE= 4'd1,
        INIT_RAM_WAIT = 4'd2,
        PREP_DIGIT    = 4'd3,
        CSA1_STAGE    = 4'd4,
        CSA2_STAGE    = 4'd5,
        FINALIZE_PREP = 4'd6,
        FINALIZE_START= 4'd7,
        FINALIZE_WAIT = 4'd8,
        DONE_ST       = 4'd9;

    reg [3:0] state;
    reg [7:0] counter;

    reg [WID-1:0] C_reg, S_reg;

    // Giữ 255 bit đang xử lý, lấy digit từ MSB [254:252] rồi shift left 3 mỗi vòng
    reg [254:0] X_work;

    // Pipeline registers cho datapath
    reg [WID-1:0] c_shifted_reg, s_shifted_reg;
    reg [WID-1:0] ram_data_reg, rom_data_reg;
    reg [WID-1:0] csa1_sum_reg, csa1_carry_reg;
    reg [WID-1:0] Z_tmp_reg;

    reg  start_mod;
    wire done_mod;
    reg  ram_init_en;
    wire ram_done;

    wire [254:0] mod_p_result;

    // -------------------------------------------------------------------------
    // Combinational wires
    // -------------------------------------------------------------------------
    wire [2:0] digit_sel;
    wire [WID-1:0] ram_data_ext;
    wire [4:0] high_S, high_C;
    wire [4:0] N_index;
    wire [3:0] sel_comb;

    wire [WID-1:0] c_shifted_w, s_shifted_w;
    wire [WID-1:0] csa1_sum_w, csa1_carry_w;
    wire [WID-1:0] csa2_sum_w, csa2_carry_w;
    wire [WID-1:0] rom_data_comb;

    assign digit_sel   = X_work[254:252];
    assign ram_data_ext = {{(WID-WIDTH){1'b0}}, ram_data_out};

    assign high_S  = S_reg[WID-1:WIDTH-1];  // [259:255]
    assign high_C  = C_reg[WID-1:WIDTH-1];
    assign N_index = (high_S + high_C) & 5'b0_1111;
    assign sel_comb = N_index[3:0];

    // -------------------------------------------------------------------------
    // New modular reduction block
    // -------------------------------------------------------------------------
    mod_p_ed25519_seq u_mod_p (
        .clk  (clk),
        .rst  (reset),
        .start(start_mod),
        .X    ({252'b0, Z_tmp_reg}),   // 512 = 252 + 260
        .Z    (mod_p_result),
        .done (done_mod)
    );

    // -------------------------------------------------------------------------
    // Precomputed multiples of Y
    // init_en chỉ pulse 1 chu kỳ khi bắt đầu
    // -------------------------------------------------------------------------
    wire [WIDTH-1:0] ram_data_out;

    ramY_2 ramY (
        .clk     (clk),
        .rst     (reset),
        .Y       (Y),
        .init_en (ram_init_en),
        .addr    (digit_sel),
        .data_out(ram_data_out),
        .done    (ram_done)
    );

    // -------------------------------------------------------------------------
    // ROM correction term
    // -------------------------------------------------------------------------
    ROM rom2 (
        .sel (sel_comb),
        .data(rom_data_comb)
    );

    // -------------------------------------------------------------------------
    // Shift blocks
    // -------------------------------------------------------------------------
    Shift_mod #(.N(WID)) u_shift_c (
        .in (C_reg),
        .out(c_shifted_w)
    );

    Shift_mod #(.N(WID)) u_shift_s (
        .in (S_reg),
        .out(s_shifted_w)
    );

    // -------------------------------------------------------------------------
    // CSA stage 1
    // -------------------------------------------------------------------------
    CSA #(.WIDTH(WID)) u_csa1 (
        .in1   (c_shifted_reg),
        .in2   (s_shifted_reg),
        .in3   (ram_data_reg),
        .sum   (csa1_sum_w),
        .carry (csa1_carry_w)
    );

    // -------------------------------------------------------------------------
    // CSA stage 2
    // -------------------------------------------------------------------------
    CSA #(.WIDTH(WID)) u_csa2 (
        .in1   (csa1_sum_reg),
        .in2   (csa1_carry_reg),
        .in3   (rom_data_reg),
        .sum   (csa2_sum_w),
        .carry (csa2_carry_w)
    );

    // -------------------------------------------------------------------------
    // FSM
    // -------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state         <= IDLE;
            counter       <= 8'd0;
            done          <= 1'b0;
            start_mod     <= 1'b0;
            ram_init_en   <= 1'b0;
            Z             <= {WIDTH{1'b0}};
            C_reg         <= {WID{1'b0}};
            S_reg         <= {WID{1'b0}};
            X_work        <= 255'd0;
            c_shifted_reg <= {WID{1'b0}};
            s_shifted_reg <= {WID{1'b0}};
            ram_data_reg  <= {WID{1'b0}};
            rom_data_reg  <= {WID{1'b0}};
            csa1_sum_reg  <= {WID{1'b0}};
            csa1_carry_reg<= {WID{1'b0}};
            Z_tmp_reg     <= {WID{1'b0}};
        end else begin
            // default mỗi chu kỳ
            done        <= 1'b0;
            start_mod   <= 1'b0;
            ram_init_en <= 1'b0;

            case (state)
                IDLE: begin
                    C_reg   <= {WID{1'b0}};
                    S_reg   <= {WID{1'b0}};
                    counter <= NUM_DIGITS;

                    if (start) begin
                        X_work      <= X[254:0];   // giữ nguyên semantics của code cũ
                        ram_init_en <= 1'b1;       // pulse init RAM đúng 1 cycle
                        state       <= INIT_RAM_PULSE;
                    end
                end
                INIT_RAM_PULSE: begin
                    ram_init_en <= 1'b1;
                    state       <= INIT_RAM_WAIT;
                end
                INIT_RAM_WAIT: begin
                    if (ram_done) begin
                        counter <= NUM_DIGITS;
                        state   <= PREP_DIGIT;
                    end
                    else state       <= INIT_RAM_WAIT;
                end

                // Chu kỳ 1: chuẩn bị dữ liệu cho 1 digit
                PREP_DIGIT: begin
                    c_shifted_reg <= c_shifted_w;
                    s_shifted_reg <= s_shifted_w;
                    ram_data_reg  <= ram_data_ext;
                    rom_data_reg  <= rom_data_comb;
                    state         <= CSA1_STAGE;
                end

                // Chu kỳ 2: CSA tầng 1
                CSA1_STAGE: begin
                    csa1_sum_reg   <= csa1_sum_w;
                    csa1_carry_reg <= csa1_carry_w;
                    state          <= CSA2_STAGE;
                end

                // Chu kỳ 3: CSA tầng 2 + writeback
                CSA2_STAGE: begin
                    C_reg <= csa2_carry_w;
                    S_reg <= csa2_sum_w;

                    if (counter > 1) begin
                        counter <= counter - 1'b1;
                        X_work  <= {X_work[251:0], 3'b000}; // next radix-8 digit from MSB side
                        state   <= PREP_DIGIT;
                    end else begin
                        state   <= FINALIZE_PREP;
                    end
                end

                // Chốt adder cuối trước khi start mod_p
                FINALIZE_PREP: begin
                    Z_tmp_reg <= C_reg + S_reg;
                    state     <= FINALIZE_START;
                end

                // Pulse start cho mod_p sau khi Z_tmp_reg đã qua FF
                FINALIZE_START: begin
                    start_mod <= 1'b1;
                    state     <= FINALIZE_WAIT;
                end

                FINALIZE_WAIT: begin
                    if (done_mod) begin
                        Z     <= {1'b0, mod_p_result};
                        state <= DONE_ST;
                    end
                end

                DONE_ST: begin
                    done  <= 1'b1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
