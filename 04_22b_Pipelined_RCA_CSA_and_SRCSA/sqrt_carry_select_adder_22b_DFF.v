module sqrt_carry_select_adder_22b_DFF(
    output reg [22:0] sum,
    input      [21:0] a, b,
    input             c_in, clk, rstn
);

    reg [21:0] a_q, b_q;
    reg        c_in_q;

    wire [22:0] sum_d;

    sqrt_carry_select_adder_22b adder (sum_d, a_q, b_q, c_in_q);

    always @(posedge clk) begin
        if (!rstn) begin
            a_q    <= 22'b0;
            b_q    <= 22'b0;
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