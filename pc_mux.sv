module pc_mux (
    input logic [31:0] pc_out,
    input logic [31:0] alu_result,
    input logic br_true,
    input logic jump_en,
    input logic epc_taken,
    input logic [31:0] epc,
    output logic [31:0] next_pc
);

  always_comb begin
    if (br_true || jump_en) next_pc = alu_result;
    else if (epc_taken) next_pc = epc;
    else next_pc = pc_out + 32'd4;
  end

endmodule
