`timescale 1ns/1ps

module mode_manager(
    input clk,                  // 100MHz系统时钟（周期10ns）
    input rst_n,                // 低电平有效复位（来自顶层取反后）
    input peak_switch,          // 异步输入：向下拨=0（正常），向上拨=1（高峰）
    input emergency_key,        // 消抖后应急按键状态（高=释放，低=按下）
    input sleep_key,            // 消抖后休眠按键状态（高=释放，低=按下）
    output reg [1:0] mode,      // 当前模式输出
    output reg core_rst_n       // 核心状态机复位信号（低电平有效）
);

// 模式定义（与核心模块一致，无修改）
parameter MODE_NORMAL = 2'b00;   // 普通模式
parameter MODE_PEAK   = 2'b01;   // 高峰期模式  
parameter MODE_EMERG  = 2'b10;   // 应急模式
parameter MODE_SLEEP  = 2'b11;   // 休眠模式

// 核心修正1：新增两拍同步寄存器（仅同步，无消抖）
// 作用：消除异步信号亚稳态，确保采样正确
reg peak_sync1;  // 第一拍同步（暂存异步信号，消除亚稳态）
reg peak_sync2;  // 第二拍同步（稳定信号，用于模式判断）

// 原有内部信号（无修改）
reg emergency_active;  // 应急模式激活标志（1=激活）
reg sleep_active;      // 休眠模式激活标志（1=激活）
reg emergency_key_prev; // 上一周期应急按键状态（下降沿检测）
reg sleep_key_prev;    // 上一周期休眠按键状态（下降沿检测）
reg emergency_active_prev; // 上一周期应急激活标志（解除检测）
reg sleep_active_prev;    // 上一周期休眠激活标志（解除检测）

// 核心修正2：两拍同步逻辑（异步→同步，无消抖）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        peak_sync1 <= 1'b0;  // 复位初始为低（对应正常模式）
        peak_sync2 <= 1'b0;
    end else begin
        peak_sync1 <= peak_switch;  // 第一拍：采样原始异步信号
        peak_sync2 <= peak_sync1;  // 第二拍：采样稳定的同步信号（无亚稳态）
    end
end

// 1. 按键下降沿检测（无修改，保持原有功能）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        emergency_key_prev <= 1'b1;
        sleep_key_prev <= 1'b1;
        emergency_active <= 1'b0;  // 初始未激活应急模式
        sleep_active <= 1'b0;      // 初始未激活休眠模式
    end else begin
        emergency_key_prev <= emergency_key;
        sleep_key_prev <= sleep_key;
        
        // 应急按键按下（下降沿）：切换应急模式，关闭休眠
        if (emergency_key_prev == 1'b1 && emergency_key == 1'b0) begin
            emergency_active <= ~emergency_active;
            sleep_active <= 1'b0;
        end
        
        // 休眠按键按下（下降沿）：切换休眠模式，关闭应急
        if (sleep_key_prev == 1'b1 && sleep_key == 1'b0) begin
            sleep_active <= ~sleep_active;
            emergency_active <= 1'b0;
        end
    end
end

// 2. 模式输出（核心修正3：用同步后的peak_sync2判断高峰模式）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mode <= MODE_NORMAL;  // 复位初始为正常模式（符合预期）
    end else begin
        // 模式优先级：应急模式 > 休眠模式 > 高峰模式 > 正常模式（无修改）
        if (emergency_active) begin
            mode <= MODE_EMERG;
        end else if (sleep_active) begin
            mode <= MODE_SLEEP;
        end else if (peak_sync2) begin  // 用同步后的信号判断（无亚稳态）
            mode <= MODE_PEAK;         // 同步后为1→高峰模式（向上拨）
        end else begin
            mode <= MODE_NORMAL;       // 同步后为0→正常模式（向下拨）
        end
    end
end

// 3. 核心复位脉冲生成（无修改，保持原有功能）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        emergency_active_prev <= 1'b0;
        sleep_active_prev <= 1'b0;
        core_rst_n <= 1'b1;  // 初始不复位核心状态机
    end else begin
        emergency_active_prev <= emergency_active;
        sleep_active_prev <= sleep_active;
        
        // 应急/休眠模式解除时，复位核心状态机（重新开始计时）
        if ((emergency_active_prev == 1'b1 && emergency_active == 1'b0) || 
            (sleep_active_prev == 1'b1 && sleep_active == 1'b0)) begin
            core_rst_n <= 1'b0;  // 低电平复位
        end else begin
            core_rst_n <= 1'b1;  // 正常工作
        end
    end
end

endmodule