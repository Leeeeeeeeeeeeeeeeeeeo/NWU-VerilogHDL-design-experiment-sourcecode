`timescale 1ns / 1ps

module tb_flowing_led_sim();

// 输入信号
reg clk;
reg rst;

// 输出信号
wire [15:0] led;

// 实例化被测试模块
flowing_led_sim uut (
    .clk(clk),
    .rst(rst),
    .led(led)
);

// 时钟生成：100MHz (10ns周期)
always #5 clk = ~clk;

// 测试序列
initial begin
    // 初始化信号
    clk = 0;
    rst = 1;
    
    // 生成VCD文件用于波形查看
    $dumpfile("flowing_led_sim.vcd");
    $dumpvars(0, tb_flowing_led_sim);
    
    // 记录仿真开始
    $display("仿真开始时间: %t", $time);
    
    // 保持复位状态100ns
    #100;
    
    // 释放复位
    rst = 0;
    $display("复位已释放，开始测试流水灯序列");
    
    // 等待完整周期 (6.4us) 再加一些额外时间
    #7000;
    
    $display("仿真结束时间: %t", $time);
    $display("完成完整周期测试!");
    $finish;
end

// 实时监控LED状态变化
initial begin
    // 等待复位释放
    @(negedge rst);
    
    // 持续监控LED状态
    forever begin
        // 在每个使能信号时刻检查状态
        @(posedge uut.clk_100ns_en);
        $display("时间: %t, 计数器: %d, LED状态: %b", 
                 $time, uut.main_counter, led);
        
        // 关键状态点特别标注
        case (uut.main_counter)
            0: $display("  --> 状态1开始: 奇偶闪烁");
            8: $display("  --> 状态2开始: 从右到左点亮");
            24: $display("  --> 状态3开始: 从左到右熄灭");
            40: $display("  --> 状态4开始: 奇偶闪烁");
            48: $display("  --> 状态5开始: 从两边到中间点亮");
            56: $display("  --> 状态6开始: 从中间到两边熄灭");
            63: $display("  --> 周期完成，开始循环");
        endcase
    end
end

endmodule