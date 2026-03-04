`timescale 1ns/1ps

module uart_rx_fsm_binary_tb;

    reg clk;
    reg rst;
    reg rx;
    reg sample_tick;

    wire rx_done;
    wire frame_error;

    // DUT
    uart_rx_fsm_binary #(
        .DATA_BITS(8)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .sample_tick(sample_tick),
        .rx_done(rx_done),
        .frame_error(frame_error)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // one sampling tick
    task tick;
    begin
        sample_tick = 1'b1;
        #10;
        sample_tick = 1'b0;
        #10;
    end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        rx = 1;
        sample_tick = 0;

        // reset
        #20 rst = 0;

        // -------------------------
        // TEST 1: Valid frame
        // -------------------------
        rx = 0;        // start bit
        tick();

        repeat (8) begin
            tick();    // data bits
        end

        rx = 1;        // stop bit
        tick();

        #40;

        // -------------------------
        // TEST 2: False start
        // -------------------------
        rx = 0;
        tick();
        rx = 1;        // glitch
        tick();

        #40;

        // -------------------------
        // TEST 3: Frame error
        // -------------------------
        rx = 0;
        tick();

        repeat (8) begin
            tick();
        end

        rx = 0;        // invalid stop bit
        tick();

        #50;
        $finish;
    end

endmodule
