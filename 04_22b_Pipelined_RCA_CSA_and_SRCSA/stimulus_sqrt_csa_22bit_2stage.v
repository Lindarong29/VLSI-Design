`timescale 1 ns / 1 ps
module stimulus_sqrt_csa_22bit_2stage;

wire [22:0] sum_sqrt_csa;
reg  [21:0] a, b;
reg         clk, rstn;

reg  [22:0] mat_sum [0:99];
reg  [22:0] mat_sum_cmp;
reg  [21:0] mat_a   [0:99];
reg  [21:0] mat_b   [0:99];

sqrt_csa_22bit_2stage sqrt_csa(.sum(sum_sqrt_csa), .a(a), .b(b), .c_in(1'b0), .clk(clk), .rstn(rstn));

integer i, k;
integer err;

always #5 clk <= ~clk;

	initial	begin
		clk <= 1; rstn <= 0;
		#12 rstn <=1;
	end

	initial begin
		$readmemh("a_input_22b.txt", mat_a);
		$readmemh("b_input_22b.txt", mat_b);

		i = 0;
		#(20);
		for(i = 0; i < 100; i = i + 1) begin
			a = mat_a[i];
			b = mat_b[i];
			#(10);
		end
	end

	initial begin
		$readmemh("sum_output_23b.txt", mat_sum);

		k = 0;
		err = 0;
		#(40);
		for(k = 0; k < 100; k = k + 1) begin
			mat_sum_cmp = mat_sum[k];			
			#(2);
			if(sum_sqrt_csa != mat_sum_cmp) begin
				err = err + 1;
			end
			#(8);
		end
        #(10);
		$stop;
	end

endmodule
