`timescale 1ns/10ps

module tb_top_mbist;

    reg clk;
    reg rstn;
    reg mbist_start;

    wire [43:0] data_out;
    wire mbist_done;

    integer error_count;


    //========================================
    // DUT
    //========================================

    top_mbist DUT (
        .data_out    (data_out),
        .mbist_done  (mbist_done),
        .clk         (clk),
        .rstn        (rstn),
        .mbist_start (mbist_start)
    );


    //========================================
    // Clock
    //========================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    //========================================
    // Memory Check Task
    //========================================

    task check_memory;
        input [43:0] expected;

        integer i;
        integer errors;

        begin

            errors = 0;

            for (i = 0; i < 1024; i = i + 1) begin

                if (DUT.memory.array[i] !== expected) begin

                    errors = errors + 1;

                    if (errors <= 10) begin
                        $display(
                            "ERROR: addr=%0d expected=%h actual=%h",
                            i,
                            expected,
                            DUT.memory.array[i]
                        );
                    end

                end

            end

            if (errors == 0) begin
                $display(
                    "PASS: Memory[0:1023] = %h",
                    expected
                );
            end
            else begin
                $display(
                    "FAIL: %0d memory errors, expected=%h",
                    errors,
                    expected
                );

                error_count = error_count + errors;
            end

        end

    endtask


    //========================================
    // Test
    //========================================

    initial begin

        error_count = 0;

        rstn = 1'b0;
        mbist_start = 1'b0;

        // Reset
        #20;
        rstn = 1'b1;

        // Start MBIST
        #10;
        mbist_start = 1'b1;

        #10;
        mbist_start = 1'b0;


        //====================================
        // State 0 -> State 1
        // WRITE 000 completed
        //====================================

        wait (
            DUT.state_counter == 3'd1 &&
            DUT.addr_counter  == 10'd0
        );

        #1;

        $display("========================================");
        $display("STATE 0 COMPLETE : CHECK 000");
        $display("========================================");

        check_memory(44'h000_0000_0000);


        //====================================
        // State 2
        // WRITE FFF completed
        //====================================

        wait (
            DUT.state_counter == 3'd3 &&
            DUT.addr_counter  == 10'd0
        );

        #1;

        $display("========================================");
        $display("STATE 2 COMPLETE : CHECK FFF");
        $display("========================================");

        check_memory(44'hFFF_FFFF_FFFF);


        //====================================
        // State 4
        // WRITE 555 completed
        //====================================

        wait (
            DUT.state_counter == 3'd5 &&
            DUT.addr_counter  == 10'd0
        );

        #1;

        $display("========================================");
        $display("STATE 4 COMPLETE : CHECK 555");
        $display("========================================");

        check_memory(44'h555_5555_5555);


        //====================================
        // State 6
        // WRITE AAA completed
        //====================================

        wait (
            DUT.state_counter == 3'd7 &&
            DUT.addr_counter  == 10'd0
        );

        #1;

        $display("========================================");
        $display("STATE 6 COMPLETE : CHECK AAA");
        $display("========================================");

        check_memory(44'hAAA_AAAA_AAAA);


        //====================================
        // Wait MBIST Done
        //====================================

        wait(mbist_done == 1'b1);

        #10;

        $display("========================================");
        $display("           TEST COMPLETE");
        $display("========================================");

        if (error_count == 0)
            $display("***** ALL TESTS PASSED *****");
        else
            $display("***** TEST FAILED : %0d errors *****",
                     error_count);

        $stop;

    end

endmodule