`timescale 1ns / 1ps

module gate(
            input a,
            input b,
            output [5:0] z);
    assign z[0] = a & b;
    assign z[1] = ~(a & b);
    assign z[2] = a | b;
    assign z[3] = ~(a | b);
    assign z[4] = a ^ b;
    assign z[5] = a ~^ b;
endmodule
