module jj_count_4(d,
                  clk,
                  clr,
                  ld,
                  up down,
                  qout);
    input[3 :0]d;
    input clk,clr,ld;
    input up down;
    output[3 :0] qout;
    reg[3:0] cnt;
    assign qout = cnt;
    always @ (posedge clk)
    begin
        if (!clr)
            cnt <= 8'h00;
        else if (ld)
            cnt <= d;
        else if (up_down)
            cnt <= cnt+1;elsecnt <= cnt1;
    end
endmodule
