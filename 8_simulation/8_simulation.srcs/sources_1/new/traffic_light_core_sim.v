`timescale 1ns/1ps

module traffic_light_core_sim(
    input clk,                  // 100MHz时钟
    input core_rst_n,           // 模式切换复位
    input [1:0] current_mode,   // 当前模式
    output reg [2:0] light_ew,  // 东西方向灯：[绿,黄,红]（高电平亮）
    output reg [2:0] light_ns,  // 南北方向灯：[绿,黄,红]（高电平亮）
    output reg [5:0] count_ew,  // 东西方向倒计时（单位：ms）
    output reg [5:0] count_ns   // 南北方向倒计时（单位：ms）
);

// 模式定义
parameter MODE_NORMAL = 2'b00;
parameter MODE_PEAK   = 2'b01;
parameter MODE_EMERG  = 2'b10;
parameter MODE_SLEEP  = 2'b11;

// 仿真时间参数（原时间×1/1000，总周期40ms，适配仿真）
// 正常模式（总周期：20ms+5ms+15ms=40ms）
parameter NORMAL_GREEN_EW  = 20;    // 东西绿灯20ms（原20s）
parameter NORMAL_YELLOW    = 5;     // 黄灯5ms（原5s）
parameter NORMAL_RED_EW    = 15;    // 东西红灯15ms（原15s）
parameter NORMAL_GREEN_NS  = 15;    // 南北绿灯15ms（原15s）
parameter NORMAL_RED_NS    = 20;    // 南北红灯20ms（原20s）

// 高峰模式（总周期：25ms+3ms+10ms=38ms）
parameter PEAK_GREEN_EW    = 25;    // 东西绿灯25ms（原25s）
parameter PEAK_YELLOW      = 3;     // 黄灯3ms（原3s）
parameter PEAK_RED_EW      = 10;    // 东西红灯10ms（原10s）
parameter PEAK_GREEN_NS    = 10;    // 南北绿灯10ms（原10s）
parameter PEAK_RED_NS      = 25;    // 南北红灯25ms（原25s）

// 状态定义（东西方向为主，南北互补）
parameter S_EW_GREEN  = 3'b001;  // 东西绿灯 → 南北红灯
parameter S_EW_YELLOW = 3'b010;  // 东西黄灯 → 南北黄灯
parameter S_EW_RED    = 3'b100;  // 东西红灯 → 南北绿灯

// 内部信号：计时计数器（32位覆盖最大25ms×100MHz=2.5e6周期）
reg [2:0] current_state;
reg [2:0] next_state;
reg [31:0] cnt;  // 计时计数器（单位：时钟周期）
// 动态时间参数（随模式切换）
reg [5:0] green_ew;
reg [5:0] yellow;
reg [5:0] red_ew;
reg [5:0] green_ns;
reg [5:0] red_ns;

// 初始化所有寄存器
initial begin
    current_state = S_EW_GREEN;  // 初始东西绿灯
    next_state = S_EW_GREEN;
    cnt = 32'd0;
    green_ew = NORMAL_GREEN_EW;
    yellow = NORMAL_YELLOW;
    red_ew = NORMAL_RED_EW;
    green_ns = NORMAL_GREEN_NS;
    red_ns = NORMAL_RED_NS;
    light_ew = 3'b001;  // 初始东西绿
    light_ns = 3'b100;  // 初始南北红
    count_ew = NORMAL_GREEN_EW;
    count_ns = NORMAL_RED_NS;
end

// 1. 动态加载时间参数（模式切换时更新）
always @(posedge clk) begin
    case (current_mode)
        MODE_NORMAL: begin
            green_ew <= NORMAL_GREEN_EW;
            yellow <= NORMAL_YELLOW;
            red_ew <= NORMAL_RED_EW;
            green_ns <= NORMAL_GREEN_NS;
            red_ns <= NORMAL_RED_NS;
        end
        MODE_PEAK: begin
            green_ew <= PEAK_GREEN_EW;
            yellow <= PEAK_YELLOW;
            red_ew <= PEAK_RED_EW;
            green_ns <= PEAK_GREEN_NS;
            red_ns <= PEAK_RED_NS;
        end
        default: begin  // 应急/休眠模式保持正常参数
            green_ew <= NORMAL_GREEN_EW;
            yellow <= NORMAL_YELLOW;
            red_ew <= NORMAL_RED_EW;
            green_ns <= NORMAL_GREEN_NS;
            red_ns <= NORMAL_RED_NS;
        end
    endcase
end

// 2. 状态寄存器
always @(posedge clk or negedge core_rst_n) begin
    if (!core_rst_n) begin
        current_state <= S_EW_GREEN;
        cnt <= 32'd0;
    end else begin
        current_state <= next_state;
        if (next_state != current_state) begin
            cnt <= 32'd0;  // 状态切换时计数器清零
        end else begin
            cnt <= cnt + 32'd1;
        end
    end
end

// 3. 下一状态逻辑（按仿真时间参数切换）
always @(*) begin
    next_state = current_state;
    case (current_state)
        S_EW_GREEN: begin
            // 绿灯计时到（green_ew ms × 100MHz时钟周期）
            if (cnt >= green_ew * 100_000) begin  // 1ms=100,000时钟周期（100MHz）
                next_state = S_EW_YELLOW;
            end
        end
        S_EW_YELLOW: begin
            // 黄灯计时到（yellow ms × 100MHz）
            if (cnt >= yellow * 100_000) begin
                next_state = S_EW_RED;
            end
        end
        S_EW_RED: begin
            // 红灯计时到（red_ew ms × 100MHz）
            if (cnt >= red_ew * 100_000) begin
                next_state = S_EW_GREEN;
            end
        end
        default: next_state = S_EW_GREEN;
    endcase
end

// 4. 输出逻辑（灯状态+倒计时）
always @(posedge clk) begin
    case (current_state)
        S_EW_GREEN: begin
            light_ew <= 3'b001;  // 东西绿=1，黄=0，红=0
            light_ns <= 3'b100;  // 南北绿=0，黄=0，红=1
            // 秒级倒计时→ms级倒计时（cnt/100_000=已流逝ms数）
            count_ew <= green_ew - (cnt / 100_000);
            count_ns <= red_ns - (cnt / 100_000);
        end
        S_EW_YELLOW: begin
            light_ew <= 3'b010;  // 东西绿=0，黄=1，红=0
            light_ns <= 3'b010;  // 南北绿=0，黄=1，红=0
            count_ew <= yellow - (cnt / 100_000);
            count_ns <= yellow - (cnt / 100_000);
        end
        S_EW_RED: begin
            light_ew <= 3'b100;  // 东西绿=0，黄=0，红=1
            light_ns <= 3'b001;  // 南北绿=1，黄=0，红=0
            count_ew <= red_ew - (cnt / 100_000);
            count_ns <= green_ns - (cnt / 100_000);
        end
        default: begin
            light_ew <= 3'b001;
            light_ns <= 3'b100;
            count_ew <= green_ew;
            count_ns <= red_ns;
        end
    endcase
end

endmodule