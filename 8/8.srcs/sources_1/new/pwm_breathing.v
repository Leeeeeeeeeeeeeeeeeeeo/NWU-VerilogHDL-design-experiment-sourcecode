`timescale 1ns/1ps

module pwm_breathing(
    input clk,          // 100MHz时钟
    input enable,       // 休眠模式使能（1=启动呼吸，0=关闭）
    output reg pwm_out  // PWM输出（控制黄灯亮度）
);

// 硬件参数：“暗→亮1秒、亮→暗1秒”
parameter PWM_PERIOD = 99_999;    // PWM载波周期1ms（100MHz×1ms=100000个时钟，0~99999）
parameter BREATH_TOTAL_STEPS = 1999;  // 呼吸总步数（2000步×1ms=2秒）
parameter INCREASE_END = 999;     // 递增阶段结束点（0~999步=1秒，暗→亮）
// 递减阶段：1000~1999步=1秒（亮→暗）

// 内部计数器与寄存器
reg [16:0] pwm_cnt;     // PWM载波计数器（17位覆盖0~99999）
reg [10:0] breath_cnt;  // 呼吸步数计数器（11位覆盖0~1999）
reg [16:0] duty_threshold;  // PWM占空比阈值（0~99999）

// 初始化所有寄存器
initial begin
    pwm_cnt = 17'd0;
    breath_cnt = 10'd0;
    duty_threshold = 17'd0;
    pwm_out = 1'b0;
end

// 1. PWM载波计数器（1ms周期，基础载波）
always @(posedge clk) begin
    if (enable) begin
        pwm_cnt <= (pwm_cnt >= PWM_PERIOD) ? 17'd0 : pwm_cnt + 17'd1;
    end else begin
        pwm_cnt <= 17'd0;
    end
end

// 2. 呼吸步数计数器（每1ms走1步，总2000步=2秒）
always @(posedge clk) begin
    if (enable) begin
        // 每完成1个PWM周期（1ms），步数+1
        if (pwm_cnt >= PWM_PERIOD) begin
            breath_cnt <= (breath_cnt >= BREATH_TOTAL_STEPS) ? 10'd0 : breath_cnt + 10'd1;
        end
    end else begin
        // 关闭呼吸时，计数器清零
        breath_cnt <= 10'd0;
    end
end

// 3. 占空比阈值计算（控制1秒递增、1秒递减）
always @(posedge clk) begin
    if (enable) begin
        if (breath_cnt <= INCREASE_END) begin
            // 递增阶段（0~999步=1秒）：占空比0%→100%（暗→亮）
            // 每步占空比增加：99999 / 1000 = 99.999 ≈ 100
            duty_threshold <= (PWM_PERIOD / (INCREASE_END + 1)) * (breath_cnt + 1);
        end else begin
            // 递减阶段（1000~1999步=1秒）：占空比100%→0%（亮→暗）
            duty_threshold <= (PWM_PERIOD / (INCREASE_END + 1)) * (BREATH_TOTAL_STEPS - breath_cnt + 1);
        end
    end else begin
        // 关闭呼吸时，占空比清零
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