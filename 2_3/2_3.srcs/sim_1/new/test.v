`timescale 1ns / 1ps

module test;
    // 输入
    reg [1:0] opcode;
    reg [1:0] a;
    reg [1:0] b;
    
    // 输出
    wire [2:0] out;
    
    // 实例化被测试单元
    alu uut (
        .opcode(opcode),
        .a(a),
        .b(b),
        .out(out)
    );
    
    integer i, j;
    
    initial begin
        // 初始化监控
        $display("Time\topcode\ta\tb\tout");
        $monitor("%0t\t%b\t%b\t%b\t%b", $time, opcode, a, b, out);
        
        // 测试1: 加法运算 (opcode=00) - 减少测试用例
        $display("\n=== 测试1: 加法运算 ===");
        opcode = 2'b00;
        for(i = 0; i < 4; i = i + 2) begin  // 步长为2，减少测试数量
            for(j = 0; j < 4; j = j + 2) begin
                a = i;
                b = j;
                #10;
            end
        end
        
        // 测试2: 减法运算 (opcode=01) - 减少测试用例
        $display("\n=== 测试2: 减法运算 ===");
        opcode = 2'b01;
        for(i = 0; i < 4; i = i + 2) begin
            for(j = 0; j < 4; j = j + 2) begin
                a = i;
                b = j;
                #10;
            end
        end
        
        // 测试3: 与运算 (opcode=10) - 减少测试用例
        $display("\n=== 测试3: 与运算 ===");
        opcode = 2'b10;
        for(i = 0; i < 4; i = i + 2) begin
            for(j = 0; j < 4; j = j + 2) begin
                a = i;
                b = j;
                #10;
            end
        end
        
        // 测试4: 或运算 (opcode=11) - 减少测试用例
        $display("\n=== 测试4: 或运算 ===");
        opcode = 2'b11;
        for(i = 0; i < 4; i = i + 2) begin
            for(j = 0; j < 4; j = j + 2) begin
                a = i;
                b = j;
                #10;
            end
        end
        
        // 测试5: 关键边界情况
        $display("\n=== 测试5: 边界情况 ===");
        // 加法边界
        opcode = 2'b00; a = 2'b11; b = 2'b11; #10; // 3+3=6
        // 减法边界
        opcode = 2'b01; a = 2'b11; b = 2'b00; #10; // 3-0=3
        opcode = 2'b01; a = 2'b00; b = 2'b11; #10; // 0-3=-3
        // 逻辑运算边界
        opcode = 2'b10; a = 2'b11; b = 2'b11; #10; // 3&3=3
        opcode = 2'b11; a = 2'b11; b = 2'b11; #10; // 3|3=3
        
        $display("\n=== 仿真完成 ===");
        $finish;
    end
    
endmodule