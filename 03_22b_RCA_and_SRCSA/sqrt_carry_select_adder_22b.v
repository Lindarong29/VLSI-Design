// ── 1bit full adder
module fulladd_gate(sum, c_out, a, b, c_in);
    output sum, c_out;
    input  a, b, c_in;
    wire s1, c1, s2;

    xor (s1, a, b);
    and (c1, a, b);
    and (s2, s1, c_in);
    xor (sum, s1, c_in);
    or  (c_out, s2, c1);
endmodule


// ── N-bit ripple
module RCA_nbit #(parameter WIDTH = 2) (
                        sum, c_out,
                        a, b, c_in
                 );

                output [WIDTH-1:0] sum;
                output           c_out;
                input  [WIDTH-1:0] a, b;
                input  c_in;

                wire   [WIDTH:0] carry;
                
            genvar i;
            generate
                for (i=0; i<WIDTH; i=i+1) begin : fa_chain
                    if (i == 0) // sum[0] 일 때는 c_in -> carry로 나가니까
                        fulladd_gate fa(sum[0], carry[0], a[0], b[0], c_in); 
                    else if (i == WIDTH-1) // 마지막은 c_out에 연결
                        fulladd_gate fa(sum[i], c_out, a[i], b[i], carry[i-1]);
                    else
                        fulladd_gate fa(sum[i], carry[i], a[i], b[i], carry[i-1]);    
                end
            endgenerate
                        
endmodule

// ── N-bit MUX
module mux2_gate #(parameter WIDTH = 1) (
    output [WIDTH-1:0] y,
    input  [WIDTH-1:0] d0, d1,
    input               sel
    );
    
    wire nsel;
    not (nsel, sel);

    wire [WIDTH-1:0] t0, t1;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : mux_bit
            and (t0[i], d0[i], nsel);   // sel=0이면 d0 통과
            and (t1[i], d1[i], sel);    // sel=1이면 d1 통과
            or  (y[i], t0[i], t1[i]);
        end
    endgenerate
endmodule

//SRCSA
module sqrt_carry_select_adder_22b (
    output  [22:0] sum,
    input   [21:0] a, b,
    input          c_in
    );

    //real carry
    wire c0, c1, c2, c3, c4;
    
    //dual carry
    wire c1a, c1b, c2a, c2b, c3a, c3b, c4a, c4b, c5a, c5b;
    
    //instance order reference
    //module RCA_nbit #() (sum,c_out, a,b,c_in)
    //module mux2_gate #() (y,d0,d1,sel)

    //Block [1:0] (2bit)
    RCA_nbit #(2) blk0 (sum0, c0, a[1:0], b[1:0], c_in);

    // Block1 [3:2] (2bit): dual + mux
    RCA_nbit #(2) blk1a(sum1a, c1a, a[3:2], b[3:2], 1'b0);
    RCA_nbit #(2) blk1b(sum1b, c1b, a[3:2], b[3:2], 1'b1);
    mux2_gate  #(2) mux1  (sum[3:2], c1, sum1a, sum1b, c0);
    mux2_gate  #(1) muxc1 (c1, c1a, c1b, c0);

    // Block2 [6:4] (3bit): dual + mux
    RCA_nbit #(3) blk2a(sum2a, c2a, a[6:4], b[6:4], 1'b0);
    RCA_nbit #(3) blk2b(sum2b, c2b, a[6:4], b[6:4], 1'b1);
    mux2_gate  #(3) mux2  (sum[6:4], sum2a, sum2b, c1);
    mux2_gate  #(1) muxc2 (c2, c2a, c2b, c1);

    // Block3 [10:7] (4bit): dual + mux
    RCA_nbit #(4) blk3a(sum3a, c3a, a[10:7], b[10:7], 1'b0);
    RCA_nbit #(4) blk3b(sum3b, c3b, a[10:7], b[10:7], 1'b1);
    mux2_gate  #(4) mux3  (sum[10:7], sum3a, sum3b, c2);
    mux2_gate  #(1) muxc3 (c3, c3a, c3b, c2);

    // Block4 [15:11] (5bit): dual + mux
    RCA_nbit #(5) blk4a(sum4a, c4a, a[15:11], b[15:11], 1'b0);
    RCA_nbit #(5) blk4b(sum4b, c4b, a[15:11], b[15:11], 1'b1);
    mux2_gate  #(5) mux4  (sum[15:11], sum4a, sum4b, c3);
    mux2_gate  #(1) muxc4 (c4, c4a, c4b, c3);

    // Block5 [21:16] (6bit): dual + mux, 최종 carry는 sum[22]에 바로 연결
    RCA_nbit #(6) blk5a(sum5a, c5a, a[21:16], b[21:16], 1'b0);
    RCA_nbit #(6) blk5b(sum5b, c5b, a[21:16], b[21:16], 1'b1);
    mux2_gate  #(6) mux5  (sum[21:16], sum5a, sum5b, c4);
    mux2_gate  #(1) muxc5 (sum[22], c5a, c5b, c4);

endmodule