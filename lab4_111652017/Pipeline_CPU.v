`include "Program_Counter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"
`include "Pipe_Reg.v"

module Pipeline_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  /*your code here*/
  //Internal Signles
  wire [32-1:0] pc_in;
  wire [32-1:0] pc_out;
  wire [32-1:0] pc_add;
  wire [32-1:0] pc_branch;
  wire [32-1:0] pc_no_jump;
  wire [32-1:0] pc_temp;
  wire [32-1:0] instr;
  wire RegWrite;
  wire [2-1:0] ALUOp;
  wire ALUSrc;
  wire RegDst;
  wire Jump;
  wire Branch;
  wire JRsrc;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire [5-1:0] RegAddrTemp;
  wire [5-1:0] RegAddr;
  wire [32-1:0] WriteData;
  wire [32-1:0] RSdata;
  wire [32-1:0] RTdata;
  wire [4-1:0] ALU_operation;
  wire [2-1:0] FURslt;
  wire sftVariable;
  wire leftRight;
  wire [32-1:0] extendData;
  wire [32-1:0] zeroData;
  wire [32-1:0] ALUsrcData;
  wire [32-1:0] ALUresult;
  wire zero;
  wire overflow;
  wire [5-1:0] shamt;
  wire [32-1:0] sftResult;
  wire [32-1:0] RegData;
  wire [32-1:0] MemData;
  wire [32-1:0] WB_write_back;

  //modules


  // --------------------------------------------------------------    IF
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_in),
      .pc_out_o(pc_out)
  );

  Adder Adder1 (
      .src1_i(pc_out),
      .src2_i(32'd4),
      .sum_o (pc_in)
  );
  
  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instr)
  );
  // --------------------------------------------------------------    IF end

  // --------------------------------------------------------------    IF_ID_stage reg
  wire [32-1:0] IF_ID_pc_add;
  wire [32-1:0] IF_ID_instr;
  
  Pipe_Reg #(
      .size(32)
  ) pipe_IF_ID_pc_add (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(pc_in),
      .data_o(IF_ID_pc_add)
  );

  Pipe_Reg #(
      .size(32)
  ) pipe_IF_ID_instr (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(instr),
      .data_o(IF_ID_instr)
  );

  // --------------------------------------------------------------    IF_ID_stage end








  // --------------------------------------------------------------    ID
  Decoder Decoder (
      .instr_op_i(IF_ID_instr[31:26]),
      .RegWrite_o(RegWrite),
      .ALUOp_o(ALUOp),
      .ALUSrc_o(ALUSrc),
      .RegDst_o(RegDst),
      .Jump_o(Jump),
      .Branch_o(Branch),
      .MemRead_o(MemRead),
      .MemWrite_o(MemWrite),
      .MemtoReg_o(MemtoReg)
  );
  
  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(IF_ID_instr[25:21]),
      .RTaddr_i(IF_ID_instr[20:16]),
      .RDaddr_i(RegAddr),
      .RDdata_i(WriteData),
      .RegWrite_i(RegWrite),
      .RSdata_o(RSdata),
      .RTdata_o(RTdata)
  );

  Sign_Extend SE (
      .data_i(IF_ID_instr[15:0]),
      .data_o(extendData)
  );
  // --------------------------------------------------------------    ID end
  // --------------------------------------------------------------    ID_EX_stage reg
  wire [32-1:0] ID_EX_pc_add;
  wire [32-1:0] ID_EX_Read_data1;
  wire [32-1:0] ID_EX_Read_data2;
  wire [32-1:0] ID_EX_SE;
  wire [25-21:0] ID_EX_RTaddr_i;
  wire [20-16:0] ID_EX_RDaddr_i;
  wire [2-1:0] ID_EX_WB; //MemtoReg, RegWrite
  wire [1+1+1-1:0] ID_EX_M; // branch, MemRead, MemWrite
  wire [1+2+1-1:0] ID_EX_EX; // RegDst, ALUOp, ALUSrc;


  Pipe_Reg #(
      .size(32)
  ) pipe_ID_EX_pc_add (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(IF_ID_pc_add),
      .data_o(ID_EX_pc_add)
  );

  Pipe_Reg #(
      .size(32)
  ) pipe_ID_EX_Read_data1 (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(RSdata),
      .data_o(ID_EX_Read_data1)
  );

  Pipe_Reg #(
      .size(32)
  ) pipe_ID_EX_Read_data2 (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(RTdata),
      .data_o(ID_EX_Read_data2)
  );
  // other
  Pipe_Reg #(
      .size(32)
  ) pipe_ID_EX_SE (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(extendData),
      .data_o(ID_EX_SE)
  );

  Pipe_Reg #(
      .size(5)
  ) pipe_ID_EX_RTaddr_i (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(IF_ID_instr[20:16]),
      .data_o(ID_EX_RTaddr_i)
  );

  Pipe_Reg #(
      .size(5)
  ) pipe_ID_EX_RDaddr_i (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(IF_ID_instr[15:11]),
      .data_o(ID_EX_RDaddr_i)
  );
  // control
  Pipe_Reg #(
      .size(2)
  ) pipe_ID_EX_WB (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i({RegWrite, MemtoReg}),
      .data_o(ID_EX_WB)
  );

  Pipe_Reg #(
      .size(3)
  ) pipe_ID_EX_M (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i({Branch, MemRead, MemWrite}),
      .data_o(ID_EX_M)
  );

  Pipe_Reg #(
      .size(4)
  ) pipe_ID_EX_EX (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i({RegDst, ALUOp, ALUSrc}),
      .data_o(ID_EX_EX)
  );
  // --------------------------------------------------------------    ID_EX_stage end








  // --------------------------------------------------------------    EX
  Adder Adder2 (
      .src1_i(ID_EX_pc_add),
      .src2_i({ID_EX_SE[29:0], 2'b00}),
      .sum_o (pc_branch)
  );

  ALU_Ctrl AC (
      .funct_i(ID_EX_SE[5:0]),
      .ALUOp_i(ID_EX_EX[2:1]),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .sftVariable_o(sftVariable),
      .leftRight_o(leftRight),
      .JRsrc_o(JRsrc)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_2 (
      .data0_i (ID_EX_Read_data2),
      .data1_i (ID_EX_SE),
      .select_i(ID_EX_EX[3]),
      .data_o  (ALUsrcData)
  );

  ALU ALU (
      .aluSrc1(RSdata),
      .aluSrc2(ALUsrcData),
      .ALU_operation_i(ALU_operation),
      .result(ALUresult),
      .zero(zero),
      .overflow(overflow)
  );

  Shifter shifter (
      .leftRight(leftRight),
      .shamt(shamt),
      .sftSrc(ALUsrcData),
      .result(sftResult)
  );
  
  // --------------------------------------------------------------    EX end

  // EX_MEN_stage reg
  wire [32-1:0] EX_MEM_branch_address;
  wire [1+1+1-1:0] EX_MEM_M;
  wire [20-16:0] EX_MEM_write_back_reg;
  wire [32-1:0] EX_MEM_write_data;
  wire [32-1:0] EX_MEM_alu_result;
  wire EX_MEM_Zero;
  wire [2-1:0] EX_MEM_WB;


  Pipe_Reg #(
      .size(32)
  ) pipe_EX_MEM_branch_address (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(pc_branch),
      .data_o(EX_MEM_branch_address)
  );

  wire [20-16:0] temp_EX_MEM_write_back_reg;

  Mux2to1 #(
      .size(5)
  ) Mux_RS_RT (
      .data0_i (ID_EX_RDaddr_i),
      .data1_i (ID_EX_RTaddr_i),
      .select_i(ID_EX_EX[0]),
      .data_o  (temp_EX_MEM_write_back_reg)
  );

  Pipe_Reg #(
      .size(5)
  ) pipe_EX_MEM_write_back_reg (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(temp_EX_MEM_write_back_reg),
      .data_o(EX_MEM_write_back_reg)
  );

  Pipe_Reg #(
      .size(32)
  ) pipe_EX_MEM_write_data (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(ID_EX_Read_data2),
      .data_o(EX_MEM_write_data)
  );

  Pipe_Reg #(
      .size(1)
  ) pipe_EX_MEM_Zero (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(zero),
      .data_o(EX_MEM_Zero)
  );

  Pipe_Reg #(
      .size(32)
  ) pipe_EX_MEM_alu_result (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(ALUresult),
      .data_o(EX_MEM_alu_result)
  );
  // control
  Pipe_Reg #(
      .size(2)
  ) pipe_EX_MEM_WB (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(ID_EX_WB),
      .data_o(EX_MEM_WB)
  );

  Pipe_Reg #(
      .size(3)
  ) pipe_EX_MEM_M (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(ID_EX_M),
      .data_o(EX_MEM_M)
  );
  // EX_MEN_stage end









  
  // --------------------------------------------------------------    MEM
  Mux2to1 #(
      .size(32)
  ) Mux_pc_no_jump (
      .data0_i (pc_in),
      .data1_i (EX_MEM_branch_address),
      .select_i(ID_EX_M[0] & EX_MEM_Zero),
      .data_o  (pc_in)
  );


  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(EX_MEM_alu_result),
      .data_i(EX_MEM_write_data),
      .MemRead_i(ID_EX_M[1]),
      .MemWrite_i(ID_EX_M[2]),
      .data_o(MemData)
  );
  // --------------------------------------------------------------    MEM end

  // --------------------------------------------------------------    MEN_WB_stage reg
  wire [20-16:0] MEM_WB_write_back_reg;
  wire [32-1:0] MEM_WB_alu_result;
  wire [32-1:0] MEM_WB_read_data;
  wire [2-1:0] MEM_WB_WB;

  Pipe_Reg #(
      .size(32)
  ) pipe_MEM_WB_read_data (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(MemData),
      .data_o(MEM_WB_read_data)
  );

  Pipe_Reg #(
      .size(32)
  ) pipe_MEM_WB_alu_result (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(EX_MEM_alu_result),
      .data_o(MEM_WB_alu_result)
  );

  Pipe_Reg #(
      .size(5)
  ) pipe_MEM_WB_write_back_reg (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(EX_MEM_write_back_reg),
      .data_o(MEM_WB_write_back_reg)
  );
  // control
  Pipe_Reg #(
      .size(2)
  ) pipeMEM_WB_WB (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(EX_MEM_WB),
      .data_o(MEM_WB_WB)
  );
  // --------------------------------------------------------------    MEN_WB_stage end








  // --------------------------------------------------------------    WB
  Mux2to1 #(
      .size(32)
  ) Reg_Write (
      .data0_i (MEM_WB_alu_result),
      .data1_i (MEM_WB_read_data),
      .select_i(MEM_WB_WB[1]),
      .data_o  (WriteData)
  );

  assign RegWrite = MEM_WB_WB[0];
  assign WriteData = (MEM_WB_WB[1] == 1'b0) ? MEM_WB_alu_result : MEM_WB_read_data;
  assign RegAddr = MEM_WB_write_back_reg;
  // --------------------------------------------------------------    WB end
endmodule