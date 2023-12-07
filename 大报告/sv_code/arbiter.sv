`include "ahb_pkg.sv"
module arbiter(interface pins);
    logic [4:0] beat;
    logic       en_cnt_hready;
    logic [4:0] cnt_hready;
    logic       grant_done;
    logic [1:0] split_mark;
    logic       tran_conti;

   // always_comb pins.hmastlock = pins.hlock !=2'b00;
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.hmastlock <=1'b0;
        else if(pins.hmastlock)begin
            if(cnt_hready==beat-1 && pins.hresp==OKAY && pins.hready)
                pins.hmastlock <=1'b0;
        end
        else if(pins.hlock !=2'b00)
            pins.hmastlock <=1'b1;
    end

    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            tran_conti <=1'b0;
        else if(pins.hresp inside {ERROR,SPLIT,RETRY})
            tran_conti <= ~tran_conti;
        else
            tran_conti <=1'b0;
    end
 
    always_comb begin
        if(pins.hmastlock)
            pins.hgrant = pins.hgrant;
        //pins.hgrant  = 2'b00;
        else if(pins.hlock[0])
            pins.hgrant = 2'b01;
        else if(pins.hlock[1])
            pins.hgrant = 2'b10;
        else unique case(pins.hsplit)
            2'b00:begin
                if(((cnt_hready==0) || (cnt_hready ==(beat-2)))
                || (pins.hburst inside {SINGLE,INCR} && pins.htrans==IDLE )
                || pins.hresp==RETRY
                || (pins.hresp==ERROR && pins.htrans==IDLE))begin
                        $display("sddfsfd");
                        $display("beat=%d,cnt_hready=%d,time=%d",beat,cnt_hready,$time);
                    if(pins.hbusreq[0])begin
                        if((tran_conti && pins.hresp==RETRY) || (pins.hresp==ERROR && pins.htrans==IDLE))
                            pins.hgrant = 2'b01;
                        else if(pins.hmaster ==2)
                            pins.hgrant = 2'b01;
                        else if(pins.hmaster==0)
                            pins.hgrant = 2'b01;
                        else if(pins.hburst inside{SINGLE,INCR} && pins.htrans==IDLE)
                            pins.hgrant = 2'b01;
                    end
                    else if(pins.hbusreq[1])begin
                        if(cnt_hready==(beat-2))
                            pins.hgrant = 2'b10;
                        else if(pins.hmaster==2)
                            pins.hgrant = 2'b10;
                        else if(pins.hburst inside{SINGLE,INCR} && pins.htrans ==IDLE)
                            pins.hgrant = 2'b10;
                    end
                    else if(pins.hmaster==2)
                        pins.hgrant = 2'b00;
                end
            end
            2'b01:begin
                if(pins.hbusreq[1])
                    pins.hgrant = 2'b10;
                else
                    pins.hgrant = 2'b00;
            end
            2'b10:begin
                if(pins.hbusreq[0])
                    pins.hgrant = 2'b01;
                else
                    pins.hgrant = 2'b00;
            end
            2'b11:pins.hgrant = 2'b00;
        endcase     
    end

// hmaster signal generation
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.hmaster <= 2;
        else if(pins.hgrant[0])
            pins.hmaster <=0;
        else if(pins.hgrant[1])begin
            if((cnt_hready==0) || (cnt_hready==beat-2 && pins.hready && pins.hresp==OKAY))
                pins.hmaster<=1;
        end
        else 
            pins.hmaster<=2;
    end
// do not support incr trans for now
    always_comb beat = calc_beat(pins.hburst);
// start count the successful trans
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            cnt_hready <= 'b0;
        else if(cnt_hready==beat-1 && pins.hresp==OKAY && pins.hready)
            cnt_hready <= 'b0;
        else if(pins.hresp inside{RETRY,SPLIT})
            if(pins.hmastlock)
                cnt_hready <= cnt_hready;
            else
                cnt_hready <= 'b0;
        else if(pins.hready && pins.hresp==OKAY && pins.htrans==SEQ)
            cnt_hready <=cnt_hready+1;
    end
// signal show one trans completed
    assign grant_done = ((cnt_hready == beat-2) && (pins.htrans == IDLE));

endmodule
