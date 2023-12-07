`include "ahb_pkg.sv"
module decode(interface pins);
    always_comb begin
        if(pins.haddr <(2<<10))
            pins.hsel = 2'b01;
        else if(pins.haddr>=2<<10 && pins.haddr<2<<11)
            pins.hsel = 2'b10;
        else
            pins.hsel = 2'b00;
    end

    always_ff @(posedge pins.clk)begin
        if(!pins.rstn)
            pins.hresp <=OKAY;
        else if(pins.hsel==2'b00)begin
            case(pins.htrans)
                IDLE,BUSY:pins.hresp <=OKAY;
                NONSEQ,SEQ:pins.hresp <=ERROR;
            endcase
        end
    end

endmodule
