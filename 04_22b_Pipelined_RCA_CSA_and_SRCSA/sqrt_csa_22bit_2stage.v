module sqrt_csa_22bit_2stage(
    output  reg [22:0] sum,
    input       [21:0] a, b,
    input              c_in, clk, rstn
);


//input FF
    reg [21:0] a_q, b_q;
    reg        c_in_q;
    always @(posedge clk) begin
        if (!rstn) begin 
            a_q<=0; 
            b_q<=0; 
            c_in_q<=0; 
        end
        else begin 
            a_q<=a; 
            b_q<=b; 
            c_in_q<=c_in; 
        end
    end


    // ── Stage1: Block0,1,2는 완결, Block3,4,5는 앞 3비트(lo)만 ──
    wire [1:0] sum0_s; wire c0;
    RCA_nbit #(2) blk0(sum0_s, c0, a_q[1:0], b_q[1:0], c_in_q);

    wire [1:0] sum1a,sum1b,sum1_s; wire c1a,c1b,c1;
    RCA_nbit #(2) blk1a(sum1a,c1a,a_q[3:2],b_q[3:2],1'b0);
    RCA_nbit #(2) blk1b(sum1b,c1b,a_q[3:2],b_q[3:2],1'b1);
    mux2_gate #(2) mux1(sum1_s, sum1a, sum1b, c0);
    mux2_gate #(1) muxc1(c1, c1a, c1b, c0);

    wire [2:0] sum2a,sum2b,sum2_s; wire c2a,c2b,c2;
    RCA_nbit #(3) blk2a(sum2a,c2a,a_q[6:4],b_q[6:4],1'b0);
    RCA_nbit #(3) blk2b(sum2b,c2b,a_q[6:4],b_q[6:4],1'b1);
    mux2_gate #(3) mux2(sum2_s, sum2a, sum2b, c1);
    mux2_gate #(1) muxc2(c2, c2a, c2b, c1);

    // Block3 (4=3+1): lo만 stage1
    wire [2:0] sum3a_lo, sum3b_lo; wire c3a_lo, c3b_lo;
    RCA_nbit #(3) blk3a_lo(sum3a_lo, c3a_lo, a_q[9:7], b_q[9:7], 1'b0);
    RCA_nbit #(3) blk3b_lo(sum3b_lo, c3b_lo, a_q[9:7], b_q[9:7], 1'b1);

    // Block4 (5=3+2): lo만 stage1
    wire [2:0] sum4a_lo, sum4b_lo; wire c4a_lo, c4b_lo;
    RCA_nbit #(3) blk4a_lo(sum4a_lo, c4a_lo, a_q[13:11], b_q[13:11], 1'b0);
    RCA_nbit #(3) blk4b_lo(sum4b_lo, c4b_lo, a_q[13:11], b_q[13:11], 1'b1);

    // Block5 (6=3+3): lo만 stage1
    wire [2:0] sum5a_lo, sum5b_lo; wire c5a_lo, c5b_lo;
    RCA_nbit #(3) blk5a_lo(sum5a_lo, c5a_lo, a_q[18:16], b_q[18:16], 1'b0);
    RCA_nbit #(3) blk5b_lo(sum5b_lo, c5b_lo, a_q[18:16], b_q[18:16], 1'b1);

    // ── 중간 FF: ①블록 간 carry, ②완결된 블록 출력, ③나머지 비트 입력+부분결과 ──
    reg [1:0] sum0_q, sum1_q; reg [2:0] sum2_q; reg c2_q;
    reg [2:0] sum3a_lo_q, sum3b_lo_q; reg c3a_lo_q, c3b_lo_q;
    reg [2:0] sum4a_lo_q, sum4b_lo_q; reg c4a_lo_q, c4b_lo_q;
    reg [2:0] sum5a_lo_q, sum5b_lo_q; reg c5a_lo_q, c5b_lo_q;
    reg a3_hi_q, b3_hi_q;
    reg [1:0] a4_hi_q, b4_hi_q;
    reg [2:0] a5_hi_q, b5_hi_q;

    always @(posedge clk) begin
        if (!rstn) begin
            sum0_q<=0; sum1_q<=0; sum2_q<=0; c2_q<=0;
            sum3a_lo_q<=0; sum3b_lo_q<=0; c3a_lo_q<=0; c3b_lo_q<=0;
            sum4a_lo_q<=0; sum4b_lo_q<=0; c4a_lo_q<=0; c4b_lo_q<=0;
            sum5a_lo_q<=0; sum5b_lo_q<=0; c5a_lo_q<=0; c5b_lo_q<=0;
            a3_hi_q<=0; b3_hi_q<=0; a4_hi_q<=0; b4_hi_q<=0; a5_hi_q<=0; b5_hi_q<=0;
        end else begin
            sum0_q<=sum0_s; sum1_q<=sum1_s; sum2_q<=sum2_s;      // ② 밸런싱
            c2_q<=c2;                                             // ① 중간 carry
            sum3a_lo_q<=sum3a_lo; sum3b_lo_q<=sum3b_lo; c3a_lo_q<=c3a_lo; c3b_lo_q<=c3b_lo;
            sum4a_lo_q<=sum4a_lo; sum4b_lo_q<=sum4b_lo; c4a_lo_q<=c4a_lo; c4b_lo_q<=c4b_lo;
            sum5a_lo_q<=sum5a_lo; sum5b_lo_q<=sum5b_lo; c5a_lo_q<=c5a_lo; c5b_lo_q<=c5b_lo;
            a3_hi_q<=a_q[10];    b3_hi_q<=b_q[10];                // ③ 나머지 입력
            a4_hi_q<=a_q[15:14]; b4_hi_q<=b_q[15:14];
            a5_hi_q<=a_q[21:19]; b5_hi_q<=b_q[21:19];
        end
    end

    // ── Stage2: 나머지 비트 완성 + 각 블록 select ──
    wire sum3a_hi, sum3b_hi, c3a, c3b, c3;
    fulladd_gate fa3a(sum3a_hi, c3a, a3_hi_q, b3_hi_q, c3a_lo_q);
    fulladd_gate fa3b(sum3b_hi, c3b, a3_hi_q, b3_hi_q, c3b_lo_q);
    wire [3:0] sum3_s;
    mux2_gate #(4) mux3(sum3_s, {sum3a_hi,sum3a_lo_q}, {sum3b_hi,sum3b_lo_q}, c2_q);
    mux2_gate #(1) muxc3(c3, c3a, c3b, c2_q);

    wire [1:0] sum4a_hi, sum4b_hi; wire c4a, c4b, c4;
    RCA_nbit #(2) fa4a(sum4a_hi, c4a, a4_hi_q, b4_hi_q, c4a_lo_q);
    RCA_nbit #(2) fa4b(sum4b_hi, c4b, a4_hi_q, b4_hi_q, c4b_lo_q);
    wire [4:0] sum4_s;
    mux2_gate #(5) mux4(sum4_s, {sum4a_hi,sum4a_lo_q}, {sum4b_hi,sum4b_lo_q}, c3);
    mux2_gate #(1) muxc4(c4, c4a, c4b, c3);

    wire [2:0] sum5a_hi, sum5b_hi; wire c5a, c5b, c_out_final;
    RCA_nbit #(3) fa5a(sum5a_hi, c5a, a5_hi_q, b5_hi_q, c5a_lo_q);
    RCA_nbit #(3) fa5b(sum5b_hi, c5b, a5_hi_q, b5_hi_q, c5b_lo_q);
    wire [5:0] sum5_s;
    mux2_gate #(6) mux5(sum5_s, {sum5a_hi,sum5a_lo_q}, {sum5b_hi,sum5b_lo_q}, c4);
    mux2_gate #(1) muxc5(c_out_final, c5a, c5b, c4);

    // ── 출력 FF ──
    always @(posedge clk) begin
        if (!rstn) sum <= 0;
        else sum <= {c_out_final, sum5_s, sum4_s, sum3_s, sum2_q, sum1_q, sum0_q};
    end
endmodule
