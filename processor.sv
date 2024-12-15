module processor (
    input logic clk,
    input logic rst
);
  // Internal signals
  logic [31:0] pc_out;
  logic [31:0] inst;
  logic [ 6:0] opcode;
  logic [31:0] csr_rdata;
  logic [31:0] read_data_from_data_memory;  // Data read from data memory
  logic [31:0] write_data;  // Data to write to data memory
  logic [ 2:0] func3;
  logic [ 6:0] func7;
  logic [ 4:0] rs1;
  logic [ 4:0] rs2;
  logic [ 4:0] rd;
  logic [31:0] alu_result;  // ALU output
  logic [31:0] rdata1;
  logic [31:0] rdata2;
  logic [31:0] opr_b;
  logic [31:0] opr_a;
  logic [31:0] wdata;
  logic [ 3:0] aluop;
  logic [31:0] sign_extended_imm;
  logic rf_en, imm_en, mem_read, mem_write, csr_rd, csr_wr, jump_en, sel_A;
  logic [ 1:0] wb_sel;  // Write-back select signal from controller
  logic        br_true;
  logic [31:0] next_pc;  // Next PC value for JAL, JALR, and branches
  logic trap, is_mret, epc_taken;
  logic [31:0] epc;

  // Additional signals for lwpostinc
  logic [31:0] post_inc_data;
  logic        post_inc_en;

  // Program Counter instance
  pc pc_inst (
      .clk   (clk),
      .rst   (rst),
      .pc_in (next_pc),
      .pc_out(pc_out)
  );

  // Instruction Memory Instance
  inst_mem imem (
      .addr(pc_out),
      .data(inst)
  );

  // Instruction Decoder
  inst_dec inst_instance (
      .inst  (inst),
      .rs1   (rs1),
      .rs2   (rs2),
      .rd    (rd),
      .opcode(opcode),
      .func3 (func3),
      .func7 (func7)
  );

  // Register File
  reg_file reg_file_inst (
      .clk          (clk),
      .rs1          (rs1),
      .rs2          (rs2),
      .rd           (rd),
      .rf_en        (rf_en),
      .rdata1       (rdata1),
      .rdata2       (rdata2),
      .wdata        (wdata),
      .post_inc_data(post_inc_data),  // Data for post-increment
      .post_inc_en  (post_inc_en)     // Enable signal for post-increment
  );

  csr csr_inst (
      .csr_rd(csr_rd),
      .csr_wr(csr_wr),
      .inst(inst),
      .pc(next_pc),
      .rdata(csr_rdata),
      .wdata(write_data),
      .rst(rst),
      .clk(clk),
      .is_mret(is_mret),
      .epc(epc),
      .epc_taken(epc_taken)
  );

  // Controller
  controller contr_inst (
      .opcode(opcode),
      .func3(func3),
      .func7(func7),
      .rf_en(rf_en),
      .csr_rd(csr_rd),
      .csr_wr(csr_wr),
      .aluop(aluop),
      .imm_en(imm_en),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .sel_A(sel_A),
      .jump_en(jump_en),
      .wb_sel(wb_sel)  // Write-back select signal
  );

  // ALU Multiplexer
  alu_mux alu_mux_inst (
      .sign_extended_imm(sign_extended_imm),
      .imm_en(imm_en),
      .rdata2(rdata2),
      .opr_b(opr_b)
  );

  opr_A_mux opr_A_mux_inst (
      .rdata1(rdata1),
      .pc_out(pc_out),
      .sel_A (sel_A),
      .opr_a (opr_a)
  );

  // ALU
  alu alu_inst (
      .opr_a  (opr_a),
      .opr_b  (opr_b),
      .aluop  (aluop),
      .opr_res(alu_result)  // ALU result
  );

  // Immediate Generator
  imm_gen imm_gen_inst (
      .inst(inst),
      .sign_extended_imm(sign_extended_imm),
      .func3(func3),
      .opcode(opcode)
  );

  // Data Memory Instance
  data_mem data_mem_inst (
      .clk       (clk),                        // Clock signal for memory
      .addr      (alu_result),                 // Address for load/store (from ALU result)
      .write_data(rdata2),                     // Data to write to memory (from rdata2)
      .mem_read  (mem_read),                   // Memory read enable
      .mem_write (mem_write),                  // Memory write enable
      .func3     (func3),
      .rdata     (read_data_from_data_memory)  // Data read from memory
  );

  // Branch Condition Generator
  branch_cond_gen branch_cond_gen_inst (
      .func3  (func3),
      .rdata1 (rdata1),
      .rdata2 (rdata2),
      .br_true(br_true)
  );

  writeback_mux writeback_mux_inst (
      .read_data_from_data_memory(read_data_from_data_memory),
      .alu_result(alu_result),
      .csr_rdata(csr_rdata),
      .wb_sel(wb_sel),
      .pc(pc_out),
      .wdata(wdata)
  );

  pc_mux pc_mux_inst (
      .pc_out(pc_out),
      .alu_result(alu_result),
      .br_true(br_true),
      .jump_en(jump_en),
      .epc_taken(epc_taken),
      .epc(epc),
      .next_pc(next_pc)
  );



  always_comb begin
    post_inc_en   = (opcode == 7'b0101011 && func3 == 3'b000);  // Custom lwpostinc enable condition
    post_inc_data = rdata1 + sign_extended_imm;               // Increment rs1 by immediate value
  end

endmodule
