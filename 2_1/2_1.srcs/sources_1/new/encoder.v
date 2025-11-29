`timescale 1ns / 1ps

module encoder(
    input [7:0] I,
    input EN,
    output reg [2:0] Y,
    output reg GS,
    output reg GC
);

always @(*) begin
    if (!EN) begin
        // 使能无效时，输出全0
        Y = 3'b000;
        GS = 1'b0;
        GC = 1'b0;
    end else begin
        // 使能有效时，按优先级编码
        casex (I)
            8'b1xxxxxxx: begin Y = 3'b111; GS = 1'b1; GC = 1'b0; end  // I7最高优先级
            8'b01xxxxxx: begin Y = 3'b110; GS = 1'b1; GC = 1'b0; end  // I6
            8'b001xxxxx: begin Y = 3'b101; GS = 1'b1; GC = 1'b0; end  // I5
            8'b0001xxxx: begin Y = 3'b100; GS = 1'b1; GC = 1'b0; end  // I4
            8'b00001xxx: begin Y = 3'b011; GS = 1'b1; GC = 1'b0; end  // I3
            8'b000001xx: begin Y = 3'b010; GS = 1'b1; GC = 1'b0; end  // I2
            8'b0000001x: begin Y = 3'b001; GS = 1'b1; GC = 1'b0; end  // I1
            8'b00000001: begin Y = 3'b000; GS = 1'b1; GC = 1'b0; end  // I0
            8'b00000000: begin Y = 3'b000; GS = 1'b0; GC = 1'b1; end  // 无输入
            default:     begin Y = 3'b000; GS = 1'b0; GC = 1'b0; end
        endcase
    end
end

endmodule