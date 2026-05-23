module spi_top_combined(

input clk,
input rst,

output spi_mosi,
input  spi_miso,
output spi_sclk,
output spi_cs_n,

output [7:0] rx_data,
output rx_valid,

input  [7:0] tx_data,
input  tx_start,
output tx_done

);

wire busy;

spi_master master(

.clk(clk),
.rst(rst),
.start(tx_start),
.data_in(tx_data),
.mode(2'b00),

.data_out(rx_data),
.busy(busy),
.done(tx_done),

.cs_n(spi_cs_n),
.sclk(spi_sclk),
.mosi(spi_mosi),
.miso(spi_miso)

);

assign rx_valid = tx_done;

endmodule