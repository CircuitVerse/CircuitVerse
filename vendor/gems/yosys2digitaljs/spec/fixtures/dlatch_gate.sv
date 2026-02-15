// D latch (gate model)
module d_latch(
  input d, e,
  output q, nq
);

  logic s, r, nd;

  nor g1(q, r, nq);
  nor g2(nq, s, q);
  and g3(r, e, nd);
  and g4(s, e, d);
  not g5(nd, d);

endmodule
