# AHB-Lite-Interconnect
This project implements an AMBA AHB-Lite bus system in Verilog.
# AHB-Lite Interconnect (Verilog)

This project implements an AMBA AHB-Lite bus system in Verilog.

## Architecture
- 1 Master
- 4 Slaves
- Address Decoder
- Response Multiplexer
- Interconnect Logic

## Features
- Supports byte, halfword and word transfers
- 4 KB memory per slave
- Address based slave selection
- Testbench for verification

## Address Map
Slave0 : 0x0000_0000 – 0x0000_0FFF  
Slave1 : 0x0000_1000 – 0x0000_1FFF  
Slave2 : 0x0000_2000 – 0x0000_2FFF  
Slave3 : 0x0000_3000 – 0x0000_3FFF  

## Simulation
Testbench verifies:
- Write transactions
- Read transactions
- Different transfer sizes

## Tools
- Verilog HDL
- Vivado
