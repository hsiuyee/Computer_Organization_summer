`include "Full_adder.v"
module ALU_1bit (
    a,
    b,
    invertA,
    invertB,
    operation,
    carryIn,
    less,
    result,
    carryOut
);

  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [2-1:0] operation;
  input carryIn;
  input less;

  output result;
  output carryOut;

  //Internal Signals
  wire result;
  wire carryOut;

  //Main function
  /*your code here*/
  wire sum;
  wire ai, bi;

  // check whether signal negate 
  assign ai = a ^ invertA;
  assign bi = b ^ invertB;

  // by the description on P.6
  // assign: http://ccckmit.wikidot.com/ve:assign
  // branch: http://ccckmit.wikidot.com/ve:if

  assign result = (operation == 2'b00) ? ai & bi :
                  (operation == 2'b01) ? less :
                  (operation == 2'b10) ? ai | bi :
                  (operation == 2'b11) ? sum : 1'b0;

  // use Full adder
  // import module: https://stackoverflow.com/questions/19661868/include-a-module-in-verilog
  Full_adder fa (
      .carryIn(carryIn),
      .input1(ai),
      .input2(bi),
      .sum(sum),
      .carryOut(carryOut)
  );

endmodule