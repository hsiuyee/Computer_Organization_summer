module ALU_Ctrl (
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
    sftVariable_o,
    leftRight_o,
    JRsrc_o
);

  //I/O ports
  input [6-1:0] funct_i;
  input [2-1:0] ALUOp_i;

  output [4-1:0] ALU_operation_o;
  output [2-1:0] FURslt_o;
  output sftVariable_o;
  output leftRight_o;
  output JRsrc_o;

  //Internal Signals
  reg [4-1:0] ALU_operation_o;
  reg [2-1:0] FURslt_o;
  reg sftVariable_o;
  reg leftRight_o;
  reg JRsrc_o;


  //Main function
  /*your code here*/
  parameter ADD = 4'b0010;
  parameter SUB = 4'b0110;
  parameter AND = 4'b0000;
  parameter OR = 4'b0001;
  parameter NOR = 4'b1100;
  parameter LESS = 4'b0111;
  
  always @(ALUOp_i, funct_i) begin
    case (ALUOp_i)
      // R-type
      2'b00:
      case (funct_i)
        // add
        6'b100011: ALU_operation_o <= ADD;
        // sub
        6'b010011: ALU_operation_o <= SUB;
        // and
        6'b011111: ALU_operation_o <= AND;
        // or
        6'b101111: ALU_operation_o <= OR;
        // nor
        6'b010000: ALU_operation_o <= NOR;
        // less
        6'b010100: ALU_operation_o <= LESS;
        default:  ALU_operation_o  <= 4'b0000;
      endcase
      // addi
      2'b01: ALU_operation_o <= ADD;
      2'b10: ALU_operation_o <= SUB;
      2'b11: ALU_operation_o <= LESS;
      default: ALU_operation_o <= 4'b0000;
    endcase

    // FURslt_o
    case (ALUOp_i)
      2'b00:
      case (funct_i)
        6'b100011, 6'b010011, 6'b011111, 6'b101111, 6'b010000, 6'b010100: FURslt_o <= 2'd00;
        6'b010010, 6'b100010, 6'b011000, 6'b101000: FURslt_o <= 2'd01;
        default: FURslt_o <= 2'b0;
      endcase
      2'b01, 2'b10, 2'b11: FURslt_o <= 2'd00;
      default: FURslt_o <= 2'b00;
    endcase

    // leftRight_o
    case (ALUOp_i)
      2'b00:
      case (funct_i)
        6'b010010, 6'b011000: leftRight_o <= 1'b0;
        6'b100010, 6'b101000: leftRight_o <= 1'b1;
        default: leftRight_o <= 1'b0;
      endcase
      default: leftRight_o <= 1'b0;
    endcase

    // JRsrc_o
    case (ALUOp_i)
      2'b00:
      case (funct_i)
        6'b000001: JRsrc_o <= 1'b1;
        default: JRsrc_o <= 1'b0;
      endcase
      default: JRsrc_o <= 1'b0;
    endcase
  end
endmodule
