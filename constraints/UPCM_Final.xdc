###############################################################################
# Nexys A7-100T Constraints File
# Project : UPCM FPGA Protocol Bridge
# Board   : Digilent Nexys A7 Artix-7 FPGA
###############################################################################

###############################################################################
# CLOCK (100 MHz)
###############################################################################

set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -period 10.000 -name sys_clk_pin \
-waveform {0 5} [get_ports clk]

###############################################################################
# RESET BUTTON
# BTN0
###############################################################################

set_property PACKAGE_PIN N17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

###############################################################################
# COSE SWITCHES
###############################################################################

# SW0 -> cose[0]
set_property PACKAGE_PIN J15 [get_ports {cose[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cose[0]}]

# SW1 -> cose[1]
set_property PACKAGE_PIN L16 [get_ports {cose[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cose[1]}]

###############################################################################
# UART
# USB-UART Bridge
###############################################################################

# UART RX
set_property PACKAGE_PIN C4 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]

# UART TX
set_property PACKAGE_PIN D4 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]

###############################################################################
# SPI  (PMOD JA)
###############################################################################

# MOSI
set_property PACKAGE_PIN J1 [get_ports spi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]

# MISO
set_property PACKAGE_PIN L2 [get_ports spi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]

# SCLK
set_property PACKAGE_PIN J2 [get_ports spi_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports spi_sclk]

# CS_N
set_property PACKAGE_PIN G2 [get_ports spi_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports spi_cs_n]

###############################################################################
# I2C  (PMOD JB)
###############################################################################

# SDA
set_property PACKAGE_PIN A14 [get_ports i2c_sda]
set_property IOSTANDARD LVCMOS33 [get_ports i2c_sda]
set_property PULLUP true [get_ports i2c_sda]

# SCL
set_property PACKAGE_PIN A16 [get_ports i2c_scl]
set_property IOSTANDARD LVCMOS33 [get_ports i2c_scl]
set_property PULLUP true [get_ports i2c_scl]

###############################################################################
# DEBUG LEDs
#
# IMPORTANT:
# Add this port in mpcu_top:
#
# output wire [5:0] led;
#
###############################################################################

# LED0
set_property PACKAGE_PIN H17 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

# LED1
set_property PACKAGE_PIN K15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

# LED2
set_property PACKAGE_PIN J13 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

# LED3
set_property PACKAGE_PIN N14 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

# LED4
set_property PACKAGE_PIN R18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]

# LED5
set_property PACKAGE_PIN V17 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

###############################################################################
# SUGGESTED LED DEBUG MAPPING
###############################################################################
#
# led[0] = uart_rx_valid
# led[1] = spi_rx_valid
# led[2] = i2c_ext_valid
# led[3] = uart_done
# led[4] = spi_done
# led[5] = i2c_done
#
###############################################################################
