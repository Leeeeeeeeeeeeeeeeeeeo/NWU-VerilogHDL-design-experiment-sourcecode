module dff_rst_ld1(clk,
                   reset,
                   load,
                   d,
                   q);
    input clk, d, reset, load;
    output q;
    reg q;
    always@(posedge clk or posedge reset or posedge load)
    begin
    if (reset == 1)
        q <= 0else
        if (load == 1)
            q <= 1;
        else
            q <= d;
    end
endmodule
