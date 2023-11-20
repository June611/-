module do_while();
    int done, OutOfBound,addr=130;
    logic [511:0]mem;
    logic out, outd;
	
    always_comb begin
        if(addr<128 || addr>255)begin
            done = 0;
            OutOfBound = 1;
            out = mem[128];
        end
        else while(addr >= 128 && addr<=255) begin
            if(addr==128)begin
                done = 1;
                OutOfBound=0;
            end
            else begin
                done = 0;
                OutOfBound=0;
            end
            out = mem[addr];
            addr -= 1;
        end
    end
	
	/*
    always_comb begin
        do begin
            done = 0;
            OutOfBound = 0;
            outd = mem[128];
            if(addr<128 || addr>255)
                OutOfBound=1;
            else if(addr == 128)
                done = 1;
            else outd = mem[addr];
            addr-=1;     
        end
        while(addr>=128 && addr<=255);
    end 
	*/
	/*
    always_comb begin
        if(addr<128 || addr>255)begin
            done = 1'b0;
            OutOfBound = 1'b1;
        end
        else begin
            done = 1'b1;
            OutOfBound = 1'b0;
        end
        out = mem[128];
    end
	*/

	initial begin
		mem = '1;
		//assign addr = 130;
		//addr = 128;
	end
endmodule