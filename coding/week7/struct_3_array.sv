module arraytest();
	struct packed{
		int i_vec;
		//int [7:0] i_pack;
		//int i_pack[7:0];
		logic [7:0] tag; // packed array
		//int i_a[7:0];	// Error! Field 'i_a' in packed struct is not packed.
	}tst_pack;
	
	//int [7:0] i;//Error! Can't have packed array of integer type
	reg [7:0] i_reg; //right! packed array must have the basic type of reg, logic, byte, not int
endmodule