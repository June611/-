`timescale 1ns/100ps
module testbench;
reg Clock;



//the instance of the module to be test
print_test  DUT( Clock);	
initial
begin
	Clock = 0;
	forever
	#5 Clock = ~Clock;
end


endmodule