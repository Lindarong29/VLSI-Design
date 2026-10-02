module mul_nbit #(parameter n=22) (out, a, b);

    input [n-1:0] a;
    input         b;
    
    output [n-1:0] out;
    
    genvar i;
    
    generate
      for (i=0; i<n; i=i+1)
        begin 
             and(out[i], a[i], b); 
        end
    endgenerate


endmodule
