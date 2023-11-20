module compare(output lt, eq, gt,
		input logic [63:0] a, b);
	always @(a, b)
		if(a<b) lt = 1'b1;	//process fetech value
		else lt = 1'b0;
	assign gt = (a>b);		//fetch a value again
	comparator ul(eq, a, b);	//模块实例化
endmodule

module comparator(output logic eq,	
		input logic [63:0] a, b);
	always @(a, b)
		eq = (a==b);
endmodule