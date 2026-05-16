# RV_PL — 5-Stage Pipelined RISC-V Processor (RV32I)

A synthesisable Verilog implementation of a classic 5-stage in-order pipelined RISC-V processor supporting a significant subset of the RV32I base integer instruction set.

---

## Architecture Overview

The processor follows the standard 5-stage RISC pipeline:

```
IF  →  ID  →  EX  →  MA  →  WB
     PLR1    PLR2    PLR3   PLR4
```

| Stage | Name | Function |
|-------|------|----------|
| IF | Instruction Fetch | Read instruction from `inst_mem` using the PC |
| ID | Instruction Decode | Decode instruction, read register file, sign-extend immediate |
| EX | Execute | Perform ALU operation; compute branch/jump target |
| MA | Memory Access | Read or write `data_mem` |
| WB | Write Back | Select and write result back to register file |

Each stage boundary is separated by a pipeline register (PLR1–PLR4). The register file writes on the **negative clock edge** and reads combinatorially, enabling the WB→ID forwarding path to work without an extra stall cycle.

---

## File Structure

```
rtl/
├── rv_pl.v                         # Top-level: connects all stages and modules
├── alu.v                           # 32-bit ALU (10 operations)
├── controller.v                    # Combinational control signal decoder
├── extender.v                      # Immediate sign-extender (5 formats)
├── hazard_unit.v                   # Forwarding + stall + flush logic
├── inst_mem.v                      # Instruction memory (256 × 32-bit words)
├── data_mem.v                      # Data memory (256 × 32-bit words)
├── pc_reg.v                        # Program counter register (with enable)
├── reg_file.v                      # 32 × 32-bit register file (x0 hardwired 0)
└── pipeline_registers/
    ├── plr1.v                      # IF/ID register
    ├── plr2.v                      # ID/EX register
    ├── plr3.v                      # EX/MA register
    └── plr4.v                      # MA/WB register
tb/
└── tb_rv_pl.v                      # Testbench with 5 pre-loaded test programs
```

---

## Supported Instructions

### R-Type (`op = 0110011`)
`ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`

### I-Type (`op = 0010011`)
`ADDI`, `SLLI`, `SLTI`, `SLTIU`, `XORI`, `SRLI`, `SRAI`, `ORI`, `ANDI`

### Load (`op = 0000011`)
`LW` (32-bit word load)

### Store (`op = 0100011`)
`SW` (32-bit word store)

### Branch (`op = 1100011`)
`BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`

> **Note:** Branch condition resolution is done in the EX stage using the ALU zero flag. BEQ/BNE use subtraction; BLT/BGE use SLT; BLTU/BGEU use SLTU.

### Jump
- `JAL` (`op = 1101111`) — PC-relative jump, writes return address to `rd`
- `JALR` (`op = 1100111`) — Register-indirect jump, writes return address to `rd`

### Upper Immediate
- `LUI` (`op = 0110111`) — Load upper immediate
- `AUIPC` (`op = 0010111`) — Add upper immediate to PC

---

## Hazard Handling (`hazard_unit.v`)

### Data Forwarding
The hazard unit monitors the register addresses flowing through all stages and drives two 2-bit forwarding muxes (`E_forward_alu_op1`, `E_forward_alu_op2`) in the EX stage:

| Forwarding value | Source |
|---|---|
| `2'b10` | Forward from MA stage (previous ALU result) |
| `2'b01` | Forward from WB stage (writeback result) |
| `2'b00` | Use value latched in ID/EX register (no forwarding) |

Forwarding is suppressed for `x0` writes (since `x0` is always 0).

### Load-Use Stall
When an instruction in EX is a load (`E_sel_result[0] == 1`) and its destination register matches a source register of the instruction currently in ID, a **one-cycle stall** is inserted:

- PC and PLR1 (IF/ID) are held (`en = 0`)
- PLR2 (ID/EX) is flushed (`clr = 1`), inserting a NOP bubble

### Branch/Jump Flush
Branches and jumps are resolved in the EX stage. When `take_branch` is asserted (`E_branch & E_zero` or `E_jump`), the two instructions that entered the pipeline after the branch (currently in IF and ID) are invalid. Both PLR1 and PLR2 are flushed by asserting `clr`, which loads the NOP instruction (`32'h00000013`).

> This gives a **2-cycle branch penalty** on every taken branch or jump.

---

## Control Signals

The `controller` module decodes the opcode and function fields into:

| Signal | Width | Meaning |
|---|---|---|
| `we_rf` | 1 | Write enable for register file |
| `we_dm` | 1 | Write enable for data memory |
| `sel_alu_src_b` | 1 | ALU B input: 0 = rs2, 1 = immediate |
| `alu_control` | 4 | ALU operation (see table below) |
| `sel_ext` | 3 | Immediate format: I / S / B / U / J |
| `sel_result` | 2 | WB mux: 0 = ALU result, 1 = mem read, 2 = PC+4 |
| `branch` | 1 | Instruction is a conditional branch |
| `jump` | 1 | Instruction is an unconditional jump |

### ALU Control Encoding

| `alu_control` | Operation |
|---|---|
| `4'b0000` | ADD |
| `4'b0001` | SUB |
| `4'b0010` | AND |
| `4'b0011` | OR |
| `4'b0100` | XOR |
| `4'b0101` | SLL |
| `4'b0110` | SRL |
| `4'b0111` | SRA |
| `4'b1000` | SLT (signed) |
| `4'b1001` | SLTU (unsigned) |

---

## Immediate Formats (`extender.v`)

| `sel_ext` | Format | Used by |
|---|---|---|
| `3'b000` | I-type | ADDI, LW, JALR, I-ALU |
| `3'b001` | S-type | SW |
| `3'b010` | B-type | BEQ, BNE, BLT, … |
| `3'b011` | U-type | LUI, AUIPC |
| `3'b100` | J-type | JAL |

---

## Testbench (`tb/tb_rv_pl.v`)

The testbench selects a test program via `test_case` and pre-loads instruction memory directly. Change the value at the top of the file to select:

| `test_case` | Program | What it tests |
|---|---|---|
| `0` | Independent ADDIs | Basic execution with no hazards |
| `1` | RAW hazard chain | EX→EX and MA→EX data forwarding |
| `2` | Load-use stall | LW followed immediately by a dependent instruction |
| `3` | Taken branch | BEQ flush of two fetched instructions |
| `4` | JAL + SUB + branch-not-taken | Combined control flow check (default) |

After 500 ns the testbench calls `display_registers()` to print all non-zero register values. A VCD waveform file (`rv_pl.vcd`) is generated for viewing in GTKWave or similar.

### Running with Icarus Verilog

```bash
iverilog -o rv_pl_sim \
    tb/tb_rv_pl.v \
    rtl/rv_pl.v \
    rtl/alu.v \
    rtl/controller.v \
    rtl/extender.v \
    rtl/hazard_unit.v \
    rtl/inst_mem.v \
    rtl/data_mem.v \
    rtl/pc_reg.v \
    rtl/reg_file.v \
    rtl/pipeline_registers/plr1.v \
    rtl/pipeline_registers/plr2.v \
    rtl/pipeline_registers/plr3.v \
    rtl/pipeline_registers/plr4.v

vvp rv_pl_sim
gtkwave rv_pl.vcd
```

---

## Known Limitations

- **Word-only memory access**: `inst_mem` and `data_mem` are word-addressed (`addr[31:2]`). Byte (`LB`/`SB`) and halfword (`LH`/`SH`) accesses are not supported.
- **Branch resolution in EX**: The 2-cycle branch penalty is always paid for taken branches. A branch predictor (e.g. predict-not-taken) could reduce this to 1 cycle for not-taken branches.
- **No exception/interrupt handling**: Illegal opcodes, misaligned accesses, and traps are not modelled.
- **No memory initialisation**: Both memories start with undefined content at power-on; the testbench fills them explicitly via hierarchical references.
- **AUIPC partial**: LUI routes `U_imm + 0` through the ALU correctly. AUIPC is decoded identically and relies on the EX stage adding the immediate to `E_PC` — verify the datapath handles this case if you use it.
