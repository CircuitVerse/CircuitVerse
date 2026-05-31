// Adds input to accumulator on successive cycles
module cycleadder
#(parameter WIDTH = 4)(
  input clk,
  input rst,
  input en,
  input [WIDTH-1:0] A,
  output logic [WIDTH-1:0] O
);

  always_ff @(posedge clk or posedge rst)
    if (rst) O <= 0;
    else if (en) O <= O + A;

endmodule
