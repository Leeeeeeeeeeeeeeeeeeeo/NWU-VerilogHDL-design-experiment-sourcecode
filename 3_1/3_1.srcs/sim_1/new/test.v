`timescale 1ns / 1ps

module test();
    // 输入信号定义为reg类型
    reg S;
    reg R;
    reg D;
    reg CP;
    // 输出信号定义为wire类型
    wire Q;
    wire Q_n;

    // 实例化待测试模块
    Dff uut (
        .S(S),
        .R(R),
        .D(D),
        .CP(CP),
        .Q(Q),
        .Q_n(Q_n)
    );

    // 生成时钟信号，周期20ns (频率50MHz)
    initial begin
        CP = 0;
        forever #10 CP = ~CP; // 每10ns翻转一次
    end

    // 测试激励
    initial begin
        // 打印表头
        $display("Time\tS\tR\tD\tCP\tQ\tQ_n");
        $display("-----------------------------------------------------");
        
        // 初始化输入信号
        S = 0; R = 0; D = 0;
        #20; // 等待一个时钟周期
        
        // 打印初始状态
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);
        
        // 测试用例1: 异步复位 (高电平有效)
        $display("\n=== 测试1: 异步复位 ===");
        R = 1; // 激活复位
        #20;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);
        R = 0; // 解除复位
        #20;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);

        // 测试用例2: 同步置位 (在时钟上升沿置位)
        $display("\n=== 测试2: 同步置位 ===");
        S = 1; // 激活置位
        #5; // 在时钟上升沿之前
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);
        @(posedge CP); // 等待下一个时钟上升沿
        #5; // 等待一段时间观察输出
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);
        S = 0; // 关闭置位
        #20;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);

        // 测试用例3: 正常数据锁存 (在时钟上升沿将D的值传递给Q)
        $display("\n=== 测试3: 正常数据锁存 ===");
        D = 1; // 准备数据1
        #5; // 在时钟上升沿之前
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);
        @(posedge CP); // 等待时钟上升沿，Q应变为1
        #5; // 等待一段时间观察输出
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);
        D = 0; // 准备数据0
        #5; // 在时钟上升沿之前
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);
        @(posedge CP); // 等待时钟上升沿，Q应变为0
        #5; // 等待一段时间观察输出
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);

        // 测试用例4: 复位和置位同时有效 (复位优先级高)
        $display("\n=== 测试4: 复位和置位同时有效 ===");
        R = 1;
        S = 1;
        D = 1;
        #20;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);
        R = 0;
        S = 0;
        #20;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, S, R, D, CP, Q, Q_n);

        $display("\n=== 仿真完成 ===");
        $finish; // 结束仿真
    end

endmodule