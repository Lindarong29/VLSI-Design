module CSM_RCA_22bit_FF (out, a, b, clk, rstn);

	output reg [43:0] out;
	input  [21:0] a, b;
	input  clk, rstn;

	reg [21:0] a_q, b_q;
	wire [43:0] out_q;

	CSM_RCA_22bit csm (out_q, a_q, b_q);

	always @(posedge clk) begin
		if (!rstn) begin
	 	  a_q <= 22'b0;
	  	  b_q <= 22'b0;
		  out <= 44'b0;
		end
      		else begin
		  a_q <= a;
  		  b_q <= b;
		  out <= out_q;
		end
	end
endmodule	
