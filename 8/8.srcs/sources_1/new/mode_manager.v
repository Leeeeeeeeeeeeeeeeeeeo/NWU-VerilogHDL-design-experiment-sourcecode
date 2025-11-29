module mode_manager(
    input clk,
    input rst_n,
    input peak_switch,      // 高峰期模式开关
    input emergency_btn,    // 应急模式按钮
    input sleep_btn,        // 休眠模式按钮
    output reg [1:0] mode   // 当前模式
);

    // 模式定义
    parameter MODE_NORMAL = 2'b00;   // 普通模式
    parameter MODE_PEAK   = 2'b01;   // 高峰期模式  
    parameter MODE_EMERG  = 2'b10;   // 应急模式
    parameter MODE_SLEEP  = 2'b11;   // 休眠模式

    // 按钮消抖寄存器
    reg [19:0] emergency_counter;
    reg [19:0] sleep_counter;
    reg emergency_stable;
    reg sleep_stable;
    reg emergency_prev;
    reg sleep_prev;
    
    // 模式状态寄存器
    reg emergency_active;
    reg sleep_active;

    // 按钮消抖逻辑（20ms消抖）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            emergency_counter <= 0;
            sleep_counter <= 0;
            emergency_stable <= 0;
            sleep_stable <= 0;
            emergency_prev <= 0;
            sleep_prev <= 0;
        end else begin
            // 应急按钮消抖
            if (emergency_btn != emergency_prev) begin
                emergency_counter <= 0;
                emergency_prev <= emergency_btn;
            end else if (emergency_counter < 20'd1_000_000) begin // 20ms at 50MHz
                emergency_counter <= emergency_counter + 1;
            end else begin
                emergency_stable <= emergency_prev;
            end
            
            // 休眠按钮消抖
            if (sleep_btn != sleep_prev) begin
                sleep_counter <= 0;
                sleep_prev <= sleep_btn;
            end else if (sleep_counter < 20'd1_000_000) begin
                sleep_counter <= sleep_counter + 1;
            end else begin
                sleep_stable <= sleep_prev;
            end
        end
    end

    // 模式切换逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            emergency_active <= 0;
            sleep_active <= 0;
            mode <= MODE_NORMAL;
        end else begin
            // 应急模式切换（按钮按下翻转）
            if (emergency_stable && !emergency_prev) begin
                emergency_active <= ~emergency_active;
                sleep_active <= 0;  // 应急模式激活时关闭休眠模式
            end
            
            // 休眠模式切换（按钮按下翻转）
            if (sleep_stable && !sleep_prev) begin
                sleep_active <= ~sleep_active;
                emergency_active <= 0;  // 休眠模式激活时关闭应急模式
            end
            
            // 模式优先级：应急模式 > 休眠模式 > 高峰期模式 > 普通模式
            if (emergency_active) begin
                mode <= MODE_EMERG;
            end else if (sleep_active) begin
                mode <= MODE_SLEEP;
            end else if (peak_switch) begin
                mode <= MODE_PEAK;
            end else begin
                mode <= MODE_NORMAL;
            end
        end
    end

endmodule