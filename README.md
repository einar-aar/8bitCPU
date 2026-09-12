# 8-bit CPU

This is a small accumulator-based CPU written in SystemVerilog. I made it as a
simple project for learning how a CPU fetches and runs instructions.

The data bus, address bus, and program counter are all 8 bits wide. Program
memory and data memory are separate. Both memories can hold 256 bytes.

## Files

- `rtl/cpu8.sv` contains the control logic, accumulator, and flags.
- `rtl/alu.sv` handles arithmetic and logic operations.
- `rtl/program_rom.sv` loads a program from a hex file.
- `rtl/data_ram.sv` contains the data memory.
- `rtl/cpu8_system.sv` connects the CPU and memories.
- `tb/cpu8_tb.sv` is the testbench.
- `tb/program.hex` is the program used by the testbench.

## How instructions work

Each opcode is one byte. Instructions that need a value or address use the next
byte as their argument. These instructions take three clock cycles. Instructions
without an argument take two.

| Opcode | Instruction | Description |
|---:|:---|:---|
| `00` | NOP | Do nothing |
| `10 nn` | LDI | Load `nn` into the accumulator |
| `11 aa` | LDA | Load from data address `aa` |
| `12 aa` | STA | Store at data address `aa` |
| `20 aa` | ADD | Add a value from memory |
| `21 aa` | SUB | Subtract a value from memory |
| `22 aa` | AND | Bitwise AND |
| `23 aa` | OR | Bitwise OR |
| `24 aa` | XOR | Bitwise XOR |
| `25 nn` | ADI | Add the value `nn` |
| `30 aa` | JMP | Jump to program address `aa` |
| `31 aa` | JZ | Jump if the result was zero |
| `32 aa` | JC | Jump if carry is set |
| `40` | OUT | Copy the accumulator to the output port |
| `ff` | HLT | Stop the CPU |

Unknown opcodes act like NOP. The `OUT` instruction raises `out_strobe` for one
clock cycle. Reset is synchronous and active high.

Arithmetic and logic instructions update the zero and carry flags. For
subtraction, a set carry flag means that no borrow was needed.

## Running the test

Run this from the project folder:

```powershell
.\run_test.ps1
```

The test program adds the numbers from 1 through 10 and stores the result in
RAM. It also checks the ALU and tests a conditional jump using the carry flag.
A successful run ends with:

```text
PASS: CPU test completed
```