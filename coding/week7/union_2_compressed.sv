module compressd_union();

	union tagged packed{	//tagged one
		logic [15:0] short_word;
		logic [31:0 ] word;
		logic [63:0] long_word;
	}data_word;

	initial begin
	# 5 data_word = tagged word '1 ; //bug
	$display("union is %d", data_word);
	$display("test ");
	end
endmodule