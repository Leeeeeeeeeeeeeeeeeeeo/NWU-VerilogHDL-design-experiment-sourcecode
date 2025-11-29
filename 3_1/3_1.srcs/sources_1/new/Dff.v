module Dff(
    input wire S,    // 同步置位，高有效，对应SW2
    input wire R,    // 异步复位，高有效，对应SW1
    input wire D,    // 数据输入，对应SW0
    input wire CP,   // 时钟信号，对应SW3
    output wire Q,   // 输出，对应LD1
    output wire Q_n  // 反相输出，对应LD0
);

reg q_reg; // 定义一个寄存器来存储D触发器的状态

// 时序逻辑块：定义在时钟上升沿或异步复位时执行的操作
always @(posedge CP or posedge R) begin
    if (R) begin         // 异步复位优先级最高
        q_reg <= 1'b0;
    end else if (S) begin // 同步置位
        q_reg <= 1'b1;
    end else begin       // 正常数据锁存
        q_reg <= D;
    end
end

// 连续赋值语句：将寄存器的值输出，并生成反相输出
assign Q = q_reg;
assign Q_n = ~q_reg;

endmodule