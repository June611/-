module FSM();

enum {GO, WAIT, DONE} fsm2;
always@ ( *)
begin
	enum {GO, STOP} fsm1;
	fsm1 = GO;
	fsm2 = GO;//An enum variable 'fsm2' may only be assigned the same enum typed variable or one of its values. Variable 'GO' is not valid.
end

endmodule