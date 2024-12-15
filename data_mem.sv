module data_mem (
    input  logic        clk,
    input  logic [31:0] addr,        // Base address from ALU for load/store
    input  logic [31:0] write_data,  // Data to be written to memory for store
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [ 2:0] func3,       // ALU operation code
    output logic [31:0] rdata        // Data read from memory for load
);

  // Define memory: 40 rows of 32-bit words
  logic [31:0] data_memory[0:39];

  // Read operation for Load
  always_comb begin
      if (mem_read) begin
          unique case (func3)
              3'b000: rdata = {{24{data_memory[addr][7]}}, data_memory[addr][7:0]};  // LB (Load Byte, sign-extended)
              3'b001: rdata = {{16{data_memory[addr][15]}}, data_memory[addr][15:0]};  // LH (Load Halfword, sign-extended)
              3'b010: rdata = data_memory[addr];  // LW (Load Word)
              3'b100: rdata = {24'b0, data_memory[addr][7:0]};  // LBU (Load Byte Unsigned, zero-extended)
              3'b101: rdata = {16'b0, data_memory[addr][15:0]};  // LHU (Load Halfword Unsigned, zero-extended)
              default: rdata = 32'b0;  // Default to 0 for unsupported func3 values
          endcase
      end else begin
          rdata = 32'b0;  // Default to 0 if mem_read is not active
      end
  end

  // Write operation for Store
  always_ff @(posedge clk) begin
      if (mem_write) begin
          unique case (func3)
              3'b000: data_memory[addr][7:0] <= write_data[7:0];  // SB (Store Byte)
              3'b001: data_memory[addr][15:0] <= write_data[15:0];  // SH (Store Halfword)
              3'b010: data_memory[addr] <= write_data;  // SW (Store Word)
              default: ;  // No operation for unsupported func3 values
          endcase
      end
  end

endmodule
