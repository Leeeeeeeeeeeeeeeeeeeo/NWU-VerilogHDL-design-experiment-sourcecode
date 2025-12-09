`timescale 1ns/1ps

module key_debounce(
    input            clk,          // 100MHz系统时钟（现实时间基准）
    input            rst_n,        // 低电平有效复位
    input      [1:0] key_in,       // 2个按键输入：[1]=BTNU（休眠），[0]=BTNC（应急）（高电平按下）
    output reg [1:0] key_state     // 消抖后稳定状态：高=释放，低=按下
);

// 现实消抖参数：20ms（硬件标准消抖时间）
// 计算：100MHz × 20ms = 2,000,000个时钟周期（0~1999999）
parameter PARAM_CNT_MAX = 1999999;

// 内部信号：双按键独立同步+计数（21位计数器覆盖2e6周期）
reg [1:0] key_sync1;       // 第一拍同步（消亚稳态）
reg [1:0] key_sync2;       // 第二拍同步（稳定信号）
reg [20:0] cnt[1:0];       // 21位计数器（足够覆盖2e6）
reg [1:0] cnt_en;          // 计数器使能
integer i;                 // 循环变量

// 1. 异步转同步（打两拍+取反适配硬件电平）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_sync1 <= 2'b11;
        key_sync2 <= 2'b11;
    end else begin
        key_sync1 <= ~key_in;  // 硬件高电平按下→内部低电平触发
        key_sync2 <= key_sync1;
    end
end

// 2. 消抖计时+稳定状态更新
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_en <= 2'b00;
        key_state <= 2'b11;
        for(i=0; i<2; i=i+1) begin
            cnt[i] <= 21'd0;
        end
    end else begin
        for(i=0; i<2; i=i+1) begin
            if(key_sync2[i] != key_state[i]) begin
                cnt_en[i] <= 1'b1;
                cnt[i] <= cnt[i] + 21'd1;
                if(cnt[i] >= PARAM_CNT_MAX) begin
                    key_state[i] <= key_sync2[i];
                    cnt[i] <= 21'd0;
                    cnt_en[i] <= 1'b0;
                end
            end else begin
                cnt[i] <= 21'd0;
                cnt_en[i] <= 1'b0;
            end
        end
    end
end

endmodule