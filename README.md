UART Receiver FSM implemented in Verilog and synthesized on Xilinx Artix-7 using Vivado.

This project compares two FSM state encoding strategies:

1. Binary Encoding
2. One-Hot Encoding

FSM States:
IDLE → START → DATA → STOP → DONE

Features:
- Mid-bit sampling
- False start-bit detection
- Frame error handling

## Results

Binary FSM
- LUTs: 10
- Flip-flops: 7

One-Hot FSM
- LUTs: 9
- Flip-flops: 9

Clock constraint: 100 MHz  
Worst Negative Slack: ~7.6 ns
