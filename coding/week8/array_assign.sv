module array_assgin();
	initial begin
		typedef int data_t [3:0][7:0]; //unpacked array
		data_t a;	//unpacked array
		byte b[1:0][3:0][3:0];	//unpacked array
		byte c[3:0];
		bit d[1:0][3:0][3:0];
		int e[1:0][3:0][3:0]; 
		a = data_t'(b);	//convert   error!
   		a = data_t'(c);	//convert   error!
		a = data_t'(d);//conver  	error!
		a =  data_t'(e); //			right
	end
endmodule