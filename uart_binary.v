module uart_rx_fsm_binary #(
    parameter DATA_BITS = 8   // configurable data length
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,
    input  wire sample_tick,  // mid-bit sampling pulse
    output reg  rx_done,
    output reg  frame_error
);

    // -------------------------
    // State encoding (BINARY)
    // -------------------------
localparam IDLE  = 3'b000;
localparam START = 3'b001;
localparam DATA  = 3'b010;
localparam STOP  = 3'b011;
localparam DONE  = 3'b100;


    reg [2:0] state, next_state;
    reg [$clog2(DATA_BITS)-1:0] bit_cnt;

    // -------------------------
    // State register
    // -------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // -------------------------
    // Frame error register
    // -------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            frame_error <= 1'b0;
        else if (state == IDLE)
            frame_error <= 1'b0;   // clear for next frame
        else if (state == STOP && sample_tick && rx == 1'b0)
            frame_error <= 1'b1;   // bad stop bit
        else
            frame_error <= frame_error;
    end

    // -------------------------
    // Data bit counter
    // -------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            bit_cnt <= 0;
        else if (state == DATA && sample_tick)
            bit_cnt <= bit_cnt + 1'b1;
        else if (state != DATA)
            bit_cnt <= 0;
    end

    // -------------------------
    // Next-state logic
    // -------------------------
    always @(*) begin
        next_state = state;

        case (state)

            IDLE: begin
                if (rx == 1'b0)
                    next_state = START;
            end

            START: begin
                if (sample_tick) begin
                    if (rx == 1'b0)
                        next_state = DATA;   // valid start
                    else
                        next_state = IDLE;   // false start
                end
            end

            DATA: begin
                if (sample_tick && bit_cnt == DATA_BITS-1)
                    next_state = STOP;
            end

            STOP: begin
                if (sample_tick) begin
                    if (rx == 1'b1)
                        next_state = DONE;   // valid stop
                    else
                        next_state = IDLE;   // framing error
                end
            end

            DONE: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;

        endcase
    end

    // -------------------------
    // Output logic (Moore FSM)
    // -------------------------
    always @(*) begin
        rx_done = (state == DONE);
    end

endmodule
