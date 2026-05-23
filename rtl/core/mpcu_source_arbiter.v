module source_arbiter (
    input  wire       clk,
    input  wire       rst,

    input  wire [7:0] uart_rx_data,
    input  wire       uart_rx_valid,

    input  wire [7:0] spi_rx_data,
    input  wire       spi_rx_valid,

    input  wire [7:0] i2c_rx_data,
    input  wire       i2c_rx_valid,

    output reg  [7:0] bridge_data,
    output reg        bridge_valid,
    output reg  [1:0] source_id
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        bridge_valid <= 0;
        bridge_data  <= 0;
        source_id    <= 2'b00;
    end else begin
        bridge_valid <= 0;

        if (uart_rx_valid) begin
            bridge_data  <= uart_rx_data;
            bridge_valid <= 1;
            source_id    <= 2'b01;
        end
        else if (spi_rx_valid) begin
            bridge_data  <= spi_rx_data;
            bridge_valid <= 1;
            source_id    <= 2'b10;
        end
        else if (i2c_rx_valid) begin
            bridge_data  <= i2c_rx_data;
            bridge_valid <= 1;
            source_id    <= 2'b11;
        end
    end
end

endmodule
