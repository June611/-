module s1();
	var struct{
		logic[31:0] a,b;
		logic[7:0] opcode;
		logic[23:0] address;
	}instruction_word_var;
	
	wire struct{
		logic[31:0] a, b;
		logic[7:0] opcode;
		logic[23:0] address;
	}instruction_word_net;

endmodule