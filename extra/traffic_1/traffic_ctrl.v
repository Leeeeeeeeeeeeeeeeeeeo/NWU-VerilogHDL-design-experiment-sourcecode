module traffic_ctrl(
    input clk,
    input en,
    input hold,
    output reg [3:0] lampa,
    output reg [3:0] lampb,
    output [7:0] acount,
    output [7:0] bcount
);

    // 交通灯状态定义
    parameter RED    = 4'b0001;
    parameter YELLOW = 4'b0010; 
    parameter GREEN  = 4'b0100;
    parameter LEFT   = 4'b1000;
    
    // 计时参数
    reg [7:0] agreen  = 40;
    reg [7:0] ayellow = 5;
    reg [7:0] aleft   = 20;
    reg [7:0] ared    = 55;
    
    reg [7:0] bgreen  = 25;
    reg [7:0] byellow = 5;
    reg [7:0] bleft   = 10;
    reg [7:0] bred    = 80;

    reg [2:0] counta, countb;
    reg tempa, tempb;
    reg [7:0] numa, numb;

    // 初始化参数（当en为低时）
    always@(negedge en) begin
        ared    <= 55;   // 红灯55秒
        ayellow <= 5;    // 黄灯5秒
        agreen  <= 40;   // 绿灯40秒
        aleft   <= 20;   // 左转20秒
        
        bred    <= 80;   // 红灯80秒
        byellow <= 5;    // 黄灯5秒
        bgreen  <= 25;   // 绿灯25秒
        bleft   <= 10;   // 左转10秒
    end

    // A方向状态机
    always@(posedge clk or posedge hold) begin
        if (hold) begin
            lampa <= RED;
        end else if (en) begin
            if (!tempa) begin
                tempa <= 1;
                case(counta)
                    0: begin numa <= agreen;  lampa <= GREEN;  counta <= 1; end
                    1: begin numa <= ayellow; lampa <= YELLOW; counta <= 2; end
                    2: begin numa <= aleft;   lampa <= LEFT;   counta <= 3; end
                    3: begin numa <= ayellow; lampa <= YELLOW; counta <= 4; end
                    4: begin numa <= ared;    lampa <= RED;    counta <= 5; end
                    5: begin numa <= ayellow; lampa <= YELLOW; counta <= 0; end
                    default: lampa <= RED;
                endcase
            end else begin
                if (numa > 1) begin
                    numa <= numa - 1;
                end
                if (numa == 2) begin
                    tempa <= 0;
                end
            end
        end else begin
            lampa <= RED;
            counta <= 0;
            tempa <= 0;
            numa <= 0;
        end
    end

    // B方向状态机
    always@(posedge clk or posedge hold) begin
        if (hold) begin
            lampb <= RED;
        end else if (en) begin
            if (!tempb) begin
                tempb <= 1;
                case(countb)
                    0: begin numb <= bred;    lampb <= RED;    countb <= 1; end
                    1: begin numb <= byellow; lampb <= YELLOW; countb <= 2; end
                    2: begin numb <= bgreen;  lampb <= GREEN;  countb <= 3; end
                    3: begin numb <= byellow; lampb <= YELLOW; countb <= 4; end
                    4: begin numb <= bleft;   lampb <= LEFT;   countb <= 5; end
                    5: begin numb <= byellow; lampb <= YELLOW; countb <= 0; end
                    default: lampb <= RED;
                endcase
            end else begin
                if (numb > 1) begin
                    numb <= numb - 1;
                end
                if (numb == 2) begin
                    tempb <= 0;
                end
            end
        end else begin
            lampb <= RED;
            countb <= 0;
            tempb <= 0;
            numb <= 0;
        end
    end

    assign acount = numa;
    assign bcount = numb;

endmodule