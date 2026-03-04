module onehot #(
    parameter DATA_BITS = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,
    input  wire sample_tick,
    output reg  rx_done,
    output reg  frame_error
);

    // One-hot state encoding
    localparam IDLE  = 5'b00001;
    localparam START = 5'b00010;
    localparam DATA  = 5'b00100;
    localparam STOP  = 5'b01000;
    localparam DONE  = 5'b10000;

    reg [4:0] state, next_state;
    reg [$clog2(DATA_BITS)-1:0] bit_cnt;

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Frame error register
    always @(posedge clk or posedge rst) begin
        if (rst)
            frame_error <= 1'b0;
        else if (state == IDLE)
            frame_error <= 1'b0;
        else if (state == STOP && sample_tick && rx == 1'b0)
            frame_error <= 1'b1;
    end

    // Bit counter
    always @(posedge clk or posedge rst) begin
        if (rst)
            bit_cnt <= 0;
        else if (state == DATA && sample_tick)
            bit_cnt <= bit_cnt + 1'b1;
        else if (state != DATA)
            bit_cnt <= 0;
    end

    // Next-state logic
    always @(*) begin
        next_state = state;

        case (state)
            IDLE:  if (rx == 1'b0) next_state = START;

            START: if (sample_tick)
                        next_state = (rx == 1'b0) ? DATA : IDLE;

            DATA:  if (sample_tick && bit_cnt == DATA_BITS-1)
                        next_state = STOP;

            STOP:  if (sample_tick)
                        next_state = (rx == 1'b1) ? DONE : IDLE;

            DONE:  next_state = IDLE;

            default: next_state = IDLE;
        endcase
    end

    // Output logic (Moore)
    always @(*) begin
        rx_done = (state == DONE);
    end

endmodule
