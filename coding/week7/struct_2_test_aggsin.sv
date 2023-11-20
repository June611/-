module teststruct();
	typedef struct{
		logic [31:0] a, b;
		logic[7:0] opcode;
		logic[23:0] address;
	}instruction_word_t;
	instruction_word_t  IW;
	/*
	struct{
		logic [31:0] a, b;
		logic [7:0] opcode;
		logic [23:0] address;
	}instruction;
	//struct instruction iw;
	*/
	typedef struct{
		logic [31:0] a, b;
		logic [7:0] opcode;
		logic [23:0] address;
	}instruction_t;
	instruction_t instruction;
	initial begin
	IW = instruction;
	end

endmodule