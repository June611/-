`include "ahb_pkg.sv"
interface ahb_bus(
    input clk,
    input rstn
);
    logic  [1:0]    hgrant;
    logic           hready;
    hresp_t         hresp;
    logic  [31:0]   hrdata;
    logic  [1 :0]   hbusreq;
    logic  [1:0]    hlock;
    htrans_t        htrans;
    logic  [31:0]   haddr;
    hwrite_t        hwrite;
    hsize_t         hsize;
    hburst_t        hburst;
    logic  [3:0]    hprot;
    logic  [31:0]   hwdata;
    logic  [1:0]    hsplit;//default [15:0]
    logic  [1:0]    hsel;
    logic  [3:0]    hmaster;
    logic           hmastlock;

    modport master(
        input  hgrant,
        input  hready,
        input  hresp,
        input  hrdata,
        //input  hmaster,//not in standard
        output hbusreq,
        output hlock,
        output htrans,
        output haddr,
        output hwrite,
        output hsize,
        output hburst,
        output hprot,
        output hwdata,
        input  clk,
        input  rstn
    );

    modport slave(
        input  hsel,
        input  haddr,
        input  hwrite,
        input  htrans,
        input  hsize,
        input  hburst,
        input  hwdata,
        input  hmaster,
        input  hmastlock,
        output hready,
        output hresp,
        output hrdata,
        output hsplit,
        input  clk,
        input  rstn
    );

    modport arbiter(
        input  hbusreq,
        input  hlock,
        input  hsplit,
        input  htrans,
        input  hburst,
        input  hresp,
        input  hready,
        output hgrant,
        output hmaster,
        output hmastlock,
        input  clk,
        input  rstn
    );
    modport decode(
        input  haddr,
        output hsel,
        input  htrans,
        output hresp,
        input  clk,
        input  rstn
    );
endinterface
