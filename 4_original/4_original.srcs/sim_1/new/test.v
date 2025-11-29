`timescale 1ns / 1ps

module tb_vending_machine;

    // 输入信号
    reg clk;
    reg rstn;
    reg [1:0] coin;
    
    // 输出信号
    wire sell;
    wire change;
    
    // 实例化被测试的设计
    vending_machine dut (
        .clk(clk),
        .rstn(rstn),
        .coin(coin),
        .sell(sell),
        .change(change)
    );
    
    // 为了方便观察状态，我们将内部信号引出
    wire [1:0] current_state = dut.current_state;
    
    // 状态名称定义，用于显示
    reg [39:0] state_name;
    always @(current_state) begin
        case (current_state)
            2'b00: state_name = "IDLE";
            2'b01: state_name = "GET05";
            2'b10: state_name = "GET10";
            2'b11: state_name = "GET15";
            default: state_name = "UNKNOWN";
        endcase
    end
    
    // 时钟生成：100MHz时钟，周期10ns
    always #5 clk = ~clk;
    
    // 获取当前操作的描述
    reg [79:0] description;
    always @(*) begin
        case (coin)
            2'b01: description = "投入0.5元";
            2'b10: description = "投入1元";
            2'b11: description = "无效投币";
            default: begin
                if (sell && change) 
                    description = "出货并找零0.5元";
                else if (sell) 
                    description = "出货完成";
                else 
                    description = "等待投币";
            end
        endcase
    end
    
    // 实时显示状态变化
    always @(posedge clk) begin
        if (rstn) begin
            $display("%t\t%s\t%b\t%b\t%b\t%s", 
                    $time, state_name, coin, sell, change, description);
        end else begin
            $display("%t\t复位状态\t-\t-\t-\t系统复位", $time);
        end
    end
    
    // 测试序列
    initial begin
        // 初始化信号
        clk = 0;
        rstn = 0;
        coin = 2'b00;
        
        // 生成VCD文件用于波形分析
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, tb_vending_machine);
        
        $display("开始自动售卖机仿真测试");
        $display("时间\t状态\t\t投币\t出货\t找零\t描述");
        $display("==================================================================");
        
        // 测试1: 复位和初始状态测试
        $display("\n--- 测试1: 复位功能测试 ---");
        #10;
        rstn = 0;
        #20;
        rstn = 1;
        #20;
        
        // 测试2: 0.5元 * 4 -> 完成购买
        $display("\n--- 测试2: 0.5元 * 4 -> 完成购买 ---");
        coin = 2'b01; // 投0.5元
        #10;
        coin = 2'b01; // 投0.5元，累计1元
        #10;
        coin = 2'b01; // 投0.5元，累计1.5元
        #10;
        coin = 2'b01; // 投0.5元，累计2元，完成购买
        #10;
        coin = 2'b00; // 无投币
        #20;
        
        // 测试3: 1元 * 2 -> 完成购买
        $display("\n--- 测试3: 1元 * 2 -> 完成购买 ---");
        coin = 2'b10; // 投1元
        #10;
        coin = 2'b10; // 投1元，累计2元，完成购买
        #10;
        coin = 2'b00; // 无投币
        #20;
        
        // 测试4: 1元 + 0.5元 + 0.5元 -> 完成购买
        $display("\n--- 测试4: 1元 + 0.5元 + 0.5元 -> 完成购买 ---");
        coin = 2'b10; // 投1元
        #10;
        coin = 2'b01; // 投0.5元，累计1.5元
        #10;
        coin = 2'b01; // 投0.5元，累计2元，完成购买
        #10;
        coin = 2'b00; // 无投币
        #20;
        
        // 测试5: 1元 + 0.5元 + 1元 -> 完成购买并找零
        $display("\n--- 测试5: 1元 + 0.5元 + 1元 -> 完成购买并找零 ---");
        coin = 2'b10; // 投1元
        #10;
        coin = 2'b01; // 投0.5元，累计1.5元
        #10;
        coin = 2'b10; // 投1元，累计2.5元，完成购买并找零
        #10;
        coin = 2'b00; // 无投币
        #20;
        
        // 测试6: 0.5元 + 1元 -> 0.5元 -> 完成购买
        $display("\n--- 测试6: 0.5元 + 1元 + 0.5元 -> 完成购买 ---");
        coin = 2'b01; // 投0.5元
        #10;
        coin = 2'b10; // 投1元，累计1.5元
        #10;
        coin = 2'b01; // 投0.5元，累计2元，完成购买
        #10;
        coin = 2'b00; // 无投币
        #20;
        
        // 测试7: 无效投币测试
        $display("\n--- 测试7: 无效投币测试 ---");
        coin = 2'b11; // 无效投币
        #10;
        coin = 2'b00; // 无投币
        #10;
        coin = 2'b01; // 有效投币
        #10;
        coin = 2'b00; // 无投币
        #10;
        
        // 测试8: 复位后重新开始测试
        $display("\n--- 测试8: 复位后重新开始测试 ---");
        rstn = 0;
        #20;
        rstn = 1;
        #10;
        coin = 2'b10; // 投1元
        #10;
        coin = 2'b00; // 无投币
        #10;
        
        $display("\n==================================================================");
        $display("仿真测试完成");
        $finish;
    end

endmodule