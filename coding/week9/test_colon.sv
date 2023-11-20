module test_colon();

	
	logic[3:0] check;
	logic[15:0] cg;
	logic[15:0] data;

	initial begin
		//data = 16'haaaa;
		data = 16'b11111110110111001011101010011000;
		check = 4'h00;

		for(int i=0; i<4; i++) begin
			check[i] = data[(i*4)+:4];
			$display("check[%d] is %d", i, check[i]);
			$display("data[(i*4)+:4] is %d", data[(i*4)+:4]);
			//$display("data[4+:(i*4)] is %d", data[4+:(i*4)]);
			cg = data[(i*4)+:4];
			$display("cg is %d", cg);

		end
	end
	

endmodule