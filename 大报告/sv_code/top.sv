module top();
    logic clk;
    logic rstn;
    
    ahb_bus bus(
        .clk(clk),
        .rstn(rstn)
    );

    master #(.mas_id(0)) master0(bus.master);
    master #(.mas_id(1)) master1(bus.master);
    slave  #(.sla_id(0)) slave0(bus.slave); 
    slave  #(.sla_id(1)) slave1(bus.slave);
    arbiter arbiter(bus.arbiter);                       
    decode  decode(bus.decode);  

    initial begin
        clk = 1'b0;
        rstn= 1'b0;
    #10  rstn= 1'b1;
    #205 $stop;
    end

    always #5 clk = ~clk;
endmodule
