module traffic2_2(input wire clk,
                  input wire clr,
                  output reg [5:0]lights,
                  output reg [3:0]counter);
    
    reg[1:0] pstate,nstate;
    reg [4:0]count;
    parameter s0   = 2'b00,s1   = 2'b01,s2   = 2'b10,s3   = 2'b11;
    parameter sec9 = 8,sec3 = 2;
    always @(posedge clk or posedge clr)
    begin
        if (clr == 1)
        begin
            //state <= s0;
            pstate  <= s0;
            count   <= 0;
        end
        
        else
        begin
        if (pstate == s0 | pstate == s2)
            if (count)						count <= count+1;
        else
        begin
            pstate <= nstate;
            count  <= 0;
        end
        else if (pstate == s1 | pstate == s3)
        if (count)						count <= count+1;
        else
        begin
        pstate <= nstate;
        count  <= 0;
    end
    end
    end
    
    //C1
    always@(*)
    begin
        case(pstate)
            s0:	nstate = s1;
            s1:	nstate = s2;
            s2:	nstate = s3;
            s3:	nstate = s0;
            default nstate <= s0;
        endcase
    end
    //C2
    always @(*)
    begin
        case (pstate)
        s0: begin lights = 6'b100001;counter = sec9-count;end
    s1: begin lights = 6'b100010;counter = sec3-count;end
s2: begin lights = 6'b001100;counter = sec9-count;end
s3: begin lights = 6'b010100;counter = sec3-count;end
default begin lights = 6'b100001;counter = sec9-count;end
        endcase
    end
    
endmodule
