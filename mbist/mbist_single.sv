`timescale 1ns/10ps

module mbist_single (
    input  logic        clk,
    input  logic        rstn,
    input  logic        mbist_start,

    output logic        mbist_busy,
    output logic        mbist_done,
    output logic        mbist_fail
);

    localparam int ADDR_W    = 10;
    localparam int DATA_W    = 44;
    localparam int LAST_ADDR = 1023;

    localparam logic [DATA_W-1:0] PATTERN_0 =
        44'h000_0000_0000;

    localparam logic [DATA_W-1:0] PATTERN_1 =
        44'hFFF_FFFF_FFFF;


    // ============================================================
    // March C-
    //
    // M0 : ↑ w0
    // M1 : ↑ r0 w1
    // M2 : ↑ r1 w0
    // M3 : ↓ r0 w1
    // M4 : ↓ r1 w0
    // M5 : ↓ r0
    // ============================================================

    typedef enum logic [3:0] {

        S_IDLE,

        // M0 : ↑ w0
        S_W0_UP,

        // M1 : ↑ r0 w1
        S_R0W1_REQ_UP,
        S_R0W1_CMP_UP,

        // M2 : ↑ r1 w0
        S_R1W0_REQ_UP,
        S_R1W0_CMP_UP,

        // M3 : ↓ r0 w1
        S_R0W1_REQ_DOWN,
        S_R0W1_CMP_DOWN,

        // M4 : ↓ r1 w0
        S_R1W0_REQ_DOWN,
        S_R1W0_CMP_DOWN,

        // M5 : ↓ r0
        S_R0_REQ_DOWN,
        S_R0_CMP_DOWN,

        S_DONE

    } state_t;


    state_t state;


    // ============================================================
    // Address
    // ============================================================

    logic [ADDR_W-1:0] addr;


    // ============================================================
    // SRAM interface
    // ============================================================

    logic [DATA_W-1:0] din;
    logic [DATA_W-1:0] memory_out;

    logic              nce;
    logic              nwrt;


    // ============================================================
    // Compare
    // ============================================================

    logic [DATA_W-1:0] expected_data;

    // Registered mismatch
    logic              mismatch;


    // ============================================================
    // SRAM
    // ============================================================

    rflp1024x44mx3 memory (
        .DO   (memory_out),
        .DIN  (din),
        .RA   (addr[9:3]),
        .CA   (addr[2:0]),
        .NWRT (nwrt),
        .NCE  (nce),
        .CLK  (clk)
    );


    // ============================================================
    // SRAM Enable
    //
    // NCE = 0 : Enable
    // NCE = 1 : Disable
    // ============================================================

    assign nce = ~mbist_busy;


    // ============================================================
    // SRAM Control
    //
    // NWRT = 0 : WRITE
    // NWRT = 1 : READ
    // ============================================================

    always_comb begin

        // Default
        din           = PATTERN_0;
        expected_data = PATTERN_0;
        nwrt          = 1'b1;


        case (state)

            // ====================================================
            // M0 : ↑ w0
            // ====================================================

            S_W0_UP: begin

                nwrt = 1'b0;
                din  = PATTERN_0;

            end


            // ====================================================
            // M1 : ↑ r0 w1
            // ====================================================

            S_R0W1_REQ_UP: begin

                // READ
                nwrt = 1'b1;

            end


            S_R0W1_CMP_UP: begin

                // COMPARE with 0
                // WRITE 1
                nwrt          = 1'b0;
                din           = PATTERN_1;
                expected_data = PATTERN_0;

            end


            // ====================================================
            // M2 : ↑ r1 w0
            // ====================================================

            S_R1W0_REQ_UP: begin

                // READ
                nwrt = 1'b1;

            end


            S_R1W0_CMP_UP: begin

                // COMPARE with 1
                // WRITE 0
                nwrt          = 1'b0;
                din           = PATTERN_0;
                expected_data = PATTERN_1;

            end


            // ====================================================
            // M3 : ↓ r0 w1
            // ====================================================

            S_R0W1_REQ_DOWN: begin

                // READ
                nwrt = 1'b1;

            end


            S_R0W1_CMP_DOWN: begin

                // COMPARE with 0
                // WRITE 1
                nwrt          = 1'b0;
                din           = PATTERN_1;
                expected_data = PATTERN_0;

            end


            // ====================================================
            // M4 : ↓ r1 w0
            // ====================================================

            S_R1W0_REQ_DOWN: begin

                // READ
                nwrt = 1'b1;

            end


            S_R1W0_CMP_DOWN: begin

                // COMPARE with 1
                // WRITE 0
                nwrt          = 1'b0;
                din           = PATTERN_0;
                expected_data = PATTERN_1;

            end


            // ====================================================
            // M5 : ↓ r0
            // ====================================================

            S_R0_REQ_DOWN: begin

                // READ
                nwrt = 1'b1;

            end


            S_R0_CMP_DOWN: begin

                // COMPARE with 0
                // No WRITE
                nwrt          = 1'b1;
                expected_data = PATTERN_0;

            end


            default: begin

                nwrt          = 1'b1;
                din           = PATTERN_0;
                expected_data = PATTERN_0;

            end

        endcase

    end


    // ============================================================
    // FSM
    // ============================================================

    always_ff @(posedge clk or negedge rstn) begin

        if (!rstn) begin

            state       <= S_IDLE;
            addr        <= '0;

            mbist_fail  <= 1'b0;
            mbist_done  <= 1'b0;
            mismatch    <= 1'b0;

        end

        else begin

            // DONE은 1 clock pulse
            mbist_done <= 1'b0;

            // 기본값:
            // mismatch는 CMP state에서만 1이 될 수 있도록
            // 매 clock마다 0으로 초기화
            mismatch <= 1'b0;


            case (state)


                // =================================================
                // IDLE
                // =================================================

                S_IDLE: begin

                    addr       <= '0;
                    mbist_fail <= 1'b0;

                    if (mbist_start) begin

                        state <= S_W0_UP;

                    end

                end


                // =================================================
                // M0 : ↑ w0
                //
                // 0 → 1 → ... → 1023
                // =================================================

                S_W0_UP: begin

                    if (addr == LAST_ADDR) begin

                        // M0 완료
                        // M1 시작은 address 0

                        addr  <= '0;
                        state <= S_R0W1_REQ_UP;

                    end

                    else begin

                        addr <= addr + 1'b1;

                    end

                end


                // =================================================
                // M1 : ↑ r0 w1
                // =================================================

                S_R0W1_REQ_UP: begin

                    // READ request
                    //
                    // SRAM의 read latency를 고려하여
                    // 다음 state에서 compare

                    state <= S_R0W1_CMP_UP;

                end


                S_R0W1_CMP_UP: begin

                    // 실제 compare 결과를 register에 저장
                    if (memory_out != expected_data) begin

                        mismatch   <= 1'b1;
                        mbist_fail <= 1'b1;

                    end


                    if (addr == LAST_ADDR) begin

                        // M1 완료
                        // M2 시작 address = 0

                        addr  <= '0;
                        state <= S_R1W0_REQ_UP;

                    end

                    else begin

                        addr  <= addr + 1'b1;
                        state <= S_R0W1_REQ_UP;

                    end

                end


                // =================================================
                // M2 : ↑ r1 w0
                // =================================================

                S_R1W0_REQ_UP: begin

                    // READ request
                    state <= S_R1W0_CMP_UP;

                end


                S_R1W0_CMP_UP: begin

                    // memory_out == 1인지 확인
                    if (memory_out != expected_data) begin

                        mismatch   <= 1'b1;
                        mbist_fail <= 1'b1;

                    end


                    if (addr == LAST_ADDR) begin

                        // M2 완료
                        // M3는 DOWN 방향
                        // 따라서 1023에서 시작

                        addr  <= LAST_ADDR;
                        state <= S_R0W1_REQ_DOWN;

                    end

                    else begin

                        addr  <= addr + 1'b1;
                        state <= S_R1W0_REQ_UP;

                    end

                end


                // =================================================
                // M3 : ↓ r0 w1
                //
                // 1023 → ... → 0
                // =================================================

                S_R0W1_REQ_DOWN: begin

                    // READ request
                    state <= S_R0W1_CMP_DOWN;

                end


                S_R0W1_CMP_DOWN: begin

                    // memory_out == 0인지 확인
                    if (memory_out != expected_data) begin

                        mismatch   <= 1'b1;
                        mbist_fail <= 1'b1;

                    end


                    if (addr == '0) begin

                        // M3 완료
                        // M4도 DOWN
                        // 1023에서 시작

                        addr  <= LAST_ADDR;
                        state <= S_R1W0_REQ_DOWN;

                    end

                    else begin

                        addr  <= addr - 1'b1;
                        state <= S_R0W1_REQ_DOWN;

                    end

                end


                // =================================================
                // M4 : ↓ r1 w0
                // =================================================

                S_R1W0_REQ_DOWN: begin

                    // READ request
                    state <= S_R1W0_CMP_DOWN;

                end


                S_R1W0_CMP_DOWN: begin

                    // memory_out == 1인지 확인
                    if (memory_out != expected_data) begin

                        mismatch   <= 1'b1;
                        mbist_fail <= 1'b1;

                    end


                    if (addr == '0) begin

                        // M4 완료
                        // M5 시작 address = 1023

                        addr  <= LAST_ADDR;
                        state <= S_R0_REQ_DOWN;

                    end

                    else begin

                        addr  <= addr - 1'b1;
                        state <= S_R1W0_REQ_DOWN;

                    end

                end


                // =================================================
                // M5 : ↓ r0
                //
                // 1023 → ... → 0
                // =================================================

                S_R0_REQ_DOWN: begin

                    // READ request
                    state <= S_R0_CMP_DOWN;

                end


                S_R0_CMP_DOWN: begin

                    // memory_out == 0인지 확인
                    if (memory_out != expected_data) begin

                        mismatch   <= 1'b1;
                        mbist_fail <= 1'b1;

                    end


                    if (addr == '0) begin

                        state <= S_DONE;

                    end

                    else begin

                        addr  <= addr - 1'b1;
                        state <= S_R0_REQ_DOWN;

                    end

                end


                // =================================================
                // DONE
                // =================================================

                S_DONE: begin

                    mbist_done <= 1'b1;

                    state <= S_IDLE;

                end


                // =================================================
                // Default
                // =================================================

                default: begin

                    state <= S_IDLE;
                    addr  <= '0;

                end

            endcase

        end

    end


    // ============================================================
    // MBIST BUSY
    // ============================================================

    assign mbist_busy =
        (state != S_IDLE) &&
        (state != S_DONE);


endmodule