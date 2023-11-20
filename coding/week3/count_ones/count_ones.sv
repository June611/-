module aatest();
 logic [31:0] a=15;

function int count_ones(input [31:0] data);
	automatic logic [31:0] count = 0;
	automatic logic [31:0] temp = data;

	for(int i=0; i<32; i++ ) begin
		$display("temp[0] is %d",temp[0]);
		if(temp[0]) count++;
		temp>>=1;
	end
	return count;
endfunction

initial
begin
int c;
#1 a = 15;
c = count_ones(a);
#1 a=16;
 $display("c is %d", c);
end

endmodule