`timescale 1ns/1ps

module key_debounce(
    input            clk,          // 100MHz系统时钟
    input            rst_n,        // 异步复位（高电平有效，来自顶层取反后）
    input      [1:0] key_in,       // 2个按键输入：[1]=BTNU（休眠），[0]=BTNC（应急），高电平按下
    output reg [1:0] key_state     // 消抖后稳定状态：高=释放（内部逻辑），低=按下（内部逻辑）
);

// 消抖参数：20ms（100MHz时钟=20ms×100MHz=2,000,000个周期）
parameter PARAM_CNT_MAX = 1999999;

// 内部信号：双按键独立同步+计数
reg [1:0] key_sync1;       // 第一拍同步（消亚稳态）
reg [1:0] key_sync2;       // 第二拍同步（稳定信号）
reg [20:0] cnt[1:0];       // 2个按键独立计数器（21位足够覆盖2e6）
reg [1:0] cnt_en;          // 计数器使能
integer i;                 // 循环变量

// 1. 异步转同步（打两拍+取反适配硬件电平）
// 关键修改：~key_in 将硬件高电平按下 → 内部低电平触发，兼容原有消抖逻辑
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_sync1 <= 2'b11;  // 内部初始状态：未按下（高电平）
        key_sync2 <= 2'b11;
    end else begin
        key_sync1 <= ~key_in;  // 核心修正：硬件高电平按下 → 内部低电平
        key_sync2 <= key_sync1;
    end
end

// 2. 消抖计时+稳定状态更新（逻辑不变，基于内部低电平触发）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_en <= 2'b00;
        key_state <= 2'b11;  // 初始释放（内部高电平）
        for(i=0; i<2; i=i+1) begin
            cnt[i] <= 21'd0;
        end
    end else begin
        for(i=0; i<2; i=i+1) begin
            // 检测到按键状态变化，启动计时
            if(key_sync2[i] != key_state[i]) begin
                cnt_en[i] <= 1'b1;
                cnt[i] <= cnt[i] + 21'd1;
                // 计时满20ms，更新稳定状态
                if(cnt[i] >= PARAM_CNT_MAX) begin
                    key_state[i] <= key_sync2[i];
                    cnt[i] <= 21'd0;
                    cnt_en[i] <= 1'b0;
                end
            end else begin
                // 状态无变化，计数器清零
                cnt[i] <= 21'd0;
                cnt_en[i] <= 1'b0;
            end
        end
    end
end

endmodule