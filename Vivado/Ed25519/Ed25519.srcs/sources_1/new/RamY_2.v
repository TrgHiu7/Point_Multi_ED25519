`timescale 1ns / 1ps

module ramY_2 (
    input  wire        clk,
    input  wire        rst,
    input  wire        init_en,
    input  wire [255:0] Y,
    input  wire [2:0]  addr,
    output reg  [255:0] data_out,
    output wire        done      // <--- thêm tín hiệu done
);

    reg [255:0] mem [0:7];      // RAM 8 x 256-bit
    reg [255:0] Y_reg;
    reg [2:0]   i;
    reg         loading;
    reg [1:0]   stage;         // 0: mult, 1: store result
    reg [511:0] mult_result;

    // Control for modular reduction
    reg         start_mod;
    wire        done_mod;
    wire [254:0] reduced_mod_p;

    // Done signal when loading is finished
    assign done = ~loading;

    mod_p_ed25519_seq mod_p (
        .clk(clk),
        .rst(rst),
        .start(start_mod),
        .X(mult_result),
        .Z(reduced_mod_p),
        .done(done_mod)
    );
    reg [511:0] Y_mul_wire;
    wire [511:0] Y_ext = {256'b0, Y_reg};
    always @(*) begin
        case (i)
            3'd0: Y_mul_wire = 512'd0;
            3'd1: Y_mul_wire = Y_ext;
            3'd2: Y_mul_wire = Y_ext << 1;
            3'd3: Y_mul_wire = (Y_ext << 1) + Y_ext;
            3'd4: Y_mul_wire = Y_ext << 2;
            3'd5: Y_mul_wire = (Y_ext << 2) + Y_ext;
            3'd6: Y_mul_wire = (Y_ext << 2) + (Y_ext << 1);
            3'd7: Y_mul_wire = (Y_ext << 2) + (Y_ext << 1) + Y_ext;
            default: Y_mul_wire = 512'd0;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Y_reg       <= 256'd0;
            i           <= 3'd0;
            loading     <= 1'b0;
            stage       <= 2'b0;
            start_mod   <= 1'b0;
            mult_result <= 512'd0;
        end else begin
            start_mod <= 1'b0;
            if (init_en && !loading) begin
                Y_reg     <= Y;
                i         <= 3'd0;
                loading   <= 1'b1;
                stage     <= 2'd0;
            end 
            else if (loading) begin
                case(stage)
                    2'd0: begin
                        mult_result <= Y_mul_wire;
                        stage       <= 2'd1;
                    end
                    2'd1: begin
                        start_mod <= 1'b1;
                        stage     <= 2'd2;
                    end
                    2'd2: begin
                        if(done_mod)begin
                            mem[i] <= {1'b0, reduced_mod_p};
                            if(i == 3'd7)begin
                                loading <= 1'b0;
                            end else begin
                                i   <= i + 3'd1;
                                stage <= 2'd0;
                            end
                        end
                    end
                    default: begin
                        stage <= 2'd0;
                    end
                endcase
             
            
            end
        end
    end

    // RAM read (pure combinational)
    always @(*) begin
        data_out = mem[addr];
    end

endmodule
