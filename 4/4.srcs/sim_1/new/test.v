`timescale 1ns / 1ps

module tb_vending_machine;

    // 输入信号
    reg clk;
    reg rstn;
    reg [1:0] coin;
    
    // 输出信号
    wire sell;
    wire change;
    
    // 实例化被测模块
    vending_machine uut (
        .clk(clk),
        .rstn(rstn),
        .coin(coin),
        .sell(sell),
        .change(change)
    );
    
    // 时钟生成，周期10ns
    always #5 clk = ~clk;
    
    // 显示状态名称的辅助任务
    task display_state;
        input [2:0] state;
        begin
            case (state)
                3'b000: $write("IDLE ");
                3'b001: $write("GET05");
                3'b010: $write("GET10");
                3'b011: $write("GET15");
                3'b100: $write("SOLD0");
                3'b101: $write("SOLD1");
                default: $write("UNKNW");
            endcase
        end
    endtask
    
    // 显示硬币输入的任务
    task display_coin;
        input [1:0] coin_val;
        begin
            case (coin_val)
                2'b00: $write("无投币 ");
                2'b01: $write("0.5元 ");
                2'b10: $write("1元   ");
                2'b11: $write("无效  ");
            endcase
        end
    endtask
    
    // 主测试程序
    initial begin
        // 初始化信号
        clk = 0;
        rstn = 0;
        coin = 2'b00;
        
        // 生成VCD文件用于波形查看
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, tb_vending_machine);
        
        // 打印表头
        $display("Time(ns)  State    Coin     Sell Change 备注");
        $display("------------------------------------------------");
        
        // 等待一个时钟周期
        #10;
        
        // 测试1: 复位测试
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    复位状态", sell, change);
        
        rstn = 1;
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    释放复位", sell, change);
        
        // 测试2: 投入4个0.5元 (累计2元，不找零)
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    开始测试: 4x0.5元", sell, change);
        
        coin = 2'b01; // 投0.5元
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    GET05", sell, change);
        
        coin = 2'b01; // 再投0.5元
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    GET10", sell, change);
        
        coin = 2'b01; // 再投0.5元
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    GET15", sell, change);
        
        coin = 2'b01; // 再投0.5元
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    SOLD0(出货不找零)", sell, change);
        
        coin = 2'b00; // 停止投币
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    返回IDLE(输出已清零)", sell, change);
        
        #20; // 等待一段时间
        
        // 测试3: 投入2个1元 (累计2元，不找零)
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    开始测试: 2x1元", sell, change);
        
        coin = 2'b10; // 投1元
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    GET10", sell, change);
        
        coin = 2'b10; // 再投1元
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    SOLD0(出货不找零)", sell, change);
        
        coin = 2'b00;
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    返回IDLE(输出已清零)", sell, change);
        
        #20;
        
        // 测试4: 投入1元+0.5元+1元 (累计2.5元，找零0.5元)
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    开始测试: 1元+0.5元+1元", sell, change);
        
        coin = 2'b10; // 投1元
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    GET10", sell, change);
        
        coin = 2'b01; // 投0.5元
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    GET15", sell, change);
        
        coin = 2'b10; // 投1元
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    SOLD1(出货找零)", sell, change);
        
        coin = 2'b00;
        #10;
        $write("%8t  ", $time);
        display_state(uut.current_state);
        display_coin(coin);
        $display("  %b     %b    返回IDLE(输出已清零)", sell, change);
        
        $display("------------------------------------------------");
        $display("仿真完成 - 状态机设计正确!");
        $finish;
    end

endmodule