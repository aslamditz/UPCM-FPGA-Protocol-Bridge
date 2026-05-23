// ============================================================
// MPCU TOP - PRIORITY BASED PROTOCOL CONVERTER
// ============================================================

module mpcu_top #(
    parameter UART_CLKS_PER_BIT = 8
)(

    input  wire        clk,
    input  wire        rst,

    input  wire [1:0]  cose,

    // ================= UART =================
    input  wire        uart_rx,
    output wire        uart_tx,

    // ================= SPI ==================
    inout  wire        spi_miso,
    inout  wire        spi_mosi,
    inout  wire        spi_sclk,
    inout  wire        spi_cs_n,

    // ================= I2C ==================
    inout  wire        i2c_sda,
    inout  wire        i2c_scl,

    // ================= LED OUTPUT =================
    output wire [9:0]  led
);

    // ======================================================
    // BRIDGE WIRES
    // ======================================================

    wire [7:0] bridge_data;
    wire       bridge_valid;
    wire [1:0] source_id;

    // ======================================================
    // SOURCE RX WIRES
    // ======================================================

    wire [7:0] uart_rx_data;
    wire       uart_rx_valid;

    wire [7:0] spi_rx_data;
    wire       spi_rx_valid;

    wire [7:0] i2c_ext_data;
    wire       i2c_ext_valid;

    // ======================================================
    // BUFFER OUTPUT WIRES
    // ======================================================

    wire [7:0] uart_data;
    wire       uart_valid;

    wire [7:0] spi_data;
    wire       spi_valid;

    wire [7:0] i2c_data;
    wire       i2c_valid;

    // ======================================================
    // CONTROLLER WIRES
    // ======================================================

    wire uart_start;
    wire spi_start;
    wire i2c_start;

    wire uart_done;
    wire spi_done;
    wire i2c_done;

    // ======================================================
    // LED DISPLAY
    // ======================================================

    assign led[7:0] = 8'b10101010;
    assign led[8]   = cose[0];
    assign led[9]   = cose[1];
    // ======================================================
    // UART MODULE
    // ======================================================

    uart_top #(
        .CLKS_PER_BIT(UART_CLKS_PER_BIT)
    ) uart_inst (
        .clk(clk),
        .rst(rst),

        .tx_start(uart_start),
        .tx_data(uart_data),
        .tx_busy(),
        .tx_done(uart_done),

        .rx_data(uart_rx_data),
        .rx_valid(uart_rx_valid),
        .rx_busy(),
        .rx_clear(bridge_valid),

        .uart_tx(uart_tx),
        .uart_rx_external(uart_rx)
    );

    // ======================================================
    // SPI MODULE
    // ======================================================

    spi_top_combined spi_inst (
        .clk(clk),
        .rst(rst),

        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_sclk(spi_sclk),
        .spi_cs_n(spi_cs_n),

        .rx_data(spi_rx_data),
        .rx_valid(spi_rx_valid),

        .tx_data(spi_data),
        .tx_start(spi_start),
        .tx_done(spi_done)
    );

    // ======================================================
    // I2C MASTER
    // ======================================================

    i2c_master i2c_master_inst (
        .clk(clk),
        .rst(rst),
        .start(i2c_start),
        .slave_addr(7'h50),
        .write_data(i2c_data),
        .busy(),
        .done(i2c_done),
        .ack_error(),
        .sda(i2c_sda),
        .scl(i2c_scl)
    );

    // ======================================================
    // I2C SLAVE
    // ======================================================

    i2c_slave_logic i2c_slave_ext (
        .clk(clk),
        .rst(rst),
        .sda(i2c_sda),
        .scl(i2c_scl),

        .data_out(i2c_ext_data),
        .data_valid(i2c_ext_valid),
        .data_read(1'b0)
    );

    // ======================================================
    // SOURCE ARBITER
    // ======================================================

    source_arbiter arbiter_inst (
        .clk(clk),
        .rst(rst),

        .uart_rx_data(uart_rx_data),
        .uart_rx_valid(uart_rx_valid),

        .spi_rx_data(spi_rx_data),
        .spi_rx_valid(spi_rx_valid),

        .i2c_rx_data(i2c_ext_data),
        .i2c_rx_valid(i2c_ext_valid),

        .bridge_data(bridge_data),
        .bridge_valid(bridge_valid),
        .source_id(source_id)
    );

    // ======================================================
    // BUFFER
    // ======================================================

    mpcu_buffer buffer_inst (
        .clk(clk),
        .rst(rst),
        .cose(cose),
        .data_in(bridge_data),
        .data_valid(bridge_valid),

        .uart_data(uart_data),
        .uart_valid(uart_valid),

        .spi_data(spi_data),
        .spi_valid(spi_valid),

        .i2c_data(i2c_data),
        .i2c_valid(i2c_valid)
    );

    // ======================================================
    // CONTROLLER
    // ======================================================

    mpcu_controller controller_inst (
        .clk(clk),
        .rst(rst),
        .cose(cose),
        .bridge_valid(bridge_valid),
        .uart_done(uart_done),
        .spi_done(spi_done),
        .i2c_done(i2c_done),
        .uart_start(uart_start),
        .spi_start(spi_start),
        .i2c_start(i2c_start),
        .busy()
    );

endmodule