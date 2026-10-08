//
// mismatch 신호가 combinational glitch 때문에 튐 (expexted_data보다 memory_out이 약~간 느려서)

`timescale 1ns/10ps

module mbist_single (
    input  logic        clk,
    input  logic        rstn,
    input  logic        mbist_start,

    output logic        mbist_busy,
    output logic        mbist_done,
    output logic        mbist_fail
);

    localparam int ADDR_W     = 10;
    localparam int DATA_W     = 44;
    localparam int LAST_ADDR  = 1023;

    localparam logic [DATA_W-1:0] PATTERN_0 =
        44'h000_0000_0000;

    localparam logic [DATA_W-1:0] PATTERN_1 =
        44'hFFF_FFFF_FFFF;


    // ============================================================
    // March C- State
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
    logic              compare_enable;
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
    //
    // MBIST가 동작하는 동안 SRAM enable
    // ============================================================

    assign nce = ~mbist_busy;


    // ============================================================
    // Compare
    // ============================================================

    assign mismatch =
        compare_enable &&
        (memory_out != expected_data);


    // ============================================================
    // SRAM control signals
    //
    // NWRT = 0 : Write
    // NWRT = 1 : Read
    // ============================================================

    always_comb begin

        // Default
        din           = PATTERN_0;
        expected_data = PATTERN_0;

        nwrt          = 1'b1;
        compare_enable = 1'b0;


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
            //
            // REQ  : SRAM READ
            // CMP  : compare with 0 + SRAM WRITE 1
            // ====================================================

            S_R0W1_REQ_UP: begin

                nwrt = 1'b1;

            end


            S_R0W1_CMP_UP: begin

                nwrt           = 1'b0;
                din            = PATTERN_1;

                expected_data  = PATTERN_0;
                compare_enable = 1'b1;

            end


            // ====================================================
            // M2 : ↑ r1 w0
            //
            // REQ  : SRAM READ
            // CMP  : compare with 1 + SRAM WRITE 0
            // ====================================================

            S_R1W0_REQ_UP: begin

                nwrt = 1'b1;

            end


            S_R1W0_CMP_UP: begin

                nwrt           = 1'b0;
                din            = PATTERN_0;

                expected_data  = PATTERN_1;
                compare_enable = 1'b1;

            end


            // ====================================================
            // M3 : ↓ r0 w1
            // ====================================================

            S_R0W1_REQ_DOWN: begin

                nwrt = 1'b1;

            end


            S_R0W1_CMP_DOWN: begin

                nwrt           = 1'b0;
                din            = PATTERN_1;

                expected_data  = PATTERN_0;
                compare_enable = 1'b1;

            end


            // ====================================================
            // M4 : ↓ r1 w0
            // ====================================================

            S_R1W0_REQ_DOWN: begin

                nwrt = 1'b1;

            end


            S_R1W0_CMP_DOWN: begin

                nwrt           = 1'b0;
                din            = PATTERN_0;

                expected_data  = PATTERN_1;
                compare_enable = 1'b1;

            end


            // ====================================================
            // M5 : ↓ r0
            //
            // REQ  : SRAM READ
            // CMP  : compare with 0
            //
            // 마지막 element이므로 WRITE 없음
            // ====================================================

            S_R0_REQ_DOWN: begin

                nwrt = 1'b1;

            end


            S_R0_CMP_DOWN: begin

                nwrt           = 1'b1;

                expected_data  = PATTERN_0;
                compare_enable = 1'b1;

            end


            default: begin

                nwrt           = 1'b1;
                din            = PATTERN_0;
                expected_data  = PATTERN_0;
                compare_enable = 1'b0;

            end

        endcase

    end


    // ============================================================
    // FSM
    // ============================================================

    always_ff @(posedge clk or negedge rstn) begin

        if (!rstn) begin

            state      <= S_IDLE;
            addr       <= '0;

            mbist_fail <= 1'b0;
            mbist_done <= 1'b0;

        end

        else begin

            // DONE은 1 cycle pulse
            mbist_done <= 1'b0;


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
                        //
                        // M1도 ↑ 방향이므로
                        // address를 0으로 되돌림

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

                    // 현재 addr에 대해 READ 수행
                    //
                    // 다음 state에서 memory_out 비교

                    state <= S_R0W1_CMP_UP;

                end


                S_R0W1_CMP_UP: begin

                    // READ 결과 비교
                    if (mismatch)
                        mbist_fail <= 1'b1;


                    if (addr == LAST_ADDR) begin

                        // M1 완료
                        //
                        // M2도 ↑ 방향
                        // address = 0

                        addr  <= '0;
                        state <= S_R1W0_REQ_UP;

                    end

                    else begin

                        // 다음 address
                        addr  <= addr + 1'b1;
                        state <= S_R0W1_REQ_UP;

                    end

                end


                // =================================================
                // M2 : ↑ r1 w0
                // =================================================

                S_R1W0_REQ_UP: begin

                    state <= S_R1W0_CMP_UP;

                end


                S_R1W0_CMP_UP: begin

                    // READ 결과가 1인지 확인
                    if (mismatch)
                        mbist_fail <= 1'b1;


                    if (addr == LAST_ADDR) begin

                        // M2 완료
                        //
                        // M3는 ↓ 방향이므로
                        // address = 1023에서 시작

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
                // 1023 → 1022 → ... → 0
                // =================================================

                S_R0W1_REQ_DOWN: begin

                    state <= S_R0W1_CMP_DOWN;

                end


                S_R0W1_CMP_DOWN: begin

                    // READ 결과가 0인지 확인
                    if (mismatch)
                        mbist_fail <= 1'b1;


                    if (addr == '0) begin

                        // M3 완료
                        //
                        // M4도 ↓ 방향
                        // 다시 1023에서 시작

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

                    state <= S_R1W0_CMP_DOWN;

                end


                S_R1W0_CMP_DOWN: begin

                    // READ 결과가 1인지 확인
                    if (mismatch)
                        mbist_fail <= 1'b1;


                    if (addr == '0) begin

                        // M4 완료
                        //
                        // M5도 ↓ 방향
                        // 1023부터 시작

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
                // =================================================

                S_R0_REQ_DOWN: begin

                    // READ request
                    state <= S_R0_CMP_DOWN;

                end


                S_R0_CMP_DOWN: begin

                    // 마지막 READ 결과 확인
                    if (mismatch)
                        mbist_fail <= 1'b1;


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