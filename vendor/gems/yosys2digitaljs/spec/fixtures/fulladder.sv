// Half adder
module halfadder(
  input a, 
  input b,
  output o,
  output c
);

  assign o = a ^ b;
  assign c = a & b;

endmodule

// Full adder
module fulladder(
  input a,
  input b,
  input d,
  output o,
  output c
);

  logic t, c1, c2;

  halfadder ha1(a, b, t, c1);
  halfadder ha2(t, d, o, c2);

  assign c = c1 | c2;

endmodule

