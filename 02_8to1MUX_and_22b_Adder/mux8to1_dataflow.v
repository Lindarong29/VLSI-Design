module mux8to1_dataflow(
                        out,
                        i0, i1, i2, i3,
                        i4, i5, i6, i7,
                        s0, s1, s2
                        );

            output      out;
            input       i0, i1, i2, i3;
            input       i4, i5, i6, i7;
            input       s0, s1, s2;

assign out = (s2) ? ( s1 ? (s0 ? i7:i6)         // s2=1, s1=1, s0=1or0 (111, 110)
                         : (s0 ? i5:i4) )       // s2=1, s1=0, s0=1or0 (101, 100)
                  : ( s1 ? (s0 ? i3:i2)         // s2=0, s1=1, s0=1or0 (011, 010)
                         : (s0 ? i1:i0) );      // s2=0, s1=0, s0=1or0 (001, 000)

endmodule



