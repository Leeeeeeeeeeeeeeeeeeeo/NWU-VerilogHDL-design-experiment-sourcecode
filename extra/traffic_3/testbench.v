`timescale 1ns/1ps
module traffic_2_tb;

parameter timecycle = 10;

reg clk;
reg rst_n;
wire [2:0] light1;
wire [2:0] light2;
wire [5:0] count;

initial begin
    clk   = 0;
    rst_n = 1;
    #timecycle rst_n = ~rst_n;
    #timecycle rst_n = ~rst_n;
end
 
always #(timecycle/2) clk = ~clk;

top traffic_tb(
    .clk(clk),
    .rst_n(rst_n),
    .light1(light1),
    .light2(light2),
    .count(count)
);
    
endmodule
