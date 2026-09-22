module DFF(q, d, clk, rstn);

    output  q;
    input   d,  clk,  rstn;

    reg     q;

    always @ (negedge   clk)
    begin
        if(!rstn)
            q <= 1'b0;
        else
            q <= d;
    end

endmodule


