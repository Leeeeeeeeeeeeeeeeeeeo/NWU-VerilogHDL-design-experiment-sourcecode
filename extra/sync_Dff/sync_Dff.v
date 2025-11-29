module dff_rst_ld(clk,
                  reset,
                  load,
                  d,
                  q);
    input clk, d, reset, load;
    output q;
    reg q;
    always@ (posedge clk)
    begin
        if (reset == 1)
            q< = 0;
        else if (load == 1)
            q< = 1;
        else
            q< = d;
    end
endmodule
