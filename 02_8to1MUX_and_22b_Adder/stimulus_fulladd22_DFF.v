`timescale 1 ns / 1 ps
module stimulus_fulladd22_DFF;

wire [22:0] sum;
reg  [21:0] a, b;
reg         clk, rstn;

reg  [22:0] mat_sum [0:99];
reg  [22:0] mat_sum_cmp;
reg  [21:0] mat_a   [0:99];
reg  [21:0] mat_b   [0:99];

fulladd22_DFF add0(.sum(sum), .a(a), .b(b), .c_in(1'b0), .clk(clk), .rstn(rstn));

integer i;
integer err;

initial
    clk = 1'b1;

always
    #5 clk = ~clk;

initial
begin
        rstn = 1'b0;
    #0  rstn = 1'b1;

    $readmemh("a_input.txt",    mat_a);
    $readmemh("b_input.txt",    mat_b);
    $readmemh("sum_output.txt", mat_sum);
    
    i = 0;
    err = 0;
    #(10);

    for(i=0 ; i<101 ; i=i+1)
    begin
        a = mat_a[i];
        b = mat_b[i];
        mat_sum_cmp = mat_sum[i-1];
        #(2)
        if(sum != mat_sum_cmp) err = err + 1;
        #(8);
    end
    #(20)
    $stop;
end

endmodule
