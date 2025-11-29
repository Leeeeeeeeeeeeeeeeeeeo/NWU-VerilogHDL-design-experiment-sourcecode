`timescale 1ns / 1ps
module 	 TOP(input wire clk_100mhz,
             input wire[15:0]SW,
             output wire led_clk,
             output wire led_clrn,
             output wire led_sout,
             output wire LED_PEN,
             output wire seg_clk,
             output wire seg_clrn,
             output wire seg_sout,
             output wire SEG_PEN);

wire[31:0]Div;
wire[15:0]LED_DATA;
wire CK;



wire[63:0] disp_data;
wire[5:0] out;
wire[3:0] counter;
traffic2_2 U1(Div[24],SW[0],out,counter);
shumaguan U3(disp_data[63:56],counter);
clk_div       U8(clk_100mhz,1'b0,SW[2],Div,CK);

assign disp_data[55:0] = 56'hffffffffffffff;
P2S 			  #(.DATA_BITS(64),.DATA_COUNT_BITS(6))
P7SEG (clk_100mhz,
1'b0,
Div[20],
disp_data,
seg_clk,
seg_clrn,
seg_sout,
SEG_PEN
);

LED_P2S 			  #(.DATA_BITS(16),.DATA_COUNT_BITS(4))
PLED (clk_100mhz,
1'b0,
Div[20],
LED_DATA,
led_clk,
led_clrn,
led_sout,
LED_PEN
);
assign LED_DATA = ~{out[0],out[1],out[2],out[3],out[4],out[5],1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};

endmodule
