module union_rw();
	union{
		byte i;
		byte unsigned u;
	}data;
	
	initial begin
		data.i = -5;
		$display("data is %d", data.i);
		//data.u = -5; 
		$display("data is  %d", data.u);
	end

endmodule