module vending_machine(
    input clk,           // 时钟信号 - SW4
    input rstn,          // 复位信号(低有效) - SW3
    input [1:0] coin,    // 投币输入: 01=0.5元, 10=1元 - SW2,SW1
    output reg sell,     // 出货信号 - LD0
    output reg change    // 找零信号 - LD1
);

// 状态定义
parameter IDLE  = 2'b00;  // 初始状态
parameter GET05 = 2'b01;  // 已投0.5元
parameter GET10 = 2'b10;  // 已投1元  
parameter GET15 = 2'b11;  // 已投1.5元

// 状态寄存器
reg [1:0] current_state;
reg [1:0] next_state;

// 第一段：状态寄存器（时序逻辑）
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// 第二段：状态转移逻辑（组合逻辑）
always @(*) begin
    next_state = current_state; // 默认保持当前状态
    
    case (current_state)
        IDLE: begin
            case (coin)
                2'b01: next_state = GET05;  // 投0.5元
                2'b10: next_state = GET10;  // 投1元
                default: next_state = IDLE; // 无投币或无效投币
            endcase
        end
        
        GET05: begin
            case (coin)
                2'b01: next_state = GET10;  // 再投0.5元，累计1元
                2'b10: next_state = GET15;  // 投1元，累计1.5元
                default: next_state = GET05; // 无投币，保持状态
            endcase
        end
        
        GET10: begin
            case (coin)
                2'b01: next_state = GET15;  // 再投0.5元，累计1.5元
                2'b10: next_state = IDLE;   // 投1元，累计2元，完成购买
                default: next_state = GET10; // 无投币，保持状态
            endcase
        end
        
        GET15: begin
            case (coin)
                2'b01: next_state = IDLE;   // 再投0.5元，累计2元，完成购买
                2'b10: next_state = IDLE;   // 投1元，累计2.5元，完成购买并找零
                default: next_state = GET15; // 无投币，保持状态
            endcase
        end
    endcase
end

// 第三段：输出逻辑（时序逻辑）
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        sell <= 1'b0;
        change <= 1'b0;
    end else begin
        // 默认输出
        sell <= 1'b0;
        change <= 1'b0;
        
        // 出货和找零条件
        case (current_state)
            GET10: begin
                if (coin == 2'b10) begin  // 在GET10状态投1元，完成购买
                    sell <= 1'b1;
                    change <= 1'b0;
                end
            end
            
            GET15: begin
                if (coin == 2'b01) begin  // 在GET15状态投0.5元，完成购买
                    sell <= 1'b1;
                    change <= 1'b0;
                end else if (coin == 2'b10) begin  // 在GET15状态投1元，完成购买并找零
                    sell <= 1'b1;
                    change <= 1'b1;
                end
            end
        endcase
    end
end

endmodule