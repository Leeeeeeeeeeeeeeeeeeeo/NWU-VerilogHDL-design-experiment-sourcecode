`timescale 1ns / 1ps

module tb_key_debounce;

    // 输入信号
    reg clk;
    reg reset;
    reg [2:0] keys;
    
    // 输出信号
    wire [2:0] leds;
    
    // 实例化被测试模块
    key_debounce uut (
        .clk(clk),
        .reset(reset),
        .keys(keys),
        .leds(leds)
    );
    
    // 时钟生成 - 100MHz
    always #5 clk = ~clk;  // 10ns周期 = 100MHz
    
    // 测试任务：模拟按键抖动
    task key_bounce;
        input key_num;
        begin
            keys[key_num] = 1'b1;  // 初始状态（未按下）
            #100000;               // 等待100us
            
            // 模拟按键抖动过程
            keys[key_num] = 1'b0;  // 第一次按下
            #2000;                 // 抖动2us
            keys[key_num] = 1'b1;  // 弹起
            #3000;                 // 抖动3us
            keys[key_num] = 1'b0;  // 第二次按下
            #1500;                 // 抖动1.5us
            keys[key_num] = 1'b1;  // 弹起
            #2500;                 // 抖动2.5us
            keys[key_num] = 1'b0;  // 稳定按下
            
            // 保持按下状态一段时间
            #20000000;             // 保持20ms
            
            // 模拟释放抖动
            keys[key_num] = 1'b1;  // 释放
            #1800;                 // 抖动1.8us
            keys[key_num] = 1'b0;  // 误按下
            #2200;                 // 抖动2.2us
            keys[key_num] = 1'b1;  // 稳定释放
            
            #10000000;             // 等待10ms
        end
    endtask
    
    // 测试任务：模拟快速按键
    task key_quick_press;
        input key_num;
        begin
            keys[key_num] = 1'b1;  // 初始状态
            #5000000;              // 等待5ms
            
            // 快速按下并释放
            keys[key_num] = 1'b0;  // 按下
            #10000000;             // 保持10ms
            keys[key_num] = 1'b1;  // 释放
            
            #10000000;             // 等待10ms
        end
    endtask
    
    // 主测试流程
    initial begin
        // 初始化信号
        clk = 0;
        reset = 1;
        keys = 3'b111;  // 所有按键未按下
        
        // 生成VCD文件用于波形查看
        $dumpfile("key_debounce.vcd");
        $dumpvars(0, tb_key_debounce);
        
        // 测试1: 复位测试
        #100;           // 等待100ns
        reset = 0;      // 释放复位
        #1000000;       // 等待1ms
        
        $display("=== 测试1: 复位功能测试 ===");
        $display("时间: %t, LED状态: %b", $time, leds);
        
        // 测试2: BTND按键测试（带抖动）
        $display("=== 测试2: BTND按键抖动测试 ===");
        key_bounce(0);  // 测试按键0 (BTND)
        $display("时间: %t, LED状态: %b", $time, leds);
        
        // 测试3: BTNL按键测试（带抖动）
        $display("=== 测试3: BTNL按键抖动测试 ===");
        key_bounce(1);  // 测试按键1 (BTNL)
        $display("时间: %t, LED状态: %b", $time, leds);
        
        // 测试4: BTNU按键测试（带抖动）
        $display("=== 测试4: BTNU按键抖动测试 ===");
        key_bounce(2);  // 测试按键2 (BTNU)
        $display("时间: %t, LED状态: %b", $time, leds);
        
        // 测试5: 快速按键测试
        $display("=== 测试5: 快速按键测试 ===");
        key_quick_press(0);  // 快速按下BTND
        $display("时间: %t, LED状态: %b", $time, leds);
        
        // 测试6: 多个按键同时测试
        $display("=== 测试6: 多按键同时操作测试 ===");
        fork
            key_bounce(0);  // BTND
            key_quick_press(1); // BTNL
        join
        $display("时间: %t, LED状态: %b", $time, leds);
        
        // 测试7: 复位测试
        $display("=== 测试7: 运行时复位测试 ===");
        reset = 1;      // 触发复位
        #1000000;       // 等待1ms
        reset = 0;      // 释放复位
        $display("时间: %t, LED状态: %b", $time, leds);
        
        // 测试完成
        #1000000;
        $display("=== 所有测试完成 ===");
        $finish;
    end
    
    // 监控关键信号变化
    always @(leds) begin
        $display("时间: %t, LED状态发生变化: %b", $time, leds);
    end
    
    always @(keys) begin
        $display("时间: %t, 按键状态: %b", $time, keys);
    end
    
    // 测试超时保护
    initial begin
        #500000000;  // 500ms超时
        $display("测试超时!");
        $finish;
    end

endmodule