`include "traffic2.v"
`include "counter60.v"

module top (
   input clk,
   input rst_n,
   output [2:0] light1, //[green, red, yellow] 
   output [2:0] light2, //[green, red, yellow] 
   output [5:0] count
);
   
   counter60 counter(
       .clk(clk),
       .rst_n(rst_n),
       .count(count)
   );

   traffic2 traffic(
       .clk(clk),
       .rst_n(rst_n),
       .light1(light1),
       .light2(light2),
       .count(count)
   );
   
endmodule`
