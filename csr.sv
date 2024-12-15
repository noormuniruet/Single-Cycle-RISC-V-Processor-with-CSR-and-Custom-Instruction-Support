module csr (
    input  logic [31:0] inst,      // Instruction containing CSR address in bits [31:20]
    input  logic [31:0] wdata,     // Write data for CSR
    input  logic [31:0] pc,        // Program counter value
    output logic [31:0] rdata,     // Read data from CSR
    output logic [31:0] epc,       // Exception program counter
    input  logic        csr_rd,    // CSR read enable
    input  logic        csr_wr,    // CSR write enable
    input  logic        rst,       // Reset signal
    input  logic        clk,       // Clock signal
    input  logic        is_mret,   // MRET (machine return from trap) signal
    output logic        epc_taken  // EPC taken signal
);

  // Local parameters for CSR addresses
  localparam CSR_MSTATUS = 12'h300;  // Machine Status Register
  localparam CSR_MIE = 12'h304;  // Machine Interrupt Enable
  localparam CSR_MTVEC = 12'h305;  // Machine Trap-Vector Base Address
  localparam CSR_MEPC = 12'h341;  // Machine Exception Program Counter
  localparam CSR_MCAUSE = 12'h342;  // Machine Cause Register
  localparam CSR_MIP = 12'h344;  // Machine Interrupt Pending

  // CSR register memory
  logic [31:0] csr_mem[5:0];  // Array to store CSR values
  logic is_device_ent_in;  // Device interrupt enable signal
  logic is_global_ent_in;  // Global interrupt enable signal
  logic trap;  // Trap signal

  // Asynchronous read logic
  always_comb begin
    if (csr_rd) begin
      case (inst[31:20])
        CSR_MSTATUS: rdata = csr_mem[0];
        CSR_MIE:     rdata = csr_mem[1];
        CSR_MTVEC:   rdata = csr_mem[2];
        CSR_MEPC:    rdata = csr_mem[3];
        CSR_MCAUSE:  rdata = csr_mem[4];
        CSR_MIP:     rdata = csr_mem[5];
        default:     rdata = 32'b0;  // Return 0 for invalid address
      endcase
    end else begin
      rdata = 32'b0;
    end
  end

  // Synchronous write and trap handling
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset all CSR registers
      csr_mem[0] <= 32'b0;
      csr_mem[1] <= 32'b0;
      csr_mem[2] <= 32'b0;
      csr_mem[3] <= 32'b0;
      csr_mem[4] <= 32'b0;
      csr_mem[5] <= 32'b0;
      epc        <= 32'b0;
      epc_taken  <= 1'b0;
      trap       <= 1'b0;
    end else begin
      // Handle CSR write
      if (csr_wr) begin
        case (inst[31:20])
          CSR_MSTATUS: csr_mem[0] <= wdata;
          CSR_MIE:     csr_mem[1] <= wdata;
          CSR_MTVEC:   csr_mem[2] <= wdata;
          CSR_MEPC:    csr_mem[3] <= wdata;
          CSR_MCAUSE:  csr_mem[4] <= wdata;
          CSR_MIP:     csr_mem[5] <= wdata;
          default:     ;  // No action for invalid addresses
        endcase
      end

      // Triggering a trap based on some condition (could be an interrupt or exception)
      if (is_mret) begin
        epc       <= csr_mem[3];  // Restore EPC from MEPC
        epc_taken <= 1'b1;
        trap      <= 1'b0;  // Reset trap once handled
      end else begin
        trap <= 1'b0;  // Ensure trap is reset if no condition is met
        epc_taken <= 1'b0;  // No EPC taken if no trap
      end

      // Handle trap logic
      if (trap) begin
        csr_mem[4] <= 32'b0;  // Clear MCAUSE (Machine Cause Register)
        csr_mem[5] <= csr_mem[5] | 32'd128;  // Set MIP (Machine Interrupt Pending)

        // Handle interrupt enabling logic
        is_device_ent_in = csr_mem[5][7] & csr_mem[1][7];  // Check device interrupt enable
        is_global_ent_in = csr_mem[0][3] & is_device_ent_in;  // Check global interrupt enable

        if (is_global_ent_in) begin
          csr_mem[3] <= pc;  // Save PC in MEPC
          epc        <= csr_mem[2] + (csr_mem[4] << 2);  // Calculate exception PC
          epc_taken  <= 1'b1;  // Indicate EPC is taken
        end
      end
    end
  end
  // always_ff @(posedge clk) begin
  //   $display("At time %t, CSR Registers: MSTATUS=%h, MIE=%h, MTVEC=%h, MEPC=%h, MCAUSE=%h, MIP=%h", 
  //            $time, csr_mem[0], csr_mem[1], csr_mem[2], csr_mem[3], csr_mem[4], csr_mem[5]);
  // end
endmodule
