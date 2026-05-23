// ======================================================
// COSE - Protocol Selection Module (UPDATED)
// 00 = NONE
// 01 = UART
// 10 = SPI
// 11 = I2C
// ======================================================

module cose_selector (
    input  wire [1:0] cose,

    output reg uart_en,
    output reg spi_en,
    output reg i2c_en
);

always @(*) begin
    // default
    uart_en = 0;
    spi_en  = 0;
    i2c_en  = 0;

    case (cose)
        2'b01: uart_en = 1;
        2'b10: spi_en  = 1;
        2'b11: i2c_en  = 1;
        default: begin end
    endcase
end

endmodule
