`timescale 1ns / 1ps

module stimulus_mux8to1;

    reg i0, i1, i2, i3, i4, i5, i6, i7;
    reg s0, s1, s2;
    wire gate_out , behav_out;

    //mux8to1_gate gate0 (gate_out , i0, i1, i2, i3, i4, i5, i6, i7, s0, s1, s2);
    //mux8to1_behav beha0 (behav_out , i0, i1, i2, i3, i4, i5, i6, i7, s0, s1, s2);

    mux8to1_gate  gate0  (.out( gate_out), .i0(i0), .i1(i1), .i2(i2), .i3(i3), .i4(i4), .i5(i5),
                        .i6(i6), .i7(i7), .s0(s0), .s1(s1), .s2(s2));
    mux8to1_behav beha0  (.out(behav_out), .i0(i0), .i1(i1), .i2(i2), .i3(i3), .i4(i4), .i5(i5),
                        .i6(i6), .i7(i7), .s0(s0), .s1(s1), .s2(s2));


    always #10 s0 = ~s0;
    always #20 s1 = ~s1;
    always #40 s2 = ~s2;

    initial
    begin
        {i0, i1, i2, i3, i4, i5, i6, i7} = 8'b01010101;
        {s0, s1, s2} = 3'b0;
        #200
        $stop;
    end

endmodule