`timescale 1ns / 1ps

module comparator(
    input [1:0] A,
    input [1:0] B,
    input RST,
    output reg AGTB,
    output reg AEQB,
    output reg ALTB
);

always @(*) begin
    if (!RST) begin
        // 使能无效时，输出全0
        AGTB = 1'b0;
        AEQB = 1'b0;
        ALTB = 1'b0;
    end else begin
        // 使能有效时，进行比较
        if (A > B) begin
            AGTB = 1'b1;
            AEQB = 1'b0;
            ALTB = 1'b0;
        end else if (A == B) begin
            AGTB = 1'b0;
            AEQB = 1'b1;
            ALTB = 1'b0;
        end else begin
            AGTB = 1'b0;
            AEQB = 1'b0;
            ALTB = 1'b1;
        end
    end
end

endmodule