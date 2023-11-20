module add_and_increment(output logic [63:0] sum,
						output logic carry,
						input logic [63:0] a,b);
	always @(a,b)
		sum = a+b;		//procudural assignment to sum
	//assign sum = sum + 1;	//Error! sum is already being assigned a value
	
	look_ahead i1(carry, a, b);	//module instance drives carry
	overflow_check i2(carry, a , b);	//Error! 2nd driver of carry 
endmodule

module look_ahead(output wire  carry,	
					input logic [63:0] a, b);

endmodule

module overflow_check(output wire carry,	
					input logic [63:0] a, b);

endmodule