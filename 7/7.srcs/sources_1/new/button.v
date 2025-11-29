`timescale 1ns/1ps

module key_debounce_led(
    input            clk,        // 时钟信号（对应实验中的W5引脚，默认100MHz）
    input            rst_n,      // 复位信号（对应BTNC，低电平有效）
    input      [2:0] key_in,     // 3个独立按键输入（[2]=BTNU, [1]=BTNL, [0]=BTND，低电平按下）
    output reg [2:0] led_out,    // 修正1：添加逗号，分隔端口
    output reg [2:0] key_state   // 观察key_state，添加output声明（已在端口列表，无需内部重复声明）
);

// 1. 参数定义：20ms消抖延时对应的计数器最大值（100MHz时钟：100MHz = 1e8周期/秒，20ms = 2e6周期）
parameter PARAM_CNT_MAX = 1999999;  // 计数器从0到1999999，共2e6个周期，实现20ms延时

// 2. 内部信号声明（修正2：删除重复的key_state声明）
reg [2:0] key_sync1;       // 按键同步寄存器1（异步转同步第一拍）
reg [2:0] key_sync2;       // 按键同步寄存器2（异步转同步第二拍，消除亚稳态）
reg [2:0] key_prev;        // 按键上一周期稳定状态寄存器（用于检测按键边沿）
reg [20:0] cnt[2:0];       // 3个按键独立的消抖计数器（21位可覆盖PARAM_CNT_MAX）
reg [2:0] cnt_en;          // 计数器使能信号（1：启动计数，0：清零）
integer i;                 // 修正3：提前声明循环变量，兼容所有Verilog版本

// 3. 第一步：按键异步信号同步（消除亚稳态，关键时序处理）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin       // 复位时，同步寄存器清零
        key_sync1 <= 3'b111;
        key_sync2 <= 3'b111;
    end else begin         // 时钟上升沿，按键信号打两拍同步
        key_sync1 <= key_in;
        key_sync2 <= key_sync1;
    end
end

// 4. 第二步：消抖计数器控制与稳定状态更新（每个按键独立消抖）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin       // 复位时，计数器、稳定状态、使能信号初始化
        cnt_en <= 3'b000;
        key_state <= 3'b111;  // key_state为端口寄存器，直接初始化
        for(i=0; i<3; i=i+1) begin  // 复用外部声明的i，无块内integer
            cnt[i] <= 21'd0;
        end
    end else begin
        for(i=0; i<3; i=i+1) begin  // 复用外部声明的i
            // 检测到同步后按键状态与当前稳定状态不同，启动计数器
            if(key_sync2[i] != key_state[i]) begin
                cnt_en[i] <= 1'b1;          // 使能计数器
                cnt[i] <= cnt[i] + 21'd1;   // 计数器累加
                // 计数器计满20ms，更新稳定状态，关闭计数器
                if(cnt[i] >= PARAM_CNT_MAX) begin
                    key_state[i] <= key_sync2[i];
                    cnt[i] <= 21'd0;
                    cnt_en[i] <= 1'b0;
                end
            end else begin                  // 状态无变化，计数器清零，关闭使能
                cnt[i] <= 21'd0;
                cnt_en[i] <= 1'b0;
            end
        end
    end
end

// 5. 第三步：LED亮灭控制（检测按键稳定按下边沿，实现Toggle功能）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin       // 复位时，所有LED熄灭
        led_out <= 3'b000;
        key_prev <= 3'b111;
    end else begin
        key_prev <= key_state;  // 保存上一周期稳定状态，用于边沿检测
        for(i=0; i<3; i=i+1) begin  // 复用外部声明的i
            // 检测按键“释放→按下”边沿（key_prev高、key_state低，对应按键按下）
            if(key_prev[i] == 1'b1 && key_state[i] == 1'b0) begin
                led_out[i] <= ~led_out[i];  // 翻转LED状态（亮→灭/灭→亮）
            end
        end
    end
end

endmodule