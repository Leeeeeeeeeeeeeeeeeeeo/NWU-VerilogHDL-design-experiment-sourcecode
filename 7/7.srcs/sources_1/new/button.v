`timescale 1ns/1ps

// 模块功能：3个独立按键消抖控制对应LED（Toggle功能：按一次亮/再按一次灭）
// 硬件适配：Basys3开发板
// 端口说明：
// - clk：100MHz时钟输入（对应W5引脚）
// - rst_n：复位信号（对应BTNC，高电平有效，按下时复位）
// - key_in：3个按键输入（[2]=BTNU/[1]=BTNL/[0]=BTND，高电平按下）
// - led_out：3个LED输出（[2]=LD5/[1]=LD3/[0]=LD1，高电平点亮）
module key_debounce_led(
    input            clk,        
    input            rst_n,      
    input      [2:0] key_in,     
    output reg [2:0] led_out     
);

// 参数定义：20ms消抖延时计数器最大值（100MHz时钟计算）
// 计算逻辑：100MHz = 1e8周期/秒，20ms = 0.02秒，总周期数 = 1e8 * 0.02 = 2e6（0~1999999）
parameter PARAM_CNT_MAX = 1999999;  

// 内部信号声明
reg [2:0] key_sync1;       // 按键同步寄存器1（异步转同步第一拍，消除亚稳态）
reg [2:0] key_sync2;       // 按键同步寄存器2（异步转同步第二拍，稳定信号）
reg [2:0] key_prev;        // 按键上一周期稳定状态（用于边沿检测）
reg [2:0] key_state;       // 按键稳定状态（消抖后结果）
reg [20:0] cnt[2:0];       // 3个按键独立消抖计数器（21位覆盖2e6计数范围）
reg [2:0] cnt_en;          // 计数器使能信号（1=启动计数，0=停止并清零）
integer i;                 // 循环变量（兼容所有Verilog版本）

// 第一步：异步按键信号同步（FPGA时序设计核心，避免亚稳态）
// 适配硬件按键高电平有效特性，通过取反转换为内部低电平触发逻辑
always @(posedge clk or posedge rst_n) begin
    if(rst_n) begin       // 复位有效（高电平），初始化同步寄存器
        key_sync1 <= 3'b111;  // 对应按键未按下状态（取反后为1）
        key_sync2 <= 3'b111;
    end else begin         // 时钟上升沿，按键信号打两拍同步
        key_sync1 <= ~key_in;  // 取反：硬件高电平按下→内部低电平触发
        key_sync2 <= key_sync1;
    end
end

// 第二步：独立消抖计数器控制 + 按键稳定状态更新
always @(posedge clk or posedge rst_n) begin
    if(rst_n) begin       // 复位初始化
        cnt_en    <= 3'b000;          // 关闭所有计数器
        key_state <= 3'b111;          // 初始化为按键未按下状态
        for(i=0; i<3; i=i+1) begin    // 所有计数器清零
            cnt[i] <= 21'd0;
        end
    end else begin
        for(i=0; i<3; i=i+1) begin    // 逐个处理3个按键
            // 检测到同步后信号与当前稳定状态不一致（抖动或真实按键）
            if(key_sync2[i] != key_state[i]) begin
                cnt_en[i] <= 1'b1;          // 启动该按键消抖计数器
                cnt[i] <= cnt[i] + 21'd1;   // 计数器累加计时
                // 计数满20ms（状态稳定），更新按键稳定状态
                if(cnt[i] >= PARAM_CNT_MAX) begin
                    key_state[i] <= key_sync2[i];
                    cnt[i] <= 21'd0;       // 计数器清零
                    cnt_en[i] <= 1'b0;     // 关闭计数器
                end
            end else begin  // 状态无变化（稳定或抖动结束）
                cnt[i] <= 21'd0;
                cnt_en[i] <= 1'b0;
            end
        end
    end
end

// 第三步：LED Toggle控制（检测按键按下边沿，实现翻转功能）
always @(posedge clk or posedge rst_n) begin
    if(rst_n) begin       // 复位有效，所有LED熄灭（低电平）
        led_out  <= 3'b000;
        key_prev <= 3'b111;          // 上一周期状态初始化为未按下
    end else begin
        key_prev <= key_state;  // 保存当前稳定状态，用于下一周期边沿检测
        for(i=0; i<3; i=i+1) begin
            // 检测按键“释放→按下”边沿（内部逻辑：高→低）
            if(key_prev[i] == 1'b1 && key_state[i] == 1'b0) begin
                led_out[i] <= ~led_out[i];  // 翻转LED状态（亮→灭/灭→亮）
            end
        end
    end
end

endmodule