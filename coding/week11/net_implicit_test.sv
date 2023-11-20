module net_test1(output  [63:0]q,
        output logic c,
        input [63:0]d,
        input clock, reset);
        wire[63:0] outp, inp;
        alias inp = d;      //infers inp is a 64-bit wire
        //alias outp = q;     //infers outp is a 64-bit wire
        alias rstN = reset; //infes 1-bit wire

        wire[63:0] data;
        wire[7:0] lo_byte, hi_byte;
        alias data[7:0] = lo_byte;
        alias hi_byte = data[63:56];
        //wire[31:0] tmp;
        //alias tmp = data[31:0];
		/*        
		logic a,b;
		assign a= c;
		wire logic  f;
		assign f = d;
		*/
        always_ff@(posedge clock)begin
            //assign q = 64'h1;
			//assign b= c;
        	//q = 64'h1;
		end
        
endmodule
/*
module net_test2(output logic [63:0]q,
        input [63:0]d,
        input clock, reset);
        wire[63:0] outp, inp;
        alias inp = d;      //infers inp is a 64-bit wire
        //alias outp = q;     //infers outp is a 64-bit wire
        alias rstN = reset; //infes 1-bit wire

        wire[63:0] data;
        wire[7:0] lo_byte, hi_byte;
        alias data[7:0] = lo_byte;
        alias hi_byte = data[63:56];
        //wire[31:0] tmp;
        //alias tmp = data[31:0];
endmodule
*/