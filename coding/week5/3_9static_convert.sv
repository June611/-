//compiling convert
//static forcing convert will not detect the error!
module converttest();

typedef enum{ s1, s2, s3} states_t;
states_t state, next_state;
always_comb begin
	if(state == s3)
		next_state = states_t'(state+1);
	//else next_state = s1;
end

initial
begin
 state = s1;
state = s2;
state = s3;
end

endmodule
