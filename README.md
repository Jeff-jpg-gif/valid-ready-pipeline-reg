# Valid/Ready Pipeline Register (SystemVerilog)

This repository contains a single-stage pipeline register implemented in
SystemVerilog using a standard valid/ready handshake.

## Files
- `design.sv` – Pipeline register (1-entry FIFO behavior)
- `testbench.sv` – Testbench with backpressure, flow-through, and waveform dumping

## How to simulate (Icarus Verilog)

```bash
iverilog -g2012 -Wall design.sv testbench.sv
vvp a.out
gtkwave wave.vcd
