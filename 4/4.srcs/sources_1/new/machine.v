`timescale 1ns / 1ps

module vending_machine(
    input clk,
    input rstn,
    input [1:0] coin,
    output reg sell,
    output reg change
);

// 状态定义
parameter IDLE  = 3'b000;
parameter GET05 = 3'b001;
parameter GET10 = 3'b010; 
parameter GET15 = 3'b011;
parameter SOLD0 = 3'b100;
parameter SOLD1 = 3'b101;

// 状态寄存器
reg [2:0] current_state;
reg [2:0] next_state;

// 第一段：时序逻辑，状态寄存器
always @(posedge clk or negedge rstn) begin
    if (!rstn)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// 第二段：组合逻辑，状态转移
always @(*) begin
    case (current_state)
        IDLE: begin
            case (coin)
                2'b01: next_state = GET05;  // 投入0.5元
                2'b10: next_state = GET10;  // 投入1元
                default: next_state = IDLE;
            endcase
        end
        
        GET05: begin
            case (coin)
                2'b01: next_state = GET10;  // 再投0.5元，累计1元
                2'b10: next_state = GET15;  // 再投1元，累计1.5元
                default: next_state = GET05;
            endcase
        end
        
        GET10: begin
            case (coin)
                2'b01: next_state = GET15;  // 再投0.5元，累计1.5元
                2'b10: next_state = SOLD0;  // 再投1元，累计2元
                default: next_state = GET10;
            endcase
        end
        
        GET15: begin
            case (coin)
                2'b01: next_state = SOLD0;  // 再投0.5元，累计2元
                2'b10: next_state = SOLD1;  // 再投1元，累计2.5元
                default: next_state = GET15;
            endcase
        end
        
        SOLD0: next_state = IDLE;  // 出货完成后回到初始状态
        SOLD1: next_state = IDLE;  // 出货完成后回到初始状态
        
        default: next_state = IDLE;
    endcase
end

// 第三段：时序逻辑，基于next_state预判输出
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        sell <= 1'b0;
        change <= 1'b0;
    end else begin
        // 根据下一个状态来决定输出
        case (next_state)
            SOLD0: begin
                sell <= 1'b1;    // 预判下一个状态是SOLD0
                change <= 1'b0;
            end
            
            SOLD1: begin
                sell <= 1'b1;    // 预判下一个状态是SOLD1
                change <= 1'b1;
            end
            
            default: begin
                // 对于所有非SOLD状态，输出清零
                sell <= 1'b0;
                change <= 1'b0;
            end
        endcase
    end
end

endmodule