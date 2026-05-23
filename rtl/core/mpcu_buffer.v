module mpcu_buffer (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] cose,
    input  wire [7:0] data_in,
    input  wire       data_valid,

    output reg  [7:0] uart_data,
    output reg        uart_valid,

    output reg  [7:0] spi_data,
    output reg        spi_valid,

    output reg  [7:0] i2c_data,
    output reg        i2c_valid
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        uart_valid <= 0;
        spi_valid  <= 0;
        i2c_valid  <= 0;
    end else begin
        uart_valid <= 0;
        spi_valid  <= 0;
        i2c_valid  <= 0;

        if (data_valid) begin
            case (cose)
                2'b01: begin
                    uart_data  <= data_in;
                    uart_valid <= 1;
                end
                2'b10: begin
                    spi_data  <= data_in;
                    spi_valid <= 1;
                end
                2'b11: begin
                    i2c_data  <= data_in;
                    i2c_valid <= 1;
                end
            endcase
        end
    end
end

endmodule
