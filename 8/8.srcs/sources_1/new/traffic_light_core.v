module traffic_light_core(
    input clk,              // 系统时钟
    input rst_n,            // 异步复位
    input peak_switch,      // 高峰期模式开关
    output reg [2:0] light_ew,  // 东西方向灯 [绿,黄,红]
    output reg [2:0] light_ns,  // 南北方向灯 [绿,黄,红]
    output reg [5:0] count_ew,  // 东西方向倒计时
    output reg [5:0] count_ns   // 南北方向倒计时
);

    // 状态定义 - 严格按照实验要求的三个状态
    parameter S_EW_GREEN  = 2'b00;  // 东西绿灯，南北红灯
    parameter S_EW_YELLOW = 2'b01;  // 东西黄灯，南北黄灯  
    parameter S_NS_GREEN  = 2'b10;  // 东西红灯，南北绿灯
    
    // 普通模式计时参数
    parameter EW_GREEN_NORMAL  = 20;  // 东西绿灯20秒
    parameter EW_YELLOW_NORMAL = 5;   // 黄灯5秒
    parameter NS_GREEN_NORMAL  = 15;  // 南北绿灯15秒
    
    // 高峰期模式计时参数  
    parameter EW_GREEN_PEAK    = 25;  // 东西绿灯25秒
    parameter EW_YELLOW_PEAK   = 3;   // 黄灯3秒
    parameter NS_GREEN_PEAK    = 10;  // 南北绿灯10秒

    reg [1:0] current_state, next_state;
    reg [5:0] timer;  // 状态计时器
    
    // 状态寄存器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S_EW_GREEN;
            timer <= EW_GREEN_NORMAL;
        end else begin
            current_state <= next_state;
            
            // 计时器逻辑
            if (timer > 0) begin
                timer <= timer - 1;
            end else begin
                // 状态转换时加载新的计时值
                case (next_state)
                    S_EW_GREEN:  timer <= peak_switch ? EW_GREEN_PEAK : EW_GREEN_NORMAL;
                    S_EW_YELLOW: timer <= peak_switch ? EW_YELLOW_PEAK : EW_YELLOW_NORMAL;
                    S_NS_GREEN:  timer <= peak_switch ? NS_GREEN_PEAK : NS_GREEN_NORMAL;
                    default:     timer <= EW_GREEN_NORMAL;
                endcase
            end
        end
    end
    
    // 次态逻辑
    always @(*) begin
        case (current_state)
            S_EW_GREEN: begin
                if (timer == 0) 
                    next_state = S_EW_YELLOW;
                else
                    next_state = S_EW_GREEN;
            end
            S_EW_YELLOW: begin
                if (timer == 0) 
                    next_state = S_NS_GREEN;
                else
                    next_state = S_EW_YELLOW;
            end
            S_NS_GREEN: begin
                if (timer == 0) 
                    next_state = S_EW_GREEN;
                else
                    next_state = S_NS_GREEN;
            end
            default: next_state = S_EW_GREEN;
        endcase
    end
    
    // 输出逻辑 - 灯状态
    always @(*) begin
        case (current_state)
            S_EW_GREEN: begin
                light_ew = 3'b100;  // 东西绿灯
                light_ns = 3'b001;  // 南北红灯
            end
            S_EW_YELLOW: begin
                light_ew = 3'b010;  // 东西黄灯
                light_ns = 3'b010;  // 南北黄灯
            end
            S_NS_GREEN: begin
                light_ew = 3'b001;  // 东西红灯
                light_ns = 3'b100;  // 南北绿灯
            end
            default: begin
                light_ew = 3'b100;  // 默认东西绿灯
                light_ns = 3'b001;  // 默认南北红灯
            end
        endcase
    end
    
    // 输出逻辑 - 倒计时显示
    always @(*) begin
        case (current_state)
            S_EW_GREEN: begin
                count_ew = timer;  // 东西绿灯倒计时
                count_ns = timer + (peak_switch ? EW_YELLOW_PEAK : EW_YELLOW_NORMAL) + 
                           (peak_switch ? NS_GREEN_PEAK : NS_GREEN_NORMAL);  // 南北红灯总时间
            end
            S_EW_YELLOW: begin
                count_ew = timer;  // 东西黄灯倒计时
                count_ns = timer;  // 南北黄灯倒计时
            end
            S_NS_GREEN: begin
                count_ew = timer + (peak_switch ? EW_YELLOW_PEAK : EW_YELLOW_NORMAL) + 
                           (peak_switch ? EW_GREEN_PEAK : EW_GREEN_NORMAL);  // 东西红灯总时间
                count_ns = timer;  // 南北绿灯倒计时
            end
            default: begin
                count_ew = timer;
                count_ns = timer;
            end
        endcase
    end

endmodule