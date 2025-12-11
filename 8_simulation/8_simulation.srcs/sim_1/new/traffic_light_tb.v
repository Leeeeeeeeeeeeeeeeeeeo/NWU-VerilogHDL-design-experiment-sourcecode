`timescale 1ns/1ps

module traffic_light_system_tb;

// --------------- 激励信号定义（输入顶层模块）---------------
reg clk_100m;         // 100MHz系统时钟
reg peak_switch;      // 高峰模式开关（SW5）
reg BTNC;             // 应急按键
reg BTNU;             // 休眠按键

// --------------- 观察信号定义（输出顶层模块）---------------
wire [5:0] led_out;   // LED输出（LD10~LD5）
wire CA, CB, CC, CD, CE, CF, CG;  // 数码管段选
wire dp;              // 数码管小数点
wire AN0, AN1, AN2, AN3;  // 数码管位选

// --------------- 内部关键信号（层次化引用，便于观察）---------------
wire [1:0] current_mode;       // 当前模式（正常/高峰/应急/休眠）
wire [5:0] count_ew, count_ns; // 东西/南北倒计时
wire pwm_signal;               // 呼吸灯PWM信号
wire [2:0] base_light_ew, base_light_ns; // 核心灯状态
wire [1:0] key_state;          // 消抖后按键状态
wire core_rst_n;               // 核心状态机复位

// --------------- 实例化仿真版顶层模块 ---------------
traffic_light_system_sim u_traffic_light_system_sim(
    .clk_100m(clk_100m),
    .peak_switch(peak_switch),
    .BTNC(BTNC),
    .BTNU(BTNU),
    .led_out(led_out),
    .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG),
    .dp(dp),
    .AN0(AN0), .AN1(AN1), .AN2(AN2), .AN3(AN3)
);

// --------------- 层次化引用内部信号（无需修改顶层模块，直接观察）---------------
assign current_mode = u_traffic_light_system_sim.current_mode;
assign count_ew = u_traffic_light_system_sim.count_ew;
assign count_ns = u_traffic_light_system_sim.count_ns;
assign pwm_signal = u_traffic_light_system_sim.pwm_signal;
assign base_light_ew = u_traffic_light_system_sim.base_light_ew;
assign base_light_ns = u_traffic_light_system_sim.base_light_ns;
assign key_state = u_traffic_light_system_sim.key_state;
assign core_rst_n = u_traffic_light_system_sim.core_rst_n;

// --------------- 生成100MHz时钟（周期10ns）---------------
initial begin
    clk_100m = 1'b0;
    forever #5 clk_100m = ~clk_100m; // 5ns高电平+5ns低电平=10ns周期
end

// --------------- 激励信号时序生成（应急/休眠时长延长一倍）---------------
initial begin
    // 初始化所有激励信号（默认状态）
    peak_switch = 1'b0;  // 初始正常模式
    BTNC = 1'b0;         // 应急按键未按
    BTNU = 1'b0;         // 休眠按键未按

    // ====================================== 阶段1：正常模式（0~50ms）
    #0;  // 启动时保持默认状态
    #50_000_000;  // 运行50ms（1个完整周期40ms+额外10ms）

    // ====================================== 阶段2：高峰模式（50~98ms）
    peak_switch = 1'b1;  // 50ms时切换到高峰模式
    #48_000_000;  // 运行48ms（1个完整周期38ms+额外10ms）

    // ====================================== 阶段3：切回正常模式（98~108ms）
    peak_switch = 1'b0;  // 98ms时切回正常模式
    #10_000_000;  // 运行10ms（较短时间过渡）

    // ====================================== 阶段4：进入应急模式（108~129ms）- 延长至20ms
    BTNC = 1'b1;  // 108ms时按下应急按键
    #1_000_000;   // 按键持续1ms（远超20us消抖时间）
    BTNC = 1'b0;  // 109ms时释放按键
    #20_000_000;  // 应急模式保持20ms（原10ms，延长一倍）

    // ====================================== 阶段5：退出应急模式（129~139ms）
    BTNC = 1'b1;  // 129ms时再次按下应急按键（退出）
    #1_000_000;   // 按键持续1ms
    BTNC = 1'b0;  // 130ms时释放按键
    #9_000_000;   // 恢复正常模式运行9ms（较短时间过渡）

    // ====================================== 阶段6：进入休眠模式（139~180ms）- 延长至40ms
    BTNU = 1'b1;  // 139ms时按下休眠按键
    #1_000_000;   // 按键持续1ms
    BTNU = 1'b0;  // 140ms时释放按键
    #40_000_000;  // 休眠模式保持40ms（原20ms，延长一倍，覆盖2个完整呼吸周期）

    // ====================================== 阶段7：退出休眠模式（180~190ms）
    BTNU = 1'b1;  // 180ms时再次按下休眠按键（退出）
    #1_000_000;   // 按键持续1ms
    BTNU = 1'b0;  // 181ms时释放按键
    #9_000_000;   // 恢复正常模式运行9ms（收尾观察）

    // ====================================== 仿真结束
    #1_000_000;  // 额外1ms确保状态稳定
    $finish;  // 终止仿真
end

// --------------- 仿真波形打印（可选，便于文本观察关键状态）---------------
initial begin
    $timeformat(-9, 2, "ns", 10);  // 时间格式：ns，保留2位小数
    $monitor("Time: %t | Mode: %b | LED_EW[绿,黄,红]: %b | LED_NS[绿,黄,红]: %b | Count_EW: %2d | Count_NS: %2d | PWM: %b",
             $time, current_mode,
             led_out[5], led_out[4], led_out[3],  // 东西方向LED（绿/黄/红）
             led_out[2], led_out[1], led_out[0],  // 南北方向LED（绿/黄/红）
             count_ew, count_ns, pwm_signal);
end

endmodule