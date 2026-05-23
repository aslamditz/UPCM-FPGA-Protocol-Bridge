module uart_rx #(
    parameter CLKS_PER_BIT = 8
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       uart_rx,

    output reg  [7:0] rx_data,
    output reg        rx_valid,
    output reg        rx_busy,
    input  wire       rx_clear
);

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0]  state;
    reg [15:0] clk_cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  data_reg;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state    <= IDLE;
            clk_cnt  <= 0;
            bit_idx  <= 0;
            data_reg <= 0;
            rx_data  <= 0;
            rx_valid <= 0;
            rx_busy  <= 0;
        end else begin

            if (rx_clear)
                rx_valid <= 0;

            case (state)

            IDLE: begin
                rx_busy <= 0;
                clk_cnt <= 0;
                if (uart_rx == 0) begin
                    rx_busy <= 1;
                    state   <= START;
                end
            end

            START: begin
                if (clk_cnt == (CLKS_PER_BIT/2)) begin
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    state   <= DATA;
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            DATA: begin
                if (clk_cnt == CLKS_PER_BIT-1) begin
                    clk_cnt <= 0;
                    data_reg[bit_idx] <= uart_rx;
                    if (bit_idx == 7)
                        state <= STOP;
                    else
                        bit_idx <= bit_idx + 1;
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            STOP: begin
                if (clk_cnt == CLKS_PER_BIT-1) begin
                    rx_data  <= data_reg;
                    rx_valid <= 1;
                    rx_busy  <= 0;
                    clk_cnt  <= 0;      // ✅ FIX
                    state    <= IDLE;
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            endcase
        end
    end
endmodule
