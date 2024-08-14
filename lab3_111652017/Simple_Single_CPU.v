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

module Simple_Single_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signles
  wire [32-1:0] pc_input;
  wire [32-1:0] pc_output;
  wire [32-1:0] pc_plus4;
  wire [32-1:0] pc_branch_target;
  wire [32-1:0] pc_no_jump;
  wire [32-1:0] pc_temp;
  wire [32-1:0] instruction;
  wire reg_write_enable;
  wire [2-1:0] alu_operation_code;
  wire ALUSrc;
  wire RegDst;
  wire Jump;
  wire Branch;
  wire BranchType;
  wire JRsrc;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire [5-1:0] RegAddrTemp;
  wire [5-1:0] RegAddr;
  wire [32-1:0] write_data;
  wire [32-1:0] rs_data;
  wire [32-1:0] rt_data;
  wire [4-1:0] alu_operation;
  wire [2-1:0] fur_select;
  wire sft_variable;
  wire left_right;
  wire [32-1:0] extended_data;
  wire [32-1:0] zero_filled_data;
  wire [32-1:0] alu_src_data;
  wire [32-1:0] alu_result;
  wire zero;
  wire overflow;
  wire [5-1:0] shift_amount;
  wire [32-1:0] shift_result;
  wire [32-1:0] register_data;
  wire [32-1:0] memory_data;
  wire [32-1:0] data_no_jal;



  //modules
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_input),
      .pc_out_o(pc_output)
  );

  Adder Adder1 (
      .src1_i(pc_output),
      .src2_i(32'd4),
      .sum_o (pc_plus4)
  );

  Adder Adder2 (
      .src1_i(pc_plus4),
      .src2_i({extended_data[29:0], 2'b00}),
      .sum_o (pc_branch_target)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i (pc_plus4),
      .data1_i (pc_branch_target),
      .select_i(Branch & (~BranchType ^ zero)),
      .data_o  (pc_no_jump)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i (pc_no_jump),
      .data1_i ({pc_plus4[31:28], instruction[25:0], 2'b00}),
      .select_i(Jump),
      .data_o  (pc_temp)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jr (
      .data0_i (pc_temp),
      .data1_i (rs_data),
      .select_i(JRsrc),
      .data_o  (pc_input)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_output),
      .instr_o  (instruction)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_RS_RT (
      .data0_i (instruction[20:16]),
      .data1_i (instruction[15:11]),
      .select_i(RegDst),
      .data_o  (RegAddrTemp)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (RegAddrTemp),
      .data1_i (5'd31),
      .select_i(Jump),
      .data_o  (RegAddr)
  );

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(instruction[25:21]),
      .RTaddr_i(instruction[20:16]),
      .RDaddr_i(RegAddr),
      .RDdata_i(write_data),
      .RegWrite_i(reg_write_enable & (~JRsrc)),
      .RSdata_o(rs_data),
      .RTdata_o(rt_data)
  );

  Decoder Decoder (
      .instr_op_i(instruction[31:26]),
      .RegWrite_o(reg_write_enable),
      .ALUOp_o(alu_operation_code),
      .ALUSrc_o(ALUSrc),
      .RegDst_o(RegDst),
      .Jump_o(Jump),
      .Branch_o(Branch),
      .BranchType_o(BranchType),
      .MemRead_o(MemRead),
      .MemWrite_o(MemWrite),
      .MemtoReg_o(MemtoReg)
  );

  ALU_Ctrl AC (
      .funct_i(instruction[5:0]),
      .ALUOp_i(alu_operation_code),
      .ALU_operation_o(alu_operation),
      .FURslt_o(fur_select),
      .sftVariable_o(sft_variable),
      .leftRight_o(left_right),
      .JRsrc_o(JRsrc)
  );

  Sign_Extend SE (
      .data_i(instruction[15:0]),
      .data_o(extended_data)
  );

  Zero_Filled ZF (
      .data_i(instruction[15:0]),
      .data_o(zero_filled_data)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (rt_data),
      .data1_i (extended_data),
      .select_i(ALUSrc),
      .data_o  (alu_src_data)
  );

  ALU ALU (
      .aluSrc1(rs_data),
      .aluSrc2(alu_src_data),
      .ALU_operation_i(alu_operation),
      .result(alu_result),
      .zero(zero),
      .overflow(overflow)
  );

  Mux2to1 #(
      .size(5)
  ) Shamt_Src (
      .data0_i (instruction[10:6]),
      .data1_i (rs_data[4:0]),
      .select_i(sft_variable),
      .data_o  (shift_amount)
  );

  Shifter shifter (
      .leftRight(left_right),
      .shamt(shift_amount),
      .sftSrc(alu_src_data),
      .result(shift_result)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (alu_result),
      .data1_i (shift_result),
      .data2_i (zero_filled_data),
      .select_i(fur_select),
      .data_o  (register_data)
  );

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(register_data),
      .data_i(rt_data),
      .MemRead_i(MemRead),
      .MemWrite_i(MemWrite),
      .data_o(memory_data)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Read_Mem (
      .data0_i (register_data),
      .data1_i (memory_data),
      .select_i(MemRead),
      .data_o  (data_no_jal)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Jal (
      .data0_i (data_no_jal),
      .data1_i (pc_plus4),
      .select_i(Jump),
      .data_o  (write_data)
  );

endmodule