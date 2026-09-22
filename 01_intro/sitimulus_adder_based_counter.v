`timescale 1ns/1ps

module sitimulus_adder_based_counter;

    reg     clk, rstn;
    wire    [7:0] q_rca;
    wire    [7:0] q_abc;
    
    ripple_carry_counter_8bit counter1 (q_rca, clk, rstn);
    adder_based_counter_8bit  counter2 (q_abc, clk, rstn);

    initial begin
        clk = 1'b0;
    end
    
    always
        #5 clk = ~clk;

    initial begin
        rstn = 1'b0;
        #15 rstn = 1'b1;
        #60 rstn = 1'b0;
        #10 rstn = 1'b1;
        #680 $stop;
    end

endmodule