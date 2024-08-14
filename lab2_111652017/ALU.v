`include "ALU_1bit.v"
module ALU (
    aluSrc1,
    aluSrc2,
    invertA,
    invertB,
    operation,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input invertA;
  input invertB;
  input [2-1:0] operation;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [32-1:0] result;
  wire zero;
  wire overflow;

  //Main function
  /*your code here*/
  wire set;
  wire [32-1:0] carryOut;

  // special case for LSB
  // import module: https://stackoverflow.com/questions/19661868/include-a-module-in-verilog
  ALU_1bit alu1 (
      .a(aluSrc1[0]),
      .b(aluSrc2[0]),
      .invertA(invertA),
      .invertB(invertB),
      .operation(operation),
      .carryIn(invertB),
      .less(set),
      .result(result[0]),
      .carryOut(carryOut[0])
  );

  // other cases
  // import module: https://stackoverflow.com/questions/19661868/include-a-module-in-verilog
  // genvar: https://blog.csdn.net/bleauchat/article/details/86482941
  genvar i;
  generate
    for (i = 1; i < 32; i = i + 1) begin
        ALU_1bit alu2 (
            .a(aluSrc1[i]),
            .b(aluSrc2[i]),
            .invertA(invertA),
            .invertB(invertB),
            .operation(operation),
            .carryIn(carryOut[i-1]),
            .less(1'b0),
            .result(result[i]),
            .carryOut(carryOut[i])
        );
    end
  endgenerate

  // set some one bit signals
  assign zero = (result == 32'b0);
  assign overflow = carryOut[31] ^ carryOut[30];
  assign set = (aluSrc1 < aluSrc2) ? 1 : 0;

endmodule