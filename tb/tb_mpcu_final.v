`timescale 1ns/1ps

module tb_mpcu_complete;

///////////////////////////////////////////////////////////
// CLOCK & RESET
///////////////////////////////////////////////////////////

reg clk;
reg rst;

always #5 clk = ~clk;

///////////////////////////////////////////////////////////
// COSE
///////////////////////////////////////////////////////////

reg [1:0] cose;

///////////////////////////////////////////////////////////
// UART
///////////////////////////////////////////////////////////

reg  uart_rx;
wire uart_tx;

///////////////////////////////////////////////////////////
// SPI
///////////////////////////////////////////////////////////

wire spi_sclk;
wire spi_mosi;
wire spi_cs_n;
wire spi_miso;

///////////////////////////////////////////////////////////
// I2C
///////////////////////////////////////////////////////////

wire i2c_sda;
wire i2c_scl;

pullup(i2c_sda);
pullup(i2c_scl);

///////////////////////////////////////////////////////////
// DUT
///////////////////////////////////////////////////////////

mpcu_top dut (

    .clk(clk),
    .rst(rst),
    .cose(cose),

    .uart_rx(uart_rx),
    .uart_tx(uart_tx),

    .spi_miso(spi_miso),
    .spi_mosi(spi_mosi),
    .spi_sclk(spi_sclk),
    .spi_cs_n(spi_cs_n),

    .i2c_sda(i2c_sda),
    .i2c_scl(i2c_scl)

);

///////////////////////////////////////////////////////////
// External SPI Slave
// (used when FPGA is SPI master)
///////////////////////////////////////////////////////////

spi_slave spi_ext_slave (

    .clk(clk),
    .rst(rst),

    .sclk(spi_sclk),
    .cs_n(spi_cs_n),
    .mosi(spi_mosi),
    .miso(spi_miso),

    .rx_data(),
    .rx_valid(),

    .tx_data(8'h3C),
    .tx_load(1'b0)

);

///////////////////////////////////////////////////////////
// UART SEND TASK
///////////////////////////////////////////////////////////

task uart_send;

input [7:0] data;

integer i;

begin

    // START BIT
    uart_rx = 0;
    #(80);

    // DATA BITS
    for (i=0; i<8; i=i+1)
    begin
        uart_rx = data[i];
        #(80);
    end

    // STOP BIT
    uart_rx = 1;
    #(80);

end

endtask

///////////////////////////////////////////////////////////
// SPI MASTER SEND
// (External -> FPGA SPI Slave)
///////////////////////////////////////////////////////////

task spi_master_send;

input [7:0] data;

integer i;

begin

    force spi_cs_n = 0;

    for (i=7; i>=0; i=i-1)
    begin

        force spi_sclk = 0;
        force spi_mosi = data[i];
        #40;

        force spi_sclk = 1;
        #40;

    end

    force spi_cs_n = 1;

    #100;

    release spi_sclk;
    release spi_mosi;
    release spi_cs_n;

end

endtask

///////////////////////////////////////////////////////////
// I2C MASTER SEND
// (External -> FPGA I2C Slave)
///////////////////////////////////////////////////////////

task i2c_master_send;

input [7:0] data;

integer i;

begin

    // START CONDITION
    force i2c_sda = 1;
    force i2c_scl = 1;
    #40;

    force i2c_sda = 0;
    #40;

    // SEND DATA
    for (i=7; i>=0; i=i-1)
    begin

        force i2c_scl = 0;
        force i2c_sda = data[i];
        #40;

        force i2c_scl = 1;
        #40;

    end

    // STOP CONDITION
    force i2c_scl = 1;
    force i2c_sda = 1;
    #80;

    release i2c_sda;
    release i2c_scl;

end

endtask

///////////////////////////////////////////////////////////
// MONITORING
///////////////////////////////////////////////////////////

always @(posedge clk)
begin

    if (dut.uart_rx_valid)
    begin
        $display("[UART RX] Time=%0t Data=%h",
                 $time,
                 dut.uart_rx_data);
    end

    if (dut.spi_rx_valid)
    begin
        $display("[SPI RX] Time=%0t Data=%h",
                 $time,
                 dut.spi_rx_data);
    end

    if (dut.i2c_ext_valid)
    begin
        $display("[I2C RX] Time=%0t Data=%h",
                 $time,
                 dut.i2c_ext_data);
    end

end

///////////////////////////////////////////////////////////
// MAIN TEST SEQUENCE
///////////////////////////////////////////////////////////

initial
begin

    ///////////////////////////////////////////////////////
    // WAVEFORM DUMP
    ///////////////////////////////////////////////////////

    $dumpfile("mpcu.vcd");
    $dumpvars(0, tb_mpcu_complete);

    ///////////////////////////////////////////////////////
    // INITIALIZATION
    ///////////////////////////////////////////////////////

    clk     = 0;
    rst     = 1;
    cose    = 2'b00;
    uart_rx = 1;

    ///////////////////////////////////////////////////////
    // RESET
    ///////////////////////////////////////////////////////

    #200;
    rst = 0;

    ///////////////////////////////////////////////////////
    // TEST 1 : UART -> SPI
    ///////////////////////////////////////////////////////

    $display("\n=================================");
    $display("TEST 1 : UART -> SPI");
    $display("=================================");

    cose = 2'b10;

    uart_send(8'hA5);

    #4000;

    ///////////////////////////////////////////////////////
    // TEST 2 : UART -> I2C
    ///////////////////////////////////////////////////////

    $display("\n=================================");
    $display("TEST 2 : UART -> I2C");
    $display("=================================");

    cose = 2'b11;

    uart_send(8'h55);

    #4000;

    ///////////////////////////////////////////////////////
    // TEST 3 : SPI -> UART
    ///////////////////////////////////////////////////////

    $display("\n=================================");
    $display("TEST 3 : SPI -> UART");
    $display("=================================");

    cose = 2'b01;

    spi_master_send(8'h5A);

    #4000;

    ///////////////////////////////////////////////////////
    // TEST 4 : SPI -> I2C
    ///////////////////////////////////////////////////////

    $display("\n=================================");
    $display("TEST 4 : SPI -> I2C");
    $display("=================================");

    cose = 2'b11;

    spi_master_send(8'h33);

    #4000;

    ///////////////////////////////////////////////////////
    // TEST 5 : I2C -> UART
    ///////////////////////////////////////////////////////

    $display("\n=================================");
    $display("TEST 5 : I2C -> UART");
    $display("=================================");

    cose = 2'b01;

    i2c_master_send(8'h77);

    #4000;

    ///////////////////////////////////////////////////////
    // TEST 6 : I2C -> SPI
    ///////////////////////////////////////////////////////

    $display("\n=================================");
    $display("TEST 6 : I2C -> SPI");
    $display("=================================");

    cose = 2'b10;

    i2c_master_send(8'h22);

    #4000;

    ///////////////////////////////////////////////////////
    // FINISH
    ///////////////////////////////////////////////////////

    $display("\n=================================");
    $display("ALL 6 DIRECTIONS COMPLETED");
    $display("=================================");

    $stop;

end

endmodule