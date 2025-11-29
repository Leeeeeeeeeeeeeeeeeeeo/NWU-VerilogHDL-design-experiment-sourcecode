`timescale 1ns / 1ps

module test();
    reg Clk;
    reg R;
    reg S;
    reg Up_Down;
    reg [3:0] Load_Data;
    wire [3:0] Count;
    wire GS;
    wire GC;

    Dec_Add_Sub_CNTR uut (
        .Clk(Clk),
        .R(R),
        .S(S),
        .Up_Down(Up_Down),
        .Load_Data(Load_Data),
        .Count(Count),
        .GS(GS),
        .GC(GC)
    );

    // 时钟生成
    initial begin
        Clk = 0;
        forever #10 Clk = ~Clk;
    end

    initial begin
        // 初始化
        R = 0; S = 0; Up_Down = 1; Load_Data = 4'b0000;
        
        $display("Time\tR\tS\tUD\tLoad\tCount\tGS\tGC\t状态");
        $display("----------------------------------------------------------------");
        #15;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t初始", 
                 $time, R, S, Up_Down, Load_Data, Count, GS, GC);
        
        // 测试1: 异步复位
        $display("\n=== 测试1: 异步复位 ===");
        #5; R = 1;
        #15;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t复位有效", 
                 $time, R, S, Up_Down, Load_Data, Count, GS, GC);
        #5; R = 0;
        #15;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t复位解除", 
                 $time, R, S, Up_Down, Load_Data, Count, GS, GC);

        // 测试2: 同步置数有效数据
        $display("\n=== 测试2: 同步置数（有效数据5）===");
        #5; S = 1; Load_Data = 4'b0101;
        #15;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t置数前", 
                 $time, R, S, Up_Down, Load_Data, Count, GS, GC);
        @(posedge Clk);
        #5; S = 0;
        #15;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t置数后", 
                 $time, R, S, Up_Down, Load_Data, Count, GS, GC);

        // 测试3: 无效数据+加法模式
        $display("\n=== 测试3: 无效数据12+加法模式（应置0）===");
        #5; S = 1; Load_Data = 4'b1100; Up_Down = 1;
        #5;  // 缩短等待时间
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t置数信号设置后", 
                $time, R, S, Up_Down, Load_Data, Count, GS, GC);
        @(posedge Clk);
        #5; S = 0;
        #15;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t置数后", 
                $time, R, S, Up_Down, Load_Data, Count, GS, GC);

        // 测试4: 无效数据+减法模式  
        $display("\n=== 测试4: 无效数据12+减法模式（应置9）===");
        #5; S = 1; Load_Data = 4'b1100; Up_Down = 0;
        #15;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t置数前", 
                 $time, R, S, Up_Down, Load_Data, Count, GS, GC);
        @(posedge Clk);
        #5; S = 0;
        #15;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t置数后", 
                 $time, R, S, Up_Down, Load_Data, Count, GS, GC);

        $display("\n=== 仿真完成 ===");
        #100;
        $finish;
    end
endmodule