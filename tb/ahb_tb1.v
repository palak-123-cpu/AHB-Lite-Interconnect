`timescale 1ns/1ps

// the tester — drives signals, checks results, prints pass or fail
module ahb_tb;

    reg  HCLK;    // clock we generate ourselves
    reg  HRESETn; // we control reset too

    initial  HCLK = 1'b0;
    always #5 HCLK = ~HCLK; // flips every 5ns → 100MHz clock

    // we drive these — so they're reg
    reg  [31:0] HADDR;
    reg         HWRITE;
    reg  [2:0]  HSIZE;
    reg  [2:0]  HBURST;
    reg  [3:0]  HPROT;
    reg  [1:0]  HTRANS;
    reg         HMASTLOCK;
    reg  [31:0] HWDATA;

    // DUT drives these back to us — so they're wire
    wire [31:0] HRDATA;
    wire        HREADY;
    wire        HRESP;

    // select lines from decoder
    wire HSEL_1, HSEL_2, HSEL_3;

    // each slave's individual output lines
    wire [31:0] HRDATA_1,    HRDATA_2,    HRDATA_3;
    wire        HREADYOUT_1, HREADYOUT_2, HREADYOUT_3;
    wire        HRESP_1,     HRESP_2,     HRESP_3;

    localparam IDLE   = 2'b00; // no transfer
    localparam NONSEQ = 2'b10; // start of a transfer

    // plug in the decoder
    ahb_decoder u_decoder (
        .HADDR  (HADDR),
        .HSEL_1 (HSEL_1),
        .HSEL_2 (HSEL_2),
        .HSEL_3 (HSEL_3)
    );

    // plug in slave 1
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

    // plug in slave 2
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

    // plug in slave 3
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

    // plug in the mux
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

    // sends one write transfer to a given address
    task ahb_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge HCLK); #1;
            // address phase — tell slave where and what we're doing
            HADDR     = addr;
            HWRITE    = 1'b1;
            HTRANS    = NONSEQ;
            HSIZE     = 3'b010;
            HBURST    = 3'b000;
            HPROT     = 4'b0011;
            HMASTLOCK = 1'b0;

            @(posedge HCLK); #1;
            // data phase — put the actual data on the bus
            HWDATA = data;
            HTRANS = IDLE;

            @(posedge HCLK); #1; // give slave one more cycle to finish
            HADDR  = 32'h0;
            HWRITE = 1'b0;
        end
    endtask

    // sends one read transfer and returns whatever the slave gives back
    task ahb_read;
        input  [31:0] addr;
        output [31:0] data;
        begin
            @(posedge HCLK); 
            #1;
            // address phase
            HADDR     = addr;
            HWRITE    = 1'b0;
            HTRANS    = NONSEQ;
            HSIZE     = 3'b010;
            HBURST    = 3'b000;
            HPROT     = 4'b0011;
            HMASTLOCK = 1'b0;

            @(posedge HCLK); 
            #1;
            // data phase — grab whatever the slave put on HRDATA
            HTRANS = IDLE;
            data   = HRDATA;

            @(posedge HCLK);
             #1;
            HADDR = 32'h0;
        end
    endtask

    reg [31:0] rd_data;
    integer    pass_count, fail_count;

    initial begin
        // start everything at zero
        HADDR = 32'h0; HWRITE = 1'b0; HSIZE = 3'b010;
        HBURST = 3'b000; HPROT = 4'b0000;
        HTRANS = IDLE; HMASTLOCK = 1'b0; HWDATA = 32'h0;
        pass_count = 0; fail_count = 0;

        // hold reset low for a few cycles then release
        HRESETn = 1'b0;
        
        @(posedge HCLK); #1;
        HRESETn = 1'b1;
       

        $display("========================================");
        $display("  AHB-Lite Testbench");
        $display("========================================");

        // test slave 1
        $display("\n--- Slave 1 Tests ---");

        ahb_write(32'h1000_0000, 32'hAABB_CCDD);
        ahb_read (32'h1000_0000, rd_data);
        if (rd_data === 32'hAABB_CCDD) begin
            $display("[PASS] S1[0x1000_0000] wrote=0xAABBCCDD read=0x%08h", rd_data);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] S1[0x1000_0000] expected=0xAABBCCDD got=0x%08h", rd_data);
            fail_count = fail_count + 1;
        end

        ahb_write(32'h1000_0004, 32'h1111_2222);
        ahb_read (32'h1000_0004, rd_data);
        if (rd_data === 32'h1111_2222) begin
            $display("[PASS] S1[0x1000_0004] wrote=0x11112222 read=0x%08h", rd_data);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] S1[0x1000_0004] expected=0x11112222 got=0x%08h", rd_data);
            fail_count = fail_count + 1;
        end

        // test slave 2
        $display("\n--- Slave 2 Tests ---");
        ahb_write(32'h2000_0004, 32'h1234_5678);
        ahb_read (32'h2000_0004, rd_data);
        if (rd_data === 32'h1234_5678) begin
            $display("[PASS] S2[0x2000_0004] wrote=0x12345678 read=0x%08h", rd_data);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] S2[0x2000_0004] expected=0x12345678 got=0x%08h", rd_data);
            fail_count = fail_count + 1;
        end

        ahb_write(32'h2000_0008, 32'hEEEE_FFFF);
        ahb_read (32'h2000_0008, rd_data);
        if (rd_data === 32'hEEEE_FFFF) begin
            $display("[PASS] S2[0x2000_0008] wrote=0xEEEE_FFFF read=0x%08h", rd_data);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] S2[0x2000_0008] expected=0xEEEE_FFFF got=0x%08h", rd_data);
            fail_count = fail_count + 1;
        end

        // test slave 3
        $display("\n--- Slave 3 Tests ---");
        ahb_write(32'h3000_0008, 32'h9999_6666);
        ahb_read (32'h3000_0008, rd_data);
        if (rd_data === 32'h9999_6666) begin
            $display("[PASS] S3[0x3000_0008] wrote=0x9999_6666 read=0x%08h", rd_data);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] S3[0x3000_0008] expected=0x9999_6666 got=0x%08h", rd_data);
            fail_count = fail_count + 1;
        end

        ahb_write(32'h3000_000C, 32'h2005_2006);
        ahb_read (32'h3000_000C, rd_data);
        if (rd_data === 32'h2802_1702) begin
            $display("[PASS] S3[0x3000_000C] wrote=2005_2006 read=0x%08h", rd_data);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] S3[0x3000_000C] expected=0x2005_2006 got=0x%08h", rd_data);
            fail_count = fail_count + 1;
        end

        // make sure writing to slave 2 and 3 didn't mess up slave 1
        $display("\n--- Cross-Slave Independence ---");
        ahb_read(32'h1000_0004, rd_data);
        if (rd_data === 32'h1111_2222) begin
            $display("[PASS] S1 data still intact after S2/S3 writes");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] S1 data got corrupted! got=0x%08h", rd_data);
            fail_count = fail_count + 1;
        end

        $display("\n========================================");
        $display("  RESULTS: %0d PASSED  %0d FAILED", pass_count, fail_count);
        $display("========================================\n");

        repeat(4) @(posedge HCLK);
        $stop; // pause here so Vivado keeps the waveform window open
    end

endmodule
