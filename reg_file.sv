module reg_file (
    input logic clk,
    input logic rf_en,
    input logic [4:0] rs1,  // Address of register
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] wdata,
    input logic [31:0] post_inc_data,  // Data to write during post-increment
    input logic post_inc_en,           // Enable signal for post-increment write
    output logic [31:0] rdata1,        // Value of register
    output logic [31:0] rdata2
);

  logic [31:0] reg_mem[31:0];  // 32 registers of 32-bit size

  // Async read
  always_comb begin
    rdata1 = reg_mem[rs1];
    rdata2 = reg_mem[rs2];
  end

  // Synchronous write
  always_ff @(posedge clk) begin
    if (rf_en && rd != 5'd0) begin  // Avoid writing to register x0
      reg_mem[rd] <= wdata;
    end
    if (post_inc_en && rs1 != 5'd0) begin
      reg_mem[rs1] <= post_inc_data;
    end
  end

endmodule
