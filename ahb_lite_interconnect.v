module ahb_lite_interconnect_4s (
    // master -> interconnect (inputs)
    input  wire [31:0] M_HADDR,
    input  wire [1:0]  M_HTRANS,
    input  wire        M_HWRITE,
    input  wire [2:0]  M_HSIZE,
    input  wire [31:0] M_HWDATA,

    // interconnect -> master (responses)
    output wire [31:0] M_HRDATA,
    output wire        M_HREADY,
    output wire        M_HRESP,

    // broadcast to slaves (same for all)
    output wire [31:0] S_HADDR,
    output wire [1:0]  S_HTRANS,
    output wire        S_HWRITE,
    output wire [2:0]  S_HSIZE,
    output wire [31:0] S_HWDATA,

    // decoder-generated selects
    output wire [3:0]  S_HSEL,

    // responses from each slave
    input  wire [31:0] S_HRDATA0, S_HRDATA1, S_HRDATA2, S_HRDATA3,
    input  wire        S_HREADY0, S_HREADY1, S_HREADY2, S_HREADY3,
    input  wire        S_HRESP0,  S_HRESP1,  S_HRESP2,  S_HRESP3
);

    // broadcast address/control/data to slaves
    assign S_HADDR  = M_HADDR;
    assign S_HTRANS = M_HTRANS;
    assign S_HWRITE = M_HWRITE;
    assign S_HSIZE  = M_HSIZE;
    assign S_HWDATA = M_HWDATA;

    // decoder: one-hot HSEL
    ahb_addr_decoder DEC (
        .HADDR(M_HADDR),
        .valid(M_HTRANS != 2'b00),
        .HSEL(S_HSEL)
    );

    // response mux: pick from selected slave
    wire [31:0] mux_hrdata;
    wire        mux_hready;
    wire        mux_hresp;

    ahb_resp_mux MUX (
        .HSEL   (S_HSEL),
        .HRDATA0(S_HRDATA0), .HRDATA1(S_HRDATA1),
        .HRDATA2(S_HRDATA2), .HRDATA3(S_HRDATA3),
        .HREADY0(S_HREADY0), .HREADY1(S_HREADY1),
        .HREADY2(S_HREADY2), .HREADY3(S_HREADY3),
        .HRESP0 (S_HRESP0),  .HRESP1(S_HRESP1),
        .HRESP2(S_HRESP2),  .HRESP3(S_HRESP3),
        .HRDATA (mux_hrdata),
        .HREADY (mux_hready),
        .HRESP  (mux_hresp)
    );

    assign M_HRDATA = mux_hrdata;
    assign M_HREADY = mux_hready;
    assign M_HRESP  = mux_hresp;
endmodule

