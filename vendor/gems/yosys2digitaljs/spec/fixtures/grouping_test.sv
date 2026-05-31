module grouping_test(input a, b, c, input [2:0] d1, input [3:0] d2, output [2:0] o1, output [3:0] o2);
    assign o1 = b ? {1'b0, a, a} : d1;
    assign o2 = c ? {2'b0, a, a} : d2;
endmodule
