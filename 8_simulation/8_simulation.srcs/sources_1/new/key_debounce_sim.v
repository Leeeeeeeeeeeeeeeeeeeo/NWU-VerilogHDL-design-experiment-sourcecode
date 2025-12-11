`timescale 1ns/1ps

module key_debounce_sim(
    input            clk,          // 100MHz系统时钟
    input      [1:0] key_in,       // 2个按键输入：[1]=休眠(BTNU)，[0]=应急(BTNC)
                                   // 硬件特性：未按=0，按下=1
    output reg [1:0] key_state     // 消抖后状态：高=按下，低=释放
);

// 仿真消抖参数：20us（原20ms缩放1/1000，避免仿真时间过长）
// 100MHz × 20us = 2000个时钟周期
parameter PARAM_CNT_MAX = 1999;

// 内部信号：双按键独立同步+计数
reg [1:0] key_sync1;       // 第一拍同步（消亚稳态）
reg [1:0] key_sync2;       // 第二拍同步（稳定信号）
reg [20:0] cnt[1:0];       // 21位计数器（覆盖2000周期）
reg [1:0] cnt_en;          // 计数器使能
integer i;                 // 循环变量

// 初始化所有寄存器
initial begin
    key_sync1 = 2'b00;
    key_sync2 = 2'b00;
    cnt_en = 2'b00;
    key_state = 2'b00;  // 初始按键未按
    for(i=0; i<2; i=i+1) begin
        cnt[i] = 21'd0;
    end
end

// 1. 异步转同步（打两拍，直接同步硬件电平）
always @(posedge clk) begin
    key_sync1 <= key_in;  // 直接接收硬件输入（0=未按，1=按下）
    key_sync2 <= key_sync1;  // 第二拍同步，稳定信号
end

// 2. 消抖计时+稳定状态更新（key_state高=按下，低=释放）
always @(posedge clk) begin
    for(i=0; i<2; i=i+1) begin
        // 检测到按键电平变化（未按→按下 或 按下→未按）
        if(key_sync2[i] != key_state[i]) begin
            cnt_en[i] <= 1'b1;
            cnt[i] <= cnt[i] + 21'd1;
            // 消抖时间到，更新稳定状态
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

endmodule