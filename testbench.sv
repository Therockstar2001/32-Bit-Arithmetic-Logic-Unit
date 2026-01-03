module tb_alu;

  localparam int W = 32;

  logic [W-1:0] a, b;
  logic [3:0]   op;
  logic [W-1:0] y;
  logic         zero;

  alu #(.W(W)) dut (
    .a(a), .b(b), .op(op),
    .y(y), .zero(zero)
  );

  function automatic logic [W-1:0] golden(
    input logic [W-1:0] a_g,
    input logic [W-1:0] b_g,
    input logic [3:0]   op_g
  );
    logic signed [W-1:0] as, bs;
    as = a_g; bs = b_g;

    unique case (op_g)
      4'h0: golden = a_g + b_g;
      4'h1: golden = a_g - b_g;
      4'h2: golden = a_g & b_g;
      4'h3: golden = a_g | b_g;
      4'h4: golden = a_g ^ b_g;
      4'h5: golden = (as < bs) ? {{(W-1){1'b0}},1'b1} : '0;
      4'h6: golden = a_g << b_g[$clog2(W)-1:0];
      4'h7: golden = a_g >> b_g[$clog2(W)-1:0];
      default: golden = '0;
    endcase
  endfunction

  int errors = 0;

  task automatic run_one(input int idx);
    logic [W-1:0] exp;
    exp = golden(a,b,op);
    #1;
    if (y !== exp) begin
      errors++;
      $display("[FAIL] i=%0d op=%0h a=%0h b=%0h | y=%0h exp=%0h",
               idx, op, a, b, y, exp);
    end
    if (zero !== (exp=='0)) begin
      errors++;
      $display("[FAIL-Z] i=%0d op=%0h a=%0h b=%0h | zero=%0b exp_zero=%0b",
               idx, op, a, b, zero, (exp=='0));
    end
  endtask

  initial begin
    a = 32'd10; b = 32'd5; op = 4'h0; run_one(-1); // add
    op = 4'h1; run_one(-2); // sub
    op = 4'h2; run_one(-3); // and
    op = 4'h5; run_one(-4); // slt

    
    for (int i = 0; i < 1000; i++) begin
      a  = $urandom();
      b  = $urandom();
      op = $urandom_range(0,7);
      run_one(i);
    end

    if (errors == 0) $display("\n ALL TESTS PASSED\n");
    else            $display("\n TESTS FAILED: %0d errors\n", errors);

    $finish;
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule
