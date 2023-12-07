`ifndef ahb_def
    `define ahb_def
    package def;
        parameter max_dataw = 32;//data path width
        parameter endian = 1'b0;//small edian
        parameter mas_num = 2;
        parameter sla_num = 2;
        typedef enum logic {READ,WRITE} hwrite_t;
        typedef enum logic [2:0] {SINGLE,INCR,WRAP4,INCR4,WRAP8,INCR8,WRAP16,INCR16} hburst_t;
        typedef enum logic [1:0] {IDLE, BUSY, NONSEQ, SEQ} htrans_t;
        typedef enum logic [1:0] {OKAY, ERROR, RETRY, SPLIT} hresp_t;
        typedef enum logic [2:0] {BYTE,HWORD,WORD,DWORD,FWORD,EWORD,SWORD,TWORD} hsize_t;

        function automatic logic [5:0] calc_beat(hburst_t hburst_type);
            unique case(hburst_type)
                SINGLE       :calc_beat = 1;
                INCR         :calc_beat = 32;
                WRAP4,INCR4  :calc_beat = 4;
                WRAP8,INCR8  :calc_beat = 8;
                WRAP16,INCR16:calc_beat = 16;
            endcase
        endfunction

        function automatic int first1(
                input int addr
        );
        
            int j=0;
            if(addr==0)
                return 32;
            else for(;;)begin
              $display("addr=%d",addr);
                if(addr[0] !=1'b1)begin
                    addr>>=1;
                    j++;
                end
                else
                    return j;         
            end
        endfunction
endpackage
import def::*;
`endif
