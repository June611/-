//""" 时序检测器"""
module Count3_1s(Data, Clock, Detect3_1s);
	integer Count;
	//reg Detect3_1s;
	input Data, Clock;
	output Detect3_1s;
	logic Detect3_1s;
initial
begin
	Count = 0;
	Detect3_1s = 0;
end

always@(posedge Clock)
begin
	if(Data == 1)
		Count = Count + 1;  
	else
		Count = 0;
	if(Count > 3)
		Detect3_1s = 1;
	else
		Detect3_1s = 0;
	$display("this time is %t, Count is %d", $time, Count);
end 
endmodule
	