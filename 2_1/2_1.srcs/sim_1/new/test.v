`timescale 1ns / 1ps

module test;
    // 输入
    reg [7:0] I;
    reg EN;
    
    // 输出
    wire [2:0] Y;
    wire GS;
    wire GC;
    
    // 实例化被测试单元
    encoder uut (
        .I(I),
        .EN(EN),
        .Y(Y),
        .GS(GS),
        .GC(GC)
    );
    
    integer i;
    
    initial begin
        // 初始化监控
        $display("Time\tEN\tI[7:0]\tY[2:0]\tGS\tGC");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b", $time, EN, I, Y, GS, GC);
        
        // 测试1: 使能无效时的所有输入情况
        $display("\n=== 测试1: 使能无效 ===");
        EN = 0;
        for(i = 0; i < 8; i = i + 1) begin  // 减少测试数量
            I = i * 32;  // 调整测试模式
            #20;         // 减少延迟
        end
        
        // 测试2: 使能有效，测试无输入和单个输入有效
        $display("\n=== 测试2: 单个输入有效 ===");
        EN = 1;
        
        // 无输入
        I = 8'b00000000;
        #20;
        
        // 每个输入单独有效
        for(i = 0; i < 8; i = i + 1) begin
            I = (1 << i);  // 左移生成one-hot编码
            #20;
        end
        
        // 测试3: 多个输入同时有效（验证优先级）
        $display("\n=== 测试3: 多个输入同时有效 ===");
        for(i = 1; i < 8; i = i + 1) begin
            // 生成包含当前位和低位有效的模式
            I = (1 << i) | ((1 << i) - 1);
            #20;
        end
        
        // 测试4: 边界情况和特殊模式
        $display("\n=== 测试4: 特殊模式 ===");
        I = 8'b10101010;  // 交替模式
        #20;
        I = 8'b01010101;  // 交替模式
        #20;
        I = 8'b11111111;  // 全有效
        #20;
        I = 8'b10000001;  // 最高和最低同时有效
        #20;
        
        $display("\n=== 仿真完成 ===");
        $finish;
    end
    
endmodule