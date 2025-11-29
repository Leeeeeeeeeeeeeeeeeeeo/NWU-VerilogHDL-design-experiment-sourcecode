module counter60 (
    input clk,
    input rst_n,
    output reg [5:0] count
);

always @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 'd0;
    end
    else if (count == 'd59) begin
        count <= 'd0;
    end
    else
        count <= count + 1;    
end

    
endmodule
