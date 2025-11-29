module traffic_light_system(
    input clk_100m,         // 100MHz系统时钟
    input rst_n,            // 异步复位
    input peak_switch,      // 高峰期模式开关(SW5)
    input emergency_btn,    // 应急模式按钮(BTNC)
    input sleep_btn,        // 休眠模式按钮(BTNU)
    output [2:0] light_ew,  // 东西方向灯 [绿,黄,红] - LD10,LD9,LD8
    output [2:0] light_ns,  // 南北方向灯 [绿,黄,红] - LD7,LD6,LD5
    // 新的数码管接口
    output CA, CB, CC, CD, CE, CF, CG,  // 七段数码管段选信号
    output dp,               // 小数点
    output AN0, AN1, AN2, AN3 // 数码管位选信号
);

    wire [1:0] current_mode;
    wire [5:0] count_ew, count_ns;
    wire pwm_signal;
    wire [2:0] base_light_ew, base_light_ns;
    
    // 实例化模式管理模块
    mode_manager u_mode_manager(
        .clk(clk_100m),
        .rst_n(rst_n),
        .peak_switch(peak_switch),
        .emergency_btn(emergency_btn),
        .sleep_btn(sleep_btn),
        .mode(current_mode)
    );
    
    // 实例化PWM呼吸灯模块
    pwm_breathing u_pwm_breathing(
        .clk(clk_100m),
        .rst_n(rst_n),
        .enable(current_mode == 2'b11), // 仅在休眠模式使能
        .pwm_out(pwm_signal)
    );
    
    // 实例化交通灯核心模块
    traffic_light_core u_traffic_light_core(
        .clk(clk_100m),
        .rst_n(rst_n),
        .peak_switch(peak_switch),
        .light_ew(base_light_ew),
        .light_ns(base_light_ns),
        .count_ew(count_ew),
        .count_ns(count_ns)
    );
    
    // 实例化显示控制模块（新接口）
    display_controller u_display_controller(
        .clk_100m(clk_100m),
        .rst_n(rst_n),
        .mode(current_mode),
        .count_ew(count_ew),
        .count_ns(count_ns),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .dp(dp),
        .AN0(AN0),
        .AN1(AN1),
        .AN2(AN2),
        .AN3(AN3)
    );
    
    // 最终灯输出 - 处理休眠模式的呼吸灯效果
    assign light_ew = (current_mode == 2'b11) ? {1'b0, pwm_signal, 1'b0} : base_light_ew;
    assign light_ns = (current_mode == 2'b11) ? {1'b0, pwm_signal, 1'b0} : base_light_ns;

endmodule