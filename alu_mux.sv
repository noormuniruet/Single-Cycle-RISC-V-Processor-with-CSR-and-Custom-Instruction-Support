module alu_mux (
    input logic [31:0] sign_extended_imm,
    input logic imm_en,
    input logic [31:0] rdata2,
    output logic [31:0] opr_b
);

always_comb
begin
        opr_b = imm_en ? sign_extended_imm : rdata2;
end
endmodule
