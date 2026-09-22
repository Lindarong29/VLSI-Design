module TFF(q, clk, rstn);

    output  q;
    input   clk,    rstn;

    wire    d;

    DFF dff0(q, d, clk, rstn);
    not n1(d, q);

endmodule

