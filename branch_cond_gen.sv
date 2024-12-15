module branch_cond_gen (
    input logic [31:0] rdata1,
    input logic [31:0] rdata2,
    input logic [2:0] func3,
    output logic br_true
);
  always_comb begin
    case (func3)
      3'b000: br_true = (rdata1 == rdata2);  // BEQ: branch if equal
      3'b001: br_true = (rdata1 != rdata2);  // BNE: branch if not equal
      3'b100: br_true = (rdata1 < rdata2);  // BLT: branch if less than (signed)
      3'b101: br_true = (rdata1 >= rdata2);  // BGE: branch if greater than or equal (signed)
      3'b110: br_true = ($unsigned(rdata1) < $unsigned(rdata2));  // BLTU: branch if less than (unsigned)
      3'b111: br_true = ($unsigned(rdata1) >= $unsigned(rdata2));  // BGEU: branch if greater than or equal (unsigned)
      default: br_true = 0;
    endcase
  end
endmodule
