// Simple asynchronous ROM
module rom
#(parameter AWIDTH = 4, DWIDTH = 4)(
  input [AWIDTH-1:0] addr,
  output [DWIDTH-1:0] data
);

  integer i;

  logic [DWIDTH-1:0] mem[2**AWIDTH-1:0];

  initial begin
    for (i = 0; i < 2**AWIDTH; i = i+1) mem[i] = i;
  end

  assign data = mem[addr];

endmodule
