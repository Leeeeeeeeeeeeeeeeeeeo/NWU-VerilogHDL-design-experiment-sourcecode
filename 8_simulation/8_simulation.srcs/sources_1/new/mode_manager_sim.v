`timescale 1ns/1ps

module mode_manager_sim(
    input clk,                  // 100MHz时钟（不变）
    input rst_n,                // 低电平有效复位
    input peak_switch,          // 异步输入：向下0→正常，向上1→高峰
    input emergency_key,        // 消抖后应急按键（高=释放，低=按下）
    input sleep_key,            // 消抖后休眠按键（高=释放，低=按下）
    output reg [1:0] mode,      // 当前模式输出
    output reg core_rst_n       // 核心状态机复位（低电平有效）
);

// 模式定义（不变）
parameter MODE_NORMAL = 2'b00;   // 普通模式
parameter MODE_PEAK   = 2'b01;   // 高峰期模式  
parameter MODE_EMERG  = 2'b10;   // 应急模式
parameter MODE_SLEEP  = 2'b11;   // 休眠模式

// 内部信号（新增高峰开关边沿检测）
reg peak_sync1;
reg peak_sync2;
reg peak_sync_prev;  // 上一周期同步后高峰开关状态
wire peak_edge;      // 高峰开关边沿检测（上升沿+下降沿）

// 按键相关内部信号（不变）
reg emergency_active;
reg sleep_active;
reg emergency_key_prev;
reg sleep_key_prev;
reg emergency_active_prev;
reg sleep_active_prev;

// 1. 两拍同步逻辑（处理异步输入peak_switch，不变）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        peak_sync1 <= 1'b0;
        peak_sync2 <= 1'b0;
        peak_sync_prev <= 1'b0;
    end else begin
        peak_sync1 <= peak_switch;
        peak_sync2 <= peak_sync1;
        peak_sync_prev <= peak_sync2;  // 延迟一拍，用于边沿检测
    end
end

// 2. 高峰开关边沿检测（新增核心逻辑）
assign peak_edge = (peak_sync2 != peak_sync_prev);  // 0→1或1→0均触发

// 3. 按键下降沿检测（不变）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        emergency_key_prev <= 1'b1;
        sleep_key_prev <= 1'b1;
        emergency_active <= 1'b0;
        sleep_active <= 1'b0;
    end else begin
        emergency_key_prev <= emergency_key;
        sleep_key_prev <= sleep_key;
        
        // 应急按键下降沿（释放→按下）：切换应急状态，退出休眠
        if (emergency_key_prev == 1'b1 && emergency_key == 1'b0) begin
            emergency_active <= ~emergency_active;
            sleep_active <= 1'b0;
        end
        
        // 休眠按键下降沿（释放→按下）：切换休眠状态，退出应急
        if (sleep_key_prev == 1'b1 && sleep_key == 1'b0) begin
            sleep_active <= ~sleep_active;
            emergency_active <= 1'b0;
        end
    end
end

// 4. 模式输出（不变）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mode <= MODE_NORMAL;
    end else begin
        // 模式优先级：应急 > 休眠 > 高峰 > 正常
        if (emergency_active) begin
            mode <= MODE_EMERG;
        end else if (sleep_active) begin
            mode <= MODE_SLEEP;
        end else if (peak_sync2) begin
            mode <= MODE_PEAK;
        end else begin
            mode <= MODE_NORMAL;
        end
    end
end

// 5. 核心复位脉冲生成（修正：加入高峰切换触发+延长脉冲稳定）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        emergency_active_prev <= 1'b0;
        sleep_active_prev <= 1'b0;
        core_rst_n <= 1'b1;  // 初始复位无效
    end else begin
        emergency_active_prev <= emergency_active;
        sleep_active_prev <= sleep_active;
        
        // 触发条件：高峰切换、应急退出、休眠退出
        if (peak_edge || 
            (emergency_active_prev == 1'b1 && emergency_active == 1'b0) || 
            (sleep_active_prev == 1'b1 && sleep_active == 1'b0)) begin
            core_rst_n <= 1'b0;  // 复位有效（低电平）
        end else begin
            core_rst_n <= 1'b1;  // 复位无效（高电平）
        end
    end
end

endmodule