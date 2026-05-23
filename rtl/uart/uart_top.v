module uart_top #(
    parameter CLKS_PER_BIT = 8   // use SAME value everywhere
)(
    input  wire clk,
    input  wire rst,

    // TX interface
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx_busy,
    output wire       tx_done,

    // RX interface
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       rx_busy,
    input  wire       rx_clear,   // CLEAR VALID

    // UART pins
    output wire uart_tx,
    input  wire  uart_rx_external // external RX (optional)
);

    wire uart_line;

    // =========================
    // UART TRANSMITTER
    // =========================
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_tx (
        .i_clk   (clk),
        .i_rst   (rst),
        .i_start (tx_start),
        .i_data  (tx_data),
        .o_tx    (uart_line),
        .o_busy  (tx_busy),
        .o_done  (tx_done)
    );

    assign uart_tx = uart_line;

    // =========================
    // UART RECEIVER
    // =========================
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_rx (
        .clk      (clk),
        .rst      (rst),
        .uart_rx  (uart_rx_external),  
        .rx_data  (rx_data),
        .rx_valid (rx_valid),
        .rx_busy  (rx_busy),
        .rx_clear (rx_clear)
    );

endmodule
