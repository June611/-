//detect the const varivable features
module aconst();
logic [7:0] addr = 8'haa;
const logic [7:0] taddr = addr;

initial begin
//addr = 8'haa;
//taddr = 8'hxx;  unstable state
//$display("taddr is 0x%h", taddr);

logic [7:0] b_addr = taddr;
$display("b_addr is 0x%h", b_addr);
end

endmodule