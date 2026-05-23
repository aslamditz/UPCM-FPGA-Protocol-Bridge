# UPCM-FPGA-Protocol-Bridge

A Multi-Protocol Conversion Unit (UPCM) implemented on FPGA using Verilog HDL.
The system supports communication and protocol conversion between UART, SPI, and I2C interfaces using a centralized arbitration and buffering architecture.

---

# Features

* UART Protocol Support
* SPI Protocol Support
* I2C Protocol Support
* Dynamic Protocol Selection using COSE
* Centralized MPCU Controller
* Source Arbitration
* FPGA Implementation on Nexys A7
* Full RTL Verification Testbench

---

# Supported Protocol Conversions

| Source | Destination |
| ------ | ----------- |
| UART   | SPI         |
| UART   | I2C         |
| SPI    | UART        |
| SPI    | I2C         |
| I2C    | UART        |
| I2C    | SPI         |

---

# FPGA Board

* Digilent Nexys A7
* Artix-7 FPGA

---

# Tools Used

* Verilog HDL
* Xilinx Vivado
* GTKWave
* FPGA Simulation

---

# Project Structure

```text
rtl/            -> RTL source files
tb/             -> Testbench
constraints/    -> FPGA constraints
docs/           -> Block diagrams and waveforms
sim/            -> Simulation outputs
```

---

# Simulation

The project includes a complete verification testbench:

```text
tb/tb_mpcu_complete.v
```

Supported tests:

* UART -> SPI
* UART -> I2C
* SPI -> UART
* SPI -> I2C
* I2C -> UART
* I2C -> SPI

---

# Future Improvements

* AXI Interface Support
* DMA Integration
* Error Detection Mechanisms
* FIFO-based buffering
* High-speed protocol scaling

---

# Author

Aslam
Frontend RTL / FPGA / VLSI Enthusiast
