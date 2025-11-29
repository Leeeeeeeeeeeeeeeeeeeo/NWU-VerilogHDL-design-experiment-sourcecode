module traffic_light_core_sim(
    input clk,              // 100MHz系统时钟
    input rst_n,            // 异步复位（低电平有效）
    input core_rst_n,       // 核心复位信号（低电平有效）
    input [1:0] current_mode,  // 当前模式（正常/高峰/应急/休眠）
    output reg [2:0] light_ew,  // 东西方向灯：[绿,黄,红]
    output reg [2:0] light_ns,  // 南北方向灯：[绿,黄,红]
    output reg [5:0] count_ew,  // 东西方向倒计时（仿真ms）
    output reg [5:0] count_ns   // 南北方向倒计时（仿真ms）
);

// 状态定义（逻辑不变）
parameter S_EW_GREEN  = 2'b00;  // 状态1：东西绿，南北红
parameter S_EW_YELLOW = 2'b01;  // 状态2：东西黄，南北黄
parameter S_NS_GREEN  = 2'b10;  // 状态3：东西红，南北绿

// 模式定义（逻辑不变）
parameter MODE_NORMAL = 2'b00;
parameter MODE_PEAK   = 2'b01;

// 仿真专用计时参数（数值不变，单位改为“仿真ms”，对应真实秒）
parameter EW_GREEN_NORMAL  = 20;  // 仿真20ms → 真实20秒
parameter EW_YELLOW_NORMAL = 5;   // 仿真5ms → 真实5秒
parameter NS_GREEN_NORMAL  = 15;  // 仿真15ms → 真实15秒
parameter EW_GREEN_PEAK    = 25;  // 仿真25ms → 真实25秒
parameter EW_YELLOW_PEAK   = 3;   // 仿真3ms → 真实3秒
parameter NS_GREEN_PEAK    = 10;  // 仿真10ms → 真实10秒

// 内部信号（逻辑不变）
reg [1:0] current_state, next_state;
reg [5:0] timer;          // 状态持续计时器（仿真ms）
reg [25:0] clk_div;       // 1000Hz分频计数器（100MHz→1000Hz）
reg clk_1khz;             // 1000Hz时钟（仿真ms级计时触发）
reg [1:0] mode_prev;      // 上一周期模式（检测模式切换）

// 1. 100MHz→1000Hz分频逻辑（仿真专用：1ms周期，对应真实1秒）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_div <= 26'd0;
        clk_1khz <= 1'b0;
    end else if (clk_div == 26'd49_999) begin  // 100MHz/(2×1000) -1 = 49999
        clk_div <= 26'd0;
        clk_1khz <= ~clk_1khz;  // 0.5ms翻转一次，1ms周期
    end else begin
        clk_div <= clk_div + 26'd1;
    end
end

// 2. 模式变化检测（逻辑不变）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mode_prev <= MODE_NORMAL;
    end else begin
        mode_prev <= current_mode;
    end
end

// 3. 状态寄存器+计时器逻辑（仅时钟改为clk_1khz，其余不变）
always @(posedge clk_1khz or negedge rst_n or negedge core_rst_n) begin
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
            timer <= timer - 6'd1;  // 每1ms减1（对应真实每秒减1）
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

// 4. 次态逻辑（逻辑不变）
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

// 5. 灯状态输出（逻辑不变）
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

// 6. 倒计时输出（逻辑不变）
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