module adder_based_counter_8bit (q, clk, rstn);

    output  [7:0]    q;
    input   clk, rstn ;

    reg     [7:0]    q;

    always @(negedge clk)
        begin
            if(!rstn)
                q <= 8'b00000000;
            else
                q <= q + 1'b1;
        end

endmodule    
            