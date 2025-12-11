`timescale 1ns/1ps

module display_controller(
    input clk_100m,             // 100MHz系统时钟
    input [1:0] mode,           // 当前模式（正常/高峰/应急/休眠）
    input [5:0] count_ew,       // 东西方向倒计时（0~59）
    input [5:0] count_ns,       // 南北方向倒计时（0~59）
    output reg CA, CB, CC, CD, CE, CF, CG,  // 段选（共阳极：0=点亮，1=熄灭）
    output reg dp,              // 小数点（始终熄灭）
    output reg AN0, AN1, AN2, AN3  // 位选（共阳极：0=选中，1=未选中；AN3左→AN0右）
);

// 模式定义（与顶层/核心模块一致）
parameter MODE_NORMAL = 2'b00;
parameter MODE_PEAK   = 2'b01;
parameter MODE_EMERG  = 2'b10;  // 应急：全显0000
parameter MODE_SLEEP  = 2'b11;  // 休眠：全显9999

// 共阳极七段数码管段码表（低电平点亮）
parameter CODE_0 = 7'b0000001;  // 0
parameter CODE_1 = 7'b1001111;  // 1
parameter CODE_2 = 7'b0010010;  // 2
parameter CODE_3 = 7'b0000110;  // 3
parameter CODE_4 = 7'b1001100;  // 4
parameter CODE_5 = 7'b0100100;  // 5
parameter CODE_6 = 7'b0100000;  // 6
parameter CODE_7 = 7'b0001111;  // 7
parameter CODE_8 = 7'b0000000;  // 8
parameter CODE_9 = 7'b0000100;  // 9

// 内部信号：扫描时钟（250Hz，对应每个数字亮4ms，刷新周期16ms）
reg [17:0] div_cnt;  // 分频计数器
reg clk_scan;        // 扫描时钟（250Hz）
reg [1:0] digit_sel; // 位选计数器（0=AN3，1=AN2，2=AN1，3=AN0）
reg [3:0] current_digit; // 当前选中的显示数字（0~9）

// 初始化所有寄存器
initial begin
    div_cnt = 18'd0;
    clk_scan = 1'b0;
    digit_sel = 2'b00;
    current_digit = 4'd0;
    CA = 1'b1;
    CB = 1'b1;
    CC = 1'b1;
    CD = 1'b1;
    CE = 1'b1;
    CF = 1'b1;
    CG = 1'b1;
    dp = 1'b1;
    AN0 = 1'b1;
    AN1 = 1'b1;
    AN2 = 1'b1;
    AN3 = 1'b1;
end

// 分频生成250Hz扫描时钟（刷新周期16ms）
// 100MHz ÷ (2 × 200000) = 250Hz，每个数字亮4ms
always @(posedge clk_100m) begin
    if (div_cnt >= 18'd199_999) begin  // 分频阈值为199999
        div_cnt <= 18'd0;
        clk_scan <= ~clk_scan;
    end else begin
        div_cnt <= div_cnt + 18'd1;
    end
end

// 位选计数器（250Hz驱动，循环选中AN3→AN2→AN1→AN0）
always @(posedge clk_scan) begin
    digit_sel <= digit_sel + 2'b01;  // 00→01→10→11→00循环
end

// 位选信号生成（共阳极：低电平有效）
always @(*) begin
    case (digit_sel)
        2'b00: begin  // 选中最左AN3（东西十位）
            AN3 = 1'b0;
            AN2 = 1'b1;
            AN1 = 1'b1;
            AN0 = 1'b1;
        end
        2'b01: begin  // 选中左二AN2（东西个位）
            AN3 = 1'b1;
            AN2 = 1'b0;
            AN1 = 1'b1;
            AN0 = 1'b1;
        end
        2'b10: begin  // 选中右二AN1（南北十位）
            AN3 = 1'b1;
            AN2 = 1'b1;
            AN1 = 1'b0;
            AN0 = 1'b1;
        end
        2'b11: begin  // 选中最右AN0（南北个位）
            AN3 = 1'b1;
            AN2 = 1'b1;
            AN1 = 1'b1;
            AN0 = 1'b0;
        end
        default: begin  // 默认全未选中
            AN3 = 1'b1;
            AN2 = 1'b1;
            AN1 = 1'b1;
            AN0 = 1'b1;
        end
    endcase
end

// 选择当前要显示的数字（按模式+位选切换）
always @(*) begin
    case (mode)
        MODE_EMERG: current_digit = 4'd0;  // 应急模式：全显0
        MODE_SLEEP: current_digit = 4'd9;  // 休眠模式：全显9
        default: begin  // 正常/高峰模式：显示倒计时
            case (digit_sel)
                2'b00: current_digit = count_ew / 10;  // AN3：东西十位
                2'b01: current_digit = count_ew % 10;  // AN2：东西个位
                2'b10: current_digit = count_ns / 10;  // AN1：南北十位
                2'b11: current_digit = count_ns % 10;  // AN0：南北个位
                default: current_digit = 4'd0;
            endcase
        end
    endcase
end

// 段选信号解码（按共阳极低电平有效映射）
always @(*) begin
    case (current_digit)
        4'd0: {CA, CB, CC, CD, CE, CF, CG} = CODE_0;
        4'd1: {CA, CB, CC, CD, CE, CF, CG} = CODE_1;
        4'd2: {CA, CB, CC, CD, CE, CF, CG} = CODE_2;
        4'd3: {CA, CB, CC, CD, CE, CF, CG} = CODE_3;
        4'd4: {CA, CB, CC, CD, CE, CF, CG} = CODE_4;
        4'd5: {CA, CB, CC, CD, CE, CF, CG} = CODE_5;
        4'd6: {CA, CB, CC, CD, CE, CF, CG} = CODE_6;
        4'd7: {CA, CB, CC, CD, CE, CF, CG} = CODE_7;
        4'd8: {CA, CB, CC, CD, CE, CF, CG} = CODE_8;
        4'd9: {CA, CB, CC, CD, CE, CF, CG} = CODE_9;
        default: {CA, CB, CC, CD, CE, CF, CG} = 7'b1111111;  // 异常状态全灭
    endcase
    dp = 1'b1;  // 小数点始终熄灭
end

endmodule