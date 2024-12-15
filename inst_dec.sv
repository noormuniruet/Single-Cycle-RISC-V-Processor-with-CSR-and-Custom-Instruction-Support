module inst_dec (
    input  logic [31:0] inst,
    output logic [ 6:0] opcode,
    output logic [ 2:0] func3,
    output logic [ 6:0] func7,
    output logic [ 4:0] rs1,
    output logic [ 4:0] rs2,
    output logic [ 4:0] rd
);

  // Decode the instruction fields
  assign opcode = inst[6:0];      // Opcode field
  assign func7 = inst[31:25];    // funct7 field
  assign func3 = inst[14:12];    // funct3 field

  // Decode the register fields
  assign rs1 = inst[19:15];      // Source register 1
  assign rs2 = inst[24:20];      // Source register 2
  assign rd = inst[11:7];        // Destination register

  
  localparam logic [6:0] LWPOSTINC_OPCODE = 7'b0101011;  
  localparam logic [2:0] LWPOSTINC_FUNCT3 = 3'b001;      
  localparam logic [6:0] LWPOSTINC_FUNCT7 = 7'b0000001;  

  // Check if the decoded instruction matches lwpostinc
  logic is_lwpostinc;
  assign is_lwpostinc = (opcode == LWPOSTINC_OPCODE) &&
                        (func3 == LWPOSTINC_FUNCT3) &&
                        (func7 == LWPOSTINC_FUNCT7);

endmodule
