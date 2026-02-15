// SR latch (gate model)
module sr_latch(
  input s, r,
  output q, nq
);

  nor g1(q, r, nq);
  nor g2(nq, s, q);

endmodule
