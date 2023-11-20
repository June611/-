//??????????
module tt_assign_output();
	function [3:0] add(input logic[3:0] a, logic[3:0] b, output overflow);
		// add = a+b;
		{overflow, add} = a+b;	
	endfunction

	logic[3:0] a, b, d, e;
	wire[3:0] c;
	
	assign d = add(a,b,e);
	assign c = add(a,b,e);
	initial begin
		
		a = 1;
		b = 2;
		assign e = add(a,b,e);
		
	end
endmodule