`timescale 1ns/1ps

// wires everything together — master, decoder, 3 slaves and the mux
module ahb_top (
    input  wire HCLK,    // clock for the whole system
    input  wire HRESETn  // reset for the whole system
);

    // signals from master going out to the bus
    wire [31:0] HADDR;
    wire        HWRITE;
    wire [2:0]  HSIZE;
    wire [2:0]  HBURST;
    wire [3:0]  HPROT;
    wire [1:0]  HTRANS;
    wire        HMASTLOCK;
    wire [31:0] HWDATA;

    // signals coming back from the bus to the master
    wire [31:0] HRDATA;
    wire        HREADY;
    wire        HRESP;

    // which slave the decoder picked
    wire HSEL_1, HSEL_2, HSEL_3;

    // each slave's individual response lines
    wire [31:0] HRDATA_1,    HRDATA_2,    HRDATA_3;
    wire        HREADYOUT_1, HREADYOUT_2, HREADYOUT_3;
    wire        HRESP_1,     HRESP_2,     HRESP_3;

    // the one who starts every transfer
    ahb_master u_master (
        .HRESETn   (HRESETn),
        .HCLK      (HCLK),
        .HREADY    (HREADY),
        .HRESP     (HRESP),
        .HRDATA    (HRDATA),
        .HADDR     (HADDR),
        .HWRITE    (HWRITE),
        .HSIZE     (HSIZE),
        .HBURST    (HBURST),
        .HPROT     (HPROT),
        .HTRANS    (HTRANS),
        .HMASTLOCK (HMASTLOCK),
        .HWDATA    (HWDATA)
    );

    // figures out which slave the address belongs to
    ahb_decoder u_decoder (
        .HADDR  (HADDR),
        .HSEL_1 (HSEL_1),
        .HSEL_2 (HSEL_2),
        .HSEL_3 (HSEL_3)
    );

    // handles addresses starting at 0x1000_0000
    ahb_slave u_slave1 (
        .HRESETn   (HRESETn),
        .HCLK      (HCLK),
        .HSELX     (HSEL_1),
        .HADDR     (HADDR),
        .HWRITE    (HWRITE),
        .HTRANS    (HTRANS),
        .HSIZE     (HSIZE),
        .HBURST    (HBURST),
        .HPROT     (HPROT),
        .HMASTLOCK (HMASTLOCK),
        .HREADY    (HREADY),
        .HWDATA    (HWDATA),
        .HRDATA    (HRDATA_1),
        .HREADYOUT (HREADYOUT_1),
        .HRESP     (HRESP_1)
    );

    // handles addresses starting at 0x2000_0000
    ahb_slave u_slave2 (
        .HRESETn   (HRESETn),
        .HCLK      (HCLK),
        .HSELX     (HSEL_2),
        .HADDR     (HADDR),
        .HWRITE    (HWRITE),
        .HTRANS    (HTRANS),
        .HSIZE     (HSIZE),
        .HBURST    (HBURST),
        .HPROT     (HPROT),
        .HMASTLOCK (HMASTLOCK),
        .HREADY    (HREADY),
        .HWDATA    (HWDATA),
        .HRDATA    (HRDATA_2),
        .HREADYOUT (HREADYOUT_2),
        .HRESP     (HRESP_2)
    );

    // handles addresses starting at 0x3000_0000
    ahb_slave u_slave3 (
        .HRESETn   (HRESETn),
        .HCLK      (HCLK),
        .HSELX     (HSEL_3),
        .HADDR     (HADDR),
        .HWRITE    (HWRITE),
        .HTRANS    (HTRANS),
        .HSIZE     (HSIZE),
        .HBURST    (HBURST),
        .HPROT     (HPROT),
        .HMASTLOCK (HMASTLOCK),
        .HREADY    (HREADY),
        .HWDATA    (HWDATA),
        .HRDATA    (HRDATA_3),
        .HREADYOUT (HREADYOUT_3),
        .HRESP     (HRESP_3)
    );

    // routes the right slave's data back to the master
    ahb_mux u_mux (
        .HCLK        (HCLK),
        .HRESETn     (HRESETn),
        .HREADY_IN   (HREADY),
        .HSEL_1      (HSEL_1),
        .HSEL_2      (HSEL_2),
        .HSEL_3      (HSEL_3),
        .HRDATA_1    (HRDATA_1),
        .HRDATA_2    (HRDATA_2),
        .HRDATA_3    (HRDATA_3),
        .HREADYOUT_1 (HREADYOUT_1),
        .HREADYOUT_2 (HREADYOUT_2),
        .HREADYOUT_3 (HREADYOUT_3),
        .HRESP_1     (HRESP_1),
        .HRESP_2     (HRESP_2),
        .HRESP_3     (HRESP_3),
        .HRDATA      (HRDATA),
        .HREADY      (HREADY),
        .HRESP       (HRESP)
    );

endmodule
