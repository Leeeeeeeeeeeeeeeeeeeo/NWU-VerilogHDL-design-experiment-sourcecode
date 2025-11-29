`timescale 1ns / 1ps

// 定义操作指令
`define ADD     2'b00    // 求和
`define SUB     2'b01    // 相减
`define AND     2'b10    // 与运算
`define OR      2'b11    // 或运算

module alu(
    input [1:0] opcode,  // 操作指令
    input [1:0] a,       // 操作数a
    input [1:0] b,       // 操作数b
    output reg [2:0] out // 输出结果
);

always @(*) begin
    case (opcode)
        `ADD: out = a + b;           // 求和
        `SUB: out = a - b;           // 相减
        `AND: out = {1'b0, a & b};   // 与运算，扩展为3位
        `OR:  out = {1'b0, a | b};   // 或运算，扩展为3位
        default: out = 3'b000;       // 默认输出0
    endcase
end

endmodule