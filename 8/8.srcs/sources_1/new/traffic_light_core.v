module traffic_light_core(
    input clk,              // 100MHz系统时钟
    input rst_n,            // 异步复位（低电平有效）
    input core_rst_n,       // 核心复位信号（低电平有效，来自模式管理模块）
    input [1:0] current_mode,  // 当前模式（正常/高峰/应急/休眠）
    output reg [2:0] light_ew,  // 东西方向灯：[绿,黄,红]（LD10,LD9,LD8）
    output reg [2:0] light_ns,  // 南北方向灯：[绿,黄,红]（LD7,LD6,LD5）
    output reg [5:0] count_ew,  // 东西方向倒计时（0~60秒）
    output reg [5:0] count_ns   // 南北方向倒计时（0~60秒）
);

// 状态定义（严格遵循实验状态转移表）
parameter S_EW_GREEN  = 2'b00;  // 状态1：东西绿，南北红
parameter S_EW_YELLOW = 2'b01;  // 状态2：东西黄，南北黄
parameter S_NS_GREEN  = 2'b10;  // 状态3：东西红，南北绿

// 模式定义（与mode_manager一致）
parameter MODE_NORMAL = 2'b00;
parameter MODE_PEAK   = 2'b01;

// 现实时间参数（实验要求）
// 普通模式：东西绿20s、黄5s、红15s；南北绿15s、黄5s、红20s
parameter EW_GREEN_NORMAL  = 20;
parameter EW_YELLOW_NORMAL = 5;
parameter NS_GREEN_NORMAL  = 15;
// 高峰模式：东西绿25s、黄3s、红10s；南北绿10s、黄3s、红25s
parameter EW_GREEN_PEAK    = 25;
parameter EW_YELLOW_PEAK   = 3;
parameter NS_GREEN_PEAK    = 10;

// 内部信号
reg [1:0] current_state, next_state;
reg [5:0] timer;          // 状态持续计时器（秒级）
reg [25:0] clk_div;       // 1Hz分频计数器（100MHz→1Hz）
reg clk_1hz;              // 1Hz时钟（秒级计时触发）
reg [1:0] mode_prev;      // 上一周期模式（检测模式切换）

// 1. 100MHz→1Hz分频逻辑（秒级计时基础）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_div <= 26'd0;
        clk_1hz <= 1'b0;
    end else if (clk_div == 26'd49_999_999) begin  // 5000万周期=0.5秒，翻转得1Hz
        clk_div <= 26'd0;
        clk_1hz <= ~clk_1hz;
    end else begin
        clk_div <= clk_div + 26'd1;
    end
end

// 2. 模式变化检测（模式切换时重置计时器）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mode_prev <= MODE_NORMAL;
    end else begin
        mode_prev <= current_mode;
    end
end

// 3. 状态寄存器+计时器逻辑（1Hz驱动，应急/休眠时暂停）
always @(posedge clk_1hz or negedge rst_n or negedge core_rst_n) begin
    if (!rst_n || !core_rst_n) begin
        // 复位：恢复初始状态（S_EW_GREEN）+ 加载初始计时
        current_state <= S_EW_GREEN;
        timer <= (current_mode == MODE_PEAK) ? EW_GREEN_PEAK : EW_GREEN_NORMAL;
    end else if (current_mode == MODE_NORMAL || current_mode == MODE_PEAK) begin
        // 仅正常/高峰模式运行状态机
        current_state <= next_state;
        
        // 模式切换时，重置当前状态的计时器
        if (mode_prev != current_mode) begin
            case (current_state)
                S_EW_GREEN:  timer <= (current_mode == MODE_PEAK) ? EW_GREEN_PEAK : EW_GREEN_NORMAL;
                S_EW_YELLOW: timer <= (current_mode == MODE_PEAK) ? EW_YELLOW_PEAK : EW_YELLOW_NORMAL;
                S_NS_GREEN:  timer <= (current_mode == MODE_PEAK) ? NS_GREEN_PEAK : NS_GREEN_NORMAL;
                default:     timer <= (current_mode == MODE_PEAK) ? EW_GREEN_PEAK : EW_GREEN_NORMAL;
            endcase
        end else if (timer > 6'd0) begin
            timer <= timer - 6'd1;  // 每秒减1
        end else begin
            // 状态切换时，加载下一状态的计时参数
            case (next_state)
                S_EW_GREEN:  timer <= (current_mode == MODE_PEAK) ? EW_GREEN_PEAK : EW_GREEN_NORMAL;
                S_EW_YELLOW: timer <= (current_mode == MODE_PEAK) ? EW_YELLOW_PEAK : EW_YELLOW_NORMAL;
                S_NS_GREEN:  timer <= (current_mode == MODE_PEAK) ? NS_GREEN_PEAK : NS_GREEN_NORMAL;
                default:     timer <= (current_mode == MODE_PEAK) ? EW_GREEN_PEAK : EW_GREEN_NORMAL;
            endcase
        end
    end
    // 应急/休眠模式：保持当前状态和计时器（暂停运行）
end

// 4. 次态逻辑（状态循环：S_EW_GREEN→S_EW_YELLOW→S_NS_GREEN→S_EW_GREEN）
always @(*) begin
    case (current_state)
        S_EW_GREEN: begin
            next_state = (timer == 6'd0) ? S_EW_YELLOW : S_EW_GREEN;
        end
        S_EW_YELLOW: begin
            next_state = (timer == 6'd0) ? S_NS_GREEN : S_EW_YELLOW;
        end
        S_NS_GREEN: begin
            next_state = (timer == 6'd0) ? S_EW_GREEN : S_NS_GREEN;
        end
        default: next_state = S_EW_GREEN;
    endcase
end

// 5. 灯状态输出（严格匹配实验状态表）
always @(*) begin
    case (current_state)
        S_EW_GREEN: begin
            light_ew = 3'b100;  // 东西绿灯
            light_ns = 3'b001;  // 南北红灯
        end
        S_EW_YELLOW: begin
            light_ew = 3'b010;  // 东西黄灯
            light_ns = 3'b010;  // 南北黄灯（实验特殊要求）
        end
        S_NS_GREEN: begin
            light_ew = 3'b001;  // 东西红灯
            light_ns = 3'b100;  // 南北绿灯
        end
        default: begin
            light_ew = 3'b100;
            light_ns = 3'b001;
        end
    endcase
end

// 6. 倒计时输出（同一状态下双方向计时同步）
always @(*) begin
    case (current_state)
        S_EW_GREEN: begin
            count_ew = timer;  // 东西绿灯倒计时
            count_ns = timer;  // 南北红灯倒计时（同步）
        end
        S_EW_YELLOW: begin
            count_ew = timer;  // 东西黄灯倒计时
            count_ns = timer;  // 南北黄灯倒计时（同步）
        end
        S_NS_GREEN: begin
            count_ew = timer;  // 东西红灯倒计时
            count_ns = timer;  // 南北绿灯倒计时（同步）
        end
        default: begin
            count_ew = 6'd0;
            count_ns = 6'd0;
        end
    endcase
end

endmodule