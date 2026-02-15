// SR latch (behavioral model)
// Synthesized model has timing issues!
module sr_latch(
  input s, r,
  output logic q, nq
);

  always_latch
    if (s || r) begin
      q = s && !r;
      nq = r && !s;
    end

endmodule
