module pwm_breathing(
    input clk,              // 100MHz系统时钟
    input rst_n,            // 异步复位
    input enable,           // 呼吸灯使能
    output reg pwm_out      // PWM输出信号
);

    // 呼吸灯参数 - 基于100MHz时钟调整
    parameter PWM_PERIOD = 10'd1000;     // PWM周期 = 1000时钟周期 = 10us
    parameter BREATHE_CYCLE = 28'd100_000_000; // 呼吸周期1秒（100MHz时钟）
    
    reg [9:0] pwm_counter;               // PWM周期计数器
    reg [27:0] breathe_counter;          // 呼吸周期计数器
    reg breathe_direction;               // 呼吸方向：0=渐亮，1=渐暗
    reg [9:0] pwm_duty_cycle;            // 当前PWM占空比
    
    // 呼吸周期计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            breathe_counter <= 0;
            breathe_direction <= 0;
        end else if (enable) begin
            if (breathe_counter < BREATHE_CYCLE - 1) begin
                breathe_counter <= breathe_counter + 1;
            end else begin
                breathe_counter <= 0;
                breathe_direction <= ~breathe_direction; // 切换呼吸方向
            end
        end else begin
            breathe_counter <= 0;
            breathe_direction <= 0;
        end
    end
    
    // 计算PWM占空比（三角波）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_duty_cycle <= 0;
        end else if (enable) begin
            if (breathe_direction == 0) begin
                // 渐亮：占空比从0%到100%
                pwm_duty_cycle <= (breathe_counter * PWM_PERIOD) / BREATHE_CYCLE;
            end else begin
                // 渐暗：占空比从100%到0%
                pwm_duty_cycle <= PWM_PERIOD - ((breathe_counter * PWM_PERIOD) / BREATHE_CYCLE);
            end
        end else begin
            pwm_duty_cycle <= 0;
        end
    end
    
    // PWM计数器
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
    
    // PWM输出
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