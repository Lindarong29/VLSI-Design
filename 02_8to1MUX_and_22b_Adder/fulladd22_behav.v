module fulladd22_behav(
                        sum,
                        a, b, c_in
                        );
                        
        output  reg [22:0] sum;
        input       [21:0] a, b;
        input       c_in;

    always @(*) begin
        sum = a + b + c_in;
    end
endmodule

