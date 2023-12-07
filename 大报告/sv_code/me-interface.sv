`include "ahb_pkg.sv"
interface AHB_BUS_T(input HCLK, HRESETn);
//slave's signals
    
    //select
    logic HSELx ; // choose slave
    //address and control
    logic [31:0] HADDR;
    logic HWRITE;   // 1:write, 0:read
    logic [1:0]HTRANS;
    logic [2:0] HSIZE;
    logic [2:0]HBURST;
    //data
    logic [31:0] HWDATA;

    logic HREADY;
    logic [1:0]HRESP;
    logic [31:0]HRDATA;
//master's 
    logic HGRANTx;
    logic [?] HBUSREQx;
    logic [?] HLOCKx;
    logci [3:0]HPORT;

// arbiter's
    logic HBUSREQx
    logic HLOCKx;
    
    logic [15:0] HSPLITx;
    logic HGRANTx; // out:grant which master to use bus
    logic [3:0] HMASTER; // what is it mean?
    logic MASTERLOCK;


    modport ahb_slave_t(
        input HCLK,
        input HRESETn,
        input HSELx,
        input HADDR,
        input HWRITE,
        input HTRANS,
        input HSIZE,
        input HBURST,
        input HWDATA,
        output HREADY,
        output HRESP,
        output HRDATA
    )

    modport ahb_master_t(
        input HCLK,
        input HRESETn,
        input HGRANTx,
        input HREADY,
        input HRESP,
        input HRDATA,
        output HBUSREQx,
        output HLOCKx,
        output HTRANS,
        output HADDR,
        output HWRITE,
        output HSIZE,
        output HBURST,
        output HPROT,
        output HWDATA
    )

    modport ahb_arbiter_t(
        input HCLK,
        input HRESETn,
        input HBUSREQx,
        input HLOCKx,
        input HADDR,
        input HSPLITx,
        input HTRANS,
        input HRESP,
        input HBURST,
        input HREADY,
        output HGRANTx,
        output HMASTER,
        output HMASTLOCK
    )

    modport ahb_decoder_t(
        input HCLK,
        input HRESETn,
        input HADDR,
        output HSELx
    )
endinterface