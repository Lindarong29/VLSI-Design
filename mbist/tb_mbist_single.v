`timescale 1ns/10ps

module tb_mbist_single;

    logic clk;
    logic rstn;
    logic mbist_start;

    logic mbist_busy;
    logic mbist_done;
    logic mbist_fail;

    mbist_single dut (
        .clk        (clk),
        .rstn       (rstn),
        .mbist_start(mbist_start),
        .mbist_busy (mbist_busy),
        .mbist_done (mbist_done),
        .mbist_fail (mbist_fail)
    );

    initial begin
        clk = 1'b0;
        forever #1.5 clk = ~clk;
    end

    initial begin
        rstn        = 1'b0;
        mbist_start = 1'b0;

        repeat (5) @(posedge clk);
        rstn = 1'b1;

        @(posedge clk);
        mbist_start = 1'b1;

        @(posedge clk);
        mbist_start = 1'b0;

        wait (mbist_done);

        if (mbist_fail)
            $display("MBIST RESULT: FAIL");
        else
            $display("MBIST RESULT: PASS");

        #10;
        $finish;
    end

endmodule