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

// master-slave D flip-flop
module dff_master_slave(
  input clk, d,
  output o
);

  logic q, nq1, nq2, nclk;

  d_latch dl1(d, clk, q, nq1);
  d_latch dl2(q, nclk, o, nq2);
  not g(nclk, clk);

endmodule
