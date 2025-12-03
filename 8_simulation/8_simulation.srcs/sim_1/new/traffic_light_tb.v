`timescale 1ns/1ps

module traffic_light_tb;

// 激励信号（与顶层模块一致）
reg clk_100m;         // 100MHz时钟（周期10ns）
reg top_rst;          // 硬件复位键（高电平有效）
reg peak_switch;      // 高峰模式开关（0=正常，1=高峰）
reg [1:0] key_in;     // 按键输入：[1]=休眠，[0]=应急（高电平按下）

// 观测信号（与顶层模块一致）
wire [2:0] light_ew;  // 东西方向灯
wire [2:0] light_ns;  // 南北方向灯
wire CA, CB, CC, CD, CE, CF, CG;
wire dp;
wire AN0, AN1, AN2, AN3;

// 实例化顶层模块
traffic_light_system_sim u_traffic_light_system(
    .clk_100m(clk_100m),
    .top_rst(top_rst),
    .peak_switch(peak_switch),
    .key_in(key_in),
    .light_ew(light_ew),
    .light_ns(light_ns),
    .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG),
    .dp(dp),
    .AN0(AN0), .AN1(AN1), .AN2(AN2), .AN3(AN3)
);

// 1. 生成100MHz时钟（周期10ns，持续运行）
initial begin
    clk_100m = 1'b0;
    forever #5 clk_100m = ~clk_100m;  // 每5ns翻转一次，稳定时钟
end

// 2. 生成硬件复位激励（仅初始复位）
initial begin
    top_rst = 1'b1;          // 0ns：复位有效
    #20;                     // 复位20ns（2个时钟周期，确保所有模块稳定复位）
    top_rst = 1'b0;          // 0.02ms：释放复位，系统启动
end

// 3. 生成高峰模式开关激励（精准控制模式切换）
initial begin
    peak_switch = 1'b0;      // 0~100ms：正常模式
    #100_000_000;            // 100ms：切换到高峰模式
    peak_switch = 1'b1;
    #100_000_000;            // 200ms：高峰模式结束，切回正常模式
    peak_switch = 1'b0;
end

// 4. 按键激励（时序精准计算，确保350ms准时按下应急键）
initial begin
    key_in = 2'b00;          // 初始：无按键按下（低电平）
    
    // -------------------------- 阶段1：休眠模式（200ms进入，300ms解除）--------------------------
    #200_000_000;            // 200ms：第一次按休眠键（进入模式）
    key_in[1] = 1'b1;
    #20_000_000;             // 按下维持20ms（200~220ms），满足消抖阈值
    key_in[1] = 1'b0;        // 220ms：释放休眠键，消抖后触发进入休眠（220ms左右生效）
    
    #80_000_000;             // 220ms + 80ms = 300ms：第二次按休眠键（解除模式）
    key_in[1] = 1'b1;
    #20_000_000;             // 按下维持20ms（300~320ms）
    key_in[1] = 1'b0;        // 320ms：释放休眠键，消抖后触发解除休眠（320ms左右生效）
    
    // -------------------------- 阶段2：应急模式（350ms进入，450ms解除）--------------------------
    #30_000_000;             // 320ms + 30ms = 350ms：第一次按应急键（进入模式）
    key_in[0] = 1'b1;
    #20_000_000;             // 按下维持20ms（350~370ms）
    key_in[0] = 1'b0;        // 370ms：释放应急键，消抖后触发进入应急（370ms左右生效）
    
    #80_000_000;             // 370ms + 80ms = 450ms：第二次按应急键（解除模式）
    key_in[0] = 1'b1;
    #20_000_000;             // 按下维持20ms（450~470ms）
    key_in[0] = 1'b0;        // 470ms：释放应急键，消抖后触发解除应急（470ms左右生效）
end

// 5. 仿真结束控制（总时长500ms，确保应急解除后稳定观测）
initial begin
    #500_000_000;            // 500ms：所有核心测试场景完成（应急解除后30ms稳定期）
    $stop;                    // 停止仿真
end

endmodule