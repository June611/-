module dec2x4(A, B, Enable, Z);
input A, B, Enable;
output[3:0] Z;
reg [3:0] Z_o;
assign Z = Z_o;
always@(A or B or Enable)
begin 
if(Enable == 1'b0)
	Z_o = 4'b1111;
else 
	case({A, B})
		2'b00: Z_o = 4'b1110;
		2'b01: Z_o = 4'b1101;
		2'b10: Z_o = 4'b1011;
		2'b11: Z_o = 4'b0111;
		default: Z_o = 4'b1111;
	endcase
end
endmodule