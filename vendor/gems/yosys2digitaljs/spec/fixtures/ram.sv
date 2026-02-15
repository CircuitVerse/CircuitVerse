// Simple RAM
module ram
#(parameter AWIDTH = 4, DWIDTH = 4)(
  input clk,
  input [AWIDTH-1:0] addr,
  output [DWIDTH-1:0] data,
  input [AWIDTH-1:0] wraddr,
  input [DWIDTH-1:0] wrdata
);

  integer i;

  logic [DWIDTH-1:0] mem[2**AWIDTH-1:0];

  initial begin
    for (i = 0; i < 2**AWIDTH; i = i+1) mem[i] = i;
  end

  assign data = mem[addr];

  always_ff @(posedge clk) mem[wraddr] <= wrdata;

endmodule
