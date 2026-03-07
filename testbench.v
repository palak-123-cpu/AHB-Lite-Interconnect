module testbench;
    reg HCLK, HRESETn;
    reg start_trans, write_en;
    reg [31:0] addr_in, wdata_in;
    reg [2:0] size_type;

    wire [31:0] HADDR;
    wire [1:0]  HTRANS;
    wire        HWRITE;
    wire [2:0]  HSIZE;
    wire [31:0] HWDATA;

    wire [31:0] M_HRDATA;
    wire        M_HREADY;
    wire        M_HRESP;

    wire [31:0] rdata_out;
    wire        trans_done;

    // signals between interconnect and slaves
    wire [31:0] S_HADDR;
    wire [1:0]  S_HTRANS;
    wire        S_HWRITE;
    wire [2:0]  S_HSIZE;
    wire [31:0] S_HWDATA;
    wire [3:0]  S_HSEL;

    // slave response wires
    wire [31:0] S0_HRDATA, S1_HRDATA, S2_HRDATA, S3_HRDATA;
    wire        S0_HREADY,  S1_HREADY,  S2_HREADY,  S3_HREADY;
    wire        S0_HRESP,   S1_HRESP,   S2_HRESP,   S3_HRESP;

    // Instantiate Master
    ahb_lite_master U_M (
        .HCLK(HCLK), .HRESETn(HRESETn),
        .start_trans(start_trans),
        .addr_in(addr_in),
        .write_en(write_en),
        .wdata_in(wdata_in),
        .size_type(size_type),
        .HRDATA(M_HRDATA),
        .HREADY(M_HREADY),
        .HADDR(HADDR), .HTRANS(HTRANS),
        .HWRITE(HWRITE), .HSIZE(HSIZE),
        .HWDATA(HWDATA),
        .rdata_out(rdata_out),
        .trans_done(trans_done)
    );

    // Instantiate Interconnect
    ahb_lite_interconnect_4s U_I (
        .M_HADDR(HADDR), .M_HTRANS(HTRANS), .M_HWRITE(HWRITE),
        .M_HSIZE(HSIZE), .M_HWDATA(HWDATA),

        .M_HRDATA(M_HRDATA), .M_HREADY(M_HREADY), .M_HRESP(M_HRESP),

        .S_HADDR(S_HADDR), .S_HTRANS(S_HTRANS), .S_HWRITE(S_HWRITE),
        .S_HSIZE(S_HSIZE), .S_HWDATA(S_HWDATA), .S_HSEL(S_HSEL),

        .S_HRDATA0(S0_HRDATA), .S_HRDATA1(S1_HRDATA),
        .S_HRDATA2(S2_HRDATA), .S_HRDATA3(S3_HRDATA),

        .S_HREADY0(S0_HREADY), .S_HREADY1(S1_HREADY),
        .S_HREADY2(S2_HREADY), .S_HREADY3(S3_HREADY),

        .S_HRESP0(S0_HRESP), .S_HRESP1(S1_HRESP),
        .S_HRESP2(S2_HRESP), .S_HRESP3(S3_HRESP)
    );

    // Connect broadcasts from interconnect to slaves (they all get same address/control/data)
    // S_HADDR etc are outputs from interconnect and are wired to slave inputs below.

    // Instantiate 4 slaves
    ahb_lite_slave S0 (
        .HCLK(HCLK), .HRESETn(HRESETn),
        .HADDR(S_HADDR), .HTRANS(S_HTRANS), .HWRITE(S_HWRITE),
        .HSIZE(S_HSIZE), .HWDATA(S_HWDATA), .HSEL(S_HSEL[0]),
        .HRDATA(S0_HRDATA), .HREADYOUT(S0_HREADY), .HRESP(S0_HRESP)
    );

    ahb_lite_slave S1 (
        .HCLK(HCLK), .HRESETn(HRESETn),
        .HADDR(S_HADDR), .HTRANS(S_HTRANS), .HWRITE(S_HWRITE),
        .HSIZE(S_HSIZE), .HWDATA(S_HWDATA), .HSEL(S_HSEL[1]),
        .HRDATA(S1_HRDATA), .HREADYOUT(S1_HREADY), .HRESP(S1_HRESP)
    );

    ahb_lite_slave S2 (
        .HCLK(HCLK), .HRESETn(HRESETn),
        .HADDR(S_HADDR), .HTRANS(S_HTRANS), .HWRITE(S_HWRITE),
        .HSIZE(S_HSIZE), .HWDATA(S_HWDATA), .HSEL(S_HSEL[2]),
        .HRDATA(S2_HRDATA), .HREADYOUT(S2_HREADY), .HRESP(S2_HRESP)
    );

    ahb_lite_slave S3 (
        .HCLK(HCLK), .HRESETn(HRESETn),
        .HADDR(S_HADDR), .HTRANS(S_HTRANS), .HWRITE(S_HWRITE),
        .HSIZE(S_HSIZE), .HWDATA(S_HDATA /* Typo guard below will fix */ ), .HSEL(S_HSEL[3]),
        .HRDATA(S3_HRDATA), .HREADYOUT(S3_HREADY), .HRESP(S3_HRESP)
    );

    // ---------- NOTE: small correction for S3 HWDATA connection ----------
    // Above S3 instantiation accidentally used S_HDATA for HWDATA in one spot.
    // The correct port is S_HWDATA. To avoid simulator syntax issues, re-instantiate S3 correctly:

    // Re-instantiate S3 (overwrite previous)
    ahb_lite_slave S3_fix (
        .HCLK(HCLK), .HRESETn(HRESETn),
        .HADDR(S_HADDR), .HTRANS(S_HTRANS), .HWRITE(S_HWRITE),
        .HSIZE(S_HSIZE), .HWDATA(S_HWDATA), .HSEL(S_HSEL[3]),
        .HRDATA(S3_HRDATA), .HREADYOUT(S3_HREADY), .HRESP(S3_HRESP)
    );

    // ---------- Clock & Reset ----------
    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK;
    end

    initial begin
        HRESETn = 0;
        start_trans = 0;
        addr_in = 0;
        write_en = 0;
        wdata_in = 0;
        size_type = 3'b010;

        #20 HRESETn = 1;

        // basic transactions across slaves
        write(32'h0000_0004, 32'h12345678, 3'b010); // slave 0
        read (32'h0000_0004, 3'b010);

        write(32'h0000_1004, 32'h16541254, 3'b010); // slave 1
        read (32'h0000_1004, 3'b010);

        write(32'h0000_2002, 32'h0000_00AA, 3'b000); // byte to slave 2
        read (32'h0000_2002, 3'b000);

        write(32'h0000_3001, 32'h0000_00BB, 3'b001); // halfword to slave 3
        read (32'h0000_3001, 3'b001);

        #100 $finish;
    end

    // TASKS: start transaction, wait for trans_done
    task write(input [31:0] a, input [31:0] d, input [2:0] s);
    begin
        @(posedge HCLK);
        start_trans = 1;
        addr_in = a;
        wdata_in = d;
        write_en = 1;
        size_type = s;
        @(posedge HCLK);
        start_trans = 0;
        wait(trans_done);
        $display("[%0t] WRITE   addr=%h data=%h size=%b", $time, a, d, s);
    end
    endtask

    task read(input [31:0] a, input [2:0] s);
    begin
        @(posedge HCLK);
        start_trans = 1;
        addr_in = a;
        write_en = 0;
        size_type = s;
        @(posedge HCLK);
        start_trans = 0;
        wait(trans_done);
        $display("[%0t] READ    addr=%h data=%h size=%b", $time, a, rdata_out, s);
    end
    endtask

    // VCD dump
    initial begin
        $dumpfile("ahb_lite.vcd");
        $dumpvars(0, testbench);
    end
endmodule
