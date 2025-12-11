`timescale 1ns/1ps

module mode_manager_sim(
    input clk,                  // 100MHz时钟
    input peak_switch,          // 高峰开关(SW5)：上端=1→高峰，下端=0→正常
    input emergency_key,        // 消抖后应急按键（低=未按，高=按下）
    input sleep_key,            // 消抖后休眠按键（低=未按，高=按下）
    output reg [1:0] mode,      // 当前模式输出
    output reg core_rst_n       // 核心状态机复位（低电平有效）
);

// 模式定义
parameter MODE_NORMAL = 2'b00;   // 普通模式
parameter MODE_PEAK   = 2'b01;   // 高峰期模式  
parameter MODE_EMERG  = 2'b10;   // 应急模式
parameter MODE_SLEEP  = 2'b11;   // 休眠模式

// 内部信号：高峰开关边沿检测
reg peak_sync1;
reg peak_sync2;
reg peak_sync_prev;
wire peak_edge;

// 按键相关内部信号（仅记录当前激活的特殊模式，互斥）
reg emergency_active;  // 1=应急模式激活，0=未激活
reg sleep_active;      // 1=休眠模式激活，0=未激活
reg emergency_key_prev;  // 上一周期应急按键状态
reg sleep_key_prev;      // 上一周期休眠按键状态
reg emergency_active_prev;
reg sleep_active_prev;

// 初始化所有寄存器
initial begin
    peak_sync1 = 1'b0;
    peak_sync2 = 1'b0;
    peak_sync_prev = 1'b0;
    emergency_key_prev = 1'b0;
    sleep_key_prev = 1'b0;
    emergency_active = 1'b0;  // 初始无特殊模式激活
    sleep_active = 1'b0;
    emergency_active_prev = 1'b0;
    sleep_active_prev = 1'b0;
    mode = MODE_NORMAL;       // 初始正常模式
    core_rst_n = 1'b1;        // 初始复位无效
end

// 1. 两拍同步（处理异步输入peak_switch）
always @(posedge clk) begin
    peak_sync1 <= peak_switch;
    peak_sync2 <= peak_sync1;
    peak_sync_prev <= peak_sync2;
end

// 2. 高峰开关边沿检测（模式切换时复位核心状态机）
assign peak_edge = (peak_sync2 != peak_sync_prev);

// 3. 按键上升沿检测（纯互斥切换，无固定优先级）
always @(posedge clk) begin
    emergency_key_prev <= emergency_key;
    sleep_key_prev <= sleep_key;
    
    // -------------- 应急按键（BTNC）逻辑 --------------
    if (emergency_key_prev == 1'b0 && emergency_key == 1'b1) begin
        if (sleep_active == 1'b1) begin
            sleep_active <= 1'b0;    // 退出休眠
            emergency_active <= 1'b1; // 进入应急
        end else begin
            emergency_active <= ~emergency_active; // 切换应急状态
        end
    end
    
    // -------------- 休眠按键（BTNU）逻辑 --------------
    if (sleep_key_prev == 1'b0 && sleep_key == 1'b1) begin
        if (emergency_active == 1'b1) begin
            emergency_active <= 1'b0;  // 退出应急
            sleep_active <= 1'b1;     // 进入休眠
        end else begin
            sleep_active <= ~sleep_active; // 切换休眠状态
        end
    end
end

// 4. 模式输出（纯互斥，特殊模式优先，正常/高峰兜底）
always @(posedge clk) begin
    if (emergency_active) begin
        mode <= MODE_EMERG;  // 应急激活→输出应急模式
    end else if (sleep_active) begin
        mode <= MODE_SLEEP;  // 休眠激活→输出休眠模式
    end else if (peak_sync2) begin
        mode <= MODE_PEAK;   // 无特殊模式→高峰模式
    end else begin
        mode <= MODE_NORMAL; // 无特殊模式→正常模式
    end
end

// 5. 核心复位脉冲生成（模式切换时复位状态机）
always @(posedge clk) begin
    emergency_active_prev <= emergency_active;
    sleep_active_prev <= sleep_active;
    
    // 触发复位条件：特殊模式切换、高峰模式切换
    if (peak_edge || 
        (emergency_active_prev != emergency_active) || 
        (sleep_active_prev != sleep_active)) begin
        core_rst_n <= 1'b0;  // 复位有效（低电平，持续1周期）
    end else begin
        core_rst_n <= 1'b1;
    end
end

endmodule