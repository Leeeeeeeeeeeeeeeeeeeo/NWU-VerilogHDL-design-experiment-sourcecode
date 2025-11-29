`timescale 1ns / 1ps

module test;
    // 输入
    reg [1:0] A;
    reg [1:0] B;
    reg RST;
    
    // 输出
    wire AGTB;
    wire AEQB;
    wire ALTB;
    
    // 实例化被测试单元
    comparator uut (
        .A(A),
        .B(B),
        .RST(RST),
        .AGTB(AGTB),
        .AEQB(AEQB),
        .ALTB(ALTB)
    );
    
    integer i, j;
    
    initial begin
        // 初始化监控
        $display("Time\tRST\tA\tB\tAGTB\tAEQB\tALTB");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, RST, A, B, AGTB, AEQB, ALTB);
        
        // 测试1: 使能无效时的所有输入情况
        $display("\n=== 测试1: 使能无效 ===");
        RST = 0;
        for(i = 0; i < 4; i = i + 1) begin
            for(j = 0; j < 4; j = j + 1) begin
                A = i;
                B = j;
                #20;
            end
        end
        
        // 测试2: 使能有效，全面测试所有A、B组合
        $display("\n=== 测试2: 全面比较测试 ===");
        RST = 1;
        for(i = 0; i < 4; i = i + 1) begin
            for(j = 0; j < 4; j = j + 1) begin
                A = i;
                B = j;
                #20;
            end
        end
        
        // 测试3: 边界情况和特殊值
        $display("\n=== 测试3: 边界情况 ===");
        // 最大值比较
        A = 2'b11;
        B = 2'b11;
        #20;
        A = 2'b11;
        B = 2'b10;
        #20;
        // 最小值比较
        A = 2'b00;
        B = 2'b00;
        #20;
        A = 2'b00;
        B = 2'b01;
        #20;
        
        $display("\n=== 仿真完成 ===");
        $finish;
    end
    
endmodule