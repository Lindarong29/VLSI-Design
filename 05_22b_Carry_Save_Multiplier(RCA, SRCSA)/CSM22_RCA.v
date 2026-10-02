

module CSM_RCA_22bit (out, a, b);
    
    output [43:0] out;
    input  [21:0] a, b;

    wire [21:0] aa [1:21];
    wire [21:0] c  [1:21];
    wire [20:0] s  [0:21];

    //Multipiler
    genvar mi;
    generate
      for (mi=0; mi<22; mi=mi+1)
        begin : Multipiler
		if (mi == 0) 
                	mul_nbit mul ({s[0], out[0]}, a, b[0] );

		else 
                	mul_nbit mul (aa[mi], a, b[mi]);  
       end
    endgenerate

    //Add
    genvar ai;
    generate
        for (ai = 1; ai < 22; ai = ai+1) begin : FullAdder
            if (ai == 1)
                fulladd_nbit_gate fa({s[1], out[1]}, c[1], aa[1], s[0], 0);        
            else 
                fulladd_nbit_gate fa({s[ai], out[ai]}, c[ai], aa[ai], s[ai-1], c[ai-1]); 
        end
    endgenerate

    //
    RCA_22 fin (out[43:22], c[21], s[21]);

endmodule

module RCA_22(sum, a, b);

    output [21:0] sum;
    input [21:0] a;
    input [20:0] b;

    wire [21:0] out;
    wire x;

    genvar rcai;
    generate
        for (rcai = 0; rcai < 22; rcai = rcai+1) begin : FA
            if (rcai == 0) 
                fulladd_gate fa(sum[0], out[0], a[0], b[0], 1'b0);        
		

	    else if (rcai == 21)
                fulladd_gate fa(sum[21], x, a[21], 1'b0, out[20]);
	

	    else 
                fulladd_gate fa(sum[rcai], out[rcai], a[rcai], b[rcai], out[rcai-1]); 
                
	end
    endgenerate
endmodule
