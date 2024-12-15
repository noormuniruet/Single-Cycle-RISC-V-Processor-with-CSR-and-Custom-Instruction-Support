module controller (
    input logic [6:0] opcode,
    input logic [2:0] func3,
    input logic [6:0] func7,
    output logic [3:0] aluop,
    output logic rf_en,
    output logic imm_en,
    output logic jump_en,
    output logic mem_read,
    output logic mem_write,
    output logic [1:0] wb_sel,
    output logic sel_A,
    output logic csr_rd,  // control signal to read from CSR register file
    output logic csr_wr,
    output logic is_mret
);

  always_comb begin
    // Default control signals
    rf_en     = 1'b0;  // Disable register write-back by default
    imm_en    = 1'b0;  // Disable immediate generation by default
    mem_read  = 1'b0;  // Disable memory read by default
    mem_write = 1'b0;  // Disable memory write by default
    aluop     = 4'b0000;  // Default ALU operation
    wb_sel    = 2'b00;  // Default to ALU result for write-back
    csr_wr    = 1'b0;
    csr_rd    = 1'b0;
    is_mret   = 1'b0;
    sel_A     = 1'b0;
    jump_en   = 1'b0;

    case (opcode)
      // R-type instructions
      7'b0110011: begin
        rf_en = 1'b1;  // Enable write-back for R-type instructions
        imm_en = 1'b0;  // Immediate generation not used
        unique case (func3)
          3'b000: begin
            unique case (func7)
              7'b0000000: aluop = 4'b0000;  // ADD
              7'b0100000: aluop = 4'b0001;  // SUB
              7'b0000001: aluop = 4'b1011;  // MUL
            endcase
          end
          3'b001: aluop = 4'b0010;  // SLL
          3'b010: aluop = 4'b0011;  // SLT
          3'b011: aluop = 4'b0100;  // SLTU
          3'b100: aluop = 4'b0101;  // XOR
          3'b101: begin
            unique case (func7)
              7'b0000000: aluop = 4'b0110;  // SRL
              7'b0100000: aluop = 4'b0111;  // SRA
            endcase
          end
          3'b110: aluop = 4'b1000;  // OR
          3'b111: aluop = 4'b1001;  // AND
        endcase
      end

      // I-type instructions
      7'b0010011: begin
        rf_en = 1'b1;  // Enable write-back for I-type instructions
        imm_en = 1'b1;  // Enable immediate generation
        unique case (func3)
          3'b000: aluop = 4'b0000;  // ADDI
          3'b010: aluop = 4'b0011;  // SLTI
          3'b011: aluop = 4'b0100;  // SLTIU
          3'b100: aluop = 4'b0101;  // XORI
          3'b110: aluop = 4'b1000;  // ORI
          3'b111: aluop = 4'b1001;  // ANDI
          3'b001: aluop = 4'b0010;  // SLLI
          3'b101: begin
            unique case (func7)
              7'b0000000: aluop = 4'b0110;  // SRLI
              7'b0100000: aluop = 4'b0111;  // SRAI
            endcase
          end
        endcase
      end

      // LUI instruction
      7'b0110111: begin
        rf_en = 1'b1;  // Enable write-back for LUI
        imm_en = 1'b1;  // Enable immediate generation
        aluop = 4'b1100;
      end

      // AUIPC instruction
      7'b0010111: begin
        rf_en = 1'b1;  // Enable write-back for AUIPC
        imm_en = 1'b1;  // Enable immediate generation
        aluop = 4'b1101;
        sel_A = 1'b1;
      end

      // Load instructions
      7'b0000011: begin
        rf_en = 1'b1;  // Enable write-back for load instructions
        imm_en = 1'b1;  // Enable immediate generation
        mem_read = 1'b1;  // Enable memory read
        wb_sel = 2'b01;  // Select data from memory for write-back
        aluop = 4'b0000;  // ALU operation for address calculation
      end

      // Store instructions
      7'b0100011: begin
        rf_en = 1'b0;  // Disable write-back for store instructions
        imm_en = 1'b1;  // Enable immediate generation
        mem_write = 1'b1;  // Enable memory write
        aluop = 4'b0000;  // ALU operation for address calculation
      end

      // Custom Instruction: lwpostinc
      7'b0101011: begin  // Example opcode for lwpostinc
        rf_en = 1'b1;   // Enable register file write-back
        mem_read = 1'b1;   // Enable memory read
        wb_sel = 2'b01;  // Select memory data for write-back
        aluop = 4'b0000;  // ALU performs addition for address computation
        sel_A = 1'b1;   // Use rs1 as base register
      end

      // Other instructions...
      default: rf_en = 1'b0;  // Disable register file for unsupported opcodes
    endcase
  end
endmodule
