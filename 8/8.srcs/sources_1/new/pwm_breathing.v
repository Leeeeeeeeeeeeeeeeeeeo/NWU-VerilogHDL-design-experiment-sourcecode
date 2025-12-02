module pwm_breathing(
    input clk,              // 100MHz系统时钟
    input rst_n,            // 异步复位
    input enable,           // 呼吸灯使能（休眠模式=1）
    output reg pwm_out      // PWM输出（驱动黄灯呼吸）
);

// 现实时间参数
parameter PWM_PERIOD = 10'd1000;     // PWM周期=10us（100MHz×10us=1000个周期）
parameter BREATHE_CYCLE = 28'd100_000_000; // 呼吸周期=1秒（100MHz×1秒=1e8个周期）

// 内部信号
reg [9:0] pwm_counter;               // PWM周期计数器（0~999）
reg [27:0] breathe_counter;          // 呼吸周期计数器（0~99,999,999）
reg breathe_direction;               // 呼吸方向：0=渐亮，1=渐暗
reg [9:0] pwm_duty_cycle;            // 当前PWM占空比（0~999）

// 1. 呼吸周期计数器（控制渐亮/渐暗切换）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        breathe_counter <= 0;
        breathe_direction <= 0;
    end else if (enable) begin
        if (breathe_counter < BREATHE_CYCLE - 1) begin
            breathe_counter <= breathe_counter + 1;
        end else begin
            breathe_counter <= 0;
            breathe_direction <= ~breathe_direction; // 1秒切换一次方向
        end
    end else begin
        breathe_counter <= 0;
        breathe_direction <= 0;
    end
end

// 2. 占空比计算（三角波变化：0%→100%→0%）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_duty_cycle <= 0;
    end else if (enable) begin
        if (breathe_direction == 0) begin
            // 渐亮：占空比从0→100%
            pwm_duty_cycle <= (breathe_counter * PWM_PERIOD) / BREATHE_CYCLE;
        end else begin
            // 渐暗：占空比从100%→0
            pwm_duty_cycle <= PWM_PERIOD - ((breathe_counter * PWM_PERIOD) / BREATHE_CYCLE);
        end
    end else begin
        pwm_duty_cycle <= 0;
    end
end

// 3. PWM周期计数器
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_counter <= 0;
    end else begin
        if (pwm_counter < PWM_PERIOD - 1) begin
            pwm_counter <= pwm_counter + 1;
        end else begin
            pwm_counter <= 0;
        end
    end
end

// 4. PWM输出（占空比控制亮度）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_out <= 0;
    end else if (enable) begin
        pwm_out <= (pwm_counter < pwm_duty_cycle);
    end else begin
        pwm_out <= 0;
    end
end

endmodule