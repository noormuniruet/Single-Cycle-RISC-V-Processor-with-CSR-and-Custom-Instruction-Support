module imm_gen(
 input logic [31:0] inst, 
 output logic [31:0] sign_extended_imm,
 input logic [6:0] opcode,
 input logic [2:0] func3 // to check if it's SLLI, SRLI, or SRAI
// output logic [4:0] shamt  // 5-bit immediate for shift instructions
);
logic [4:0] shamt;
logic [11:0] imm;
logic [19:0] long_imm;


always_comb begin
        if (opcode == 7'b0110111 || opcode == 7'b0010111) begin
            // U-type: imm[31:12] is used directly from inst[31:12]
            long_imm = inst[31:12];
            sign_extended_imm = {{12{long_imm[19]}}, long_imm};; // Zero-extend lower 12 bits for LUI/AUIPC
        end
        else if(opcode==7'b1100011) //B-type
        begin
              imm = {inst[31], inst[7], inst[30:25], inst[11:8]};
            // Sign-extend the 12-bit immediate to 32 bits
              sign_extended_imm = {{20{imm[11]}}, imm};
        end
        else if(opcode==7'b1101111) //JAL type
        begin
            long_imm = {inst[31], inst[19:12], inst[20], inst[30:21]};
            // Sign-extend the 20-bit immediate to 32 bits
            sign_extended_imm = {{12{long_imm[19]}}, long_imm};
        end

        else if (opcode == 7'b0100011) begin
             // S-type immediate: concatenate bits [31:25] and [11:7]
             imm = {inst[31:25], inst[11:7]};
             sign_extended_imm={{20{imm[11]}}, imm};
        end
    // Shift instructions: extract only the shift amount (bits [24:20])
        else if ( opcode== 7'b0010011 && (func3 == 3'b001 || func3 == 3'b101)) begin
            shamt = inst[24:20]; // For SLLI, SRLI, SRAI
            imm={7'b0, shamt};
            sign_extended_imm={{20{imm[11]}}, imm};
        end
        else begin
             imm = inst[31:20]; // For all other instructions
             sign_extended_imm={{20{imm[11]}}, imm};
        end
end
endmodule