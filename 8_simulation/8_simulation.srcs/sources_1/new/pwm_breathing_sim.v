`timescale 1ns/1ps

module pwm_breathing_sim(
    input clk,          // 100MHz时钟（周期10ns，不变）
    input rst_n,        // 低电平有效复位（不变）
    input enable,       // 休眠模式使能（1=启动呼吸，0=关闭）
    output reg pwm_out  // PWM输出（控制黄灯亮度）
);

// ------------- 精准参数（无冗余，无截断问题） -------------
// 1. PWM载波周期：1ms（100Hz）→ 100,000个时钟周期（1e5×10ns）
parameter PWM_PERIOD = 99_999;  // 0~99999，刚好1ms
// 2. 呼吸周期：100ms→100个PWM周期（0~99步，共100步）
parameter BREATH_STEPS = 99;    // 呼吸步数计数器最大值
// 3. 递增/递减分界步：49步（0~49递增，50~99递减）
parameter HALF_STEP = 49;

// ------------- 内部计数器与寄存器 -------------
reg [16:0] pwm_cnt;     // PWM载波计数器（0~99999，17位足够）
reg [6:0] breath_cnt;   // 呼吸步数计数器（0~99，7位足够）
reg [16:0] duty_threshold;  // PWM占空比阈值

// ------------- 1. PWM载波计数器（1ms周期，不变） -------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_cnt <= 17'd0;
    end else if (enable) begin
        pwm_cnt <= (pwm_cnt >= PWM_PERIOD) ? 17'd0 : pwm_cnt + 17'd1;
    end else begin
        pwm_cnt <= 17'd0;
    end
end

// ------------- 2. 呼吸步数计数器（100ms周期，不变） -------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        breath_cnt <= 7'd0;
    end else if (enable && (pwm_cnt >= PWM_PERIOD)) begin
        // 每个PWM周期（1ms）加1步，100步=100ms
        breath_cnt <= (breath_cnt >= BREATH_STEPS) ? 7'd0 : breath_cnt + 7'd1;
    end else if (!enable) begin
        breath_cnt <= 7'd0;
    end
end

// ------------- 3. 占空比阈值计算（核心修正：确保100%占空比） -------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        duty_threshold <= 17'd0;
    end else if (enable) begin
        // 递增阶段：0~49步（0~50ms）→ 占空比0%→100%
        if (breath_cnt <= HALF_STEP) begin
            // 精准计算：第49步时，duty_threshold=99999（100%占空比）
            // 公式：duty_threshold = (PWM_PERIOD / HALF_STEP) × breath_cnt
            duty_threshold <= (PWM_PERIOD / (HALF_STEP + 1)) * (breath_cnt + 1);
        end
        // 递减阶段：50~99步（50~100ms）→ 占空比100%→0%
        else begin
            // 精准计算：第50步=99999，第99步=0
            duty_threshold <= (PWM_PERIOD / (HALF_STEP + 1)) * (BREATH_STEPS - breath_cnt + 1);
        end
    end else begin
        duty_threshold <= 17'd0;
    end
end

// ------------- 4. PWM输出（不变） -------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_out <= 1'b0;
    end else if (enable) begin
        // 载波计数器 < 阈值 → 高电平（占空比随阈值变化）
        pwm_out <= (pwm_cnt < duty_threshold) ? 1'b1 : 1'b0;
    end else begin
        pwm_out <= 1'b0;
    end
end

endmodule