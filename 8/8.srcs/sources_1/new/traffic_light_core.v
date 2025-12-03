`timescale 1ns/1ps

module traffic_light_core(
    input clk,                  // 100MHz时钟（现实时间）
    input rst_n,                // 低电平有效复位
    input core_rst_n,           // 核心状态机复位（低电平有效）
    input [1:0] current_mode,   // 当前模式（来自模式管理模块）
    output reg [2:0] light_ew,  // 东西方向灯：[2]=LD10（绿），[1]=LD9（黄），[0]=LD8（红）
    output reg [2:0] light_ns,  // 南北方向灯：[2]=LD7（绿），[1]=LD6（黄），[0]=LD5（红）
    output reg [5:0] count_ew,  // 东西方向倒计时（秒级，现实时间）
    output reg [5:0] count_ns   // 南北方向倒计时（秒级，现实时间）
);

// 模式定义（与模式管理模块一致）
parameter MODE_NORMAL = 2'b00;
parameter MODE_PEAK   = 2'b01;
parameter MODE_EMERG  = 2'b10;
parameter MODE_SLEEP  = 2'b11;

// 现实时间参数（严格按文档要求）
// 正常模式：东西绿20s、黄5s、红15s；南北绿15s、黄5s、红20s
parameter NORMAL_GREEN_EW  = 20;    // 东西绿灯20s
parameter NORMAL_YELLOW    = 5;     // 黄灯5s
parameter NORMAL_RED_EW    = 15;    // 东西红灯15s
parameter NORMAL_GREEN_NS  = 15;    // 南北绿灯15s
parameter NORMAL_RED_NS    = 20;    // 南北红灯20s

// 高峰模式：东西绿25s、黄3s、红10s；南北绿10s、黄3s、红25s
parameter PEAK_GREEN_EW    = 25;    // 东西绿灯25s
parameter PEAK_YELLOW      = 3;     // 黄灯3s
parameter PEAK_RED_EW      = 10;    // 东西红灯10s
parameter PEAK_GREEN_NS    = 10;    // 南北绿灯10s
parameter PEAK_RED_NS      = 25;    // 南北红灯25s

// 状态定义（按东西方向时序，南北互补，符合文档状态表）
parameter S_EW_GREEN  = 3'b001;  // 东西绿灯→南北红灯
parameter S_EW_YELLOW = 3'b010;  // 东西黄灯→南北黄灯
parameter S_EW_RED    = 3'b100;  // 东西红灯→南北绿灯

// 内部信号（30位计数器覆盖最长25s×1e8=2.5e9周期）
reg [2:0] current_state;  // 当前状态（东西方向为主）
reg [2:0] next_state;     // 下一状态
reg [29:0] cnt;           // 30位计数器（最大1e9，满足25s计时）
// 动态时间参数（随模式切换）
reg [5:0] green_ew;   // 东西绿灯时间
reg [5:0] yellow;     // 黄灯时间
reg [5:0] red_ew;     // 东西红灯时间
reg [5:0] green_ns;   // 南北绿灯时间
reg [5:0] red_ns;     // 南北红灯时间

// 1. 参数更新逻辑（模式切换立即生效）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 复位后加载正常模式参数
        green_ew <= NORMAL_GREEN_EW;
        yellow <= NORMAL_YELLOW;
        red_ew <= NORMAL_RED_EW;
        green_ns <= NORMAL_GREEN_NS;
        red_ns <= NORMAL_RED_NS;
    end else if (!core_rst_n) begin
        // 核心复位时强制加载当前模式参数
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
            default: begin  // 应急/休眠模式，保持正常参数
                green_ew <= NORMAL_GREEN_EW;
                yellow <= NORMAL_YELLOW;
                red_ew <= NORMAL_RED_EW;
                green_ns <= NORMAL_GREEN_NS;
                red_ns <= NORMAL_RED_NS;
            end
        endcase
    end else begin
        // 正常运行时实时更新参数
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
            default: begin
                green_ew <= NORMAL_GREEN_EW;
                yellow <= NORMAL_YELLOW;
                red_ew <= NORMAL_RED_EW;
                green_ns <= NORMAL_GREEN_NS;
                red_ns <= NORMAL_RED_NS;
            end
        endcase
    end
end

// 2. 状态寄存器（时序逻辑，复位后重启时序）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || !core_rst_n) begin
        current_state <= S_EW_GREEN;  // 初始状态：东西绿灯（文档要求）
        cnt <= 30'd0;                 // 计数器清零
    end else begin
        current_state <= next_state;
        // 状态切换时计数器清零，否则递增（1e8周期=1秒）
        if (next_state != current_state) begin
            cnt <= 30'd0;
        end else begin
            cnt <= cnt + 30'd1;
        end
    end
end

// 3. 下一状态逻辑（按现实时间切换）
always @(*) begin
    next_state = current_state;
    case (current_state)
        S_EW_GREEN: begin
            // 绿灯计时到：green_ew × 1e8（1秒=1e8时钟周期）
            if (cnt >= green_ew * 100000000) begin
                next_state = S_EW_YELLOW;
            end
        end
        S_EW_YELLOW: begin
            // 黄灯计时到：yellow × 1e8
            if (cnt >= yellow * 100000000) begin
                next_state = S_EW_RED;
            end
        end
        S_EW_RED: begin
            // 红灯计时到：red_ew × 1e8
            if (cnt >= red_ew * 100000000) begin
                next_state = S_EW_GREEN;
            end
        end
        default: next_state = S_EW_GREEN;
    endcase
end

// 4. 输出逻辑（LED位定义符合文档：[2]=绿，[1]=黄，[0]=红）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || !core_rst_n) begin
        light_ew <= 3'b100;  // 复位后：东西绿灯（LD10亮）
        light_ns <= 3'b001;  // 复位后：南北红灯（LD5亮）
        count_ew <= green_ew;
        count_ns <= red_ns;
    end else begin
        case (current_state)
            // 状态1：东西绿灯 → 南北红灯
            S_EW_GREEN: begin
                light_ew <= 3'b100;  // LD10（绿）亮
                light_ns <= 3'b001;  // LD5（红）亮
                count_ew <= green_ew - (cnt / 100000000);  // 秒级倒计时
                count_ns <= red_ns - (cnt / 100000000);
            end
            // 状态2：东西黄灯 → 南北黄灯
            S_EW_YELLOW: begin
                light_ew <= 3'b010;  // LD9（黄）亮
                light_ns <= 3'b010;  // LD6（黄）亮
                count_ew <= yellow - (cnt / 100000000);
                count_ns <= yellow - (cnt / 100000000);
            end
            // 状态3：东西红灯 → 南北绿灯
            S_EW_RED: begin
                light_ew <= 3'b001;  // LD8（红）亮
                light_ns <= 3'b100;  // LD7（绿）亮
                count_ew <= red_ew - (cnt / 100000000);
                count_ns <= green_ns - (cnt / 100000000);
            end
            default: begin
                light_ew <= 3'b100;
                light_ns <= 3'b001;
                count_ew <= green_ew;
                count_ns <= red_ns;
            end
        endcase
    end
end

endmodule