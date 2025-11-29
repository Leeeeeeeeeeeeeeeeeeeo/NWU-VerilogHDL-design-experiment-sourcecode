module mode_manager(
    input clk,
    input rst_n,
    input peak_switch,      // 高峰期模式开关（SW5：拨上=1，拨下=0）
    input emergency_key,    // 消抖后应急按键状态（高=释放，低=按下）
    input sleep_key,        // 消抖后休眠按键状态（高=释放，低=按下）
    output reg [1:0] mode,  // 当前模式输出
    output reg core_rst_n   // 核心状态机复位信号（低电平有效，解除应急/休眠时触发）
);

// 模式定义（与核心模块一致）
parameter MODE_NORMAL = 2'b00;   // 普通模式
parameter MODE_PEAK   = 2'b01;   // 高峰期模式  
parameter MODE_EMERG  = 2'b10;   // 应急模式
parameter MODE_SLEEP  = 2'b11;   // 休眠模式

// 内部信号
reg emergency_active;  // 应急模式激活标志（1=激活）
reg sleep_active;      // 休眠模式激活标志（1=激活）
reg emergency_key_prev; // 上一周期应急按键状态（用于下降沿检测）
reg sleep_key_prev;    // 上一周期休眠按键状态（用于下降沿检测）
reg emergency_active_prev; // 上一周期应急激活标志（用于检测解除）
reg sleep_active_prev;    // 上一周期休眠激活标志（用于检测解除）

// 1. 按键下降沿检测（捕捉“按下”动作）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        emergency_key_prev <= 1'b1;
        sleep_key_prev <= 1'b1;
        emergency_active <= 1'b0;
        sleep_active <= 1'b0;
    end else begin
        // 保存上一周期按键状态
        emergency_key_prev <= emergency_key;
        sleep_key_prev <= sleep_key;
        
        // 应急按键：按下→Toggle激活状态，同时关闭休眠
        if (emergency_key_prev == 1'b1 && emergency_key == 1'b0) begin
            emergency_active <= ~emergency_active;
            sleep_active <= 1'b0;
        end
        
        // 休眠按键：按下→Toggle激活状态，同时关闭应急
        if (sleep_key_prev == 1'b1 && sleep_key == 1'b0) begin
            sleep_active <= ~sleep_active;
            emergency_active <= 1'b0;
        end
    end
end

// 2. 模式输出（优先级：应急＞休眠＞高峰＞正常）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mode <= MODE_NORMAL;
    end else begin
        if (emergency_active) begin
            mode <= MODE_EMERG;
        end else if (sleep_active) begin
            mode <= MODE_SLEEP;
        end else if (peak_switch) begin
            mode <= MODE_PEAK;
        end else begin
            mode <= MODE_NORMAL;
        end
    end
end

// 3. 核心复位脉冲生成（应急/休眠解除时，产生1拍低电平复位）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        emergency_active_prev <= 1'b0;
        sleep_active_prev <= 1'b0;
        core_rst_n <= 1'b1;  // 初始不复位
    end else begin
        // 保存上一周期激活标志
        emergency_active_prev <= emergency_active;
        sleep_active_prev <= sleep_active;
        
        // 检测“应急解除”或“休眠解除”（1→0跳变）
        if ((emergency_active_prev == 1'b1 && emergency_active == 1'b0) || 
            (sleep_active_prev == 1'b1 && sleep_active == 1'b0)) begin
            core_rst_n <= 1'b0;  // 拉低1拍复位
        end else begin
            core_rst_n <= 1'b1;  // 其余时间高电平
        end
    end
end

endmodule