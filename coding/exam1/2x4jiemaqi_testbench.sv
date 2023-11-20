`timescale 1ns/100ps
module testbench;
reg a, b, en;
wire [3:0] z;

//实例化被测试模块
dec2x4 DUT(.A(a), .B(b), .Enable(en), .Z(z));

//产生输入激励
initial
begin
	en = 0;
	a = 0;
	b = 0;
	#10 en = 1;
	#10 b = 1;
	#10 a = 1;
	#10 b = 0;
	#10 a = 0;
	#10 $stop;
end

//print result
always@(en or a or b or z)
begin
	$display("at time %t, input is %b%b%b, output is %b", $time, a ,b ,en, z);
end 

endmodule