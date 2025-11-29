`timescale 1ns / 1ps

module test; reg a; reg b; wire [5:0] z; integer i; gate uut (.a(a), .b(b), .z(z));
    always
    begin
    for(i = 0;i < 4;i = i + 1)
    begin
        {a, b} = i;
        #100;
    end
    end
endmodule
