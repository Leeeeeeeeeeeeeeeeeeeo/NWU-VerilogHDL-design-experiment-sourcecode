`timescale 1ns / 1ps

module seven_segment_display(
    input clk_100m,          // 100MHz系统时钟
    output reg CA, CB, CC, CD, CE, CF, CG,  // 七段数码管段选信号
    output dp,               // 小数点
    output reg AN0, AN1, AN2, AN3 // 数码管位选信号
);

// 分频模块生成200Hz扫描时钟
reg [17:0] counter = 0;
reg clk_200hz = 0;

// 分频参数：100,000,000 / 200 / 2 = 250,000
parameter DIVIDER_VALUE = 250000 - 1;

always @(posedge clk_100m) begin
    if (counter == DIVIDER_VALUE) begin
        counter <= 0;
        clk_200hz <= ~clk_200hz;
    end else begin
        counter <= counter + 1;
    end
end

// 要显示的数字：7484 (从左到右：AN3=7, AN2=4, AN1=8, AN0=4)
wire [3:0] digit_an3 = 4'd7; // AN3 (最左边) 显示7
wire [3:0] digit_an2 = 4'd4; // AN2 显示4
wire [3:0] digit_an1 = 4'd8; // AN1 显示8
wire [3:0] digit_an0 = 4'd4; // AN0 (最右边) 显示4

// 位选计数器
reg [1:0] digit_sel = 0;

// 200Hz时钟驱动位选扫描
always @(posedge clk_200hz) begin
    digit_sel <= digit_sel + 1;
end

// 位选信号解码（共阳极，低电平有效）
// AN3是最左边，AN0是最右边
always @(*) begin
    case(digit_sel)
        2'b00: begin
            AN3 = 1'b0; // 选中AN3 (最左边)
            AN2 = 1'b1;
            AN1 = 1'b1;
            AN0 = 1'b1;
        end
        2'b01: begin
            AN3 = 1'b1;
            AN2 = 1'b0; // 选中AN2
            AN1 = 1'b1;
            AN0 = 1'b1;
        end
        2'b10: begin
            AN3 = 1'b1;
            AN2 = 1'b1;
            AN1 = 1'b0; // 选中AN1
            AN0 = 1'b1;
        end
        2'b11: begin
            AN3 = 1'b1;
            AN2 = 1'b1;
            AN1 = 1'b1;
            AN0 = 1'b0; // 选中AN0 (最右边)
        end
        default: begin
            AN3 = 1'b1;
            AN2 = 1'b1;
            AN1 = 1'b1;
            AN0 = 1'b1;
        end
    endcase
end

// 当前选中的数字
reg [3:0] current_digit;

// 选择当前要显示的数字
always @(*) begin
    case(digit_sel)
        2'b00: current_digit = digit_an3;
        2'b01: current_digit = digit_an2;
        2'b10: current_digit = digit_an1;
        2'b11: current_digit = digit_an0;
        default: current_digit = 4'd0;
    endcase
end

// 七段数码管译码器（共阳极，低电平点亮）
always @(*) begin
    case(current_digit)
        4'd0: begin
            CA = 1'b0;
            CB = 1'b0;
            CC = 1'b0;
            CD = 1'b0;
            CE = 1'b0;
            CF = 1'b0;
            CG = 1'b1;
        end
        4'd1: begin
            CA = 1'b1;
            CB = 1'b0;
            CC = 1'b0;
            CD = 1'b1;
            CE = 1'b1;
            CF = 1'b1;
            CG = 1'b1;
        end
        4'd2: begin
            CA = 1'b0;
            CB = 1'b0;
            CC = 1'b1;
            CD = 1'b0;
            CE = 1'b0;
            CF = 1'b1;
            CG = 1'b0;
        end
        4'd3: begin
            CA = 1'b0;
            CB = 1'b0;
            CC = 1'b0;
            CD = 1'b0;
            CE = 1'b1;
            CF = 1'b1;
            CG = 1'b0;
        end
        4'd4: begin
            CA = 1'b1;
            CB = 1'b0;
            CC = 1'b0;
            CD = 1'b1;
            CE = 1'b1;
            CF = 1'b0;
            CG = 1'b0;
        end
        4'd5: begin
            CA = 1'b0;
            CB = 1'b1;
            CC = 1'b0;
            CD = 1'b0;
            CE = 1'b1;
            CF = 1'b0;
            CG = 1'b0;
        end
        4'd6: begin
            CA = 1'b0;
            CB = 1'b1;
            CC = 1'b0;
            CD = 1'b0;
            CE = 1'b0;
            CF = 1'b0;
            CG = 1'b0;
        end
        4'd7: begin
            CA = 1'b0;
            CB = 1'b0;
            CC = 1'b0;
            CD = 1'b1;
            CE = 1'b1;
            CF = 1'b1;
            CG = 1'b1;
        end
        4'd8: begin
            CA = 1'b0;
            CB = 1'b0;
            CC = 1'b0;
            CD = 1'b0;
            CE = 1'b0;
            CF = 1'b0;
            CG = 1'b0;
        end
        4'd9: begin
            CA = 1'b0;
            CB = 1'b0;
            CC = 1'b0;
            CD = 1'b0;
            CE = 1'b1;
            CF = 1'b0;
            CG = 1'b0;
        end
        default: begin
            CA = 1'b1;
            CB = 1'b1;
            CC = 1'b1;
            CD = 1'b1;
            CE = 1'b1;
            CF = 1'b1;
            CG = 1'b1;
        end
    endcase
end

// 小数点始终不点亮
assign dp = 1'b1;

endmodule