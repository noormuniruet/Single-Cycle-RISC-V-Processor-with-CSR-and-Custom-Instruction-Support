module opr_A_mux (
    input logic [31:0] pc_out,
    input logic sel_A,
    input logic [31:0] rdata1,
    output logic [31:0] opr_a
);

  always_comb begin
    opr_a = sel_A ? pc_out : rdata1;
  end


endmodule
