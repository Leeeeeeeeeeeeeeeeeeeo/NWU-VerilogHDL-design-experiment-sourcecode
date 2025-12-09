`timescale 1ns/1ps

module pwm_breathing(
    input clk,          // 100MHz时钟（现实时间）
    input rst_n,        // 低电平有效复位
    input enable,       // 休眠模式使能（1=启动呼吸，0=关闭）
    output reg pwm_out  // PWM输出（控制黄灯亮度，文档要求1s渐变）
);

// 现实时间参数（符合文档：1s亮暗渐变，呼吸周期2s）
parameter PWM_PERIOD = 99999;    // PWM载波周期1ms（100Hz，100MHz×1ms=1e5周期）
parameter BREATH_STEPS = 1999;   // 呼吸步数：1ms×2000步=2s（亮→暗1s，暗→亮1s）
parameter HALF_STEP = 999;       // 递增/递减分界：前1000步递增，后1000步递减

// 内部计数器与寄存器
reg [16:0] pwm_cnt;     // PWM载波计数器（0~99999，17位足够）
reg [10:0] breath_cnt;  // 呼吸步数计数器（0~1999，11位足够）
reg [16:0] duty_threshold;  // PWM占空比阈值

// 1. PWM载波计数器（1ms周期，不变）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_cnt <= 17'd0;
    end else if (enable) begin
        pwm_cnt <= (pwm_cnt >= PWM_PERIOD) ? 17'd0 : pwm_cnt + 17'd1;
    end else begin
        pwm_cnt <= 17'd0;
    end
end

// 2. 呼吸步数计数器（2s周期，符合文档1s渐变）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        breath_cnt <= 11'd0;
    end else if (enable && (pwm_cnt >= PWM_PERIOD)) begin
        breath_cnt <= (breath_cnt >= BREATH_STEPS) ? 11'd0 : breath_cnt + 11'd1;
    end else if (!enable) begin
        breath_cnt <= 11'd0;
    end
end

// 3. 占空比阈值计算（精准渐变，无跳变）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        duty_threshold <= 17'd0;
    end else if (enable) begin
        // 递增阶段：0~999步（0~1s）→ 占空比0%→100%
        if (breath_cnt <= HALF_STEP) begin
            duty_threshold <= (PWM_PERIOD / (HALF_STEP + 1)) * (breath_cnt + 1);
        end
        // 递减阶段：1000~1999步（1~2s）→ 占空比100%→0%
        else begin
            duty_threshold <= (PWM_PERIOD / (HALF_STEP + 1)) * (BREATH_STEPS - breath_cnt + 1);
        end
    end else begin
        duty_threshold <= 17'd0;
    end
end

// 4. PWM输出
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_out <= 1'b0;
    end else if (enable) begin
        pwm_out <= (pwm_cnt < duty_threshold) ? 1'b1 : 1'b0;
    end else begin
        pwm_out <= 1'b0;
    end
end

endmodule