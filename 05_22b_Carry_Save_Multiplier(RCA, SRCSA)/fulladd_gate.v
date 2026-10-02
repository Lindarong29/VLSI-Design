module fulladd_gate(
                    sum, c_out,
                    a, b, c_in
                   );

                output    sum, c_out;
                input     a, b, c_in;

                wire s1, c1, s2;

            xor (s1, a, b);
            and (c1, a, b);
            and (s2, s1, c_in);
            xor (sum, s1, c_in);
            xor (c_out, s2, c1);

endmodule


module fulladd4_gate(
                        sum, c_out,
                        a, b, c_in
                     );

                output [3:0] sum;
                output c_out;
                input  [3:0] a, b;
                input  c_in;

                wire   [3:0] carry;
                
            fulladd fa0(sum[0], c1, a[0], b[0], c_in);
            fulladd fa1(sum[1], c2, a[1], b[1], c1);
            fulladd fa2(sum[2], c3, a[2], b[2], c2);
            fulladd fa3(sum[3], c_out, a[3], b[3], c3);
                        
endmodule

module fulladd22_gate(
                        sum,
                        a, b, c_in
                     );

                output [22:0] sum; /*22bit sum + 1bit carry = 23bit ! 
                                     c_out을 따로 두지 않고*/
                input  [21:0] a, b;
                input  c_in;

                wire   [21:0] carry;
                
            genvar i;
            generate
                for (i=0; i <22; i=i+1) begin : fa22
                    if (i == 0) // sum[0] 일 때는 c_in -> carry로 나가니까
                        fulladd_gate fa(sum[0], carry[0], a[0], b[0], c_in);
                    else if (i == 21) // c_out을 sum[22]에 바로 연결
                        fulladd_gate fa(sum[21], sum[22], a[21], b[21], carry[20]); 
                    else
                        fulladd_gate fa(sum[i], carry[i], a[i], b[i], carry[i-1]);
                end
            endgenerate
                        
endmodule


