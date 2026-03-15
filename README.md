# AHB-Lite-Interconnect

This project implements an AMBA AHB-Lite bus system in Verilog.

# AHB-Lite Interconnect (Verilog)

This project implements a simplified AMBA AHB-Lite bus system using Verilog HDL.

## Architecture

* 1 Master
* 3 Slaves
* Address Decoder
* Response Multiplexer
* Interconnect Logic

## Features

* Supports basic read and write transactions
* 256 bytes memory per slave
* Address based slave selection
* Testbench for verification

## Address Map

Slave1 : 0x1000_0000 – 0x1FFF_FFFF
Slave2 : 0x2000_0000 – 0x2FFF_FFFF
Slave3 : 0x3000_0000 – 0x3FFF_FFFF

## Simulation

Testbench verifies:

* Write transactions
* Read transactions
* Correct slave selection

