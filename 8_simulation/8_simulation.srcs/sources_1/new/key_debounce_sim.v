`timescale 1ns/1ps

module key_debounce_sim(
    input            clk,          // 100MHz系统时钟
    input            rst_n,        // 异步复位（低电平有效）
    input      [1:0] key_in,       // 2个按键输入：[1]=BTNU（休眠），[0]=BTNC（应急）
    output reg [1:0] key_state     // 消抖后稳定状态：高=释放，低=按下
);

// 仿真专用消抖参数：20μs（100MHz×20μs=2000个周期，真实20ms→仿真20μs，缩放1000倍）
parameter PARAM_CNT_MAX = 1999;  // 2000个周期（含0）

// 内部信号（逻辑不变）
reg [1:0] key_sync1;       // 第一拍同步（消亚稳态）
reg [1:0] key_sync2;       // 第二拍同步（稳定信号）
reg [20:0] cnt[1:0];       // 计数器位宽保留，兼容小数值
reg [1:0] cnt_en;          // 计数器使能
integer i;                 // 循环变量

// 1. 异步转同步（逻辑不变）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_sync1 <= 2'b11;
        key_sync2 <= 2'b11;
    end else begin
        key_sync1 <= key_in;
        key_sync2 <= key_sync1;
    end
end

// 2. 消抖计时+稳定状态更新（仅参数修改）
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
                if(cnt[i] >= PARAM_CNT_MAX) begin  // 触发条件改为20μs
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