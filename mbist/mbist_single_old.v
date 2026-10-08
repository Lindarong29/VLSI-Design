`timescale 1ns/10ps

module mbist_single (
    input  logic        clk,
    input  logic        rstn,
    input  logic        mbist_start,

    output logic        mbist_busy,
    output logic        mbist_done,
    output logic        mbist_fail
);

    localparam int ADDR_W = 10;
    localparam int DATA_W = 44;
    localparam int LAST_ADDR = 1023;

    //========================================
    // March C-  state
    //========================================
    typedef enum logic [3:0] {
        S_IDLE,
        S_W0_UP,
        S_R0W1_REQ_UP,
        S_R0W1_CMP_UP,
        S_W1_UP,
        S_R1W0_REQ_UP,
        S_R1W0_CMP_UP,
        S_W0_DOWN,
        S_R0W1_REQ_DOWN,
        S_R0W1_CMP_DOWN,
        S_W1_DOWN,
        S_R1W0_REQ_DOWN,
        S_R1W0_CMP_DOWN,
        S_R0_REQ_DOWN,
        S_R0_CMP_DOWN,
        S_DONE
    } state_t;

    
    //address(10-bit counter)
    logic [ADDR_W-1:0] addr;
    
    //state
    state_t state;
    
    //SRAM I
    logic [DATA_W-1:0] din;
    
    logic [DATA_W-1:0] memory_out;
    logic [DATA_W-1:0] expected_data;

    
    // SRAM control (mode)
    logic nce;
    logic nwrt;

    logic compare_enable;
    logic mismatch;

    rflp1024x44mx3 memory (
        .DO   (memory_out),
        .DIN  (din),
        .RA   (addr[9:3]),
        .CA   (addr[2:0]),
        .NWRT (nwrt),
        .NCE  (nce),
        .CLK  (clk)
    );

    assign nce = ~mbist_busy;

    assign mismatch =
        compare_enable && (memory_out != expected_data);

    always(*) begin
        din            = '0;
        expected_data  = '0;
        nwrt           = 1'b1;
        compare_enable = 1'b0;

        case (state)

            S_W0_UP: begin
                nwrt = 1'b0;
                din  = 44'h0;
            end

            S_R0W1_REQ_UP: begin
                nwrt = 1'b1;
            end

            S_R0W1_CMP_UP: begin
                nwrt           = 1'b0;
                din            = {DATA_W{1'b1}};
                expected_data  = 44'h0;
                compare_enable = 1'b1;
            end

            S_W1_UP: begin
                nwrt = 1'b0;
                din  = {DATA_W{1'b1}};
            end

            S_R1W0_REQ_UP: begin
                nwrt = 1'b1;
            end

            S_R1W0_CMP_UP: begin
                nwrt           = 1'b0;
                din            = 44'h0;
                expected_data  = {DATA_W{1'b1}};
                compare_enable = 1'b1;
            end

            S_W0_DOWN: begin
                nwrt = 1'b0;
                din  = 44'h0;
            end

            S_R0W1_REQ_DOWN: begin
                nwrt = 1'b1;
            end

            S_R0W1_CMP_DOWN: begin
                nwrt           = 1'b0;
                din            = {DATA_W{1'b1}};
                expected_data  = 44'h0;
                compare_enable = 1'b1;
            end

            S_W1_DOWN: begin
                nwrt = 1'b0;
                din  = {DATA_W{1'b1}};
            end

            S_R1W0_REQ_DOWN: begin
                nwrt = 1'b1;
            end

            S_R1W0_CMP_DOWN: begin
                nwrt           = 1'b0;
                din            = 44'h0;
                expected_data  = {DATA_W{1'b1}};
                compare_enable = 1'b1;
            end

            S_R0_REQ_DOWN: begin
                nwrt = 1'b1;
            end

            S_R0_CMP_DOWN: begin
                expected_data  = 44'h0;
                compare_enable = 1'b1;
            end

            default: begin
                nwrt           = 1'b1;
                compare_enable = 1'b0;
            end

        endcase
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state       <= S_IDLE;
            addr        <= '0;
            mbist_fail  <= 1'b0;
            mbist_done  <= 1'b0;
        end
        else begin
            mbist_done <= 1'b0;

            case (state)

                S_IDLE: begin
                    addr       <= '0;
                    mbist_fail <= 1'b0;

                    if (mbist_start) begin
                        state <= S_W0_UP;
                    end
                end

                S_W0_UP: begin
                    if (addr == LAST_ADDR) begin
                        addr  <= '0;
                        state <= S_R0W1_REQ_UP;
                    end
                    else begin
                        addr <= addr + 1'b1;
                    end
                end

                S_R0W1_REQ_UP: begin
                    state <= S_R0W1_CMP_UP;
                end

                S_R0W1_CMP_UP: begin
                    if (mismatch)
                        mbist_fail <= 1'b1;

                    state <= S_W1_UP;
                end

                S_W1_UP: begin
                    if (addr == LAST_ADDR) begin
                        addr  <= '0;
                        state <= S_R1W0_REQ_UP;
                    end
                    else begin
                        addr  <= addr + 1'b1;
                        state <= S_R0W1_REQ_UP;
                    end
                end

                S_R1W0_REQ_UP: begin
                    state <= S_R1W0_CMP_UP;
                end

                S_R1W0_CMP_UP: begin
                    if (mismatch)
                        mbist_fail <= 1'b1;

                    state <= S_W0_DOWN;
                end

                S_W0_DOWN: begin
                    if (addr == LAST_ADDR) begin
                        addr  <= LAST_ADDR;
                        state <= S_R0W1_REQ_DOWN;
                    end
                    else begin
                        addr <= addr + 1'b1;
                    end
                end

                S_R0W1_REQ_DOWN: begin
                    state <= S_R0W1_CMP_DOWN;
                end

                S_R0W1_CMP_DOWN: begin
                    if (mismatch)
                        mbist_fail <= 1'b1;

                    state <= S_W1_DOWN;
                end

                S_W1_DOWN: begin
                    if (addr == '0) begin
                        addr  <= LAST_ADDR;
                        state <= S_R1W0_REQ_DOWN;
                    end
                    else begin
                        addr <= addr - 1'b1;
                        state <= S_R0W1_REQ_DOWN;
                    end
                end

                S_R1W0_REQ_DOWN: begin
                    state <= S_R1W0_CMP_DOWN;
                end

                S_R1W0_CMP_DOWN: begin
                    if (mismatch)
                        mbist_fail <= 1'b1;

                    state <= S_R0_REQ_DOWN;
                end

                S_R0_REQ_DOWN: begin
                    state <= S_R0_CMP_DOWN;
                end

                S_R0_CMP_DOWN: begin
                    if (mismatch)
                        mbist_fail <= 1'b1;

                    state <= S_DONE;
                end

                S_DONE: begin
                    mbist_done <= 1'b1;
                    state      <= S_IDLE;
                end

                default: begin
                    state <= S_IDLE;
                end

            endcase
        end
    end

    assign mbist_busy = (state != S_IDLE) &&
                        (state != S_DONE);

endmodule