module traffic_light(output bit green_light,    //one bit 
                            yellow_light,   //one bit 
                            red_light,      //one bit 
                    input clock, resetN);
    enum{R_BIT = 0,     //the index of the RED'S state register of the FSM
         G_BIT = 1,     // the index of the GREEN
         Y_BIT = 2,
         D_BIT = 3}state_bit;

    //将1移到表示每个状态的位上
    enum logic[3:0] {
                    RED     = 4'b0001<<R_BIT,
                    GREEN   = 4'b0001<<G_BIT,
                    YELLOW  = 4'b0001<<Y_BIT,
                    DEAD    = 4'b0001<<D_BIT //死锁状态
    }Cur_state=DEAD, Nxt_state=RED;
    logic[15:0] green_circle=30;        //绿灯30个周期时间
    logic[15:0] red_circle=30;          //红灯30个周期时间
    logic[15:0] yellow_circle=5;        //黄灯5个周期时间

    logic[15:0] downcnt;  //downcount of each color

    always_ff@(posedge clock, negedge resetN)begin: state_change
        if(!resetN) 
            Cur_state <= RED;    //reset as RED light
        else  
            Cur_state <= Nxt_state;
    end

    //which modify downcnt? always_comb

    always_ff@(posedge clock, negedge resetN) begin:set_next_state
        //Nxt_state = Cur_state;      //troublesome one
        unique case(1'b1)   //反向case语句
            Cur_state[R_BIT]: 
                if(!resetN) begin
                    downcnt <= red_circle;       //resetN 一直为0，不会被修改了。
                    Nxt_state <= RED;
                end

                else if(downcnt      == 1) begin 
                    Nxt_state <= GREEN;    //if next == cur 这边就不会被执行？？？
                    downcnt <= green_circle;
                end
                else
                    downcnt <= downcnt - 1;
                
                
            Cur_state[G_BIT]:
                if(downcnt    == 1) begin
                    Nxt_state <= YELLOW;
                    downcnt <= yellow_circle;
                end
                else
                    downcnt <= downcnt - 1;
               
            Cur_state[Y_BIT]:
                if(downcnt   == 1) begin
                    Nxt_state <= RED;
                    downcnt <= red_circle;
                end
                else
                    downcnt <= downcnt - 1;
                
            Cur_state[D_BIT]:
                downcnt = red_circle;
        endcase
    end

    always_comb begin:set_outputs
                {red_light, green_light, yellow_light} = 3'b000;
                unique case(1'b1)   //反向case
                    Cur_state[R_BIT]:       red_light       = 1'b1;
                    Cur_state[G_BIT]:       green_light     = 1'b1;
                    Cur_state[Y_BIT]:       yellow_light    = 1'b1;
                    Cur_state[D_BIT]:       ;           //do nothing
                endcase
    end

                
endmodule