`timescale 1ns / 1ps

module mod_p_ed25519_seq (
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [511:0] X,
    output reg  [254:0] Z,
    output reg          done
);
    // p = 2^255 - 19
    localparam [254:0] P = 255'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED;

    // FSM states
    localparam [2:0]
        IDLE    = 3'd0,
        LOAD    = 3'd1,
        STEP1   = 3'd2,
        STEP2   = 3'd3,
        REDUCE1 = 3'd4,
        REDUCE2 = 3'd5,
        DONE_ST = 3'd6;

    reg [2:0] state, next_state;

    // Split input X = X_low + 2^255 * X_high
    reg [254:0] X_low;
    reg [256:0] X_high;

    // First fold
    // temp1 = X_low + 19*X_high
    reg [260:0] temp1;

    // Split temp1 again
    reg [254:0] t1_low;
    reg [5:0]   t1_high;

    // Second fold
    // temp2 = t1_low + 19*t1_high
    reg [260:0] temp2;

    // Final candidate after at most one subtraction
    reg [254:0] z_candidate;

    // Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:    if (start) next_state = LOAD;
            LOAD:              next_state = STEP1;
            STEP1:             next_state = STEP2;
            STEP2:             next_state = REDUCE1;
            REDUCE1:           next_state = REDUCE2;
            REDUCE2:           next_state = DONE_ST;
            DONE_ST:           next_state = IDLE;
            default:           next_state = IDLE;
        endcase
    end

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Datapath + outputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done        <= 1'b0;
            Z           <= 255'd0;
            X_low       <= 255'd0;
            X_high      <= 257'd0;
            temp1       <= 261'd0;
            t1_low      <= 255'd0;
            t1_high     <= 6'd0;
            temp2       <= 261'd0;
            z_candidate <= 255'd0;
        end else begin
            // default
            done <= 1'b0;

            case (state)
                IDLE: begin
                    // chờ start
                end

                LOAD: begin
                    X_low  <= X[254:0];
                    X_high <= X[511:255];
                end

                STEP1: begin
                    // temp1 = X_low + 19 * X_high
                    // 19*x = (x<<4) + (x<<1) + x
                    temp1 <= {6'd0, X_low}
                           + ({4'd0, X_high} << 4)
                           + ({4'd0, X_high} << 1)
                           + ({4'd0, X_high});
                end

                STEP2: begin
                    // Fold lần 2 vì temp1 vẫn có thể vượt quá 255 bit
                    t1_low  <= temp1[254:0];
                    t1_high <= temp1[260:255];

                    temp2 <= {6'd0, temp1[254:0]}
                           + ({255'd0, temp1[260:255]} << 4)
                           + ({255'd0, temp1[260:255]} << 1)
                           + ({255'd0, temp1[260:255]});
                end

                REDUCE1: begin
                    // Sau 2 lần fold, giá trị đã rất nhỏ.
                    // Thực hiện 1 lần trừ P nếu cần.
                    if (temp2[254:0] >= P)
                        z_candidate <= temp2[254:0] - P;
                    else
                        z_candidate <= temp2[254:0];
                end

                REDUCE2: begin
                    // Thêm 1 lớp bảo hiểm: nếu vẫn còn >= P thì trừ tiếp.
                    // Điều này giúp chắc chắn hơn cho biên.
                    if (z_candidate >= P)
                        Z <= z_candidate - P;
                    else
                        Z <= z_candidate;
                end

                DONE_ST: begin
                    done <= 1'b1;
                end

                default: begin
                    // không làm gì
                end
            endcase
        end
    end

endmodule