`include "ahb_pkg.sv"
module slave(interface pins);
    parameter sla_id = 0;
    logic [7:0] Mem [0 : 2<<10-1];

    enum  logic[1:0] {data_okay,data_split,data_retry,data_error} data_ins;
    hresp_t       resp_ns;
    logic         hresp_err_conti;
    logic         tran_conti;
    logic         hresp_split_conti;
    logic         data_valid;
    logic         hwdata_valid;
    hresp_t       hresp_ns;
    logic tt;
    logic         split_del;
    
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            hresp_err_conti <=1'b0;
        else if(data_error)
            hresp_err_conti <=1'b1;
    end

    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            tran_conti <=1'b0;
        else if(pins.hresp inside {ERROR,SPLIT,RETRY})
            tran_conti <= ~tran_conti;
        else
            tran_conti <=1'b0;
    end

    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.hresp <=OKAY;
        else if(pins.hsel[sla_id])
            pins.hresp <=hresp_ns;
    end

    always_comb begin
        hresp_ns = OKAY;
        unique case(pins.hresp)
            OKAY:unique case(data_ins)
                data_okay: hresp_ns=OKAY;
                data_error:hresp_ns=ERROR;
                data_split:hresp_ns =SPLIT;
                data_retry:hresp_ns = RETRY;
            endcase
            ERROR:if(!tran_conti)
                hresp_ns=ERROR;
            SPLIT:if(!tran_conti)
                hresp_ns=SPLIT;
            RETRY:if(!tran_conti)
                hresp_ns=RETRY;
        endcase
    end

    always_ff @(posedge pins.clk) begin
        if(!pins.rstn)
            pins.hsplit <=2'b00;
        else if(pins.hsel[sla_id])begin
            if(pins.hmastlock)
                pins.hsplit <=2'b00;
            else if(pins.hresp==SPLIT && !tran_conti)
                pins.hsplit<=pins.hsplit | (1<<pins.hmaster);
            else if(data_ins!=data_split)begin
                if(split_del)
                    pins.hsplit <= 2'b00;
                else
                    pins.hsplit<=2'b0 | pins.hsplit;
            end
        end
    end          
// read data--consider endian and hsize for 32-bits data width
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.hrdata <='b0;
        else if(pins.hsel[sla_id])begin
            if(!pins.hready)
                pins.hrdata = 'b0;
            else if(pins.hwrite==READ && pins.htrans inside {NONSEQ,SEQ})case(endian)
                1'b1:case(pins.hsize)
                    3'b000:unique case(pins.haddr[1:0])
                        2'b00:pins.hrdata={24'b0,Mem[pins.haddr]};
                        2'b01:pins.hrdata={16'b0,Mem[pins.haddr],8'b0};
                        2'b10:pins.hrdata={8'b0, Mem[pins.haddr],16'b0};
                        2'b11:pins.hrdata={Mem[pins.haddr],24'b0};
                    endcase
                    3'b001:unique case(pins.haddr[1])
                        1'b0:pins.hrdata ={16'b0,Mem[pins.haddr+1],Mem[pins.haddr]};
                        1'b1:pins.hrdata ={Mem[pins.haddr+1],Mem[pins.haddr],16'b0};
                    endcase
                    3'b010:pins.hrdata={Mem[pins.haddr+3],Mem[pins.haddr+2],Mem[pins.haddr+1],Mem[pins.haddr]};
                    default:;
                endcase
                1'b0:case(pins.hsize)
                    3'b000:unique case(pins.haddr[1:0])
                        2'b00:pins.hrdata={Mem[pins.haddr],24'b0};
                        2'b01:pins.hrdata={8'b0, Mem[pins.haddr],16'b0};
                        2'b10:pins.hrdata={16'b0,Mem[pins.haddr],8'b0};
                        2'b11:pins.hrdata={24'b0,Mem[pins.haddr]};
                    endcase
                    3'b001:unique case(pins.haddr[1])
                        1'b0:pins.hrdata ={Mem[pins.haddr+1],Mem[pins.haddr],16'b0};
                        1'b1:pins.hrdata ={16'b0,Mem[pins.haddr+1],Mem[pins.haddr]};
                    endcase
                    3'b010:pins.hrdata={Mem[pins.haddr],Mem[pins.haddr+1],Mem[pins.haddr+2],Mem[pins.haddr+3]};
                    default:;
                endcase
            endcase
            else
                pins.hrdata <='b0;
        end
    end
    
  // write data--consider endian hsize for 32-bits data width
    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            hwdata_valid <= 1'b0;
        else if(pins.hwrite==WRITE && pins.htrans inside {NONSEQ, SEQ})
            hwdata_valid <= 1'b1;
        else 
            hwdata_valid <= 1'b0;
    end

    always_comb begin
        if(hwdata_valid)begin
            case(endian)
                1'b1:case(pins.hsize)
                    3'b000:begin
                        case(pins.haddr[1:0])
                            2'b00:Mem[pins.haddr] = pins.hwdata[7:0];
                            2'b01:Mem[pins.haddr] = pins.hwdata[15:8];
                            2'b10:Mem[pins.haddr] = pins.hwdata[23:16];
                            2'b11:Mem[pins.haddr] = pins.hwdata[31:24];
                        endcase
                    end
                    3'b001:begin
                        if(!pins.haddr[1])begin 
                            Mem[pins.haddr]   = pins.hwdata[7:0];
                            Mem[pins.haddr+1] = pins.hwdata[15:8];
                        end
                        else begin
                            Mem[pins.haddr]  = pins.hwdata[23:15];
                            Mem[pins.haddr+1]= pins.hwdata[31:16];
                        end
                    end
                    3'b010:begin
                        Mem[pins.haddr+0] = pins.hwdata[7:0];
                        Mem[pins.haddr+1] = pins.hwdata[15:8];
                        Mem[pins.haddr+2] = pins.hwdata[23:16];
                        Mem[pins.haddr+3] = pins.hwdata[31:24];
                    end
                    default:;
                endcase
                1'b0:case(pins.hsize)
                    3'b000:begin
                        case(pins.haddr[1:0])
                            2'b00:Mem[pins.haddr] = pins.hwdata[31:24];
                            2'b01:Mem[pins.haddr] = pins.hwdata[23:16];
                            2'b10:Mem[pins.haddr] = pins.hwdata[15:8];
                            2'b11:Mem[pins.haddr] = pins.hwdata[7:0];
                        endcase
                    end
                    3'b001:begin
                        if(!pins.haddr[1])begin 
                            Mem[pins.haddr+0]  = pins.hwdata[23:15];
                            Mem[pins.haddr+1]= pins.hwdata[31:16];
                        end
                        else begin
                            Mem[pins.haddr+0]   = pins.hwdata[7:0];
                            Mem[pins.haddr+1] = pins.hwdata[15:8];
                        end
                    end
                    3'b010:begin
                        Mem[pins.haddr+3] = pins.hwdata[7:0];
                        Mem[pins.haddr+2] = pins.hwdata[15:8];
                        Mem[pins.haddr+1] = pins.hwdata[23:16];
                        Mem[pins.haddr+0] = pins.hwdata[31:24];
                    end
                    default:;
                endcase
            endcase
        end
    end
                              
    always_ff @(posedge pins.clk) begin
        if(!pins.rstn)
            pins.hready <=1'b1;
        else if(pins.hsel[sla_id])
            pins.hready <= data_valid;
    end


// test vector generation
    initial begin
        $readmemh("sla_mem.txt",Mem);
        //pins.hsplit =2'b01;
        data_valid = 1'b1;
        #35 data_ins = data_okay;
        #10 data_ins = data_okay;
        split_del = 1'b0;
        #30 data_valid =1'b0;
        #10 data_valid =1'b1;
        #30   data_ins = data_okay;
        //data_error ='b0;
    end
endmodule
