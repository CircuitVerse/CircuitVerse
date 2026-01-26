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

// Multibit serial adder
module serialadder
#(parameter WIDTH = 4)(
   input [WIDTH-1:0] a,
   input [WIDTH-1:0] b,
   output [WIDTH:0]  o
);
   
  logic [WIDTH:0]   c;
  logic [WIDTH-1:0]   s;
   
  assign c[0] = 1'b0;    
   
  genvar       ii;
  generate 
    for (ii=0; ii<WIDTH; ii=ii+1) 
      begin
        fulladder fa(a[ii],b[ii],c[ii],s[ii],c[ii+1]);
      end
  endgenerate
   
  assign o = {c[WIDTH], s};
 
endmodule
