// Four-bit priority encoder
module prio_encoder(
  output logic [1:0] y,
  output logic valid,
  input [3:0] a
);

  always_comb
    casez (a)
      4'b1??? : {y,valid} = 3'b111;
      4'b01?? : {y,valid} = 3'b101;
      4'b001? : {y,valid} = 3'b011;    
      4'b0001 : {y,valid} = 3'b001; 
      default : {y,valid} = 3'b000;
    endcase

endmodule
