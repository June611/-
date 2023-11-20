module circuit(input logic[15:0]a, b, output logic[15:0] y);
  
	logic [2:0] opcode;
    always_comb begin
		unique case(opcode)
			3'b000: y = a+b;
			3'b001: y = a-b;
			3'b010: y = a*b;
			3'b100: y = a+b+1;
	endcase
endmodule