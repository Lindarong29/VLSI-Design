`timescale 1ns / 1ps
module stimulus_fulladd22;

wire [22:0] sum;
reg [21:0]  a, b;

reg [22:0] mat_sum [0:99];
reg [22:0] mat_sum_cmp;
reg [21:0] mat_a [0:99];
reg [21:0] mat_b [0:99];

fulladd22_gate add0(.sum(sum), .a(a), .b(b), .c_in(1'b0));
//fulladd22_behav add1(.sum(sum), .a(a), .b(b), .c_in(1'b0));

integer i;
integer err;

initial
begin

	$readmemh("a_input.txt", mat_a);
	$readmemh("b_input.txt", mat_b);
	$readmemh("sum_output.txt", mat_sum);

	i = 0;
	err = 0;
	#(10);

	for(i = 0; i < 100; i = i + 1)
	begin
		a = mat_a[i];
		b = mat_b[i];

        #(0)
		mat_sum_cmp = mat_sum[i];
		if(sum != mat_sum_cmp)
			err = err + 1;
		#(10);
	end
    #(20)
    $stop;
end

endmodule
