module ripple_carry_adder_22b (
    output  reg [22:0]  sum,
    input       [21:0]  a, b,
    input               c_in, clk, rstn
);

reg             c_in_q;
reg     [21:0]  a_q, b_q;
wire    [22:0]  sum_d;

fulladd22_gate  adder (.sum(sum_d), .a(a), .b(b), .c_in(c_in));

always @(posedge clk) begin
    if (!rstn) begin
        a_q    <= 21'b0;
        b_q    <= 21'b0;
        c_in_q <= 1'b0;
        sum    <= 23'b0;
    end
    else begin
        a_q    <= a;
        b_q    <= b;
        c_in_q <= c_in;
        sum    <= sum_d;
    end
end

endmodule

