`timescale 1ns / 1ps

module tb_seven_segment_display;

    // 输入信号
    reg clk_100m;
    
    // 输出信号
    wire CA, CB, CC, CD, CE, CF, CG;
    wire dp;
    wire AN0, AN1, AN2, AN3;
    
    // 实例化设计模块
    seven_segment_display uut (
        .clk_100m(clk_100m),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .dp(dp),
        .AN0(AN0),
        .AN1(AN1),
        .AN2(AN2),
        .AN3(AN3)
    );
    
    // 生成100MHz时钟信号
    always #5 clk_100m = ~clk_100m;
    
    initial begin
        clk_100m = 0;
        $display("=== Seven Segment Display Simulation Started ===");
        $display("Target Display: 7484");
        $display("Clock: 100MHz, Scan: 200Hz, Refresh: 50Hz");
        $display("AN3=7, AN2=4, AN1=8, AN0=4");
        $display("");
        
        // 运行30ms观察多个扫描周期
        #30000000;
        
        $display("");
        $display("=== Simulation Completed ===");
        $finish;
    end
    
    // 监控显示变化
    integer scan_count = 0;
    always @(posedge uut.clk_200hz) begin
        scan_count = scan_count + 1;
        $display("Scan #%0d at %t:", scan_count, $time);
        $display("  digit_sel = %0d", uut.digit_sel);
        $display("  AN = %b%b%b%b", AN3, AN2, AN1, AN0);
        $display("  SEG = %b%b%b%b%b%b%b", CA, CB, CC, CD, CE, CF, CG);
        $display("  current_digit = %0d", uut.current_digit);
        
        // 验证显示的数字
        case(uut.digit_sel)
            0: begin
                if (CA == 1'b0 && CB == 1'b0 && CC == 1'b0 && CD == 1'b1 && CE == 1'b1 && CF == 1'b1 && CG == 1'b1)
                    $display("  -> AN3 shows: 7 [CORRECT]");
                else
                    $display("  -> AN3 ERROR: expected 7 (0001111)");
            end
            1: begin
                if (CA == 1'b1 && CB == 1'b0 && CC == 1'b0 && CD == 1'b1 && CE == 1'b1 && CF == 1'b0 && CG == 1'b0)
                    $display("  -> AN2 shows: 4 [CORRECT]");
                else
                    $display("  -> AN2 ERROR: expected 4 (1001100)");
            end
            2: begin
                if (CA == 1'b0 && CB == 1'b0 && CC == 1'b0 && CD == 1'b0 && CE == 1'b0 && CF == 1'b0 && CG == 1'b0)
                    $display("  -> AN1 shows: 8 [CORRECT]");
                else
                    $display("  -> AN1 ERROR: expected 8 (0000000)");
            end
            3: begin
                if (CA == 1'b1 && CB == 1'b0 && CC == 1'b0 && CD == 1'b1 && CE == 1'b1 && CF == 1'b0 && CG == 1'b0)
                    $display("  -> AN0 shows: 4 [CORRECT]");
                else
                    $display("  -> AN0 ERROR: expected 4 (1001100)");
            end
        endcase
        $display("");
    end
    
    // 验证时序特性
    real last_scan_time = 0;
    real scan_period;
    always @(posedge uut.clk_200hz) begin
        if (last_scan_time > 0) begin
            scan_period = ($time - last_scan_time) / 1000000.0; // 转换为ms
            if (scan_count == 2) begin
                $display("=== Timing Verification ===");
                $display("Measured scan period: %0.3f ms (expected: 5ms)", scan_period);
                $display("Refresh rate: %0.1f Hz (expected: 50Hz)", 1000.0/(scan_period*4));
                $display("");
            end
        end
        last_scan_time = $time;
    end

endmodule