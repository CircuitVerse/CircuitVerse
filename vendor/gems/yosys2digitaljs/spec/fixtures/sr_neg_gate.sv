// SR latch with negated inputs (gate model)
module sr_neg_latch(
  input ns, nr,
  output q, nq
);

  nand g1(q, ns, nq);
  nand g2(nq, nr, q);

endmodule
