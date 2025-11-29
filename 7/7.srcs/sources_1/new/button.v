`timescale 1ns / 1ps

module key_debounce(
    input clk,          // 时钟信号 W5
    input reset,        // 复位按键 BTNC
    input [2:0] keys,   // 三个独立按键 {BTNU, BTNL, BTND}
    output reg [2:0] leds // 三个LED {LD5, LD3, LD1}
);

// 参数定义
parameter CLK_FREQ = 100_000_000;  // 100MHz时钟
parameter DEBOUNCE_TIME = 20;      // 20ms消抖时间
parameter COUNTER_MAX = CLK_FREQ / 1000 * DEBOUNCE_TIME; // 20ms对应的计数值

// 内部信号定义
reg [2:0] key_reg;           // 按键同步寄存器
reg [2:0] key_stable;        // 稳定后的按键状态
reg [2:0] key_pressed;       // 按键按下检测
reg [2:0] led_state;         // LED状态寄存器
reg [19:0] debounce_counter; // 消抖计数器

// 按键同步，防止亚稳态
always @(posedge clk) begin
    key_reg <= keys;
end

// 消抖状态机
always @(posedge clk) begin
    if (reset) begin
        key_stable <= 3'b111;       // 按键默认高电平（未按下）
        debounce_counter <= 0;
    end else begin
        // 检测按键状态变化
        if (key_reg != key_stable) begin
            // 按键状态变化，启动消抖计数器
            if (debounce_counter < COUNTER_MAX) begin
                debounce_counter <= debounce_counter + 1;
            end else begin
                // 消抖时间到，更新稳定状态
                key_stable <= key_reg;
                debounce_counter <= 0;
            end
        end else begin
            // 按键状态稳定，重置计数器
            debounce_counter <= 0;
        end
    end
end

// 按键按下检测（下降沿检测）
always @(posedge clk) begin
    if (reset) begin
        key_pressed <= 3'b000;
    end else begin
        // 检测每个按键的下降沿
        key_pressed[0] <= (key_stable[0] == 1'b0) && (key_reg[0] == 1'b1); // BTND
        key_pressed[1] <= (key_stable[1] == 1'b0) && (key_reg[1] == 1'b1); // BTNL  
        key_pressed[2] <= (key_stable[2] == 1'b0) && (key_reg[2] == 1'b1); // BTNU
    end
end

// LED状态控制
always @(posedge clk) begin
    if (reset) begin
        led_state <= 3'b000;  // 复位时所有LED熄灭
    end else begin
        // 检测按键按下，切换对应LED状态
        if (key_pressed[0]) begin  // BTND 按下
            led_state[0] <= ~led_state[0]; // 切换 LD1
        end
        if (key_pressed[1]) begin  // BTNL 按下
            led_state[1] <= ~led_state[1]; // 切换 LD3
        end
        if (key_pressed[2]) begin  // BTNU 按下
            led_state[2] <= ~led_state[2]; // 切换 LD5
        end
    end
end

// LED输出
always @(posedge clk) begin
    leds <= led_state;
end

endmodule