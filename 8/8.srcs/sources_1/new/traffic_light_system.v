`timescale 1ns/1ps

module traffic_light_system(
    input clk_100m,         // 100MHz系统时钟（Basys3时钟）
    input top_rst,          // 硬件复位键（高电平有效，Basys3复位键）
    input peak_switch,      // 高峰模式开关（SW5：0=正常，1=高峰）
    input [1:0] key_in,     // 按键输入：[1]=BTNU（休眠），[0]=BTNC（应急）
    output [2:0] light_ew,  // 东西方向灯：[2]=LD10，[1]=LD9，[0]=LD8
    output [2:0] light_ns,  // 南北方向灯：[2]=LD7，[1]=LD6，[0]=LD5
    output CA, CB, CC, CD, CE, CF, CG,  // 数码管段选
    output dp,              // 数码管小数点
    output AN0, AN1, AN2, AN3  // 数码管位选
);

// 内部互联信号
wire [1:0] current_mode;
wire [5:0] count_ew, count_ns;
wire pwm_signal;
wire [2:0] base_light_ew, base_light_ns;
wire [1:0] key_state;
wire core_rst_n;
wire rst_n;  // 子模块低电平有效复位（top_rst高电平→rst_n低电平）

// 硬件复位键转换（高电平有效→低电平有效）
assign rst_n = ~top_rst;

// 1. 按键消抖模块
key_debounce u_key_debounce(
    .clk(clk_100m),
    .rst_n(rst_n),
    .key_in(key_in),
    .key_state(key_state)
);

// 2. 模式管理模块
mode_manager u_mode_manager(
    .clk(clk_100m),
    .rst_n(rst_n),
    .peak_switch(peak_switch),
    .emergency_key(key_state[0]),
    .sleep_key(key_state[1]),
    .mode(current_mode),
    .core_rst_n(core_rst_n)
);

// 3. 呼吸灯模块
pwm_breathing u_pwm_breathing(
    .clk(clk_100m),
    .rst_n(rst_n),
    .enable(current_mode == 2'b11),  // 休眠模式启动呼吸
    .pwm_out(pwm_signal)
);

// 4. 核心交通灯状态机
traffic_light_core u_traffic_light_core(
    .clk(clk_100m),
    .rst_n(rst_n),
    .core_rst_n(core_rst_n),
    .current_mode(current_mode),
    .light_ew(base_light_ew),
    .light_ns(base_light_ns),
    .count_ew(count_ew),
    .count_ns(count_ns)
);

// 5. 数码管显示模块
display_controller u_display_controller(
    .clk_100m(clk_100m),
    .rst_n(rst_n),
    .mode(current_mode),
    .count_ew(count_ew),
    .count_ns(count_ns),
    .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG),
    .dp(dp),
    .AN0(AN0), .AN1(AN1), .AN2(AN2), .AN3(AN3)
);

// 6. 最终灯状态输出（符合文档模式要求）
assign light_ew = (current_mode == 2'b10) ? 3'b001 :  // 应急模式→全红灯（LD8亮）
                  (current_mode == 2'b11) ? {1'b0, pwm_signal, 1'b0} :  // 休眠→黄灯呼吸（LD9）
                  base_light_ew;
                  
assign light_ns = (current_mode == 2'b10) ? 3'b001 :  // 应急模式→全红灯（LD5亮）
                  (current_mode == 2'b11) ? {1'b0, pwm_signal, 1'b0} :  // 休眠→黄灯呼吸（LD6）
                  base_light_ns;

endmodule