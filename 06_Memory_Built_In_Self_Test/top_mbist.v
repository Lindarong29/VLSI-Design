`timescale 1ns/10ps

module top_mbist(
                    output [43:0] data_out,
                    output    reg mbist_done,
                    input         clk,
                    input         rstn,
                    input         mbist_start
				);

    //주소(10-bit counter), 상태(state counter)
    reg [9:0] addr_counter  ;
    reg [2:0] state_counter ;

    //SRAM에 넣을 데이터
    reg [43:0] data_in;
    
    //SRAM 제어 신호
    wire        nce;
    wire        nwrt;

    //SRAM에서 나오는 데이터 받아
    wire [43:0] memory_out;
    
    //MBIST Running state
    reg        mbist_running;

    rflp1024x44mx3 memory (
                            .DO   (memory_out),
                            .DIN  (data_in),
                            .RA   (addr_counter[9:3]),
                            .CA   (addr_counter[2:0]),
                            .NWRT (nwrt),
                            .NCE  (nce),
                            .CLK  (clk)
                          );

// READ output
    assign data_out = memory_out;

// MBIST Running state
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            mbist_running <= 1'b0;
            mbist_done    <= 1'b0;
        end

        else if (mbist_start && !mbist_running) begin // MBIST START
            mbist_running <= 1'b1;
            mbist_done    <= 1'b0;
        end
        else if ( mbist_running &&
                 (state_counter == 3'b111) &&
                 (addr_counter == 10'd1023) ) begin
            mbist_running <= 1'b0;
            mbist_done    <= 1'b1;
        end

    end

// SRAM Enable
    assign nce = ~mbist_running;


//Addr counter + State counter 
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            addr_counter  <= 10'd0;
            state_counter <= 3'b000;
        end

        else if(mbist_running) begin 
                if (addr_counter == 10'd1023) begin
                    addr_counter  <= 10'd0;
                    state_counter <= state_counter + 3'd1;
                end

                else begin
                    addr_counter <= addr_counter + 10'd1;
                end
        end
    end

    
//Read_Write
    assign nwrt = state_counter[0];



//MUX
    always @(*) begin
        case (state_counter[2:1])
            2'b00: data_in = 44'h00000000000;
            2'b01: data_in = 44'hFFFFFFFFFFF;
            2'b10: data_in = 44'h55555555555;
            2'b11: data_in = 44'hAAAAAAAAAAA;
            default: data_in = 44'h00000000000;
        endcase
    end


endmodule