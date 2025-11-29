`timescale 1ns/1ps

module tb_traffic_light_sim;

// 激励信号（对应顶层模块输入）
reg clk_100m;
reg rst_n;
reg peak_switch;
reg [1:0] key_in;  // [1]=BTNU（休眠），[0]=BTNC（应急）

// 观测信号（用于波形查看）
wire [2:0] light_ew;
wire [2:0] light_ns;
wire CA, CB, CC, CD, CE, CF, CG, dp;
wire AN0, AN1, AN2, AN3;
wire [1:0] current_mode;  // 观测当前模式（从mode_manager_sim暴露）
wire [5:0] count_ew, count_ns;  // 观测倒计时（从core_sim暴露）

// 实例化仿真专用顶层模块
traffic_light_system_sim u_traffic_light_system_sim(
    .clk_100m(clk_100m),
    .rst_n(rst_n),
    .peak_switch(peak_switch),
    .key_in(key_in),
    .light_ew(light_ew),
    .light_ns(light_ns),
    .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG),
    .dp(dp),
    .AN0(AN0), .AN1(AN1), .AN2(AN2), .AN3(AN3)
);

// 暴露内部信号用于观测（直接通过层级访问，无需修改模块）
assign current_mode = u_traffic_light_system_sim.u_mode_manager_sim.mode;
assign count_ew = u_traffic_light_system_sim.u_traffic_light_core_sim.count_ew;
assign count_ns = u_traffic_light_system_sim.u_traffic_light_core_sim.count_ns;

// 1. 生成100MHz时钟（周期10ns，仿真核心时钟）
initial begin
    clk_100m = 1'b0;
    forever #5 clk_100m = ~clk_100m;  // 10ns周期（100MHz），正确！
end

// 2. 生成复位信号（初始复位100ns，正确！）
initial begin
    rst_n = 1'b0;
    #100 rst_n = 1'b1;  // 100ns后释放复位，正确！
end

// 3. 生成模式切换与按键激励（核心修正：所有延迟×1000）
initial begin
    // 初始状态：正常模式（SW5拨下）、按键释放（高电平）
    peak_switch = 1'b0;
    key_in = 2'b11;  // 按键释放（低电平按下，高电平释放）
    
    // 场景1：正常模式运行1个完整循环（40ms：20+5+15）→ 原#40_000 → 修正#40_000_000
    #40_000_000;  // 仿真40ms（等价真实40秒）
    
    // 场景2：切换高峰模式（SW5拨上），运行30ms → 原#30_000 → 修正#30_000_000
    peak_switch = 1'b1;
    #30_000_000;  // 仿真30ms（覆盖高峰模式1个半状态）
    
    // 场景3：触发应急模式（按下BTNC，低电平10ms）→ 原#10_000 → 修正#10_000_000
    key_in[0] = 1'b0;  // 应急按键按下
    #10_000_000;  // 保持按下10ms（超过消抖时间20μs，正确！）
    key_in[0] = 1'b1;  // 释放按键
    #15_000_000;  // 应急模式运行15ms → 原#15_000 → 修正#15_000_000
    
    // 场景4：解除应急模式（再按BTNC）
    key_in[0] = 1'b0;
    #10_000_000;  // 按下10ms → 修正后
    key_in[0] = 1'b1;
    #20_000_000;  // 恢复高峰模式运行20ms → 修正后
    
    // 场景5：触发休眠模式（按下BTNU）
    key_in[1] = 1'b0;
    #10_000_000;  // 按下10ms → 修正后
    key_in[1] = 1'b1;
    #15_000_000;  // 休眠模式运行15ms → 修正后
    
    // 场景6：解除休眠模式（再按BTNU）
    key_in[1] = 1'b0;
    #10_000_000;  // 按下10ms → 修正后
    key_in[1] = 1'b1;
    #10_000_000;  // 恢复运行10ms → 修正后
    
    // 结束仿真（总时长：40+30+10+15+10+20+10+15+10+10= 170ms，与日志呼应）
    $finish;
end

// 波形文件保存（便于Vivado查看信号）
initial begin
    $dumpfile("tb_traffic_light_sim.vcd");
    $dumpvars(0, tb_traffic_light_sim);
end

endmodule