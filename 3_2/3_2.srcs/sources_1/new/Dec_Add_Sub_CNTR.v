module Dec_Add_Sub_CNTR(
    input wire Clk,
    input wire R,
    input wire S,
    input wire Up_Down,
    input wire [3:0] Load_Data,
    output reg [3:0] Count,
    output wire GS,
    output wire GC
);

// 使用内部寄存器避免竞态条件
reg [3:0] next_count;

always @(posedge Clk or posedge R) begin
    if (R) begin
        // 异步复位优先级最高
        Count <= 4'b0000;
    end else begin
        Count <= next_count;
    end
end

// 组合逻辑计算下一个状态
always @(*) begin
    if (S) begin
        // 同步置数
        if (Load_Data > 4'd9) begin
            // 根据当前Up_Down状态决定无效数据的处理
            if (Up_Down) begin
                next_count = 4'b0000; // 加法模式从0开始
            end else begin
                next_count = 4'b1001; // 减法模式从9开始
            end
        end else begin
            next_count = Load_Data; // 有效数据直接置入
        end
    end else begin
        // 正常计数模式
        if (Up_Down) begin
            // 加法计数
            if (Count >= 4'd9) begin
                next_count = 4'b0000;
            end else begin
                next_count = Count + 4'b0001;
            end
        end else begin
            // 减法计数
            if (Count <= 4'd0) begin
                next_count = 4'b1001;
            end else begin
                next_count = Count - 4'b0001;
            end
        end
    end
end

// 初始化寄存器
initial begin
    Count = 4'b0000;
end

// 输出信号
assign GS = (Count != 4'b0000);
assign GC = (Count == 4'b0000);

endmodule