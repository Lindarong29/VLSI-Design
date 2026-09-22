module mux8to1_gate(
                        out,
                        i0, i1, i2, i3,
                        i4, i5, i6, i7
                        s0, s1, s2
                    );

            output      out;

            input       i0, i1, i2, i3;
            input       i4, i5, i6, i7;
            input       s0, s1, s2;

            wire s0n,s1n,s2n;
            wire w0,w1,w2,w3,w4,w5,w6,w7;

    // 1) select 보수 만들기 (다이어그램의 not 게이트 단계)
    not (s0n,s0);   // s0n = s0'
    not (s1n,s1);   // s1n = s1'
    not (s2n,s2);   // s2n = s2'

    // 2) 부울식의 각 minterm을 AND 게이트로 하나씩 (다이어그램의 and 게이트 단계)
    and (w0,i0,s2n,s1n,s0n);  // w0 = i0·s2'·s1'·s0'  ← 부울식 1항
    and (w1,i1,s2n,s1n,s0);   // w1 = i1·s2'·s1'·s0   ← 부울식 2항
    and (w2,i2,s2n,s1,s0n);
    and (w3,i3,s2n,s1,s0);
    and (w4,i4,s2,s1n,s0n);
    and (w5,i5,s2,s1n,s0);
    and (w6,i6,s2,s1,s0n);
    and (w7,i7,s2,s1,s0);     // w7 = i7·s2·s1·s0     ← 부울식 8항

    // 3) 8개 minterm을 전부 더하기 (다이어그램의 or 게이트 단계)
    or (y, w0,w1,w2,w3,w4,w5,w6,w7);   // y = w0+w1+...+w7

endmodule

