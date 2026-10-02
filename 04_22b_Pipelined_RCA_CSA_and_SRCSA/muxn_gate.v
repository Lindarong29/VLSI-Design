module muxn_gate #(parameter WIDTH = 1) (
    output [WIDTH-1:0] y,
    input  [WIDTH-1:0] d0, d1,
    input               sel
    );
    
    wire nsel;
    not (nsel, sel);

    wire [WIDTH-1:0] t0, t1;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : mux_bit
            and (t0[i], d0[i], nsel);   // sel=0이면 d0 통과
            and (t1[i], d1[i], sel);    // sel=1이면 d1 통과
            or  (y[i], t0[i], t1[i]);
        end
    endgenerate
endmodule