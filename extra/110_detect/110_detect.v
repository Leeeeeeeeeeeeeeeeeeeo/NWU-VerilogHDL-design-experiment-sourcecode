module detector_110_three_Mealy(
    input clk,
    input reset,
    input in,
    output reg out
);
    
    reg [1:0] n_state, p_state;
    parameter s0 = 2'b00, s1 = 2'b01, s2 = 2'b11;
    
    // 时序逻辑 - 非阻塞赋值
    always@(posedge clk) begin
        if (reset) 
            p_state <= s0;
        else 
            p_state <= n_state;
    end
    
    // 组合逻辑 - 自动敏感列表
    always@(*) begin
        case(p_state)
            s0: n_state = (in == 1'b1) ? s1 : s0;
            s1: n_state = (in == 1'b1) ? s2 : s0;
            s2: n_state = (in == 1'b1) ? s2 : s0;
            default: n_state = s0;
        endcase
    end
    
    // 输出逻辑 - 自动敏感列表
    always@(*) begin
        case(p_state)
            s0: out = 1'b0;
            s1: out = 1'b0;
            s2: out = (in == 1'b0) ? 1'b1 : 1'b0;
            default: out = 1'b0;
        endcase
    end
endmodule