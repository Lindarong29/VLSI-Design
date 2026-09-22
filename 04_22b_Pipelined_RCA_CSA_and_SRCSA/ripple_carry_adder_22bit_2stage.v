module ripple_carry_adder_22bit_2stage(
    output  reg [22:0] sum,
    input       [21:0] a, b,
    input              c_in, clk, rstn
);


//default input FF (black)
    reg [21:0] a_q, b_q;
    reg        c_in_q;
    
    always @(posedge clk) begin
        if (!rstn) begin
            a_q <= 0; b_q <= 0; c_in_q <= 0;
        end 
        
        else begin
            a_q <= a;
            b_q <= b;
            c_in_q <= c_in;
        end
    end

// 11-bit RCA (LSB)
    wire [10:0] sum_lsb;
    wire        c_mid;
    RCA_nbit #(11) lsb_adder(sum_lsb, c_mid, a_q[10:0], b_q[10:0], c_in_q);

    // ── 빨간 FF 3개: 중간(carry), LSB출력, MSB입력, 같은 always에
    reg [10:0] sum_lsb_q; 
    reg        c_mid_q;
    reg [10:0] a_msb_q, b_msb_q;

    always @(posedge clk) begin
        if (!rstn) begin
            sum_lsb_q <= 0;  c_mid_q <= 0;
            a_msb_q   <= 0;  b_msb_q <= 0;
        end else begin
            sum_lsb_q <= sum_lsb;      // LSB 결과를 한 박자 늦춤 (그림의 sum[10:0] 위 빨간 FF)
            c_mid_q   <= c_mid;        // 중간 carry FF (그림 가운데 빨간 FF)
            a_msb_q   <= a_q[21:11];   // MSB 입력, 2번째 latch (그림의 a[21:11] 아래 빨간 FF)
            b_msb_q   <= b_q[21:11];
        end
    end

    // 11-bit RCA (MSB)
    wire [10:0] sum_msb;
    wire        c_out;
    RCA_nbit #(11) msb_adder(sum_msb, c_out, a_msb_q, b_msb_q, c_mid_q);

    // final output
    always @(posedge clk) begin
        if (!rstn)
            sum <= 0;
        else
            sum <= {c_out, sum_msb, sum_lsb_q};
    end

endmodule