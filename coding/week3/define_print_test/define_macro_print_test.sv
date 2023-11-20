module print_test(Clock);
	input Clock;
initial
begin
`define print1(v) $display("variable \"v\" = %d ", v)
`define print2(v) $display(`"variable "v" = %d` ", v)
`define print3(v) $display(`"variable \"v\" = %d` ", v)
`define print4(v) $display(`"variable `\"v`\" = %d` ", v)
`define print5(v) $display("variable "v" = %d ", v)
`define print6(v) $display(`"variable \`"v\`" = %d` ", v)
`define print7(v) $display(`"variable `\`"v`\`" = %d` ", v)	
automatic int i =0;
	`print1(i);
	`print2(i);
	`print3(i);
	`print4(i);
	`print5(i);
	`print6(i);
	`print7(i);
end
endmodule