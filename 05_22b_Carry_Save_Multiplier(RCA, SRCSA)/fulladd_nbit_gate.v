
module fulladd_nbit_gate #(parameter n=22) (
                        sum, c_out,
                        a, b, c_in
                     );

                output [n-1:0] sum;                 
		output c_out;                   
                input  [n-1:0] a, b;
                input  c_in;

                wire   [n-1:0] carry;
                
            genvar i;
            generate
                for (i=0; i <n; i=i+1) begin : fa22
                    if (i == 0) 
     		        fulladd_gate fa(sum[0], carry[0], a[0], b[0], c_in);
                    else if (i == n-1) 
     			fulladd_gate fa(sum[i], c_out, a[i], b[i], carry[i-1]); 
                    else
                        fulladd_gate fa(sum[i], carry[i], a[i], b[i], carry[i-1]);
                end
            endgenerate
                        
endmodule
