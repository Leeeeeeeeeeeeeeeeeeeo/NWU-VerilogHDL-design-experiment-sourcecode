module display_controller_sim(
    input clk_100m,         // 100MHz系统时钟
    input rst_n,            // 异步复位
    input [1:0] mode,       // 当前模式
    input [5:0] count_ew,   // 东西方向倒计时（仿真ms，对应真实秒）
    input [5:0] count_ns,   // 南北方向倒计时（仿真ms，对应真实秒）
    output reg CA, CB, CC, CD, CE, CF, CG,  // 七段数码管段选信号（共阳极，低电平有效）
    output dp,               // 小数点（始终熄灭）
    output reg AN0, AN1, AN2, AN3 // 数码管位选信号（共阳极，低电平有效）
);

    // 分频模块生成200Hz扫描时钟（避免数码管闪烁，仿真无需修改）
    reg [17:0] counter = 0;
    reg clk_200hz = 0;
    parameter DIVIDER_VALUE = 250000 - 1;  // 100MHz→200Hz，仿真/真实一致
    
    // 100MHz→200Hz分频逻辑
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

    // 根据模式解码显示数字（逻辑不变）
    reg [3:0] digit_ew_high, digit_ew_low;
    reg [3:0] digit_ns_high, digit_ns_low;
    
    always @(*) begin
        case (mode)
            2'b10: begin  // 应急模式：显示00
                digit_ew_high = 4'd0;
                digit_ew_low = 4'd0;
                digit_ns_high = 4'd0;
                digit_ns_low = 4'd0;
            end
            2'b11: begin  // 休眠模式：显示99
                digit_ew_high = 4'd9;
                digit_ew_low = 4'd9;
                digit_ns_high = 4'd9;
                digit_ns_low = 4'd9;
            end
            default: begin  // 正常/高峰模式：显示倒计时（0-60ms，对应真实0-60秒）
                digit_ew_high = (count_ew / 10) % 10;
                digit_ew_low = count_ew % 10;
                digit_ns_high = (count_ns / 10) % 10;
                digit_ns_low = count_ns % 10;
            end
        endcase
    end

    // 位选计数器与解码（逻辑不变）
    reg [1:0] digit_sel = 0;
    always @(posedge clk_200hz or negedge rst_n) begin
        if (!rst_n) begin
            digit_sel <= 0;
        end else begin
            digit_sel <= digit_sel + 1;
        end
    end

    always @(*) begin
        case(digit_sel)
            2'b00: {AN3, AN2, AN1, AN0} = 4'b0111;  // 东西十位（AN3）
            2'b01: {AN3, AN2, AN1, AN0} = 4'b1011;  // 东西个位（AN2）
            2'b10: {AN3, AN2, AN1, AN0} = 4'b1101;  // 南北十位（AN1）
            2'b11: {AN3, AN2, AN1, AN0} = 4'b1110;  // 南北个位（AN0）
            default: {AN3, AN2, AN1, AN0} = 4'b1111;
        endcase
    end

    // 显示数字选择（逻辑不变）
    reg [3:0] current_digit;
    always @(*) begin
        case(digit_sel)
            2'b00: current_digit = digit_ew_high;
            2'b01: current_digit = digit_ew_low;
            2'b10: current_digit = digit_ns_high;
            2'b11: current_digit = digit_ns_low;
            default: current_digit = 4'd0;
        endcase
    end

    // 七段数码管译码（逻辑不变）
    always @(*) begin
        case(current_digit)
            4'd0: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000001;
            4'd1: {CA, CB, CC, CD, CE, CF, CG} = 7'b1001111;
            4'd2: {CA, CB, CC, CD, CE, CF, CG} = 7'b0010010;
            4'd3: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000110;
            4'd4: {CA, CB, CC, CD, CE, CF, CG} = 7'b1001100;
            4'd5: {CA, CB, CC, CD, CE, CF, CG} = 7'b0100100;
            4'd6: {CA, CB, CC, CD, CE, CF, CG} = 7'b0100000;
            4'd7: {CA, CB, CC, CD, CE, CF, CG} = 7'b0001111;
            4'd8: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000000;
            4'd9: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000100;
            default: {CA, CB, CC, CD, CE, CF, CG} = 7'b1111111;
        endcase
    end

    assign dp = 1'b1;  // 小数点始终熄灭

endmodule