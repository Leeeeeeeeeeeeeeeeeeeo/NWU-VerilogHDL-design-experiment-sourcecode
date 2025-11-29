module display_controller(
    input clk_100m,         // 100MHz系统时钟
    input rst_n,            // 异步复位
    input [1:0] mode,       // 当前模式
    input [5:0] count_ew,   // 东西方向倒计时
    input [5:0] count_ns,   // 南北方向倒计时
    output reg CA, CB, CC, CD, CE, CF, CG,  // 七段数码管段选信号
    output dp,               // 小数点
    output reg AN0, AN1, AN2, AN3 // 数码管位选信号
);

    // 分频模块生成200Hz扫描时钟
    reg [17:0] counter = 0;
    reg clk_200hz = 0;
    
    // 分频参数：100,000,000 / 200 / 2 = 250,000
    parameter DIVIDER_VALUE = 250000 - 1;
    
    // 分频逻辑
    always @(posedge clk_100m) begin
        if (!rst_n) begin
            counter <= 0;
            clk_200hz <= 0;
        end else if (counter == DIVIDER_VALUE) begin
            counter <= 0;
            clk_200hz <= ~clk_200hz;
        end else begin
            counter <= counter + 1;
        end
    end

    // 根据模式确定要显示的数字
    reg [3:0] digit_ew_high, digit_ew_low;  // 东西方向十位和个位
    reg [3:0] digit_ns_high, digit_ns_low;  // 南北方向十位和个位
    
    always @(*) begin
        case (mode)
            // 应急模式：显示00
            2'b10: begin
                digit_ew_high = 4'd0;
                digit_ew_low = 4'd0;
                digit_ns_high = 4'd0;
                digit_ns_low = 4'd0;
            end
            // 休眠模式：显示99
            2'b11: begin
                digit_ew_high = 4'd9;
                digit_ew_low = 4'd9;
                digit_ns_high = 4'd9;
                digit_ns_low = 4'd9;
            end
            // 普通模式和高峰期模式：显示实际倒计时
            default: begin
                // 东西方向显示
                if (count_ew >= 60) begin
                    digit_ew_high = 4'd0;
                    digit_ew_low = 4'd0;
                end else begin
                    digit_ew_high = (count_ew / 10) % 10;
                    digit_ew_low = count_ew % 10;
                end
                
                // 南北方向显示
                if (count_ns >= 60) begin
                    digit_ns_high = 4'd0;
                    digit_ns_low = 4'd0;
                end else begin
                    digit_ns_high = (count_ns / 10) % 10;
                    digit_ns_low = count_ns % 10;
                end
            end
        endcase
    end

    // 位选计数器
    reg [1:0] digit_sel = 0;
    
    // 200Hz时钟驱动位选扫描
    always @(posedge clk_200hz or negedge rst_n) begin
        if (!rst_n) begin
            digit_sel <= 0;
        end else begin
            digit_sel <= digit_sel + 1;
        end
    end

    // 位选信号解码（共阳极，低电平有效）
    // AN3是最左边，AN0是最右边
    // 分配：AN3=东西十位, AN2=东西个位, AN1=南北十位, AN0=南北个位
    always @(*) begin
        case(digit_sel)
            2'b00: begin
                AN3 = 1'b0; // 选中AN3 (东西十位)
                AN2 = 1'b1;
                AN1 = 1'b1;
                AN0 = 1'b1;
            end
            2'b01: begin
                AN3 = 1'b1;
                AN2 = 1'b0; // 选中AN2 (东西个位)
                AN1 = 1'b1;
                AN0 = 1'b1;
            end
            2'b10: begin
                AN3 = 1'b1;
                AN2 = 1'b1;
                AN1 = 1'b0; // 选中AN1 (南北十位)
                AN0 = 1'b1;
            end
            2'b11: begin
                AN3 = 1'b1;
                AN2 = 1'b1;
                AN1 = 1'b1;
                AN0 = 1'b0; // 选中AN0 (南北个位)
            end
            default: begin
                AN3 = 1'b1;
                AN2 = 1'b1;
                AN1 = 1'b1;
                AN0 = 1'b1;
            end
        endcase
    end

    // 当前选中的数字
    reg [3:0] current_digit;
    
    // 选择当前要显示的数字
    always @(*) begin
        case(digit_sel)
            2'b00: current_digit = digit_ew_high;  // AN3: 东西十位
            2'b01: current_digit = digit_ew_low;   // AN2: 东西个位
            2'b10: current_digit = digit_ns_high;  // AN1: 南北十位
            2'b11: current_digit = digit_ns_low;   // AN0: 南北个位
            default: current_digit = 4'd0;
        endcase
    end

    // 七段数码管译码器（共阳极，低电平点亮）
    always @(*) begin
        case(current_digit)
            4'd0: begin
                CA = 1'b0;
                CB = 1'b0;
                CC = 1'b0;
                CD = 1'b0;
                CE = 1'b0;
                CF = 1'b0;
                CG = 1'b1;
            end
            4'd1: begin
                CA = 1'b1;
                CB = 1'b0;
                CC = 1'b0;
                CD = 1'b1;
                CE = 1'b1;
                CF = 1'b1;
                CG = 1'b1;
            end
            4'd2: begin
                CA = 1'b0;
                CB = 1'b0;
                CC = 1'b1;
                CD = 1'b0;
                CE = 1'b0;
                CF = 1'b1;
                CG = 1'b0;
            end
            4'd3: begin
                CA = 1'b0;
                CB = 1'b0;
                CC = 1'b0;
                CD = 1'b0;
                CE = 1'b1;
                CF = 1'b1;
                CG = 1'b0;
            end
            4'd4: begin
                CA = 1'b1;
                CB = 1'b0;
                CC = 1'b0;
                CD = 1'b1;
                CE = 1'b1;
                CF = 1'b0;
                CG = 1'b0;
            end
            4'd5: begin
                CA = 1'b0;
                CB = 1'b1;
                CC = 1'b0;
                CD = 1'b0;
                CE = 1'b1;
                CF = 1'b0;
                CG = 1'b0;
            end
            4'd6: begin
                CA = 1'b0;
                CB = 1'b1;
                CC = 1'b0;
                CD = 1'b0;
                CE = 1'b0;
                CF = 1'b0;
                CG = 1'b0;
            end
            4'd7: begin
                CA = 1'b0;
                CB = 1'b0;
                CC = 1'b0;
                CD = 1'b1;
                CE = 1'b1;
                CF = 1'b1;
                CG = 1'b1;
            end
            4'd8: begin
                CA = 1'b0;
                CB = 1'b0;
                CC = 1'b0;
                CD = 1'b0;
                CE = 1'b0;
                CF = 1'b0;
                CG = 1'b0;
            end
            4'd9: begin
                CA = 1'b0;
                CB = 1'b0;
                CC = 1'b0;
                CD = 1'b0;
                CE = 1'b1;
                CF = 1'b0;
                CG = 1'b0;
            end
            default: begin
                CA = 1'b1;
                CB = 1'b1;
                CC = 1'b1;
                CD = 1'b1;
                CE = 1'b1;
                CF = 1'b1;
                CG = 1'b1;
            end
        endcase
    end

    // 小数点始终不点亮
    assign dp = 1'b1;

endmodule