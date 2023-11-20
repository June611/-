module aatest();
 logic [31:0] a=15;

function int count_ones(input [31:0] data);
	logic [31:0] count = 0;
	logic [31:0] temp = data;

	for(int k=0; k<32; k++ ) begin
		$display("temp[%d] is %d",k,temp[k]);
		if(temp[k]) count++;
	end
	return count;
endfunction

initial
begin
int c;
c = count_ones(a);
 $display("c is %d", c);
end

endmodule