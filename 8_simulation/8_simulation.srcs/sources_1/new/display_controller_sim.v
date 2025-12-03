`timescale 1ns/1ps

module display_controller_sim(
    input clk_100m,             // 100MHz时钟（Basys3系统时钟）
    input rst_n,                // 低电平有效复位（Basys3复位键特性）
    input [1:0] mode,           // 当前模式（正常/高峰/应急/休眠）
    input [5:0] count_ew,       // 东西方向倒计时（0~59）
    input [5:0] count_ns,       // 南北方向倒计时（0~59）
    output reg CA, CB, CC, CD, CE, CF, CG,  // 段选（CA=图A，...，CG=图G）
    output reg dp,              // 小数点（始终熄灭）
    output reg AN0, AN1, AN2, AN3  // 位选（AN=1选中，逐位扫描）
);

// 模式定义（与系统一致）
parameter MODE_NORMAL = 2'b00;
parameter MODE_PEAK   = 2'b01;
parameter MODE_EMERG  = 2'b10;
parameter MODE_SLEEP  = 2'b11;

// 七段数码管编码（唯一标准：你提供的Basys3数码管结构图）
// 编码规则：{CA,CB,CC,CD,CE,CF,CG}，0=点亮（图中对应段阴极低电平），1=熄灭
parameter CODE_0 = 7'b0000001;  // 0：A/B/C/D/E/F亮，G灭
parameter CODE_1 = 7'b1100111;  // 1：B/C亮，A/D/E/F/G灭
parameter CODE_2 = 7'b0010010;  // 2：A/B/G/E/D亮，C/F灭（按图修正）
parameter CODE_3 = 7'b0000110;  // 3：A/B/G/C/D亮，E/F灭（按图修正）
parameter CODE_4 = 7'b1001100;  // 4：F/G/B/C亮，A/D/E灭（按图修正）
parameter CODE_5 = 7'b0100100;  // 5：A/F/G/C/D亮，B/E灭（按图修正）
parameter CODE_6 = 7'b0100000;  // 6：A/F/G/C/D/E亮，B灭（按图修正）
parameter CODE_7 = 7'b0001111;  // 7：A/B/C亮，D/E/F/G灭（按图修正）
parameter CODE_8 = 7'b0000000;  // 8：全亮
parameter CODE_9 = 7'b0000100;  // 9：A/B/C/D/F/G亮，E灭（按图修正）

// 内部扫描信号
reg [19:0] scan_cnt;  // 1ms扫描计数器（100MHz×1ms=100,000周期）
reg [1:0] scan_bit;   // 扫描位选（0=AN0，1=AN1，2=AN2，3=AN3）
reg [6:0] seg_code;   // 段选编码（映射到CA~CG）

// 1. 扫描计时（逐位扫描，符合硬件设计）
always @(posedge clk_100m or negedge rst_n) begin
    if (!rst_n) begin
        scan_cnt <= 20'd0;
        scan_bit <= 2'b00;
    end else begin
        if (scan_cnt >= 20'd99999) begin
            scan_cnt <= 20'd0;
            scan_bit <= scan_bit + 2'b01;
        end else begin
            scan_cnt <= scan_cnt + 20'd1;
        end
    end
end

// 2. 段选编码生成（核心：按图标准显示数字）
always @(*) begin
    case (mode)
        MODE_EMERG: seg_code = CODE_0;  // 应急：0000（全显0，按图标准）
        MODE_SLEEP: seg_code = CODE_9;  // 休眠：9999（全显9，按图标准）
        default: begin  // 正常/高峰：显示双方向倒计时（4个数码管）
            case (scan_bit)
                2'b00: seg_code = count2code(count_ew % 10);  // 东西个位
                2'b01: seg_code = count2code(count_ew / 10);  // 东西十位
                2'b10: seg_code = count2code(count_ns % 10);  // 南北个位
                2'b11: seg_code = count2code(count_ns / 10);  // 南北十位
                default: seg_code = CODE_0;
            endcase
        end
    endcase
end

// 3. 位选信号生成（AN=1选中，逐位轮流，无串扰）
always @(*) begin
    AN0 = 1'b0;
    AN1 = 1'b0;
    AN2 = 1'b0;
    AN3 = 1'b0;
    case (scan_bit)
        2'b00: AN0 = 1'b1;
        2'b01: AN1 = 1'b1;
        2'b10: AN2 = 1'b1;
        2'b11: AN3 = 1'b1;
        default: AN0 = 1'b1;
    endcase
end

// 4. 段选+小数点赋值（严格对应图中A-G段，无颠倒）
always @(*) begin
    CA = seg_code[6];  // 代码CA → 图中A段（阴极）
    CB = seg_code[5];  // 代码CB → 图中B段（阴极）
    CC = seg_code[4];  // 代码CC → 图中C段（阴极）
    CD = seg_code[3];  // 代码CD → 图中D段（阴极）
    CE = seg_code[2];  // 代码CE → 图中E段（阴极）
    CF = seg_code[1];  // 代码CF → 图中F段（阴极）
    CG = seg_code[0];  // 代码CG → 图中G段（阴极）
    dp = 1'b1;         // 小数点始终熄灭（图中无特殊需求）
end

// 辅助函数：数字→按图标准的共阳极七段码（10个数字全修正）
function [6:0] count2code;
    input [5:0] count;
    begin
        case (count)
            0: count2code = CODE_0;
            1: count2code = CODE_1;
            2: count2code = CODE_2;
            3: count2code = CODE_3;
            4: count2code = CODE_4;
            5: count2code = CODE_5;
            6: count2code = CODE_6;
            7: count2code = CODE_7;
            8: count2code = CODE_8;
            9: count2code = CODE_9;
            default: count2code = CODE_0;  // 异常值默认显0（按图标准）
        endcase
    end
endfunction

endmodule