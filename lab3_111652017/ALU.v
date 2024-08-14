module ALU (
    aluSrc1,
    aluSrc2,
    ALU_operation_i,
    result,
    zero,
    overflow
);

  //I/O ports
  input signed [32-1:0] aluSrc1;
  input signed [32-1:0] aluSrc2;
  input [4-1:0] ALU_operation_i;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  reg [32-1:0] result;
  wire zero;
  wire overflow;

  //Main function
  /*your code here*/
  parameter ADD = 4'b0010;
  parameter SUB = 4'b0110;
  parameter AND = 4'b0000;
  parameter OR = 4'b0001;
  parameter NOR = 4'b1100;
  parameter LESS = 4'b0111;

  always @(aluSrc1, aluSrc2, ALU_operation_i) begin
    case (ALU_operation_i)
      ADD: result <= aluSrc1 + aluSrc2;
      SUB: result <= aluSrc1 - aluSrc2;
      AND: result <= aluSrc1 & aluSrc2;
      OR: result <= aluSrc1 | aluSrc2;
      NOR: result <= ~(aluSrc1 | aluSrc2);
      LESS: result <= aluSrc1 < aluSrc2;
      default: result <= 32'b0;
    endcase
  end

  assign zero = result == 1'b0 ?  1'b1 : 1'b0;
  assign overflow = ~((ALU_operation_i == SUB) ^ (aluSrc1[31] ^ aluSrc2[31])) &
                      (aluSrc1[31] ^ result[31]) & (ALU_operation_i == SUB | ALU_operation_i == ADD);

endmodule
