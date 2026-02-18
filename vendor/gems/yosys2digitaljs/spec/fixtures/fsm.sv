// Write your modules here!
module fsm(input clk, rst, a, output logic b);

  (* fsm_encoding = "auto" *)
  logic [1:0] state;
  
  localparam A = 2'b00;
  localparam B = 2'b01;
  localparam C = 2'b10;
  localparam D = 2'b11;

  always_ff @(posedge clk or posedge rst)
    if (rst) state <= B;
    else unique case(state)
      A: state <= C;
      B: state <= D;
      C: if (a) state <= D; else state <= B;
      D: state <= A;
    endcase

  always_comb begin
    b = 1'bx;
    unique case(state)
      A, D: b = 0;
      B: b = 1;
      C: if (a) b = 1; else b = 0;
    endcase
  end

endmodule
