`timescale 1ns/10ps
module top_memory_ctrl(
                        output [43:0]   out,
                        input           clk,  rstn
                      );

    //========================================
    // SRAM
    //========================================
        rflp1024x44mx3 memory (
                                .DO   (memory_out),
                                .DIN  (memory_in),
                                .RA   (addr[9:3]),
                                .CA   (addr[2:0]),
                                .NWRT (nwrt),
                                .NCE  (nce),
                                .CLK  (clk)
                            );
        
    //========================================
    // SRAM control
    //========================================
        //SRAM mode
        wire        nce;
        wire        nwrt;

        //address
        reg [9:0] addr;

        //SRAM ->
        wire [43:0] memory_in;
        wire [43:0] memory_out;


    //========================================
    // Split mem output
    //========================================
        //mem out split
        wire [21:0] A; //mem out split 1
        wire [21:0] B; //mem out split 2

        assign A = memory_out[43:22];
        assign B = memory_out[21:0] ;


    //========================================
    // Pipeline registers
    //========================================

        reg [21:0] d_A; //mem out split 1
        reg [21:0] d_B; //mem out split 2
        

        //mul result (to SRAM)
        reg [43:0] mul_out;
        //reg [43:0] d_mul_out;


    //========================================
    // state 
    //========================================        
        //MBIST Running state
        reg [1:0]  state_counter ;

    ////////////////////////////////////////////////////

    assign out = memory_out;
    assign memory_in = mul_out;
    //assign memory_in = d_mul_out;

    assign nce  = 1'b0;
    assign nwrt = (state_counter == 2'b11) ? 1'b0 : 1'b1;


    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            d_A         <= 22'd0;
            d_B         <= 22'd0;
            mul_out     <= 44'd0;
            addr        <= 10'd0;
        end
 
            else if (state_counter == 2'b00) begin
                //nce <= 0; nwrt <= 1;
                //SRAM에 addr 주고 read 결과 대기 
            end

            else if (state_counter == 2'b01) begin
                d_A <= A; 
                d_B <= B;
            end

            else if (state_counter == 2'b10) begin
                mul_out <= d_A * d_B;
            end

            else if (state_counter == 2'b11) begin
                //nce <= 0; nwrt <= 0;
                addr <= addr + 1;
            end
            
    end    

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state_counter <= 2'b00;
        end

        else if (state_counter == 2'b11) begin
             state_counter <= 2'b00;
        end

        else begin
            state_counter <= state_counter + 2'b01;
        end
    end
        
endmodule