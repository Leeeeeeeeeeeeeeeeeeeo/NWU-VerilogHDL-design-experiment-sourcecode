module traffic2 (
    input clk,
    input rst_n,
    output reg [2:0] light1, //[green, red, yellow] 
    output reg [2:0] light2, //[green, red, yellow] 
    output [5:0] count
);

    reg [2:0] state ;
    parameter Idle = 3'd0 ;
    parameter S1 = 3'd1 ;
    parameter S2 = 3'd2 ;
    parameter S3 = 3'd3 ;
    parameter S4 = 3'd4 ;

    always @(posedge clk or negedge rst_n) begin
        if ( !rst_n ) begin
            state <= Idle;
            light1 = 3'b010;
            light2 = 3'b010;
        end
    end

    always @(*) begin
        case (state)
            Idle: if ( !rst_n ) begin
                state <= S1;
                light1 = 3'b100;
                light2 = 3'b010;
            end
            S1: if (count == 'd25) begin
                state <= S2;
                light1 = 3'b001;
                light2 = 3'b010;
            end
            S2: if (count == 'd30) begin
                state <= S3;
                light1 = 3'b010;
                light2 = 3'b100;
            end
            S3: if (count == 'd55) begin
                state <= S4;
                light1 = 3'b010;
                light2 = 3'b001;
            end
            S4: if (count == 'd0) begin
                state <= S1;
                light1 = 3'b100;
                light2 = 3'b010;
            end
        endcase
    end

    counter60 counter1(
        .clk(clk),
        .rst_n(rst_n),
        .count(count)
    );

endmodule
