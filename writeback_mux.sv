module writeback_mux (
    input logic [31:0] read_data_from_data_memory,
    input logic [31:0] alu_result,
    input logic [31:0] csr_rdata,
    input logic [31:0] pc,
    input logic [1:0] wb_sel,  
    output logic [31:0] wdata
);

  always_comb begin

    case (wb_sel)
      2'b00: wdata = alu_result;
      2'b01: wdata = read_data_from_data_memory;
      2'b10: wdata = pc + 32'd4;
      2'b11: wdata = csr_rdata;
    endcase
  end


endmodule
