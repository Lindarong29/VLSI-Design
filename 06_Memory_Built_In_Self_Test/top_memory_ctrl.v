`timescale 1ns/10ps
module top_memory_ctrl(
                        output [43:0]   out,
                        input           clk,  rstn
                      );

        rflp1024x44mx3 memory (
                                .DO   (memory_out),
                                .DIN  (d_mul_out),
                                .RA   (addr[9:3]),
                                .CA   (addr[2:0]),
                                .NWRT (nwrt),
                                .NCE  (nce),
                                .CLK  (clk)
                            );
        
        //SRAM 제어 신호
        wire        nce;
        wire        nwrt;

        //address
        reg [9:0] addr;

        //SRAM에서 Read한 data
        wire [43:0] memory_out;

        //mem out split
        wire [21:0] A; //mem out split 1
        wire [21:0] B; //mem out split 2
        wire [21:0] d_A; //mem out split 1
        wire [21:0] d_B; //mem out split 2
        
        assign A = memory_out[43:22];
        assign B = memory_out[21:0] ;

        //SRAM에 넣을 데이터(연산결과)
        reg [43:0] mul_out;
        reg [43:0] d_mul_out;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            nce <= 1'b0;
            nwrt<= 1'b0;
            memory_out <= 44'd0;
        end

    end

endmodule