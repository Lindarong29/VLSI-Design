module RCA_nbit #(parameter WIDTH = 2) 
                 (sum, c_out, a, b, c_in);

                output [WIDTH-1:0] sum;
                output           c_out;
                input  [WIDTH-1:0] a, b;
                input  c_in;

                wire   [WIDTH:0] carry;
                
            genvar i;
            generate
                for (i=0; i<WIDTH; i=i+1) begin : fa_chain
                    if (i == 0) // sum[0] 일 때는 c_in -> carry로 나가니까
                        fulladd_gate fa(sum[0], carry[0], a[0], b[0], c_in); 
                    else if (i == WIDTH-1) // 마지막은 c_out에 연결
                        fulladd_gate fa(sum[i], c_out, a[i], b[i], carry[i-1]);
                    else
                        fulladd_gate fa(sum[i], carry[i], a[i], b[i], carry[i-1]);    
                end
            endgenerate
                        
endmodule