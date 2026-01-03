module alu #(
  parameter int W = 32
)(
  input  logic [W-1:0] a,
  input  logic [W-1:0] b,
  input  logic [3:0]   op,
  output logic [W-1:0] y,
  output logic         zero
);

  // op encoding
  localparam logic [3:0]
    OP_ADD = 4'h0,
    OP_SUB = 4'h1,
    OP_AND = 4'h2,
    OP_OR  = 4'h3,
    OP_XOR = 4'h4,
    OP_SLT = 4'h5,
    OP_SLL = 4'h6,
    OP_SRL = 4'h7;

  logic signed [W-1:0] as, bs;

  always_comb begin
    as = a;
    bs = b;
    unique case (op)
      OP_ADD: y = a + b;
      OP_SUB: y = a - b;
      OP_AND: y = a & b;
      OP_OR : y = a | b;
      OP_XOR: y = a ^ b;
      OP_SLT: y = (as < bs) ? {{(W-1){1'b0}}, 1'b1} : '0;
      OP_SLL: y = a << b[$clog2(W)-1:0];
      OP_SRL: y = a >> b[$clog2(W)-1:0];
      default: y = '0;
    endcase
  end

  always_comb begin
    zero = (y == '0);
  end

endmodule
