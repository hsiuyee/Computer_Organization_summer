module Decoder (
    instr_op_i,
    RegWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RegDst_o,
    Jump_o,
    Branch_o,
    BranchType_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o
);

  //I/O ports
  input [6-1:0] instr_op_i;

  output RegWrite_o;
  output [2-1:0] ALUOp_o;
  output ALUSrc_o;
  output RegDst_o;
  output Jump_o;
  output Branch_o;
  output BranchType_o;
  output MemRead_o;
  output MemWrite_o;
  output MemtoReg_o;

  //Internal Signals
  reg RegWrite_o;
  reg [2-1:0] ALUOp_o;
  reg ALUSrc_o;
  reg RegDst_o;
  reg Jump_o;
  reg Branch_o;
  reg BranchType_o;
  reg MemRead_o;
  reg MemWrite_o;
  reg MemtoReg_o;

  //Main function
  /*your code here*/
  //Instruction Format
  parameter OP_R_TYPE = 6'b000000;
  parameter OP_ADDI = 6'b010011;
  parameter OP_BEQ = 6'b011001;
  parameter OP_LW = 6'b011000;
  parameter OP_SW = 6'b101000;
  parameter OP_BNE = 6'b011010;
  parameter OP_JUMP = 6'b001100;
  parameter OP_JAL = 6'b001111;
  parameter OP_BLT = 6'b011100;
  parameter OP_BNEZ = 6'b011101;
  parameter OP_BGEZ = 6'b011110;


  //ALU OP
  parameter ALU_OP_R_TYPE = 2'b00;
  parameter ALU_ADD = 2'b01;
  parameter ALU_SUB = 2'b10;
  parameter ALU_LESS = 2'b11;
  
    always @(instr_op_i) begin
      // Default values
      RegWrite_o   <= 1'b0;
      ALUOp_o      <= 2'b0;
      ALUSrc_o     <= 1'b0;
      RegDst_o     <= 1'b0;
      Jump_o       <= 1'b0;
      Branch_o     <= 1'b0;
      BranchType_o <= 1'b0;
      MemRead_o    <= 1'b0;
      MemWrite_o   <= 1'b0;
      MemtoReg_o   <= 1'b0;

      case (instr_op_i)
          // Instructions that require register write
          OP_R_TYPE, OP_ADDI, OP_LW, OP_JAL: 
              RegWrite_o <= 1'b1;
          default: 
              RegWrite_o <= 1'b0;
      endcase

      case (instr_op_i)
          // R-Type instructions
          OP_R_TYPE: 
              ALUOp_o <= ALU_OP_R_TYPE;
          // Instructions that perform addition
          OP_ADDI, OP_LW, OP_SW: 
              ALUOp_o <= ALU_ADD;

          // Instructions that perform subtraction
          OP_BEQ, OP_BNE, OP_BNEZ: 
              ALUOp_o <= ALU_SUB;

          // Instructions that compare less than
          OP_BLT, OP_BGEZ: 
              ALUOp_o <= ALU_LESS;

          default: 
              ALUOp_o <= 2'b0;
      endcase

      case (instr_op_i)
          // Immediate instructions use an immediate value
          OP_ADDI, OP_LW, OP_SW: 
              ALUSrc_o <= 1'b1;
          default: 
              ALUSrc_o <= 1'b0;
      endcase

      case (instr_op_i)
          // R-Type instructions write to a register
          OP_R_TYPE: 
              RegDst_o <= 1'b1;
          default: 
              RegDst_o <= 1'b0;
      endcase

      case (instr_op_i)
          // Jump and JAL instructions require a jump
          OP_JUMP, OP_JAL: 
              Jump_o <= 1'b1;
          // All other instructions do not require a jump
          default: 
              Jump_o <= 1'b0;
      endcase

      case (instr_op_i)
          // Branch instructions require branching
          OP_BEQ, OP_BNE, OP_BLT, OP_BNEZ, OP_BGEZ: 
              Branch_o <= 1'b1;
          // All other instructions do not require branching
          default: 
              Branch_o <= 1'b0;
      endcase

      case (instr_op_i)
          // BEQ and BGEZ are specific branch types
          OP_BEQ, OP_BGEZ: 
              BranchType_o <= 1'b1;

          default: 
              BranchType_o <= 1'b0;
      endcase

      case (instr_op_i)
          // Load instructions require memory read
          OP_LW: 
              MemRead_o <= 1'b1;

          // All other instructions do not require memory read
          default: 
              MemRead_o <= 1'b0;
      endcase

      case (instr_op_i)
          // Store instructions require memory write
          OP_SW: 
              MemWrite_o <= 1'b1;

          // All other instructions do not require memory write
          default: 
              MemWrite_o <= 1'b0;
      endcase

      case (instr_op_i)
          // Load instructions write data from memory to register
          OP_LW: 
              MemtoReg_o <= 1'b1;
          default: 
              MemtoReg_o <= 1'b0;
      endcase
  end
endmodule
