`include "ahb_pkg.sv"
module master(interface pins);
    
    parameter mas_id = 0;
   
    htrans_t     htrans_ns;
    logic [3:0]  tran_masid;
    logic [3:0]  tran_masid_pre;
    logic        incr_last;
    logic [31:0] haddr_ini;
    hburst_t     burst_ini;
    hsize_t      hsize_ini;
    logic [1:0]  hlock_ini;

    logic        hwvalid;
    logic        hrvalid;

    logic [5:0]  beat;
    logic        tran_conti;
    logic [5:0]  cnt_hready;
    logic        hresp_error_con;
    logic [1:0]  hlock_res;

    logic [1:0]  habort;
    logic        abort_con;
    logic [5:0]  cnt_hready_res[1:0];
    hsize_t      hsize_res[1:0];
    logic [31:0] haddr_res[1:0];
 
    logic [7:0] Mem [0:2<<10-1];

    logic        tran_valid;

    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            tran_valid <=1'b0;
        else if(pins.hburst==INCR || pins.htrans==IDLE)
            tran_valid <=1'b0;
        else if(cnt_hready == beat-1)
            tran_valid <=1'b0;
        else
            tran_valid <=1'b1;
    end

    //always_comb tran_valid = ((cnt_hready>0) && cnt_hready <=beat);

    always_comb beat = calc_beat(pins.hburst);
// calculate the num of hready response
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            cnt_hready <='b0;
        else if(pins.hgrant==2'b00)
            cnt_hready <='b0;
        else if(cnt_hready==beat-1 && pins.hresp==OKAY && pins.hready)
            cnt_hready <= 'b0;
        else if(hlock_res[mas_id] && (pins.hresp inside {RETRY,SPLIT}))
            cnt_hready <= cnt_hready;
        else if(hlock_res[mas_id] && (pins.htrans inside {NONSEQ}))
            cnt_hready <= cnt_hready;
        else if(pins.hburst inside {SINGLE})
            cnt_hready <='b0;
        else if(pins.htrans==SEQ)begin
            if(pins.hready && pins.hresp==OKAY)
                cnt_hready <=cnt_hready+1;
        end
        else if(pins.htrans==BUSY)
            cnt_hready <= cnt_hready;
        else
            cnt_hready <='b0;
    end
// two cycle delay for error and split resp 
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            tran_conti <=1'b0;
        else if(pins.hresp inside {ERROR, SPLIT, RETRY})
            tran_conti <= ~tran_conti;
        else
            tran_conti <=1'b0;
    end

    always_comb begin
        if(pins.hgrant[0])
            tran_masid_pre = 0;
        else begin
            if((cnt_hready==0 && pins.hgrant!=2'b00) || (cnt_hready==beat-2 && pins.hready && pins.hresp==OKAY))begin
                if(pins.hgrant[1])
                    tran_masid_pre = 1;
                else
                    tran_masid_pre = 2;
            end
            else if(pins.hgrant==2'b00)
                tran_masid_pre=2;
        end
    end

    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            tran_masid <=2;
        else 
            tran_masid <=tran_masid_pre;
    end

    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            hlock_res<=2'b00;
        else if(cnt_hready ==beat-1 && pins.hresp==OKAY && pins.hready)
            hlock_res <=2'b00;
        else if(pins.htrans==IDLE && cnt_hready!=0 && (pins.hresp!=SPLIT) && pins.hresp!=RETRY)
            hlock_res<=2'b00;
        else if(hlock_res!=0)
            hlock_res<=hlock_res;
        else if(pins.hlock==2'b01)
            hlock_res<=2'b01;
        else if(pins.hlock==2'b10)
            hlock_res<=2'b10;
    end

// calc the addr 
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.haddr <=1<<13;
        else if(tran_masid_pre==mas_id)begin
            if(pins.hresp inside {RETRY,SPLIT} && hlock_res[mas_id])begin
                if(!tran_conti)begin
                    if(first1(beat<<pins.hburst)<=first1(pins.haddr))
                        pins.haddr <=pins.haddr-(1<<pins.hsize)+(beat<<pins.hsize);
                    else
                        pins.haddr <=pins.haddr-(1<<pins.hsize);
                end
                else
                    pins.haddr <= pins.haddr;
            end
            else if(pins.htrans == BUSY || (pins.hresp==SPLIT &&!tran_conti))
                pins.haddr <= pins.haddr;
            else if(pins.hready)begin
                if(pins.hresp==RETRY)begin
                    if(pins.htrans==IDLE)
                        pins.haddr <=haddr_ini;
                    else if(!tran_conti)
                        pins.haddr <=pins.haddr;
                    else if(first1(beat<<pins.hburst)<=first1(pins.haddr))
                        pins.haddr <=pins.haddr-((1<<pins.hsize)+(beat<<pins.hsize));
                    else
                        pins.haddr <=pins.haddr-(1<<pins.hsize);
                end
                else if(pins.htrans inside {IDLE} || pins.hburst==SINGLE)
                    pins.haddr <=haddr_ini;
                else if(pins.hburst==INCR)
                    pins.haddr <=pins.haddr +(1<<pins.hsize);
                else begin
                    if(pins.hburst inside{INCR4,INCR8,INCR16})begin
                        if(cnt_hready==beat-1 && pins.hresp==OKAY)
                            pins.haddr <= haddr_ini;
                        else
                            pins.haddr <= pins.haddr+(1<<pins.hsize);
                    end
                    else if(first1((beat<<pins.hsize))<=first1((pins.haddr+(1<<pins.hsize))))begin
                        pins.haddr <=pins.haddr+(1<<pins.hsize)-(beat<<pins.hsize);
                    end
                    else
                        pins.haddr <=pins.haddr+(1<<pins.hsize);
                end
            end
        end
        else if(pins.hgrant==2'b00)
            pins.haddr <= 'b0;
    end

// htrans gen using state machine
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.htrans <=IDLE;
        else if(tran_masid_pre==2)
            pins.htrans <= IDLE;
        else if(tran_masid_pre==mas_id)
            pins.htrans <=htrans_ns;
    end

    always_comb begin
        htrans_ns = IDLE;
        if(tran_masid_pre==mas_id)begin
            if(pins.hresp inside{RETRY,SPLIT,ERROR} && !tran_conti)begin
                if(pins.hresp==ERROR && hresp_error_con)
                    htrans_ns = SEQ;
                else
                    htrans_ns = IDLE;
            end
            else begin
                if((!hrvalid && pins.hwrite==READ) || (!hwvalid && pins.hwrite==WRITE))
                    htrans_ns = BUSY;
                else unique case(pins.htrans)
                    IDLE:if(pins.hready)
                        htrans_ns = NONSEQ;
                    NONSEQ:if(pins.hready)
                        htrans_ns = SEQ;
                    else
                        htrans_ns = NONSEQ;
                    SEQ:begin
                        if(hlock_res[mas_id] && pins.hresp==OKAY && pins.hready && cnt_hready==beat-2)
                            htrans_ns = SEQ;
                        else if(hlock_res[mas_id] && pins.hresp==OKAY && pins.hready && cnt_hready==beat-1)
                            htrans_ns = IDLE;
                        else if(pins.hburst==SINGLE)begin
                            if(pins.hready && pins.hresp==OKAY)
                                htrans_ns = IDLE;
                            else
                                htrans_ns = SEQ;
                        end
                        else if(pins.hburst==INCR)begin
                            if(incr_last && pins.hready && pins.hresp==OKAY)
                                htrans_ns = IDLE;
                            else
                                htrans_ns = SEQ;
                        end
                        else if(cnt_hready==beat-2 && pins.hready && pins.hresp==OKAY)
                            htrans_ns = NONSEQ;
                        else
                            htrans_ns = SEQ;
                    end
                    BUSY:htrans_ns = SEQ;
                endcase
            end
        end
    end
    
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.hwdata <= 'b0;
        else if(tran_masid_pre==mas_id)
            if(pins.hwrite==WRITE && pins.htrans inside {NONSEQ,SEQ})case(endian)
                1'b1:case(pins.hsize)
                    3'b000:unique case(pins.haddr[1:0])
                        2'b00:pins.hwdata={24'b0,Mem[pins.haddr]};
                        2'b01:pins.hwdata={16'b0,Mem[pins.haddr],8'b0};
                        2'b10:pins.hwdata={8'b0, Mem[pins.haddr],16'b0};
                        2'b11:pins.hwdata={Mem[pins.haddr],24'b0};
                    endcase
                    3'b001:unique case(pins.haddr[1])
                        1'b0:pins.hwdata ={16'b0,Mem[pins.haddr+1],Mem[pins.haddr]};
                        1'b1:pins.hwdata ={Mem[pins.haddr+1],Mem[pins.haddr],16'b0};
                    endcase
                    3'b010:pins.hwdata={Mem[pins.haddr+3],Mem[pins.haddr+2],Mem[pins.haddr+1],Mem[pins.haddr]};
                    default:;
                endcase
                1'b0:case(pins.hsize)
                    3'b000:unique case(pins.haddr[1:0])
                        2'b00:pins.hwdata={Mem[pins.haddr],24'b0};
                        2'b01:pins.hwdata={8'b0, Mem[pins.haddr],16'b0};
                        2'b10:pins.hwdata={16'b0,Mem[pins.haddr],8'b0};
                        2'b11:pins.hwdata={24'b0,Mem[pins.haddr]};
                    endcase
                    3'b001:unique case(pins.haddr[1])
                        1'b0:pins.hwdata ={Mem[pins.haddr+1],Mem[pins.haddr],16'b0};
                        1'b1:pins.hwdata ={16'b0,Mem[pins.haddr+1],Mem[pins.haddr]};
                    endcase
                    3'b010:pins.hwdata={Mem[pins.haddr],Mem[pins.haddr+1],Mem[pins.haddr+2],Mem[pins.haddr+3]};
                    default:;
                endcase
            endcase
    end

    // for the advanced burst abort 
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            habort <=2'b00;
        else if(tran_masid==mas_id && pins.hresp==SPLIT)
            habort <=(1<<mas_id) | habort;
        else begin
            if(mas_id==0)
                habort <= {habort[1],1'b0};
            else if(mas_id==1)
                habort <= {1'b0,habort[0]};
            else
                habort <=2'b00;
        end
    end

    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            abort_con <= 1'b0;
        else if(cnt_hready==beat)
            abort_con <= 1'b0;
        else if(habort[mas_id])
            abort_con <= 1'b1;
    end
    /*
    always_comb begin
        if(tran_masid==mas_id && pins.hresp==SPLIT)
            habort = (1<<mas_id) | habort;
        else if(pins.hgrant==2'b01)
            habort &= 2'b10;
        else if(pins.hgrant==2'b10)
            habort &= 2'b01;
    end
*/
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.hburst <=WRAP4;
        else if(pins.hlock[mas_id])
            pins.hburst <= burst_ini;
        else if(pins.hgrant==2'b00 || (pins.hresp==SPLIT && !tran_conti))
            pins.hburst <=SINGLE;
        else if(pins.htrans==IDLE && pins.hgrant[mas_id])begin
            if(habort[mas_id])
                pins.hburst <=INCR;
            else
                pins.hburst <=burst_ini;
        end
    end
    
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            haddr_res[mas_id] <= 'b0;
        else if(pins.hresp==SPLIT && !tran_conti)begin
            if(first1(beat<<pins.hburst)<=first1(pins.haddr))
                haddr_res[mas_id] <=pins.haddr-((1<<pins.hsize)+(beat<<pins.hsize));
            else
                haddr_res[mas_id] <=pins.haddr-(1<<pins.hsize);;
        end
    end

    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            cnt_hready_res[mas_id]<='b0;
        else if(pins.hresp==SPLIT &&!tran_conti)
            cnt_hready_res[mas_id]<=cnt_hready;
    end
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            hsize_res[mas_id] <= BYTE;
        else if(habort[mas_id])
            hsize_res[mas_id] <= pins.hsize;
    end

    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.hsize <=BYTE;
        else if(mas_id==tran_masid_pre)
            pins.hsize <=hsize_ini;
    end
/*
   always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.hlock <=2'b00;
        else if(tran_masid_pre==mas_id)begin
            if(cnt_hready==beat-2 && pins.hready && pins.hresp==OKAY)
                pins.hlock <=2'b0;
            else 
                pins.hlock <=hlock_ini;
        end
    end
*/
    // for the test vector gen
    logic [10:0] a;
    /*
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.hbusreq<=2'b00;
        else
            pins.hbusreq<=2'b11;
    end
*/
    initial begin
        $readmemh("mas_mem.txt",Mem);
        hresp_error_con =1'b0;
        hwvalid=1'b1;
        hrvalid=1'b1;
        pins.hprot ='b0;
        incr_last = 1'b0;
        burst_ini=WRAP4;
       // pins.hbusreq=2'b11;
        haddr_ini = 2<<11;
        //pins.hlock=0;
        pins.hwrite=READ;
        //pins.hsize=3'b010;
        hsize_ini = HWORD;
        pins.hbusreq=2'b11;
        pins.hlock = 2'b00;
       // #15
        //pins.hlock = 2'b10;
       // pins.hbusreq = 2'b10;
        #25 pins.hbusreq = 2'b10;
         //   pins.hlock=2'b01;
     hrvalid = 1'b0;
        #20 hrvalid = 1'b1;
    end
    endmodule  
