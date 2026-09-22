`timescale 1ns/10ps
module stimulus_Top_memory_control;

	reg clk;
	reg rstn;
	wire [44-1:0] out;
	reg [44-1:0] mat_output [0:1023];
	reg [44-1:0] mat_out; 
	
	initial	begin
		clk <= 1;
		rstn <= 0;
		#10
		rstn <= 1;
		#82010 $stop;
	end
	
	always #5 clk <= ~clk;
	
	top_memory_ctrl TOP_MEM_TEST(out, clk, rstn);

	integer i = 0;
	integer err = 0;
	
	initial $readmemh("input.txt", TOP_MEM_TEST.memory.array);
	initial $readmemh("output.txt", mat_output);
	
	initial	begin
    #(40970);
		for(i = 0; i < 1024; i = i + 1)
		begin
			mat_out <= mat_output[i];
			#(10);
			if(out != mat_out) err = err + 1;
			#(30);
		end
	end
	
	
endmodule