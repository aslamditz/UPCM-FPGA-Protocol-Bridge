module spi_slave #(
    parameter MODE = 2'b00
)(
    input  wire clk,
    input  wire rst,

    input  wire sclk,
    input  wire cs_n,
    input  wire mosi,
    output reg  miso,

    output reg [7:0] rx_data,
    output reg       rx_valid,

    input  wire [7:0] tx_data,
    input  wire       tx_load
);

reg [7:0] shift_rx;
reg [7:0] shift_tx;
reg [2:0] bit_cnt;

reg sclk_d1, sclk_d2;

wire sclk_rise;
wire sclk_fall;

assign sclk_rise = (sclk_d2 == 0 && sclk_d1 == 1);
assign sclk_fall = (sclk_d2 == 1 && sclk_d1 == 0);

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        sclk_d1 <= 0;
        sclk_d2 <= 0;
    end
    else begin
        sclk_d1 <= sclk;
        sclk_d2 <= sclk_d1;
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        bit_cnt  <= 7;
        rx_valid <= 0;
        shift_rx <= 0;
        shift_tx <= 0;
        miso     <= 0;
    end
    else begin

        rx_valid <= 0;

        if(tx_load)
            shift_tx <= tx_data;

        if(!cs_n) begin

            if(sclk_rise) begin

                shift_rx[bit_cnt] <= mosi;

                if(bit_cnt == 0) begin
                    rx_data  <= {shift_rx[7:1], mosi};
                    rx_valid <= 1;
                    bit_cnt  <= 7;
                end
                else
                    bit_cnt <= bit_cnt - 1;
            end

            if(sclk_fall)
                miso <= shift_tx[bit_cnt];

        end
        else
            bit_cnt <= 7;
    end
end

endmodule