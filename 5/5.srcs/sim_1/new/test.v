`timescale 1ns / 1ps

module tb_flowing_led();

// 输入信号
reg clk;
reg rst;

// 输出信号
wire [15:0] led;

// 实例化被测试模块
flowing_led uut (
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
    $dumpfile("flowing_led.vcd");
    $dumpvars(0, tb_flowing_led);
    
    // 保持复位状态一段时间
    #100;
    
    // 释放复位
    rst = 0;
    
    $display("仿真开始时间: %t", $time);
    $display("复位已释放，开始测试流水灯序列");
    
    // 监视LED状态变化
    forever begin
        @(led);
        $display("时间: %t, LED状态: %b", $time, led);
    end
end

// 状态检查任务
task check_state;
    input [5:0] expected_counter_range_start;
    input [5:0] expected_counter_range_end;
    input [15:0] expected_led_pattern;
    input string state_name;
    begin
        if (led === expected_led_pattern) begin
            $display("时间: %t - 状态检查通过: %s, LED: %b", 
                     $time, state_name, led);
        end else begin
            $display("时间: %t - 状态检查失败: %s, 期望: %b, 实际: %b", 
                     $time, state_name, expected_led_pattern, led);
        end
    end
endtask

// 特定时间点的状态验证
initial begin
    // 等待复位释放
    @(negedge rst);
    
    // 状态1: 奇偶闪烁验证
    #1000000000; // 等待1秒
    check_state(0, 0, 16'b1010_1010_1010_1010, "状态1-奇数位亮");
    
    #1000000000; // 再等1秒
    check_state(1, 1, 16'b0000_0000_0000_0000, "状态1-全灭");
    
    // 状态2: 从右到左依次点亮验证
    #8000000000; // 等待8秒到达状态2开始
    check_state(8, 8, 16'b0000_0000_0000_0001, "状态2-LED0亮");
    
    #1000000000; // 再等1秒
    check_state(9, 9, 16'b0000_0000_0000_0011, "状态2-LED0-1亮");
    
    // 状态5: 从两边到中间验证 (跳过一些状态以节省仿真时间)
    #24000000000; // 等待24秒到达状态5开始
    check_state(48, 48, 16'b1000_0000_0000_0001, "状态5-LED15和LED0亮");
    
    #1000000000; // 再等1秒
    check_state(49, 49, 16'b1100_0000_0000_0011, "状态5-LED15-14和LED1-0亮");
    
    // 完成一个完整周期后停止仿真
    #32000000000; // 等待32秒完成整个周期
    $display("完成一个完整周期测试");
    $display("仿真结束时间: %t", $time);
    $finish;
end

// 超时保护
initial begin
    #70000000000; // 70秒超时
    $display("仿真超时!");
    $finish;
end

endmodule