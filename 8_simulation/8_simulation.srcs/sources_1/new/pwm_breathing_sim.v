`timescale 1ns/1ps

module pwm_breathing_sim(
    input clk,          // 100MHz时钟
    input enable,       // 休眠模式使能（1=启动呼吸，0=关闭）
    output reg pwm_out  // PWM输出（控制黄灯亮度）
);

// 仿真呼吸灯参数优化：避免整数除法截断，保证渐变平滑
// 核心逻辑：暗→亮10ms（100步×100us），亮→暗10ms（100步×100us），总周期20ms
parameter PWM_PERIOD = 9999;        // PWM载波周期100us（100MHz×100us=10000时钟，0~9999）
parameter BREATH_TOTAL_STEPS = 199;  // 呼吸总步数（200步×100us=20ms）
parameter INCREASE_END = 99;        // 递增阶段结束点（0~99步=10ms，暗→亮）
// 递减阶段：100~199步=10ms（亮→暗）

// 内部计数器与寄存器
reg [16:0] pwm_cnt;     // PWM载波计数器（覆盖0~9999）
reg [10:0] breath_cnt;  // 呼吸步数计数器（覆盖0~199）
reg [16:0] duty_threshold;  // PWM占空比阈值（0~9999）

// 初始化所有寄存器
initial begin
    pwm_cnt = 17'd0;
    breath_cnt = 10'd0;
    duty_threshold = 17'd0;
    pwm_out = 1'b0;
end

// 1. PWM载波计数器（100us周期，基础载波，确保渐变平滑）
always @(posedge clk) begin
    if (enable) begin
        pwm_cnt <= (pwm_cnt >= PWM_PERIOD) ? 17'd0 : pwm_cnt + 17'd1;
    end else begin
        pwm_cnt <= 17'd0;
    end
end

// 2. 呼吸步数计数器（每1个PWM周期（100us）走1步，总200步=20ms）
always @(posedge clk) begin
    if (enable) begin
        // 每完成1个PWM周期，步数+1
        if (pwm_cnt >= PWM_PERIOD) begin
            breath_cnt <= (breath_cnt >= BREATH_TOTAL_STEPS) ? 10'd0 : breath_cnt + 10'd1;
        end
    end else begin
        breath_cnt <= 10'd0;
        duty_threshold <= 17'd0;  // 关闭时重置占空比
    end
end

// 3. 占空比阈值计算（避免整数除法截断，实现线性渐变）
always @(posedge clk) begin
    if (enable) begin
        if (breath_cnt <= INCREASE_END) begin
            // 递增阶段（0~99步=10ms）：占空比0%→100%（暗→亮）
            // 每步增量：9999 / 100 = 99.99 ≈ 100，确保每步有明显变化
            duty_threshold <= (PWM_PERIOD / (INCREASE_END + 1)) * (breath_cnt + 1);
        end else begin
            // 递减阶段（100~199步=10ms）：占空比100%→0%（亮→暗）
            duty_threshold <= (PWM_PERIOD / (INCREASE_END + 1)) * (BREATH_TOTAL_STEPS - breath_cnt + 1);
        end
    end else begin
        duty_threshold <= 17'd0;
    end
end

// 4. PWM输出（根据占空比阈值生成呼吸效果）
always @(posedge clk) begin
    if (enable) begin
        pwm_out <= (pwm_cnt < duty_threshold) ? 1'b1 : 1'b0;
    end else begin
        pwm_out <= 1'b0;
    end
end

endmodule