# Single-Cycle RISC-V Processor with CSR and Custom Instruction Support

## Overview
This project implements a single-cycle RISC-V processor with the following features:

1. **CSR (Control and Status Register) Support**: Includes CSR functionalities for system-level operations and interrupt handling.
2. **Custom Instruction `lwpostinc`**: A new RISC-V instruction that combines load (`lw`) with a post-increment operation on the source register.

The processor is designed using SystemVerilog, with modular components to ensure scalability and ease of testing. The architecture adheres to the RISC-V specification, supporting both standard and custom features.

---

## Features

### 1. RISC-V Single-Cycle Architecture
- Implements a basic single-cycle datapath to execute RISC-V instructions efficiently.
- Supports RISC-V base integer instructions (RV32I).

### 2. CSR (Control and Status Registers)
- Implements essential CSR registers for system control and interrupt handling.
- Supports CSR read and write operations using the `csrrw`, `csrrs`, and `csrrc` instructions.

### 3. Custom Instruction: `lwpostinc`
- **Syntax**: `lwpostinc rd, imm(rs)`
- **Operation**:
  - Loads a word from memory into the destination register (`rd`).
  - Increments the base register (`rs`) by the immediate value (`imm`).
- **Equivalent Assembly**:
  ```assembly
  lw rd, 0(rs)
  addi rs, rs, imm
  ```

### 4. Modular Design
- **Instruction Memory (`inst_mem.sv`)**: Stores the program instructions.
- **Data Memory (`data_mem.sv`)**: Handles load and store operations.
- **Register File (`reg_file.sv`)**: Implements RISC-V general-purpose registers.
- **ALU (`alu.sv`)**: Executes arithmetic and logical operations.
- **CSR Register File (`csr_register_file.sv`)**: Manages system-level control registers.

---

## Project Structure

```
.
├── rtl/
│   ├── alu.sv
│   ├── controller.sv
│   ├── csr_register_file.sv
│   ├── data_mem.sv
│   ├── imm_gen.sv
│   ├── inst_dec.sv
│   ├── inst_mem.sv
│   ├── pc.sv
│   ├── processor.sv
│   ├── reg_file.sv
│   └── writeback_mux.sv
├── testbench/
│   ├── tb_processor.sv
├── simulation_files/
│   ├── instruction_memory
│   ├── register_file
│   ├── data_memory
│   ├── csr_register_file
├── processor.vcd
```

### Key Files
- `rtl/processor.sv`: Top-level module integrating all components.
- `testbench/tb_processor.sv`: Testbench to validate processor functionality.
- `simulation_files/`: Contains pre-initialized files for memory and register values.

---

## How to Run

### Prerequisites
- **Verilog Simulator**: Any SystemVerilog simulator like ModelSim, Xcelium, or Icarus Verilog.
- **GTKWave**: For waveform analysis.

### Steps
1. Clone this repository:
   ```bash
   git clone https://github.com/noormuniruet/Single-Cycle-RISC-V-Processor-with-CSR-and-Custom-Instruction-Support.git
   cd <repository-folder>
   ```
2. Compile the RTL files and testbench:
   ```bash
   vlog rtl/*.sv testbench/tb_processor.sv
   vsim tb_processor
   ```
3. Run the simulation and generate waveforms:
   ```bash
   run -all
   ```
4. View the waveforms in GTKWave:
   ```bash
   gtkwave processor.vcd
   ```

---

## Testing

### Validating `lwpostinc`
1. Add appropriate instructions in `simulation_files/instruction_memory`:
   ```assembly
   lwpostinc x10, 4(x2)  // Load value at address in x2 and increment x2 by 4
   lw x11, 0(x2)         // Verify x2 is incremented
   ```
2. Ensure initial values for `x2` and memory addresses are set in `register_file` and `data_memory` respectively.
3. Observe the waveforms to confirm the `lwpostinc` operation.

---

